#Requires -Version 7.0
#region ── Oh My Posh configuration  ─────────────────────────────────────────────────
$OMPConfig = 'C:\Users\ayoub\AppData\Local\Programs\oh-my-posh\themes\akanoun.omp.json'
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
$modules = @('PSReadLine', 'Terminal-Icons', 'posh-git')
foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}
#endregion

#region ── PSReadLine tweaks ───────────────────────────────────────────────────
try {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -MaximumHistoryCount 10000

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord Ctrl+Space -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+l -ScriptBlock { Clear-Host }
    Set-PSReadLineKeyHandler -Key Ctrl+d -ScriptBlock { [Environment]::Exit(0) }
} catch {}

    Set-PSReadLineOption -Colors @{
        Command   = 'Cyan'
        Parameter = 'DarkCyan'
        String    = 'Green'
        Number    = 'Magenta'
        Operator  = 'DarkGray'
        Variable  = 'Yellow'
        Comment   = 'DarkGreen'
    }

#endregion


#region ── Aliases ─────────────────────────────────────────────
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name ..  Set-LocationParent
Set-Alias -Name ... Set-LocationGrandParent
Set-Alias -Name e -Value explorer

# Prefer ripgrep & nvim when present
if (Get-Command rg -ErrorAction SilentlyContinue) { Set-Alias grep rg }
if (Get-Command nvim -ErrorAction SilentlyContinue) { 
    Set-Alias vim nvim
    Set-Alias vi nvim
} elseif (Get-Command code -ErrorAction SilentlyContinue) { 
    Set-Alias vim code 
}
if (Get-Command bat -ErrorAction SilentlyContinue) { Set-Alias cat bat }
if (Get-Command eza -ErrorAction SilentlyContinue) { 
    Set-Alias ls eza
    function ll {eza -la --icons}
}
# fallback
#endregion

#region ── Navigation Functions ────────────────────────────────────────────────
function Set-LocationParent { Set-Location .. }
function Set-LocationGrandParent { Set-Location ../.. }
function ~ { Set-Location ~ }
function dt { Set-Location ~/Desktop }
function docs { Set-Location ~/Documents }
function dl { Set-Location ~/Downloads }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -LiteralPath $Path
}

function zaki {
    $path = 'E:\zaki_project'
    if (Test-Path $path) { 
        Set-Location $path 
        Write-Host "📁 Navigated to Zaki Project" -ForegroundColor Cyan
    } else { 
        Write-Error "Path not found: $path" 
    }
}


#endregion


#region ── File Operations ─────────────────────────────────────────────────────
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

function rmrf {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
        [string]$Path
    )

    process {
        # 1. Expand the path to handle wildcards like '*'
        #    -Force is needed here to include hidden files/directories.
        try {
            $ItemsToRemove = Get-Item -Path $Path -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Could not find item(s) matching path '$Path': $_"
            return # Skip to the next item in the pipeline
        }

        # 2. Iterate through the expanded items
        foreach ($Item in $ItemsToRemove) {
            if ($PSCmdlet.ShouldProcess($Item.FullName, 'Remove-Item -Recurse -Force')) {
                try {
                    # Use the fully expanded path ($Item.FullName)
                    Remove-Item -Recurse -Force -LiteralPath $Item.FullName -ErrorAction Stop 
                    Write-Host "🗑️  Removed: $($Item.FullName)" -ForegroundColor Green
                }
                catch { 
                    Write-Warning "Failed to remove '$($Item.FullName)': $_" 
                }
            }
        }
    }
}

function mkdir { 
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Paths # Still an array, but populated by space-separated args
    )
    foreach($path in $Paths){
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}


# touch
function touch {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Files # Still an array, but populated by space-separated args
    )
 
    foreach ($file in $Files) {
        if (Test-Path $file) {
            # Update the timestamp if the file exists
            Set-ItemProperty -Path $file -Name LastWriteTime -Value (Get-Date)
        } else {
            # Create a new file if it doesn't exist
            New-Item -Path $file -ItemType File | Out-Null
        }
    }
}
function tre { tree /F @args }

#endregion

