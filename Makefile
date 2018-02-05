.PHONY: clean help updateversion
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: ## remove all build, test, coverage and Python artifacts
	rm -fr dist/

test: ## run tests quickly with the default Python
	./RunUnitTests.m

release: dist ## package and upload a release to s3
	@echo "Creating new release"
	@vers=`cat VERSION` ; \
	tarfile=deep3m-$${vers}.tar.gz ;\
	cloudform=deep3m_$${vers}_basic_cloudformation.json ;\
	aws s3 cp dist/$$cloudform s3://deep3m-releases/$${vers}/$$cloudform --acl public-read ; \
	aws s3 cp dist/$$tarfile s3://deep3m-releases/$${vers}/$$tarfile --acl public-read

dist: clean ## builds source and wheel package
	@vers=`cat VERSION` ; \
	deep3mdirname=deep3m-$$vers ;\
	distdir=dist/$$deep3mdirname ;\
	/bin/mkdir -p $$distdir ;\
	cp *.m $$distdir/. ;\
	cp -a scripts $$distdir/. ;\
	cp -a model $$distdir/. ;\
        cp VERSION $$distdir/. ;\
        cat aws/basic_cloudformation.json | sed "s/@@VERSION@@/$${vers}/g" > dist/deep3m_$${vers}_basic_cloudformation.json ;\
	tar -C dist/ -cz $$deep3mdirname > $$distdir.tar.gz
	ls -l dist

updateversion: ## Updates version by updating VERSION file
	@cv=`cat VERSION`; \
	read -p "Current ($$cv) enter new version: " vers; \
	echo "Updating VERSION with new version: $$vers"; \
	echo $$vers > VERSION
