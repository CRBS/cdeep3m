.PHONY: clean singularity

help:
	@echo "clean - remove all build and test artifacts"
	@echo "singularity - Creates singularity 2.3.2 image"

clean:
	rm -fr /home/ubuntu/build/
	rm -f /tmp/*.deb
	rm -f /tmp/Mini*


singularity: clean
	@echo 'Creating Singularity v232 image'
	mkdir -p /home/ubuntu/build
	imgfile='/home/ubuntu/build/cdeep3m.img' ; \
	sudo /usr/local/bin/singularity create -s 8092 $$imgfile ; \
	sudo /usr/local/bin/singularity bootstrap $$imgfile ubuntu-cuda.def; \
	echo 'Singularity image created $imgfile'
	mv /home/ubuntu/build/cdeep3m.img /vagrant/.
