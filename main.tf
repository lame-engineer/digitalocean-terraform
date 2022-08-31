resource "digitalocean_vpc" "sample" {
  name     = "test-network"
  region   = "nyc1"
  ip_range = "10.100.1.0/24"
}

resource "digitalocean_droplet" "test-vm" {
  name     = "test-1"
  size     = "s-1vcpu-1gb"
  image    = "ubuntu-18-04-x64"
  region   = "nyc1"
  vpc_uuid = digitalocean_vpc.sample.id
  user_data = <<EOF
  #cloud-config
groups:
  - ubuntu: [root,sys]
# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: test
    gecos: test
    shell: /bin/bash
    primary_group: test
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, docker
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa YOUR KEY
  
runcmd:
  - sudo apt-get -y update
  - sudo apt -y install apt-transport-https ca-certificates curl software-properties-common net-tools
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  - sudo apt -y update
  - sudo apt-cache policy docker-ce && apt-get -y install docker-ce
  - sudo apt-get install nginx
  - sudo usermod -aG docker test
EOF
}
#tag the droplet what ever you like
resource "digitalocean_tag" "docker" {
  name = "docker and nginx"
}

#output

output "ip_address" {
  value       = digitalocean_droplet.test-vm.ipv4_address
  description = "The public IP address of your droplet."
}
