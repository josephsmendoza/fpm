
$ErrorActionPreference = 'SilentlyContinue'
if(get-command dub){}else{
    $ErrorActionPreference = 'Stop'
    if($IsMacOS){
        brew install dub ldc
    } if ($IsLinux){
        sudo snap install --classic --channel=edge ldc2
        sudo snap install --classic --channel=edge dub
    } if ($IsWindows){
        choco install ldc
        mv /tools/ldc* /tools/ldc
    }
}