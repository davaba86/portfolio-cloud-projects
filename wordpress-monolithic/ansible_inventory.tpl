[aws_ec2]
%{ for addr in ip_addrs ~}
${addr}
%{ endfor ~}

[aws_ec2:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=${ssh_keyfile}