#region ── System Information ──────────────────────────────────────────────────
function sysinfo {
    # 1. Fetch Static Hardware Info (WMI/CIM)
    $CimCS = Get-CimInstance -ClassName Win32_ComputerSystem
    $CimOS = Get-CimInstance -ClassName Win32_OperatingSystem
    $CimCPU = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    # Get GPU (Filter out generic Microsoft drivers)
    $CimGPU = Get-CimInstance -ClassName Win32_VideoController | 
              Where-Object { $_.AdapterCompatibility -ne 'Microsoft Corporation' } | 
              Select-Object -First 1
    try {
        $CpuPerf = Get-Counter "\Processor Information(_Total)\% Processor Performance" -ErrorAction Stop
        $PerfPercentage = $CpuPerf.CounterSamples.CookedValue
        $BaseClockMHz = $CimCPU.MaxClockSpeed
        
        # Calculate Real-Time Frequency
        $CurrentClockMHz = $BaseClockMHz * ($PerfPercentage / 100)
        
        # Formatting
        $BaseClockDisplay    = "$([math]::Round($BaseClockMHz / 1000, 1)) GHz"
        $CurrentClockDisplay = "$([math]::Round($CurrentClockMHz / 1000, 1)) GHz"
    }
    catch {
        $BaseClockDisplay    = "$([math]::Round($CimCPU.MaxClockSpeed / 1000, 1)) GHz"
        $CurrentClockDisplay = "Calculation Error"
    }

    # 3. Output the Custom Object
    [PSCustomObject]@{
        '💻 Computer'       = $CimCS.Name
        '🏢 Manufacturer'   = $CimCS.Manufacturer
        '👤 User'           = $env:USERNAME
        '🪟 OS'             = $CimOS.Caption
        '📦 Version'        = $CimOS.Version
        '🏗️  Architecture'  = $CimOS.OSArchitecture
        
        # CPU Details
        '🧠 CPU Model'      = $CimCPU.Name
        '🐢 Base Clock'     = $BaseClockDisplay      # The Stock Speed (2.8)
        '🚀 Current Clock'  = $CurrentClockDisplay   # Real-time Speed (fluctuates!)
        '🔢 Cores/Threads'  = "$($CimCPU.NumberOfCores)/$($CimCPU.NumberOfLogicalProcessors)"
        
        # GPU & RAM
        '🎨 GPU Model'      = $CimGPU.Name
        '🖼️  VRAM (GB)'      = if ($CimGPU.AdapterRam) { [math]::Round($CimGPU.AdapterRam / 1GB, 2) } else { "Shared" }
        '💾 RAM (GB)'       = [math]::Round($CimCS.TotalPhysicalMemory / 1GB, 2)
    }
}
function diskspace {
    Get-PSDrive -PSProvider FileSystem | 
        Where-Object { $_.Used -gt 0 } |
        Select-Object Name,
            @{Name='Used(GB)'; Expression={[math]::Round($_.Used/1GB, 2)}},
            @{Name='Free(GB)'; Expression={[math]::Round($_.Free/1GB, 2)}},
            @{Name='Total(GB)'; Expression={[math]::Round(($_.Used+$_.Free)/1GB, 2)}},
            @{Name='Free(%)'; Expression={[math]::Round(($_.Free/($_.Used+$_.Free))*100, 1)}}
}

function uptime {
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "⏱️  System Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Cyan
}
#endregion


