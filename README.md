# GNU Radio setup from source

## SetupGrcOnUbuntu1804.sh

Install GNU Radio 3.8 and various OOTs and SDR tools from source on Ubuntu 18.04 LTS with the following components from source.

ONLY TESTED ON UBUNTU 18.04. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

Be sure to add "export PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH" to your .bashrc or .zshrc

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
* gr-satnogs
* gr-iio (PLUTO-SDR)
* gr-fosphor
* gr-adapt
* gr-foo
* gr-ieee802-15-4
* buildgr-ieee802-11
* gr-adsb
* gr-airspy
* SoapyPlutoSDR
* SoapyHackRF
* SoapyRtlSDR
* LimeSuite incl. Desktop tools
* multimon-ng
* SigDigger

### install

```
git clone https://github.com/krippendorf/setup_sdr.git
cd setup_sdr
sudo ./SetupGrcOnUbuntu1804.sh
sudo rm -rf ~/.cache/grc_gnuradio/
```
Now add ... 
```export PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH``` 
...to your .bashrc or .zshrc file!

or start apps like
``` 
PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH gnuradio-companion
PYTHONPATH=/usr/local/lib/python3/dist-packages/:$PYTHONPATH gqrx
```
