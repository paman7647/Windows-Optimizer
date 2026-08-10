#requires -Version 5.1

<#
.SYNOPSIS
    Unattended WSL 2 + Ubuntu LTS installer.

.DESCRIPTION
    Run directly:

        irm https://raw.githubusercontent.com/paman7647/Windows-Tools/main/linux.ps1 | iex

    Features:
      - No command-line arguments
      - Automatic Administrator elevation
      - Works from IEX / GitHub
      - Reliable reboot/resume
      - Enables WSL
      - Enables Virtual Machine Platform
      - Handles DISM 3010 / 1641 correctly
      - Enables hypervisor launch if disabled
      - Updates WSL
      - Installs latest stable Ubuntu LTS
      - ARM64 and AMD64 support
      - SHA256 verifies direct Ubuntu image fallback
      - Uses Ubuntu cloud-init
      - Creates requested Linux user
      - Sets requested password
      - Configures sudo
      - Sets Linux user as default
      - Forces WSL 2
      - Idempotent
      - Preserves existing Ubuntu installation
      - Cleans temporary state after success
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ================================================================
# CONFIGURATION
# ================================================================

$SelfUrl =
    'https://raw.githubusercontent.com/paman7647/Windows-Tools/main/linux.ps1'

$DistroName = 'Ubuntu'

$StateRoot = Join-Path `
    $env:ProgramData `
    'WSL2-Ubuntu-Installer'

$StateFile = Join-Path `
    $StateRoot `
    'state.json'

$PasswordFile = Join-Path `
    $StateRoot `
    'password.dat'

$InstallerFile = Join-Path `
    $StateRoot `
    'linux.ps1'

$ResumeTaskName =
    'WSL2-Ubuntu-Installer-Resume'

$CloudInitDirectory = Join-Path `
    $env:USERPROFILE `
    '.cloud-init'

$CloudInitFile = Join-Path `
    $CloudInitDirectory `
    "$DistroName.user-data"

$script:RebootRequired = $false


# ================================================================
# OUTPUT
# ================================================================

