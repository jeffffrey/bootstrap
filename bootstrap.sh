#!/bin/bash 

TMUX_CONF=~/.tmux.conf
ZSHRC=~/.zshrc
SPACEMACS_CONF=~/.spacemacs
EMACSDIR=~/.emacs.d
BOOTSTRAP_DIR=~/bootstrap

NODE_VERSION=6.10

setup_common(){

    if [ -f $ZSHRC ]; then
        echo "System already configured. Abort"
        exit 1
    fi

    # TODO
    #git clone https://


}

install_fonts(){

    if [ $OSTYPE="Linux" ]; then

        fc-cache -vf $BOOTSTRAP_DIR/fonts/
    fi
}

install_node(){

    #install nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

    source ~/.zshrc

    nvm install $NODE_VERSION

    TEST_NODE_INSTALL=$(node -v)
    echo "Node install completed. Version=" $TEST_NODE_INSTALL
}

install_tmux(){

    if [ -f $TMUX_CONF ]; then
        echo "tmux file exist. return"

    fi
    cp $BOOTSTRAP_DIR/.tmux 

}

install_powerline(){

    POWERLINE_SCRIPT=/usr/share/powerline/bindings/bash/powerline.sh
    if [ -f $POWERLINE_SCRIPT ]; then
        source $POWERLINE_SCRIPT
    elif 
        echo "Can't locate powerline script. Abort"
        exit 1
    fi

}

install_spacemacs(){


    # install emacs base system

    if [ $OSTYPE="Darwin" ]; then

        echo "Install Emacs base"
        brew cask install emacs

    elif [ $OSTPYE="Linux" ]; then
        #Download Emacs 24.5+ source code
        wget ftp://ftp.gnu.org/pub/gnu/emacs/emacs-24.5.tar.gz
        tar -zxvf emacs-24.5.tar.gz
        cd emacs-24.5
        ./configure
        make
        sudo make install
    fi


    # install emacs base system ( version must > 24.2 )
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

    cp $BOOTSTRAP_DIR/.spacemacs ~/
}

setup_osx (){

    echo "Setup OSX System"

    setup_common
    setup_fonts
    
}

setup_linux(){

    echo "Setup Linux System"

    setup_common

    # Install prequisites
    sudo apt-get update
    sudo apt-get install git tmux vim emacs curl powerline  build-essential

    # Install ZSH
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # Copy Configuration files
    
}





# Detect OS Type

if [ "$(uname)" == "Darwin" ]; then
    OSTYPE=darwin
    setup_osx    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then


    OSTYPE=linux
    # Currently this script only support Ubuntu 16.04 and 14.04
    Version=$(lsb_release -r --short)
    Codename=$(lsb_release -c --short)
    OSArch=$(uname -m)

    if [ Version = '16.04' ] || [ Version = '14.04' ]; then
        setup_linux
    fi 

else
    echo "No way... "
    exit 1
fi

# Utility Functions


clean_up () {

    echo "Cleanup Resources"

    if [ -f $TMUX_CONF ]; then
        echo "remove tmux config"
        #rm $TMUX_CONF
    fi

    if [ -f $ZSHRC ]; then
        echo "remove zshrc"
        #rm $ZSHRC
    fi

    if [ -f $SPACEMACS_CONF ] && [ -d $EMACSDIR ]; then
        echo "remove spacemacs config"
        #rm $SPACEMACS_CONF
        #rm -rf $EMACSDIR
    fi

}

clean_up