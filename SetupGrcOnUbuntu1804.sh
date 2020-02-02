#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT.
#
# Frank Werner-Krippendorf, HB9FXQ 2020

# source root
mkdir -p /opt/sdr/src

export PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH

# set default python interpreter to python 3.6 
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
update-alternatives --set python /usr/bin/python3.6

# update and install dependencies
apt-get update && apt-get upgrade -y
apt install -y autoconf automake yasm build-essential ccache cmake doxygen fort77 g++ git gpsd gpsd-clients gtk2-engines-pixbuf libasound2-dev libboost-all-dev libcodec2-dev libcomedi-dev libcppunit-1.14-0 libcppunit-dev libcppunit-doc libfftw3-bin libfftw3-dev libfftw3-doc libfontconfig1-dev libgmp-dev libgmp3-dev libgps-dev libgps23 libgsl-dev libgsm1-dev liblog4cpp5-dev libncurses5 libncurses5-dbg libncurses5-dev liborc-0.4-0 liborc-0.4-dev libpulse-dev libqt5opengl5-dev libqwt-dev libqwt-qt5-dev libqwt6abi1 libqwtplot3d-qt5-dev libsdl1.2-dev libtool libudev-dev libusb-1.0-0 libusb-1.0-0-dev libusb-dev libxi-dev libxrender-dev libzmq3-dev libzmq5 ncurses-bin portaudio19-dev python-cheetah python-dev python-docutils python-gps python-gtk2 python-lxml python-mako python-numpy python-numpy-dbg python-numpy-doc python-opengl python-requests python-scipy python-setuptools python-six python-sphinx python-tk python-wxgtk3.0 python-zmq python3-click python3-click-plugins python3-gi-cairo python3-lxml python3-mako python3-numpy python3-pip python3-pyqt5 python3-scipy python3-sphinx python3-yaml python3-zmq r-base-dev snapd swig vim wget htop curl libusb-1.0-0-dev pkg-config libfftw3-dev libqt5svg5-dev qt5-default qt5-qmake libliquid-dev python3-numpy python3-psutil python3-zmq python3-pyqt5 g++ libpython3-dev python3-pip cython3 qt5-default libfftw3-dev cmake pkg-config pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev libboost-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev libboost-regex-dev libboost-test-dev libconfig++-dev libgmp-dev liborc-0.4-0 liborc-0.4-dev liborc-0.4-dev-bin libjsoncpp-dev libpng++-dev libvorbis-dev libxml2 libxml2-dev bison flex libaio-dev libboost-all-dev libglfw3-dev libfreetype6-dev ocl-icd-opencl-dev python3-opengl libarmadillo-dev libarmadillo-dev

# fetch latest available cmake via snap
snap install cmake --classic

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
cmake ../
make -j $(nproc)
make install
ldconfig

# clone and build GR
cd /opt/sdr/src
git clone --recursive -b maint-3.8 --single-branch https://github.com/gnuradio/gnuradio.git
cd gnuradio/
mkdir build
cd build
cmake ../
make -j $(nproc)
make install
ldconfig

# clone and build hackrf host
cd /opt/sdr/src
git clone https://github.com/mossmann/hackrf.git
cd hackrf
mkdir host/build
cd host/build
cmake ..
make -j $(nproc)
make install
ldconfig

# clone and build rtl-sdr
cd /opt/sdr/src
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

# clone and build airspyone & airspyhf
cd /opt/sdr/src
git clone https://github.com/airspy/airspyone_host.git
cd airspyone_host
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/airspy/airspyhf.git 
cd airspyhf
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make -j $(nproc)
make install
ldconfig

# clone and build soapySDR
cd /opt/sdr/src
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
mkdir build
cd build
cmake ..
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
cmake ../
make -j $(nproc)
make install
ldconfig

# clone and build GQRX
cd /opt/sdr/src
git clone https://github.com/csete/gqrx.git gqrx.git
cd gqrx.git
mkdir build
cd build
cmake ..
make -j $(nproc)
make install
ldconfig