#region ── Network Functions ───────────────────────────────────────────────────
function myip {
    try {
        $ip = (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json' -TimeoutSec 5).ip
        Write-Host "🌐 Public IP: $ip" -ForegroundColor Green
        
    } catch {
        Write-Warning "Unable to fetch public IP"
    }
}

function ip {
    Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Manual, Dhcp |
        Where-Object { $_.InterfaceAlias -notlike '*Loopback*' } |
        Select-Object InterfaceAlias, IPAddress | 
        Format-Table -AutoSize
}

function ports {
    Get-NetTCPConnection -State Listen |
        Sort-Object LocalPort |
        Select-Object @{Name='Port'; Expression={$_.LocalPort}},
                      @{Name='Address'; Expression={$_.LocalAddress}},
                      @{Name='Process'; Expression={
                          try { (Get-Process -Id $_.OwningProcess -ErrorAction Stop).Name }
                          catch { 'Unknown' }
                      }},
                      @{Name='PID'; Expression={$_.OwningProcess}} |
        Format-Table -AutoSize
}

function pingtest {
    param([string]$Url = '8.8.8.8')
    Test-Connection -ComputerName $Url -Count 4
}
#endregion

#region ── Process Management ──────────────────────────────────────────────────

function top {
    Get-Process | 
        Sort-Object WS -Descending | 
        Select-Object -First 20 Name, Id, 
            @{Name='CPU(s)'; Expression={$_.CPU}},
            @{Name='Memory(MB)'; Expression={[math]::Round($_.WS/1MB, 2)}} |
        Format-Table -AutoSize
}
function psg {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$NameOrID
    )
    try {
        if ($NameOrID -as [int]) {
            $Processes = Get-Process -Id $NameOrID -ErrorAction Stop
        } else {
            $Processes = Get-Process | Where-Object { $_.Name -like "*$NameOrID*" }
        }
    } catch {
        Write-Warning "Could not find a process matching '$NameOrID'."
        return
    }
    $Processes | Format-Table -AutoSize -Property @(
        'Name',
        'Id',
        'CPU',
        @{Name='Memory(MB)'; Expression={[math]::Round($_.WS/1MB, 2)}} # Working Set in MB
    )
}

function killp {
    param([Parameter(Mandatory)][int]$Id)
    Stop-Process -Id $Id -Force
    Write-Host "❌ Killed process: $Id" -ForegroundColor Red
}

function killname {
    param([Parameter(Mandatory)][string]$Name)
    Get-Process | Where-Object { $_.Name -like "*$Name*" } | 
        ForEach-Object { 
            Stop-Process -Id $_.Id -Force
            Write-Host "❌ Killed: $($_.Name) (PID: $($_.Id))" -ForegroundColor Red
        }
}

#endregion

#region ── Git Shortcuts ───────────────────────────────────────────────────────
function g { git $args }
function gs { git status }
function gst { git status }
function ga { git add @args }
function gaa { git add --all }
function gcmsg { param([Parameter(Mandatory)][string]$Message) git commit -m $Message }
function gpo  { git push $args }
function gpsu { git push -u origin HEAD }
function gpl { git pull --rebase --autostash }
function gpull { git pull --rebase --autostash }
function gco { git checkout @args }
function gcb { param([Parameter(Mandatory)][string]$Branch) git checkout -b $Branch }
function gbr { git branch --all }
function gbd { param([Parameter(Mandatory)][string]$Branch) git branch -d $Branch }
function glog { git log --oneline --graph --decorate --all -20 }
function gg { git log --graph --decorate --oneline --all --date=relative --pretty="%C(auto)%h %C(blue)%ad%C(reset) %s %C(dim white)- %an" }
function gundo { git reset --soft HEAD~1 }
function gstash { git stash push -m @args }
function gsp { git stash pop }
function gd { git diff @args }
function gds { git diff --staged }
function groot { 
    $root = git rev-parse --show-toplevel 2>$null
    if ($root) { return $root } else { Write-Error "Not in a git repository" }
}
function cdup { 
    $root = groot
    if ($root) { Set-Location $root }
}
#endregion


#region ── Docker Shortcuts ────────────────────────────────────────────────────
function d { docker $args }
function dc { docker-compose $args }
function dcu { docker-compose up -d }
function dcd { docker-compose down }
function dps { docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}" }
function dpsa { docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}" }
function di { docker images }
function dlog { param([Parameter(Mandatory)][string]$Container) docker logs -f $Container }
function dex { 
    param([Parameter(Mandatory)][string]$Container)
    docker exec -it $Container sh -c '[ -x /bin/bash ] && /bin/bash || /bin/sh'
}
function dclean {
    Write-Host "🧹 Cleaning Docker system..." -ForegroundColor Yellow
    docker system prune -af --volumes
    Write-Host "✅ Docker cleanup complete" -ForegroundColor Green
}
function dstop { docker stop $(docker ps -q) }
#endregion


