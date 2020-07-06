#!/bin/sh
grey='\033[1;30m'
red='\033[0;31m'
RED='\033[1;31m'
green='\033[0;32m'
GREEN='\033[1;32m'
yellow='\033[0;33m'
YELLOW='\033[1;33m'
purple='\033[0;35m'
PURPLE='\033[1;35m'
white='\033[0;37m'
WHITE='\033[1;37m'
blue='\033[0;34m'
BLUE='\033[1;34m'
cyan='\033[0;36m'
CYAN='\033[1;36m'
NC='\033[0m'

# Save the working directory of the script
working_dir=$PWD

# Setup command
DEBUG=false
VERBOSE=false
FLAGS=""
OTHER_ARGUMENTS=""

for arg in "$@"
do
    case $arg in
        -d|--debug)
        DEBUG=true
        FLAGS="$FLAGS-d "
        shift # Remove --debug from processing
        ;;
        -v|--verbose)
        VERBOSE=true
        FLAGS="$FLAGS-v "
        shift # Remove --verbose from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo; echo; exit 0; }
trap ctrl_c INT

echo
echo -n "${PURPLE}Compile Knossos (y/n)? ${NC}"
read answer
echo
if [ "$answer" != "${answer#[Yy]}" ] ;then

    # Set Install Directory
        install_dir="$HOME/knossos"
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Where do you want to install to?${NC}\n"
        printf "${YELLOW}\t0) $HOME/knossos (default)${NC}\n"
        printf "${YELLOW}\t1) $HOME/Games/knossos${NC}\n"
        printf "${YELLOW}\t2) Custom${NC}\n"
        echo
        printf "${GREEN}Selection? ${NC}"
        read install
        if [ "$install" != "${install#[1]}" ] ;then install_dir="$HOME/Games/knossos"; fi
        if [ "$install" != "${install#[2]}" ] ;then printf "${BLUE}Directory? ${NC}"; read install_dir; fi
        
    # Create Directories
        remdir="n"
        if [ -d "$install_dir" ] ;then
            printf "${PURPLE}Source [knossos]: ${BLUE}Directory already exists, remove first? ${NC}"
            read answer
            if [ "$answer" != "${answer#[Yy]}" ] ;then
                cmd "sudo rm -rf $install_dir"
                remdir="y"
            fi
        fi
        
        if [ ! -d "$install_dir" ] ;then
            if [ "$remdir" != "${remdir#[Nn]}" ] ;then
                printf "${PURPLE}Source [knossos]: ${BLUE}Directory '$install_dir' doesn't exist, create (y/n)? ${NC}"
                read answer
            fi
            if [ "$answer" != "${answer#[Yy]}" ] || [ "$remdir" != "${remdir#[Yy]}" ] ;then
                cmd "mkdir -pv $install_dir"
            else
                printf "${RED}Aborting!${NC}\n"
                exit 0
            fi
        fi

    # Dependencies
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Add key for yarn${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -"
        fi
        
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Add yarn source${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "echo "deb [trusted=yes] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list"
        fi
        
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Update apt${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo apt update"
        fi
        
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Install apt packages${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "sudo apt install nodejs npm python3-wheel python3-setuptools pyqt5-dev pyqt5-dev-tools qttools5-dev-tools qt5-default pipenv yarn ninja-build"
        fi
    
    # Grab Source
        echo
        echo -n "${PURPLE}Source [knossos]: ${BLUE}Pull current source from git (requires internet connection) (y/n)? ${NC}"
        read source
        if [ "$source" != "${source#[Yy]}" ] ;then
            cmd "git clone https://github.com/ngld/knossos.git $install_dir"
        else
            cmd "cp --preserve=all -rT ./src/knossos-develop $install_dir"
        fi
    
    # Knossos: build and install
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Moving into directory '$install_dir'${NC}\n"
        cmd "cd $install_dir"
        cmd "echo $PWD"
        cmd "ls -al"
        ctrl_c() {
            echo;
            cmd "cd '${working_dir}'";
            echo;
            exit 0;
        }
    
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Install pipenv${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "pipenv install"
        fi
    
        # Knossos says to do this but it doesn't work, also doesn't seem necessary
        #printf "${BLUE}Install yarn${NC}"
        #echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
        #    echo "yarn install"
        #    cmd "yarn install"
        #fi
        
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Install npm modules${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "npm install"
        fi
        
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Configure/Build Knossos${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            printf "${YELLOW}Watch for 'Writing build.ninja' for success.${NC}\n"
            cmd "pipenv run python configure.py"
        fi
    
    # Test Run
        echo
        printf "${PURPLE}Source [knossos]: ${BLUE}Test Knossos${NC}"
        echo -n "${GREEN} (y/n)? ${NC}"; read answer; if [ "$answer" != "${answer#[Yy]}" ] ;then
            cmd "ninja run"
        fi
    
    cmd "cd '${working_dir}'";
    ctrl_c() {
        echo;
        echo;
        exit 0;
    }
    
    ctrl_c() { echo; echo; exit 0; }
    
fi
