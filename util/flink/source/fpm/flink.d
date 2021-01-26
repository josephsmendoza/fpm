module fpm.flink;

import std.algorithm;
import std.path;
import std.file;
import std.exception;
import std.process;

enum {
    /// create softlink instead of hardlink
    SOFTLINK,
    /// create softlink if hardlink fails
    SOFTLINK_FALLBACK,
    /// create parent directories as necessary
    CREATE_PARENT_DIRECTORIES,
    /// delete existing files as necessary
    DELETE_EXISTING_FILE
}
/// do whatever it takes
static FORCE = [CREATE_PARENT_DIRECTORIES, DELETE_EXISTING_FILE, SOFTLINK_FALLBACK];
/// create a file link
void flink(string sourcePath, string destPath, int[] flags...) {
    if (flags.canFind(CREATE_PARENT_DIRECTORIES)) {
        destPath.dirName().mkdirRecurse();
    }
    if (flags.canFind(DELETE_EXISTING_FILE) && destPath.exists) {
        destPath.remove();
    }
    if (!flags.canFind(SOFTLINK)) {
        version (Windows) {
            auto proc = execute(["fsutil", "hardlink", "create", destPath, sourcePath]);
        } else {
            auto proc = execute(["ln", sourcePath, destPath]);
        }
        if (proc.status == 0 || !flags.canFind(SOFTLINK_FALLBACK)) {
            enforce(proc.status == 0, proc.output);
            return;
        }
    }
    version (Windows) {
        auto proc = execute(["mklink", destPath, sourcePath]);
    } else {
        auto proc = execute(["ln", "-s", sourcePath, destPath]);
    }
    enforce(proc.status == 0, proc.output);
}
