output "id" {
  value = "${data.null_data_source.flannel.outputs.output_id}"
}

output "name" {
  value = "flannel"
}
