data "null_data_source" "calico-network" {
  inputs = {
    output_id = "${
      var.enabled
        ? "${sha1("${join(" ", local_file.calico-network.*.id)}")}"
        : "# calico policy disabled"
      }"
  }
}

data "template_file" "calico-network" {
  template = "${file("${path.module}/resources/manifests/kube-calico.yaml")}"

  vars {
    kube_apiserver_url = "${var.kube_apiserver_url}"
    cni_version        = "${var.cni_version}"
    log_level          = "${var.log_level}"
    calico_image       = "${var.calico_image}"
    calico_cni_image   = "${var.calico_cni_image}"
    cluster_cidr       = "${var.cluster_cidr}"
    host_cni_bin       = "${var.host_cni_bin}"
    bgp_backend        = "${var.bgp_backend}"

    bootkube_dir = "${var.bootkube_dir}"
  }
}

resource "local_file" "calico-network" {
  count = "${
    var.enabled
      ? 1
      : 0
    }"

  content  = "${data.template_file.calico-network.rendered}"
  filename = "./generated/manifests/kube-calico.yaml"
}
