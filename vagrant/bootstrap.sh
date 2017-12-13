
apt-get -y upgrade
apt-get -y update
apt-get -y install octave octave-image octave-pkg-dev

cd ~
git clone https://github.com/stegro/hdf5oct
cd hdf5oct
make
make install 
