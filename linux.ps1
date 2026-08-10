

<#
    WSL 2 + Ubuntu 26.04 LTS Automated Installer

    FEATURES
    --------
    - No command-line arguments
    - Automatically requests Administrator elevation
    - Starts installation immediately
    - Prompts for Linux username/password
    - Enables WSL + Virtual Machine Platform
    - Automatically handles reboot
    - Automatically resumes after reboot
    - Updates WSL
    - Forces WSL 2
    - Installs Ubuntu LTS
    - Uses Ubuntu cloud-init for unattended first-run setup
    - Creates requested Linux user
    - Sets requested user as default
    - Idempotent
    - Does not unregister existing distributions
    - Cleans temporary credentials/configuration
#>

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ================================================================
# CONFIGURATION
# ================================================================

$DistroName = 'Ubuntu'

$StateRoot     = Join-Path $env:ProgramData 'WSL2-Ubuntu-Installer'
$StateFile     = Join-Path $StateRoot 'state.json'
$PasswordFile  = Join-Path $StateRoot 'password.dat'
$ScriptCopy    = Join-Path $StateRoot 'Install-WSL2-Ubuntu.ps1'

$ResumeTask   = 'WSL2-Ubuntu-Installer-Resume'

$CloudInitDir  = Join-Path $env:USERPROFILE '.cloud-init'
$CloudInitFile = Join-Path $CloudInitDir "$DistroName.user-data"

# ================================================================
# FUNCTIONS
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

function Test-Admin {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

# ================================================================
# AUTOMATIC ADMIN ELEVATION
# ================================================================

if (-not (Test-Admin)) {

    if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {

        Write-Fail 'The script must be saved as a .ps1 file before running.'
        Write-Host ''
        Write-Host 'Save this script as: Install-WSL2-Ubuntu.ps1'
        Write-Host ''
        exit 1
    }

    Write-Host ''
    Write-Host 'Administrator privileges are required.' -ForegroundColor Yellow
    Write-Host 'Requesting elevation...' -ForegroundColor Cyan
    Write-Host ''

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $PowerShellExe = (Get-Command pwsh.exe).Source
    }
    else {
        $PowerShellExe = (Get-Command powershell.exe).Source
    }

    $arguments = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        $PSCommandPath
    )

    try {

        Start-Process `
            -FilePath $PowerShellExe `
            -ArgumentList $arguments `
            -Verb RunAs

        exit 0
    }
    catch {

        Write-Fail 'Administrator elevation was cancelled or failed.'
        exit 1
    }
}

# ================================================================
# STATE FUNCTIONS
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
        [System.Security.SecureString]$Password
    )

    Ensure-StateDirectory

    # Windows DPAPI encryption.
    $encrypted = ConvertFrom-SecureString $Password

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

        $encrypted = Get-Content `
            -Path $PasswordFile `
            -Raw

        return ConvertTo-SecureString $encrypted
    }
    catch {

        return $null
    }
}

# ================================================================
# RESUME TASK
# ================================================================

function Register-ResumeTask {

    Ensure-StateDirectory

    if (-not $PSCommandPath) {
        throw 'Unable to determine script path.'
    }

    Copy-Item `
        -Path $PSCommandPath `
        -Destination $ScriptCopy `
        -Force

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $PowerShellExe = (Get-Command pwsh.exe).Source
    }
    else {
        $PowerShellExe = (Get-Command powershell.exe).Source
    }

    $action = New-ScheduledTaskAction `
        -Execute $PowerShellExe `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptCopy`""

    $trigger = New-ScheduledTaskTrigger `
        -AtLogOn

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-ScheduledTaskPrincipal `
        -UserId $identity.Name `
        -LogonType Interactive `
        -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Hours 2)

    Register-ScheduledTask `
        -TaskName $ResumeTask `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Force |
        Out-Null

    Write-OK 'Automatic reboot-resume task created.'
}

function Remove-ResumeTask {

    try {

        Unregister-ScheduledTask `
            -TaskName $ResumeTask `
            -Confirm:$false `
            -ErrorAction SilentlyContinue
    }
    catch {}
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

        if ($null -ne $pending.PendingFileRenameOperations) {
            return $true
        }
    }
    catch {}

    return $false
}

