FROM ubuntu:18.04
MAINTAINER Frank Werner-Krippendorf <mail@hb9fxq.ch>


ENV DEBIAN_FRONTEND noninteractive
ENV UNAME sdrtools

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils sudo

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio


COPY pulse-client.conf /etc/pulse/client.conf

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git curl wget python3-mako python3-cairo software-properties-common libgtk-3-dev libghc-pango-dev python3-gi-cairo pavucontrol sox apt-transport-https ca-certificates autoconf automake libtool libudev-dev pkg-config build-essential python3-pip libpython3-dev python-dev doxygen vim wget htop curl g++ libconfig++-dev libpng++-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libfftw3-bin libboost-all-dev libncurses5 libncurses5-dbg libncurses5-dev python-numpy python-numpy-dbg python-numpy-doc python3-numpy dpdk dpdk-dev swig liblog4cpp5-dev libgmp-dev libgmp3-dev python3-pyqt5 python3-sphinx python3-yaml python3-zmq libzmq3-dev libzmq5 python3-click python3-click-plugins libsdl1.2-dev libqwt-dev libqwt-qt5-dev libqwt6abi1 libqwtplot3d-qt5-dev libgsl-dev qt5-default libqt5opengl5-dev libqt5svg5-dev libliquid-dev yasm libxml2 libxml2-dev ocl-icd-opencl-dev python3-opengl libfreetype6-dev libsqlite3-dev libwxgtk3.0-dev gnuplot libfltk1.3-dev libjsoncpp-dev libpng++-dev libvorbis-dev libsndfile1-dev cython3 luajit python-dbg python3-dbg graphviz bison flex 

USER sdrtools
ENV HOME /home/sdrtools

COPY ./SetupGrcOnUbuntu1804.sh /home/${UNAME}/SetupGrcOnUbuntu1804.sh
COPY ./vars /home/${UNAME}/vars
copy ./entrypoint.sh /home/${UNAME}/entrypoint.sh
RUN sudo /home/${UNAME}/SetupGrcOnUbuntu1804.sh

ENTRYPOINT ["/home/${UNAME}/entrypoint.sh"]
