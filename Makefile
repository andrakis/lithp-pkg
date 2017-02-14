LIBS=
RUN=node_modules/lithp/run
GENFILES=./genfiles.sh
RUNFLAGS=-cc

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

lithp: node_modules
	$(MAKE) -C node_modules/lithp ast RUNFLAGS="$(RUNFLAGS)"

files.js: lithp
	./genfiles.sh $(EXTRA_PATHS)

lithp-pkg.js: node_modules run files.js index.js
	node_modules/.bin/browserify index.js -o lithp-pkg.js

clean: node_modules
	rm -f lithp-pkg.js
	rm -f files.js
	$(MAKE) -C node_modules/lithp clean
	rm node_modules
