resource "local_file" "apiserver_key" {
  content  = "${tls_private_key.apiserver.private_key_pem}"
  filename = "./generated/tls/apiserver.key"
}

resource "local_file" "apiserver_crt" {
  content  = "${tls_locally_signed_cert.apiserver.cert_pem}"
  filename = "./generated/tls/apiserver.crt"
}

resource "local_file" "kube_ca_key" {
  content  = "${var.ca_cert_pem == "" ? join(" ", tls_private_key.kube_ca.*.private_key_pem) : var.ca_key_pem}"
  filename = "./generated/tls/ca.key"
}

resource "local_file" "kube_ca_crt" {
  content  = "${var.ca_cert_pem == "" ? join(" ", tls_self_signed_cert.kube_ca.*.cert_pem) : var.ca_cert_pem}"
  filename = "./generated/tls/ca.crt"
}

resource "local_file" "admin_key" {
  content  = "${tls_private_key.admin.private_key_pem}"
  filename = "./generated/tls/admin.key"
}

resource "local_file" "admin_crt" {
  content  = "${tls_locally_signed_cert.admin.cert_pem}"
  filename = "./generated/tls/admin.crt"
}
