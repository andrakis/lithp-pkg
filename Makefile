LIBS=
RUN=node_modules/lithp/run
GENFILES=./genfiles.sh
RUNFLAGS=

default: lithp-pkg.js
all: default

lithp-pkg.js: index.js
	./genfiles.sh
	browserify index.js -o lithp-pkg.js

