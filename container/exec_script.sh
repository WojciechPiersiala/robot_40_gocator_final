DIR=$(dirname $(readlink -f $0))
cd $DIR

docker exec -it robot_40_container  bash
