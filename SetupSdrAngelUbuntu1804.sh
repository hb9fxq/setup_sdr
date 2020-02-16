#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT.
#
# Frank Werner-Krippendorf, HB9FXQ 2020
#
# Based on instructions from https://github.com/f4exb/sdrangel/wiki/Compile-from-source-in-Linux


if [ ! "`whoami`" = "root" ]
then
    echo "Please run this script as root using sudo! (sudo ./SetupGrcOnUbuntu1804.sh)"
    exit 1
fi

echo "creating source and dest dir"
SDRSOURCEDIR=/home/$SUDO_USER/wrk/srcSdrAngel
SDRDESTDIR=/home/$SUDO_USER/wrk/sdr_env_sdrangel

mkdir -p $SDRSOURCEDIR
mkdir -p $SDRDESTDIR

export LD_LIBRARY_PATH=$SDRDESTDIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$SDRDESTDIR/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH=$SDRDESTDIR/bin:$PATH

do_chown(){
    chown -R $SUDO_USER:$SUDO_USER $SDRSOURCEDIR
    chown -R $SUDO_USER:$SUDO_USER $SDRDESTDIR    
}

do_chown

clone_and_cd() {
    BASE_DIRECTORY=$(echo "$1" | cut -d "/" -f1)
    BASE_DIRECTORY=script_$BASE_DIRECTORY
    cd $SDRSOURCEDIR
    echo DELETING $BASE_DIRECTORY 
    rm -rf $BASE_DIRECTORY
    git clone $2 $BASE_DIRECTORY
    cd script_$1
    if [[ -n "$3" ]]
        then
            git checkout $3
    fi

    mkdir build
    cd build
    do_chown
}

make_and_ldconfig(){
    make -j $(nproc) && make install && ldconfig
    do_chown
}

cmake_and_ldconfig(){
    cmake -DCMAKE_INSTALL_PREFIX=$SDRDESTDIR $1 .. 
    make_and_ldconfig
}

apt_install_yes(){
    apt install -y $1
}

update_and_configure_system(){ 
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
    update-alternatives --set python /usr/bin/python3.6

    apt-get update && apt-get upgrade -y
    apt_install_yes "pavucontrol sox apt-transport-https ca-certificates autoconf git cmake g++ pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev"

    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
    apt-get update
    apt-get install -y cmake
}

#update_and_configure_system

#read -p "Press enter to continue" 

# clone and build CM265cc
#clone_and_cd cm256cc https://github.com/f4exb/cm256cc.git "f21e8bc1e9afdb0b28672743dcec111aec1d32d9"
#cmake_and_ldconfig

# clone and build SerialDV
#clone_and_cd serialDV https://github.com/f4exb/serialDV.git "v1.1.4"
#cmake_and_ldconfig

# clone and build DSDcc
#clone_and_cd DSDcc https://github.com/f4exb/dsdcc.git "v1.8.6"
#cmake_and_ldconfig

# Codec2/FreeDV
#apt_install_yes "libspeexdsp-dev libsamplerate0-dev"
#clone_and_cd codec2 https://github.com/drowe67/codec2.git 76a20416d715ee06f8b36a9953506876689a3bd2
#cmake_and_ldconfig

# clone and build Airspy
#clone_and_cd libairspy https://github.com/airspy/host.git "bfb667080936ca5c2d23b3282f5893931ec38d3f"
#cmake_and_ldconfig

# clone and build SDRplay RSP1
#clone_and_cd libmirisdr https://github.com/f4exb/libmirisdr-4.git
#cmake_and_ldconfig

# clone and build RTL-SDR
# clone_and_cd rtl-sdr https://github.com/osmocom/rtl-sdr "be1d1206bfb6e6c41f7d91b20b77e20f929fa6a7"
# cmake_and_ldconfig

# clone and build Pluto SDR
#clone_and_cd libiio https://github.com/analogdevicesinc/libiio.git "826563e41b5ce9890b75506f672017de8d76d52d"
#cmake_and_ldconfig

# clone and build BladeRF all versions
#clone_and_cd bladeRF https://github.com/Nuand/bladeRF.git "2019.07"
#cmake_and_ldconfig

# clone and build HackRF
#clone_and_cd hackrf/host https://github.com/mossmann/hackrf.git "v2018.01.1"
#cmake_and_ldconfig

# clone and build LimeSuite
#clone_and_cd LimeSuite https://github.com/myriadrf/LimeSuite.git "v20.01.0"
#cmake_and_ldconfig

# clone and build airspyhf
#clone_and_cd airspyhf https://github.com/airspy/airspyhf "1.1.5"
#cmake_and_ldconfig

# clone and build Perseus
#clone_and_cd libperseus https://github.com/f4exb/libperseus-sdr.git "afefa23e3140ac79d845acb68cf0beeb86d09028"
#cmake_and_ldconfig

# clone and build XTRX
#clone_and_cd xtrx-images https://github.com/xtrx-sdr/images.git "053ec82"
#cd ..
#git submodule init
#git submodule update
#cd sources
#mkdir build
#cd build
#cmake_and_ldconfig

# clone and build airspyhf
clone_and_cd sdrangel https://github.com/f4exb/sdrangel.git
cmake_and_ldconfig "-Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=ON -DMIRISDR_DIR=$SDRDESTDIR -DAIRSPY_DIR=$SDRDESTDIR -DAIRSPYHF_DIR=$SDRDESTDIR -DBLADERF_DIR=$SDRDESTDIR -DHACKRF_DIR=$SDRDESTDIR -DRTLSDR_DIR=$SDRDESTDIR -DLIMESUITE_DIR=$SDRDESTDIR -DIIO_DIR=$SDRDESTDIR -DPERSEUS_DIR=$SDRDESTDIR -DXTRX_DIR=$SDRDESTDIR -DSOAPYSDR_DIR=$SDRDESTDIR -DCM256CC_DIR=$SDRDESTDIR -DDSDCC_DIR=$SDRDESTDIR -DSERIALDV_DIR=$SDRDESTDIR -DMBE_DIR=$SDRDESTDIR -DCODEC2_DIR=$SDRDESTDIR"

chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.cache/grc_gnuradio