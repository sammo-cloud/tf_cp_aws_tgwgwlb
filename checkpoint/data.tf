data "aws_instance" "ins_management" {
  depends_on = [
    aws_cloudformation_stack.checkpoint_gwlb_cloudformation_stack,
  ]
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-gwlb-management-server"]
  }
}
