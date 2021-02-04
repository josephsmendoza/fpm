
    if($IsWindows){
        $env:PATH += ";/tools/ldc/bin"
        $cliext=".exe"
        $libext=".lib"
    }else{
        $libext=".a"
        $libpre="lib"
    }
    "flink", "rflink", "uflink", "smerge" | ForEach-Object {
        dub build :$_ -b release -c lib --parallel
        Push-AppveyorArtifact util/$_/$libpre$_$libext
        dub build :$_ -b release -c cli --parallel
        Push-AppveyorArtifact util/$_/$_$cliext
    }
    $_="fpm"
    dub build -b release -c lib --parallel
    Push-AppveyorArtifact $libpre$_$cliext
    dub build -b release -c cli --parallel
    Push-AppveyorArtifact $_$cliext