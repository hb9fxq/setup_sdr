#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT.
#
# Frank Werner-Krippendorf, HB9FXQ 2020

if [ ! "`whoami`" = "root" ]
then
    echo "Please run this script as root using sudo! (sudo ./SetupGrcOnUbuntu1804.sh)"
    exit 1
fi

echo "creating source and dest dir"
SDRSOURCEDIR=/home/$SUDO_USER/wrk/src
SDRDESTDIR=/home/$SUDO_USER/wrk/sdr_env_gr38

mkdir -p $SDRSOURCEDIR
mkdir -p $SDRDESTDIR

export PYTHONPATH=$SDRDESTDIR/lib/python3/dist-packages:$SDRDESTDIR/lib/python3.6/site-packages:$PYTHONPATH
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

update_and_configure_system(){ 
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
    update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
    update-alternatives --set python /usr/bin/python3.6

    apt-get update && apt-get upgrade -y

    apt install -y autoconf automake yasm build-essential ccache cmake doxygen fort77 g++ git gpsd gpsd-clients gtk2-engines-pixbuf libasound2-dev libboost-all-dev libcodec2-dev libcomedi-dev libcppunit-1.14-0 libcppunit-dev libcppunit-doc libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgmp3-dev libgps-dev libgps23 libgsl-dev libgsm1-dev liblog4cpp5-dev libncurses5 libncurses5-dbg libncurses5-dev liborc-0.4-0 liborc-0.4-dev libpulse-dev libqt5opengl5-dev libqwt-dev libqwt-qt5-dev libqwt6abi1 libqwtplot3d-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin portaudio19-dev python-cheetah python-dev python-docutils python-gps python-gtk2 python-lxml python-mako python-numpy python-numpy-dbg python-numpy-doc python-opengl python-requests python-scipy python-setuptools python-six python-sphinx python-tk python-wxgtk3.0 python-zmq python3-click python3-click-plugins python3-gi-cairo python3-lxml python3-mako python3-numpy python3-pip python3-pyqt5 python3-scipy python3-sphinx python3-yaml python3-zmq r-base-dev swig vim wget htop curl libusb-1.0-0-dev pkg-config libfftw3-dev libqt5svg5-dev qt5-default qt5-qmake libliquid-dev python3-numpy python3-psutil python3-zmq python3-pyqt5 g++ libpython3-dev python3-pip cython3 qt5-default libfftw3-dev cmake pkg-config pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev libboost-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev libboost-regex-dev libboost-test-dev libconfig++-dev libgmp-dev liborc-0.4-0 liborc-0.4-dev liborc-0.4-dev-bin libjsoncpp-dev libpng++-dev libvorbis-dev libxml2 libxml2-dev bison flex libaio-dev libboost-all-dev libglfw3-dev libfreetype6-dev ocl-icd-opencl-dev python3-opengl libarmadillo-dev libarmadillo-dev libi2c-dev libi2c0 libsqlite3-dev libwxgtk3.0-dev gnuplot libfltk1.3-dev pavucontrol sox libsndfile1-dev apt-transport-https ca-certificates gnupg software-properties-common wget

    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -

    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
    apt-get update

    apt-get install -y cmake

    # install python dependencies
    pip3 install --upgrade setuptools
    pip3 install click
    pip3 install construct==2.9.45
    pip3 install requests
}

update_and_configure_system

# clone and build hackrf host
clone_and_cd hackrf/host https://github.com/mossmann/hackrf.git
cmake_and_ldconfig

# clone and build rtl-sdr
clone_and_cd rtl-sdr git://git.osmocom.org/rtl-sdr.git
cmake_and_ldconfig "-DINSTALL_UDEV_RULES=ON"
echo blacklist dvb_usb_rtl28xxu > /etc/modprobe.d/blacklist-rtl.conf
udevadm control --reload-rules
udevadm trigger

# clone and build UHD
clone_and_cd uhd/host https://github.com/EttusResearch/uhd "v3.15.0.0"
cmake_and_ldconfig
cp $SDRSOURCEDIR/script_uhd/host/utils/uhd-usrp.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger
$SDRDESTDIR/lib/uhd/utils/uhd_images_downloader.py

# clone and build GR
clone_and_cd gnuradio "https://github.com/gnuradio/gnuradio.git --recursive -b maint-3.8 --single-branch"
cmake_and_ldconfig

# clone and build airspyone & airspyhf
clone_and_cd airspyone_host https://github.com/airspy/airspyone_host.git
cmake_and_ldconfig "-DINSTALL_UDEV_RULES=ON"

# clone and build airspyone & airspyhf
clone_and_cd airspyone_host https://github.com/airspy/airspyone_host.git
cmake_and_ldconfig "-DINSTALL_UDEV_RULES=ON"

clone_and_cd airspyhf https://github.com/airspy/airspyhf.git
cmake_and_ldconfig "-DINSTALL_UDEV_RULES=ON"

# clone and build soapySDR
clone_and_cd SoapySDR https://github.com/pothosware/SoapySDR.git
cmake_and_ldconfig

