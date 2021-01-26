module fpm.extra;

import std.path: globMatch, CaseSensitive, relativePath, absolutePath;
import std.file: getcwd;
import core.stdc.stdlib: exit;
import std.stdio: stderr;

/// list of file globs to skip
string[] skip;
/// returns true if any of the given globs match the path
bool globsMatch(string path, string[] patterns) {
    foreach (string pattern; patterns) {
        if (path.globMatch!(CaseSensitive.no)(pattern)) {
            return true;
        }
    }
    return false;
}
/// make an absolute link map relative
string[string] relativeMap(string[string] map, lazy string base=getcwd()) {
    string[string] relmap;
    foreach (string key, val; map) {
        map.remove(key);
        relmap[key.relativePath(base)] = val.relativePath(base);
    }
    return relmap;
}
/// make a link map absolute
string[string] absoluteMap(string[string] map, lazy string base=getcwd()) {
    string[string] absmap;
    foreach(string key,val;map){
        absmap[key.absolutePath(base)]=val.absolutePath(base);
    }
    return absmap;
}