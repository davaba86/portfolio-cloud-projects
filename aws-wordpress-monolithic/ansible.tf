resource "local_file" "ansible_inventory" {
  content = templatefile("ansible_inventory.tpl", {
    ip_addrs    = [for i in aws_instance.web : i.public_ip]
    ssh_keyfile = local_file.ed25519_compute_private_key.filename
  })
  filename = format("%s/%s", abspath(path.root), "ansible/inventory.ini")
}