# clone and build gr-osmosdr
clone_and_cd gr-osmosdr https://github.com/osmocom/gr-osmosdr.git "gr3.8"
cmake_and_ldconfig

# clone and build gqrx
clone_and_cd gqrx https://github.com/csete/gqrx.git
cmake_and_ldconfig

# clone and build rtl_433
clone_and_cd rtl_433 https://github.com/merbanan/rtl_433.git
cmake_and_ldconfig

# clone and build inspectrum
clone_and_cd inspectrum https://github.com/miek/inspectrum
cmake_and_ldconfig

# clone and build dump1090
clone_and_cd dump1090 https://github.com/antirez/dump1090.git
cd .. && make && cp dump1090 $SDRDESTDIR/bin/

# clone and build gr-satellites

cd $SDRSOURCEDIR
rm -rf scirpt_mpir_3.0.0
wget http://mpir.org/mpir-3.0.0.zip
unzip mpir-3.0.0.zip -d scirpt_mpir_3.0.0
cd scirpt_mpir_3.0.0/mpir-3.0.0
./configure --prefix=$SDRDESTDIR
make_and_ldconfig

clone_and_cd libfec https://github.com/daniestevez/libfec.git
cd .. && ./configure --prefix=$SDRDESTDIR
make_and_ldconfig

clone_and_cd gr-satellites https://github.com/daniestevez/gr-satellites.git
cmake_and_ldconfig
cd .. && ./compile_hierarchical.sh
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.cache/grc_gnuradio

# clone and build gr-soapy
clone_and_cd gr-soapy https://gitlab.com/librespacefoundation/gr-soapy.git
cmake_and_ldconfig

# TODO: lib-fec issues https://gitlab.com/librespacefoundation/satnogs/gr-satnogs.git

# clone and build gr-iio (PLUTO-SDR)
clone_and_cd libiio https://github.com/analogdevicesinc/libiio.git
cmake_and_ldconfig

clone_and_cd libad9361-iio https://github.com/analogdevicesinc/libad9361-iio.git
cmake_and_ldconfig

clone_and_cd gr-iio https://github.com/analogdevicesinc/gr-iio.git "upgrade-3.8"
cmake_and_ldconfig

# SoapySDR Plugins
clone_and_cd SoapyPlutoSDR https://github.com/pothosware/SoapyPlutoSDR
cmake_and_ldconfig

clone_and_cd SoapyHackRF https://github.com/pothosware/SoapyHackRF.git
cmake_and_ldconfig

clone_and_cd SoapyAirspy https://github.com/pothosware/SoapyAirspy.git
cmake_and_ldconfig

clone_and_cd SoapyAirspyHF https://github.com/pothosware/SoapyAirspyHF.git
cmake_and_ldconfig

# clone and build gr-fosphor
clone_and_cd gr-fosphor https://github.com/osmocom/gr-fosphor.git
cmake_and_ldconfig

# clone and build gr-adapt
clone_and_cd gr-adapt https://github.com/karel/gr-adapt.git
cmake_and_ldconfig

# clone and build gr-foo
clone_and_cd gr-foo https://github.com/bastibl/gr-foo.git
cmake_and_ldconfig

# clone and build gr-ieee802-15-4
clone_and_cd gr-ieee802-15-4 https://github.com/bastibl/gr-ieee802-15-4.git
cmake_and_ldconfig

# clone and build gr-ieee802-11
clone_and_cd gr-ieee802-11 https://github.com/bastibl/gr-ieee802-11.git
cmake_and_ldconfig

# clone and build gr-adsb
clone_and_cd gr-adsb https://github.com/mhostetter/gr-adsb.git "maint-3.8"
cmake_and_ldconfig

# clone and build LimeSuite
clone_and_cd LimeSuite https://github.com/myriadrf/LimeSuite.git "stable"
cmake_and_ldconfig
cd ../udev-rules
./install.sh

# TODO...https://github.com/ast/gr-airspy.git

# clone and build multimon-ng
clone_and_cd multimon-ng https://github.com/EliasOenal/multimon-ng.git
cmake_and_ldconfig

# clone and install SigDigger

# TODO: find a better way: 
ln -s $SDRDESTDIR/lib/libvolk.so /usr/lib/libvolk.so
ln -s $SDRDESTDIR/lib/libvolk.so.2.0 /usr/lib/libvolk.so.2.0

# clone and build sigutils
clone_and_cd sigutils https://github.com/BatchDrake/sigutils.git
cmake_and_ldconfig

clone_and_cd suscan https://github.com/BatchDrake/suscan.git
cmake_and_ldconfig

clone_and_cd SuWidgets https://github.com/BatchDrake/SuWidgets
cd .. && qmake SUWIDGETS_PREFIX=$SDRDESTDIR SuWidgetsLib.pro
make_and_ldconfig

clone_and_cd SigDigger https://github.com/BatchDrake/SigDigger
cd .. && qmake SUWIDGETS_PREFIX=$SDRDESTDIR SIGDIGGER_PREFIX=$SDRDESTDIR SigDigger.pro
make_and_ldconfig

# urh
pip3 install -I  urh

chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.cache/grc_gnuradio