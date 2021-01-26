module fpm.uflink;

public import fpm.rflink;

/// fake a union mount with rflink
void uflink(string[string] linkMap, int[] flags ...){
    foreach (source, dest; linkMap) {
        rflink(source, dest, flags);
    }
}
