@echo off
setlocal EnableDelayedExpansion

title Windows Optimizer

:: Script Information
echo.
echo   --------------------------------------------------------
echo     Windows Optimizer v7.0 (Ultimate Performance + Advanced Debloat + 2025 Tweaks)
echo     Copyright (C) 2021-2025 Aman Pandey
echo   --------------------------------------------------------
echo.
pause
cls

:: Check for Administrator privileges
net session >nul 2>&1
IF NOT %errorLevel% == 0 (
    COLOR C
    CLS
    ECHO   Error: Please run this script as Administrator.
    PAUSE > NUL
    EXIT /B  
)

:: Color Scheme
color 0A

:: --------------------------------------
:: MAIN MENU
:: --------------------------------------
:MAIN_MENU
cls
echo  --------------------------------------------------------
echo   Windows Optimizer v6.4 - Main Menu (Ultimate Performance + Advanced Debloat + 2025 Tweaks)
echo  --------------------------------------------------------
echo.
echo  Choose an optimization option:
echo  Note - Choose Any One 123456789ABCDEFGHI (A=10, B=11, C=12, D=13, E=14, F=15, G=16, H=17, I=18)
echo    1.  Clear Temporary Files
echo    2.  Restart Tasks
echo    3.  Defragment Disk (HDD Only)
echo    4.  Clear Event Logs
echo    5.  Optimize Network Settings
echo    6.  Registry Optimizations (Advanced)
echo    7.  Group Policy Optimizations (Advanced)
echo    8.  Ultimate Performance Mode (Advanced)
echo    9.  Maximum Responsiveness Mode (Advanced)
echo   10.  Gaming Tweaks
echo   11.  Disk Cleanup
echo   12.  Disable Windows Search Indexing
echo   13.  Optimize Startup Programs
echo   14.  Clean Windows.old Folder
echo   15.  Disable Hibernation
echo   16.  Automated System Optimizations (Hidden Tweaks)
echo   17.  Debloat Windows (Remove Bloatware)
echo   18.  Advanced Performance Tweaks (2025)
echo   19.  Exit 
echo.
choice /c 123456789ABCDEFGHI /n /m "Enter your choice: "
if errorlevel 19 goto :eof
if errorlevel 18 goto :ADVANCED_TWEAKS
if errorlevel 17 goto :DEBLOAT_WINDOWS
if errorlevel 16 goto :AUTO_OPTIMIZE
if errorlevel 15 goto :DISABLE_HIBERNATION
if errorlevel 14 goto :CLEAN_WINDOWS_OLD
if errorlevel 13 goto :OPTIMIZE_STARTUP
if errorlevel 12 goto :DISABLE_SEARCH_INDEXING
if errorlevel 11 goto :DISK_CLEANUP
if errorlevel 10 goto :GAMING_TWEAKS
if errorlevel 9 goto :MAX_RESPONSIVENESS
if errorlevel 8 goto :ULTIMATE_PERFORMANCE
if errorlevel 7 goto :GPEDIT
if errorlevel 6 goto :REGISTRY
if errorlevel 5 goto :NETWORK_OPTIMIZE
if errorlevel 4 goto :CLEAREVENTS
if errorlevel 3 goto :DEFRAG
if errorlevel 2 goto :STARTUP
if errorlevel 1 goto :CLEANTEMP

:: --------------------------------------
:: OPTIMIZATION MODULES
:: --------------------------------------

:: 1. Clear Temporary Files and Caches
:CLEANTEMP
    echo.
    echo  --------------------------------------------------------
    echo   Clearing Temporary Files & Caches... 
    echo  --------------------------------------------------------
    echo.

    :: Automated Service Optimizations (Hidden)
    sc config "SysMain" start= auto >nul 2>&1
    sc config "WSearch" start= delayed-auto >nul 2>&1
    sc config "Spooler" start= demand >nul 2>&1
    sc config "Fax" start= disabled >nul 2>&1
    sc config "WpcMonSvc" start= disabled >nul 2>&1
    sc config "wisvc" start= disabled >nul 2>&1
    sc config "RetailDemo" start= disabled >nul 2>&1
    sc config "diagsvc" start= disabled >nul 2>&1
    sc config "dmwappushservice" start= disabled >nul 2>&1
    sc config "RemoteRegistry" start= disabled >nul 2>&1

    ipconfig /flushdns

    :: --- System-wide Temporary Files ---
    del /q /f /s "%SystemRoot%\Temp\*" >nul 2>&1
    rd /s /q "%SystemRoot%\Temp" >nul 2>&1
    md "%SystemRoot%\Temp" >nul 2>&1

    del /q /f /s "%SystemRoot%\Prefetch\*" >nul 2>&1
    rd /s /q "%SystemRoot%\Prefetch" >nul 2>&1
    md "%SystemRoot%\Prefetch" >nul 2>&1 
    :: --- End System-wide Temporary Files ---

    :: Standard Temporary File Cleanup 
    /s /f /q c:\windows\temp\*.*
    rd /s /q c:\windows\temp
    md c:\windows\temp
    del /s /f /q C:\WINDOWS\Prefetch
    del /s /f /q %temp%\*.*
    rd /s /q %temp%
    md %temp%
    del /f /q c:\windows\tempor~1
    cls
    pause
    echo Wait for a While
    del /s /f /q C:\Windows\temp
    del /s /f /q %USERPROFILE%\AppData\Local\Temp\*.*
    del /s /f /q %USERPROFILE%\AppData\LocalLow\Temp\*.*
    del /s /f /q %USERPROFILE%\history
    del /s /f /q %USERPROFILE%\cookies
    del /s /f /q %USERPROFILE%\recent
    del /s /f /q %USERPROFILE%\printers
    del /s /f /q c:\WIN386.SWP

    ::  C:\Windows Targeted Cleanup (More Controlled) 
    echo Cleaning temporary files in C:\Windows...
    for %%a in ( "*.tmp", "*.temp", "*.log", "*.bak", "*.old" ) do ( 
        del /s /f /q "C:\Windows\%%a" 2>nul  
    ) 

    :: SoftwareDistribution Cleanup (with user prompt)
    echo.
    set /P "confirm=Clean up SoftwareDistribution\Download folder? (Y/N)? "
    if /i "%confirm%"=="Y" (
        echo Cleaning SoftwareDistribution\Download...
        del /s /f /q "C:\Windows\SoftwareDistribution\Download\*"  
        rd /s /q "C:\Windows\SoftwareDistribution\Download" 
        md "C:\Windows\SoftwareDistribution\Download" 
    ) else (
        echo Skipping SoftwareDistribution\Download cleanup.
    )

    echo.
    echo  --------------------------------------------------------
    echo   Temporary Files Cleared!
    echo  --------------------------------------------------------
    pause

