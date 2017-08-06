#!/bin/bash 

TMUX_CONF=~/.tmux.conf
ZSHRC=~/.zshrc
ZSHDIR=~/.oh-my-zsh
SPACEMACS_CONF=~/.spacemacs
EMACSDIR=~/.emacs.d
BOOTSTRAP_DIR=~/bootstrap
NVMDIR=~/.nvm
GITCONFIG=~/.gitconfig

NODE_VERSION=6.10

setup_common(){

    if [ -f $ZSHRC ]; then
        echo "System already configured. Abort"
        exit 1
    fi

    # TODO
    cd ~

    if [ ! -d ~/bootstrap ]; then
      git clone https://github.com/jeffffrey/bootstrap.git  
    fi
    
 
    echo "Linking configuration files"
 
    ln -s bootstrap/.tmux.conf $TMUX_CONF
    ln -s bootstrap/.zshrc $ZSHRC
    ln -s bootstrap/.emacs.d $EMACSDIR
    ln -s bootstrap/.spacemacs $SPACEMACS_CONF
    ln -s bootstrap/.gitconfig $GITCONFIG

    echo "Install oh-my-zsh"
    install_zsh

    echo "Activate ZSH configuration"    
    source $ZSHRC

}

install_fonts(){

    if [ $OSTYPE="Linux" ]; then

        fc-cache -vf $BOOTSTRAP_DIR/fonts/
    fi
}

install_zsh(){

  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
  if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi
  unset CHECK_ZSH_INSTALLED

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  if [ -d "$ZSH" ]; then
    printf "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
    printf "You'll need to remove $ZSH if you want to re-install.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Oh My Zsh...${NORMAL}\n"
  hash git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
    printf "Error: git clone of oh-my-zsh repo failed\n"
    exit 1
  }

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    chsh -s /usr/bin/zsh
  fi

  printf "${GREEN}"
  echo '         __                                     __   '
  echo '  ____  / /_     ____ ___  __  __   ____  _____/ /_  '
  echo ' / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ '
  echo '/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / '
  echo '\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  '
  echo '                        /____/                       ....is now installed!'
  echo ''
  echo ''
  echo 'Please look over the ~/.zshrc file to select plugins, themes, and options.'
  echo ''
  echo 'p.s. Follow us at https://twitter.com/ohmyzsh.'
  echo ''
  echo 'p.p.s. Get stickers and t-shirts at http://shop.planetargon.com.'
  echo ''
  printf "${NORMAL}"
  env zsh
}

install_node(){


    echo "Setting up Node.js env"
    #install nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh > install_nvm.sh
    
    source ./install_nvm.sh
    source ~/.zshrc

    nvm install $NODE_VERSION

    TEST_NODE_INSTALL=$(node -v)
    echo "Node install completed. Version=" $TEST_NODE_INSTALL
    rm ./install_nvm.sh
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
    else
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


    # Install prequisites
    sudo apt-get update
    sudo apt-get -y install git tmux vim emacs curl powerline  build-essential zsh

    setup_common
    install_node

    # Copy Configuration files
    
}


clean_up () {

    echo "Cleanup Resources"

    if [ -f $TMUX_CONF ]; then
        echo "remove tmux config"
        rm $TMUX_CONF
    fi

    if [ -f $ZSHRC ]; then
        echo "remove zshrc"
        rm $ZSHRC
        rm -rf $ZSHDIR
    fi

    if [ -f $SPACEMACS_CONF ] ; then
        echo "remove spacemacs config"
        rm $SPACEMACS_CONF
        rm -rf $EMACSDIR
    fi
    
    if [ -d $NVMDIR ] ; then
        echo "remove nvm config and resources"
        rm -rf $NVMDIR
    fi
    
    if [ -f $GITCONFIG ] ; then
        echo "remove git config"
        rm $GITCONFIG
    fi

}

usage(){

    echo "Usage: \n"
    echo "bootstrap.sh -i <component> \n"
    echo "bootstrap.sh -d \n"
}

# Detect OS Type

if [ "$(uname)" == "Darwin" ]; then
    OSTYPE=darwin
#    setup_osx    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then


    OSTYPE=linux
    # Currently this script only support Ubuntu 16.04 and 14.04
    VERSION=$(awk '/DISTRIB_RELEASE=/' /etc/*-release | sed 's/DISTRIB_RELEASE=//')

#    if [ $VERSION = '16.04' ] || [ $VERSION = '14.04' ]; then
#        setup_linux
#    else
#        echo "Linux version not supported. Abort."
#        exit 1
#    fi 

else
    echo "No way... "
    exit 1
fi

while getopts "i:d:h" argv
do
     case $argv in
         i)
             COMPONENT=$OPTARG
  
             case $COMPONENT in 
		
		all)
                    setup_linux
                    ;;

               node)
		    install_node

             esac
             ;;
         d)
             clean_up
             exit
             ;;
         ?)
             usage
             exit
             ;;
     esac
done





# Utility Functions