#region ── Python virtualenv helpers ───────────────────────────────────────────
function mkvenv {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Name = 'venv',

        [ValidateSet('auto', 'python', 'py')][string]$Python = 'auto'
    )
    
    # 1. Determine the Python executable path and arguments
    # Initialize the command array to hold the executable and its arguments
    $CmdArgs = @()

    if ($Python -eq 'py' -or ($Python -eq 'auto' -and (Get-Command py -ErrorAction SilentlyContinue))) {
        # Use 'py -3' for the Windows Python launcher
        $CmdArgs += 'py';
        $CmdArgs += '-3', '-m', 'venv', $Name
    } else {
        # Use 'python' fallback
        $CmdArgs += 'python';
        $CmdArgs += '-m', 'venv', $Name
    }

    # 2. Execute the Python venv creation command
    Write-Host "🐍 Creating virtual environment '$Name' using $($CmdArgs[0])..." -ForegroundColor Cyan
    
    # Use the standard call operator (&) with the array of arguments
    # Arguments start from the second element ($CmdArgs[1])
    & $CmdArgs[0] $CmdArgs[1..$CmdArgs.Count]
    
    # Check if the command failed by looking at the last exit code
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create virtual environment '$Name'. Python might not be installed or venv module is missing."
        return
    }

    # 3. Activate the environment
    $activate = Join-Path $Name 'Scripts\Activate.ps1'
    if (Test-Path $activate) { 
        # The dot-sourcing operator (.) is REQUIRED to run the activation script
        # as it modifies the current session's environment variables.
        . $activate
        Write-Host "✅ Virtual environment activated ($Name)" -ForegroundColor Green
    } else {
        Write-Warning "Activation script not found at '$activate'. Environment created, but not activated."
    }
}

function workon {
    param([string]$Name = 'venv')
    $activate = Join-Path $Name 'Scripts\Activate.ps1'
    if (Test-Path $activate) { 
        & $activate
        Write-Host "🐍 Activated: $Name" -ForegroundColor Green
    } else { 
        Write-Error "Virtual environment not found: $Name" 
    }
}
function pipup {
    Write-Host "📦 Updating pip packages..." -ForegroundColor Cyan
    python -m pip install --upgrade pip
    pip list --outdated --format=json | ConvertFrom-Json | ForEach-Object {
        Write-Host "⬆️  Upgrading $($_.name)..." -ForegroundColor Yellow
        pip install --upgrade $_.name
    }
    Write-Host "✅ All packages updated" -ForegroundColor Green
}
#endregion



#region ── Compression/Archive Functions ───────────────────────────────────────
function zipit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Source,
        
        # This parameter is OPTIONAL and must be explicitly named if used, 
        # to prevent it from being absorbed by $Source.
        [string]$DestinationFileName
    )

    # 1. Determine the Destination File Path
    if ($DestinationFileName) {
        # If a name is provided, ensure it's in the current location and ends in .zip
        $ArchivePath = Join-Path (Get-Location) "$DestinationFileName"
        if (-not ($ArchivePath -like '*.zip')) {
            $ArchivePath = "$ArchivePath.zip"
        }
    } else {
        # Intelligent naming logic (since no destination was provided)
        # Use the name of the directory or the name of the first source item
        if ($Source.Count -gt 1) {
            $BaseName = (Get-Location).Path.Split('\')[-1]
            if ($BaseName -in @('Users', 'Desktop', 'Documents')) {
                 $BaseName = (Get-Item $Source[0]).Name + "-plus-more"
            }
        } else {
            # Use the name of the single source item
            $BaseName = (Get-Item $Source[0]).Name
        }
        
        $ArchivePath = Join-Path (Get-Location) "$BaseName.zip"
    }

    # 2. Execute the compression
    Write-Host "📦 Compressing $($Source.Count) item(s) to '$ArchivePath'..." -ForegroundColor Cyan
    try {
        # Compress-Archive handles the array of sources correctly
        Compress-Archive -Path $Source -DestinationPath $ArchivePath -Force -ErrorAction Stop
        Write-Host "✅ Compressed successfully to: $ArchivePath" -ForegroundColor Green
    }
    catch {
        Write-Error "Compression failed: $($_.Exception.Message)"
    }
}