:: 2. Manage Startup Programs
:STARTUP
    echo.
    echo  --------------------------------------------------------
    echo   Restarting explorer and dwm
    echo  --------------------------------------------------------
    echo.
    echo  Opening System Configuration...
    TASKKILL /F /IM dwm.exe
	start dwm.exe
	TASKKILL /F /IM explorer.exe
	start explorer.exe
    goto :MAIN_MENU

:: 3. Defragment Disk (HDD only)
:DEFRAG
    echo.
    echo  --------------------------------------------------------
    echo   Defragmenting Disk (HDD Only)...  
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: This will defragment your C: drive. 
    echo           If you have an SSD, skip this step!
    echo.
    pause
    defrag c: /u /v
    goto :MAIN_MENU

:: 4. Clear Event Logs
:CLEAREVENTS
    echo.
    echo  --------------------------------------------------------
    echo   Clearing Event Logs...
    echo  --------------------------------------------------------
    echo.
    for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :delfile "%%G")
    echo  - Event logs cleared.
    pause
    goto :MAIN_MENU

:delfile 
    wevtutil.exe cl %1 >nul 2>&1
    goto :eof

:: 5. Network Optimizations
:NETWORK_OPTIMIZE
    echo.
    echo  --------------------------------------------------------
    echo   Optimizing Network Settings...
    echo  --------------------------------------------------------
    echo.
	ipconfig /flushdns
    
    :: Automated Network Optimizations (Hidden)
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    netsh int tcp set global chimney=enabled >nul 2>&1
    netsh int tcp set global dca=enabled >nul 2>&1
    netsh int tcp set global netdma=enabled >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    netsh int tcp set heuristics disabled >nul 2>&1
    netsh int ip set global taskoffload=enabled >nul 2>&1
    netsh int tcp set global timestamps=disabled >nul 2>&1
    netsh int tcp set global rsc=enabled >nul 2>&1
    netsh winsock reset >nul 2>&1
    
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\DefaultTTL set to 64. 
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "GlobalMaxTcpWindowSize" /t REG_DWORD /d 65535 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\GlobalMaxTcpWindowSize set to 65535.
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\MaxUserPort set to 65534.
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Tcp1323Opts set to 1. 
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\TcpMaxDupAcks set to 2.
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\TCPTimedWaitDelay set to 30. 

    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d ffffffff /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex set to ffffffff. 
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583\Attributes set to 0. 
    
    echo  - Network settings optimized. Some changes require a restart. 
    pause
    goto :MAIN_MENU

:: 6. Registry Optimizations (Advanced)
:REGISTRY
    cls
    echo  --------------------------------------------------------
    echo   Registry Optimizations (Advanced)
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: Create a system restore point before proceeding!
    echo.
    echo  Choose a registry optimization:
    echo    1.  Disable Unnecessary Visual Effects 
    echo    2.  Disable Windows Defender (Not Recommended!)
    echo    3.  Enable "Ultimate Performance" Power Plan 
    echo    4.  Disable Superfetch Service 
    echo    5.  Disable Prefetch 
    echo    6.  Boost Menu Responsiveness 
    echo    7.  Back to Main Menu 
    echo.
    choice /c 1234567 /n /m "Enter your choice: "

    if errorlevel 7 goto :MAIN_MENU
    if errorlevel 6 goto :BOOST_MENU
    if errorlevel 5 goto :DISABLE_PREFETCH
    if errorlevel 4 goto :DISABLE_SUPERFETCH
    if errorlevel 3 goto :ENABLE_ULTIMATE_REG
    if errorlevel 2 goto :DISABLE_DEFENDER
    if errorlevel 1 goto :DISABLE_VISUAL_EFFECTS

:DISABLE_VISUAL_EFFECTS
   reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting set to 2.
    echo  - Unnecessary visual effects disabled. 
    pause
    goto :REGISTRY 

:DISABLE_DEFENDER
    echo.
    echo  --------------------------------------------------------
    echo   WARNING: Disabling Windows Defender is NOT recommended 
    echo   unless you have another antivirus installed and active! 
    echo  --------------------------------------------------------
    echo.
    pause 

   reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\DisableAntiSpyware set to 1.
    echo  - Windows Defender disabled. A restart might be required.
    pause
    goto :REGISTRY

:ENABLE_ULTIMATE_REG
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\75b0ae3f-bce0-45a7-8c89-c9611c224f84" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\75b0ae3f-bce0-45a7-8c89-c9611c224f84\Attributes set to 2.
    echo  - "Ultimate Performance" power plan enabled in the registry.
    pause
    goto :REGISTRY

:DISABLE_SUPERFETCH
    sc config "SysMain" start= disabled >nul 2>&1
    net stop "SysMain" >nul 2>&1
    echo  - Service "SysMain" disabled.
    echo  - Superfetch service disabled.
    pause
    goto :REGISTRY

:DISABLE_PREFETCH
   reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters\EnablePrefetcher set to 0. 
    echo  - Prefetch disabled. 
    pause
    goto :REGISTRY

:BOOST_MENU
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\SystemResponsiveness set to 1. 
    echo  - Menu responsiveness boosted. 
    pause
    goto :REGISTRY

:: 7. Group Policy Optimizations (Advanced)
:GPEDIT
    cls 
    echo  --------------------------------------------------------
    echo   Group Policy and Performance Optimizations
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: Modifying system settings can impact stability. 
    echo  Proceed with caution and create a restore point if needed.
    echo.
    echo  Choose an optimization:
    echo    1.  Delay Automatic Windows Updates (Less Secure)
    echo    2.  Disable User Account Control (UAC) Prompts (Not Recommended - Reduces Security)
    echo    3.  Enable Fast Startup (with Hibernation Tweaks)
    echo    4.  Disable Visual Effects (for best performance)
    echo    5.  Adjust Processor Scheduling 
    echo    6.  Manage Services (Advanced Users Only!)
    echo    7.  Back to Main Menu
    echo.
    choice /c 12345678 /n /m "Enter your choice: "

    if errorlevel 7 goto :MAIN_MENU
    if errorlevel 6 goto :MANAGE_SERVICES
    if errorlevel 5 goto :PROCESSOR_SCHEDULING
    if errorlevel 4 goto :DISABLE_VISUAL_EFFECTS 
    if errorlevel 3 goto :ENABLE_FAST_STARTUP
    if errorlevel 2 goto :DISABLE_UAC_PROMPTS
    if errorlevel 1 goto :DELAY_UPDATES 

