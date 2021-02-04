
if($IsWindows){
    $env:PATH += ";/tools/ldc/bin"
}
dub test --parallel