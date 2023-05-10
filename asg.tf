# Resources required for autoscaling

# basic autoscaling group

resource "aws_autoscaling_group" "autoscaling_group" {
    name = "auoscaling_group"
    min_size = 2
    max_size = 4
    health_check_type = "EC2"
    vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    target_group_arns =  [aws_lb_target_group.alb_target_group.arn]

    launch_template {
      id = aws_launch_template.launchtemp.id
    }
}

resource "aws_autoscaling_policy" "xl_asg_policy" {
    autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
    name = "xl-asg-policy"
    scaling_adjustment = 1 
    adjustment_type = "ChangeInCapacity"
}

resource "aws_launch_template" "launchtemp" {
    name_prefix = "launchtemp"
    image_id = var.ami
    instance_type = "t3.micro"
    key_name        = var.key
    # user data not yet functional, likely wrong syntax for base64
    user_data       =  base64encode(file("install_wp.sh"))
    vpc_security_group_ids = [aws_security_group.My_VPC_Security_group.id]


     monitoring {
      enabled = true
    }

    depends_on = [
      aws_security_group.My_VPC_Security_group
    ]
} 

# policy to activate upon "scale out metric alarm" from below
resource "aws_autoscaling_policy" "scale_out_policy" {
    autoscaling_group_name  = aws_autoscaling_group.autoscaling_group.id
    name                    = "scale-out-policy"
    scaling_adjustment      = 1 
    adjustment_type         = "ChangeInCapacity"
    policy_type             = "SimpleScaling"
}

# policy to activate upon "scale in metric alarm" from below
resource "aws_autoscaling_policy" "scale_in_policy" {
    autoscaling_group_name  = aws_autoscaling_group.autoscaling_group.id
    name                    = "scale-in-policy"
    scaling_adjustment      = -1 
    adjustment_type         = "ChangeInCapacity"
    policy_type             = "SimpleScaling"
}

# metric alarm to trigger scale out by 1 instance. set to >70% CPU threshold
resource "aws_cloudwatch_metric_alarm" "scale_out" {
    alarm_name              = "nf-scale-out-alarm"
    comparison_operator     = "GreaterThanOrEqualToThreshold"
    evaluation_periods      = 1
    metric_name             = "CPUUtilization"
    namespace               = "AWS/EC2"
    period                  = 60
    statistic               = "Average"
    threshold               = 70
    alarm_description       = "alarm for reaching >70% CPU threshold"
    alarm_actions           = [aws_autoscaling_policy.scale_out_policy.arn]
    
    dimensions = {
        "AutoScalingGroupName" = "${aws_autoscaling_group.autoscaling_group.name}"
    }
}

# metric alarm to trigger scale in by 1 instance. set to <20% CPU threshold
resource "aws_cloudwatch_metric_alarm" "scale_in" {
    alarm_name              = "nf-scale-in-alarm"
    comparison_operator     = "LessThanOrEqualToThreshold"
    evaluation_periods      = 1
    metric_name             = "CPUUtilization"
    namespace               = "AWS/EC2"
    period                  = 60
    statistic               = "Average"
    threshold               = 20
    alarm_description       = "alarm for reaching <20% CPU threshold"
    alarm_actions           = [aws_autoscaling_policy.scale_in_policy.arn]
    
    dimensions = {
        "AutoScalingGroupName" = "${aws_autoscaling_group.autoscaling_group.name}"
    }
} 

