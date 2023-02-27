FROM osrf/ros:noetic-desktop-full

# FROM ros:noetic

# RUN sudo -i
# RUN apt update
# RUN logout 
# RUN apt update 

RUN apt update 

RUN mkdir libfreenect2
COPY ./libfreenect2 ./libfreenect2
RUN apt-get install build-essential cmake pkg-config -y
RUN apt-get install libusb-1.0-0-dev -y
RUN apt-get install libturbojpeg0-dev -y
RUN apt-get install libglfw3-dev -y

WORKDIR /libfreenect2
RUN mkdir build
WORKDIR /libfreenect2/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/freenect2
RUN make
RUN make install


WORKDIR /
RUN rm -rf /libfreenect2
RUN apt install -y ros-noetic-scaled-joint-trajectory-controller 
RUN apt install -y ros-noetic-speed-scaling-interface
RUN apt install -y libompl-dev
RUN apt install -y ros-noetic-rosparam-shortcuts
RUN apt install -y ros-noetic-rosparam-shortcuts-dbgsym
RUN apt install -y ros-noetic-vision-msgs
RUN apt install -y ros-noetic-speed-scaling-state-controller-dbgsym
RUN apt install -y ros-noetic-speed-scaling-state-controller
RUN apt install -y ros-noetic-gazebo-ros-pkgs ros-noetic-gazebo-ros-control ros-noetic-joy
RUN apt install -y ros-noetic-dynamixel-sdk
RUN apt install -y libserial-dev
RUN apt install -y portaudio19-dev
RUN apt install -y ros-noetic-rgbd-launch
RUN apt install -y ros-noetic-moveit-ros-planning-interface
RUN apt install -y ros-noetic-moveit-planners-ompl ros-noetic-moveit-commander ros-noetic-moveit-ros-planning
RUN apt install -y ros-noetic-effort-controllers ros-noetic-force-torque-sensor-controller ros-noetic-joint-trajectory-controller
RUN apt install -y ros-noetic-moveit-simple-controller-manager
RUN apt install -y ros-noetic-ros-control ros-noetic-ros-controllers ros-noetic-velocity-controllers
RUN apt install -y ros-noetic-tf2-tools
RUN apt install -y nano
RUN apt install -y python3-catkin-tools
RUN apt install -y ros-noetic-moveit
RUN apt install -y ros-noetic-dynamixel-workbench
RUN apt install -y ros-noetic-moveit-visual-tools
RUN apt install -y iputils-ping
RUN apt install -y net-tools 
RUN apt install -y pcl-tools
# RUN RUN python3 -m pip install scipy

RUN sudo apt -y install python3-pip
RUN python3 -m pip install "kivy[base]" kivy_examples
RUN python3 -m pip install scipy
RUN python3 -m pip install open3d


WORKDIR /robot40human_ws
CMD echo "Container started"