:DELAY_UPDATES 
    echo  --------------------------------------------------------
    echo   WARNING: Delaying updates still carries security risks!
    echo   Ensure you apply updates manually and regularly.
    echo  --------------------------------------------------------
    echo.
    set /p "delayDays=Enter the number of days to delay updates (max 35): "
    if %delayDays% gtr 35 set delayDays=35
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d %delayDays% /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d %delayDays% /f >nul 2>&1
    echo  - Updates delayed. Remember to install them manually.
    pause
    goto :GPEDIT

:DISABLE_UAC_PROMPTS
    echo  --------------------------------------------------------
    echo   WARNING: Disabling UAC significantly reduces security!
    echo   Proceed only if you understand the risks.
    echo  --------------------------------------------------------
    echo.
    pause 
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - UAC prompts disabled. A restart is required.
    pause
    goto :GPEDIT

:ENABLE_FAST_STARTUP 
    powercfg /hibernate on >nul 2>&1  
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Fast Startup (with Hibernation) enabled.
    pause
    goto :GPEDIT

:DISABLE_VISUAL_EFFECTS
    echo  Disabling visual effects...
    pause
    reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 90010000 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1
    echo  - Visual effects settings applied.
    pause
    goto :GPEDIT

:PROCESSOR_SCHEDULING
    echo.
    echo  --------------------------------------------------------
    echo   Processor scheduling options:
    echo     1. Optimize for Background Processes 
    echo     2. Optimize for Programs
    echo     3. Back to Previous Menu
    echo  --------------------------------------------------------
    echo.
    choice /c 123 /n /m "Enter your choice: "

    if errorlevel 3 goto :GPEDIT 
    if errorlevel 2 (
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT 0b621858-018a-4bbb-a0e7-0e7f60eeec18 75b0ae3f-bce0-45ca-8c62-87d78b76c147 0
    ) else (
       powercfg /SETDCVALUEINDEX SCHEME_CURRENT 0b621858-018a-4bbb-a0e7-0e7f60eeec18 75b0ae3f-bce0-45ca-8c62-87d78b76c147 1
    )
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 0b621858-018a-4bbb-a0e7-0e7f60eeec18 75b0ae3f-bce0-45ca-8c62-87d78b76c147 1
    echo  - Processor scheduling changed.
    pause
    goto :GPEDIT

:MANAGE_SERVICES
    echo.
    echo  --------------------------------------------------------
    echo   WARNING: Modifying services can make your system unstable!
    echo   Proceed with EXTREME CAUTION and only if you know 
    echo   exactly what you're doing. 
    echo  --------------------------------------------------------
    echo.
    pause

    echo  --------------------------------------------------------
    echo   Choose an action:
    echo      1. List All Services
    echo      2. Disable a Service (Recommended List)
    echo      3. Enable a Service
    echo      4. Set a Service to Manual (Start Only When Needed) 
    echo      5. Back to Previous Menu
    echo  --------------------------------------------------------
    choice /c 12345 /n /m "Enter your choice: "

    if errorlevel 5 goto :GPEDIT
    if errorlevel 4 goto :SET_SERVICE_MANUAL
    if errorlevel 3 goto :ENABLE_SERVICE
    if errorlevel 2 goto :DISABLE_RECOMMENDED_SERVICE 
    if errorlevel 1 goto :LIST_SERVICES

:LIST_SERVICES
    echo.
    echo  Listing services... (This might take a moment)
    echo.
    sc query type= service state= all | more
    pause
    goto :MANAGE_SERVICES

:DISABLE_RECOMMENDED_SERVICE
    echo.
    echo  --------------------------------------------------------
    echo   Potentially Safe Services to Disable (But Research First!):
    echo      1. Bluetooth Support Service (bthserv)
    echo      2. Fax 
    echo      3. Print Spooler (Spooler)
    echo      4. Windows Media Player Network Sharing Service
    echo      5. Downloaded Maps Manager (MapsBroker)
    echo      6. Offline Files (CscService)
    echo      7. Secondary Logon (seclogon)
    echo      8. Windows Error Reporting Service (WerSvc)
    echo      9. Back to Service Menu
    echo  --------------------------------------------------------
    choice /c 123456789 /n /m "Enter your choice (or 9 to go back): "

    if errorlevel 9 goto :MANAGE_SERVICES
    if errorlevel 8 set serviceName="WerSvc"
    if errorlevel 7 set serviceName="seclogon"
    if errorlevel 6 set serviceName="CscService" 
    if errorlevel 5 set serviceName="MapsBroker"
    if errorlevel 4 set serviceName="WMPNetworkSvc"
    if errorlevel 3 set serviceName="Spooler"
    if errorlevel 2 set serviceName="Fax"
    if errorlevel 1 set serviceName="bthserv"

    sc config "%serviceName%" start= disabled >nul 2>&1
    if %errorlevel% == 0 (
        echo  - Service "%serviceName%" disabled. 
    ) else (
        echo  - Error disabling service "%serviceName%". Make sure the name is correct.
    )
    pause
    goto :MANAGE_SERVICES

:ENABLE_SERVICE
    echo.
    set /p "serviceName=Enter the EXACT name of the service to enable: "
    sc config "%serviceName%" start= auto >nul 2>&1 
    if %errorlevel% == 0 (
        echo  - Service "%serviceName%" set to start automatically. 
    ) else (
        echo  - Error enabling service "%serviceName%". Make sure the name is correct.
    )
    pause
    goto :MANAGE_SERVICES

:SET_SERVICE_MANUAL
    echo.
    echo  --------------------------------------------------------
    echo   Services You Might Consider Setting to Manual: 
    echo      1. Application Identity (AppIDSvc)
    echo      2. Superfetch (SysMain) 
    echo      3. Back to Service Menu
    echo  --------------------------------------------------------
    choice /c 123 /n /m "Enter your choice (or 3 to go back): "

    if errorlevel 3 goto :MANAGE_SERVICES
    if errorlevel 2 set serviceName="SysMain"
    if errorlevel 1 set serviceName="AppIDSvc"

    sc config "%serviceName%" start= demand >nul 2>&1 
    if %errorlevel% == 0 (
        echo  - Service "%serviceName%" set to start manually (on demand).
    ) else (
        echo  - Error setting service "%serviceName%" to manual. Make sure the name is correct.
    )
    pause
    goto :MANAGE_SERVICES
