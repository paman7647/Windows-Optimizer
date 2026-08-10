#requires -Version 5.1

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ================================================================
# CONFIG
# ================================================================

$SelfUrl        = 'https://raw.githubusercontent.com/paman7647/Windows-Tools/main/linux.ps1'
$DistroName     = 'Ubuntu-26.04'
$StateRoot      = Join-Path $env:ProgramData 'WSL2-Ubuntu-Installer'
$ScriptCopy     = Join-Path $StateRoot 'linux.ps1'
$StateFile      = Join-Path $StateRoot 'state.json'
$PasswordFile   = Join-Path $StateRoot 'password.dat'
$ResumeTaskName = 'WSL2-Ubuntu-Installer-Resume'
$CloudInitDir   = Join-Path $env:USERPROFILE '.cloud-init'
$CloudInitFile  = Join-Path $CloudInitDir "$DistroName.user-data"

$script:RebootRequired      = $false
$script:LinuxUsername       = $null
$script:LinuxPassword       = $null
$script:InstallerScriptPath = $null

# ================================================================
# OUTPUT
# ================================================================

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# ================================================================
# BASICS
# ================================================================

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-PowerShellExe {
    $pwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($pwsh) {
        return $pwsh.Source
    }

    return (Get-Command powershell.exe -ErrorAction Stop).Source
}

function Ensure-StateRoot {
    if (-not (Test-Path $StateRoot)) {
        New-Item -ItemType Directory -Path $StateRoot -Force | Out-Null
    }
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [Parameter(Mandatory)] [string]$Content
    )
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Get-InstallerScriptPath {
    if (-not [string]::IsNullOrWhiteSpace($PSCommandPath) -and (Test-Path $PSCommandPath)) {
        return $PSCommandPath
    }

    Ensure-StateRoot
    Write-Host ''
    Write-Host 'Preparing installer...' -ForegroundColor Cyan

    Invoke-WebRequest -Uri $SelfUrl -OutFile $ScriptCopy -UseBasicParsing
    return $ScriptCopy
}

function Invoke-SelfRelaunch {
    param(
        [Parameter(Mandatory)] [string]$ScriptPath,
        [switch]$RunAs
    )

    $pwsh = Get-PowerShellExe
    $argLine = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

    if ($RunAs) {
        $proc = Start-Process -FilePath $pwsh -ArgumentList $argLine -Verb RunAs -Wait -PassThru
    }
    else {
        $proc = Start-Process -FilePath $pwsh -ArgumentList $argLine -Wait -PassThru
    }

    exit $proc.ExitCode
}

# ================================================================
# STATE
# ================================================================

function Save-State {
    param([Parameter(Mandatory)] [string]$Username)

    Ensure-StateRoot

    @{
        Username = $Username
        Stage    = 'RebootPending'
        Created  = (Get-Date).ToString('o')
    } |
        ConvertTo-Json |
        Set-Content -Path $StateFile -Encoding UTF8
}

