data "http" "my_pub_addr" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_pub_addr_cleansed = "${chomp(data.http.my_pub_addr.response_body)}/32"
}