function uz {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ZipPath,
        
        [Parameter(Position=1)]
        [string]$DestinationPath = '.'
    )

    if (-not (Test-Path $ZipPath)) { 
        Write-Error "Zip file not found: $ZipPath"
        return
    }

    Write-Host "📂 Extracting '$ZipPath' to '$DestinationPath'..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force -ErrorAction Stop
        Write-Host "✅ Extracted successfully to: $DestinationPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Extraction failed: $($_.Exception.Message)"
    }
}
function extract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        
        [Parameter(Position=1)]
        [string]$Dest = '.'
    )

    # Standard check for file existence
    if (-not (Test-Path $Path)) { 
        Write-Error "Archive file not found: $Path"
        return
    }
    
    # 1. Use Resolve-Path to get the full path for reliable processing
    $FullPath = (Resolve-Path $Path).Path
    Write-Host "⚙️  Attempting to extract: $FullPath" -ForegroundColor Yellow

    # 2. Use a robust switch statement with built-in tools first
    switch -Regex ($FullPath) {
        '\.(zip)$'{ 
            Write-Host "  Using Expand-Archive..."
            Expand-Archive -Path $FullPath -DestinationPath $Dest -Force 
        }

        # Tar is built-in to modern Windows (tar.exe)
        '\.(tar|tar\.gz|tgz|tar\.bz2|tbz)$'  { 
            Write-Host "  Using built-in 'tar' executable..."
            # Check for the compression flag and use appropriate combination
            if ($FullPath -match '\.gz$|\.tgz$') {
                tar -xzf $FullPath -C $Dest
            } elseif ($FullPath -match '\.bz2$|\.tbz$') {
                tar -xjf $FullPath -C $Dest
            } else { # Just .tar
                tar -xf $FullPath -C $Dest
            }
        }
        
        # 7z/RAR requires the external 7z executable
        '\.(7z|rar)$'{
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                Write-Host "  Using '7z' executable..."
                # Note: -y auto-confirms, -o sets output directory
                7z x "-o$Dest" -y -- $FullPath 
            } else { 
                Write-Error "7z or RAR file detected. Please install '7z' and add it to your PATH." 
            }
        }
        
        default { 
            Write-Error "Unknown or unsupported archive type: $Path. Supported: zip, tar, tar.gz, tgz, tar.bz2, tbz, 7z, rar." 
        }
    }
    
    Write-Host "✅ Extraction complete to: $Dest" -ForegroundColor Green
}

#endregion

#region ── Utility Functions ───────────────────────────────────────────────────
function jsonpp {
    param([Parameter(Mandatory, ValueFromPipeline)][string]$Inp)
    if (Test-Path $Inp) {
        Get-Content $Inp -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100
    } else {
        $Inp | ConvertFrom-Json | ConvertTo-Json -Depth 100
    }
}

function path { 
    $env:Path -split ';' | Where-Object { $_ } | ForEach-Object { 
        [PSCustomObject]@{
            Path = $_
            Exists = Test-Path $_
        }
    } | Format-Table -AutoSize
}

function refreshenv {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
    Write-Host "✅ Environment variables refreshed" -ForegroundColor Green
}

function sudo {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Command)
    $pwsh = (Get-Command pwsh).Path
    if ($Command) {
        $escaped = ($Command | ForEach-Object { "`"$($_ -replace '"','`"')`"" }) -join ' '
        Start-Process $pwsh -Verb RunAs -ArgumentList "-NoLogo -NoProfile -Command $escaped"
    } else {
        Start-Process $pwsh -Verb RunAs
    }
}

function serve {
    param([int]$Port = 8000, [string]$Path = '.')
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Push-Location $Path
        Write-Host "🌐 Starting server on http://localhost:$Port" -ForegroundColor Cyan
        try { python -m http.server $Port }
        finally { Pop-Location }
    } else {
        Write-Error "Python not found"
    }
}


function timer {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Duration = '5m'
    )
    $TotalSeconds = 0

    if ($Duration -match '^(\d+)([smh])$') {
        $Value = [int]$Matches[1]
        $Unit = $Matches[2].ToLower()

        switch ($Unit) {
            's' { $TotalSeconds = $Value }
            'm' { $TotalSeconds = $Value * 60 }
            'h' { $TotalSeconds = $Value * 3600 }
        }
    } else {
        try {
            $TotalSeconds = [int]$Duration * 60
        } catch {
            Write-Error "Invalid duration format. Use a number followed by s (seconds), m (minutes), or h (hours), e.g., '30s' or '1h'."
            return
        }
    }

    $StartTime = Get-Date
    $EndTime = $StartTime.AddSeconds($TotalSeconds)
    if ($TotalSeconds -le 0) {
        Write-Warning "Duration must be greater than zero."
        return
    }

    Write-Host "⏱️ Timer set for $TotalSeconds seconds, ending at $($EndTime.ToShortTimeString())..." -ForegroundColor Cyan
    while ((Get-Date) -lt $EndTime) {
        $RemainingTime = $EndTime - (Get-Date)
        $DisplayTime = "{0:d2}:{1:d2}:{2:d2}" -f $RemainingTime.Hours, $RemainingTime.Minutes, $RemainingTime.Seconds
        Write-Host "🕒 Remaining: $DisplayTime" -NoNewLine
        Start-Sleep -Seconds 1
        Write-Host "`r" -NoNewLine
    }
    Write-Host "`r" -NoNewLine
    Write-Host "⏰ Time's up! Starting alert..." -ForegroundColor Green
    [Console]::Beep(1000, 500)
}
function pomo {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$WorkDuration = '25m',
        
        [Parameter(Position=1)]
        [string]$BreakDuration = '5m'
    )
    Write-Host "🍅 Starting Pomodoro Work Session: $WorkDuration" -ForegroundColor Magenta
    timer $WorkDuration
    Write-Host "---"
    Write-Host "🔔 Work complete! Starting Break Session: $BreakDuration" -ForegroundColor Cyan
    [Console]::Beep(800, 300); Start-Sleep -Milliseconds 200
    [Console]::Beep(1000, 300); Start-Sleep -Milliseconds 200
    [Console]::Beep(1200, 500)
    timer $BreakDuration
    Write-Host "---"
    Write-Host "✅ Break finished. Ready for the next work session!" -ForegroundColor Green
}   

