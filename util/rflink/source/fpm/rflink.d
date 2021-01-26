module fpm.rflink;

public import fpm.flink;
public import fpm.extra;
import std.path;
import std.file;
import std.array;
import std.algorithm;

/// recursively create file links
void rflink(string sourcePath, string destPath, int[] flags){
    string[] queue = [sourcePath];
    while (!queue.empty) {
        foreach (string entry; queue[0].dirEntries(SpanMode.shallow)) {
            if (entry.baseName.globsMatch(skip)) {
                continue;
            }
            string entryDest = destPath.buildNormalizedPath(entry.relativePath(sourcePath));
            if (entry.isDir) {
                queue ~= entry;
                if(flags.canFind(CREATE_PARENT_DIRECTORIES)){
                    entryDest.mkdirRecurse();
                }
                continue;
            }
            flink(entry, entryDest, flags);
        }
        queue.popFront();
    }
}