locals {
  ip_route_add_tpl = "- ip route add %s dev %s scope link metric 0"
  eth_route_tpl    = "%s dev %s scope link metric 0"
}

data "template_file" "cfssl_ca_files" {
  template = <<TPL
- path: /opt/cfssl/cacert/ca.pem
  permissions: '0644'
  owner: cfssl:cfssl
  content: |
     ${indent(5, var.cacert)}
- path: /opt/cfssl/cacert/ca-key.pem
  permissions: '0600'
  owner: cfssl:cfssl
  content: |
     ${indent(5, var.cacert_key)}
TPL
}


data "template_file" "cfssl_conf" {
  template = <<TPL
- path: /etc/sysconfig/cfssl.conf
  mode: 0644
  content: |
      ${indent(6, module.cfssl.conf)}
TPL
}

data "template_file" "etcd_conf" {
  count = "${var.count}"
  template = <<TPL
- path: /etc/sysconfig/cfssl.conf
  mode: 0644
  content: |
      ${indent(6, module.etcd.conf[count.index])}
TPL
}

data "template_file" "cfssl_files" {
  template = <<TPL
${var.cacert != "" && var.cacert_key != "" ? data.template_file.cfssl_ca_files.rendered : ""}
${data.template_file.cfssl_conf.rendered}
TPL
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "config" {
  count         = "${var.ignition_mode ? 0 : var.count}"
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = <<CLOUDCONFIG
#cloud-config
ssh_authorized_keys:
  ${length(var.ssh_authorized_keys) > 0 ? indent(2, join("\n", formatlist("- %s", var.ssh_authorized_keys))) : ""}
## This route has to be added in order to reach other subnets of the network
bootcmd:
  ${indent(2, format(local.ip_route_add_tpl, var.host_cidr, "eth0"))}
ca-certs:
  trusted:
    - ${var.cacert}
write_files:
  ${var.cfssl && var.cfssl_endpoint == "" && count.index == 0 ? indent(2, element(data.template_file.cfssl_files.*.rendered, count.index)) : ""}
  ${var.etcd ? indent(2, element(data.template_file.etcd_conf.*.rendered, count.index)) : ""}
  - path: /etc/sysconfig/network-scripts/route-eth0
    content: |
      ${indent(6, format(local.eth_route_tpl, var.host_cidr, "eth0"))}
CLOUDCONFIG
  }
}
