import std.stdio;
import fpm.fpm;
import std.getopt;
import std.range;
import std.file;
import std.path;
import std.algorithm;
import asdf;

private string command;
/// welcome to the land of garbage code
void main(string[] args) {
    // dfmt off
	auto opt=getopt(args, config.caseSensitive, config.passThrough,
        "init|I","initialize a directory for fpm, optionally takes config file path", &cli,
        "install|i","install an archive, also takes package name as second arg", &cli,
        "uninstall|u","uninstall a package", &cli,
        "enable|e","enable a package", &cli,
        "disable|d", "disable a package", &cli
    );
    // dfmt on
    if(opt.helpWanted){
        defaultGetoptPrinter("usage: fpm (command) (basseDir) [args...]", opt.options);
    }
    args.popFront;
    switch(command){
        case "init|I":{
            Config conf;
            if(args.length==2){
                conf=args[1].readText.deserialize!(Config);
            }
            init(args[0], conf).serializeToJsonPretty.writeln();
            break;
        }
        case "install|i":{
            if(args.length==3){
            install(args[0], args[1], args[2]).writeln();
            }else{
                install(args[0], args[1]).prettyMap(args[0]).serializeToJsonPretty.writeln();
            }
            break;
        }
        case "uninstall|u":{
            uninstall(args[0], args[1]);
            writeln(args[1]~" uninstalled from "~args[0]);
            break;
        }
        case "enable|e":{
            enable(args[0], args[1]);
            writeln(args[1]~" enabled in "~args[0]);
            break;
        }
        case "disable|d":{
            disable(args[0], args[1]);
            writeln(args[1]~" disabled in "~args[0]);
            break;
        }
        default:{
            writeln("no command");
        }
    }
}

private string[string] prettyMap(string[string] map, string baseDir){
    string[string] ptymap;
    foreach (key, val; map) {
        string[] valPath=val.pathSplitter.array;
        valPath[0]=baseDir.baseName;
        ptymap[key]=buildPath(valPath);
    }
    return ptymap;
}

private void cli(string command){
    .command=command;
}


unittest{
    writeln("this is a fake unit test");
}