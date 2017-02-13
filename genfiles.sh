#!/usr/bin/env bash

#
# Generate files.js, which will import the JSON AST format of all found
# Lithp AST's.
#
# Additional paths can be supplied.

FIND_OPTS="-L"

pushd node_modules/lithp > /dev/null
if [ ! -e run ]; then
	ln -s run.js run
fi
#make clean
# Compile in compact mode
make RUNFLAGS=-cc
popd > /dev/null

content=$(cat << EOF
// files.js, generated from genfiles.sh\nvar files = {};
EOF
)

getContents () {
	path=$1
	prefix=`echo $path | sed 's/^..\///g'`
	if [ "$path"x != "x" ]; then
		pushd $path > /dev/null
		prefix=`echo $prefix | sed 's/^\(\.\.\/\)\+//g'`/
		path=./`echo $path | sed 's/^\(\.\.\/\)\+//g'`/
	fi
	echo "Packaging `find $FIND_OPTS . -name '*.ast' 2> /dev/null | wc -l` files in `readlink -e .`"
	files=`find $FIND_OPTS . -name '*.ast' 2> /dev/null`

	for file in $files; do
		asJson=`echo $file | sed 's/\.ast$/.json/g'`
		cp $file $asJson
		proper=`echo $asJson | sed 's/^..node_modules.//g' | sed 's/^\.\///g'`
		properAst=`echo $proper | sed 's/\.json$/.ast/g' | sed 's/^lithp\///g'`
		content+="\nfiles['$prefix$properAst'] = require('$path$proper');"
	done

	if [ "$path"x != "x" ]; then
		popd > /dev/null
	fi
}

getContents ""
for extra in $@; do
	getContents $extra
done

content+="\nmodule.exports = files;\n"
echo -e $content > files.js

