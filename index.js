
var lithp = require('lithp');

var files;
try {
	files = require('./files');
} catch (e) {
	console.error("Please run genfiles.sh");
	return;
}

global._lithp.browserify = true;
global._lithp.fileCache = files;

lithp.set_debug_flag(true);
//global._lithp.set_parser_debug(true);
var instance = new lithp.Lithp();
var code = files["modules/match.ast"];
var replParsed = lithp.Parser(code, {ast: true, finalize: true});
instance.setupDefinitions(replParsed, "match.ast");
instance.Define(replParsed, "__AST__", lithp.Types.Atom('true'));
instance.Define(replParsed, "MATCH_TEST", lithp.Types.Atom('true'));
instance.run(replParsed);
