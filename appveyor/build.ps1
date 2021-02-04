$ErrorActionPreference = 'Continue'
if($IsWindows){
    $env:PATH += ";/tools/ldc/bin"
}
"flink", "rflink", "uflink", "smerge" | ForEach-Object {
    dub build :$_ -b release -c lib --parallel
    dub build :$_ -b release -c cli --parallel
}
dub build -b release -c lib --parallel
dub build -b release -c cli --parallel