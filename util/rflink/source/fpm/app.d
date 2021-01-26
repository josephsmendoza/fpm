module fpm.app;

import std.stdio;
import fpm.rflink;
import std.getopt;
import std.exception;
import std.range;
import std.path;

void main(string[] args) {
	bool softlink;
	bool softlinkFallback;
	bool createParentDirectories;
	bool deleteExistingFile;
	bool force;
	string sourceDir;
	string destDir;
	//dfmt off
	auto opt=getopt(args, config.passThrough, config.caseSensitive,
		"softlink|S", "create softlink instead of hardlink", &softlink,
		"softlink-fallback|s", "create softlink if hardlink fails", &softlinkFallback,
		"create-parent-directories|c", "create parent directories as necessary", &createParentDirectories,
		"delete-existing-file|d", "delete files as necessary", &deleteExistingFile,
		"force|f", "do whatever it takes", &force,
		"origin|O", "path to new link", &sourceDir,
		"destination|D", "path that link refers to", &destDir,
		"glob-skip|g", "file glob to skip, can be used multiple times", &skip
	);
	//dfmt on
	if(opt.helpWanted){
		defaultGetoptPrinter("usage: "~args[0].baseName~" ([-o] originDir) ([-d] destDir)", opt.options);
		return;
	}
	args.popFront();
	if(sourceDir.empty){
		enforce(args.length!=0,"missing origin");
		sourceDir=args[0];
		args.popFront();
	}
	if(destDir.empty){
		enforce(args.length!=0,"missing destination");
		destDir=args[0];
		args.popFront();
	}
	enforce(args.length==0,"unrecognized args");
	int[] flags;
	if(softlink){
		flags~=SOFTLINK;
	}
	if(softlinkFallback){
		flags~=SOFTLINK_FALLBACK;
	}
	if(createParentDirectories){
		flags~=CREATE_PARENT_DIRECTORIES;
	}
	if(deleteExistingFile){
		flags~=DELETE_EXISTING_FILE;
	}
	if(force){
		flags~=FORCE;
	}
	rflink(sourceDir, destDir, flags);
}
