locals {
  asg_tags = ["${null_resource.tags_as_list_of_maps.*.triggers}"]

  # Followed recommendation http://67bricks.com/blog/?p=85
  # to workaround terraform not supporting short circut evaluation
  cluster_security_group_id = "${coalesce(join("", aws_security_group.cluster.*.id), var.cluster_security_group_id)}"

  worker_security_group_id = "${coalesce(join("", aws_security_group.workers.*.id), var.worker_security_group_id)}"
  default_iam_role_id      = "${element(concat(aws_iam_role.workers.*.id, list("")), 0)}"
  kubeconfig_name          = "${var.kubeconfig_name == "" ? "eks_${var.cluster_name}" : var.kubeconfig_name}"

  workers_group_defaults_defaults = {
    name                          = "count.index"                   # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
    ami_id                        = "${data.aws_ami.eks_worker.id}" # AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI.
    asg_desired_capacity          = "1"                             # Desired worker capacity in the autoscaling group.
    asg_max_size                  = "3"                             # Maximum worker capacity in the autoscaling group.
    asg_min_size                  = "1"                             # Minimum worker capacity in the autoscaling group.
    instance_type                 = "m4.large"                      # Size of the workers instances.
    spot_price                    = ""                              # Cost of spot instance.
    placement_tenancy             = ""                              # The tenancy of the instance. Valid values are "default" or "dedicated".
    root_volume_size              = "100"                           # root volume size of workers instances.
    root_volume_type              = "gp2"                           # root volume type of workers instances, can be 'standard', 'gp2', or 'io1'
    root_iops                     = "0"                             # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
    key_name                      = ""                              # The key name that should be used for the instances in the autoscaling group
    use_default_userdata          = true                            # Use default userdata
    pre_userdata                  = ""                              # userdata to pre-append to the default userdata.
    additional_userdata           = ""                              # userdata to append to the default userdata.
    ebs_optimized                 = true                            # sets whether to use ebs optimization on supported types.
    enable_monitoring             = true                            # Enables/disables detailed monitoring.
    public_ip                     = false                           # Associate a public ip address with a worker
    kubelet_extra_args            = ""                              # This string is passed directly to kubelet if set. Useful for adding labels or taints.
    subnets                       = "${join(",", var.subnets)}"     # A comma delimited string of subnets to place the worker nodes in. i.e. subnet-123,subnet-456,subnet-789
    autoscaling_enabled           = false                           # Sets whether policy and matching tags will be added to allow autoscaling.
    additional_security_group_ids = ""                              # A comman delimited list of additional security group ids to include in worker launch config
    protect_from_scale_in         = false                           # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
    iam_role_id                   = "${local.default_iam_role_id}"  # Use the specified IAM role if set.
    suspended_processes           = ""                              # A comma delimited string of processes to to suspend. i.e. AZRebalance,HealthCheck,ReplaceUnhealthy
  }

  workers_group_defaults = "${merge(local.workers_group_defaults_defaults, var.workers_group_defaults)}"

  ebs_optimized = {
    "c1.medium"    = false
    "c1.xlarge"    = true
    "c3.2xlarge"   = true
    "c3.4xlarge"   = true
    "c3.8xlarge"   = false
    "c3.large"     = false
    "c3.xlarge"    = false
    "c4.2xlarge"   = true
    "c4.4xlarge"   = true
    "c4.8xlarge"   = true
    "c4.large"     = true
    "c4.xlarge"    = true
    "c5.18xlarge"  = true
    "c5.2xlarge"   = true
    "c5.4xlarge"   = true
    "c5.9xlarge"   = true
    "c5.large"     = true
    "c5.xlarge"    = true
    "c5d.18xlarge" = true
    "c5d.2xlarge"  = true
    "c5d.4xlarge"  = true
    "c5d.9xlarge"  = true
    "c5d.large"    = true
    "c5d.xlarge"   = true
    "cc2.8xlarge"  = false
    "cr1.8xlarge"  = false
    "d2.2xlarge"   = true
    "d2.4xlarge"   = true
    "d2.8xlarge"   = true
    "d2.xlarge"    = true
    "f1.16xlarge"  = true
    "f1.2xlarge"   = true
    "g2.2xlarge"   = true
    "g2.8xlarge"   = false
    "g3.16xlarge"  = true
    "g3.4xlarge"   = true
    "g3.8xlarge"   = true
    "h1.16xlarge"  = true
    "h1.2xlarge"   = true
    "h1.4xlarge"   = true
    "h1.8xlarge"   = true
    "hs1.8xlarge"  = false
    "i2.2xlarge"   = true
    "i2.4xlarge"   = true
    "i2.8xlarge"   = false
    "i2.xlarge"    = true
    "i3.16xlarge"  = true
    "i3.2xlarge"   = true
    "i3.4xlarge"   = true
    "i3.8xlarge"   = true
    "i3.large"     = true
    "i3.metal"     = true
    "i3.xlarge"    = true
    "m1.large"     = true
    "m1.medium"    = false
    "m1.small"     = false
    "m1.xlarge"    = true
    "m2.2large"    = false
    "m2.2xlarge"   = true
    "m2.4xlarge"   = true
    "m2.xlarge"    = false
    "m3.2xlarge"   = true
    "m3.large"     = false
    "m3.medium"    = false
    "m3.xlarge"    = true
    "m4.10xlarge"  = true
    "m4.16xlarge"  = true
    "m4.2xlarge"   = true
    "m4.4xlarge"   = true
    "m4.large"     = true
    "m4.xlarge"    = true
    "m5.12xlarge"  = true
    "m5.24xlarge"  = true
    "m5.2xlarge"   = true
    "m5.4xlarge"   = true
    "m5.large"     = true
    "m5.xlarge"    = true
    "m5d.12xlarge" = true
    "m5d.24xlarge" = true
    "m5d.2xlarge"  = true
    "m5d.4xlarge"  = true
    "m5d.large"    = true
    "m5d.xlarge"   = true
    "p2.16xlarge"  = true
    "p2.8xlarge"   = true
    "p2.xlarge"    = true
    "p3.16xlarge"  = true
    "p3.2xlarge"   = true
    "p3.8xlarge"   = true
    "r3.2xlarge"   = false
    "r3.2xlarge"   = true
    "r3.4xlarge"   = true
    "r3.8xlarge"   = false
    "r3.large"     = false
    "r3.xlarge"    = true
    "r4.16xlarge"  = true
    "r4.2xlarge"   = true
    "r4.4xlarge"   = true
    "r4.8xlarge"   = true
    "r4.large"     = true
    "r4.xlarge"    = true
    "t1.micro"     = false
    "t2.2xlarge"   = false
    "t2.large"     = false
    "t2.medium"    = false
    "t2.micro"     = false
    "t2.nano"      = false
    "t2.small"     = false
    "t2.xlarge"    = false
    "t3.small"     = false
    "t3.medium"    = false
    "t3.large"     = false
    "t3.xlarge"    = false
    "t3.2xlarge"   = false
    "x1.16xlarge"  = true
    "x1.32xlarge"  = true
    "x1e.16xlarge" = true
    "x1e.2xlarge"  = true
    "x1e.32xlarge" = true
    "x1e.4xlarge"  = true
    "x1e.8xlarge"  = true
    "x1e.xlarge"   = true
  }
}
