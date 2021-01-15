#!/bin/bash

REPO_DIR=$PWD/repos

GENERAL_BRANCH_VERSION="master"
GPIO_BRANCH_VERSION="master"

# =================================================================================
# GLOBAL TERMINAL MODIFIERS
# =================================================================================
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GREEN=$'\e[1;32m'
CYAN=$'\e[1;36m'
END_COLOR=$'\e[0m'

function sync_repos
{
    mkdir -p $REPO_DIR
    if [ $? -ne 0 ]
        then
            echo
            echo "========================================================="
            echo "${BOLD}Creating Yocto build directory failed...${NORMAL}"
            echo "========================================================="
            exit 1
    fi

    git config --global credential.helper "cache --timeout=5400"

    OLD_LOCATION=$PWD
    eval cd $REPO_DIR

    if [ ! -d "general" ]
        then
        git clone -b $GENERAL_BRANCH_VERSION https://code.ornl.gov/uvdl/general.git
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone general${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi

    if [ ! -d "gpio" ]
        then
        git clone -b $GPIO_BRANCH_VERSION https://code.ornl.gov/uvdl/gpio.git
        if [ $? -ne 0 ]
            then
                echo
                echo "==============================================="
                echo "${BOLD}Failed to clone gpio${NORMAL}"
                echo "==============================================="
                exit 1
        fi
    fi

    eval cd $OLD_LOCATION
}

function copy_n2n_folder
{
    LOCATION=$PWD
    eval cd ../

    rsync -a --exclude '.git' --exclude '.gitignore' --exclude 'repos' --exclude 'meta-n2n' n2n/ n2n/repos/n2n
    eval cd $LOCATION
}

function create_recipe_tarball
{
    OLD_LOCATION=$PWD
    eval cd $REPO_DIR

    tar --exclude="*.tar.gz" --exclude=".git" --exclude=".gitignore" -czf n2n.tar.gz ./
    # copy tarball to the file dependency folder for the swu recipe
    cp n2n.tar.gz ../meta-n2n/recipes-support/swupdate/n2n-application-swu/
    # also need it in the mission-application recipe
    mkdir -p ../meta-n2n/recipes-n2n/n2n/files/
    cp n2n.tar.gz ../meta-n2n/recipes-n2n/n2n/files/

    eval cd $OLD_LOCATION
}

function help()
{
    echo 
    echo "Usage : ./setup_meta_n2n.sh -b build_directory "
    echo "build_directory - the full Yocto build directory"
    echo
    echo
    exit 0
}

if [ $# -eq 0 ]
    then 
        help
fi

if [ $1 != "-b" ]
    then 
        help
fi

BUILD_DIR=""

while getopts "h?b:" opt; do
    case "$opt" in
    h|\?)
        help
        ;;
    b)  BUILD_DIR=$2/sources
        ;;
    esac
done

# Do all the stuff we need to do to get the repos ready
sync_repos

# copy the mission folder into the repos directory
copy_n2n_folder

# create tarball for mission-application-swu
create_recipe_tarball

# Copy the layer over to the actual build directory
cp -rf meta-n2n/ $BUILD_DIR
