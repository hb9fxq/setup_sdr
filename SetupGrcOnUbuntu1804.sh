#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT.
#
# Frank Werner-Krippendorf, HB9FXQ 2020

# source root
mkdir -p /opt/sdr/src
mkdir -p /opt/sdr/tools

export PYTHONPATH=/opt/sdr/tools/lib/python3/dist-packages:/opt/sdr/tools/lib/python3.6/site-packages:$PYTHONPATH
export LD_LIBRARY_PATH=/opt/sdr/tools/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/opt/sdr/tools/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH=/opt/sdr/tools/bin:$PATH

# set default python interpreter to python 3.6 
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
update-alternatives --set python /usr/bin/python3.6

# update and install dependencies
apt-get update && apt-get upgrade -y
apt install -y autoconf automake yasm build-essential ccache cmake doxygen fort77 g++ git gpsd gpsd-clients gtk2-engines-pixbuf libasound2-dev libboost-all-dev libcodec2-dev libcomedi-dev libcppunit-1.14-0 libcppunit-dev libcppunit-doc libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgmp3-dev libgps-dev libgps23 libgsl-dev libgsm1-dev liblog4cpp5-dev libncurses5 libncurses5-dbg libncurses5-dev liborc-0.4-0 liborc-0.4-dev libpulse-dev libqt5opengl5-dev libqwt-dev libqwt-qt5-dev libqwt6abi1 libqwtplot3d-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin portaudio19-dev python-cheetah python-dev python-docutils python-gps python-gtk2 python-lxml python-mako python-numpy python-numpy-dbg python-numpy-doc python-opengl python-requests python-scipy python-setuptools python-six python-sphinx python-tk python-wxgtk3.0 python-zmq python3-click python3-click-plugins python3-gi-cairo python3-lxml python3-mako python3-numpy python3-pip python3-pyqt5 python3-scipy python3-sphinx python3-yaml python3-zmq r-base-dev swig vim wget htop curl libusb-1.0-0-dev pkg-config libfftw3-dev libqt5svg5-dev qt5-default qt5-qmake libliquid-dev python3-numpy python3-psutil python3-zmq python3-pyqt5 g++ libpython3-dev python3-pip cython3 qt5-default libfftw3-dev cmake pkg-config pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev libboost-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev libboost-regex-dev libboost-test-dev libconfig++-dev libgmp-dev liborc-0.4-0 liborc-0.4-dev liborc-0.4-dev-bin libjsoncpp-dev libpng++-dev libvorbis-dev libxml2 libxml2-dev bison flex libaio-dev libboost-all-dev libglfw3-dev libfreetype6-dev ocl-icd-opencl-dev python3-opengl libarmadillo-dev libarmadillo-dev libi2c-dev libi2c0 libsqlite3-dev libwxgtk3.0-dev gnuplot libfltk1.3-dev pavucontrol sox libsndfile1-dev apt-transport-https ca-certificates gnupg software-properties-common wget

wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -

sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
sudo apt-get update

apt-get install -y cmake


# install python dependencies
pip3 install --upgrade setuptools
pip3 install click
pip3 install construct==2.9.45
pip3 install requests

# clone and build UHD
cd /opt/sdr/src
git clone https://github.com/EttusResearch/uhd
cd uhd
git checkout v3.15.0.0
cd host
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc)
make install
ldconfig

# clone and build GR
cd /opt/sdr/src
git clone --recursive -b maint-3.8 --single-branch https://github.com/gnuradio/gnuradio.git
cd gnuradio/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc)
make install
ldconfig

# clone and build hackrf host
cd /opt/sdr/src
git clone https://github.com/mossmann/hackrf.git
cd hackrf
mkdir host/build
cd host/build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install
ldconfig

# clone and build rtl-sdr
cd /opt/sdr/src
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

# clone and build airspyone & airspyhf
cd /opt/sdr/src
git clone https://github.com/airspy/airspyone_host.git
cd airspyone_host
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/airspy/airspyhf.git 
cd airspyhf
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

# clone and build soapySDR
cd /opt/sdr/src
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install
ldconfig
SoapySDRUtil --info

# clone and build gr-osmosdr
cd /opt/sdr/src
git clone https://github.com/osmocom/gr-osmosdr.git
cd gr-osmosdr/
git checkout gr3.8
mkdir build
cd build/
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc)
make install
ldconfig

# clone and build GQRX
cd /opt/sdr/src
git clone https://github.com/csete/gqrx.git gqrx.git
cd gqrx.git
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install
ldconfig

# clone and build rtl_433
cd /opt/sdr/src
git clone https://github.com/merbanan/rtl_433.git
cd rtl_433/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install

# clone and build inspectrum
cd /opt/sdr/src && git clone https://github.com/miek/inspectrum
cd inspectrum
mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools .. && make -j $(nproc) && make install

