
apt-get -y upgrade
apt-get -y update
apt-get -y install octave octave-image octave-pkg-dev

cd ~
wget https://github.com/stegro/hdf5oct/archive/0.4.0.tar.gz
tar -zxf 0.4.0.tar.gz
cd hdf5oct-0.4.0

make
make install 
