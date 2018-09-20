Vagrant.configure(2) do |config|

  config.vm.box = "envimation/ubuntu-xenial"
  config.vm.network "private_network", type: "dhcp"


 config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.name = "treebo-devops"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = ""
     ansible.raw_arguments="-vvv"
     ansible.extra_vars = {
    }
  end
end