function Write-Step {
    param(
        [string]$Message
    )

    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-OK {
    param(
        [string]$Message
    )

    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param(
        [string]$Message
    )

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param(
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}


# ================================================================
# ADMIN CHECK
# ================================================================

function Test-Administrator {

    $identity =
        [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal =
        New-Object Security.Principal.WindowsPrincipal($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}


function Get-PowerShellExecutable {

    $pwsh =
        Get-Command `
            pwsh.exe `
            -ErrorAction SilentlyContinue

    if ($pwsh) {
        return $pwsh.Source
    }

    return (
        Get-Command `
            powershell.exe `
            -ErrorAction Stop
    ).Source
}


# ================================================================
# ENSURE REAL SCRIPT FILE
#
# Critical for:
#     irm URL | iex
#
# IEX does not provide $PSCommandPath.
# ================================================================

function Ensure-RealScriptFile {

    if (
        -not [string]::IsNullOrWhiteSpace($PSCommandPath) -and
        (Test-Path $PSCommandPath)
    ) {

        return $PSCommandPath
    }

    if (-not (Test-Path $StateRoot)) {

        New-Item `
            -ItemType Directory `
            -Path $StateRoot `
            -Force |
            Out-Null
    }

    if (-not (Test-Path $InstallerFile)) {

        Write-Host ''
        Write-Host `
            'Preparing installer...' `
            -ForegroundColor Cyan

        Invoke-WebRequest `
            -Uri $SelfUrl `
            -OutFile $InstallerFile `
            -UseBasicParsing
    }

    return $InstallerFile
}


# ================================================================
# AUTOMATIC ELEVATION
# ================================================================

if (-not (Test-Administrator)) {

    Write-Host ''
    Write-Host `
        'Administrator privileges are required.' `
        -ForegroundColor Yellow

    Write-Host `
        'Requesting Administrator elevation...' `
        -ForegroundColor Cyan

    Write-Host ''

    try {

        $SourceFile = Ensure-RealScriptFile

        $PowerShell = Get-PowerShellExecutable

        $Arguments =
            "-NoProfile -ExecutionPolicy Bypass -File `"$SourceFile`""

        $process = Start-Process `
            -FilePath $PowerShell `
            -ArgumentList $Arguments `
            -Verb RunAs `
            -Wait `
            -PassThru

        exit $process.ExitCode
    }
    catch {

        Write-Fail `
            "Administrator elevation failed: $($_.Exception.Message)"

        exit 1
    }
}


# ================================================================
# WE ARE NOW ELEVATED
#
# If originally started using IEX, make sure the elevated
# process itself is file-backed.
# ================================================================

try {

    if (
        [string]::IsNullOrWhiteSpace($PSCommandPath) -or
        -not (Test-Path $PSCommandPath)
    ) {

        if (-not (Test-Path $StateRoot)) {

            New-Item `
                -ItemType Directory `
                -Path $StateRoot `
                -Force |
                Out-Null
        }

        Invoke-WebRequest `
            -Uri $SelfUrl `
            -OutFile $InstallerFile `
            -UseBasicParsing

        $PowerShell = Get-PowerShellExecutable

        $process = Start-Process `
            -FilePath $PowerShell `
            -ArgumentList `
            "-NoProfile -ExecutionPolicy Bypass -File `"$InstallerFile`"" `
            -Wait `
            -PassThru

        exit $process.ExitCode
    }
}
catch {

    Write-Fail `
        "Unable to prepare persistent installer: $($_.Exception.Message)"

    exit 1
}


# ================================================================
# STATE
# ================================================================

function Ensure-StateDirectory {

    if (-not (Test-Path $StateRoot)) {

        New-Item `
            -ItemType Directory `
            -Path $StateRoot `
            -Force |
            Out-Null
    }
}


function Save-State {

    param(
        [string]$Username
    )

    Ensure-StateDirectory

    @{
        Username = $Username
        Stage    = 'RebootPending'
        Created  = (Get-Date).ToString('o')
    } |
        ConvertTo-Json |
        Set-Content `
            -Path $StateFile `
            -Encoding UTF8
}


function Get-State {

    if (-not (Test-Path $StateFile)) {
        return $null
    }

    try {

        return (
            Get-Content `
                -Path $StateFile `
                -Raw |
            ConvertFrom-Json
        )
    }
    catch {

        return $null
    }
}


function Save-Password {

    param(
        [Security.SecureString]$Password
    )

    Ensure-StateDirectory

    # DPAPI-protected for the current Windows user.
    $encrypted =
        ConvertFrom-SecureString $Password

    Set-Content `
        -Path $PasswordFile `
        -Value $encrypted `
        -Encoding UTF8
}


function Get-SavedPassword {

    if (-not (Test-Path $PasswordFile)) {
        return $null
    }

    try {

        $encrypted =
            Get-Content `
                -Path $PasswordFile `
                -Raw

        return ConvertTo-SecureString $encrypted
    }
    catch {

        return $null
    }
}


# ================================================================
# SCHEDULED REBOOT RESUME
# ================================================================

function Remove-ResumeTask {

    try {

        Unregister-ScheduledTask `
            -TaskName $ResumeTaskName `
            -Confirm:$false `
            -ErrorAction SilentlyContinue
    }
    catch {
    }
}


function Register-ResumeTask {

    Ensure-StateDirectory

    # The script is guaranteed to be file-backed now.
    Copy-Item `
        -Path $PSCommandPath `
        -Destination $InstallerFile `
        -Force

    $PowerShell =
        Get-PowerShellExecutable

    $identity =
        [Security.Principal.WindowsIdentity]::GetCurrent()

    $action =
        New-ScheduledTaskAction `
            -Execute $PowerShell `
            -Argument `
            "-NoProfile -ExecutionPolicy Bypass -File `"$InstallerFile`""

    $trigger =
        New-ScheduledTaskTrigger `
            -AtLogOn

    $principal =
        New-ScheduledTaskPrincipal `
            -UserId $identity.Name `
            -LogonType Interactive `
            -RunLevel Highest

    $settings =
        New-ScheduledTaskSettingsSet `
            -StartWhenAvailable `
            -ExecutionTimeLimit (
                New-TimeSpan -Hours 2
            )

    Register-ScheduledTask `
        -TaskName $ResumeTaskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Force |
        Out-Null

    Write-OK `
        'Automatic reboot-resume task registered.'
}


function Restart-AndResume {

    Register-ResumeTask

    Save-State `
        -Username $script:LinuxUsername

    Save-Password `
        -Password $script:LinuxPassword

    Write-Host ''
    Write-Warn `
        'Windows restart is required.'

    Write-Host `
        'The installer will automatically continue after you sign in.' `
        -ForegroundColor Yellow

    Write-Host ''
    Write-Host `
        'Restarting Windows in 5 seconds...' `
        -ForegroundColor Yellow

    Start-Sleep -Seconds 5

    Restart-Computer -Force

    exit 0
}


# ================================================================
# REBOOT DETECTION
# ================================================================

function Test-WindowsRebootRequired {

    if (
        Test-Path `
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    ) {

        return $true
    }

    if (
        Test-Path `
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    ) {

        return $true
    }

    try {

        $pending =
            Get-ItemProperty `
                'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
                -Name PendingFileRenameOperations `
                -ErrorAction SilentlyContinue

        if ($null -ne $pending.PendingFileRenameOperations) {
            return $true
        }
    }
    catch {
    }

    return $false
}


# ================================================================
# WINDOWS FEATURE ENABLEMENT
# ================================================================

function Enable-WindowsFeatureSafe {

    param(
        [Parameter(Mandatory)]
        [string]$FeatureName
    )

    Write-Step `
        "Enabling $FeatureName"

    # ------------------------------------------------------------
    # Preferred Microsoft PowerShell API.
    #
    # It exposes RestartNeeded directly.
    # ------------------------------------------------------------

    try {

        $result =
            Enable-WindowsOptionalFeature `
                -Online `
                -FeatureName $FeatureName `
                -All `
                -NoRestart `
                -ErrorAction Stop

        if ($result.RestartNeeded) {

            $script:RebootRequired = $true

            Write-OK `
                "$FeatureName enabled. Restart required."
        }
        else {

            Write-OK `
                "$FeatureName enabled."
        }

        return
    }
    catch {

        Write-Warn `
            'PowerShell feature API failed; using DISM fallback.'
    }

    # ------------------------------------------------------------
    # DISM fallback.
    #
    # 0    = success
    # 3010 = success + reboot required
    # 1641 = success + restart initiated/required
    # ------------------------------------------------------------

    & dism.exe `
        /online `
        /enable-feature `
        "/featurename:$FeatureName" `
        /all `
        /norestart

    $code = $LASTEXITCODE

    if ($code -notin @(0, 3010, 1641)) {

        throw `
            "Failed to enable $FeatureName. DISM exit code: $code"
    }

    if ($code -in @(3010, 1641)) {

        $script:RebootRequired = $true

        Write-OK `
            "$FeatureName enabled. Restart required."
    }
    else {

        Write-OK `
            "$FeatureName enabled."
    }
}


# ================================================================
# HYPERVISOR BOOT CONFIGURATION
# ================================================================

function Ensure-HypervisorLaunch {

    Write-Step `
        'Checking Windows hypervisor configuration'

    $output =
        & bcdedit.exe `
            /enum `
            '{current}' `
            2>$null

    $line =
        $output |
        Where-Object {
            $_ -match 'hypervisorlaunchtype'
        } |
        Select-Object -First 1

    if ($line -match 'Off') {

        Write-Warn `
            'Hypervisor launch is disabled.'

        & bcdedit.exe `
            /set `
            hypervisorlaunchtype `
            Auto

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Unable to enable hypervisor launch.'
        }

        $script:RebootRequired = $true

        Write-OK `
            'Hypervisor launch enabled. Restart required.'
    }
    else {

        Write-OK `
            'Hypervisor launch configuration is ready.'
    }
}


# ================================================================
# WSL DISTRIBUTIONS
# ================================================================

function Get-WSLDistros {

    try {

        $result =
            & wsl.exe `
                --list `
                --quiet `
                2>$null

        if ($LASTEXITCODE -ne 0) {
            return @()
        }

        return @(
            $result |
            ForEach-Object {
                $_.ToString().
                    Trim().
                    TrimStart([char]0xFEFF)
            } |
            Where-Object {
                $_ -and
                $_ -notmatch 'Windows Subsystem' -and
                $_ -notmatch 'No installed distributions'
            }
        )
    }
    catch {

        return @()
    }
}


function Test-WSLDistro {

    param(
        [string]$Name
    )

    foreach (
        $distro in (
            Get-WSLDistros
        )
    ) {

        if ($distro -ieq $Name) {
            return $true
        }
    }

    return $false
}


function Get-WSLDistroVersion {

    param(
        [string]$Name
    )

    try {

        $output =
            & wsl.exe `
                --list `
                --verbose `
                2>$null

        foreach ($line in $output) {

            $text =
                $line.ToString()

            if (
                $text -match [regex]::Escape($Name) -and
                $text -match '\s([12])\s*$'
            ) {

                return [int]$Matches[1]
            }
        }
    }
    catch {
    }

    return $null
}


# ================================================================
# LINUX USER VALIDATION
# ================================================================

function Test-LinuxUsername {

    param(
        [string]$Username
    )

    if (
        $Username -notmatch `
            '^[a-z_][a-z0-9_-]{0,31}$'
    ) {

        return $false
    }

    if ($Username -eq 'root') {
        return $false
    }

    return $true
}


# ================================================================
# SECURE STRING
# ================================================================

function Convert-SecureStringToPlain {

    param(
        [Security.SecureString]$SecureString
    )

    $ptr =
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR(
            $SecureString
        )

    try {

        return (
            [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
                $ptr
            )
        )
    }
    finally {

        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
            $ptr
        )
    }
}


# ================================================================
# CLOUD-INIT
# ================================================================

function New-CloudInit {

    param(
        [string]$Username
    )

    if (-not (Test-Path $CloudInitDirectory)) {

        New-Item `
            -ItemType Directory `
            -Path $CloudInitDirectory `
            -Force |
            Out-Null
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

runcmd:
  - mkdir -p /home/$Username
  - chown -R $Username`:$Username /home/$Username
  - touch /home/$Username/.hushlogin

final_message: "WSL Ubuntu provisioning completed."
"@

    Set-Content `
        -Path $CloudInitFile `
        -Value $config `
        -Encoding UTF8

    Write-OK `
        'Ubuntu cloud-init configuration created.'
}


function Remove-CloudInit {

    if (Test-Path $CloudInitFile) {

        Remove-Item `
            $CloudInitFile `
            -Force `
            -ErrorAction SilentlyContinue
    }
}


# ================================================================
# WSL UPDATE
# ================================================================

function Update-WSL {

    Write-Step `
        'Updating WSL'

    # Current Microsoft-supported path.
    try {

        & wsl.exe `
            --update `
            --web-download

        if ($LASTEXITCODE -eq 0) {

            Write-OK `
                'WSL updated successfully.'

            return
        }
    }
    catch {
    }

    Write-Warn `
        'wsl --update --web-download did not complete.'

    # Try normal WSL update.
    try {

        & wsl.exe `
            --update

        if ($LASTEXITCODE -eq 0) {

            Write-OK `
                'WSL updated successfully.'

            return
        }
    }
    catch {
    }

    # ------------------------------------------------------------
    # Official Microsoft WSL release fallback.
    # ------------------------------------------------------------

    Write-Warn `
        'Downloading the latest stable Microsoft WSL package.'

    $api =
        'https://api.github.com/repos/microsoft/WSL/releases/latest'

    $release =
        Invoke-RestMethod `
            -Uri $api `
            -Headers @{
                'User-Agent' = 'WSL2-Ubuntu-Installer'
            } `
            -UseBasicParsing

    $architecture =
        $env:PROCESSOR_ARCHITECTURE.ToUpperInvariant()

    if ($architecture -eq 'ARM64') {

        $assetPattern =
            '\.arm64\.msi$'
    }
    elseif ($architecture -eq 'AMD64') {

        $assetPattern =
            '\.x64\.msi$'
    }
    else {

        throw `
            "Unsupported Windows architecture: $architecture"
    }

    $asset =
        $release.assets |
        Where-Object {
            $_.name -match $assetPattern
        } |
        Select-Object -First 1

    if ($null -eq $asset) {

        throw `
            "No WSL MSI for architecture $architecture was found."
    }

    $msi =
        Join-Path `
            $env:TEMP `
            $asset.name

    Write-Host ''
    Write-Host `
        "    Microsoft WSL release: $($release.tag_name)"

    Write-Host `
        "    Package: $($asset.name)"

    Invoke-WebRequest `
        -Uri $asset.browser_download_url `
        -OutFile $msi `
        -UseBasicParsing

    # ------------------------------------------------------------
    # Verify Authenticode signature.
    # ------------------------------------------------------------

    Write-Host `
        '    Verifying Microsoft digital signature...'

    $signature =
        Get-AuthenticodeSignature `
            -FilePath $msi

    if ($signature.Status -ne 'Valid') {

        Remove-Item `
            $msi `
            -Force `
            -ErrorAction SilentlyContinue

        throw `
            "WSL MSI signature validation failed: $($signature.Status)"
    }

    if (
        $signature.SignerCertificate.Subject `
            -notmatch 'Microsoft'
    ) {

        Remove-Item `
            $msi `
            -Force `
            -ErrorAction SilentlyContinue

        throw `
            'WSL MSI is not signed by a Microsoft certificate.'
    }

    Write-OK `
        'Microsoft WSL package signature verified.'

    $process =
        Start-Process `
            -FilePath 'msiexec.exe' `
            -ArgumentList `
                "/i `"$msi`" /qn /norestart" `
            -Wait `
            -PassThru

    $code =
        $process.ExitCode

    Remove-Item `
        $msi `
        -Force `
        -ErrorAction SilentlyContinue

    if ($code -notin @(0, 3010)) {

        throw `
            "WSL MSI installation failed with exit code $code."
    }

    if ($code -eq 3010) {

        $script:RebootRequired = $true

        Write-OK `
            'WSL updated. Restart required.'
    }
    else {

        Write-OK `
            'WSL updated.'
    }
}


# ================================================================
# UBUNTU INSTALLATION
# ================================================================

function Install-Ubuntu {

    if (Test-WSLDistro $DistroName) {

        Write-OK `
            'Ubuntu is already installed.'

        return
    }

    Write-Step `
        'Installing current Ubuntu LTS'

    # ------------------------------------------------------------
    # Preferred Microsoft WSL path.
    # ------------------------------------------------------------

    try {

        & wsl.exe `
            --install `
            --distribution $DistroName `
            --web-download `
            --no-launch

        if ($LASTEXITCODE -eq 0) {

            for ($i = 0; $i -lt 30; $i++) {

                if (
                    Test-WSLDistro `
                        $DistroName
                ) {

                    Write-OK `
                        'Ubuntu installed.'

                    return
                }

                Start-Sleep -Seconds 1
            }
        }
    }
    catch {
    }

    Write-Warn `
        'Standard Ubuntu installation did not complete.'

    Write-Host `
        'Using the current Microsoft Ubuntu distribution manifest.'

    # ------------------------------------------------------------
    # Microsoft DistributionInfo.json
    # ------------------------------------------------------------

    $manifestUrl =
        'https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json'

    $manifest =
        Invoke-RestMethod `
            -Uri $manifestUrl `
            -UseBasicParsing

    $ubuntu =
        $manifest.ModernDistributions.Ubuntu |
        Where-Object {
            $_.Name -eq 'Ubuntu'
        } |
        Select-Object -First 1

    if ($null -eq $ubuntu) {

        throw `
            'The current Ubuntu distribution was not found in Microsoft WSL metadata.'
    }

    if (
        $env:PROCESSOR_ARCHITECTURE -eq 'ARM64'
    ) {

        $image =
            $ubuntu.Arm64Url
    }
    elseif (
        $env:PROCESSOR_ARCHITECTURE -eq 'AMD64'
    ) {

        $image =
            $ubuntu.Amd64Url
    }
    else {

        throw `
            "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE"
    }

    $imageFile =
        Join-Path `
            $env:TEMP `
            'ubuntu-current.wsl'

    Write-Host ''
    Write-Host `
        "    Ubuntu image: $($image.Url)"

    Invoke-WebRequest `
        -Uri $image.Url `
        -OutFile $imageFile `
        -UseBasicParsing

    Write-Host `
        '    Verifying Ubuntu SHA-256...'

    $hash =
        (
            Get-FileHash `
                -Path $imageFile `
                -Algorithm SHA256
        ).Hash

    if (
        $hash.ToUpperInvariant() `
        -ne `
        $image.Sha256.ToUpperInvariant()
    ) {

        Remove-Item `
            $imageFile `
            -Force `
            -ErrorAction SilentlyContinue

        throw `
            'Ubuntu image SHA-256 verification failed.'
    }

    Write-OK `
        'Ubuntu image SHA-256 verified.'

    & wsl.exe `
        --install `
        --from-file $imageFile `
        --no-launch

    $code =
        $LASTEXITCODE

    Remove-Item `
        $imageFile `
        -Force `
        -ErrorAction SilentlyContinue

    if ($code -ne 0) {

        throw `
            "Ubuntu installation from verified image failed. Exit code: $code"
    }

    Write-OK `
        'Ubuntu installed from the verified current image.'
}


# ================================================================
# WAIT FOR DISTRO
# ================================================================

function Wait-ForUbuntu {

    Write-Step `
        'Waiting for Ubuntu registration'

    for ($i = 0; $i -lt 90; $i++) {

        if (
            Test-WSLDistro `
                $DistroName
        ) {

            Write-OK `
                'Ubuntu registration confirmed.'

            return
        }

        Start-Sleep -Seconds 2
    }

    throw `
        'Ubuntu did not register with WSL within the expected time.'
}


# ================================================================
# CONFIGURE LINUX USER
# ================================================================

function Configure-LinuxUser {

    param(
        [string]$Username
    )

    $safeUsername =
        $Username.Replace(
            "'",
            "'\''"
        )

    $bashScript = @"
set -e

USERNAME='$safeUsername'

if ! id -u "`$USERNAME" >/dev/null 2>&1; then
    useradd \
        --create-home \
        --shell /bin/bash \
        --user-group \
        "`$USERNAME"
fi

usermod -aG sudo "`$USERNAME"

mkdir -p /etc/sudoers.d

printf '%s\n' \
    "`$USERNAME ALL=(ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/90-`$USERNAME"

chmod 0440 "/etc/sudoers.d/90-`$USERNAME"

mkdir -p "/home/`$USERNAME"

chown -R \
    "`$USERNAME:`$USERNAME" \
    "/home/`$USERNAME"

touch "/home/`$USERNAME/.hushlogin"

cat > /etc/wsl.conf <<EOF
[user]
default=`$USERNAME

[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[automount]
enabled=true
mountFsTab=false
EOF

echo USER_READY
"@

    & wsl.exe `
        --distribution $DistroName `
        --user root `
        --exec bash `
        -c $bashScript

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Failed to configure the Linux user.'
    }
}


# ================================================================
# SET LINUX PASSWORD
# ================================================================

function Set-LinuxPassword {

    param(
        [string]$Username,

        [Security.SecureString]$Password
    )

    $plain =
        Convert-SecureStringToPlain `
            $Password

    try {

        $inputLine =
            "$Username`:$plain"

        $inputLine |
            & wsl.exe `
                --distribution $DistroName `
                --user root `
                --exec chpasswd

        if ($LASTEXITCODE -ne 0) {

            throw `
                "chpasswd failed with exit code $LASTEXITCODE."
        }
    }
    finally {

        $plain = $null
        $inputLine = $null
    }
}


# ================================================================
# MAIN
# ================================================================

try {

    Write-Host ''
    Write-Host `
        '============================================================' `
        -ForegroundColor Cyan

    Write-Host `
        '             WSL 2 + UBUNTU LTS INSTALLER' `
        -ForegroundColor Cyan

    Write-Host `
        '============================================================' `
        -ForegroundColor Cyan

    Write-Host ''

    Write-OK `
        'Administrator privileges confirmed.'


    # ============================================================
    # WINDOWS VERSION
    # ============================================================

    Write-Step `
        'Checking Windows compatibility'

    $OS =
        Get-CimInstance `
            Win32_OperatingSystem

    $Build =
        [int]$OS.BuildNumber

    Write-Host `
        "    Operating System : $($OS.Caption)"

    Write-Host `
        "    Build            : $Build"

    Write-Host `
        "    Architecture     : $env:PROCESSOR_ARCHITECTURE"

    if ($Build -lt 19041) {

        throw `
            'Windows 10 build 19041+ or Windows 11 is required.'
    }

    Write-OK `
        'Supported Windows version detected.'


    # ============================================================
    # USER CREDENTIALS
    # ============================================================

    $state =
        Get-State

    if (
        $null -ne $state -and
        $state.Stage -eq 'RebootPending'
    ) {

        $script:LinuxUsername =
            $state.Username

        $script:LinuxPassword =
            Get-SavedPassword

        Write-Host ''

        Write-OK `
            "Resuming installation for '$LinuxUsername'."

        if ($null -eq $LinuxPassword) {

            Write-Warn `
                'Saved password could not be recovered.'

            $script:LinuxPassword =
                Read-Host `
                    'Enter Linux password' `
                    -AsSecureString
        }
    }
    else {

        Write-Step `
            'Linux account setup'

        Write-Host ''
        Write-Host `
            'Choose the Linux username and password.'

        Write-Host ''
        Write-Host `
            'Press Enter for username "dev".'

        Write-Host ''

        do {

            $script:LinuxUsername =
                Read-Host `
                    'Linux username [dev]'

            if (
                [string]::IsNullOrWhiteSpace(
                    $LinuxUsername
                )
            ) {

                $script:LinuxUsername =
                    'dev'
            }

            if (
                -not (
                    Test-LinuxUsername `
                        $LinuxUsername
                )
            ) {

                Write-Warn `
                    'Invalid Linux username.'

                $script:LinuxUsername = $null
            }

        }
        while (
            [string]::IsNullOrWhiteSpace(
                $LinuxUsername
            )
        )


        do {

            $script:LinuxPassword =
                Read-Host `
                    'Linux password' `
                    -AsSecureString

            $confirm =
                Read-Host `
                    'Confirm Linux password' `
                    -AsSecureString

            $password1 =
                Convert-SecureStringToPlain `
                    $LinuxPassword

            $password2 =
                Convert-SecureStringToPlain `
                    $confirm

            $match =
                (
                    $password1.Length -gt 0 -and
                    $password1 -eq $password2
                )

            $password1 = $null
            $password2 = $null

            if (-not $match) {

                Write-Warn `
                    'Passwords do not match.'
            }

        }
        while (-not $match)

        Write-OK `
            "Linux username: $LinuxUsername"

        Write-OK `
            'Linux password accepted.'
    }


    # ============================================================
    # WINDOWS FEATURES
    # ============================================================

    Write-Step `
        'Checking WSL Windows features'

    $WSLFeature =
        Get-WindowsOptionalFeature `
            -Online `
            -FeatureName `
                Microsoft-Windows-Subsystem-Linux

    $VMFeature =
        Get-WindowsOptionalFeature `
            -Online `
            -FeatureName `
                VirtualMachinePlatform

    Write-Host ''
    Write-Host `
        "    WSL               : $($WSLFeature.State)"

    Write-Host `
        "    Virtual Machine   : $($VMFeature.State)"


    if (
        $WSLFeature.State -ne 'Enabled'
    ) {

        Enable-WindowsFeatureSafe `
            -FeatureName `
                'Microsoft-Windows-Subsystem-Linux'
    }
    else {

        Write-OK `
            'Windows Subsystem for Linux already enabled.'
    }


    if (
        $VMFeature.State -ne 'Enabled'
    ) {

        Enable-WindowsFeatureSafe `
            -FeatureName `
                'VirtualMachinePlatform'
    }
    else {

        Write-OK `
            'Virtual Machine Platform already enabled.'
    }


    # ============================================================
    # HYPERVISOR
    # ============================================================

    Ensure-HypervisorLaunch


    # ============================================================
    # REBOOT
    # ============================================================

    if (
        $script:RebootRequired -or
        (Test-WindowsRebootRequired)
    ) {

        Restart-AndResume
    }


    # ============================================================
    # WSL UPDATE
    # ============================================================

    Update-WSL


    if ($script:RebootRequired) {

        Restart-AndResume
    }


    # ============================================================
    # WSL 2 DEFAULT
    # ============================================================

    Write-Step `
        'Configuring WSL 2'

    & wsl.exe `
        --set-default-version `
        2

    if ($LASTEXITCODE -ne 0) {

        Write-Warn `
            'Initial WSL 2 configuration failed.'

        Update-WSL

        if ($script:RebootRequired) {

            Restart-AndResume
        }

        & wsl.exe `
            --set-default-version `
            2

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Unable to configure WSL 2 as the default version.'
        }
    }

    Write-OK `
        'WSL 2 configured as the default version.'


    # ============================================================
    # CLOUD INIT
    # ============================================================

    $UbuntuExists =
        Test-WSLDistro `
            $DistroName

    if (-not $UbuntuExists) {

        Write-Step `
            'Preparing unattended Ubuntu provisioning'

        New-CloudInit `
            -Username $LinuxUsername
    }


    # ============================================================
    # UBUNTU
    # ============================================================

    Install-Ubuntu

    Wait-ForUbuntu


    # ============================================================
    # FORCE UBUNTU WSL 2
    # ============================================================

    Write-Step `
        'Validating Ubuntu WSL version'

    $UbuntuVersion =
        Get-WSLDistroVersion `
            -Name $DistroName

    if ($UbuntuVersion -eq 1) {

        Write-Warn `
            'Ubuntu is WSL 1.'

        Write-Host `
            'Converting Ubuntu to WSL 2...'

        & wsl.exe `
            --set-version `
            $DistroName `
            2

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Failed to convert Ubuntu to WSL 2.'
        }

        Write-OK `
            'Ubuntu converted to WSL 2.'
    }
    elseif ($UbuntuVersion -eq 2) {

        Write-OK `
            'Ubuntu is already WSL 2.'
    }
    else {

        throw `
            'Unable to determine the Ubuntu WSL version.'
    }


    # ============================================================
    # START ROOT SESSION
    # ============================================================

    Write-Step `
        'Starting Ubuntu provisioning'

    & wsl.exe `
        --distribution $DistroName `
        --user root `
        --exec true

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Ubuntu could not start.'
    }


    # ============================================================
    # WAIT FOR CLOUD INIT USER
    # ============================================================

    if (-not $UbuntuExists) {

        Write-Step `
            'Waiting for Ubuntu cloud-init'

        $cloudUserReady = $false

        for ($i = 0; $i -lt 120; $i++) {

            & wsl.exe `
                --distribution $DistroName `
                --user root `
                --exec bash `
                -c `
                "id -u '$LinuxUsername' >/dev/null 2>&1" `
                2>$null

            if ($LASTEXITCODE -eq 0) {

                $cloudUserReady = $true
                break
            }

            Start-Sleep -Seconds 2
        }

        if ($cloudUserReady) {

            Write-OK `
                'Ubuntu cloud-init user provisioning completed.'
        }
        else {

            Write-Warn `
                'Cloud-init did not create the user.'

            Write-Warn `
                'Direct root provisioning will create it.'
        }
    }


    # ============================================================
    # USER CONFIGURATION
    # ============================================================

    Write-Step `
        'Configuring Linux user'

    Configure-LinuxUser `
        -Username $LinuxUsername

    Write-OK `
        "Linux user '$LinuxUsername' configured."


    # ============================================================
    # PASSWORD
    # ============================================================

    Write-Step `
        'Setting Linux password'

    Set-LinuxPassword `
        -Username $LinuxUsername `
        -Password $LinuxPassword

    Write-OK `
        'Linux password configured.'


    # ============================================================
    # RESTART WSL
    # ============================================================

    Write-Step `
        'Restarting WSL'

    & wsl.exe `
        --shutdown

    Start-Sleep -Seconds 3

    Write-OK `
        'WSL restarted.'


    # ============================================================
    # DEFAULT DISTRIBUTION
    # ============================================================

    Write-Step `
        'Setting Ubuntu as default distribution'

    & wsl.exe `
        --set-default `
        $DistroName

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Unable to set Ubuntu as the default distribution.'
    }

    Write-OK `
        'Ubuntu is the default distribution.'


    # ============================================================
    # USER VALIDATION
    # ============================================================

    Write-Step `
        'Validating default Linux user'

    $DetectedUser =
        (
            & wsl.exe `
                --distribution $DistroName `
                --exec whoami `
                2>$null |
            Select-Object -First 1
        ).ToString().Trim()

    if (
        $DetectedUser -ne
        $LinuxUsername
    ) {

        throw `
            "Default user validation failed. Expected '$LinuxUsername', got '$DetectedUser'."
    }

    Write-OK `
        "Default Linux user: $LinuxUsername"


    # ============================================================
    # WSL 2 FINAL VALIDATION
    # ============================================================

    Write-Step `
        'Performing final WSL 2 validation'

    $FinalVersion =
        Get-WSLDistroVersion `
            -Name $DistroName

    if ($FinalVersion -ne 2) {

        throw `
            "Ubuntu is not running WSL 2. Detected version: $FinalVersion"
    }

    Write-OK `
        'Ubuntu is running WSL 2.'


    # ============================================================
    # SUDO VALIDATION
    # ============================================================

    Write-Step `
        'Validating sudo'

    & wsl.exe `
        --distribution $DistroName `
        --exec sudo `
        -n `
        true `
        2>$null

    if ($LASTEXITCODE -ne 0) {

        throw `
            'sudo validation failed.'
    }

    Write-OK `
        'sudo is configured.'


    # ============================================================
    # FINAL STATUS
    # ============================================================

    Write-Step `
        'Final WSL status'

    Write-Host ''
    Write-Host `
        'WSL STATUS' `
        -ForegroundColor Cyan

    Write-Host `
        '----------'

    & wsl.exe `
        --status

    Write-Host ''
    Write-Host `
        'DISTRIBUTIONS' `
        -ForegroundColor Cyan

    Write-Host `
        '-------------'

    & wsl.exe `
        --list `
        --verbose

    Write-Host ''
    Write-Host `
        'WSL VERSION' `
        -ForegroundColor Cyan

    Write-Host `
        '-----------'

    & wsl.exe `
        --version


    # ============================================================
    # CLEANUP
    # ============================================================

    Write-Step `
        'Cleaning temporary installer data'

    Remove-CloudInit

    Remove-ResumeTask


    Remove-Item `
        $StateFile `
        -Force `
        -ErrorAction SilentlyContinue

    Remove-Item `
        $PasswordFile `
        -Force `
        -ErrorAction SilentlyContinue

    Remove-Item `
        $InstallerFile `
        -Force `
        -ErrorAction SilentlyContinue


    try {
    if (
        (Test-Path $StateRoot) -and
        (
            @(
                Get-ChildItem `
                    $StateRoot `
                    -Force `
                    -ErrorAction SilentlyContinue
            ).Count -eq 0
        )
    ) {

        Remove-Item `
            $StateRoot `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
catch {
}


    # ============================================================
    # SUCCESS
    # ============================================================

    Write-Host ''
    Write-Host `
        '============================================================' `
        -ForegroundColor Green

    Write-Host `
        '              INSTALLATION COMPLETE' `
        -ForegroundColor Green

    Write-Host `
        '============================================================' `
        -ForegroundColor Green

    Write-Host ''

    Write-Host `
        "Distribution : $DistroName"

    Write-Host `
        'WSL Version  : 2'

    Write-Host `
        "Linux User   : $LinuxUsername"

    Write-Host ''

    Write-Host `
        'Launch Ubuntu:' `
        -ForegroundColor Cyan

    Write-Host ''
    Write-Host `
        '    wsl'

    Write-Host ''

    Write-Host `
        'Verify:' `
        -ForegroundColor Cyan

    Write-Host ''
    Write-Host `
        '    wsl -l -v'

    Write-Host `
        '    wsl --status'

    Write-Host ''

    exit 0
}
catch {

    Write-Host ''
    Write-Host `
        '============================================================' `
        -ForegroundColor Red

    Write-Host `
        '              INSTALLATION FAILED' `
        -ForegroundColor Red

    Write-Host `
        '============================================================' `
        -ForegroundColor Red

    Write-Host ''

    Write-Fail `
        $_.Exception.Message

    Write-Host ''

    Write-Host `
        'Diagnostics:' `
        -ForegroundColor Yellow

    Write-Host ''
    Write-Host `
        '    wsl --status'

    Write-Host `
        '    wsl --version'

    Write-Host `
        '    wsl -l -v'

    Write-Host ''

    Write-Warn `
        'The installer can be run again safely.'

    Write-Host ''

    exit 1
}
