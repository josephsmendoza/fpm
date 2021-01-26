module fpm.fpm;

import asdf;
public import fpm.uflink;
public import fpm.smerge;
import std.range;
import std.path;
import std.file;
import std.process : execute;
import std.exception;
import std.algorithm;

/// destination subdirectory where fpm data is stored
const DATADIR = ".fpm";
/// file extension for all config files
const CONFIGEXT = ".json";
/// file name for smerge config
const SMERGECONF = "smerge" ~ CONFIGEXT;
/// file name for fpm config
const DATACONF = "fpm" ~ CONFIGEXT;
/// fpm data subdirectory where the original file nodes are stored
const BACKUPDIR = "backup";
/// extract an archive to a destination using 7zip
void extract(string archivePath, string destPath) {
    auto extract = execute(["7z", "x", archivePath, "-o" ~ destPath, "-y"]);
    enforce(extract.status == 0, extract.output);
}
/// initialize a destination for fpm
Config init(string baseDir, Config config = Config()) {
    skip ~= DATADIR;
    if (config.anchorMap.empty) {
        config.anchorMap = generateAnchorMap(baseDir, config);
    }
    string dataPath = baseDir.buildPath(DATADIR);
    dataPath.mkdirRecurse();
    string smergeConf = dataPath.buildPath(SMERGECONF);
    smergeConf.write(config.serializeToJsonPretty);
    string backupPath = dataPath.buildPath(BACKUPDIR);
    skip ~= DATADIR;
    rflink(baseDir, backupPath, FORCE);
    string[string] backupConfig = [backupPath: baseDir].relativeMap(dataPath);
    string backupConfigPath = dataPath.buildPath(BACKUPDIR ~ CONFIGEXT);
    backupConfigPath.write(backupConfig.serializeToJsonPretty());
    string[] enabledPackages = [backupConfigPath.baseName];
    foreach (nameDir; config.nameDirs) {
        string nameDirPath = baseDir.buildPath(nameDir);
        foreach (string entry; nameDirPath.dirEntries(SpanMode.shallow)) {
            string packageName = entry.baseName;
            string packagePath = dataPath.buildPath(packageName);
            rflink(entry, packagePath, FORCE);
            string[string] packageConfig = [packagePath: entry].relativeMap(dataPath);
            string packageConfigPath = dataPath.buildPath(packageName ~ CONFIGEXT);
            packageConfigPath.write(packageConfig.serializeToJsonPretty);
            string oldPackagePath = backupPath.buildPath(entry.relativePath(baseDir));
            oldPackagePath.rmdirRecurse();
            enabledPackages ~= packageConfigPath.baseName;
        }
    }
    string enabledPackagesPath = dataPath.buildPath(DATACONF);
    enabledPackagesPath.write(enabledPackages.serializeToJsonPretty);
    return config;
}
/// enable an installed package
void enable(string baseDir, string packageName) {
    string dataPath = baseDir.buildPath(DATADIR);
    string packageConfigPath = dataPath.buildPath(packageName ~ CONFIGEXT);
    string[string] linkMap = packageConfigPath.readText().deserialize!(string[string]).absoluteMap(dataPath);
    uflink(linkMap, FORCE);
    string enabledPackagesPath = dataPath.buildPath(DATACONF);
    string[] enabledPackages = enabledPackagesPath.readText().deserialize!(string[]) ~ packageConfigPath.baseName;
    enabledPackagesPath.write(enabledPackages.serializeToJson);
}
/// install and enable a package
string[string] install(string baseDir, string archivePath, string packageName = "") {
    if (packageName.empty) {
        packageName = archivePath.baseName.stripExtension;
    }
    string dataPath = baseDir.buildPath(DATADIR);
    string packagePath = dataPath.buildPath(packageName);
    packagePath.mkdirRecurse();
    extract(archivePath, packagePath);
    string smergeConfigPath = dataPath.buildPath(SMERGECONF);
    Config config = smergeConfigPath.readText().deserialize!(Config);
    string[string] linkMap = getPackageMap(packagePath, config, packageName, baseDir).relativeMap(dataPath);
    string packageConfigPath = dataPath.buildPath(packageName ~ CONFIGEXT);
    packageConfigPath.write(linkMap.serializeToJsonPretty);
    enable(baseDir, packageName);
    return linkMap;
}
/// std.file.rmdirRecurse implemented with skip[] support
void rmdirRecurse(string path) {
    if (path.baseName.globsMatch(skip)) {
        return;
    }
    if (path.isDir) {
        foreach (string entry; path.dirEntries(SpanMode.shallow)) {
            rmdirRecurse(entry);
        }
        if (path.dirEntries(SpanMode.shallow).array.length == 0) {
            path.rmdir;
        }
    } else {
        path.remove;
    }
}
/// disable an installed package
void disable(string baseDir, string packageName) {
    string dataPath = baseDir.buildPath(DATADIR);
    string enabledPackagesPath = dataPath.buildPath(DATACONF);
    string[] enabledPackages = enabledPackagesPath.readText.deserialize!(string[]);
    string packageConfigPath = dataPath.buildPath(packageName ~ CONFIGEXT);
    if (!enabledPackages.canFind(packageConfigPath.baseName)) {
        return;
    }
    string[string] packageConfig = packageConfigPath.readText().deserialize!(string[string]).absoluteMap(dataPath);
    skip = [DATADIR];
    foreach (source, dest; packageConfig) {
        dest.rmdirRecurse();
    }
    enabledPackages = enabledPackages.remove(enabledPackages.countUntil(packageConfigPath.baseName));
    int[] empty;
    enabledPackagesPath.write(empty.serializeToJson);
    foreach (string enabledPackageConfigPath; enabledPackages) {
        enable(baseDir, enabledPackageConfigPath.stripExtension);
    }
}
/// uninstall an installed package
void uninstall(string baseDir, string packageName) {
    disable(baseDir, packageName);
    string dataPath = baseDir.buildPath(DATADIR);
    string packagePath = dataPath.buildPath(packageName);
    if (packagePath.exists) {
        skip = [];
        packagePath.rmdirRecurse();
    }
    string packageConfigPath = packagePath ~ CONFIGEXT;
    if (packageConfigPath.exists) {
        packageConfigPath.remove();
    }
}
