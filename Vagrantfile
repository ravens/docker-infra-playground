Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"

  config.vm.hostname = "dockerinfraplayground"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 4
    libvirt.memory = 8192
    libvirt.nested = true
  end

  config.vm.provision "shell", inline: <<-SHELL
	apt-get -qy update
	apt-get -qy install qemu-kvm docker.io docker-compose
	apt-get -qy install linux-image-generic 
	adduser vagrant docker
	adduser vagrant kvm
  SHELL

end