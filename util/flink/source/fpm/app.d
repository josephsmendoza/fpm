module fpm.app;

import std.stdio;
import fpm.flink;
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
	string linkPath;
	string targetPath;
	//dfmt off
	auto opt=getopt(args, config.passThrough, config.caseSensitive,
		"softlink|S", "create softlink instead of hardlink", &softlink,
		"softlink-fallback|s", "create softlink if hardlink fails", &softlinkFallback,
		"create-parent-directories|c", "create parent directories as necessary", &createParentDirectories,
		"delete-existing-file|d", "delete files as necessary", &deleteExistingFile,
		"force|f", "do whatever it takes", &force,
		"link|l", "path to new link", &linkPath,
		"target|t", "path that link refers to", &targetPath
	);
	//dfmt on
	if(opt.helpWanted){
		defaultGetoptPrinter("usage: "~args[0].baseName~" ([-t] target) ([-l] link)", opt.options);
		return;
	}
	args.popFront();
	if(targetPath.empty){
		enforce(args.length!=0,"missing target");
		targetPath=args[0];
		args.popFront();
	}
	if(linkPath.empty){
		enforce(args.length!=0,"missing link");
		linkPath=args[0];
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
	flink(targetPath, linkPath, flags);
}
