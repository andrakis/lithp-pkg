#!/usr/bin/env bash

pushd node_modules/lithp
if [ ! -e run ]; then
	ln -s run.js run
fi
make clean
# Compile in compact mode
make RUNFLAGS=-cc
popd
files=`find . -name *.ast`
content=$(cat << EOF
// files.js, generated from genfiles.sh\nvar files = {};
EOF
)

for file in $files; do
	asJson=`echo $file | sed 's/\.ast$/.json/g'`
	cp $file $asJson
	proper=`echo $asJson | sed 's/^..node_modules.//g'`
	properAst=`echo $proper | sed 's/\.json$/.ast/g' | sed 's/^lithp\///g'`
	content+="\nfiles['$properAst'] = require('$proper');"
done

content+="\nmodule.exports = files;\n"

echo -e $content > files.js

