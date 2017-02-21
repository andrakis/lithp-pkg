#!/usr/bin/env bash

#
# Generate files.js, which will import the JSON AST format of all found
# Lithp AST's.
#
# Additional paths can be supplied.

FIND_OPTS="-L"
EXT_IN=${EXT_IN:=ast}
EXT_OUT=${EXT_OUT:=json}
REL=${REL:=n}
OUTFILE=${OUTFILE:=files.js}

pushd node_modules/lithp > /dev/null
if [ ! -e run ]; then
	ln -s run.js run
fi

# Compile in compact mode
make RUNFLAGS=-cc
popd > /dev/null

content=$(cat << EOF
// $OUTFILE, generated from genfiles.sh\nvar files = {};
EOF
)

getContents () {
	path=$1
	prefix=`echo $path | sed 's/^..\///g'`
	shouldpop=0
	if [ "$path"x != "x" ]; then
		pushd $path > /dev/null
		shouldpop=1
		prefix=`echo $prefix | sed 's/^\(\.\.\/\)\+//g'`/
		path=./`echo $path | sed 's/^\(\.\.\/\)\+//g'`/
	fi
	echo "Packaging `find $FIND_OPTS . -name "*.$EXT_IN" 2> /dev/null | wc -l` files in `readlink -e .`"
	files=`find $FIND_OPTS . -name "*.$EXT_IN" 2> /dev/null`

	for file in $files; do
		asJson=`echo $file | sed "s/\.$EXT_IN$/.$EXT_OUT/g"`
		if [ "$file" != "$asJson" ]; then
			cp $file $asJson
		fi
		proper=`echo $asJson | sed 's/^..node_modules.//g' | sed 's/^\.\///g'`
		properAst=`echo $proper | sed "s/\.$EXT_OUT$/.$EXT_IN/g" | sed 's/^lithp\///g'`
		if [ "$REL" == "y" ]; then
			proper=./$proper
		fi
		content+="\nfiles['$prefix$properAst'] = require('$path$proper');"
	done

	if [ "$shouldpop" -eq 1 ]; then
		popd > /dev/null
	fi
}

getContents ""
for extra in $@; do
	getContents $extra
done

content+="\nmodule.exports = files;\n"
echo -e $content > $OUTFILE

