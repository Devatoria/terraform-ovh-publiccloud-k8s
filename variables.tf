variable "region" {
  type        = "string"
  description = "The target openstack region"
}

variable "name" {
  type        = "string"
  description = "Cluster name"
}

variable "ssh_authorized_keys" {
  type        = "list"
  description = "SSH public keys"
  default     = []
}

variable "domain" {
  description = "The domain of the cluster."
  default     = "local"
}

variable "datacenter" {
  description = "The datacenter of the cluster."
  default     = "dc1"
}

variable "image_id" {
  description = "The ID of the glance image to run in the cluster. If `post_install_module` is set to `false`, this should be an image built from the Packer template under examples/k8s-glance-image/k8s.json. If the default value is used, Terraform will look up the latest image build automatically."
  default     = ""
}

variable "image_name" {
  description = "The name of the glance image to run in the cluster. If `post_install_module` is set to `false`, this should be an image built from the Packer template under examples/k8s-glance-image/k8s.json. If the default value is used, Terraform will look up the latest image build automatically."
  default     = "CoreOS Stable"
}

variable "flavor_name" {
  description = <<DESC
The flavor name that will be used for k8s nodes.
kube-dns may fail if only one VCPU is present (see kubernetes/kubernetes#38806).
It is not recommanded to use sandbox instances `s1-2` and `s1-4`.
DESC
  default     = "s1-8"
}

variable "count" {
  type        = "string"
  default     = "1"
  description = "Number of nodes"
}

variable "metadata" {
  description = "A map of metadata to add to all resources supporting it."
  default     = {}
}

variable "subnet_ids" {
  type = "list"

  description = <<DESC
The list of subnets ids to deploy k8s nodes in.
If `count` is specified, will spawn `count` k8s node
accross the list of subnets. Conflicts with `subnets`.
DESC

  default = []
}

variable "subnets" {
  type = "list"

  description = <<DESC
The list of subnets CIDR blocks to deploy k8s nodes in.
If `count` is specified, will spawn `count` k8s node
accross the list of subnets. Conflicts with `subnet_ids`.
DESC

  default = [""]
}

variable "public_security_group_ids" {
  type        = "list"
  description = "An optional list of additional security groups to attach to public ports"
  default     = []
}

variable "cacert" {
  description = "Optional ca certificate to add to the nodes. If `cfssl` is set to `true`, cfssl will use `cacert` along with `cakey` to generate certificates. Otherwise will generate a new self signed ca."
  default     = ""
}

variable "cacert_key" {
  description = "Optional ca certificate key. If `cfssl` is set to `true`, cfssl will use `cacert` along with `cakey` to generate certificates. Otherwise will generate a new self signed ca."
  default     = ""
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to openstack instances"
  type        = "string"
  default     = ""
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "post_install_modules" {
  description = "Setting this variable to true will assume the necessary software to boot the cluster hasn't packaged in the image and thus will be post provisionned. Defaults to `false`"
  default     = true
}

variable "ssh_user" {
  description = "The ssh username of the image used to boot the k8s cluster."
  default     = "core"
}

variable "ssh_bastion_host" {
  description = "The address of the bastion host used to post provision the k8s cluster. This may be required if `post_install_module` is set to `true`"
  default     = ""
}

variable "ssh_bastion_user" {
  description = "The ssh username of the bastion host used to post provision the k8s cluster. This may be required if `post_install_module` is set to `true`"
  default     = ""
}

variable "ignition_mode" {
  description = "Set to true if os family supports ignition, such as CoreOS/Container Linux distribution"
  default     = true
}

variable "associate_public_ipv4" {
  description = "Associate a public ipv4 with the k8s nodes"
  default     = false
}

variable "associate_private_ipv4" {
  description = "Associate a private ipv4 with the k8s nodes"
  default     = true
}

variable "master_mode" {
  description = "Determines if nodes are k8s master nodes or simple workers"
  default     = false
}

variable "ip_dns_domains" {
  description = "Every public ipv4 addr at OVH is registered as a A record in DNS zones according to the format ip 1.2.3.4 > ip4.ip-q1-2-3.eu for EU regions or  ip4.ip-1-2-3.net for other ones. This variables maps the domain name to use according to the region."

  default = {
    GRA1 = "eu"
    SBG3 = "eu"
    GRA3 = "eu"
    SBG3 = "eu"
    BHS3 = "net"
    WAW1 = "eu"
    DE1  = "eu"
    UK1  = "eu"
  }
}

variable "default_ip_dns_domains" {
  description = "Default value for `ip_dns_domains`"
  default     = "net"
}

variable "cfssl" {
  description = <<DESC
Defines if cfssl shall be used as a pki. If set to `true`
and no cacert with associated private key is given as argument, cfssl will
generate its own self signed ca cert.

If `cfssl_endpoint` is left blank, a cfssl server is started on the first cluster node.
A systemd unit will then get tls keypairs for the etcd service.

At every etcd agent restart, if tls keypair is older than 1h,
a new keypair will be fetched.
DESC

  default = false
}

variable "cfssl_endpoint" {
  description = "If `cfssl` is set to `true`, this argument can be used to specify a target cfssl endpoint. Otherwise the first ipv4 given as argument in `private_ipv4_addrs` will be used as the cfssl endpoint in instances userdata."
  default     = ""
}

variable "cfssl_ca_validity_period" {
  description = "validity period for generated CA"
  default     = "43800h"
}

variable "cfssl_cert_validity_period" {
  description = "default validity period for generated certs"
  default     = "8760h"
}

variable "cfssl_key_algo" {
  description = "generated certs key algo"
  default     = "rsa"
}

variable "cfssl_key_size" {
  description = "generated certs key size"
  default     = "2048"
}

variable "cfssl_bind" {
  description = "cfssl service bind addr"
  default     = "0.0.0.0"
}

variable "cfssl_port" {
  description = "cfssl service bind port"
  default     = "8888"
}

variable "private_ipv4_addrs" {
  description = "list of nodes ipv4 addrs. Required if `master_mode` is true."
  type        = "list"
  default     = []
}

variable "etcd" {
  description = <<DESC
Defines if node shall be started as an etcd cluster member. If set to `true`
and no `etcd_initial_cluster` is given as argument, etcd will
bootstrap a new cluster.
DESC

  default = false
}

variable "etcd_initial_cluster" {
  description = "etcd initial cluster. Useful to join an existing cluster. Useful if `master_mode` is true."
  default     = ""
}

variable "master_as_worker" {
  description = "Determines if master are also worker"
  default     = false
}
