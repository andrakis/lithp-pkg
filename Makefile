LIBS=
RUN=node_modules/lithp/run
GENFILES=./genfiles.sh
RUNFLAGS=

default: lithp-pkg.js
all: default

node_modules:
	if [ ! -e "node_modules" ]; then \
		ln -s .. node_modules; \
	fi

run:
	if [ ! -L "run" ]; then \
		ln -s node_modules/lithp/run.js run; \
	fi

files.js:
	./genfiles.sh $(EXTRA_PATHS)

lithp-pkg.js: node_modules run files.js index.js
	node_modules/.bin/browserify index.js -o lithp-pkg.js

clean:
	rm -f lithp-pkg.js
	rm -f files.js