function Restart-AndResume {

    Write-Warn 'A Windows restart is required.'

    Register-ResumeTask

    Write-Host ''
    Write-Host 'Installation will automatically continue after reboot.' `
        -ForegroundColor Yellow

    Write-Host ''
    Write-Host 'Restarting Windows in 10 seconds...' `
        -ForegroundColor Yellow

    Start-Sleep -Seconds 10

    Restart-Computer -Force

    exit
}

# ================================================================
# WSL FUNCTIONS
# ================================================================

function Get-WSLDistros {

    try {

        $result = & wsl.exe --list --quiet 2>$null

        if ($LASTEXITCODE -ne 0) {
            return @()
        }

        return @(
            $result |
            ForEach-Object {
                $_.ToString().Trim().TrimStart([char]0xFEFF)
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

    foreach ($distro in (Get-WSLDistros)) {

        if ($distro -ieq $Name) {
            return $true
        }
    }

    return $false
}

function Get-WSLVersion {

    param(
        [string]$Name
    )

    try {

        $output = & wsl.exe --list --verbose 2>$null

        foreach ($line in $output) {

            $text = $line.ToString()

            if ($text -match [regex]::Escape($Name)) {

                if ($text -match '\s([12])\s*$') {
                    return [int]$Matches[1]
                }
            }
        }
    }
    catch {}

    return $null
}

# ================================================================
# SECURE STRING HELPER
# ================================================================

function SecureString-ToPlainText {

    param(
        [System.Security.SecureString]$SecureString
    )

    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(
        $SecureString
    )

    try {

        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
            $ptr
        )
    }
    finally {

        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Escape-YamlSingleQuote {

    param(
        [string]$Value
    )

    return $Value.Replace("'", "''")
}

# ================================================================
# MAIN INSTALLATION
# ================================================================

try {

    Write-Host ''
    Write-Host '============================================================' `
        -ForegroundColor Cyan

    Write-Host '          WSL 2 + UBUNTU LTS INSTALLER' `
        -ForegroundColor Cyan

    Write-Host '============================================================' `
        -ForegroundColor Cyan

    Write-Host ''

    Write-OK 'Administrator privileges confirmed.'

    # ============================================================
    # WINDOWS VERSION
    # ============================================================

    Write-Step 'Checking Windows compatibility'

    $OS = Get-CimInstance Win32_OperatingSystem

    $Build = [int]$OS.BuildNumber

    Write-Host "    Operating System : $($OS.Caption)"
    Write-Host "    Build            : $Build"
    Write-Host "    Architecture     : $env:PROCESSOR_ARCHITECTURE"

    if ($Build -lt 19041) {

        throw `
            'Windows 10 build 19041+ or Windows 11 is required.'
    }

    Write-OK 'Supported Windows version detected.'

    # ============================================================
    # USER CREDENTIALS
    # ============================================================

    $SavedState = Get-State

    if ($null -ne $SavedState) {

        $LinuxUsername = $SavedState.Username

        $LinuxPasswordSecure = Get-SavedPassword

        if ($null -eq $LinuxPasswordSecure) {

            Write-Warn `
                'Saved password unavailable after reboot.'

            $LinuxPasswordSecure = Read-Host `
                'Enter Linux password' `
                -AsSecureString
        }
        else {

            Write-Host ''
            Write-Host `
                "Resuming installation for Linux user: $LinuxUsername" `
                -ForegroundColor Cyan
        }
    }
    else {

        Write-Step 'Linux account setup'

        Write-Host ''
        Write-Host 'Choose the Linux username and password for Ubuntu.'
        Write-Host ''
        Write-Host 'Example:'
        Write-Host '  Username: dev'
        Write-Host '  Password: dev'
        Write-Host ''

        do {

            $LinuxUsername = Read-Host 'Linux username [dev]'

            if (
                [string]::IsNullOrWhiteSpace(
                    $LinuxUsername
                )
            ) {

                $LinuxUsername = 'dev'
            }

            if (
                $LinuxUsername -notmatch `
                '^[a-z_][a-z0-9_-]*$'
            ) {

                Write-Warn `
                    'Invalid Linux username.'

                $LinuxUsername = $null
            }

        }
        while (
            [string]::IsNullOrWhiteSpace(
                $LinuxUsername
            )
        )

        $LinuxPasswordSecure = Read-Host `
            'Linux password' `
            -AsSecureString

        $PasswordConfirm = Read-Host `
            'Confirm Linux password' `
            -AsSecureString

        $Password1 = SecureString-ToPlainText `
            $LinuxPasswordSecure

        $Password2 = SecureString-ToPlainText `
            $PasswordConfirm

        if ($Password1 -ne $Password2) {

            $Password1 = $null
            $Password2 = $null

            throw 'Passwords do not match.'
        }

        $Password1 = $null
        $Password2 = $null

        Save-State `
            -Username $LinuxUsername

        Save-Password `
            -Password $LinuxPasswordSecure

        Write-OK `
            "Linux username: $LinuxUsername"

        Write-OK `
            'Linux password accepted.'
    }

    # ============================================================
    # WSL FEATURE CHECK
    # ============================================================

    Write-Step 'Checking WSL Windows features'

    $WSLFeature = Get-WindowsOptionalFeature `
        -Online `
        -FeatureName Microsoft-Windows-Subsystem-Linux

    $VMFeature = Get-WindowsOptionalFeature `
        -Online `
        -FeatureName VirtualMachinePlatform

    Write-Host ''
    Write-Host `
        "    WSL                  : $($WSLFeature.State)"

    Write-Host `
        "    Virtual Machine      : $($VMFeature.State)"

    $FeaturesChanged = $false

    # ============================================================
    # WSL FEATURE
    # ============================================================

    if ($WSLFeature.State -ne 'Enabled') {

        Write-Step `
            'Enabling Windows Subsystem for Linux'

        & dism.exe `
            /online `
            /enable-feature `
            /featurename:Microsoft-Windows-Subsystem-Linux `
            /all `
            /norestart

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Failed to enable Windows Subsystem for Linux.'
        }

        $FeaturesChanged = $true

        Write-OK `
            'Windows Subsystem for Linux enabled.'
    }
    else {

        Write-OK `
            'Windows Subsystem for Linux already enabled.'
    }

    # ============================================================
    # VIRTUAL MACHINE PLATFORM
    # ============================================================

    if ($VMFeature.State -ne 'Enabled') {

        Write-Step `
            'Enabling Virtual Machine Platform'

        & dism.exe `
            /online `
            /enable-feature `
            /featurename:VirtualMachinePlatform `
            /all `
            /norestart

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Failed to enable Virtual Machine Platform.'
        }

        $FeaturesChanged = $true

        Write-OK `
            'Virtual Machine Platform enabled.'
    }
    else {

        Write-OK `
            'Virtual Machine Platform already enabled.'
    }

    # ============================================================
    # REBOOT
    # ============================================================

    if (
        $FeaturesChanged -or
        (Test-RebootRequired)
    ) {

        Restart-AndResume
    }

    # ============================================================
    # UPDATE WSL
    # ============================================================

    Write-Step 'Updating WSL'

    try {

        & wsl.exe `
            --update `
            --web-download

        if ($LASTEXITCODE -eq 0) {

            Write-OK `
                'WSL updated successfully.'
        }
        else {

            Write-Warn `
                "WSL update returned code $LASTEXITCODE."
        }
    }
    catch {

        Write-Warn `
            'WSL update could not be completed.'
    }

    # ============================================================
    # WSL 2 DEFAULT
    # ============================================================

    Write-Step 'Configuring WSL 2'

    & wsl.exe `
        --set-default-version `
        2

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Unable to configure WSL 2 as the default.'
    }

    Write-OK `
        'WSL 2 configured as default.'

    # ============================================================
    # DISABLE UBUNTU FIRST-RUN CONSENT PROMPT
    # ============================================================

    Write-Step 'Configuring unattended Ubuntu setup'

    $CanonicalKey = 'HKCU:\Software\Canonical\Ubuntu'

    if (-not (Test-Path $CanonicalKey)) {

        New-Item `
            -Path $CanonicalKey `
            -Force |
            Out-Null
    }

    # Opt out of Ubuntu Insights so the first-run process
    # cannot stop waiting for an interactive consent prompt.
    New-ItemProperty `
        -Path $CanonicalKey `
        -Name UbuntuInsightsConsent `
        -PropertyType DWord `
        -Value 0 `
        -Force |
        Out-Null

    Write-OK `
        'Ubuntu first-run consent prompt preconfigured.'

    # ============================================================
    # CLOUD INIT
    # ============================================================

    if (-not (Test-Path $CloudInitDir)) {

        New-Item `
            -ItemType Directory `
            -Path $CloudInitDir `
            -Force |
            Out-Null
    }

    $PlainPassword = SecureString-ToPlainText `
        $LinuxPasswordSecure

    $YamlUsername = Escape-YamlSingleQuote `
        $LinuxUsername

    $YamlPassword = Escape-YamlSingleQuote `
        $PlainPassword

    # Plaintext password is held only while constructing this file.
    $PlainPassword = $null

    $CloudConfig = @"
#cloud-config

users:
  - default
  - name: '$YamlUsername'
    gecos: '$YamlUsername'
    groups:
      - adm
      - sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    lock_passwd: false
    passwd: '$YamlPassword'

chpasswd:
  expire: false

write_files:
  - path: /etc/wsl.conf
    permissions: '0644'
    content: |
      [user]
      default=$LinuxUsername

      [boot]
      systemd=true

      [interop]
      enabled=true
      appendWindowsPath=true

      [automount]
      enabled=true
      mountFsTab=false

runcmd:
  - mkdir -p /home/$LinuxUsername
  - chown -R $LinuxUsername`:$LinuxUsername /home/$LinuxUsername
  - touch /home/$LinuxUsername/.hushlogin

final_message: "Ubuntu WSL provisioning completed."
"@

    Set-Content `
        -Path $CloudInitFile `
        -Value $CloudConfig `
        -Encoding UTF8

    Write-OK `
        'Ubuntu cloud-init configuration prepared.'

    # ============================================================
    # UBUNTU INSTALLATION
    # ============================================================

    Write-Step 'Checking Ubuntu'

    $UbuntuExists = Test-WSLDistro `
        -Name $DistroName

    if ($UbuntuExists) {

        Write-OK `
            'Ubuntu is already installed.'

        Write-Warn `
            'Existing Ubuntu will be preserved.'
    }
    else {

        Write-Step `
            'Installing Ubuntu LTS'

        Write-Host ''
        Write-Host `
            'Downloading the current Ubuntu LTS through WSL...' `
            -ForegroundColor Cyan

        # --no-launch is essential for cloud-init.
        # --web-download avoids dependence on Microsoft Store.
        & wsl.exe `
            --install `
            --distribution $DistroName `
            --web-download `
            --no-launch

        if ($LASTEXITCODE -ne 0) {

            Write-Warn `
                'Web download installation failed.'

            Write-Host `
                'Retrying using the standard WSL source...' `
                -ForegroundColor Yellow

            & wsl.exe `
                --install `
                --distribution $DistroName `
                --no-launch

            if ($LASTEXITCODE -ne 0) {

                throw `
                    'Ubuntu installation failed.'
            }
        }

        Write-OK `
            'Ubuntu installed.'
    }

    # ============================================================
    # WAIT FOR DISTRO
    # ============================================================

    Write-Step `
        'Waiting for Ubuntu registration'

    $Registered = $false

    for ($i = 1; $i -le 60; $i++) {

        if (
            Test-WSLDistro `
                -Name $DistroName
        ) {

            $Registered = $true
            break
        }

        Start-Sleep -Seconds 2
    }

    if (-not $Registered) {

        throw `
            'Ubuntu did not register with WSL.'
    }

    Write-OK `
        'Ubuntu registration confirmed.'

    # ============================================================
    # FORCE UBUNTU TO WSL 2
    # ============================================================

    Write-Step `
        'Validating Ubuntu WSL version'

    $Version = Get-WSLVersion `
        -Name $DistroName

    if ($Version -eq 1) {

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
    elseif ($Version -eq 2) {

        Write-OK `
            'Ubuntu is already WSL 2.'
    }

    # ============================================================
    # START UBUNTU
    # ============================================================

    Write-Step `
        'Starting Ubuntu for provisioning'

    & wsl.exe `
        --distribution `
        $DistroName `
        --user `
        root `
        --exec `
        true

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Ubuntu failed to start.'
    }

    # ============================================================
    # CLOUD INIT WAIT
    # ============================================================

    if (-not $UbuntuExists) {

        Write-Step `
            'Waiting for Ubuntu cloud-init'

        $CloudInitComplete = $false

        for ($i = 1; $i -le 120; $i++) {

            try {

                & wsl.exe `
                    --distribution `
                    $DistroName `
                    --user `
                    root `
                    --exec `
                    bash `
                    -c `
                    'test -f /var/lib/cloud/instance/boot-finished' `
                    2>$null

                if ($LASTEXITCODE -eq 0) {

                    $CloudInitComplete = $true
                    break
                }
            }
            catch {}

            Start-Sleep -Seconds 2
        }

        if ($CloudInitComplete) {

            Write-OK `
                'Ubuntu cloud-init completed.'
        }
        else {

            Write-Warn `
                'Cloud-init completion marker was not detected.'

            Write-Warn `
                'Continuing with direct validation.'
        }
    }

    # ============================================================
    # EXISTING UBUNTU
    # ============================================================

    if ($UbuntuExists) {

        Write-Step `
            'Configuring existing Ubuntu user'

        $PlainPassword = SecureString-ToPlainText `
            $LinuxPasswordSecure

        $BashUser = $LinuxUsername.Replace(
            "'",
            "'\''"
        )

        $BashPassword = $PlainPassword.Replace(
            "'",
            "'\''"
        )

        $PlainPassword = $null

        $ConfigureScript = @"
set -e

USERNAME='$BashUser'
PASSWORD='$BashPassword'

if ! id -u "`$USERNAME" >/dev/null 2>&1; then

    useradd \
        --create-home \
        --shell /bin/bash \
        --user-group \
        "`$USERNAME"
fi

printf '%s:%s\n' "`$USERNAME" "`$PASSWORD" | chpasswd

usermod -aG sudo "`$USERNAME"

mkdir -p /etc/sudoers.d

printf '%s\n' \
    "`$USERNAME ALL=(ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/90-`$USERNAME"

chmod 0440 "/etc/sudoers.d/90-`$USERNAME"

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

mkdir -p "/home/`$USERNAME"

chown -R "`$USERNAME:`$USERNAME" \
    "/home/`$USERNAME"

touch "/home/`$USERNAME/.hushlogin"

echo READY
"@

        & wsl.exe `
            --distribution `
            $DistroName `
            --user `
            root `
            --exec `
            bash `
            -c `
            $ConfigureScript

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Existing Ubuntu configuration failed.'
        }

        Write-OK `
            "Ubuntu configured for '$LinuxUsername'."
    }

    # ============================================================
    # RESTART WSL
    # ============================================================

    Write-Step `
        'Restarting WSL'

    & wsl.exe --shutdown

    Start-Sleep -Seconds 3

    Write-OK `
        'WSL restarted.'

    # ============================================================
    # DEFAULT DISTRO
    # ============================================================

    Write-Step `
        'Setting Ubuntu as default distribution'

    & wsl.exe `
        --set-default `
        $DistroName

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Failed to set Ubuntu as default distribution.'
    }

    Write-OK `
        'Ubuntu is now the default WSL distribution.'

    # ============================================================
    # USER VALIDATION
    # ============================================================

    Write-Step `
        'Validating Linux user'

    $DetectedUser = & wsl.exe `
        --distribution `
        $DistroName `
        --exec `
        whoami `
        2>$null

    if ($LASTEXITCODE -ne 0) {

        throw `
            'Unable to start Ubuntu for user validation.'
    }

    $DetectedUser = (
        $DetectedUser |
        Select-Object -First 1
    ).ToString().Trim()

    Write-Host `
        "    Detected user: $DetectedUser"

    if ($DetectedUser -ne $LinuxUsername) {

        Write-Warn `
            'Default user was not applied correctly.'

        Write-Host `
            'Applying direct WSL configuration...' `
            -ForegroundColor Yellow

        $SafeUser = $LinuxUsername.Replace(
            "'",
            "'\''"
        )

        $FixDefaultUser = @"
set -e

if ! id -u '$SafeUser' >/dev/null 2>&1; then
    exit 1
fi

if [ -f /etc/wsl.conf ]; then
    sed -i '/^\[user\]/,/^\[/ { /^default=/d; }' /etc/wsl.conf
fi

if ! grep -q '^\[user\]' /etc/wsl.conf 2>/dev/null; then
    printf '\n[user]\ndefault=$SafeUser\n' >> /etc/wsl.conf
else
    sed -i "/^\[user\]/a default=$SafeUser" /etc/wsl.conf
fi
"@

        & wsl.exe `
            --distribution `
            $DistroName `
            --user `
            root `
            --exec `
            bash `
            -c `
            $FixDefaultUser

        if ($LASTEXITCODE -ne 0) {

            throw `
                'Could not configure the Ubuntu default user.'
        }

        & wsl.exe --shutdown

        Start-Sleep -Seconds 3

        $DetectedUser = & wsl.exe `
            --distribution `
            $DistroName `
            --exec `
            whoami `
            2>$null

        $DetectedUser = (
            $DetectedUser |
            Select-Object -First 1
        ).ToString().Trim()
    }

    if ($DetectedUser -ne $LinuxUsername) {

        throw `
            "User validation failed. Expected '$LinuxUsername', got '$DetectedUser'."
    }

    Write-OK `
        "Default Linux user: $LinuxUsername"

    # ============================================================
    # FINAL WSL VERSION
    # ============================================================

    Write-Step `
        'Performing final WSL 2 validation'

    $FinalVersion = Get-WSLVersion `
        -Name $DistroName

    if ($FinalVersion -ne 2) {

        throw `
            "Ubuntu is not running WSL 2. Detected version: $FinalVersion"
    }

    Write-OK `
        'Ubuntu is running WSL 2.'

    # ============================================================
    # FINAL STATUS
    # ============================================================

    Write-Step `
        'Final installation status'

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

    # ============================================================
    # CLEANUP
    # ============================================================

    Write-Step `
        'Cleaning temporary installation files'

    if (Test-Path $CloudInitFile) {

        Remove-Item `
            $CloudInitFile `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Remove-ResumeTask

    if (Test-Path $StateFile) {

        Remove-Item `
            $StateFile `
            -Force `
            -ErrorAction SilentlyContinue
    }

    if (Test-Path $PasswordFile) {

        Remove-Item `
            $PasswordFile `
            -Force `
            -ErrorAction SilentlyContinue
    }

    if (Test-Path $ScriptCopy) {

        Remove-Item `
            $ScriptCopy `
            -Force `
            -ErrorAction SilentlyContinue
    }

    try {

        if (
            (Test-Path $StateRoot) -and
            ((Get-ChildItem $StateRoot -Force).Count -eq 0)
        ) {

            Remove-Item `
                $StateRoot `
                -Force `
                -ErrorAction SilentlyContinue
        }
    }
    catch {}

    # ============================================================
    # COMPLETE
    # ============================================================

    Write-Host ''
    Write-Host '============================================================' `
        -ForegroundColor Green

    Write-Host '             INSTALLATION COMPLETE' `
        -ForegroundColor Green

    Write-Host '============================================================' `
        -ForegroundColor Green

    Write-Host ''
    Write-Host "Ubuntu       : $DistroName"
    Write-Host "Ubuntu LTS   : Current LTS"
    Write-Host "WSL          : 2"
    Write-Host "Linux User   : $LinuxUsername"
    Write-Host ''

    Write-Host 'Start Ubuntu:' `
        -ForegroundColor Cyan

    Write-Host ''
    Write-Host '    wsl'
    Write-Host ''

    Write-Host 'Verify:' `
        -ForegroundColor Cyan

    Write-Host ''
    Write-Host '    wsl -l -v'
    Write-Host '    wsl --status'
    Write-Host ''

    exit 0
}
catch {

    Write-Host ''
    Write-Host '============================================================' `
        -ForegroundColor Red

    Write-Host '             INSTALLATION FAILED' `
        -ForegroundColor Red

    Write-Host '============================================================' `
        -ForegroundColor Red

    Write-Host ''

    Write-Fail $_.Exception.Message

    Write-Host ''
    Write-Host 'The installer can be run again safely.' `
        -ForegroundColor Yellow

    Write-Host ''
    Write-Host 'Diagnostics:'
    Write-Host '    wsl --status'
    Write-Host '    wsl --version'
    Write-Host '    wsl -l -v'
    Write-Host ''

    exit 1
}
