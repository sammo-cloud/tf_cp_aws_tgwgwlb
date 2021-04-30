# Deploy CP Geo Cluster for TGW cloudformation template
# https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Transit_Gateway_High_Availability/Content/Topics/Terms.htm?tocpath=_____4
resource "aws_cloudformation_stack" "checkpoint_gwlb_cloudformation_stack" {
  name = "${var.project_name}-GWLB"

  parameters = {
AdminCIDR	 = "0.0.0.0/0"
AllowUploadDownload	= true	
AvailabilityZones	= "ap-east-1a,ap-east-1b"
ConfigurationTemplate	= "${var.project_name}-gwlb-ASG-configuration"
ControlGatewayOverPrivateOrPublicAddress	= "private"
GWLBName	 = "${var.project_name}-gwlb1"
GWLBeSubnet1CIDR	= "10.0.14.0/24"
GWLBeSubnet2CIDR	= "10.0.24.0/24"
GWLBeSubnet3CIDR	= "10.0.34.0/24"
GWLBeSubnet4CIDR	= "10.0.44.0/24"
    GatewayInstanceType     = var.geocluster_gateway_size
GatewayManagement	= "Locally managed"
    GatewayVersion          = "${var.cpversion}-BYOL"
GatewaysAddresses	= "0.0.0.0/0"
GatewaysMaxSize	= 10
GatewaysMinSize	= 2
GatewaysPolicy	= "Standard"
ManagementDeploy	= true
ManagementInstanceType	= "m5.large"
ManagementPasswordHash	= var.password_hash
ManagementServer	= "${var.project_name}-gwlb-management-server"
ManagementVersion	= "${var.cpversion}-BYOL"
NatGwSubnet1CIDR	= "10.0.13.0/24"
NatGwSubnet2CIDR	= "10.0.23.0/24"
NatGwSubnet3CIDR	= "10.0.33.0/24"
NatGwSubnet4CIDR	= "10.0.43.0/24"
NumberOfAZs	= 2
PublicSubnet1CIDR	= "10.0.10.0/24"
PublicSubnet2CIDR	= "10.0.20.0/24"
PublicSubnet3CIDR	= "10.0.30.0/24"
PublicSubnet4CIDR	= "10.0.40.0/24"
Shell	= "/bin/bash"
TargetGroupName	= "${var.project_name}-tg1"
TgwSubnet1CIDR	= "10.0.12.0/24"
TgwSubnet2CIDR	= "10.0.22.0/24"
TgwSubnet3CIDR	= "10.0.32.0/24"
TgwSubnet4CIDR	= "10.0.42.0/24"
VPCCIDR	= "10.0.0.0/16"
    KeyName                 = aws_key_pair.key_TPOT.key_name
    GatewayPasswordHash     = var.password_hash
    Shell                   = "/bin/bash"
    GatewayName	            = "${var.project_name}-gwlb-gw"
    GatewaySICKey	    = var.sickey
}

  template_url        = "https://cgi-cfts.s3.amazonaws.com/gwlb/tgw-gwlb-master.yaml"
  capabilities        = ["CAPABILITY_IAM"]
  disable_rollback    = true
  timeout_in_minutes  = 50
}

resource "null_resource" "setup_management" {
  #provisioner "local-exec" {
  #    command = "sleep 900"
  #}

connection {
      host        = data.aws_instance.ins_management.public_ip
      user        = "admin"
      type        = "ssh"
      private_key = file("../tpot.pem")
      timeout     = "30m"
}

provisioner "file" {
    source      = "cme_installation.sh"
    destination = "/home/admin/cme_installation.sh"
}

provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'until mgmt_cli -r true discard ; do sleep 30; done'",
      "clish -c 'installer uninstall Check_Point_CPcme_Bundle_R80_40_T83.tgz'",
      "chmod 700 /home/admin/cme_installation.sh",
      "/home/admin/cme_installation.sh",
      "mgmt_cli -r true set access-layer name 'Network' applications-and-url-filtering true data-awareness true --format json;",
      "mgmt_cli -r true set access-rule layer Network rule-number 1 action 'Accept' track.accounting True track.type 'Log';"
      #"mgmt_cli -r true install-policy policy-package 'standard' access true threat-prevention false;",
      #"mgmt_cli -r true install-policy policy-package 'standard' access true threat-prevention true;"
    ]
  }
}
