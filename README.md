#### File Package Manager
I got tired of having to figure out how to install mods and programs manually when most of the work could be automated. This is the automation.
### Utilities
There are multiple projects that live under the FPM umbrella, namely uflink and smerge, which contain the core functionality for FPM.
## FLink
File Link provides a cross-platform interface for creating file links. It delegates to the appropriate program depending on the OS it was built for. On windows, it will use fsutil for hardlinks and mklink for softlinks. On all other operating systems, it will use ln. FPM uses the --force mode of FLink, which will do whatever it takes to create a hardlink, or failing that, a softlink. 
## RFLink
Recursive File Link creates a directory link clone, by re-creating the directory tree of the source directory at the destination path, creating directories and linking files.
## UFlink
Union File Link fakes a union mount by using `rlink --force` for each layer, creating a file tree that looks like a union mount. This is mainly needed for Windows, which doesn't have a union mount availible, but also to prevent large memory overhead from many packages having individual union mounts.
## SMerge
Smart Merge is the main feature of FPM. It automatically determines the best way to install a package by analyzing file information like file extensions or headers and comparing that to files already present, or to a pre-built map of information. For many packages, smerge can correctly guess how to install them with no extra information.