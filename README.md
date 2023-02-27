# robot_40_gocator
## Installation
If you have acces to remote ropository robot40human_ws, you can use the installation script to automatically create a robot40_ws workspace downlad remote depedencies of that project and build a docker container. The container is allows to run the project in ROS Noetic environment with all requiered packages.

To begin installation enter: $ sudo ./installation_script.sh 
After installation go to the workspace enter: $ cd robot40human_ws
Start container, enter $source container/startup_script.sh
To enter container session from different terminal, enter : $source container/exec_script.sh
