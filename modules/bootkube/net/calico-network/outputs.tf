output "id" {
  value = "${data.null_data_source.calico-network.outputs.output_id}"
}

output "name" {
  value = "calico"
}