function Get-State {
    if (-not (Test-Path $StateFile)) {
        return $null
    }

    try {
        return Get-Content -Path $StateFile -Raw | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Save-Password {
    param([Parameter(Mandatory)] [Security.SecureString]$Password)

    Ensure-StateRoot
    (ConvertFrom-SecureString $Password) | Set-Content -Path $PasswordFile -Encoding UTF8
}

function Get-SavedPassword {
    if (-not (Test-Path $PasswordFile)) {
        return $null
    }

    try {
        $encrypted = Get-Content -Path $PasswordFile -Raw
        return ConvertTo-SecureString $encrypted
    }
    catch {
        return $null
    }
}

function Remove-StateFiles {
    Remove-Item $StateFile, $PasswordFile, $ScriptCopy -Force -ErrorAction SilentlyContinue
    try {
        if (Test-Path $StateRoot) {
            $children = @(Get-ChildItem -Path $StateRoot -Force -ErrorAction SilentlyContinue)
            if ($children.Count -eq 0) {
                Remove-Item $StateRoot -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
    }
}

# ================================================================
# RESUME TASK
# ================================================================

function Remove-ResumeTask {
    try {
        Unregister-ScheduledTask -TaskName $ResumeTaskName -Confirm:$false -ErrorAction SilentlyContinue
    }
    catch {
    }
}

function Register-ResumeTask {
    Ensure-StateRoot

    if ($script:InstallerScriptPath -and ($script:InstallerScriptPath -ne $ScriptCopy)) {
        Copy-Item -Path $script:InstallerScriptPath -Destination $ScriptCopy -Force
    }

    $pwsh = Get-PowerShellExe
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $action = New-ScheduledTaskAction -Execute $pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptCopy`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId $identity.Name -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)

    Register-ScheduledTask -TaskName $ResumeTaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-OK 'Automatic reboot-resume task registered.'
}

function Restart-AndResume {
    Save-State -Username $script:LinuxUsername
    Save-Password -Password $script:LinuxPassword
    Register-ResumeTask

    Write-Host ''
    Write-Warn 'Windows restart is required.'
    Write-Host 'The installer will automatically continue after you sign in.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Restarting Windows in 5 seconds...' -ForegroundColor Yellow

    Start-Sleep -Seconds 5
    Restart-Computer -Force
    exit 0
}

# ================================================================
# REBOOT DETECTION
# ================================================================

function Test-WindowsRebootRequired {
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') {
        return $true
    }

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') {
        return $true
    }

    try {
        $pending = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
        if ($null -ne $pending.PendingFileRenameOperations) {
            return $true
        }
    }
    catch {
    }

    return $false
}

# ================================================================
# FEATURES / HYPERVISOR
# ================================================================

function Enable-WindowsFeatureSafe {
    param([Parameter(Mandatory)] [string]$FeatureName)

    Write-Step "Enabling $FeatureName"

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart -ErrorAction Stop
        if ($result.RestartNeeded) {
            $script:RebootRequired = $true
            Write-OK "$FeatureName enabled. Restart required."
        }
        else {
            Write-OK "$FeatureName enabled."
        }
        return
    }
    catch {
        Write-Warn 'PowerShell feature API failed; using DISM fallback.'
    }

    & dism.exe /online /enable-feature "/featurename:$FeatureName" /all /norestart
    $code = $LASTEXITCODE

    if ($code -notin @(0, 3010, 1641)) {
        throw "Failed to enable $FeatureName. DISM exit code: $code"
    }

    if ($code -in @(3010, 1641)) {
        $script:RebootRequired = $true
        Write-OK "$FeatureName enabled. Restart required."
    }
    else {
        Write-OK "$FeatureName enabled."
    }
}

function Ensure-HypervisorLaunch {
    Write-Step 'Checking Windows hypervisor configuration'

    $output = & bcdedit.exe /enum '{current}' 2>$null
    $line = $output | Where-Object { $_ -match 'hypervisorlaunchtype' } | Select-Object -First 1

    if ($line -match 'Off') {
        Write-Warn 'Hypervisor launch is disabled.'
        & bcdedit.exe /set hypervisorlaunchtype auto
        if ($LASTEXITCODE -ne 0) {
            throw 'Unable to enable hypervisor launch.'
        }

        $script:RebootRequired = $true
        Write-OK 'Hypervisor launch enabled. Restart required.'
    }
    else {
        Write-OK 'Hypervisor launch configuration is ready.'
    }
}

# ================================================================
# WSL / UBUNTU
# ================================================================

function Get-WSLDistros {
    try {
        $result = & wsl.exe --list --quiet 2>$null
        if ($LASTEXITCODE -ne 0) {
            return @()
        }

        return @(
            $result |
            ForEach-Object { $_.ToString().Trim().TrimStart([char]0xFEFF) } |
            Where-Object { $_ -and $_ -notmatch 'Windows Subsystem' -and $_ -notmatch 'No installed distributions' }
        )
    }
    catch {
        return @()
    }
}

function Test-WSLDistro {
    param([Parameter(Mandatory)] [string]$Name)

    foreach ($distro in (Get-WSLDistros)) {
        if ($distro -ieq $Name) {
            return $true
        }
    }
    return $false
}

function Get-WSLDistroVersion {
    param([Parameter(Mandatory)] [string]$Name)

    try {
        $output = & wsl.exe --list --verbose 2>$null
        $escaped = [regex]::Escape($Name)
        $pattern = "^\s*\*?\s*$escaped\s+\S+\s+([12])\s*$"

        foreach ($line in $output) {
            $text = $line.ToString()
            if ($text -match $pattern) {
                return [int]$Matches[1]
            }
        }
    }
    catch {
    }

    return $null
}

function Convert-SecureStringToPlainText {
    param([Parameter(Mandatory)] [Security.SecureString]$SecureString)

    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Test-LinuxUsername {
    param([Parameter(Mandatory)] [string]$Username)

    if ($Username -notmatch '^[a-z_][a-z0-9_-]{0,31}$') {
        return $false
    }

    if ($Username -eq 'root') {
        return $false
    }

    return $true
}

function Escape-BashSingleQuote {
    param([Parameter(Mandatory)] [string]$Value)

    return $Value.Replace("'", "'\''")
}

function New-CloudInit {
    param([Parameter(Mandatory)] [string]$Username)

    if (-not (Test-Path $CloudInitDir)) {
        New-Item -ItemType Directory -Path $CloudInitDir -Force | Out-Null
    }

    $config = @"
#cloud-config

users:
  - default
  - name: $Username
    gecos: $Username
    groups:
      - adm
      - sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    lock_passwd: true

write_files:
  - path: /etc/wsl.conf
    permissions: '0644'
    content: |
      [user]
      default=$Username

      [boot]
      systemd=true

      [interop]
      enabled=true
      appendWindowsPath=true

      [automount]
      enabled=true
      mountFsTab=false

final_message: "Ubuntu WSL cloud-init completed."
"@

    Write-Utf8NoBom -Path $CloudInitFile -Content $config
}

function Remove-CloudInit {
    if (Test-Path $CloudInitFile) {
        Remove-Item $CloudInitFile -Force -ErrorAction SilentlyContinue
    }

    try {
        if (Test-Path $CloudInitDir) {
            $children = @(Get-ChildItem -Path $CloudInitDir -Force -ErrorAction SilentlyContinue)
            if ($children.Count -eq 0) {
                Remove-Item $CloudInitDir -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
    }
}

function Update-WSLRuntime {
    Write-Step 'Updating WSL runtime'

    try {
        & wsl.exe --update --web-download
        if ($LASTEXITCODE -eq 0) {
            Write-OK 'WSL runtime updated.'
            return
        }
    }
    catch {
    }

    try {
        & wsl.exe --update
        if ($LASTEXITCODE -eq 0) {
            Write-OK 'WSL runtime updated.'
            return
        }
    }
    catch {
    }

    Write-Warn 'WSL update did not complete through wsl.exe; trying Microsoft release package.'

    $apiUrl = 'https://api.github.com/repos/microsoft/WSL/releases/latest'
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'WSL2-Ubuntu-Installer' } -UseBasicParsing

    $arch = $env:PROCESSOR_ARCHITECTURE.ToUpperInvariant()
    if ($arch -eq 'ARM64') {
        $pattern = '\.arm64\.msi$'
    }
    elseif ($arch -eq 'AMD64') {
        $pattern = '\.x64\.msi$'
    }
    else {
        throw "Unsupported architecture: $arch"
    }

    $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
    if (-not $asset) {
        throw "No matching WSL MSI asset found for architecture $arch."
    }

    $msiPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $msiPath -UseBasicParsing

    $signature = Get-AuthenticodeSignature -FilePath $msiPath
    if ($signature.Status -ne 'Valid') {
        Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
        throw "WSL MSI signature validation failed: $($signature.Status)"
    }

    if ($signature.SignerCertificate.Subject -notmatch 'Microsoft') {
        Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
        throw 'WSL MSI is not signed by Microsoft.'
    }

    $proc = Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$msiPath`" /qn /norestart" -Wait -PassThru
    Remove-Item $msiPath -Force -ErrorAction SilentlyContinue

    if ($proc.ExitCode -notin @(0, 3010)) {
        throw "WSL MSI installation failed with exit code $($proc.ExitCode)."
    }

    if ($proc.ExitCode -eq 3010) {
        $script:RebootRequired = $true
        Write-OK 'WSL runtime installed. Restart required.'
    }
    else {
        Write-OK 'WSL runtime installed.'
    }
}

function Get-UbuntuManifestImage {
    $manifestUrl = 'https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json'
    $manifest = Invoke-RestMethod -Uri $manifestUrl -UseBasicParsing

    $ubuntu = $manifest.ModernDistributions.Ubuntu | Where-Object { $_.Name -eq $DistroName } | Select-Object -First 1
    if (-not $ubuntu) {
        $ubuntu = $manifest.ModernDistributions.Ubuntu | Where-Object { $_.Name -eq 'Ubuntu' } | Select-Object -First 1
    }

    if (-not $ubuntu) {
        throw 'Ubuntu distribution metadata not found in Microsoft WSL manifest.'
    }

    if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
        return [pscustomobject]@{
            Url    = $ubuntu.Arm64Url.Url
            Sha256 = $ubuntu.Arm64Url.Sha256
        }
    }

    return [pscustomobject]@{
        Url    = $ubuntu.Amd64Url.Url
        Sha256 = $ubuntu.Amd64Url.Sha256
    }
}

function Install-UbuntuFromManifest {
    $image = Get-UbuntuManifestImage
    $wslFile = Join-Path $env:TEMP 'ubuntu-current.wsl'

    Write-Host "    Download: $($image.Url)"
    Invoke-WebRequest -Uri $image.Url -OutFile $wslFile -UseBasicParsing

    $hash = (Get-FileHash -Path $wslFile -Algorithm SHA256).Hash
    if ($hash.ToUpperInvariant() -ne $image.Sha256.ToUpperInvariant()) {
        Remove-Item $wslFile -Force -ErrorAction SilentlyContinue
        throw 'Ubuntu image SHA-256 verification failed.'
    }

    Write-OK 'Ubuntu image SHA-256 verified.'

    & wsl.exe --install --from-file $wslFile --no-launch
    $code = $LASTEXITCODE

    Remove-Item $wslFile -Force -ErrorAction SilentlyContinue

    if ($code -ne 0) {
        throw "Ubuntu installation from verified image failed with exit code $code."
    }
}

function Install-Ubuntu {
    if (Test-WSLDistro $DistroName) {
        Write-OK 'Ubuntu is already installed.'
        return
    }

    Write-Step 'Installing Ubuntu LTS'

    try {
        & wsl.exe --install --distribution $DistroName --web-download --no-launch
        if ($LASTEXITCODE -eq 0) {
            for ($i = 0; $i -lt 60; $i++) {
                if (Test-WSLDistro $DistroName) {
                    Write-OK 'Ubuntu installed.'
                    return
                }
                Start-Sleep -Seconds 1
            }
        }
    }
    catch {
    }

    Write-Warn 'Standard wsl --install path did not complete; trying Microsoft manifest fallback.'
    Install-UbuntuFromManifest

    for ($i = 0; $i -lt 60; $i++) {
        if (Test-WSLDistro $DistroName) {
            Write-OK 'Ubuntu installed.'
            return
        }
        Start-Sleep -Seconds 1
    }

    throw 'Ubuntu did not register with WSL.'
}

function Wait-ForUbuntu {
    Write-Step 'Waiting for Ubuntu registration'

    for ($i = 0; $i -lt 90; $i++) {
        if (Test-WSLDistro $DistroName) {
            Write-OK 'Ubuntu registration confirmed.'
            return
        }
        Start-Sleep -Seconds 2
    }

    throw 'Ubuntu did not register with WSL within the expected time.'
}

function Configure-UbuntuUser {
    param(
        [Parameter(Mandatory)] [string]$Username,
        [Parameter(Mandatory)] [Security.SecureString]$Password
    )

    $plain = Convert-SecureStringToPlainText $Password
    $safeUser = Escape-BashSingleQuote $Username
    $safePass = Escape-BashSingleQuote $plain

    try {
        $bash = @'
set -e
u='__USER__'
p='__PASS__'

if ! id -u "$u" >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --user-group "$u"
fi

printf '%s:%s\n' "$u" "$p" | chpasswd
usermod -aG sudo "$u" || true

mkdir -p /etc/sudoers.d
printf '%s\n' "$u ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/90-$u"
chmod 0440 "/etc/sudoers.d/90-$u"

mkdir -p "/home/$u"
chown -R "$u:$u" "/home/$u"
touch "/home/$u/.hushlogin"

cat > /etc/wsl.conf <<EOF
[user]
default=$u

[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[automount]
enabled=true
mountFsTab=false
EOF
'@

        $bash = $bash.Replace('__USER__', $safeUser).Replace('__PASS__', $safePass)

        & wsl.exe --distribution $DistroName --user root --exec bash -lc $bash

        if ($LASTEXITCODE -ne 0) {
            throw "Linux user bootstrap failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        $plain = $null
        $bash = $null
    }
}

function Validate-WslStatus {
    Write-Step 'Final WSL status'

    Write-Host ''
    Write-Host 'WSL STATUS' -ForegroundColor Cyan
    Write-Host '----------'
    & wsl.exe --status

    Write-Host ''
    Write-Host 'DISTRIBUTIONS' -ForegroundColor Cyan
    Write-Host '-------------'
    & wsl.exe --list --verbose

    Write-Host ''
    Write-Host 'WSL VERSION' -ForegroundColor Cyan
    Write-Host '-----------'
    & wsl.exe --version
}

function Cleanup-Success {
    Remove-CloudInit
    Remove-ResumeTask
    Remove-StateFiles
}

# ================================================================
# SELF-MATERIALIZE + ELEVATE
# ================================================================

$script:InstallerScriptPath = Get-InstallerScriptPath

if (-not (Test-Administrator)) {
    Write-Host ''
    Write-Host 'Administrator privileges are required.' -ForegroundColor Yellow
    Write-Host 'Requesting Administrator elevation...' -ForegroundColor Cyan
    Write-Host ''
    Invoke-SelfRelaunch -ScriptPath $script:InstallerScriptPath -RunAs
}

# ================================================================
# MAIN
# ================================================================

try {
    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host '             WSL 2 + UBUNTU LTS INSTALLER' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''

    Write-OK 'Administrator privileges confirmed.'

    Write-Step 'Checking Windows compatibility'
    $os = Get-CimInstance Win32_OperatingSystem
    $build = [int]$os.BuildNumber

    Write-Host "    Operating System : $($os.Caption)"
    Write-Host "    Build            : $build"
    Write-Host "    Architecture     : $env:PROCESSOR_ARCHITECTURE"

    if ($build -lt 19041) {
        throw 'Windows 10 build 19041+ or Windows 11 is required.'
    }

    Write-OK 'Supported Windows version detected.'

    # Resume or prompt for credentials.
    $state = Get-State
    if ($null -ne $state -and $state.Stage -eq 'RebootPending') {
        $script:LinuxUsername = $state.Username
        $script:LinuxPassword = Get-SavedPassword

        Write-Host ''
        Write-OK "Resuming installation for Linux user '$script:LinuxUsername'."

        if ($null -eq $script:LinuxPassword) {
            Write-Warn 'Saved password could not be recovered.'
            $script:LinuxPassword = Read-Host 'Enter Linux password' -AsSecureString
        }
    }
    else {
        Write-Step 'Linux account setup'
        Write-Host ''
        Write-Host 'Choose the Linux username and password for Ubuntu.'
        Write-Host 'Press Enter to use the default username: dev'
        Write-Host ''

        do {
            $script:LinuxUsername = Read-Host 'Linux username [dev]'
            if ([string]::IsNullOrWhiteSpace($script:LinuxUsername)) {
                $script:LinuxUsername = 'dev'
            }

            if (-not (Test-LinuxUsername $script:LinuxUsername)) {
                Write-Warn 'Invalid Linux username. Use lowercase letters, numbers, _ or -.'
                $script:LinuxUsername = $null
            }
        }
        while ([string]::IsNullOrWhiteSpace($script:LinuxUsername))

        do {
            $script:LinuxPassword = Read-Host 'Linux password' -AsSecureString
            $confirm = Read-Host 'Confirm Linux password' -AsSecureString

            $p1 = Convert-SecureStringToPlainText $script:LinuxPassword
            $p2 = Convert-SecureStringToPlainText $confirm

            $match = ($p1.Length -gt 0 -and $p1 -eq $p2)
            $p1 = $null
            $p2 = $null

            if (-not $match) {
                Write-Warn 'Passwords do not match.'
            }
        }
        while (-not $match)

        Write-OK "Linux username: $script:LinuxUsername"
        Write-OK 'Linux password accepted.'
    }

    # Cloud-init file prepared before install, as recommended by Ubuntu docs.
    New-CloudInit -Username $script:LinuxUsername

    Write-Step 'Checking WSL Windows features'
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

    Write-Host ''
    Write-Host "    WSL               : $($wslFeature.State)"
    Write-Host "    Virtual Machine   : $($vmFeature.State)"

    if ($wslFeature.State -ne 'Enabled') {
        Enable-WindowsFeatureSafe -FeatureName 'Microsoft-Windows-Subsystem-Linux'
    }
    else {
        Write-OK 'Windows Subsystem for Linux already enabled.'
    }

    if ($vmFeature.State -ne 'Enabled') {
        Enable-WindowsFeatureSafe -FeatureName 'VirtualMachinePlatform'
    }
    else {
        Write-OK 'Virtual Machine Platform already enabled.'
    }

    Ensure-HypervisorLaunch

    if ($script:RebootRequired -or (Test-WindowsRebootRequired)) {
        Restart-AndResume
    }

    Update-WSLRuntime

    if ($script:RebootRequired) {
        Restart-AndResume
    }

    Write-Step 'Setting WSL 2 as the default version'
    & wsl.exe --set-default-version 2
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to set WSL 2 as the default version.'
    }
    Write-OK 'WSL 2 configured as the default version.'

    Install-Ubuntu
    Wait-ForUbuntu

    Write-Step 'Validating Ubuntu WSL version'
    $ubuntuVersion = Get-WSLDistroVersion -Name $DistroName
    if ($ubuntuVersion -eq 1) {
        Write-Warn 'Ubuntu is currently WSL 1. Converting to WSL 2...'
        & wsl.exe --set-version $DistroName 2
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to convert Ubuntu to WSL 2.'
        }
        Write-OK 'Ubuntu converted to WSL 2.'
    }
    elseif ($ubuntuVersion -eq 2) {
        Write-OK 'Ubuntu is already WSL 2.'
    }
    else {
        throw 'Unable to determine the Ubuntu WSL version.'
    }

    Write-Step 'Starting Ubuntu provisioning'
    & wsl.exe --distribution $DistroName --user root --exec true
    if ($LASTEXITCODE -ne 0) {
        throw 'Ubuntu could not start.'
    }

    Configure-UbuntuUser -Username $script:LinuxUsername -Password $script:LinuxPassword
    Write-OK "Linux user '$script:LinuxUsername' configured."

    Write-Step 'Restarting WSL'
    & wsl.exe --shutdown
    Start-Sleep -Seconds 3
    Write-OK 'WSL restarted.'

    Write-Step 'Setting Ubuntu as the default distribution'
    & wsl.exe --set-default $DistroName
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to set Ubuntu as the default distribution.'
    }
    Write-OK 'Ubuntu is the default distribution.'

    Write-Step 'Validating default Linux user'
    $detectedUser = (& wsl.exe --distribution $DistroName --exec whoami 2>$null | Select-Object -First 1).ToString().Trim()
    if ($detectedUser -ne $script:LinuxUsername) {
        throw "Default user validation failed. Expected '$script:LinuxUsername', got '$detectedUser'."
    }
    Write-OK "Default Linux user: $script:LinuxUsername"

    Write-Step 'Validating sudo'
    & wsl.exe --distribution $DistroName --exec sudo -n true 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'sudo validation failed.'
    }
    Write-OK 'sudo is configured.'

    $finalVersion = Get-WSLDistroVersion -Name $DistroName
    if ($finalVersion -ne 2) {
        throw "Ubuntu is not running WSL 2. Detected version: $finalVersion"
    }
    Write-OK 'Ubuntu is running WSL 2.'

    Validate-WslStatus

    Write-Step 'Cleaning temporary setup data'
    Cleanup-Success

    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Green
    Write-Host '              INSTALLATION COMPLETE' -ForegroundColor Green
    Write-Host '============================================================' -ForegroundColor Green
    Write-Host ''
    Write-Host "Ubuntu      : $DistroName"
    Write-Host 'WSL Version : 2'
    Write-Host "Linux User  : $script:LinuxUsername"
    Write-Host ''
    Write-Host 'Start Ubuntu:' -ForegroundColor Cyan
    Write-Host '    wsl'
    Write-Host ''
    Write-Host 'Verify:' -ForegroundColor Cyan
    Write-Host '    wsl -l -v'
    Write-Host '    wsl --status'
    Write-Host ''

    exit 0
}
catch {
    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Red
    Write-Host '              INSTALLATION FAILED' -ForegroundColor Red
    Write-Host '============================================================' -ForegroundColor Red
    Write-Host ''
    Write-Fail $_.Exception.Message
    Write-Host ''
    Write-Host 'Diagnostics:' -ForegroundColor Yellow
    Write-Host '    wsl --status'
    Write-Host '    wsl --version'
    Write-Host '    wsl -l -v'
    Write-Host ''
    Write-Warn 'The installer can be run again safely.'
    Write-Host ''
    exit 1
}
