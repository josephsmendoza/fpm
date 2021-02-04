
$ErrorActionPreference = 'SilentlyContinue'
if(get-command dub){}else{
    $ErrorActionPreference = 'Stop'
    if($IsMacOS){
        brew install dub ldc
    } if ($IsLinux){
        wget -qO- https://gist.github.com/josephsmendoza/2c1f55120dbe565f6eea600f513cc9c1/raw/ | sudo bash
    } if ($IsWindows){
        choco install ldc
        mv /tools/ldc* /tools/ldc
    }
}