# install URH
pip3 install urh

# install udev rules & download ettus uhd FPGA images
echo blacklist dvb_usb_rtl28xxu > /etc/modprobe.d/blacklist-rtl.conf
cd /opt/sdr/src/uhd/host/utils
cp uhd-usrp.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger

/opt/sdr/tools/lib/uhd/utils/uhd_images_downloader.py

# clone and build dump1090
cd /opt/sdr/src && git clone https://github.com/antirez/dump1090.git 
cd dump1090
make
cp dump1090 /opt/sdr/tools/bin/

# clone and build gr-satellites
cd /opt/sdr/src
git clone https://github.com/daniestevez/libfec.git
cd libfec
./configure --prefix=/opt/sdr/tools
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone -b maint-3.8 --single-branch https://github.com/daniestevez/gr-satellites.git
cd gr-satellites
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc)
make install
ldconfig
cd ..
./compile_hierarchical.sh

# clone and build gr-soapy
cd /opt/sdr/src
git clone https://gitlab.com/librespacefoundation/gr-soapy.git
cd gr-soapy
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
wget http://mpir.org/mpir-3.0.0.zip
unzip mpir-3.0.0.zip
cd mpir-3.0.0
./configure --prefix=/opt/sdr/tools
make
make install
ldconfig

# TODO: lib-fec issues
# clone and build gr-satnogs
#cd /opt/sdr/src
#git clone https://gitlab.com/librespacefoundation/satnogs/gr-satnogs.git
#cd gr-satnogs
#cd build
#cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
#mkdir build
#make -j $(nproc)
#make install

# clone and build gr-iio (PLUTO-SDR)
cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/libad9361-iio.git
cd libad9361-iio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/gr-iio.git 
cd gr-iio
git checkout upgrade-3.8
mkdir build
cd build
cmake cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools .. 
make -j $(nproc) 
make install
ldconfig

# SoapySDR Plugins
cd /opt/sdr/src
git clone https://github.com/pothosware/SoapyPlutoSDR
cd SoapyPlutoSDR
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/pothosware/SoapyHackRF.git
cd SoapyHackRF
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/pothosware/SoapyAirspy.git
cd SoapyAirspy
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/pothosware/SoapyAirspyHF.git
cd SoapyAirspyHF
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig




# clone and build gr-fosphor
cd /opt/sdr/src
git clone https://github.com/osmocom/gr-fosphor.git
cd gr-fosphor
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

# clone and build gr-adapt
cd /opt/sdr/src
git clone https://github.com/karel/gr-adapt.git
cd gr-adapt
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

# clone and build gr-foo
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-foo.git
cd gr-foo
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make
sudo make install
sudo ldconfig

# clone and build gr-ieee802-15-4
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-ieee802-15-4.git
cd gr-ieee802-15-4
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

# clone and buildgr-ieee802-11
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-ieee802-11.git
cd gr-ieee802-11
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig

# clone and build gr-adsb
cd /opt/sdr/src
git clone https://github.com/mhostetter/gr-adsb.git
cd gr-adsb
git checkout maint-3.8
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ..
make -j $(nproc) 
make install
ldconfig


# clone and build LimeSuite
cd /opt/sdr/src
git clone https://github.com/myriadrf/LimeSuite.git
cd LimeSuite
git checkout stable
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc) 
make install
ldconfig
cd ../udev-rules
./install.sh

# clone and install gr-airspy
# TODO... fix
#cd /opt/sdr/src
#git clone https://github.com/ast/gr-airspy.git
#cd gr-airspy
#mkdir build
#cd build
#cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
#make -j $(nproc) 
#make install
#ldconfig

# clone and install multimon-ng
cd /opt/sdr/src
git clone https://github.com/EliasOenal/multimon-ng.git
cd multimon-ng
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc) 
make install
ldconfig


# clone and install SigDigger

# TODO: find a better way: 
sudo ln -s /opt/sdr/tools/lib/libvolk.so /usr/lib/libvolk.so
sudo ln -s /opt/sdr/tools/lib/libvolk.so.2.0 /usr/lib/libvolk.so.2.0

cd /opt/sdr/src
git clone https://github.com/BatchDrake/sigutils.git
cd sigutils
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/BatchDrake/suscan.git
cd suscan
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/sdr/tools ../
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/BatchDrake/SuWidgets
cd SuWidgets
qmake SUWIDGETS_PREFIX=/opt/sdr/tools SuWidgetsLib.pro
make
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/BatchDrake/SigDigger
cd SigDigger
qmake SIGDIGGER_PREFIX=/opt/sdr/tools SigDigger.pro
make
make install
ldconfig


# set ownership of /opt/sdr to user called this script
chown -R $SUDO_USER:$SUDO_USER /opt/sdr
