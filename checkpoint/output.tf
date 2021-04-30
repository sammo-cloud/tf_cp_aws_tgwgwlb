output "output" {
   value = aws_cloudformation_stack.checkpoint_gwlb_cloudformation_stack.outputs["GWLBServiceName"]
}
