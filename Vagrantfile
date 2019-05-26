Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"

  config.vm.hostname = "dockerinfraplayground-worker"

  config.vm.network :forwarded_port, guest: 22, host: 10022, host_ip: "0.0.0.0"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 4
    libvirt.memory = 8192
    libvirt.nested = true

  end

  config.vm.provision "shell", inline: <<-SHELL
	apt-get -qy update
	apt-get -qy install qemu-kvm docker.io docker-compose 
  adduser --disabled-password --gecos "" labuser
  echo labuser:labpassword | chpasswd
  adduser labuser sudo 
	adduser labuser kvm
	adduser labuser docker 
  apt-get -qy install openjdk-8-jdk 
  SHELL

end
