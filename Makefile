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

clean: ## remove all build, and test artifacts
	rm -fr dist/

test: ## run tests
	bats tests

checkrepo: ## checks if remote repo is CRBS
	@therepo=`git remote get-url origin | sed "s/^.*://" | sed "s/\/.*//"` ;\
	if [ "$$therepo" != "CRBS" ] ; then \
	echo "ERROR can only do a release from master repo, not from $$therepo" ; \
	exit 1 ;\
	else \
	echo "Repo appears to be master $$therepo" ; \
	fi

release: dist checkrepo ## package and upload a release to s3
	@echo "Creating new release"
	@vers=`cat VERSION` ; \
	tarfile=cdeep3m-$${vers}.tar.gz ;\
	cloudform=cdeep3m_$${vers}_basic_cloudformation.json ;\
	aws s3 cp dist/$$cloudform s3://cdeep3m-releases/$${vers}/$$cloudform --acl public-read ; \
	aws s3 cp dist/$$tarfile s3://cdeep3m-releases/$${vers}/$$tarfile --acl public-read ; \
	deep3mdirname=cdeep3m-$$vers ;\
	distdir=dist/$$deep3mdirname ;\
	cp $$distdir/README.md . ;\
	branchy=`git branch --list | sed "s/^\* *//"` ;\
	git commit -m 'updated launch stack link' README.md ;\
	git push origin $$branchy ;\
	git tag -a v$${vers} -m 'new release' ; \
	git push origin v$${vers}

dist: clean ## creates distributable package
	@vers=`cat VERSION` ; \
	hvers=`cat VERSION | sed "s/\./-/g"` ;\
	deep3mdirname=cdeep3m-$$vers ;\
	distdir=dist/$$deep3mdirname ;\
	/bin/mkdir -p $$distdir ;\
	cp *.m $$distdir/. ;\
	cp *.sh $$distdir/. ;\
	cp -a scripts $$distdir/. ;\
	cp -a mito_testsample $$distdir/. ;\
	cp -a README.md $$distdir/. ;\
	sed -i "s/cdeep3m-stack-.*template/cdeep3m-stack-$$hvers\&template/g" $$distdir/README.md ;\
	sed -i "s/releases\/.*\/cdeep3m.*\.json/releases\/$$vers\/cdeep3m\_$$vers\_basic\_cloudformation.json/g" $$distdir/README.md ;\
	sed -i "s/download\/.*\/cdeep3m.*gz/download\/v$$vers\/cdeep3m-$$vers.tar.gz/g" $$distdir/README.md ;\
	sed -i "s/^tar -zxf cdeep3m-.*tar.gz/tar -zxf cdeep3m-$$vers.tar.gz/g" $$distdir/README.md ;\
	sed -i "s/^cd cdeep3m-.*/cd cdeep3m-$$vers/g" $$distdir/README.md ;\
	cp -a LICENSE $$distdir/. ;\
	cp -a model $$distdir/. ;\
	cp -a tests $$distdir/. ;\
        cp VERSION $$distdir/. ;\
        cat aws/basic_cloudformation.json | sed "s/@@VERSION@@/$${vers}/g" > dist/cdeep3m_$${vers}_basic_cloudformation.json ;\
	tar -C dist/ -cz $$deep3mdirname > $$distdir.tar.gz
	ls -l dist

updateversion: ## Updates version by updating VERSION file
	@cv=`cat VERSION`; \
	read -p "Current ($$cv) enter new version: " vers; \
	echo "Updating VERSION with new version: $$vers"; \
	echo $$vers > VERSION