# clone and build rtl_433
cd /opt/sdr/src
git clone https://github.com/merbanan/rtl_433.git
cd rtl_433/
mkdir build
cd build
cmake ..
make -j $(nproc)
make install

# clone and build inspectrum
cd /opt/sdr/src && git clone https://github.com/miek/inspectrum
cd inspectrum
mkdir build && cd build && cmake .. && make -j $(nproc) && make install

# install URH
pip3 install urh

# install udev rules & download ettus uhd FPGA images
echo blacklist dvb_usb_rtl28xxu > /etc/modprobe.d/blacklist-rtl.conf
cd /opt/sdr/src/uhd/host/utils
cp uhd-usrp.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger

uhd_images_downloader

# clone and build dump1090
cd /opt/sdr/src && git clone https://github.com/antirez/dump1090.git 
cd dump1090
make -j $(nproc)
cp dump1090 /usr/local/bin/


# clone and build gr-satellites
cd /opt/sdr/src
git clone https://github.com/daniestevez/libfec.git
cd libfec
./configure
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone -b maint-3.8 --single-branch https://github.com/daniestevez/gr-satellites.git
cd gr-satellites
mkdir build
cd build
cmake ../
make -j $(nproc)
make install
ldconfig
cd ..
./compile_hierarchical.sh

# WIP... add DPKGs libaec-dev libtar-dev befor iqzip
#cd /opt/sdr/src
#git clone --recurse-submodules https://github.com/deepsig/libsigmf.git
#cd libsigmf
#mkdir build && cd build
#cmake ..
#make -j $(nproc)
#sudo make install

#cd /opt/sdr/src
#git clone https://gitlab.com/librespacefoundation/sdrmakerspace/iqzip.git
#cd iqzip
#mkdir build && cd build
#cmake ..
#make -j $(nproc)
#sudo make install

# clone and build gr-soapy
cd /opt/sdr/src
git clone https://gitlab.com/librespacefoundation/gr-soapy.git
cd gr-soapy
mkdir build
cd build
cmake ..
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
wget http://mpir.org/mpir-3.0.0.zip
unzip mpir-3.0.0.zip
cd mpir-3.0.0
./configure
make
make install
ldconfig

# clone and build gr-satnogs
cd /opt/sdr/src
git clone https://gitlab.com/librespacefoundation/satnogs/gr-satnogs.git
cd gr-satnogs
mkdir build
cd build
cmake ..
make -j $(nproc)
make install

# clone and build gr-iio (PLUTO-SDR)
cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir build
cd build
cmake ..
make -j $(nproc) 
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/libad9361-iio.git
cd libad9361-iio
mkdir build
cd build
cmake ..
make -j $(nproc)
make install
ldconfig

cd /opt/sdr/src
git clone https://github.com/analogdevicesinc/gr-iio.git 
cd gr-iio
git checkout upgrade-3.8
mkdir build
cd build
cmake cmake .. 
make -j $(nproc) 
make install
ldconfig

# clone and build gr-fosphor
cd /opt/sdr/src
git clone https://github.com/osmocom/gr-fosphor.git
cd gr-fosphor
mkdir build
cd build
cmake ..
make -j $(nproc) 
make install
ldconfig

# clone and build gr-adapt
cd /opt/sdr/src
git clone https://github.com/karel/gr-adapt.git
cd gr-adapt
mkdir build
cd build
cmake ..
make -j $(nproc) 
make install
ldconfig

# clone and build gr-foo
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-foo.git
cd gr-foo
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig

# clone and build gr-ieee802-15-4
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-ieee802-15-4.git
cd gr-ieee802-15-4
mkdir build
cd build
cmake ..
make -j $(nproc) 
make install
ldconfig

# clone and buildgr-ieee802-11
cd /opt/sdr/src
git clone https://github.com/bastibl/gr-ieee802-11.git
cd gr-ieee802-11
mkdir build
cd build
cmake ..
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
cmake ..
make -j $(nproc) 
make install
ldconfig