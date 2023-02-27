if [[ $(stat -c '%a' /var/run/docker.sock)  -ne 666 ]];then 
    xhost +local:docker
    sudo chmod 666 /var/run/docker.sock
    echo "configured docker "
fi

DIR=$(dirname $(readlink -f $0))
cd $DIR
docker run -it  \
--rm  \
--privileged  \
--net=host  \
--env=NVIDIA_VISIBLE_DEVICES=all  \
--env=NVIDIA_DRIVER_CAPABILITIES=all  \
--env=DISPLAY  \
--env=QT_X11_NO_MITSHM=1 \
-v /tmp/.X11-unix:/tmp/.X11-unix  \
-v $(pwd)/..:/robot40human_ws:rw \
--name=robot_40_container \
robot_40 bash