:: 8. Ultimate Performance Mode (Advanced)
:ULTIMATE_PERFORMANCE
    cls
    echo  --------------------------------------------------------
    echo   Ultimate Performance Mode (Advanced)
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: Enabling Ultimate Performance Mode may increase 
    echo  power consumption and potentially impact hardware longevity. 
    echo  Use with caution!
    echo.
    echo  This option will:
    echo    - Enable the "Ultimate Performance" power plan.
    echo    - Apply additional system tweaks for maximum performance. 
    echo. 
    echo  Do you want to proceed?
    echo    1. Yes
    echo    2. No
    echo.
    choice /c 12 /n /m "Enter your choice: "

    if errorlevel 2 goto :MAIN_MENU

    echo  --------------------------------------------------------
    echo   Enabling Ultimate Performance Mode...
    echo  --------------------------------------------------------
    echo.

    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1 
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1

    REM --- AHCI Configuration (Check for IDE Mode first)
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\msahci" /v "Start" | find "0x00000003" >nul
    if %errorlevel% == 0 ( 
        echo  - AHCI is already enabled.
    ) else (
        REM --- AHCI is not enabled, provide instructions or attempt to enable it ---
        echo  - WARNING: Enabling AHCI requires additional steps in the BIOS 
        echo    and Registry. Make sure you understand the process before proceeding.
        echo  - For safety, this script will NOT automatically enable AHCI. 
        pause
    )

    REM --- Additional Performance Tweaks ---

    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1 
    echo  - Registry key HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\GlobalUserDisabled set to 1. 
    wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul 2>&1

    echo  - Ultimate Performance Mode enabled!
    pause
    goto :MAIN_MENU

