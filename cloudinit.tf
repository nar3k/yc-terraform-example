data "template_file" "cloud-init" {
  template = "${file("boostrap/cloud-init.yaml")}"

}
