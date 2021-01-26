module fpm.app;

import std.stdio;
import fpm.uflink;
import std.getopt;
import std.exception;
import std.range;
import std.file;
import std.path;
import asdf;

void main(string[] args) {
	bool softlink;
	bool softlinkFallback;
	bool createParentDirectories;
	bool deleteExistingFile;
	bool force;
	string configPath;
	string[string] linkMap;
	//dfmt off
	auto opt=getopt(args, config.passThrough, config.caseSensitive,
		"softlink|S", "create softlink instead of hardlink", &softlink,
		"softlink-fallback|s", "create softlink if hardlink fails", &softlinkFallback,
		"create-parent-directories|c", "create parent directories as necessary", &createParentDirectories,
		"delete-existing-file|d", "delete files as necessary", &deleteExistingFile,
		"force|f", "do whatever it takes", &force,
		"config|C", "json file containing directory mappings", &configPath,
		"map|m", "single directory mapping, can be used multiple times", &linkMap,
		"glob-skip|g", "file glob to skip, can be used multiple times", &skip
	);
	//dfmt on
	if (opt.helpWanted) {
		defaultGetoptPrinter("usage: " ~ args[0].baseName ~ " [-C config.json] [-m origin=dest]", opt.options);
		return;
	}
	args.popFront();
	enforce(args.length == 0, "unrecognized args");
	if (!configPath.empty) {
		foreach (string key, val; configPath.readText.deserialize!(string[string]).absoluteMap(configPath.dirName)) {
			linkMap.require(key, val);
		}
	}
	enforce(!linkMap.empty,"nothing to do");
	int[] flags;
	if (softlink) {
		flags ~= SOFTLINK;
	}
	if (softlinkFallback) {
		flags ~= SOFTLINK_FALLBACK;
	}
	if (createParentDirectories) {
		flags ~= CREATE_PARENT_DIRECTORIES;
	}
	if (deleteExistingFile) {
		flags ~= DELETE_EXISTING_FILE;
	}
	if (force) {
		flags ~= FORCE;
	}
	uflink(linkMap, flags);
}
