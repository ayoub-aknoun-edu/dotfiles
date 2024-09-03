# oh my posh
oh-my-posh init pwsh --config 'C:\Users\ayoub\AppData\Local\Programs\oh-my-posh\themes\akanoun.omp.json' | Invoke-Expression
# Alias
Set-Alias 'rmdir -r' 'Remove-Item -Recurse -Force'
Set-Alias cls clear
Set-Alias grep rg
Set-Alias vim nvimcld
#Set-Alias touch New-Item
Set-Alias .. 'cd ..'
Set-Alias ... 'cd ../..'
Set-Alias .... 'cd ../../..'

# Terminal icons

Import-Module Terminal-Icons

#PSReadLine

Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource History



# Functions
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
  }
  

# Git shortcuts
function g { git $args }
function gst { git status }
function gco { git checkout $args }
function gcm { git commit -m $args }
function gaa { git add --all }

function sysinfo {
    Get-ComputerInfo | Select-Object CsManufacturer, CsSystemFamily,CsUserName, WindowsProductName, OsVersion, OsArchitecture, CsProcessors,CsNumberOfLogicalProcessors, CsPhysicallyInstalledMemory
}


function profile-e{
    code $PROFILE
}

function profile-r {
    . $PROFILE
}


function venv {
    param(
        [string]$envName = "venv"
    )   
    python -m venv $envName
    & "$envName\Scripts\Activate.ps1"
}


# bash-like command
function touch($file) { if (Test-Path $file) { (Get-Item $file).LastWriteTime = Get-Date } else { New-Item -Type File $file } }
function mkdir($dir) { New-Item -ItemType Directory -Path $dir }
function ll { Get-ChildItem -Force @args }
function ls { Get-ChildItem @args }


# Function to show disk usage
function du($path = ".") { Get-ChildItem $path -Recurse | Measure-Object -Property Length -Sum | Select-Object @{Name="Path";Expression={$path}}, @{Name="Size(MB)";Expression={"{0:N2}" -f ($_.Sum / 1MB)}} }

function mkcd {
    param(
        [string]$dir
    )
    New-Item -ItemType Directory -Path $dir
    Set-Location $dir
}

# Function to get public IP address
function myip{
    (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
}

