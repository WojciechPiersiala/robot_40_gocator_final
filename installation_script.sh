#!/bin/bash

#############################
######### FUNCTIONS #########
#############################

## Clone robot40human_ws from github, user will be asked to enter Bitbucket username and password.
clone_robot_repo(){
    cd $NEW_DIR
    if [[ -d $PROJECT_DIR ]]; then
        echo "robot 40 already installed"
        INSTALLED_ROBOT=0
    else 
        INSTALLED_ROBOT=1
        while [[ $INSTALLED_ROBOT -ne 0 ]]; do
            echo "Clone robot 40 directory"
            sudo git -C $NEW_DIR clone -b noetic git clone https://bitbucket.org/robot40proj/robot40human_ws
            INSTALLED_ROBOT=$?
            if [[ $INSTALLED_ROBOT -ne 0 ]]; then
                echo -e "\033[0;31m Incorrect password. \033[0m "  \
                 "Enter correct username and password." \
                  "\033[0;32m Or press \"^C\" twice to exit \033[0m"
            fi
            sleep 1
            echo "$INSTALLED_ROBOT"
        done
    fi
}


## Clone freenect from github outside of robot40human_ws location
install_freenect(){
    cd $NEW_DIR
    echo "Installing fineect"
    git clone https://github.com/OpenKinect/libfreenect2.git
}

## Clone other robot40human_ws depedencies inside robot40human_ws/src 
clone_other_repos(){
    echo "Downlading different repositories"
    cd $PROJECT_DIR/src

    sudo git clone -b right https://github.com/WojciechPiersiala/gocator.git

    sudo git clone https://github.com/ros-industrial/ur_msgs
    sudo git clone https://github.com/gavanderhoorn/industrial_robot_status_controller
    sudo git clone https://github.com/shadow-robot/optoforce.git
    sudo git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench.git
    sudo git clone https://github.com/ROBOTIS-GIT/dynamixel-workbench-msgs.git
    sudo git clone https://github.com/ros-drivers/urg_c.git
    sudo git clone https://github.com/ros-perception/laser_proc.git
    sudo git clone https://github.com/pal-robotics/gazebo_ros_link_attacher  
    sudo git clone https://github.com/ros-industrial/industrial_core.git
    sudo git clone https://github.com/UniversalRobots/Universal_Robots_ROS_passthrough_controllers.git
    sudo git clone https://github.com/UniversalRobots/Universal_Robots_ROS_cartesian_control_msgs.git
    sudo git clone https://github.com/UniversalRobots/Universal_Robots_ROS_controllers_cartesian.git
    sudo git clone https://github.com/UniversalRobots/Universal_Robots_Client_Library.git
    sudo git clone -b kinetic-devel https://github.com/ros-industrial/universal_robot
}

## Configure docker
configure_docker(){
    echo "Docker configuration"
    sudo apt update
    xhost +local:docker
    sudo chmod 666 /var/run/docker.sock
}

#############################
########### MAIN ############
#############################

## Check if the script was started with sudo
if [[ $(id -u) -ne 0 ]]; then
    echo -e "\033[0;31m ERROR : Not running as root. Execute this script wit 'sudo' \033[0m "
    exit 1
fi

## Set the current folder to the location of this script.
DIR=$(dirname $(readlink -f $0))
cd $DIR

## Variables used to change text color of prompt messages
NORMAL_COL='\033[0m' 
HIGHLIGHT_COL='\033[1;36m'

## Variables used throughout the script
PROJECT_NAME="robot40human_ws"
CURRENT_DIR=$(pwd)
NEW_DIR=$CURRENT_DIR
PROJECT_DIR=$NEW_DIR/$PROJECT_NAME
DOCKER_CONTAINER_NAME="robot_40"
MY_NAME=$(logname)

## Display installation directory
echo -e "\n" \
"PROJECT_NAME:              $PROJECT_NAME \n "\
"CURRENT_DIR:               $CURRENT_DIR \n "\
"NEW_DIR:                   $NEW_DIR \n "\
"PROJECT_DIR:               $PROJECT_DIR \n "\
"DOCKER_CONTAINER_NAME:     $DOCKER_CONTAINER_NAME \n "\
"MY_NAME:                   $MY_NAME" 


## If there is already a workpace named robot40human_ws, ask if user wishes to reinstall the workpace
if [[ -d $PROJECT_NAME ]]; then
    read -p "Do you want purge the project directory : $NEW_DIR before installation [y/n]? " yn1
    case $yn1 in
        [Yy]* ) 
            echo "Reinstallation" 
                sudo rm -rf $PROJECT_DIR 
                ;;
        [Nn]* ) 
            echo "Using previous configurations" ;;
        * ) 
            echo "Wrong input, aborting" 
            exit 1 ;;
    esac
else
    echo "Installation"
fi


## Execute functions defined above
cd $NEW_DIR
echo  -e " $HIGHLIGHT_COL cloning main repository $NORMAL_COL" 
clone_robot_repo
echo -e " $HIGHLIGHT_COL configuring docker $NORMAL_COL"
configure_docker
echo -e " $HIGHLIGHT_COL installing freenect $NORMAL_COL"
install_freenect
echo -e " $HIGHLIGHT_COL cloning other depedencies $NORMAL_COL"
clone_other_repos

## Remove few troublesome packages
cd $PROJECT_DIR/src
echo  -e " $HIGHLIGHT_COL removing ur_msg and ur_follower $NORMAL_COL" 
sudo rm -rf $PROJECT_DIR/src/universal_robot/ur_msgs
sudo rm -rf $PROJECT_DIR/src/ur_follower

## Build docker container from Dockerfile
echo -e "$HIGHLIGHT_COL building docker image $NORMAL_COL"
cd $NEW_DIR
docker build --no-cache -t  $DOCKER_CONTAINER_NAME .

## Build ROS workspace inside the container
echo -e "$HIGHLIGHT_COL catkin build $NORMAL_COL"
sudo rm -rf  $PROJECT_DIR/src/ur_follower
docker run -it --rm -v $PROJECT_DIR:/$PROJECT_NAME  robot_40  catkin build

## Once the freenect had been installed inside the contaienr remove its source folder
echo -e "$HIGHLIGHT_COL removing temporary files $NORMAL_COL"
rm -rf $NEW_DIR/libfreenect2

## Move the 'container' folder inside the robot40human_ws workspace, the folder contains script to start the container and Dockerfile to use with 'Dev containers' extension in VS code
cd $NEW_DIR
echo -e " $HIGHLIGHT_COL adding container folder to robot_40 folder $NORMAL_COL"
sudo cp -r $CURRENT_DIR/container $PROJECT_DIR
sudo mv $PROJECT_DIR/container/.devcontainer $PROJECT_DIR

## Change the ownership of the workspace so it can be edited outside the container
echo -e "$HIGHLIGHT_COL changing workspace ownership $NORMAL_COL"
sudo chown -R $MY_NAME:$MY_NAME $NEW_DIR

echo  -e "$HIGHLIGHT_COL Installation complete $NORMAL_COL" 
