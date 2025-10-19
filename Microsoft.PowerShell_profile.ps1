#Requires -Version 7.0
#region ── Oh My Posh  ─────────────────────────────────────────────────
$OMPConfig = 'C:\Users\ayoub\AppData\Local\Programs\oh-my-posh\themes\akanoun.omp.json'

# Ensure OMP is on PATH if installed in the default user location
$ompBin = 'C:\Users\ayoub\AppData\Local\Programs\oh-my-posh\bin'
if (Test-Path $ompBin -PathType Container -ErrorAction SilentlyContinue) {
    if (-not ($env:Path -split ';' | Where-Object { $_ -eq $ompBin })) {
        $env:Path = "$ompBin;$env:Path"
    }
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $OMPConfig) {
        oh-my-posh init pwsh --config $OMPConfig | Invoke-Expression
    } else {
        Write-Verbose "Oh My Posh config not found at $OMPConfig"
    }
} else {
    Write-Verbose "oh-my-posh not installed or not in PATH."
}
#endregion

#region ── Modules  ─────────────────────────────────────
foreach ($m in 'PSReadLine','Terminal-Icons') {
    if (Get-Module -ListAvailable -Name $m) {
        Import-Module $m -ErrorAction SilentlyContinue
    }
}
#endregion

#region ── PSReadLine tweaks ───────────────────────────────────────────────────
try {
    Set-PSReadLineOption -PredictionSource History
    # Inline ghost text is nice; keep ListView if you prefer your current style
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -BellStyle None

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord Ctrl+Space -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Key Ctrl+l -ScriptBlock { Clear-Host }
    Set-PSReadLineKeyHandler -Key Ctrl+d -ScriptBlock { [Environment]::Exit(0) }
} catch {}
#endregion

#region ── Aliases ─────────────────────────────────────────────
Set-Alias cls Clear-Host

# Prefer ripgrep & nvim when present
if (Get-Command rg -ErrorAction SilentlyContinue)   { Set-Alias grep rg }
if (Get-Command nvim -ErrorAction SilentlyContinue) { Set-Alias vim  nvim }
elseif (Get-Command code -ErrorAction SilentlyContinue) { Set-Alias vim code } # fallback
#endregion

#region ── Quality-of-life Functions ───────────────────────────────────────────
function which {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Command)
    $c = Get-Command -Name $Command -All -ErrorAction SilentlyContinue
    if ($c) {
        $c | Select-Object CommandType, Name,
            @{n='Location';e={ $_.Path ?? $_.Source ?? $_.Definition }}
    } else {
        Write-Error "Command '$Command' not found."
    }
}

# Safer rm -rf for one or more paths
function rmrf {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Path)
    foreach ($p in $Path) {
        if ($PSCmdlet.ShouldProcess($p,'Remove-Item -Recurse -Force')) {
            try { Remove-Item -Recurse -Force -LiteralPath $p -ErrorAction Stop }
            catch { Write-Warning "Failed to remove '$p': $($_.Exception.Message)" }
        }
    }
}

# mkdir that won’t error if exists + mkcd
function mkdir { param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}
function mkcd { param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -LiteralPath $Path
}

