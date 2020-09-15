# Vagrantfile to configure a VirtualBox VM that can be used for Dobby Development

Vagrant.configure("2") do |config|
    # Fedora 
    config.vm.box = "fedora/32-cloud-base"
    
    config.vm.hostname = "dobby-fedora"
    config.vm.define "dobby-fedora"

    config.vm.network :forwarded_port, guest: 22, host: 2200, id: "ssh"
    
    config.vagrant.plugins = "vagrant-disksize"
    config.vagrant.plugins = "vagrant-vbguest"
    config.disksize.size = '30GB'
    
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "4096" # Change this to reduce the amount of RAM assigned to the VM
        vb.cpus = "4"   # Change this to reduce the amount of cores assigned to the VM
        vb.customize ["modifyvm", :id, "--ioapic", "on", "--vram", "100", "--graphicscontroller", "vmsvga", "--audio", "none"]
    end    
    
    # Forward SSH keys from host
    config.ssh.forward_agent = true

    # Copy host gitconfig
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
    config.vm.provision "file", source: "~/.ssh", destination: "$HOME/.ssh"

    config.vm.provision "shell", inline: <<-SHELL
        dnf upgrade -y
        dnf install -y make vim jq git skopeo go go-md2man
        
        # Install Go
        dnf install -y go
        mkdir -p $HOME/go
        echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
       source $HOME/.bashrc
    SHELL
    
    # Configure Go
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
        mkdir -p $HOME/go
        echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
        
        # Install umoci
        go get -d github.com/opencontainers/umoci
        cd $GOPATH/src/github.com/opencontainers/umoci/
        make
        sudo make install
    SHELL
end
