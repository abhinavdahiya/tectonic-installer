# Kubelet tls bootstraping id and secret
resource "random_string" "bootstrap_token_id_master" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "bootstrap_token_secret_master" {
  length  = 16
  special = false
  upper   = false
}

resource "random_string" "bootstrap_token_id_worker" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "bootstrap_token_secret_worker" {
  length  = 16
  special = false
  upper   = false
}

# Self-hosted manifests (resources/generated/manifests/)
resource "template_dir" "bootkube" {
  source_dir      = "${path.module}/resources/manifests"
  destination_dir = "./generated/manifests"

  vars {
    tectonic_network_operator_image = "${var.container_images["tectonic_network_operator"]}"

    kco_config = "${indent(4, chomp(data.template_file.kco-config_yaml.rendered))}"

    calico_mtu            = "${var.calico_mtu}"
    cloud_provider_config = "${var.cloud_provider_config}"
    cluster_cidr          = "${var.cluster_cidr}"
    tectonic_networking   = "${var.tectonic_networking}"

    aggregator_ca_cert            = "${base64encode(var.aggregator_ca_cert_pem)}"
    kube_ca_cert                  = "${base64encode(var.kube_ca_cert_pem)}"
    kube_ca_key                   = "${base64encode(var.kube_ca_key_pem)}"
    bootstrap_token_id_master     = "${random_string.bootstrap_token_id_master.result}"
    bootstrap_token_secret_master = "${random_string.bootstrap_token_secret_master.result}"
    bootstrap_token_id_worker     = "${random_string.bootstrap_token_id_worker.result}"
    bootstrap_token_secret_worker = "${random_string.bootstrap_token_secret_worker.result}"
    apiserver_key                 = "${base64encode(var.apiserver_key_pem)}"
    apiserver_cert                = "${base64encode(var.apiserver_cert_pem)}"
    apiserver_proxy_key           = "${base64encode(var.apiserver_proxy_key_pem)}"
    apiserver_proxy_cert          = "${base64encode(var.apiserver_proxy_cert_pem)}"
    oidc_ca_cert                  = "${base64encode(var.oidc_ca_cert)}"
    pull_secret                   = "${base64encode(file(var.pull_secret_path))}"
    serviceaccount_pub            = "${base64encode(tls_private_key.service_account.public_key_pem)}"
    serviceaccount_key            = "${base64encode(tls_private_key.service_account.private_key_pem)}"

    etcd_ca_cert     = "${base64encode(var.etcd_ca_cert_pem)}"
    etcd_client_cert = "${base64encode(var.etcd_client_cert_pem)}"
    etcd_client_key  = "${base64encode(var.etcd_client_key_pem)}"
  }
}

# kubeconfig (resources/generated/auth/kubeconfig)
# kubeconfig with admin privileges.
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    kube_ca_cert = "${base64encode(var.kube_ca_cert_pem)}"
    admin_cert   = "${base64encode(var.admin_cert_pem)}"
    admin_key    = "${base64encode(var.admin_key_pem)}"
    server       = "${var.kube_apiserver_url}"
    cluster_name = "${var.cluster_name}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "./generated/auth/kubeconfig"
}

# kubeconfig_master (resources/generated/auth/kubeconfig-master)
# kubeconfig used by kubelets on master nodes.
data "template_file" "kubeconfig_master" {
  template = "${file("${path.module}/resources/kubeconfig-kubelet")}"

  vars {
    kube_ca_cert           = "${base64encode(var.kube_ca_cert_pem)}"
    bootstrap_token_id     = "${random_string.bootstrap_token_id_master.result}"
    bootstrap_token_secret = "${random_string.bootstrap_token_secret_master.result}"
    server                 = "${var.kube_apiserver_url}"
    cluster_name           = "${var.cluster_name}"
  }
}

resource "local_file" "kubeconfig_master" {
  content  = "${data.template_file.kubeconfig_master.rendered}"
  filename = "./generated/auth/kubeconfig-master"
}

# kubeconfig_worker (resources/generated/auth/kubeconfig-worker)
# kubeconfig used by kubelets on worker nodes.
data "template_file" "kubeconfig_worker" {
  template = "${file("${path.module}/resources/kubeconfig-kubelet")}"

  vars {
    kube_ca_cert           = "${base64encode(var.kube_ca_cert_pem)}"
    bootstrap_token_id     = "${random_string.bootstrap_token_id_worker.result}"
    bootstrap_token_secret = "${random_string.bootstrap_token_secret_worker.result}"
    server                 = "${var.kube_apiserver_url}"
    cluster_name           = "${var.cluster_name}"
  }
}

resource "local_file" "kubeconfig_worker" {
  content  = "${data.template_file.kubeconfig_worker.rendered}"
  filename = "./generated/auth/kubeconfig-worker"
}

# kvo-config.yaml (resources/generated/kco-config.yaml)
data "template_file" "kco-config_yaml" {
  template = "${file("${path.module}/resources/kco-config.yaml")}"

  vars {
    kube_apiserver_url = "${var.kube_apiserver_url}"

    cloud_config_path      = "${var.cloud_config_path}"
    cloud_provider_profile = "${var.cloud_provider != "" ? "${var.cloud_provider}" : "metal"}"

    advertise_address = "${var.advertise_address}"
    cluster_cidr      = "${var.cluster_cidr}"

    etcd_servers = "${join(",", formatlist("https://%s:2379", var.etcd_endpoints))}"

    service_cidr = "${var.service_cidr}"

    oidc_client_id      = "${var.oidc_client_id}"
    oidc_groups_claim   = "${var.oidc_groups_claim}"
    oidc_issuer_url     = "${var.oidc_issuer_url}"
    oidc_username_claim = "${var.oidc_username_claim}"
  }
}

resource "local_file" "kco-config_yaml" {
  content  = "${data.template_file.kco-config_yaml.rendered}"
  filename = "./generated/kco-config.yaml"
}

# bootkube.sh (resources/generated/bootkube.sh)
data "template_file" "bootkube_sh" {
  template = "${file("${path.module}/resources/bootkube.sh")}"

  vars {
    bootkube_image           = "${var.container_images["bootkube"]}"
    kube_core_renderer_image = "${var.container_images["kube_core_renderer"]}"
  }
}

resource "local_file" "bootkube_sh" {
  content  = "${data.template_file.bootkube_sh.rendered}"
  filename = "./generated/bootkube.sh"
}

# bootkube.service (available as output variable)
data "template_file" "bootkube_service" {
  template = "${file("${path.module}/resources/bootkube.service")}"
}

data "ignition_systemd_unit" "bootkube_service" {
  name    = "bootkube.service"
  enabled = false
  content = "${data.template_file.bootkube_service.rendered}"
}

# bootkube.path (available as output variable)
data "template_file" "bootkube_path_unit" {
  template = "${file("${path.module}/resources/bootkube.path")}"
}

data "ignition_systemd_unit" "bootkube_path_unit" {
  name    = "bootkube.path"
  enabled = true
  content = "${data.template_file.bootkube_path_unit.rendered}"
}
