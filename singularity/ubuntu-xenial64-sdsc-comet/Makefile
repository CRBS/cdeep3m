.PHONY: clean singularity

help:
	@echo "clean - remove all build and test artifacts"
	@echo "singularity - Creates singularity 2.3.2 image"

clean:
	sudo rm -fr /vagrant/build/
	sudo rm -f /tmp/*.deb
	sudo rm -f /tmp/Mini*


singularity: clean
	@echo 'Creating Singularity v232 image'
	mkdir -p /vagrant/build
	imgfile='/vagrant/build/cdeep3m.img' ; \
	sudo /usr/local/bin/singularity create -s 12096 $$imgfile ; \
	sudo /usr/local/bin/singularity bootstrap $$imgfile ubuntu-cuda.def; \
	echo 'Singularity image created $imgfile'
