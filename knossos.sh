#!/bin/bash
grey='\e[0m\e[37m'
GREY='\e[1m\e[90m'
red='\e[0m\e[91m'
RED='\e[1m\e[31m'
green='\e[0m\e[92m'
GREEN='\e[1m\e[32m'
yellow='\e[0m\e[93m'
YELLOW='\e[1m\e[33m'
purple='\e[0m\e[95m'
PURPLE='\e[1m\e[35m'
white='\e[0m\e[37m'
WHITE='\e[1m\e[37m'
blue='\e[0m\e[94m'
BLUE='\e[1m\e[34m'
cyan='\e[0m\e[96m'
CYAN='\e[1m\e[36m'
NC='\e[0m\e[39m'

# Save the working directory of the script
working_dir=$PWD

# Setup command
DEBUG=false
VERBOSE=false
IN_TESTING=false
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
        --in-testing)
        IN_TESTING=true
        FLAGS="$FLAGS--in-testing "
        shift # Remove from processing
        ;;
        -h|--help)
        echo -e "${WHITE}"
        echo -e "Usage: $0 <options>"
        echo -e
        echo -e "Options:"
        echo -e "  -h, --help            show this help message and exit"
        echo -e "  -v, --verbose         print commands being run before running them"
        echo -e "  -d, --debug           print commands to be run but do not execute them"
        echo -e "  --in-testing          Enable use of in-testing features"
        echo -e "${NC}"
        exit
        shift # Remove from processing
        ;;
        *)
        OTHER_ARGUMENTS="$OTHER_ARGUMENTS$1 "
        echo -e "${RED}Unknown argument: $1${NC}"
        exit
        shift # Remove generic argument from processing
        ;;
    esac
done

cmd(){
    if [ "$VERBOSE" = true ] || [ "$DEBUG" = true ]; then echo -e ">> ${WHITE}$1${NC}"; fi;
    if [ "$DEBUG" = false ]; then eval $1; fi;
}

# trap ctrl-c and call ctrl_c()
ctrl_c() { echo -e; echo -e; exit 0; }
trap ctrl_c INT

echo -e
echo -e -n "${PURPLE}Compile Knossos (y/n/a)? ${NC}"
read answer
echo -e
if [ "$answer" != "${answer#[YyAa]}" ] ;then
    if [ "$answer" != "${answer#[Aa]}" ] ;then answer2="y"; else answer2=""; fi

    # Set Install Directory
        install_dir="$HOME/knossos"
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Where do you want to install to?${NC}\n"
        printf "${YELLOW}\t0) $HOME/knossos (default)${NC}\n"
        printf "${YELLOW}\t1) $HOME/Games/knossos${NC}\n"
        printf "${YELLOW}\t2) Custom${NC}\n"
        echo -e
        printf "${GREEN}Selection? ${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then read install; else install="1"; fi
        if [ "$install" != "${install#[1]}" ] ;then install_dir="$HOME/Games/knossos"; fi
        if [ "$install" != "${install#[2]}" ] ;then printf "${BLUE}Directory? ${NC}"; read install_dir; fi
        
    # Create Directories
        remdir="n"
        if [ -d "$install_dir" ] ;then
            printf "${PURPLE}Source [knossos]: ${BLUE}Directory already exists, remove first${NC}"
            if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
            if [ "$answer2" != "${answer2#[Yy]}" ] ;then
                cmd "sudo rm -rf $install_dir"
                remdir="y"
            fi
        fi
        
        if [ ! -d "$install_dir" ] ;then
            if [ "$remdir" != "${remdir#[Nn]}" ] ;then
                printf "${PURPLE}Source [knossos]: ${BLUE}Directory '$install_dir' doesn't exist, create${NC}"
                if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
            fi
            if [ "$answer2" != "${answer2#[Yy]}" ] || [ "$remdir" != "${remdir#[Yy]}" ] ;then
                cmd "mkdir -pv $install_dir"
            else
                printf "${RED}Aborting!${NC}\n"
                exit 0
            fi
        fi

    # Dependencies
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Add key for yarn${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -"
        fi
        
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Add yarn source and update apt${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "echo -e 'deb [trusted=yes] https://dl.yarnpkg.com/debian/ stable main' | sudo tee /etc/apt/sources.list.d/yarn.list"
            cmd "sudo apt update"
        fi
        
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Install apt packages${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "printf '%s\n' y | sudo apt install nodejs npm python3-wheel python3-setuptools pyqt5-dev pyqt5-dev-tools qttools5-dev-tools qt5-default pipenv yarn ninja-build"
        fi
        
    
    # Grab Source
        echo -e
        echo -e -n "${PURPLE}Source [knossos]: ${BLUE}Use provided source snapshot${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "cp --preserve=all -rT ./src/knossos-develop $install_dir"
        else
            cmd "git clone https://github.com/ngld/knossos.git $install_dir"
        fi
    
    # Knossos: build and install
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Moving into directory '$install_dir'${NC}\n"
        cmd "cd $install_dir"
        cmd "echo -e $PWD"
        cmd "ls -al"
        ctrl_c() {
            echo -e;
            cmd "cd '${working_dir}'";
            echo -e;
            exit 0;
        }
    
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Install pipenv${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "pipenv install"
        fi
    
        # Knossos says to do this but it doesn't work, also doesn't seem necessary
        #printf "${BLUE}Install yarn${NC}"
        #if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        #if [ "$answer2" != "${answer2#[Yy]}" ] ;then
        #    echo -e "yarn install"
        #    cmd "yarn install"
        #fi
        
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Install npm modules${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            cmd "npm install"
        fi
        
        echo -e
        printf "${PURPLE}Source [knossos]: ${BLUE}Configure/Build Knossos${NC}"
        if [ "$answer" != "${answer#[Yy]}" ] ;then printf " ${GREEN}(y/n)? ${NC} "; read answer2; else echo; fi
        if [ "$answer2" != "${answer2#[Yy]}" ] ;then
            printf "${YELLOW}Watch for 'Writing build.ninja' for success.${NC}\n"
            cmd "pipenv run python configure.py"
        fi
    
    cmd "cd '${working_dir}'";
    ctrl_c() {
        echo -e;
        echo -e;
        exit 0;
    }
    
    ctrl_c() { echo -e; echo -e; exit 0; }
    
fi