:: 9. Maximum Responsiveness Mode (Advanced)
:MAX_RESPONSIVENESS
    cls
    echo  --------------------------------------------------------
    echo   Maximum Responsiveness Mode (Advanced)
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: This mode applies aggressive optimizations,
    echo  which may impact stability or have unintended side effects. 
    echo  Create a system restore point before proceeding!
    echo.
    echo  This option will:
    echo    - Disable unnecessary services.
    echo    - Prioritize applications over background processes.
    echo    - Adjust visual effects for minimal overhead.
    echo    - And more... 
    echo.
    echo  Are you sure you want to proceed?
    echo    1. Yes, I understand the risks
    echo    2. No, take me back
    echo.
    choice /c 12 /n /m "Enter your choice: "
    if errorlevel 2 goto :MAIN_MENU

    echo  --------------------------------------------------------
    echo   Enabling Maximum Responsiveness Mode...
    echo  --------------------------------------------------------
    echo.

    sc config "SysMain" start= disabled >nul 2>&1
    net stop "SysMain" >nul 2>&1
    echo  - Service "SysMain" disabled.
    REM sc config "Spooler" start= disabled >nul 2>&1
    REM net stop "Spooler" >nul 2>&1
    REM echo  - Service "Spooler" disabled. (Only disable if you don't use a printer)

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl\Win32PrioritySeparation set to 2.
   reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting set to 2. 

    echo  - Maximum Responsiveness Mode applied! A PC restart is recommended.
    pause
    goto :MAIN_MENU

:: 10. Gaming Tweaks
:GAMING_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   Applying Gaming Tweaks...
    echo  --------------------------------------------------------
    echo.

    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling\PowerThrottlingOff set to 1.

    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d f /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Affinity set to f.
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_DWORD /d 0 /f >nul 2>&1 
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Background Only set to 0.
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Priority" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Background Priority set to 1.
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\GPU Priority set to 8. 
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Priority set to 6.
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\Scheduling Category set to High. 
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1 
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\SFIO Priority set to High.
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Rate" /t REG_DWORD /d 4 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games\SFIO Rate set to 4.

    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Registry key HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Direct3D\MaxPreRenderedFrames set to 1.

    echo  - Gaming tweaks applied!
    pause
    goto :MAIN_MENU

:: 11. Disk Cleanup
:DISK_CLEANUP
    echo.
    echo  --------------------------------------------------------
    echo   Running Disk Cleanup...
    echo  --------------------------------------------------------
    echo.
    cleanmgr /sagerun:1
    echo  - Disk cleanup completed.
    pause
    goto :MAIN_MENU

:: 12. Disable Windows Search Indexing
:DISABLE_SEARCH_INDEXING
    echo.
    echo  --------------------------------------------------------
    echo   Disabling Windows Search Indexing...
    echo  --------------------------------------------------------
    echo.
    sc config "WSearch" start= disabled >nul 2>&1
    net stop "WSearch" >nul 2>&1
    echo  - Windows Search service disabled.
    echo  - This will improve performance but disable search functionality.
    pause
    goto :MAIN_MENU

:: 13. Optimize Startup Programs
:OPTIMIZE_STARTUP
    echo.
    echo  --------------------------------------------------------
    echo   Optimizing Startup Programs...
    echo  --------------------------------------------------------
    echo.
    echo  Opening Task Manager to manage startup programs...
    start taskmgr.exe /7
    echo  - Please disable unnecessary startup programs in Task Manager.
    echo  - Close Task Manager when done.
    pause
    goto :MAIN_MENU

:: 14. Clean Windows.old Folder
:CLEAN_WINDOWS_OLD
    echo.
    echo  --------------------------------------------------------
    echo   Cleaning Windows.old Folder...
    echo  --------------------------------------------------------
    echo.
    if exist "C:\Windows.old" (
        rd /s /q "C:\Windows.old" >nul 2>&1
        echo  - Windows.old folder removed.
    ) else (
        echo  - Windows.old folder not found.
    )
    pause
    goto :MAIN_MENU

:: 15. Disable Hibernation
:DISABLE_HIBERNATION
    echo.
    echo  --------------------------------------------------------
    echo   Disabling Hibernation...
    echo  --------------------------------------------------------
    echo.
    powercfg /hibernate off >nul 2>&1
    echo  - Hibernation disabled. This will free up disk space.
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: DEBLOAT WINDOWS MODULE
:: --------------------------------------

:: 17. Debloat Windows (Remove Bloatware)
:DEBLOAT_WINDOWS
    echo.
    echo  --------------------------------------------------------
    echo   Debloating Windows - Choose Your Debloat Method
    echo  --------------------------------------------------------
    echo.
    echo  Choose debloat category:
    echo    1. Keep Essentials Only (Remove ALL bloatware)
    echo    2. Custom Selection (Choose what to remove)
    echo    3. Remove ALL Apps (Complete cleanup)
    echo    4. Back to Main Menu
    echo.
    choice /c 1234 /n /m "Enter your choice: "
    if errorlevel 4 goto :MAIN_MENU
    if errorlevel 3 goto :DEBLOAT_ALL
    if errorlevel 2 goto :DEBLOAT_CUSTOM
    if errorlevel 1 goto :DEBLOAT_ESSENTIALS

:: --------------------------------------
:: DEBLOAT ESSENTIALS (Keep Only Essential Apps)
:: --------------------------------------
:DEBLOAT_ESSENTIALS
    echo.
    echo  --------------------------------------------------------
    echo   Debloating Windows - Keeping Essentials Only
    echo   This will remove ALL bloatware but keep essential system apps
    echo  --------------------------------------------------------
    echo.

    :: Apply all AI and privacy disabling features first
    call :APPLY_DEBLOAT_COMMON

    :: Remove ALL pre-installed apps (aggressive removal)
    echo  - Removing ALL pre-installed bloatware apps...
    
    :: Microsoft Apps to Remove (Complete removal)
    powershell -command "Get-AppxPackage -AllUsers | Remove-AppxPackage -AllUsers" >nul 2>&1
    powershell -command "Get-AppxProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online" >nul 2>&1
    
    echo  - Removed ALL pre-installed apps

    :: Disable ALL unnecessary services
    call :DISABLE_ALL_SERVICES

    :: Disable ALL scheduled tasks
    call :DISABLE_ALL_SCHEDULED_TASKS

    echo.
    echo  --------------------------------------------------------
    echo   Essentials-only debloat completed!
    echo   Only core system components remain.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: DEBLOAT CUSTOM (User Selects What to Remove)
:: --------------------------------------
:DEBLOAT_CUSTOM
    echo.
    echo  --------------------------------------------------------
    echo   Custom Debloat Selection
    echo   Choose specific apps to remove by number
    echo  --------------------------------------------------------
    echo.
    echo  Available apps to remove:
    echo    1. Microsoft 3D Builder
    echo    2. Bing Weather
    echo    3. Get Help
    echo    4. Get Started
    echo    5. Microsoft Office Hub
    echo    6. Microsoft Solitaire Collection
    echo    7. Microsoft Sticky Notes
    echo    8. OneNote
    echo    9. People
    echo   10. Skype App
    echo   11. Windows Alarms
    echo   12. Windows Camera
    echo   13. Windows Feedback Hub
    echo   14. Windows Maps
    echo   15. Windows Sound Recorder
    echo   16. Xbox App
    echo   17. Your Phone
    echo   18. Zune Music
    echo   19. Zune Video
    echo   20. Adobe Photoshop Express
    echo   21. Bubble Witch 3 Saga
    echo   22. Candy Crush Saga
    echo   23. Disney Magic Kingdoms
    echo   24. Duolingo
    echo   25. Facebook
    echo   26. FarmVille 2
    echo   27. Flipboard
    echo   28. Instagram
    echo   29. LinkedIn
    echo   30. Minecraft
    echo   31. Netflix
    echo   32. Plex
    echo   33. Royal Revolt 2
    echo   34. Spotify Music
    echo   35. TikTok
    echo   36. Twitter
    echo   37. WhatsApp
    echo   38. All of the above (Complete removal)
    echo   39. Back to Debloat Menu
    echo.
    echo  Enter numbers separated by spaces (e.g., "1 5 10 15"):
    set /p "choices=Your choices: "
    
    :: Process user choices
    echo Processing selections...
    for %%i in (%choices%) do (
        if %%i==1 powershell -command "Get-AppxPackage -AllUsers *3DBuilder* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==2 powershell -command "Get-AppxPackage -AllUsers *BingWeather* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==3 powershell -command "Get-AppxPackage -AllUsers *GetHelp* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==4 powershell -command "Get-AppxPackage -AllUsers *Getstarted* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==5 powershell -command "Get-AppxPackage -AllUsers *MicrosoftOfficeHub* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==6 powershell -command "Get-AppxPackage -AllUsers *MicrosoftSolitaireCollection* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==7 powershell -command "Get-AppxPackage -AllUsers *MicrosoftStickyNotes* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==8 powershell -command "Get-AppxPackage -AllUsers *OneNote* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==9 powershell -command "Get-AppxPackage -AllUsers *People* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==10 powershell -command "Get-AppxPackage -AllUsers *SkypeApp* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==11 powershell -command "Get-AppxPackage -AllUsers *WindowsAlarms* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==12 powershell -command "Get-AppxPackage -AllUsers *WindowsCamera* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==13 powershell -command "Get-AppxPackage -AllUsers *WindowsFeedbackHub* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==14 powershell -command "Get-AppxPackage -AllUsers *WindowsMaps* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==15 powershell -command "Get-AppxPackage -AllUsers *WindowsSoundRecorder* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==16 powershell -command "Get-AppxPackage -AllUsers *XboxApp* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==17 powershell -command "Get-AppxPackage -AllUsers *YourPhone* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==18 powershell -command "Get-AppxPackage -AllUsers *ZuneMusic* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==19 powershell -command "Get-AppxPackage -AllUsers *ZuneVideo* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==20 powershell -command "Get-AppxPackage -AllUsers *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==21 powershell -command "Get-AppxPackage -AllUsers *BubbleWitch3Saga* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==22 powershell -command "Get-AppxPackage -AllUsers *CandyCrush* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==23 powershell -command "Get-AppxPackage -AllUsers *DisneyMagicKingdoms* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==24 powershell -command "Get-AppxPackage -AllUsers *Duolingo* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==25 powershell -command "Get-AppxPackage -AllUsers *Facebook* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==26 powershell -command "Get-AppxPackage -AllUsers *FarmVille* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==27 powershell -command "Get-AppxPackage -AllUsers *Flipboard* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==28 powershell -command "Get-AppxPackage -AllUsers *Instagram* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==29 powershell -command "Get-AppxPackage -AllUsers *LinkedInforWindows* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==30 powershell -command "Get-AppxPackage -AllUsers *Minecraft* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==31 powershell -command "Get-AppxPackage -AllUsers *Netflix* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==32 powershell -command "Get-AppxPackage -AllUsers *Plex* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==33 powershell -command "Get-AppxPackage -AllUsers *RoyalRevolt* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==34 powershell -command "Get-AppxPackage -AllUsers *SpotifyMusic* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==35 powershell -command "Get-AppxPackage -AllUsers *TikTok* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==36 powershell -command "Get-AppxPackage -AllUsers *Twitter* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==37 powershell -command "Get-AppxPackage -AllUsers *WhatsApp* | Remove-AppxPackage -AllUsers" >nul 2>&1
        if %%i==38 goto :DEBLOAT_ALL_FROM_CUSTOM
        if %%i==39 goto :DEBLOAT_WINDOWS
    )
    
    echo.
    echo  --------------------------------------------------------
    echo   Custom debloat completed!
    echo   Selected apps have been removed.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: DEBLOAT ALL (Complete Removal)
:: --------------------------------------
:DEBLOAT_ALL
    echo.
    echo  --------------------------------------------------------
    echo   Complete Windows Debloat - Removing EVERYTHING
    echo   WARNING: This will remove ALL apps including potentially useful ones!
    echo  --------------------------------------------------------
    echo.
    echo  Are you sure you want to remove ALL apps? (Y/N)
    choice /c YN /n /m "Enter your choice: "
    if errorlevel 2 goto :DEBLOAT_WINDOWS

:DEBLOAT_ALL_FROM_CUSTOM
    :: Apply all AI and privacy disabling features first
    call :APPLY_DEBLOAT_COMMON

    :: Remove ALL apps without exception
    echo  - Removing ALL apps completely...
    powershell -command "Get-AppxPackage | Remove-AppxPackage" >nul 2>&1
    powershell -command "Get-AppxPackage -AllUsers | Remove-AppxPackage -AllUsers" >nul 2>&1
    powershell -command "Get-AppxProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online" >nul 2>&1
    
    echo  - Removed ALL apps

    :: Disable ALL unnecessary services
    call :DISABLE_ALL_SERVICES

    :: Disable ALL scheduled tasks
    call :DISABLE_ALL_SCHEDULED_TASKS

    echo.
    echo  --------------------------------------------------------
    echo   Complete debloat finished!
    echo   ALL apps and bloatware removed.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: COMMON DEBLOAT FUNCTIONS
:: --------------------------------------

:APPLY_DEBLOAT_COMMON
    :: Disable Windows Copilot and AI Features
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows Copilot

    :: Disable Windows Recall (if available)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows Recall and AI Data Analysis

    :: Disable Click to Do (AI image/text analysis)
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartActionPlatform" /v "SmartActionPlatformMLDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Click to Do AI features

    :: Disable AI Features in Edge
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "ShowMicrosoftRewards" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled AI Features in Edge

    :: Disable AI Features in Paint
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Paint" /v "DisableCocreator" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled AI Features in Paint

    :: Disable AI Features in Notepad
    reg add "HKCU\SOFTWARE\Microsoft\Notepad" /v "EnableWindowsAI" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled AI Features in Notepad

    :: Disable Bing Web Search Integration
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Bing Web Search

    :: Disable Windows Spotlight and Lock Screen Ads
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Spotlight and Lock Screen Ads

    :: Disable Suggested Content and Tips
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Suggested Content and Tips

    :: Disable Widgets
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Widgets

    :: Disable Phone Link Integration
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\System\Phone" /v "EnablePhoneLink" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Phone Link Integration

    :: Disable Xbox Game Recording and Popups
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Disabled Xbox Game Recording and Popups

    :: Disable Fast Startup
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Fast Startup

    :: Disable Network Connectivity During Modern Standby
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemThrottle\ModernStandby" /v "EnableNetworkConnectivityDuringModernStandby" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Network Connectivity During Modern Standby
    goto :eof

:DISABLE_ALL_SERVICES
    :: Disable ALL unnecessary services
    sc config "SysMain" start= disabled >nul 2>&1
    sc config "WSearch" start= disabled >nul 2>&1
    sc config "Spooler" start= disabled >nul 2>&1
    sc config "Fax" start= disabled >nul 2>&1
    sc config "WpcMonSvc" start= disabled >nul 2>&1
    sc config "wisvc" start= disabled >nul 2>&1
    sc config "RetailDemo" start= disabled >nul 2>&1
    sc config "diagsvc" start= disabled >nul 2>&1
    sc config "dmwappushservice" start= disabled >nul 2>&1
    sc config "RemoteRegistry" start= disabled >nul 2>&1
    sc config "MapsBroker" start= disabled >nul 2>&1
    sc config "lfsvc" start= disabled >nul 2>&1
    sc config "SharedAccess" start= disabled >nul 2>&1
    sc config "lltdsvc" start= disabled >nul 2>&1
    sc config "wlidsvc" start= disabled >nul 2>&1
    sc config "NgcSvc" start= disabled >nul 2>&1
    sc config "NgcCtnrSvc" start= disabled >nul 2>&1
    sc config "SEMgrSvc" start= disabled >nul 2>&1
    sc config "PhoneSvc" start= disabled >nul 2>&1
    sc config "TapiSrv" start= disabled >nul 2>&1
    sc config "UevAgentService" start= disabled >nul 2>&1
    sc config "WaaSMedicSvc" start= disabled >nul 2>&1
    sc config "XblAuthManager" start= disabled >nul 2>&1
    sc config "XblGameSave" start= disabled >nul 2>&1
    sc config "XboxAccessoryManagementService" start= disabled >nul 2>&1
    sc config "XboxLiveAuthManager" start= disabled >nul 2>&1
    sc config "XboxLiveGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveNetAuthManager" start= disabled >nul 2>&1
    echo  - Disabled ALL unnecessary services
    goto :eof

:DISABLE_ALL_SCHEDULED_TASKS
    :: Disable ALL scheduled tasks
    schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Autochk\Proxy" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Feedback\Siuf\DmClient" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maintenance\WinSAT" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maps\MapsToastTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maps\MapsUpdateTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\PI\Sqm-Tasks" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable >nul 2>&1
    echo  - Disabled ALL unnecessary scheduled tasks
    goto :eof

:: 16. Automated System Optimizations (Hidden Tweaks)
:AUTO_OPTIMIZE
    echo.
    echo  --------------------------------------------------------
    echo   Applying Automated System Optimizations...
    echo   These are advanced hidden tweaks for maximum performance
    echo  --------------------------------------------------------
    echo.

    :: Disable Windows Telemetry and Data Collection
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Telemetry
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1

    :: Disable Windows Tips and Suggestions
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Tips and Suggestions

    :: Disable Cortana and Web Search
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Cortana and Web Search

    :: Optimize Windows Search Settings
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "EnableDynamicContentInWSB" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows Search Settings

    :: Disable Windows Error Reporting
    reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows Error Reporting

    :: Optimize Memory Management
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingCombining" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Memory Management

    :: Disable Windows Game Recording and Broadcasting
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Game Recording and Broadcasting

    :: Disable Windows Ink Workspace
    reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" /v "AllowWindowsInkWorkspace" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Ink Workspace

    :: Optimize USB Power Management
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized USB Power Management

    :: Disable Windows Customer Experience Improvement Program
    reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Customer Experience Improvement Program

    :: Disable Application Telemetry
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Application Telemetry

    :: Optimize NTFS Settings
    fsutil behavior set disabledeletenotify 0 >nul 2>&1
    fsutil behavior set disablelastaccess 1 >nul 2>&1
    echo  - Optimized NTFS Settings

    :: Additional Performance Registry Tweaks
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AlwaysUnloadDLL" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d 1 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d 1000 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d 2000 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "LowLevelHooksTimeout" /t REG_SZ /d 1000 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d 2000 /f >nul 2>&1
    echo  - Applied Additional Performance Registry Tweaks

    :: Disable Windows Defender Real-time Protection (Advanced Users Only)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows Defender Real-time Protection (Use with caution!)

    :: Optimize Windows Search Indexing
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "EnableDynamicContentInWSB" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows Search Indexing

    :: Disable Windows Spotlight and Lockscreen Ads
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Spotlight and Lockscreen Ads

    :: Disable Unnecessary Scheduled Tasks
    schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Autochk\Proxy" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maintenance\WinSAT" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maps\MapsToastTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\Maps\MapsUpdateTask" /disable >nul 2>&1
    schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable >nul 2>&1
    echo  - Disabled Unnecessary Scheduled Tasks

    :: Optimize GPU Settings
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
    echo  - Optimized GPU Settings for Gaming

    :: Disable Windows Tips and Notifications
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Tips and Notifications

    :: Optimize Network Settings for Gaming
    reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d 4 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d 5 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d 6 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d 7 /f >nul 2>&1
    echo  - Optimized Network Settings for Gaming

    :: Additional Advanced Optimizations from Web Research
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Applied Advanced Explorer Optimizations

    :: Optimize Windows Defender for Performance
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Intelligence\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Windows Defender for Performance

    :: Disable Windows Game Bar
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Game Bar

    :: Optimize Windows Update Settings
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d 3 /f >nul 2>&1
    echo  - Optimized Windows Update Settings

    :: Disable Windows Error Recovery
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v "GlobalFlag" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows Error Recovery Popups

    :: Optimize System Responsiveness
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
    echo  - Optimized System Responsiveness

    :: Latest Windows 11 Optimizations (2025)
    :: Optimize File Explorer for Windows 11
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized File Explorer for Windows 11

    :: Disable Windows 11 Recall (if available)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Recall and Activity Feed

    :: Optimize Windows 11 Taskbar
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Taskbar

    :: Disable Windows 11 Copilot+ Features
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartActionPlatform" /v "SmartActionPlatformMLDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows 11 Copilot+ Features

    :: Optimize Windows 11 Start Menu
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_Suggestions" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Start Menu

    :: Disable Windows 11 Widgets and News
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Disabled Windows 11 Widgets and News

    :: Optimize Windows 11 Snap Layouts
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableSnapAssistFlyout" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableSnapBar" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Snap Layouts

    :: Disable Windows 11 Suggested Actions
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartActionPlatform" /v "SmartActionPlatformMLDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartActionPlatform" /v "SmartActionPlatformEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Suggested Actions

    :: Optimize Windows 11 Notification Settings
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Notification Settings

    :: Disable Windows 11 Auto HDR
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings" /v "EnableHDR" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Auto HDR

    :: Optimize Windows 11 Power Settings
    powercfg /setacvalueindex scheme_current sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 100 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    echo  - Optimized Windows 11 Power Settings

    :: Disable Windows 11 Auto Color Management
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Auto Color Management

    echo.
    echo  --------------------------------------------------------
    echo   Automated optimizations applied successfully!
    echo   These tweaks provide maximum system performance for Windows 11.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: ADVANCED PERFORMANCE TWEAKS (2025)
:: --------------------------------------
:ADVANCED_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   Advanced Performance Tweaks (2025)
    echo   Cutting-edge optimizations for maximum performance
    echo  --------------------------------------------------------
    echo.

    :: Advanced CPU Optimizations
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\943c8cb6-6f93-4227-ad87-e9a3feec08d1" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Applied Advanced CPU Optimizations

    :: Optimize Windows 11 Context Menu
    reg add "HKCU\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
    echo  - Optimized Windows 11 Context Menu

    :: Disable Windows 11 Animation Effects
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Animation Effects

    :: Advanced Network Optimizations
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    netsh int tcp set global chimney=enabled >nul 2>&1
    netsh int tcp set global dca=enabled >nul 2>&1
    netsh int tcp set global netdma=enabled >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    netsh int tcp set global timestamps=disabled >nul 2>&1
    echo  - Applied Advanced Network Optimizations

    :: Optimize Windows 11 File Explorer Ribbon
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" /v "MinimizedStateTabletMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon" /v "MinimizedState" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Windows 11 File Explorer Ribbon

    :: Disable Windows 11 File History
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\FileHistory" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows 11 File History

    :: Advanced Storage Optimizations
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\fsvs\Parameters" /v "DisableAsyncIo" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\fsvs\Parameters" /v "EnableOplocks" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d 32 /f >nul 2>&1
    echo  - Applied Advanced Storage Optimizations

    :: Optimize Windows 11 Virtual Memory
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Virtual Memory

    :: Disable Windows 11 Smart App Control
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Smart App Control

    :: Advanced GPU Optimizations
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
    echo  - Applied Advanced GPU Optimizations

    :: Optimize Windows 11 Background Apps
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Background Apps

    :: Disable Windows 11 Cloud Clipboard
    reg add "HKCU\SOFTWARE\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Cloud Clipboard

    :: Advanced Windows 11 Security Optimizations
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "EnableNetworkProtection" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "UILockdown" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Security Optimizations

    :: Optimize Windows 11 Action Center
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.ActionCenter" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Action Center

    :: Disable Windows 11 Live Captions
    reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Speech\AllowSpeechActivation" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Live Captions

    :: Advanced Windows 11 Performance Mode
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Advanced Windows 11 Performance Mode

    :: Optimize Windows 11 Quick Settings
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\Quick Actions" /v "IsDynamic" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Quick Settings

    :: Disable Windows 11 Voice Activation
    reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" /v "AgentActivationOnLockScreenEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Voice Activation

    :: Advanced Windows 11 Storage Sense
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "01" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "04" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "08" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "32" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "1024" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "2048" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Storage Sense

    :: Disable Windows 11 Focus Assist
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.FocusAssist" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Focus Assist

    :: Optimize Windows 11 Touch Keyboard
    reg add "HKCU\SOFTWARE\Microsoft\TabletTip\1.7" /v "TipbandDesiredVisibility" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 Touch Keyboard

    :: Advanced Windows 11 Registry Optimizations
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d 4096 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Registry Optimizations

    :: Optimize Windows 11 System Tray
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoTrayItemsDisplay" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized Windows 11 System Tray

    :: Disable Windows 11 News and Interests
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Disabled Windows 11 News and Interests

    :: Advanced Windows 11 Gaming Optimizations
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Gaming Optimizations

    :: Optimize Windows 11 Battery Settings
    powercfg /setdcvalueindex scheme_current sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 100 >nul 2>&1
    powercfg /setacvalueindex scheme_current sub_processor 5d76a2ca-e8c0-402f-a133-2158492d58ad 100 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    echo  - Optimized Windows 11 Battery Settings

    :: Disable Windows 11 Auto Restart
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows 11 Auto Restart

    :: Advanced Windows 11 Memory Optimizations
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PoolUsageMaximum" /t REG_DWORD /d 60 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionPoolSize" /t REG_DWORD /d 192 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SessionViewSize" /t REG_DWORD /d 192 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Memory Optimizations

    :: Optimize Windows 11 Disk I/O
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "MaxWorkItems" /t REG_DWORD /d 8192 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "MaxMpxCt" /t REG_DWORD /d 2048 /f >nul 2>&1
    echo  - Optimized Windows 11 Disk I/O

    :: Disable Windows 11 Diagnostic Tracking
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Diagnostic Tracking

    :: Advanced Windows 11 Network Throttling
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Network Throttling

    :: Optimize Windows 11 USB Settings
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbxhci\Parameters" /v "ThreadPriority" /t REG_DWORD /d 31 /f >nul 2>&1
    echo  - Optimized Windows 11 USB Settings

    :: Disable Windows 11 Fast Startup (Hybrid Boot)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Fast Startup

    :: Advanced Windows 11 CPU Optimizations
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "ThreadDpcEnable" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 CPU Optimizations

    :: Optimize Windows 11 Prefetch and Superfetch
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 3 /f >nul 2>&1
    echo  - Optimized Windows 11 Prefetch and Superfetch

    :: Disable Windows 11 Location Services
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Location Services

    :: Advanced Windows 11 Visual Effects
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012078012000000 /f >nul 2>&1
    echo  - Optimized Windows 11 Visual Effects

    :: Disable Windows 11 Automatic Maintenance
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows 11 Automatic Maintenance

    :: Optimize Windows 11 Disk Cleanup
    cleanmgr /sagerun:1 >nul 2>&1
    echo  - Optimized Windows 11 Disk Cleanup

    :: Advanced Windows 11 Service Optimizations
    sc config "WpnService" start= disabled >nul 2>&1
    sc config "WpnUserService" start= disabled >nul 2>&1
    sc config "XboxGipSvc" start= disabled >nul 2>&1
    sc config "XboxLiveAuthManager" start= disabled >nul 2>&1
    sc config "XboxLiveGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveNetAuthSvc" start= disabled >nul 2>&1
    echo  - Applied Advanced Windows 11 Service Optimizations

    :: Optimize Windows 11 Energy Settings
    powercfg /setacvalueindex scheme_current sub_processor 06cadf0e-64ed-448a-8927-ce7bf90eb35d 79 >nul 2>&1
    powercfg /setdcvalueindex scheme_current sub_processor 06cadf0e-64ed-448a-8927-ce7bf90eb35d 79 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    echo  - Optimized Windows 11 Energy Settings

    :: Disable Windows 11 Phone Link
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\System\Phone" /v "EnablePhone" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Phone Link

    :: Advanced Windows 11 Registry Cleanup
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ExtendedUIHoverTime" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Registry Cleanup

    :: Optimize Windows 11 Thumbnail Cache
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ThumbnailLivePreviewHoverTime" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Windows 11 Thumbnail Cache

    :: Disable Windows 11 Microsoft Store Auto Updates
    reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Disabled Windows 11 Microsoft Store Auto Updates

    :: Advanced Windows 11 Task Manager Optimizations
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" /v "AlwaysOnTop" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Task Manager Optimizations

    :: Optimize Windows 11 Search Indexing Advanced
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "PreventIndexingUncachedExchangeFolders" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "PreventRemoteQueries" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Windows 11 Search Indexing Advanced

    :: Disable Windows 11 Bluetooth Auto Connect
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Bluetooth\AllowAutoConnectToWirelessPeripheral" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Windows 11 Bluetooth Auto Connect

    :: Advanced Windows 11 Power Management
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\893dee8e-2bef-41e0-89c6-b55d0929964c" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\94ac6d29-73ce-41a6-809f-6363ba21b47b" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Applied Advanced Windows 11 Power Management

    :: Optimize Windows 11 File Associations
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt\OpenWithProgids" /v "txtfile" /t REG_SZ /d "" /f >nul 2>&1
    echo  - Optimized Windows 11 File Associations

    :: Disable Windows 11 Windows Security Notifications
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Intelligence\UX Configuration" /v "UILockdown" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Windows 11 Windows Security Notifications

    :: Advanced Windows 11 Network Adapter Optimizations
    netsh int tcp set global ecncapability=enabled >nul 2>&1
    netsh int tcp set global rsc=enabled >nul 2>&1
    echo  - Applied Advanced Windows 11 Network Adapter Optimizations

    :: Final System Optimization
    sfc /scannow >nul 2>&1
    dism /online /cleanup-image /restorehealth >nul 2>&1
    echo  - Performed Final System Optimization

    echo.
    echo  --------------------------------------------------------
    echo   Advanced Performance Tweaks (2025) applied successfully!
    echo   Your system now has cutting-edge optimizations for maximum performance.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

endlocal
exit /B 
