data "null_data_source" "flannel" {
  inputs = {
    output_id = "${
      var.enabled
        ? "${sha1("${join(" ", local_file.flannel.*.id)}")}"
        : "# flannel disabled"
      }"
  }
}

data "template_file" "flannel" {
  template = "${file("${path.module}/resources/manifests/kube-flannel.yaml")}"

  vars {
    flannel_image     = "${var.flannel_image}"
    flannel_cni_image = "${var.flannel_cni_image}"
    cluster_cidr      = "${var.cluster_cidr}"
    host_cni_bin      = "${var.host_cni_bin}"

    bootkube_dir = "${var.bootkube_dir}"
  }
}

resource "local_file" "flannel" {
  count = "${
    var.enabled
      ? 1
      : 0
    }"

  content  = "${data.template_file.flannel.rendered}"
  filename = "./generated/manifests/kube-flannel.yaml"
}
