output "id" {
  value = "${data.null_data_source.calico-network-policy.outputs.output_id}"
}

output "name" {
  value = "calico"
}
