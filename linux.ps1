#requires -Version 5.1

<#
.SYNOPSIS
    Production-oriented WSL 2 + Ubuntu LTS bootstrap installer.

.DESCRIPTION
    - NO command-line arguments required.
    - Automatically requests Administrator elevation.
    - Works when launched normally or through:
        irm <raw-github-url> | iex
    - Prompts for Linux username and password.
    - Enables WSL and Virtual Machine Platform.
    - Correctly handles DISM 3010 / 1641 reboot codes.
    - Automatically resumes after Windows reboot.
    - Updates the modern WSL runtime.
    - Falls back to the latest official Microsoft WSL MSI.
    - Sets WSL 2 as the default.
    - Installs the current Ubuntu LTS.
    - Uses Ubuntu cloud-init for unattended first boot.
    - Falls back to direct root provisioning if cloud-init fails.
    - Creates/configures the requested Linux user.
    - Configures sudo.
    - Sets the requested user as the default WSL user.
    - Converts an existing Ubuntu installation to WSL 2 if necessary.
    - Verifies the final installation.
    - Cleans temporary credentials and provisioning files.

.NOTES
    Intended for Windows 10 2004 / build 19041+
    or Windows 11.
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ================================================================
# CONFIGURATION
# ================================================================

$DistroName = 'Ubuntu'

# Used when the script is launched through IEX:
# irm <URL> | iex
$SelfUrl = 'https://raw.githubusercontent.com/paman7647/Windows-Tools/main/linux.ps1'

# Persistent state used only when Windows must reboot.
$StateRoot = Join-Path `
    $env:ProgramData `
    'WSL2-Ubuntu-Installer'

$StateFile = Join-Path `
    $StateRoot `
    'state.json'

$PasswordFile = Join-Path `
    $StateRoot `
    'password.dat'

$ResumeScript = Join-Path `
    $StateRoot `
    'linux.ps1'

$ResumeTask = `
    'WSL2-Ubuntu-Installer-Resume'

# Ubuntu cloud-init location.
$CloudInitDir = Join-Path `
    $env:USERPROFILE `
    '.cloud-init'

$CloudInitFile = Join-Path `
    $CloudInitDir `
    "$DistroName.user-data"

$RebootRequired = $false


# ================================================================
# OUTPUT HELPERS
# ================================================================

function Write-Step {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-OK {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}


# ================================================================
# ADMINISTRATOR CHECK
# ================================================================

function Test-Admin {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object `
        Security.Principal.WindowsPrincipal(
            $identity
        )

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}


function Get-PowerShellExe {

    if ($PSVersionTable.PSEdition -eq 'Core') {

        $command = Get-Command `
            pwsh.exe `
            -ErrorAction SilentlyContinue

        if ($command) {
            return $command.Source
        }
    }

    $command = Get-Command `
        powershell.exe `
        -ErrorAction Stop

    return $command.Source
}


# ================================================================
# AUTOMATIC ELEVATION
# ================================================================

