
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
        $artifact="util/$_/$libpre$_$libext"
        echo "uploading $artifact"
        Push-AppveyorArtifact $artifact
        dub build :$_ -b release -c cli --parallel
        $artifact="util/$_/$_$cliext"
        echo "uploading $artifact"
        Push-AppveyorArtifact $artifact
    }
    $_="fpm"
    dub build -b release -c lib --parallel
    $artifact="$libpre$_$libext"
    echo "uploading $artifact"
    Push-AppveyorArtifact $artifact
    dub build -b release -c cli --parallel
    $artifact="$_$cliext"
    echo "uploading $artifact"
    Push-AppveyorArtifact $artifact