# touch
function touch { param([Parameter(Mandatory)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

#  ls/ll
function ls  { Get-ChildItem @args }
function ll  { Get-ChildItem -Force @args | Format-Table Mode,LastWriteTime,Length,Name -AutoSize }

# Disk usage (summary) & top-level sizes
function du {
    param([string]$Path='.')
    $sum = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue |
           Measure-Object -Property Length -Sum
    [PSCustomObject]@{
        Path    = (Resolve-Path $Path).Path
        SizeMB  = '{0:N2}' -f ($sum.Sum/1MB)
    }
}
function du1 {
    param([string]$Path='.', [int]$Top=20)
    Get-ChildItem -LiteralPath $Path -Directory -Force |
      ForEach-Object {
        $size = (Get-ChildItem -LiteralPath $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{ Name=$_.Name; Path=$_.FullName; SizeMB=[math]::Round($size/1MB,2) }
      } | Sort-Object SizeMB -Descending | Select-Object -First $Top
}

# Public IP + local IPs 
function myip {
    try {
        $ip = (Invoke-WebRequest -UseBasicParsing -Uri 'https://ifconfig.me/ip' -TimeoutSec 4).Content.Trim()
        if ($ip) { return $ip }
    } catch {}

    try {
        $lines = nslookup myip.opendns.com resolver1.opendns.com 2>$null
        $match = $lines | Select-String -Pattern 'Address:\s*([\d\.]+)$' | Select-Object -Last 1
        if ($match) { return $match.Matches[0].Groups[1].Value }
    } catch {}

    Write-Warning "Unable to determine public IP."
}
function ip {
    Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual,Dhcp |
        Select-Object InterfaceAlias,IPAddress
}

# Quick compression / extraction
function zipit { param([Parameter(Mandatory)][string]$Source,[Parameter(Mandatory)][string]$ZipPath)
    Compress-Archive -Path $Source -DestinationPath $ZipPath -Force
}
function unzip { param([Parameter(Mandatory)][string]$ZipPath,[string]$Dest='.')
    Expand-Archive -Path $ZipPath -DestinationPath $Dest -Force
}
function extract {
    [CmdletBinding()] param([Parameter(Mandatory)][string]$Path,[string]$Dest='.')
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }
    $ext = [IO.Path]::GetExtension($Path).ToLowerInvariant()
    switch -Regex ($Path) {
        '\.(zip)$'           { Expand-Archive -Path $Path -DestinationPath $Dest -Force }
        '\.(tar)$'           { tar -xf $Path -C $Dest }
        '\.(tar\.gz|tgz)$'   { tar -xzf $Path -C $Dest }
        '\.(tar\.bz2|tbz)$'  { tar -xjf $Path -C $Dest }
        '\.(7z|rar)$'        {
            if (Get-Command 7z -ErrorAction SilentlyContinue) { 7z x "-o$Dest" -y -- $Path }
            else { Write-Error "7z/rar file but '7z' not found." }
        }
        default { Write-Error "Unknown archive type: $Path" }
    }
}

# JSON pretty print
function jsonpp {
    param([Parameter(Mandatory)][string]$PathOrJson)
    if (Test-Path -LiteralPath $PathOrJson) {
        Get-Content -LiteralPath $PathOrJson -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100
    } else {
        $PathOrJson | ConvertFrom-Json | ConvertTo-Json -Depth 100
    }
}

# Processes & ports
function top   { Get-Process | Sort-Object WS -Descending | Select-Object -First 20 Name,Id,CPU,WS,PM }
function psg   { param([string]$Name) Get-Process | Where-Object {$_.Name -like "*$Name*"} }
function killp { param([Parameter(Mandatory)][int]$Id) Stop-Process -Id $Id -Force }
function ports {
    Get-NetTCPConnection -State Listen |
      Sort-Object LocalPort |
      ForEach-Object {
        $p = $null
        try { $p = (Get-Process -Id $_.OwningProcess -ErrorAction Stop).Name } catch {}
        [pscustomobject]@{
            LocalAddress = $_.LocalAddress
            LocalPort    = $_.LocalPort
            ProcessId    = $_.OwningProcess
            ProcessName  = $p
        }
      }
}

# PATH pretty view
function path { $env:Path -split ';' | Where-Object { $_ -and (Test-Path $_) } }

# Reload env (like Chocolatey 'refreshenv' but minimal)
function refreshenv {
    $newPath = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
               [System.Environment]::GetEnvironmentVariable('Path','User')
    $env:Path = $newPath
    Write-Host "Environment variables reloaded."
}
# Elevation helper (admin)
function sudo {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Cmd)
    $pwsh = (Get-Command pwsh).Source
    if ($Cmd -and $Cmd.Count) {
        # Safe quoting: run the exact command line in an elevated pwsh
        $escaped = $Cmd | ForEach-Object { '"' + ($_ -replace '"','`"') + '"' }
        Start-Process -FilePath $pwsh -Verb RunAs -ArgumentList @('-NoLogo','-NoProfile','-Command', ($escaped -join ' '))
    } else {
        Start-Process -FilePath $pwsh -Verb RunAs
    }
}

# Quick HTTP server (if Python available)
function serve {
    param([int]$Port = 8000, [string]$Dir='.')
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Push-Location $Dir
        try { python -m http.server $Port } finally { Pop-Location }
    } else {
        Write-Error "Python not found for quick server."
    }
}

# Clipboard helpers
function pbcopy { param([Parameter(ValueFromPipeline)][string]$Text) process { Set-Clipboard -Value $Text } }
function pbpaste { Get-Clipboard }

# Edit & reload profile quickly
function profile:edit {
    if (Get-Command code -ErrorAction SilentlyContinue) { code $PROFILE } else { notepad $PROFILE }
}
# --- Put this in your PowerShell 7 profile (e.g. $PROFILE) ---

function Reload-Profile {
    # Reload all relevant profile scripts into the *current* scope
    $profiles = @(
        $PROFILE.AllUsersAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($p in $profiles) { . $p }

    # (Optional) re-import PSReadLine so key handlers/options apply immediately
    if (Get-Module PSReadLine) { Remove-Module PSReadLine -Force }
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # Re-initialize Oh My Posh with *your* config
    # Adjust the path if yours differs
    $omp = "C:\Users\ayoub\AppData\Local\Programs\oh-my-posh\themes\akanoun.omp.json"
    if (Test-Path $omp) {
        # Ensure the prompt function picks up the (possibly changed) theme
        Remove-Item Function:\prompt -ErrorAction SilentlyContinue
        oh-my-posh init pwsh --config $omp | Invoke-Expression
    }

    Write-Host "✔ Profile reloaded into current session."
}

# Nice alias if you like your old name
Set-Alias 'profile:reload' Reload-Profile

#endregion

#region ── Python virtualenv helpers ───────────────────────────────────────────
function mkvenv {
    [CmdletBinding()]
    param(
        [string]$Name = '.venv',
        [ValidateSet('auto','python','py')][string]$Python = 'auto'
    )
    $pyCmd = $null; $pyArgs = @()
    switch ($Python) {
        'python' { $pyCmd='python'; $pyArgs=@('-m','venv',$Name) }
        'py'     { $pyCmd='py';      $pyArgs=@('-3','-m','venv',$Name) }
        default  { if (Get-Command py -ea SilentlyContinue){$pyCmd='py';$pyArgs=@('-3','-m','venv',$Name)} else {$pyCmd='python';$pyArgs=@('-m','venv',$Name)} }
    }
    Write-Host "Creating venv '$Name' with $pyCmd $($pyArgs -join ' ') ..."
    & $pyCmd @pyArgs
    $act = Join-Path $Name 'Scripts\Activate.ps1'
    if (Test-Path $act) { & $act } else { Write-Warning "Venv created but activation script not found at '$act'" }
}
function workit { param([string]$Name='.venv')
    $act = Join-Path $Name 'Scripts\Activate.ps1'
    if (Test-Path $act) { & $act } else { Write-Error "No venv at '$Name'." }
}
function pipup {
    python -m pip install --upgrade pip
    pip list --outdated --format=json | ConvertFrom-Json | ForEach-Object {
        pip install "$($_.name)==$($_.latest_version)"
    }
}
#endregion

#region ── Git shortcuts (robust args) ─────────────────────────────────────────
function g    { git $args }
function gst  { git status }
function gaa  { git add --all }
function gco  { param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Rest) git checkout @Rest }
function gcm  { param([Parameter(Mandatory,ValueFromRemainingArguments=$true)][string[]]$Message) git commit -m ($Message -join ' ') }
function gpsu { git push -u origin HEAD }
function gpull{ git pull --rebase --autostash }
function gundo{ git reset --soft HEAD~1 }
function gg   { git log --graph --decorate --oneline --all --date=relative --pretty="%C(auto)%h %C(blue)%ad%C(reset) %s %C(dim white)- %an" }
function gbr  { git branch --all }
function grd  { git restore --staged --worktree -- $args }
function groot{ git rev-parse --show-toplevel 2>$null }
function cdup { $r = groot; if ($r) { Set-Location $r } else { Write-Error "Not in a git repo." } }
#endregion

#region ── System info ─────────────────────────────────────────────────────────
function sysinfo {
    Get-ComputerInfo | Select-Object `
        CsManufacturer, CsSystemFamily, CsUserName, WindowsProductName,
        OsVersion, OsArchitecture, CsProcessors, CsNumberOfLogicalProcessors,
        CsPhysicallyInstalledMemory
}
#endregion

#region ── Open folders ─────────────────────────────────────────────────────
function open {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Start-Process -FilePath $Path
    } else {
        Write-Error "Path not found: $Path"
    }
}
#endregion

#region ── Quick jumps ─────────────────────────────────────────────────────────
function zaki {
    $p = 'E:\zaki_project'
    if (Test-Path -LiteralPath $p) { Set-Location -LiteralPath $p }
    else { Write-Error "Path not found: $p" }
}
#endregion