if (-not (Test-Admin)) {

    Write-Host ''
    Write-Host `
        'Administrator privileges are required.' `
        -ForegroundColor Yellow

    Write-Host `
        'Requesting elevation...' `
        -ForegroundColor Cyan

    Write-Host ''

    $PowerShellExe = Get-PowerShellExe

    $ScriptPath = $PSCommandPath
    $TemporaryScript = $null

    # ------------------------------------------------------------
    # Normal .PS1 execution
    # ------------------------------------------------------------

    if (
        [string]::IsNullOrWhiteSpace($ScriptPath) -or
        -not (Test-Path $ScriptPath)
    ) {

        # --------------------------------------------------------
        # IEX execution:
        # irm URL | iex
        #
        # IEX does not provide $PSCommandPath.
        # Download the trusted script to TEMP and elevate that.
        # --------------------------------------------------------

        $TemporaryScript = Join-Path `
            $env:TEMP `
            (
                'wsl-bootstrap-' +
                [guid]::NewGuid().ToString('N') +
                '.ps1'
            )

        try {

            Invoke-WebRequest `
                -Uri $SelfUrl `
                -OutFile $TemporaryScript `
                -UseBasicParsing

            $ScriptPath = $TemporaryScript
        }
        catch {

            Write-Fail `
                "Could not download installer for elevation: $($_.Exception.Message)"

            exit 1
        }
    }

    try {

        $Arguments =
            "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

        $process = Start-Process `
            -FilePath $PowerShellExe `
            -ArgumentList $Arguments `
            -Verb RunAs `
            -Wait `
            -PassThru

        if ($process.ExitCode -ne 0) {
            exit $process.ExitCode
        }
    }
    catch {

        Write-Fail `
            'Administrator elevation was cancelled or failed.'

        exit 1
    }
    finally {

        if (
            $TemporaryScript -and
            (Test-Path $TemporaryScript)
        ) {

            Remove-Item `
                $TemporaryScript `
                -Force `
                -ErrorAction SilentlyContinue
        }
    }

    exit 0
}


# ================================================================
# STATE MANAGEMENT
# ================================================================

function Ensure-StateRoot {

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
        [Parameter(Mandatory)]
        [string]$Username
    )

    Ensure-StateRoot

    @{
        Username = $Username
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

        return Get-Content `
            -Path $StateFile `
            -Raw |
            ConvertFrom-Json
    }
    catch {

        return $null
    }
}


function Save-Password {

    param(
        [Parameter(Mandatory)]
        [Security.SecureString]$Password
    )

    Ensure-StateRoot

    # DPAPI encryption.
    # Protected for the current Windows user.
    ConvertFrom-SecureString `
        $Password |
        Set-Content `
            -Path $PasswordFile `
            -Encoding UTF8
}


function Get-SavedPassword {

    if (-not (Test-Path $PasswordFile)) {
        return $null
    }

    try {

        $encrypted = Get-Content `
            -Path $PasswordFile `
            -Raw

        return ConvertTo-SecureString `
            $encrypted
    }
    catch {

        return $null
    }
}


# ================================================================
# REBOOT RESUME TASK
# ================================================================

function Remove-ResumeTask {

    try {

        Unregister-ScheduledTask `
            -TaskName $ResumeTask `
            -Confirm:$false `
            -ErrorAction SilentlyContinue
    }
    catch {
    }
}


function Register-ResumeTask {

    Ensure-StateRoot

    $source = $PSCommandPath

    if (
        [string]::IsNullOrWhiteSpace($source) -or
        -not (Test-Path $source)
    ) {

        throw `
            'Cannot determine installer path for reboot resume.'
    }

    Copy-Item `
        -Path $source `
        -Destination $ResumeScript `
        -Force

    $PowerShellExe = Get-PowerShellExe

    $action = New-ScheduledTaskAction `
        -Execute $PowerShellExe `
        -Argument `
        "-NoProfile -ExecutionPolicy Bypass -File `"$ResumeScript`""

    $trigger = New-ScheduledTaskTrigger `
        -AtLogOn

    $identity = `
        [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-ScheduledTaskPrincipal `
        -UserId $identity.Name `
        -LogonType Interactive `
        -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -ExecutionTimeLimit (
            New-TimeSpan -Hours 2
        )

    Register-ScheduledTask `
        -TaskName $ResumeTask `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Force |
        Out-Null

    Write-OK `
        'Automatic reboot-resume task created.'
}


function Restart-AndResume {

    Register-ResumeTask

    Write-Host ''
    Write-Warn `
        'Windows restart required.'

    Write-Host `
        'The installation will automatically resume after sign-in.' `
        -ForegroundColor Yellow

    Write-Host ''
    Write-Host `
        'Restarting Windows in 5 seconds...' `
        -ForegroundColor Yellow

    Start-Sleep -Seconds 5

    Restart-Computer -Force

    exit
}


# ================================================================
# REBOOT DETECTION
# ================================================================

function Test-RebootRequired {

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

        $pending = Get-ItemProperty `
            'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
            -Name PendingFileRenameOperations `
            -ErrorAction SilentlyContinue

        if (
            $null -ne
            $pending.PendingFileRenameOperations
        ) {

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

function Enable-Feature {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Step `
        "Enabling $Name"

    # ------------------------------------------------------------
    # Preferred PowerShell/DISM API
    # ------------------------------------------------------------

    try {

        $result = Enable-WindowsOptionalFeature `
            -Online `
            -FeatureName $Name `
            -All `
            -NoRestart `
            -ErrorAction Stop

        if ($result.RestartNeeded) {

            $script:RebootRequired = $true

            Write-OK `
                "$Name enabled. Restart required."
        }
        else {

            Write-OK `
                "$Name enabled."
        }

        return
    }
    catch {

        Write-Warn `
            'PowerShell feature API failed.'

        Write-Warn `
            'Falling back to DISM.'
    }

    # ------------------------------------------------------------
    # DISM fallback
    #
    # IMPORTANT:
    # 0    = success
    # 3010 = success, reboot required
    # 1641 = success, restart initiated/required
    # ------------------------------------------------------------

    & dism.exe `
        /online `
        /enable-feature `
        "/featurename:$Name" `
        /all `
        /norestart

    $code = $LASTEXITCODE

    if (
        $code -notin @(0, 3010, 1641)
    ) {

        throw `
            "Failed to enable $Name. DISM exit code: $code"
    }

    if (
        $code -in @(3010, 1641)
    ) {

        $script:RebootRequired = $true

        Write-OK `
            "$Name enabled. Restart required."
    }
    else {

        Write-OK `
            "$Name enabled."
    }
}


# ================================================================
# WSL DISTRIBUTION FUNCTIONS
# ================================================================

function Get-WSLDistros {

    try {

        $output = & wsl.exe `
            --list `
            --quiet `
            2>$null

        if ($LASTEXITCODE -ne 0) {
            return @()
        }

        return @(
            $output |
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


function Test-Distro {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return (
        @(
            Get-WSLDistros |
            Where-Object {
                $_ -ieq $Name
            }
        ).Count -gt 0
    )
}


function Get-WSLVersion {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {

        $output = & wsl.exe `
            --list `
            --verbose `
            2>$null

        foreach ($line in $output) {

            $text = $line.ToString()

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


function Invoke-Wsl {

    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    & wsl.exe @Arguments

    if ($LASTEXITCODE -ne 0) {

        throw `
            "wsl.exe failed with exit code $LASTEXITCODE."
    }
}


# ================================================================
# SECURE STRING
# ================================================================

function Get-PlainText {

    param(
        [Parameter(Mandatory)]
        [Security.SecureString]$SecureString
    )

    $ptr =
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR(
            $SecureString
        )

    try {

        return `
            [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
                $ptr
            )
    }
    finally {

        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
            $ptr
        )
    }
}


# ================================================================
# USERNAME VALIDATION
# ================================================================

function Test-LinuxUsername {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (
        $Name -notmatch `
        '^[a-z_][a-z0-9_-]{0,31}$'
    ) {

        return $false
    }

    if ($Name -eq 'root') {
        return $false
    }

    return $true
}


# ================================================================
# CLOUD-INIT
# ================================================================

function Prepare-CloudInit {

    param(
        [Parameter(Mandatory)]
        [string]$Username
    )

    if (-not (Test-Path $CloudInitDir)) {

        New-Item `
            -ItemType Directory `
            -Path $CloudInitDir `
            -Force |
            Out-Null
    }

    $config = @"
#cloud-config

users:
  - default
  - name: $Username
    gecos: $Username
    groups: [adm, sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false

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

final_message: "WSL provisioning complete."
"@

    Set-Content `
        -Path $CloudInitFile `
        -Value $config `
        -Encoding UTF8
}


function Remove-CloudInit {

    if (Test-Path $CloudInitFile) {

        Remove-Item `
            -Path $CloudInitFile `
            -Force `
            -ErrorAction SilentlyContinue
    }
}


# ================================================================
# LINUX USER CONFIGURATION
# ================================================================

function Ensure-LinuxUser {

    param(
        [Parameter(Mandatory)]
        [string]$Username
    )

    $safe = $Username.Replace(
        "'",
        "'\''"
    )

    $linuxScript = @"
set -e

u='$safe'

if ! id -u "`$u" >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --user-group "`$u"
fi

usermod -aG sudo "`$u"

mkdir -p /etc/sudoers.d

printf '%s\n' \
    "`$u ALL=(ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/90-`$u"

chmod 0440 "/etc/sudoers.d/90-`$u"

mkdir -p "/home/`$u"

chown -R "`$u:`$u" \
    "/home/`$u"

touch "/home/`$u/.hushlogin"

cat > /etc/wsl.conf <<EOF
[user]
default=`$u

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
        -c $linuxScript

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Failed to create/configure the Linux user.'
    }
}


# ================================================================
# LINUX PASSWORD
# ================================================================

function Set-UbuntuPassword {

    param(
        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter(Mandatory)]
        [Security.SecureString]$SecurePassword
    )

    $plain = Get-PlainText `
        $SecurePassword

    try {

        # Password is passed through stdin instead of the command line.
        $line = "$Username`:$plain"

        $line |
            & wsl.exe `
                --distribution $DistroName `
                --user root `
                --exec chpasswd

        if ($LASTEXITCODE -ne 0) {

            throw `
                "Linux password configuration failed with exit code $LASTEXITCODE."
        }
    }
    finally {

        $plain = $null
        $line = $null
    }
}


# ================================================================
# UPDATE WSL RUNTIME
# ================================================================

function Update-WSLRuntime {

    Write-Step `
        'Updating WSL runtime'

    $success = $false

    # ------------------------------------------------------------
    # Modern preferred path
    # ------------------------------------------------------------

    try {

        & wsl.exe `
            --update `
            --web-download

        if ($LASTEXITCODE -eq 0) {

            $success = $true
        }
    }
    catch {
    }

    if ($success) {

        Write-OK `
            'WSL runtime updated.'

        return
    }

    # ------------------------------------------------------------
    # Standard update
    # ------------------------------------------------------------

    Write-Warn `
        'web-download update did not complete.'

    Write-Host `
        'Trying standard WSL update...'

    try {

        & wsl.exe `
            --update

        if ($LASTEXITCODE -eq 0) {

            $success = $true
        }
    }
    catch {
    }

    if ($success) {

        Write-OK `
            'WSL runtime updated.'

        return
    }

    # ------------------------------------------------------------
    # Current official Microsoft WSL MSI
    #
    # Uses:
    # https://api.github.com/repos/microsoft/WSL/releases/latest
    # ------------------------------------------------------------

    Write-Warn `
        'WSL update did not complete.'

    Write-Host `
        'Downloading the latest official Microsoft WSL release...'

    $apiUrl =
        'https://api.github.com/repos/microsoft/WSL/releases/latest'

    $headers = @{
        'User-Agent' = 'WSL2-Ubuntu-Installer'
    }

    $release = Invoke-RestMethod `
        -Uri $apiUrl `
        -Headers $headers `
        -UseBasicParsing

    $architecture =
        $env:PROCESSOR_ARCHITECTURE

    if ($architecture -eq 'AMD64') {

        $pattern = '\.x64\.msi$'
    }
    elseif ($architecture -eq 'ARM64') {

        $pattern = '\.arm64\.msi$'
    }
    else {

        throw `
            "Unsupported processor architecture: $architecture"
    }

    $asset = @(
        $release.assets |
        Where-Object {
            $_.name -match $pattern
        } |
        Select-Object -First 1
    )

    if ($asset.Count -eq 0) {

        throw `
            'Could not find a matching WSL MSI in the latest Microsoft release.'
    }

    $msiPath = Join-Path `
        $env:TEMP `
        $asset[0].name

    Write-Host `
        "    WSL release: $($release.tag_name)"

    Write-Host `
        "    Package: $($asset[0].name)"

    Invoke-WebRequest `
        -Uri $asset[0].browser_download_url `
        -OutFile $msiPath `
        -UseBasicParsing

    $process = Start-Process `
        -FilePath msiexec.exe `
        -ArgumentList `
        "/i `"$msiPath`" /qn /norestart" `
        -Wait `
        -PassThru

    $exitCode = $process.ExitCode

    Remove-Item `
        $msiPath `
        -Force `
        -ErrorAction SilentlyContinue

    if ($exitCode -notin @(0, 3010)) {

        throw `
            "Latest WSL MSI installation failed with exit code $exitCode."
    }

    if ($exitCode -eq 3010) {

        $script:RebootRequired = $true
    }

    Write-OK `
        "WSL runtime $($release.tag_name) installed."
}


# ================================================================
# UBUNTU INSTALLATION
# ================================================================

function Install-Ubuntu {

    if (Test-Distro $DistroName) {

        Write-OK `
            'Ubuntu is already installed.'

        return
    }

    Write-Step `
        'Installing current Ubuntu LTS'

    Write-Host ''
    Write-Host `
        'Downloading Ubuntu through WSL...' `
        -ForegroundColor Cyan

    # ------------------------------------------------------------
    # Preferred modern installation.
    #
    # --no-launch is important because cloud-init must see the
    # distro before interactive first-run setup.
    # ------------------------------------------------------------

    $output = @(
        & wsl.exe `
            --install `
            --distribution $DistroName `
            --web-download `
            --no-launch `
            2>&1
    )

    $code = $LASTEXITCODE

    # Give registration a moment.
    for ($wait = 0; $wait -lt 15; $wait++) {

        if (Test-Distro $DistroName) {

            Write-OK `
                'Ubuntu installed.'

            return
        }

        Start-Sleep -Seconds 1
    }

    # ------------------------------------------------------------
    # Verified .wsl image fallback
    #
    # Uses Microsoft's official WSL DistributionInfo.json.
    # ------------------------------------------------------------

    Write-Warn `
        "Standard Ubuntu installation did not complete (exit code $code)."

    Write-Host `
        'Trying the current verified Ubuntu WSL image...'

    $manifestUrl =
        'https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json'

    $manifest = Invoke-RestMethod `
        -Uri $manifestUrl `
        -UseBasicParsing

    $entry = @(
        $manifest.ModernDistributions.Ubuntu |
        Where-Object {
            $_.Name -eq 'Ubuntu'
        } |
        Select-Object -First 1
    )

    if ($entry.Count -eq 0) {

        throw `
            'Current Ubuntu entry was not found in the Microsoft WSL distribution manifest.'
    }

    $architecture =
        $env:PROCESSOR_ARCHITECTURE

    if ($architecture -eq 'AMD64') {

        $urlInfo = $entry[0].Amd64Url
    }
    elseif ($architecture -eq 'ARM64') {

        $urlInfo = $entry[0].Arm64Url
    }
    else {

        throw `
            "Unsupported processor architecture: $architecture"
    }

    $ubuntuFile = Join-Path `
        $env:TEMP `
        'ubuntu-latest.wsl'

    Write-Host `
        "    Download: $($urlInfo.Url)"

    Invoke-WebRequest `
        -Uri $urlInfo.Url `
        -OutFile $ubuntuFile `
        -UseBasicParsing

    Write-Host `
        '    Verifying SHA-256...'

    $actualHash = (
        Get-FileHash `
            -Path $ubuntuFile `
            -Algorithm SHA256
    ).Hash

    if (
        $actualHash.ToUpperInvariant() -ne
        $urlInfo.Sha256.ToUpperInvariant()
    ) {

        Remove-Item `
            $ubuntuFile `
            -Force `
            -ErrorAction SilentlyContinue

        throw `
            'Ubuntu WSL image SHA-256 verification failed.'
    }

    Write-OK `
        'Ubuntu image SHA-256 verified.'

    & wsl.exe `
        --install `
        --from-file $ubuntuFile `
        --no-launch

    $code = $LASTEXITCODE

    Remove-Item `
        $ubuntuFile `
        -Force `
        -ErrorAction SilentlyContinue

    if (
        $code -ne 0 -or
        -not (Test-Distro $DistroName)
    ) {

        throw `
            "Ubuntu installation from verified WSL image failed. Exit code: $code"
    }

    Write-OK `
        'Verified Ubuntu WSL image installed.'
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
    # WINDOWS COMPATIBILITY
    # ============================================================

    Write-Step `
        'Checking Windows compatibility'

    $OS = Get-CimInstance `
        Win32_OperatingSystem

    $Build = [int]$OS.BuildNumber

    Write-Host `
        "    Operating System : $($OS.Caption)"

    Write-Host `
        "    Build            : $Build"

    Write-Host `
        "    Architecture     : $env:PROCESSOR_ARCHITECTURE"

    if ($Build -lt 19041) {

        throw `
            "Windows build $Build is too old. Windows 10 2004/build 19041+ or Windows 11 is required."
    }

    Write-OK `
        'Supported Windows version detected.'


    # ============================================================
    # LINUX CREDENTIALS
    # ============================================================

    $state = Get-State

    if ($null -ne $state) {

        $LinuxUsername =
            $state.Username

        $LinuxPasswordSecure =
            Get-SavedPassword

        if ($null -ne $LinuxPasswordSecure) {

            Write-OK `
                "Resuming installation for Linux user '$LinuxUsername'."
        }
        else {

            Write-Warn `
                'Saved password could not be recovered.'

            $LinuxPasswordSecure =
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
            'Choose the Linux username and password for Ubuntu.'

        Write-Host ''
        Write-Host `
            'Press Enter for the default username: dev'

        Write-Host ''

        do {

            $LinuxUsername =
                Read-Host `
                    'Linux username [dev]'

            if (
                [string]::IsNullOrWhiteSpace(
                    $LinuxUsername
                )
            ) {

                $LinuxUsername = 'dev'
            }

            if (
                -not (
                    Test-LinuxUsername `
                        $LinuxUsername
                )
            ) {

                Write-Warn `
                    'Invalid Linux username.'

                Write-Warn `
                    'Use 1-32 lowercase letters, numbers, _ or -.'

                $LinuxUsername = $null
            }

        }
        while (
            [string]::IsNullOrWhiteSpace(
                $LinuxUsername
            )
        )


        do {

            $LinuxPasswordSecure =
                Read-Host `
                    'Linux password' `
                    -AsSecureString

            $ConfirmPassword =
                Read-Host `
                    'Confirm Linux password' `
                    -AsSecureString

            $password1 =
                Get-PlainText `
                    $LinuxPasswordSecure

            $password2 =
                Get-PlainText `
                    $ConfirmPassword

            $match =
                (
                    $password1 -eq $password2 -and
                    $password1.Length -gt 0
                )

            $password1 = $null
            $password2 = $null

            if (-not $match) {

                Write-Warn `
                    'Passwords do not match or are empty.'
            }

        }
        while (-not $match)


        Save-State `
            $LinuxUsername

        Save-Password `
            $LinuxPasswordSecure

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
            -FeatureName Microsoft-Windows-Subsystem-Linux

    $VMFeature =
        Get-WindowsOptionalFeature `
            -Online `
            -FeatureName VirtualMachinePlatform

    Write-Host ''
    Write-Host `
        "    WSL                    : $($WSLFeature.State)"

    Write-Host `
        "    Virtual Machine        : $($VMFeature.State)"


    if (
        $WSLFeature.State -ne 'Enabled'
    ) {

        Enable-Feature `
            'Microsoft-Windows-Subsystem-Linux'
    }
    else {

        Write-OK `
            'Windows Subsystem for Linux already enabled.'
    }


    if (
        $VMFeature.State -ne 'Enabled'
    ) {

        Enable-Feature `
            'VirtualMachinePlatform'
    }
    else {

        Write-OK `
            'Virtual Machine Platform already enabled.'
    }


    # ============================================================
    # REBOOT IF WINDOWS FEATURES REQUIRE IT
    # ============================================================

    if (
        $RebootRequired -or
        (Test-RebootRequired)
    ) {

        Restart-AndResume
    }


    # ============================================================
    # UPDATE WSL
    # ============================================================

    Update-WSLRuntime


    if ($RebootRequired) {

        Restart-AndResume
    }


    # ============================================================
    # WSL 2 DEFAULT
    # ============================================================

    Write-Step `
        'Setting WSL 2 as the default version'

    & wsl.exe `
        --set-default-version `
        2

    if ($LASTEXITCODE -ne 0) {

        Write-Warn `
            'WSL 2 default configuration failed.'

        Write-Host `
            'Repairing/updating the WSL runtime...'

        Update-WSLRuntime

        if ($RebootRequired) {

            Restart-AndResume
        }

        & wsl.exe `
            --set-default-version `
            2

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Unable to set WSL 2 as the default version.'
        }
    }

    Write-OK `
        'WSL 2 is the default version.'


    # ============================================================
    # UBUNTU INSIGHTS CONSENT
    #
    # Ubuntu 26.04 can show a first-run data-collection prompt.
    # Temporarily set the user's existing preference to opt-out.
    # The original value is restored during cleanup.
    # ============================================================

    $ConsentKey =
        'HKCU:\Software\Canonical\Ubuntu'

    $HadConsentKey =
        Test-Path $ConsentKey

    $OldConsentExists = $false
    $OldConsent = $null

    if ($HadConsentKey) {

        try {

            $OldConsent =
                Get-ItemPropertyValue `
                    -Path $ConsentKey `
                    -Name UbuntuInsightsConsent `
                    -ErrorAction Stop

            $OldConsentExists = $true
        }
        catch {
        }
    }
    else {

        New-Item `
            -Path $ConsentKey `
            -Force |
            Out-Null
    }

    New-ItemProperty `
        -Path $ConsentKey `
        -Name UbuntuInsightsConsent `
        -PropertyType DWord `
        -Value 0 `
        -Force |
        Out-Null


    # ============================================================
    # DETECT EXISTING UBUNTU
    # ============================================================

    $UbuntuAlreadyInstalled =
        Test-Distro $DistroName


    # ============================================================
    # CLOUD-INIT FOR NEW UBUNTU
    # ============================================================

    if (-not $UbuntuAlreadyInstalled) {

        Write-Step `
            'Preparing Ubuntu cloud-init'

        Prepare-CloudInit `
            $LinuxUsername

        Write-OK `
            'Ubuntu cloud-init configuration prepared.'
    }


    # ============================================================
    # INSTALL UBUNTU
    # ============================================================

    Install-Ubuntu


    # ============================================================
    # WAIT FOR REGISTRATION
    # ============================================================

    Write-Step `
        'Waiting for Ubuntu registration'

    $registered = $false

    for ($i = 0; $i -lt 60; $i++) {

        if (
            Test-Distro `
                $DistroName
        ) {

            $registered = $true
            break
        }

        Start-Sleep `
            -Seconds 2
    }

    if (-not $registered) {

        throw `
            'Ubuntu did not register with WSL.'
    }

    Write-OK `
        'Ubuntu registration confirmed.'


    # ============================================================
    # FORCE UBUNTU WSL 2
    # ============================================================

    Write-Step `
        'Validating Ubuntu WSL version'

    $version =
        Get-WSLVersion `
            $DistroName

    if ($version -eq 1) {

        Write-Warn `
            'Ubuntu is currently WSL 1.'

        Write-Host `
            'Converting Ubuntu to WSL 2...'

        Invoke-Wsl @(
            '--set-version'
            $DistroName
            '2'
        )

        Write-OK `
            'Ubuntu converted to WSL 2.'
    }
    elseif ($version -eq 2) {

        Write-OK `
            'Ubuntu is already WSL 2.'
    }
    else {

        & wsl.exe `
            --set-version `
            $DistroName `
            2

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Could not configure Ubuntu as WSL 2.'
        }
    }


    # ============================================================
    # START UBUNTU AS ROOT
    # ============================================================

    Write-Step `
        'Starting Ubuntu provisioning'

    & wsl.exe `
        --distribution $DistroName `
        --user root `
        --exec true

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Ubuntu could not be started. Verify that CPU virtualization is enabled in UEFI/BIOS.'
    }

    Write-OK `
        'Ubuntu started.'


    # ============================================================
    # CLOUD-INIT WAIT
    # ============================================================

    $CloudInitComplete = $false

    if (-not $UbuntuAlreadyInstalled) {

        Write-Step `
            'Waiting for Ubuntu cloud-init'

        for ($i = 0; $i -lt 120; $i++) {

            & wsl.exe `
                --distribution $DistroName `
                --user root `
                --exec bash `
                -c `
                'test -f /var/lib/cloud/instance/boot-finished' `
                2>$null

            if ($LASTEXITCODE -eq 0) {

                $CloudInitComplete = $true
                break
            }

            Start-Sleep `
                -Seconds 2
        }

        if ($CloudInitComplete) {

            Write-OK `
                'Ubuntu cloud-init completed.'
        }
        else {

            Write-Warn `
                'Cloud-init did not report completion.'

            Write-Warn `
                'Using direct root provisioning fallback.'
        }
    }


    # ============================================================
    # DIRECT USER CONFIGURATION
    #
    # Even when cloud-init succeeds, this is intentionally
    # re-applied to make the script idempotent.
    # ============================================================

    Write-Step `
        'Configuring Linux user'

    Ensure-LinuxUser `
        $LinuxUsername

    Write-OK `
        "Linux user '$LinuxUsername' configured."


    # ============================================================
    # SET PASSWORD
    # ============================================================

    Write-Step `
        'Setting Linux password'

    Set-UbuntuPassword `
        -Username $LinuxUsername `
        -SecurePassword $LinuxPasswordSecure

    Write-OK `
        'Linux password configured.'


    # ============================================================
    # RESTART WSL
    # ============================================================

    Write-Step `
        'Restarting WSL environment'

    & wsl.exe `
        --shutdown

    Start-Sleep `
        -Seconds 3

    Write-OK `
        'WSL environment restarted.'


    # ============================================================
    # DEFAULT DISTRO
    # ============================================================

    Write-Step `
        'Setting Ubuntu as the default distribution'

    & wsl.exe `
        --set-default `
        $DistroName

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Failed to set Ubuntu as the default WSL distribution.'
    }

    Write-OK `
        'Ubuntu is now the default distribution.'


    # ============================================================
    # DEFAULT USER VALIDATION
    # ============================================================

    Write-Step `
        'Validating default Linux user'

    $DetectedUser = (
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
        Get-WSLVersion `
            $DistroName

    if ($FinalVersion -ne 2) {

        throw `
            "Final WSL 2 validation failed. Detected version: $FinalVersion."
    }

    Write-OK `
        'Ubuntu is running on WSL 2.'


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
            'sudo/NOPASSWD validation failed.'
    }

    Write-OK `
        'sudo is configured correctly.'


    # ============================================================
    # FINAL WSL STATUS
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
        'Cleaning temporary setup data'

    Remove-CloudInit


    # Restore Ubuntu Insights preference.
    if ($OldConsentExists) {

        New-ItemProperty `
            -Path $ConsentKey `
            -Name UbuntuInsightsConsent `
            -PropertyType DWord `
            -Value $OldConsent `
            -Force |
            Out-Null
    }
    elseif (-not $HadConsentKey) {

        Remove-ItemProperty `
            -Path $ConsentKey `
            -Name UbuntuInsightsConsent `
            -ErrorAction SilentlyContinue

        try {

            if (
                (Get-Item $ConsentKey).Property.Count -eq 0
            ) {

                Remove-Item `
                    $ConsentKey `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }
        catch {
        }
    }


    Remove-ResumeTask


    Remove-Item `
        $StateFile,
        $PasswordFile,
        $ResumeScript `
        -Force `
        -ErrorAction SilentlyContinue


    try {

        if (
            (Get-ChildItem `
                $StateRoot `
                -Force `
                -ErrorAction SilentlyContinue
            ).Count -eq 0
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
        "Ubuntu      : $DistroName"

    Write-Host `
        'WSL         : 2'

    Write-Host `
        "Linux user  : $LinuxUsername"

    Write-Host ''

    Write-Host `
        'Start Ubuntu:' `
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

    Write-Host `
        'The installer can safely be run again.' `
        -ForegroundColor Yellow

    Write-Host ''

    exit 1
}
