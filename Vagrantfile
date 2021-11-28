Vagrant.configure(2) do |config|
  config.vm.hostname = "xwiki.vm"
  
  config.vm.provider :virtualbox do |vb|
    vb.cpus = 2
    vb.memory = 3072
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 2
    libvirt.memory = 3072
  end
end
