# Build essential SDR tools from source


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.


## SetupGrcOnUbuntu1804.sh (GNU Radio 3.8 + friends)

Install GNU Radio 3.8, various OOTs and SDR tools from source on Ubuntu 18.04 LTS with the following components from source.

To use SDR Play experimental SOAPY plugin, SDRplay API for Linux Version 3.06 has to be downloaded and installed before executing this script.

ONLY TESTED ON UBUNTU 18.04. 

* UHD  v3.15.0.0
* GR maint-3.8
* HackRF Host
* OSMOSDR RTL-SDR
* AirspyOne / Airspy HF
* SOAPYSDR (Core)
* GR-OSMOSDR
* GQRX
* RTL 433
* Inspectrum
* URH
* dump1090
* gr-satellites
* gr-soapy
* TODO gr-satnogs
* gr-iio (PLUTO-SDR)
* gr-fosphor
* gr-adapt
* gr-foo
* gr-ieee802-15-4
* buildgr-ieee802-11
* gr-adsb
* TODO gr-airspy
* SoapyPlutoSDR
* SoapyHackRF
* SoapyRtlSDR
* SoapySDRplay for public Beta API 3.06
* LimeSuite incl. Desktop tools
* multimon-ng
* SigDigger

### Install

```
git clone https://github.com/krippendorf/setup_sdr.git
cd setup_sdr
sudo ./SetupGrcOnUbuntu1804.sh
```
Script will take - depending on your machine - a pretty long time... time to get some coffee :-) Maybe donate a coffee to Frank, HB9FXQ via PayPal (wernerkrippendorf@gmail.com) to support the development and maintenance of this script.

To start, setup environment vars:
``` 
source vars

#Then start apps.... 
gnuradio-compannion
gqrx
...etc
```


## SetupSdrAngelUbuntu1804.sh (SDR Angel GUI Application with drivers)

Setup SDR Angel based on https://github.com/f4exb/sdrangel/wiki/Compile-from-source-in-Linux instructions.

### Install

```
git clone https://github.com/krippendorf/setup_sdr.git
cd setup_sdr
sudo ./SetupGrcOnUbuntu1804.sh
```

To start, setup environment vars:
``` 
source vars_sdrangel

#Then start app.... 
sdrangel
```
