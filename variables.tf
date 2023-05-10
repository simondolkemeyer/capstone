# Variables can be used to store values used in .tf code
# Use format as shown here. Use "var.[variable name]" to use in code

variable "key" {
    default = "nfdemo"
}

variable "ami" {
    default = "ami-0df24e148fdb9f1d8"
}

variable "dbstorage" {
    default = "20"
}