function note {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$Text
    )
    
    $NoteFile = "$HOME\notes.txt"
    $NoteContent = $Text -join ' '
    if (-not $NoteContent -or $NoteContent.Trim() -eq "") {
        Write-Warning "Cannot save an empty note."
        return
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "`n--- $timestamp ---`n$NoteContent`n"
    $Line | Add-Content -Path $NoteFile
    Write-Host "📝 Note saved successfully to $NoteFile" -ForegroundColor Green
}

function notes {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [int]$Count = 10
    )

    $NoteFile = "$HOME\notes.txt"
    
    if (Test-Path $NoteFile) {
        Write-Host "📖 Displaying the last $Count entries from $NoteFile" -ForegroundColor Cyan
        Write-Host "---"
        Get-Content $NoteFile | Select-Object -Last $Count
        
    } else {
        Write-Host "📝 No notes file found at $NoteFile. Use 'note <text>' to create one." -ForegroundColor Yellow
    }
}

function weather {
    param([string]$City = '')
    $location = if ($City) { $City } else { '' }
    (Invoke-WebRequest -Uri "wttr.in/$location" -UseBasicParsing).Content
}

function qr {
    param([Parameter(Mandatory)][string]$Text)
    $encoded = [System.Web.HttpUtility]::UrlEncode($Text)
    Start-Process "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$encoded"
}
#endregion

#region ── Profile Management ──────────────────────────────────────────────────
function Edit-Profile {
    if (Get-Command code -ErrorAction SilentlyContinue) { 
        code $PROFILE 
    } else { 
        notepad $PROFILE 
    }
}
Set-Alias profile:edit Edit-Profile
function Update-Profile {
    $originalErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $profiles = @(
        $PROFILE.AllUsersAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost
    ) | Where-Object { $_ -and (Test-Path $_) }
    foreach ($p in $profiles) { 
        try {
            $null = . $p 2>&1
        } catch {
            Write-Warning "Could not reload profile: $p"
        }
    }
    if (Get-Module PSReadLine) { 
        Remove-Module PSReadLine -Force
        Import-Module PSReadLine
    }
    $ompConfig = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\akanoun.omp.json"
    if (Test-Path $ompConfig) {
        oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
    }
    
    $ErrorActionPreference = $originalErrorAction
    
    Write-Host "✅ Profile reloaded successfully." -ForegroundColor Green
}

Set-Alias profile:reload Update-Profile -Force
#endregion

#region ── Clipboard Functions ─────────────────────────────────────────────────
function pbcopy { param([Parameter(ValueFromPipeline)][string]$Text) process { Set-Clipboard -Value $Text } }
function pbpaste { Get-Clipboard }
#endregion
