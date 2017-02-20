LIBS=
RUN=node_modules/lithp/run
GENFILES=./genfiles.sh
RUNFLAGS=-cc
EXT=ast

default: lithp-pkg.js
all: default
.PHONY: clean node_modules run lithp

node_modules:
	if [ ! -e "node_modules" ]; then \
		ln -s .. node_modules; \
	fi

run:
	if [ ! -L "run" ]; then \
		ln -s node_modules/lithp/run.js run; \
	fi
	if [ ! -L "lithp" ]; then \
		ln -s node_modules/lithp lithp; \
	fi

lithp: node_modules
	$(MAKE) -C node_modules/lithp ast RUNFLAGS="$(RUNFLAGS)"

files.js: lithp
	EXT_IN=ast EXT_OUT=json OUTFILE=files.js ./genfiles.sh $(EXTRA_PATHS)

samples.js: lithp
	EXT_IN=lithp EXT_OUT=lithp OUTFILE=samples.js REL=y ./genfiles.sh $(EXTRA_PATHS)

lithp-pkg.js: node_modules run files.js index.js
	node_modules/.bin/browserify index.js -o lithp-pkg.js

update: clean
	npm update

clean: node_modules
	rm -f lithp-pkg.js
	rm -f files.js
	$(MAKE) -C node_modules/lithp clean
	rm node_modules
