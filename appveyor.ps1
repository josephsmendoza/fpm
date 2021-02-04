
    $ErrorActionPreference = 'Continue'
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
        echo "uploading util/$_/$libpre$_$libext"
        Push-AppveyorArtifact util/$_/$libpre$_$libext
        dub build :$_ -b release -c cli --parallel
        echo "uploading util/$_/$_$cliext"
        Push-AppveyorArtifact util/$_/$_$cliext
    }
    $_="fpm"
    dub build -b release -c lib --parallel
    echo "uploading $libpre$_$libext"
    Push-AppveyorArtifact $libpre$_$cliext
    dub build -b release -c cli --parallel
    echo "uploading $_$cliext"
    Push-AppveyorArtifact $_$cliext