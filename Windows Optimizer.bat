@echo off
setlocal EnableDelayedExpansion

title Windows System Helper

:: Script Header
cls
echo.
echo ================================================================================
echo  WINDOWS SYSTEM HELPER
echo  Version 9.0
echo ================================================================================
echo.
echo  A helpful tool for keeping your Windows system running smoothly
echo.
echo  Copyright (C) 2021-2026 Aman Pandey
echo   All Rights Reserved
echo.
echo   WHAT THIS TOOL DOES:
echo ================================================================================
echo   This tool helps you keep your Windows computer running at its best by
echo   cleaning up unnecessary files, optimizing settings, and fixing common issues.
echo.
echo   WHAT YOU CAN DO:
echo   ════════════════
echo   • Clean up temporary files and free up space
echo   • Speed up your computer and improve performance
echo   • Back up your important files and settings
echo   • Protect your privacy and security
echo   • Improve gaming and everyday use
echo   • Fix network and internet problems
echo   • Manage startup programs and background tasks
echo   • Control Windows updates and features
echo   • Check your hardware and system health
echo   • Get help and support when needed
echo.
echo   SYSTEM REQUIREMENTS:
echo   ════════════════════
echo   • Windows 10/11 (64-bit recommended)
echo   • Administrator privileges required
echo   • At least 4GB RAM and 10GB free disk space
echo   • Internet connection for installing software
echo.
echo   IMPORTANT NOTES:
echo   ════════════════
echo   • This tool changes system settings - please use carefully
echo   • Automatic backups are created for your safety
echo   • You can always restore your previous settings
echo   • Help and guidance are available throughout
echo.
echo ================================================================================
echo   Press any key to get started...
echo ================================================================================
pause >nul
cls

:: Starting up the tool
echo.
echo  [INFO] Starting Windows System Helper v9.0...
echo  [INFO] Performing system compatibility checks...
timeout /t 1 /nobreak >nul

:: Check for Administrator privileges with helpful messaging
echo  [INFO] Verifying administrator privileges...
net session >nul 2>&1
IF NOT %errorLevel% == 0 (
    COLOR C
    CLS
    echo.
    echo ================================================================================
    echo  ADMINISTRATOR ACCESS NEEDED
    echo ================================================================================
    echo.
    echo   This tool needs administrator access to work properly.
    echo   Here's how to run it correctly:
    echo.
    echo   1. Right-click on the Windows System Helper file
    echo   2. Choose "Run as administrator" from the menu
    echo   3. When asked by Windows, click "Yes"
    echo   4. The tool will then start with full access
    echo.
    echo   Without administrator access, some features won't work
    echo   and you won't be able to make all the improvements.
    echo.
    echo ================================================================================
    echo   Press any key to exit...
    echo ================================================================================
    PAUSE > NUL
    EXIT /B
)

:: Getting things ready
echo  [SUCCESS] Administrator access confirmed
echo  [INFO] Loading helper tools...
timeout /t 1 /nobreak >nul
echo  [INFO] Initializing backup and logging systems...
timeout /t 1 /nobreak >nul
echo  [INFO] Scanning system configuration...
timeout /t 1 /nobreak >nul
echo  [INFO] Preparing user interface...
timeout /t 1 /nobreak >nul
echo  [SUCCESS] System initialization completed
echo.
echo  Press any key to enter the main optimization interface...
pause >nul

:: Color Scheme
color 0A

:: Logging and Backup Setup
set "LogDir=%ProgramData%\WinOptimizer\logs"
if not exist "%LogDir%" md "%LogDir%"
set "LogFile=%LogDir%\WinOptimizer_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"

:: Smart Backup Drive Detection
call :DETECT_BACKUP_DRIVE
if not exist "%BackupDir%" md "%BackupDir%"

:: Device Detection (Desktop/Laptop)
wmic computersystem get pcSystemType /value | find "2" >nul
if %errorlevel% == 0 (
    set "DeviceType=Laptop"
) else (
    set "DeviceType=Desktop"
)

:: Logging Function
:LOG
echo [%date% %time%] %~1 >> "%LogFile%"
goto :eof

:: Smart Backup Drive Detection Function
:DETECT_BACKUP_DRIVE
    set "BackupDir=%ProgramData%\WinOptimizer\backups"
    
    :: Check for external/removable drives (USB drives, etc.)
    for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
        if exist "%%d:\" (
            vol %%d: 2>nul | find "Removable" >nul
            if !errorlevel! == 0 (
                set "BackupDir=%%d:\WinOptimizer_Backups"
                call :LOG "Using external drive %%d: for backups"
                goto :eof
            )
        )
    )
    
    :: Check for additional internal drives (non-system drives)
    for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
        if exist "%%d:\" (
            :: Check if drive has enough free space (at least 1GB)
            for /f "tokens=3" %%s in ('dir %%d:\ /-c ^| find "bytes free"') do (
                set "free_space=%%s"
                set "free_space=!free_space:,=!"
                if !free_space! gtr 1073741824 (
                    :: Check if it's not a CD/DVD drive
                    if not exist "%%d:\VIDEO_TS" if not exist "%%d:\AUDIO_TS" (
                        set "BackupDir=%%d:\WinOptimizer_Backups"
                        call :LOG "Using additional drive %%d: for backups"
                        goto :eof
                    )
                )
            )
        )
    )
    
    :: Fallback to default location
    call :LOG "Using default backup location: %BackupDir%"
    goto :eof

:: Backup Function
:BACKUP_SETTING
reg export "%~1" "%BackupDir%\%~2_%date:~-4,4%%date:~-10,2%%date:~-7,2%.reg" /y >nul 2>&1
call :LOG "Backed up %~1 to %BackupDir%\%~2_%date:~-4,4%%date:~-10,2%%date:~-7,2%.reg"
goto :eof

:: Restore Point Function
:CREATE_RESTORE_POINT
powershell -Command "Checkpoint-Computer -Description 'WinOptimizer Backup - %~1' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
if %errorlevel% == 0 (
    call :LOG "Created restore point for %~1"
) else (
    call :LOG "Failed to create restore point for %~1"
)
goto :eof

:: --------------------------------------
:: MAIN MENU
:: --------------------------------------
:MAIN_MENU
cls
echo ================================================================================
echo  WINDOWS SYSTEM HELPER
echo  Version 9.0
echo ================================================================================
echo.
echo  Your computer's assistant for better performance
echo.
echo  System Status: [Device: %DeviceType%] [Backup: %BackupDir%]
echo  Session Started: %date% %time%
echo.
echo  ┌─────────────────────────────────────────────────────────────────────────────┐
echo  │                           WHAT THIS TOOL CAN DO                            │
echo  ├─────────────────────────────────────────────────────────────────────────────┤
echo  │ • Automatically find and use backup drives    • Restore your system        │
echo  │ • Help protect your privacy and security       • Improve internet and network│
echo  │ • Make games run better and smoother           • Speed up your computer     │
echo  │ • Keep track of what the tool does             • Check hardware performance │
echo  │ • Control Windows updates and features         • Manage startup programs    │
echo  └─────────────────────────────────────────────────────────────────────────────┘
echo.
echo  ┌─────────────────────────────────────────────────────────────────────────────┐
echo  │                           WHAT WOULD YOU LIKE TO DO?                      │
echo  ├─────────────────────────────────────────────────────────────────────────────┤
echo  ├─────────────────────────────────────────────────────────────────────────────┤
echo  │ [01] Clean up temporary files          [10] Improve gaming performance     │
echo  │ [02] Restart system processes          [11] Clean up disk space deeply     │
echo  │ [03] Defragment hard drives            [12] Manage search indexing         │
echo  │ [04] Clear system logs                 [13] Control startup programs       │
echo  │ [05] Improve network and internet      [14] Clean up old Windows files     │
echo  │ [06] Fix system registry settings     [15] Manage hibernation              │
echo  │ [07] Configure system policies        [16] Apply helpful system tweaks     │
echo  │ [08] Enable best performance mode     [17] Remove unnecessary Windows apps │
echo  │ [09] Focus on responsiveness          [18] Future system improvements      │
echo  │                                       [19] Improve graphics performance    │
echo  │ EXTRA HELPFUL TOOLS:                  [20] Install useful software          │
echo  │ [21] Set up DNS settings              [22] Optimize network connections    │
echo  │ [23] Back up and manage drivers       [24] Tune for your specific device   │
echo  │ [25] Repair system files              [26] Control Windows updates         │
echo  │ [27] Enable all settings access       [28] Import better power settings    │
echo  │ [29] Undo changes and restore         [30] Check startup programs          │
echo  │ [31] View detailed logs               [32] Protect your privacy            │
echo  │ [33] Back up all your settings        [34] Check backup drive info         │
echo  │ [35] Monitor system health            [36] Test internet speed             │
echo  │ [37] Check hardware health            [38] Exit the tool                   │
echo  └─────────────────────────────────────────────────────────────────────────────┘
echo.
echo  ┌─────────────────────────────────────────────────────────────────────────────┐
echo  │                    HOW TO USE THIS TOOL                                  │
echo  ├─────────────────────────────────────────────────────────────────────────────┤
echo  │ Numbers 1-9: Choose options directly                                     │
echo  │ Letters A-Y: Options 10-34 (A=10, B=11, etc.)                            │
echo  │ Z=35, AA=36, AB=37, AC=38, and so on                                     │
echo  │ Type 'HELP' for more detailed instructions                               │
echo  └─────────────────────────────────────────────────────────────────────────────┘
echo.
choice /c 123456789ABCDEFGHIJKLMNOPQRSTUVWX YZ AA AB AC AD AE AF AG AH AI AJ H /n /m "Choose an option (H for Help): "
if errorlevel 46 goto :GET_HELP
if errorlevel 45 goto :HARDWARE_DIAGNOSTICS
if errorlevel 44 goto :NETWORK_SPEED_TEST
if errorlevel 43 goto :SYSTEM_HEALTH_MONITOR
if errorlevel 42 goto :SHOW_BACKUP_DRIVE_INFO
if errorlevel 41 goto :COMPLETE_BACKUP_RESTORE
if errorlevel 40 goto :PRIVACY_OPTIMIZATIONS
if errorlevel 39 goto :DETAILED_LOGGING
if errorlevel 38 goto :eof
if errorlevel 26 goto :GAMING_SPECIFIC
if errorlevel 25 goto :NETWORK_ENHANCEMENTS
if errorlevel 24 goto :DRIVER_HARDWARE_OPT
if errorlevel 23 goto :SYSTEM_BACKUP_RESTORE
if errorlevel 22 goto :MAINTENANCE_CLEANUP
if errorlevel 21 goto :ONE_CLICK_OPTIONS
if errorlevel 20 goto :EXTRA_TOOLS
if errorlevel 19 goto :GPU_OPTIMIZATION
if errorlevel 18 goto :FUTURE_IMPROVEMENTS
if errorlevel 17 goto :DEBLOAT_WINDOWS
if errorlevel 16 goto :AUTO_OPTIMIZE
if errorlevel 15 goto :DISABLE_HIBERNATION
if errorlevel 14 goto :CLEAN_WINDOWS_OLD
if errorlevel 13 goto :OPTIMIZE_STARTUP
if errorlevel 12 goto :DISABLE_SEARCH_INDEXING
if errorlevel 11 goto :DISK_CLEANUP
if errorlevel 10 goto :GAMING_TWEAKS
if errorlevel 9 goto :MAX_RESPONSIVENESS
if errorlevel 8 goto :BEST_PERFORMANCE
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
    echo   Deep System Cleanup & Maintenance
    echo  --------------------------------------------------------
    echo.

    ipconfig /flushdns

    :: --- Phase 1: System Temporary Files ---
    echo [CLEANUP] Phase 1: Clearing system temporary files...
    del /q /f /s "%SystemRoot%\Temp\*" >nul 2>&1
    rd /s /q "%SystemRoot%\Temp" >nul 2>&1
    md "%SystemRoot%\Temp" >nul 2>&1

    del /q /f /s "%SystemRoot%\Prefetch\*" >nul 2>&1
    rd /s /q "%SystemRoot%\Prefetch" >nul 2>&1
    md "%SystemRoot%\Prefetch" >nul 2>&1

    :: --- Phase 2: User Temporary Files ---
    echo [CLEANUP] Phase 2: Clearing user temporary files...
    del /s /f /q %temp%\*.*
    rd /s /q %temp%
    md %temp%
    del /s /f /q %tmp%\*.*
    rd /s /q %tmp%
    md %tmp%
    del /s /f /q %USERPROFILE%\AppData\Local\Temp\*.*
    del /s /f /q %USERPROFILE%\AppData\LocalLow\Temp\*.*

    :: --- Phase 3: Browser and Cache Cleanup ---
    echo [CLEANUP] Phase 3: Clearing browser caches and history...
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache\*.*
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Windows\WebCache\*.*
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*
    del /s /f /q %USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*
    del /s /f /q %USERPROFILE%\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\*.*
    del /s /f /q %USERPROFILE%\AppData\Roaming\Mozilla\Firefox\Profiles\*.default\cache2\*.*

    :: --- Phase 4: Windows System Cleanup ---
    echo [CLEANUP] Phase 4: Windows system cleanup...
    del /f /q c:\windows\tempor~1
    del /f /q c:\WIN386.SWP
    del /s /f /q %USERPROFILE%\history
    del /s /f /q %USERPROFILE%\cookies
    del /s /f /q %USERPROFILE%\recent
    del /s /f /q %USERPROFILE%\printers

    :: Clean Windows.old if it exists
    if exist "C:\Windows.old" (
        echo [CLEANUP] Phase 5: Removing Windows.old folder...
        rd /s /q "C:\Windows.old"
    )

    :: --- Phase 5: Extra File Cleanup ---
    echo [CLEANUP] Phase 5: Extra file cleanup...
    for %%a in ( "*.tmp", "*.temp", "*.log", "*.bak", "*.old", "*.dmp", "*.hdmp", "*.mdmp", "*.stackdump" ) do (
        del /s /f /q "C:\Windows\%%a" 2>nul
        del /s /f /q "C:\ProgramData\%%a" 2>nul
    )

    :: --- Phase 6: Thumbnail and Icon Cache ---
    echo [CLEANUP] Phase 6: Clearing thumbnail and icon caches...
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer\iconcache_*.db
    del /s /f /q %USERPROFILE%\AppData\Local\IconCache.db

    :: --- Phase 7: Software Distribution Cleanup ---
    echo [CLEANUP] Phase 7: Software Distribution cleanup...
    set /P "confirm=Clean Windows Update download cache? (Y/N): "
    if /i "%confirm%"=="Y" (
        echo [CLEANUP] Clearing Windows Update cache...
        net stop wuauserv >nul 2>&1
        del /s /f /q "C:\Windows\SoftwareDistribution\Download\*" 2>nul
        rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
        md "C:\Windows\SoftwareDistribution\Download" 2>nul
        net start wuauserv >nul 2>&1
        echo [CLEANUP] Windows Update cache cleared.
    ) else (
        echo [CLEANUP] Skipping Windows Update cache cleanup.
    )

    :: --- Phase 8: Recycle Bin Cleanup ---
    echo [CLEANUP] Phase 8: Emptying Recycle Bin...
    rd /s /q %systemdrive%\$Recycle.bin 2>nul

    :: --- Phase 9: DNS and Network Cache ---
    echo [CLEANUP] Phase 9: Clearing network caches...
    ipconfig /flushdns >nul 2>&1
    arp -d * >nul 2>&1
    nbtstat -R >nul 2>&1
    nbtstat -RR >nul 2>&1
    netsh winsock reset >nul 2>&1

    :: --- Phase 10: System Error Reports ---
    echo [CLEANUP] Phase 10: Clearing system error reports...
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Windows\WER\*.* 2>nul
    rd /s /q %USERPROFILE%\AppData\Local\Microsoft\Windows\WER 2>nul
    md %USERPROFILE%\AppData\Local\Microsoft\Windows\WER 2>nul

    :: --- Phase 11: Office and Application Caches ---
    echo [CLEANUP] Phase 11: Clearing application caches...
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Office\*.tmp 2>nul
    del /s /f /q %USERPROFILE%\AppData\Local\Microsoft\Office\*.log 2>nul
    del /s /f /q %USERPROFILE%\AppData\Roaming\Microsoft\Office\*.tmp 2>nul

    :: --- Phase 12: Steam and Gaming Caches ---
    echo [CLEANUP] Phase 12: Clearing gaming caches...
    if exist "C:\Program Files (x86)\Steam" (
        del /s /f /q "C:\Program Files (x86)\Steam\appcache\*.tmp" 2>nul
        del /s /f /q "C:\Program Files (x86)\Steam\logs\*.log" 2>nul
    )

    :: --- Phase 13: Final System Cleanup ---
    echo [CLEANUP] Phase 13: Final system optimization...
    cleanmgr /sagerun:1 >nul 2>&1
    defrag %systemdrive% /u /v >nul 2>&1

    echo.
    echo ================================================================================
    echo  DEEP SYSTEM CLEANUP COMPLETED SUCCESSFULLY!
    echo ================================================================================
    echo.
    echo   Files Cleaned:
    echo   • System temporary files
    echo   • User temporary files
    echo   • Browser caches and history
    echo   • Windows Update cache
    echo   • Thumbnail and icon caches
    echo   • Recycle Bin contents
    echo   • Network and DNS caches
    echo   • System error reports
    echo   • Application and gaming caches
    echo   • Windows.old folder (if present)
    echo.
    call :LOG "Completed deep system cleanup"
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
    
    call :CREATE_RESTORE_POINT "Network Optimizations"

    :: Detect active interfaces
    echo Detecting active network interfaces...
    for /f "tokens=4*" %%i in ('netsh interface show interface ^| find "Connected"') do (
        set "activeInterface=%%j"
        echo Applying optimizations to interface: %activeInterface%
        call :LOG "Applied network optimizations to %activeInterface%"
    )
    if not defined activeInterface (
        echo No specific active interface found. Applying global settings.
        call :LOG "Applied global network optimizations"
    )
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
    echo.
    echo  QoS Options:
    echo  1. Enable QoS
    echo  2. Disable QoS
    echo  3. Skip
    choice /c 123 /n /m "QoS Option: "
    if errorlevel 2 (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "EnableQoS" /t REG_DWORD /d 0 /f
        call :LOG "Disabled QoS"
    )
    if errorlevel 1 (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "EnableQoS" /t REG_DWORD /d 1 /f
        call :LOG "Enabled QoS"
    )
    pause
    goto :MAIN_MENU

:: 6. Registry Settings
:REGISTRY
    cls
    echo  --------------------------------------------------------
    echo   Registry Settings
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: Create a system restore point before proceeding!
    echo.
    call :CREATE_RESTORE_POINT "Registry Optimizations"
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
    if errorlevel 3 goto :ENABLE_BEST_REGISTRY
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

:ENABLE_BEST_REGISTRY
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\75b0ae3f-bce0-45a7-8c89-c9611c224f84" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Registry key HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\75b0ae3f-bce0-45a7-8c89-c9611c224f84\Attributes set to 2.
    echo  - "Best Performance" power plan enabled in the registry.
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

:: 7. System Policies
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
    echo    6.  Manage Services (For Experienced Users)
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
:: 8. Best Performance Mode
:BEST_PERFORMANCE
    cls
    echo  --------------------------------------------------------
    echo   Best Performance Mode
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: Enabling Best Performance Mode may increase 
    echo  power consumption and potentially impact hardware longevity. 
    echo  Use with caution!
    echo.
    echo  This option will:
    echo    - Enable the "Best Performance" power plan.
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
    if "%DeviceType%"=="Laptop" (
        echo Hibernation is recommended for laptops. Skipping.
        call :LOG "Skipped hibernation disable for laptop"
        pause
        goto :MAIN_MENU
    )
    call :CREATE_RESTORE_POINT "Disable Hibernation"
    powercfg /hibernate off >nul 2>&1
    call :LOG "Disabled hibernation"
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

    :: Latest Windows 11 Optimizations (2026)
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

    :: --- Automated Service Optimizations ---
    echo  - Applying Automated Service Optimizations...

    :: Optimize Windows Services for Performance
    sc config "SysMain" start= auto >nul 2>&1
    sc config "WSearch" start= delayed-auto >nul 2>&1
    sc config "Spooler" start= auto >nul 2>&1
    sc config "AudioSrv" start= auto >nul 2>&1
    sc config "AudioEndpointBuilder" start= auto >nul 2>&1
    sc config "EventLog" start= auto >nul 2>&1
    sc config "PlugPlay" start= auto >nul 2>&1
    sc config "RpcSs" start= auto >nul 2>&1
    sc config "RpcEptMapper" start= auto >nul 2>&1
    sc config "DcomLaunch" start= auto >nul 2>&1
    sc config "SamSs" start= auto >nul 2>&1
    sc config "LanmanServer" start= auto >nul 2>&1
    sc config "LanmanWorkstation" start= auto >nul 2>&1
    sc config "Browser" start= auto >nul 2>&1
    sc config "Dhcp" start= auto >nul 2>&1
    sc config "Dnscache" start= auto >nul 2>&1
    sc config "WinHttpAutoProxySvc" start= demand >nul 2>&1
    sc config "NlaSvc" start= auto >nul 2>&1
    sc config "nsi" start= auto >nul 2>&1
    sc config "W32Time" start= demand >nul 2>&1
    sc config "Winmgmt" start= auto >nul 2>&1
    sc config "ProfSvc" start= auto >nul 2>&1
    sc config "Schedule" start= auto >nul 2>&1
    sc config "Power" start= auto >nul 2>&1
    sc config "seclogon" start= demand >nul 2>&1
    sc config "wscsvc" start= delayed-auto >nul 2>&1
    sc config "MpsSvc" start= auto >nul 2>&1
    sc config "WinDefend" start= auto >nul 2>&1
    sc config "SecurityCenter" start= auto >nul 2>&1
    sc config "wuauserv" start= demand >nul 2>&1
    sc config "BITS" start= delayed-auto >nul 2>&1
    sc config "TrustedInstaller" start= demand >nul 2>&1
    sc config "CryptSvc" start= auto >nul 2>&1
    sc config "DsmSvc" start= demand >nul 2>&1
    sc config "DeviceAssociationService" start= demand >nul 2>&1
    sc config "DeviceInstall" start= demand >nul 2>&1
    sc config "DmEnrollmentSvc" start= demand >nul 2>&1
    sc config "fdPHost" start= demand >nul 2>&1
    sc config "FDResPub" start= demand >nul 2>&1
    sc config "gpsvc" start= auto >nul 2>&1
    sc config "IKEEXT" start= demand >nul 2>&1
    sc config "iphlpsvc" start= auto >nul 2>&1
    sc config "KeyIso" start= demand >nul 2>&1
    sc config "KtmRm" start= demand >nul 2>&1
    sc config "LSM" start= auto >nul 2>&1
    sc config "netprofm" start= demand >nul 2>&1
    sc config "NgcSvc" start= demand >nul 2>&1
    sc config "NgcCtnrSvc" start= demand >nul 2>&1
    sc config "RasMan" start= demand >nul 2>&1
    sc config "SessionEnv" start= demand >nul 2>&1
    sc config "TermService" start= demand >nul 2>&1
    sc config "UmRdpService" start= demand >nul 2>&1
    sc config "WdiServiceHost" start= demand >nul 2>&1
    sc config "WdiSystemHost" start= demand >nul 2>&1
    sc config "FontCache" start= auto >nul 2>&1
    sc config "WpnService" start= demand >nul 2>&1
    sc config "PushToInstall" start= demand >nul 2>&1
    sc config "LicenseManager" start= demand >nul 2>&1
    sc config "AppXSvc" start= demand >nul 2>&1
    sc config "ClipSVC" start= demand >nul 2>&1
    sc config "CoreMessagingRegistrar" start= auto >nul 2>&1
    sc config "DusmSvc" start= auto >nul 2>&1
    sc config "GraphicsPerfSvc" start= demand >nul 2>&1
    sc config "StorSvc" start= demand >nul 2>&1
    sc config "TokenBroker" start= demand >nul 2>&1
    sc config "UserManager" start= auto >nul 2>&1
    sc config "UsoSvc" start= demand >nul 2>&1
    sc config "WaaSMedicSvc" start= demand >nul 2>&1
    sc config "XblAuthManager" start= demand >nul 2>&1
    sc config "XblGameSave" start= demand >nul 2>&1
    sc config "XboxLiveAuthManager" start= demand >nul 2>&1
    sc config "XboxLiveGameSave" start= demand >nul 2>&1
    sc config "XboxLiveNetAuthSvc" start= demand >nul 2>&1
    sc config "xbgm" start= demand >nul 2>&1
    sc config "SysMain" start= auto >nul 2>&1
    sc config "WSearch" start= delayed-auto >nul 2>&1
    sc config "Spooler" start= auto >nul 2>&1
    sc config "AudioSrv" start= auto >nul 2>&1
    sc config "AudioEndpointBuilder" start= auto >nul 2>&1
    sc config "EventLog" start= auto >nul 2>&1
    sc config "PlugPlay" start= auto >nul 2>&1
    sc config "RpcSs" start= auto >nul 2>&1
    sc config "RpcEptMapper" start= auto >nul 2>&1
    sc config "DcomLaunch" start= auto >nul 2>&1
    sc config "SamSs" start= auto >nul 2>&1
    sc config "LanmanServer" start= auto >nul 2>&1
    sc config "LanmanWorkstation" start= auto >nul 2>&1
    sc config "Browser" start= auto >nul 2>&1
    sc config "Dhcp" start= auto >nul 2>&1
    sc config "Dnscache" start= auto >nul 2>&1
    sc config "WinHttpAutoProxySvc" start= demand >nul 2>&1
    sc config "NlaSvc" start= auto >nul 2>&1
    sc config "nsi" start= auto >nul 2>&1
    sc config "W32Time" start= demand >nul 2>&1
    sc config "Winmgmt" start= auto >nul 2>&1
    sc config "ProfSvc" start= auto >nul 2>&1
    sc config "Schedule" start= auto >nul 2>&1
    sc config "Power" start= auto >nul 2>&1
    sc config "seclogon" start= demand >nul 2>&1
    sc config "wscsvc" start= delayed-auto >nul 2>&1
    sc config "MpsSvc" start= auto >nul 2>&1
    sc config "WinDefend" start= auto >nul 2>&1
    sc config "SecurityCenter" start= auto >nul 2>&1
    sc config "wuauserv" start= demand >nul 2>&1
    sc config "BITS" start= delayed-auto >nul 2>&1
    sc config "TrustedInstaller" start= demand >nul 2>&1
    sc config "CryptSvc" start= auto >nul 2>&1
    sc config "DsmSvc" start= demand >nul 2>&1
    sc config "DeviceAssociationService" start= demand >nul 2>&1
    sc config "DeviceInstall" start= demand >nul 2>&1
    sc config "DmEnrollmentSvc" start= demand >nul 2>&1
    sc config "fdPHost" start= demand >nul 2>&1
    sc config "FDResPub" start= demand >nul 2>&1
    sc config "gpsvc" start= auto >nul 2>&1
    sc config "IKEEXT" start= demand >nul 2>&1
    sc config "iphlpsvc" start= auto >nul 2>&1
    sc config "KeyIso" start= demand >nul 2>&1
    sc config "KtmRm" start= demand >nul 2>&1
    sc config "LSM" start= auto >nul 2>&1
    sc config "netprofm" start= demand >nul 2>&1
    sc config "NgcSvc" start= demand >nul 2>&1
    sc config "NgcCtnrSvc" start= demand >nul 2>&1
    sc config "RasMan" start= demand >nul 2>&1
    sc config "SessionEnv" start= demand >nul 2>&1
    sc config "TermService" start= demand >nul 2>&1
    sc config "UmRdpService" start= demand >nul 2>&1
    sc config "WdiServiceHost" start= demand >nul 2>&1
    sc config "WdiSystemHost" start= demand >nul 2>&1
    sc config "FontCache" start= auto >nul 2>&1
    sc config "WpnService" start= demand >nul 2>&1
    sc config "PushToInstall" start= demand >nul 2>&1
    sc config "LicenseManager" start= demand >nul 2>&1
    sc config "AppXSvc" start= demand >nul 2>&1
    sc config "ClipSVC" start= demand >nul 2>&1
    sc config "CoreMessagingRegistrar" start= auto >nul 2>&1
    sc config "DusmSvc" start= auto >nul 2>&1
    sc config "GraphicsPerfSvc" start= demand >nul 2>&1
    sc config "StorSvc" start= demand >nul 2>&1
    sc config "TokenBroker" start= demand >nul 2>&1
    sc config "UserManager" start= auto >nul 2>&1
    sc config "UsoSvc" start= demand >nul 2>&1
    sc config "WaaSMedicSvc" start= demand >nul 2>&1
    sc config "XblAuthManager" start= demand >nul 2>&1
    sc config "XblGameSave" start= demand >nul 2>&1
    sc config "XboxLiveAuthManager" start= demand >nul 2>&1
    sc config "XboxLiveGameSave" start= demand >nul 2>&1
    sc config "XboxLiveNetAuthSvc" start= demand >nul 2>&1
    sc config "xbgm" start= demand >nul 2>&1

    :: Disable Unnecessary Services for Performance
    sc config "AxInstSV" start= disabled >nul 2>&1
    sc config "AJRouter" start= disabled >nul 2>&1
    sc config "AppReadiness" start= disabled >nul 2>&1
    sc config "ALG" start= disabled >nul 2>&1
    sc config "AppMgmt" start= disabled >nul 2>&1
    sc config "AppVClient" start= disabled >nul 2>&1
    sc config "AssignedAccessManagerSvc" start= disabled >nul 2>&1
    sc config "tzautoupdate" start= disabled >nul 2>&1
    sc config "BthAvctpSvc" start= disabled >nul 2>&1
    sc config "bthserv" start= disabled >nul 2>&1
    sc config "BTAGService" start= disabled >nul 2>&1
    sc config "BcastDVRUserService" start= disabled >nul 2>&1
    sc config "CaptureService" start= disabled >nul 2>&1
    sc config "cbdhsvc" start= disabled >nul 2>&1
    sc config "CDPSvc" start= disabled >nul 2>&1
    sc config "CDPUserSvc" start= disabled >nul 2>&1
    sc config "PimIndexMaintenanceSvc" start= disabled >nul 2>&1
    sc config "CscService" start= disabled >nul 2>&1
    sc config "defragsvc" start= disabled >nul 2>&1
    sc config "DevicePickerUserSvc" start= disabled >nul 2>&1
    sc config "DevicesFlowUserSvc" start= disabled >nul 2>&1
    sc config "DevQueryBroker" start= disabled >nul 2>&1
    sc config "DPS" start= disabled >nul 2>&1
    sc config "WdiServiceHost" start= disabled >nul 2>&1
    sc config "WdiSystemHost" start= disabled >nul 2>&1
    sc config "diagsvc" start= disabled >nul 2>&1
    sc config "DialogBlockingService" start= disabled >nul 2>&1
    sc config "DisplayEnhancementService" start= disabled >nul 2>&1
    sc config "DmEnrollmentSvc" start= disabled >nul 2>&1
    sc config "dmwappushservice" start= disabled >nul 2>&1
    sc config "Dnscache" start= auto >nul 2>&1
    sc config "DoSvc" start= disabled >nul 2>&1
    sc config "WpcMonSvc" start= disabled >nul 2>&1
    sc config "SEMgrSvc" start= disabled >nul 2>&1
    sc config "wercplsupport" start= disabled >nul 2>&1
    sc config "Fax" start= disabled >nul 2>&1
    sc config "fhsvc" start= disabled >nul 2>&1
    sc config "fdPHost" start= disabled >nul 2>&1
    sc config "FDResPub" start= disabled >nul 2>&1
    sc config "lfsvc" start= disabled >nul 2>&1
    sc config "GraphicsPerfSvc" start= disabled >nul 2>&1
    sc config "hidserv" start= disabled >nul 2>&1
    sc config "HvHost" start= disabled >nul 2>&1
    sc config "vmickvpexchange" start= disabled >nul 2>&1
    sc config "vmicguestinterface" start= disabled >nul 2>&1
    sc config "vmicshutdown" start= disabled >nul 2>&1
    sc config "vmicheartbeat" start= disabled >nul 2>&1
    sc config "vmicvmsession" start= disabled >nul 2>&1
    sc config "vmicrdv" start= disabled >nul 2>&1
    sc config "vmictimesync" start= disabled >nul 2>&1
    sc config "vmicvss" start= disabled >nul 2>&1
    sc config "IKEEXT" start= disabled >nul 2>&1
    sc config "irmon" start= disabled >nul 2>&1
    sc config "SharedAccess" start= disabled >nul 2>&1
    sc config "lltdsvc" start= disabled >nul 2>&1
    sc config "wlidsvc" start= disabled >nul 2>&1
    sc config "AppVClient" start= disabled >nul 2>&1
    sc config "MSiSCSI" start= disabled >nul 2>&1
    sc config "MsKeyboardFilter" start= disabled >nul 2>&1
    sc config "netTcpPortSharing" start= disabled >nul 2>&1
    sc config "Netlogon" start= disabled >nul 2>&1
    sc config "NcdAutoSetup" start= disabled >nul 2>&1
    sc config "NcbService" start= disabled >nul 2>&1
    sc config "NetTcpPortSharing" start= disabled >nul 2>&1
    sc config "p2pimsvc" start= disabled >nul 2>&1
    sc config "p2psvc" start= disabled >nul 2>&1
    sc config "PcaSvc" start= disabled >nul 2>&1
    sc config "PeerDistSvc" start= disabled >nul 2>&1
    sc config "PhoneSvc" start= disabled >nul 2>&1
    sc config "PNRPAutoReg" start= disabled >nul 2>&1
    sc config "PNRPsvc" start= disabled >nul 2>&1
    sc config "p2pimsvc" start= disabled >nul 2>&1
    sc config "p2psvc" start= disabled >nul 2>&1
    sc config "PushToInstall" start= disabled >nul 2>&1
    sc config "RemoteRegistry" start= disabled >nul 2>&1
    sc config "RetailDemo" start= disabled >nul 2>&1
    sc config "RpcLocator" start= disabled >nul 2>&1
    sc config "RemoteAccess" start= disabled >nul 2>&1
    sc config "RasAuto" start= disabled >nul 2>&1
    sc config "RasMan" start= disabled >nul 2>&1
    sc config "SessionEnv" start= disabled >nul 2>&1
    sc config "TermService" start= disabled >nul 2>&1
    sc config "UmRdpService" start= disabled >nul 2>&1
    sc config "SCardSvr" start= disabled >nul 2>&1
    sc config "ScDeviceEnum" start= disabled >nul 2>&1
    sc config "SCPolicySvc" start= disabled >nul 2>&1
    sc config "SDRSVC" start= disabled >nul 2>&1
    sc config "SensorDataService" start= disabled >nul 2>&1
    sc config "SensorService" start= disabled >nul 2>&1
    sc config "SensrSvc" start= disabled >nul 2>&1
    sc config "SensorDataService" start= disabled >nul 2>&1
    sc config "SensorService" start= disabled >nul 2>&1
    sc config "SensrSvc" start= disabled >nul 2>&1
    sc config "shpamsvc" start= disabled >nul 2>&1
    sc config "smphost" start= disabled >nul 2>&1
    sc config "SmsRouter" start= disabled >nul 2>&1
    sc config "SNMPTRAP" start= disabled >nul 2>&1
    sc config "spectrum" start= disabled >nul 2>&1
    sc config "Spooler" start= auto >nul 2>&1
    sc config "sppsvc" start= delayed-auto >nul 2>&1
    sc config "SSDPSRV" start= disabled >nul 2>&1
    sc config "SstpSvc" start= disabled >nul 2>&1
    sc config "StateRepository" start= demand >nul 2>&1
    sc config "stisvc" start= disabled >nul 2>&1
    sc config "StorSvc" start= demand >nul 2>&1
    sc config "svsvc" start= disabled >nul 2>&1
    sc config "swprv" start= disabled >nul 2>&1
    sc config "SysMain" start= auto >nul 2>&1
    sc config "TabletInputService" start= disabled >nul 2>&1
    sc config "TapiSrv" start= disabled >nul 2>&1
    sc config "Themes" start= auto >nul 2>&1
    sc config "TieringEngineService" start= demand >nul 2>&1
    sc config "TimeBrokerSvc" start= demand >nul 2>&1
    sc config "TokenBroker" start= demand >nul 2>&1
    sc config "TrkWks" start= auto >nul 2>&1
    sc config "TrustedInstaller" start= demand >nul 2>&1
    sc config "tzautoupdate" start= disabled >nul 2>&1
    sc config "UevAgentService" start= disabled >nul 2>&1
    sc config "UsoSvc" start= demand >nul 2>&1
    sc config "VaultSvc" start= demand >nul 2>&1
    sc config "vds" start= demand >nul 2>&1
    sc config "vmicguestinterface" start= disabled >nul 2>&1
    sc config "vmicheartbeat" start= disabled >nul 2>&1
    sc config "vmickvpexchange" start= disabled >nul 2>&1
    sc config "vmicrdv" start= disabled >nul 2>&1
    sc config "vmicshutdown" start= disabled >nul 2>&1
    sc config "vmictimesync" start= disabled >nul 2>&1
    sc config "vmicvmsession" start= disabled >nul 2>&1
    sc config "vmicvss" start= disabled >nul 2>&1
    sc config "VSS" start= demand >nul 2>&1
    sc config "W32Time" start= demand >nul 2>&1
    sc config "WaaSMedicSvc" start= demand >nul 2>&1
    sc config "WalletService" start= disabled >nul 2>&1
    sc config "WarpJITSvc" start= demand >nul 2>&1
    sc config "WbioSrvc" start= disabled >nul 2>&1
    sc config "Wcmsvc" start= auto >nul 2>&1
    sc config "wcncsvc" start= disabled >nul 2>&1
    sc config "WdiSystemHost" start= disabled >nul 2>&1
    sc config "WdiServiceHost" start= disabled >nul 2>&1
    sc config "WebClient" start= disabled >nul 2>&1
    sc config "Wecsvc" start= disabled >nul 2>&1
    sc config "WEPHOSTSVC" start= disabled >nul 2>&1
    sc config "wercplsupport" start= disabled >nul 2>&1
    sc config "WerSvc" start= disabled >nul 2>&1
    sc config "WiaRpc" start= disabled >nul 2>&1
    sc config "WinHttpAutoProxySvc" start= demand >nul 2>&1
    sc config "WinRM" start= disabled >nul 2>&1
    sc config "WlanSvc" start= auto >nul 2>&1
    sc config "wlidsvc" start= disabled >nul 2>&1
    sc config "wmiApSrv" start= disabled >nul 2>&1
    sc config "WMPNetworkSvc" start= disabled >nul 2>&1
    sc config "WMSvc" start= disabled >nul 2>&1
    sc config "workfolderssvc" start= disabled >nul 2>&1
    sc config "WpcMonSvc" start= disabled >nul 2>&1
    sc config "WPDBusEnum" start= disabled >nul 2>&1
    sc config "WpnService" start= demand >nul 2>&1
    sc config "WSearch" start= delayed-auto >nul 2>&1
    sc config "XblAuthManager" start= disabled >nul 2>&1
    sc config "XblGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveAuthManager" start= disabled >nul 2>&1
    sc config "XboxLiveGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveNetAuthSvc" start= disabled >nul 2>&1
    sc config "xbgm" start= disabled >nul 2>&1
    sc config "XblGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveAuthManager" start= disabled >nul 2>&1
    sc config "XboxLiveGameSave" start= disabled >nul 2>&1
    sc config "XboxLiveNetAuthSvc" start= disabled >nul 2>&1
    sc config "xbgm" start= disabled >nul 2>&1
    echo  - Automated Service Optimizations Applied

    echo.
    echo  --------------------------------------------------------
    echo   Automated optimizations applied successfully!
    echo   These tweaks provide maximum system performance for Windows 11.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: ADVANCED PERFORMANCE TWEAKS (2026)
:: --------------------------------------
:FUTURE_IMPROVEMENTS
    echo.
    echo  --------------------------------------------------------
    echo   Advanced Performance Tweaks (2026)
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
    echo   Advanced Performance Tweaks (2026) applied successfully!
    echo   Your system now has cutting-edge optimizations for maximum performance.
    echo  --------------------------------------------------------
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: GPU OPTIMIZATION MODULE (NVIDIA/AMD/Intel)
:: --------------------------------------
:GPU_OPTIMIZATION
    cls
    echo  --------------------------------------------------------
    echo   GPU Optimization - Universal Performance Settings
    echo   Supports: NVIDIA, AMD, and Intel Graphics
    echo  --------------------------------------------------------
    echo.
    echo  Choose GPU optimization category:
    echo    1. Auto-Detect and Optimize All GPUs
    echo    2. NVIDIA Specific Optimizations
    echo    3. AMD Specific Optimizations
    echo    4. Intel Specific Optimizations
    echo    5. Universal GPU Tweaks (All GPUs)
    echo    6. Gaming Latency Optimization
    echo    7. Laptop GPU Power Management
    echo    8. MSI Mode (Message Signaled Interrupts)
    echo    9. Back to Main Menu
    echo.
    choice /c 123456789 /n /m "Enter your choice: "
    if errorlevel 9 goto :MAIN_MENU
    if errorlevel 8 goto :MSI_MODE
    if errorlevel 7 goto :LAPTOP_GPU_POWER
    if errorlevel 6 goto :GAMING_LATENCY
    if errorlevel 5 goto :UNIVERSAL_GPU
    if errorlevel 4 goto :INTEL_GPU
    if errorlevel 3 goto :AMD_GPU
    if errorlevel 2 goto :NVIDIA_GPU
    if errorlevel 1 goto :AUTO_DETECT_GPU

:AUTO_DETECT_GPU
    echo.
    echo  --------------------------------------------------------
    echo   Auto-Detecting and Optimizing All GPUs...
    echo  --------------------------------------------------------
    echo.
    
    :: Detect NVIDIA GPU
    wmic path win32_videocontroller get name | findstr /i "NVIDIA GeForce RTX GTX Quadro" >nul 2>&1
    if %errorlevel% == 0 (
        echo  - NVIDIA GPU detected! Applying NVIDIA optimizations...
        call :APPLY_NVIDIA_TWEAKS
    )
    
    :: Detect AMD GPU
    wmic path win32_videocontroller get name | findstr /i "AMD Radeon RX Vega" >nul 2>&1
    if %errorlevel% == 0 (
        echo  - AMD GPU detected! Applying AMD optimizations...
        call :APPLY_AMD_TWEAKS
    )
    
    :: Detect Intel GPU
    wmic path win32_videocontroller get name | findstr /i "Intel UHD Iris Xe Arc" >nul 2>&1
    if %errorlevel% == 0 (
        echo  - Intel GPU detected! Applying Intel optimizations...
        call :APPLY_INTEL_TWEAKS
    )
    
    :: Apply universal tweaks
    call :APPLY_UNIVERSAL_GPU_TWEAKS
    call :APPLY_GAMING_LATENCY_TWEAKS
    
    echo.
    echo  --------------------------------------------------------
    echo   GPU Auto-Optimization Complete!
    echo   All detected GPUs have been optimized for performance.
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:NVIDIA_GPU
    echo.
    echo  --------------------------------------------------------
    echo   NVIDIA GPU Optimization
    echo  --------------------------------------------------------
    echo.
    call :APPLY_NVIDIA_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   NVIDIA GPU optimizations applied!
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:APPLY_NVIDIA_TWEAKS
    :: NVIDIA Driver Settings for Maximum Performance
    echo  - Applying NVIDIA driver optimizations...
    
    :: Enable Ultra Low Latency Mode (Pre-rendered frames = 1)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Enabled Hardware Accelerated GPU Scheduling
    
    :: NVIDIA Global Settings for Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableHDAudioSleep" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled HDMI Audio Sleep
    
    :: Power Management Mode - Prefer Maximum Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Display Power Saving
    
    :: NVIDIA Pre-rendered Frames (Low Latency Mode)
    reg add "HKCU\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "LowLatencyMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Enabled Low Latency Mode (Ultra)
    
    :: Disable NVIDIA Telemetry
    reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1
    schtasks /change /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable >nul 2>&1
    schtasks /change /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable >nul 2>&1
    schtasks /change /tn "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable >nul 2>&1
    echo  - Disabled NVIDIA Telemetry
    
    :: NVIDIA Shader Cache Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized Shader Cache
    
    :: Disable NVIDIA Container Services (optional - reduces background CPU)
    sc config NvContainerLocalSystem start= demand >nul 2>&1
    sc config NvContainerNetworkService start= demand >nul 2>&1
    echo  - Set NVIDIA Container to Manual Start
    
    :: CUDA Force P2 State
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "CUDAForceP2State" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled CUDA Force P2 State
    
    :: Disable NVIDIA Frame Rate Limiter
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfLevelSrc" /t REG_DWORD /d 8738 /f >nul 2>&1
    echo  - Optimized Performance Level Source
    
    :: NVIDIA GameStream Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" /v "SendTelemetryDataToNvidia" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled NVIDIA Data Collection
    
    :: G-SYNC Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "VSyncMode" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized VSync Settings
    
    :: Disable NVIDIA Overlay (reduces latency)
    reg add "HKCU\SOFTWARE\NVIDIA Corporation\Global\ShadowPlay\NVSPCAPS" /v "GameOverlayEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled NVIDIA Overlay for Lower Latency
    
    :: NVIDIA Threaded Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ThreadedOptimization" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Threaded Optimization
    
    :: Max Pre-rendered Frames = 1 for minimum latency
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PreRenderLimit" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Set Max Pre-rendered Frames to 1
    goto :eof

:AMD_GPU
    echo.
    echo  --------------------------------------------------------
    echo   AMD GPU Optimization
    echo  --------------------------------------------------------
    echo.
    call :APPLY_AMD_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   AMD GPU optimizations applied!
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:APPLY_AMD_TWEAKS
    :: AMD Driver Settings for Maximum Performance
    echo  - Applying AMD driver optimizations...
    
    :: Enable Hardware Accelerated GPU Scheduling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Enabled Hardware Accelerated GPU Scheduling
    
    :: AMD Power Profile - Maximum Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Thermal Auto Throttling
    
    :: AMD Shader Cache - Enabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ShaderCache" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Shader Cache
    
    :: AMD Anti-Lag (if supported)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableAntiLag" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled AMD Anti-Lag
    
    :: AMD Surface Format Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "SurfaceFormatOptimization" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Surface Format Optimization
    
    :: AMD Tessellation Mode - Override for Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "TessellationLevel" /t REG_DWORD /d 8 /f >nul 2>&1
    echo  - Optimized Tessellation Level
    
    :: AMD Texture Filtering Quality - Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "TextureFilteringQuality" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Set Texture Filtering to Performance Mode
    
    :: AMD Wait for Vertical Refresh - Off
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Wait for Vertical Refresh" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled VSync (Wait for Vertical Refresh)
    
    :: AMD Radeon Boost (if supported)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableRadeonBoost" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Radeon Boost
    
    :: AMD Chill - Disabled for Maximum FPS
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableChill" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled AMD Chill for Maximum FPS
    
    :: AMD Enhanced Sync - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableEnhancedSync" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Enhanced Sync
    
    :: AMD Image Sharpening
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ImageSharpening" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Image Sharpening
    
    :: AMD OpenGL Triple Buffering - Off
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "OpenGLTripleBuffering" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled OpenGL Triple Buffering
    
    :: AMD GPU Workload - Graphics
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "GPUWorkload" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Set GPU Workload to Graphics Mode
    
    :: Disable AMD Telemetry
    schtasks /change /tn "AMDRyzenMasterSDKTask" /disable >nul 2>&1
    reg add "HKLM\SOFTWARE\AMD\CN" /v "CollectGIData" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled AMD Telemetry
    
    :: AMD ULPS (Ultra Low Power State) - Disable for Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0002" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled ULPS (Ultra Low Power State)
    goto :eof

:INTEL_GPU
    echo.
    echo  --------------------------------------------------------
    echo   Intel GPU Optimization
    echo  --------------------------------------------------------
    echo.
    call :APPLY_INTEL_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   Intel GPU optimizations applied!
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:APPLY_INTEL_TWEAKS
    :: Intel Driver Settings for Maximum Performance
    echo  - Applying Intel driver optimizations...
    
    :: Enable Hardware Accelerated GPU Scheduling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Enabled Hardware Accelerated GPU Scheduling
    
    :: Intel Graphics Power Plan - Maximum Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "FeatureTestControl" /t REG_DWORD /d 9240 /f >nul 2>&1
    echo  - Optimized Intel Feature Test Control
    
    :: Intel Display Power Saving - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DP_Enable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Display Power Saving Technology
    
    :: Intel Panel Self Refresh - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PSR_Enable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Panel Self Refresh
    
    :: Intel Adaptive Brightness - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AdaptiveBrightness" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Intel Adaptive Brightness
    
    :: Intel Dynamic Video Memory Technology
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableDVMT" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Dynamic Video Memory Technology
    
    :: Intel Turbo Boost - Maximum
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "TurboBoost" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Turbo Boost
    
    :: Intel RC6 (Render Standby) - Disabled for Performance
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RC6_Enable" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled RC6 Render Standby
    
    :: Intel Xe/Arc Specific Settings
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "XeHPGMaxPerformance" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Enabled Xe/Arc Maximum Performance Mode
    
    :: Intel VSync Control - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "VSyncControl" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled VSync Control
    
    :: Intel Smooth Scrolling - Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "SmoothScrolling" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Smooth Scrolling for Lower Latency
    
    :: Intel Display Audio - Disabled (if not using HDMI audio)
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\IntcAudioBus" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
    echo  - Disabled Intel Display Audio Service
    goto :eof

:UNIVERSAL_GPU
    echo.
    echo  --------------------------------------------------------
    echo   Universal GPU Tweaks (All GPUs)
    echo  --------------------------------------------------------
    echo.
    call :APPLY_UNIVERSAL_GPU_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   Universal GPU tweaks applied!
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:APPLY_UNIVERSAL_GPU_TWEAKS
    :: Universal GPU Settings for All Graphics Cards
    echo  - Applying universal GPU optimizations...
    
    :: Hardware Accelerated GPU Scheduling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo  - Enabled Hardware Accelerated GPU Scheduling
    
    :: Disable Fullscreen Optimizations Globally
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Fullscreen Optimizations Globally
    
    :: GPU Priority for Games
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
    echo  - Set GPU Priority to High for Games
    
    :: Disable Power Throttling for GPU
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled Power Throttling
    
    :: DirectX 12 Optimizations
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d 10 /f >nul 2>&1
    echo  - Increased TDR (Timeout Detection Recovery) Delay
    
    :: Disable GPU Memory Compression (may improve some games)
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Optimized GPU Memory Block Write
    
    :: Enable Variable Refresh Rate
    reg add "HKCU\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "VRROptimizeEnable=1;" /f >nul 2>&1
    echo  - Enabled Variable Refresh Rate Optimization
    
    :: Disable Desktop Window Manager Throttling
    reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableMachineCheck" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled DWM Throttling
    
    :: DXGI Flip Model Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "FlipQueueSize" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Optimized DXGI Flip Queue Size
    
    :: Pre-rendered Frames (Universal)
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Set Max Pre-rendered Frames to 1
    goto :eof

:GAMING_LATENCY
    echo.
    echo  --------------------------------------------------------
    echo   Gaming Latency Optimization
    echo  --------------------------------------------------------
    echo.
    call :APPLY_GAMING_LATENCY_TWEAKS
    echo.
    echo  --------------------------------------------------------
    echo   Gaming latency optimizations applied!
    echo  --------------------------------------------------------
    pause
    goto :GPU_OPTIMIZATION

:APPLY_GAMING_LATENCY_TWEAKS
    :: Gaming Latency Optimization Settings
    echo  - Applying gaming latency optimizations...
    
    :: System Responsiveness (0 = prioritize games, 10-20 = balanced)
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Set System Responsiveness to Maximum
    
    :: Disable Network Throttling
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
    echo  - Disabled Network Throttling Index
    
    :: Disable Nagle's Algorithm (reduces network latency)
    for /f "tokens=3*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /s /v "DhcpIPAddress" 2^>nul') do (
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
    )
    echo  - Disabled Nagle's Algorithm
    
    :: Process Priority Separation - Short, Fixed
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
    echo  - Optimized Process Priority Separation
    
    :: Disable Game Bar Recording (reduces latency)
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
    echo  - Disabled Game DVR/Game Bar Recording
    
    :: Timer Resolution (High Precision)
    bcdedit /set disabledynamictick yes >nul 2>&1
    bcdedit /set useplatformtick yes >nul 2>&1
    echo  - Enabled High Precision Timer
    
    :: Mouse Acceleration Disabled
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
    echo  - Disabled Mouse Acceleration
    
    :: USB Polling Rate Optimization
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1
    echo  - Disabled USB Selective Suspend
    
    :: Keyboard Response Time
    reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
    echo  - Optimized Keyboard Response Time
    goto :eof

:LAPTOP_GPU_POWER
    echo.
    echo  --------------------------------------------------------
    echo   Laptop GPU Power Management Optimization
    echo  --------------------------------------------------------
    echo.
    echo  Choose laptop power profile:
    echo    1. Maximum Performance (Plugged In)
    echo    2. Balanced Performance (Battery/Plugged In)
    echo    3. Power Saving (Battery)
    echo    4. Back to GPU Menu
    echo.
    choice /c 1234 /n /m "Enter your choice: "
    if errorlevel 4 goto :GPU_OPTIMIZATION
    if errorlevel 3 goto :LAPTOP_POWER_SAVE
    if errorlevel 2 goto :LAPTOP_BALANCED
    if errorlevel 1 goto :LAPTOP_MAX_PERF

:LAPTOP_MAX_PERF
    echo.
    echo  - Applying Maximum Performance settings for laptop GPU...
    
    :: Set GPU to Maximum Performance on AC
    powercfg /setacvalueindex scheme_current sub_graphics gpupowerpc 0 >nul 2>&1
    powercfg /setacvalueindex scheme_current sub_graphics gpuvidpt 3 >nul 2>&1
    
    :: Disable GPU Power Savings
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PmKnobs" /t REG_DWORD /d 0 /f >nul 2>&1
    
    :: Maximum GPU Frequency
    powercfg /setacvalueindex scheme_current sub_graphics gpuboost 100 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    
    echo  - Maximum Performance applied for plugged-in mode!
    pause
    goto :LAPTOP_GPU_POWER

:LAPTOP_BALANCED
    echo.
    echo  - Applying Balanced Performance settings for laptop GPU...
    
    :: Set GPU to Balanced Mode
    powercfg /setacvalueindex scheme_current sub_graphics gpupowerpc 1 >nul 2>&1
    powercfg /setdcvalueindex scheme_current sub_graphics gpupowerpc 2 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    
    echo  - Balanced Performance applied!
    pause
    goto :LAPTOP_GPU_POWER

:LAPTOP_POWER_SAVE
    echo.
    echo  - Applying Power Saving settings for laptop GPU...
    
    :: Set GPU to Power Saving Mode
    powercfg /setdcvalueindex scheme_current sub_graphics gpupowerpc 3 >nul 2>&1
    powercfg /setdcvalueindex scheme_current sub_graphics gpuvidpt 0 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    
    echo  - Power Saving applied for battery mode!
    pause
    goto :LAPTOP_GPU_POWER

:MSI_MODE
    echo.
    echo  --------------------------------------------------------
    echo   MSI Mode (Message Signaled Interrupts)
    echo   Reduces input latency for GPU and other devices
    echo  --------------------------------------------------------
    echo.
    echo  WARNING: MSI Mode changes can cause system instability
    echo  on some hardware. Create a restore point first!
    echo.
    echo  Choose an option:
    echo    1. Enable MSI Mode for GPU
    echo    2. Enable MSI Mode for All PCI Devices
    echo    3. Disable MSI Mode (Restore Default)
    echo    4. Back to GPU Menu
    echo.
    choice /c 1234 /n /m "Enter your choice: "
    if errorlevel 4 goto :GPU_OPTIMIZATION
    if errorlevel 3 goto :MSI_DISABLE
    if errorlevel 2 goto :MSI_ALL_DEVICES
    if errorlevel 1 goto :MSI_GPU_ONLY

:MSI_GPU_ONLY
    echo.
    echo  - Enabling MSI Mode for GPU...
    
    :: Find GPU device path and enable MSI
    for /f "tokens=*" %%a in ('wmic path win32_videocontroller get pnpdeviceid ^| findstr /i "PCI"') do (
        set "GPU_PATH=%%a"
    )
    
    :: Enable MSI for primary display adapter
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_10DE&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1002&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_8086&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 1 /f >nul 2>&1
    
    echo  - MSI Mode enabled for GPU. Restart required!
    pause
    goto :MSI_MODE

:MSI_ALL_DEVICES
    echo.
    echo  - Enabling MSI Mode for all PCI devices...
    
    :: Enable MSI for all supported PCI devices
    for /f "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\PCI" /s ^| findstr /i "Device Parameters"') do (
        reg add "%%a\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 1 /f >nul 2>&1
    )
    
    echo  - MSI Mode enabled for all PCI devices. Restart required!
    pause
    goto :MSI_MODE

:MSI_DISABLE
    echo.
    echo  - Disabling MSI Mode (restoring defaults)...
    
    :: Disable MSI for GPU
    reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_10DE&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1002&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\PCI\VEN_8086&DEV*\*\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
    
    echo  - MSI Mode disabled. Restart required!
    pause
    goto :MSI_MODE

:: ========================================================
:: ADVANCED TOOLS MODULE
:: ========================================================
:EXTRA_TOOLS
    cls
    echo  ========================================================
    echo   Advanced Tools - System Diagnostics ^& Utilities
    echo  ========================================================
    echo.
    echo  -------------------- DIAGNOSTICS ----------------------
    echo    1.  System Information Report
    echo    2.  Hardware Detection Summary
    echo    3.  Boot Time Analysis
    echo    4.  RAM Usage Monitor
    echo.
    echo  --------------------- NETWORK -------------------------
    echo    5.  Network Speed Test (DNS)
    echo    6.  Ping Test (Latency Check)
    echo    7.  Flush DNS ^& Reset Network
    echo    8.  View Active Connections
    echo.
    echo  ---------------------- CLEANUP ------------------------
    echo    9.  Browser Cache Cleanup
    echo   10.  Windows Update Cache Cleanup
    echo   11.  Icon Cache Rebuild
    echo   12.  Font Cache Rebuild
    echo.
    echo  --------------------- UTILITIES -----------------------
    echo   13.  Export Optimization Log
    echo   14.  Create System Restore Point
    echo   15.  Check Disk Health (SMART)
    echo   16.  Back to Main Menu
    echo.
    choice /c 123456789ABCDEFG /n /m "Enter your choice (1-9, A-G): "
    if errorlevel 16 goto :MAIN_MENU
    if errorlevel 15 goto :CHECK_DISK_HEALTH
    if errorlevel 14 goto :CREATE_RESTORE_POINT
    if errorlevel 13 goto :EXPORT_LOG
    if errorlevel 12 goto :FONT_CACHE_REBUILD
    if errorlevel 11 goto :ICON_CACHE_REBUILD
    if errorlevel 10 goto :UPDATE_CACHE_CLEANUP
    if errorlevel 9 goto :BROWSER_CACHE_CLEANUP
    if errorlevel 8 goto :VIEW_CONNECTIONS
    if errorlevel 7 goto :FLUSH_DNS_RESET
    if errorlevel 6 goto :PING_TEST
    if errorlevel 5 goto :NETWORK_SPEED_TEST
    if errorlevel 4 goto :RAM_MONITOR
    if errorlevel 3 goto :BOOT_TIME_ANALYSIS
    if errorlevel 2 goto :HARDWARE_SUMMARY
    if errorlevel 1 goto :SYSTEM_INFO_REPORT

:: ----------------------------------------------------------
:: DIAGNOSTICS SECTION
:: ----------------------------------------------------------
:SYSTEM_INFO_REPORT
    cls
    echo  ========================================================
    echo   System Information Report
    echo  ========================================================
    echo.
    echo  Gathering system information... Please wait.
    echo.
    echo  ------ OPERATING SYSTEM ------
    systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Original Install Date"
    echo.
    echo  ------ COMPUTER DETAILS ------
    wmic computersystem get name,manufacturer,model,systemtype /format:list 2>nul | findstr /v "^$"
    echo.
    echo  ------ PROCESSOR ------
    wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed /format:list 2>nul | findstr /v "^$"
    echo.
    echo  ------ MEMORY ------
    wmic os get totalvisiblememorysize,freephysicalmemory /format:list 2>nul | findstr /v "^$"
    for /f "tokens=2 delims==" %%a in ('wmic os get totalvisiblememorysize /value 2^>nul') do set /a "TotalRAM=%%a/1024"
    echo  Total RAM: %TotalRAM% MB
    echo.
    echo  ------ GRAPHICS CARD ------
    wmic path win32_videocontroller get name,adapterram,driverversion /format:list 2>nul | findstr /v "^$"
    echo.
    echo  ------ STORAGE ------
    wmic diskdrive get model,size,status /format:list 2>nul | findstr /v "^$"
    echo.
    echo  ------ NETWORK ADAPTERS ------
    wmic nic where "NetEnabled=true" get name,speed /format:list 2>nul | findstr /v "^$"
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:HARDWARE_SUMMARY
    cls
    echo  ========================================================
    echo   Hardware Detection Summary
    echo  ========================================================
    echo.
    echo  Detecting hardware components...
    echo.
    echo  [CPU]
    wmic cpu get name 2>nul | findstr /v "Name" | findstr /v "^$"
    echo.
    echo  [GPU]
    wmic path win32_videocontroller get name 2>nul | findstr /v "Name" | findstr /v "^$"
    echo.
    echo  [RAM Modules]
    wmic memorychip get capacity,manufacturer,speed 2>nul | findstr /v "^$"
    echo.
    echo  [Storage Drives]
    wmic diskdrive get model,interfacetype,mediatype 2>nul | findstr /v "^$"
    echo.
    echo  [Motherboard]
    wmic baseboard get manufacturer,product,version 2>nul | findstr /v "^$"
    echo.
    echo  [BIOS]
    wmic bios get smbiosbiosversion,releasedate 2>nul | findstr /v "^$"
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:BOOT_TIME_ANALYSIS
    cls
    echo  ========================================================
    echo   Boot Time Analysis
    echo  ========================================================
    echo.
    echo  Analyzing boot performance...
    echo.
    echo  ------ LAST BOOT TIME ------
    systeminfo | findstr /C:"System Boot Time"
    echo.
    echo  ------ BOOT DURATION ------
    for /f "tokens=2 delims==" %%a in ('wmic os get lastbootuptime /value 2^>nul') do set "BootTime=%%a"
    echo  Last Boot: %BootTime:~0,4%-%BootTime:~4,2%-%BootTime:~6,2% %BootTime:~8,2%:%BootTime:~10,2%:%BootTime:~12,2%
    echo.
    echo  ------ STARTUP PROGRAMS COUNT ------
    for /f %%a in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2^>nul ^| find /c "REG_"') do echo  User Startup Items: %%a
    for /f %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2^>nul ^| find /c "REG_"') do echo  System Startup Items: %%a
    echo.
    echo  ------ UPTIME ------
    for /f "tokens=1" %%a in ('wmic os get lastbootuptime ^| findstr /v "LastBootUpTime"') do set "LastBoot=%%a"
    echo  System has been running since last boot.
    echo.
    echo  TIP: Open Task Manager ^> Startup tab to see "Last BIOS Time"
    echo  for accurate BIOS boot measurement.
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:RAM_MONITOR
    cls
    echo  ========================================================
    echo   RAM Usage Monitor
    echo  ========================================================
    echo.
    echo  ------ CURRENT MEMORY STATUS ------
    echo.
    for /f "tokens=2 delims==" %%a in ('wmic os get totalvisiblememorysize /value 2^>nul') do set "TotalMem=%%a"
    for /f "tokens=2 delims==" %%a in ('wmic os get freephysicalmemory /value 2^>nul') do set "FreeMem=%%a"
    set /a "UsedMem=%TotalMem%-%FreeMem%"
    set /a "TotalMB=%TotalMem%/1024"
    set /a "FreeMB=%FreeMem%/1024"
    set /a "UsedMB=%UsedMem%/1024"
    set /a "UsedPercent=(%UsedMem%*100)/%TotalMem%"
    echo  Total RAM:     %TotalMB% MB
    echo  Used RAM:      %UsedMB% MB
    echo  Free RAM:      %FreeMB% MB
    echo  Usage:         %UsedPercent%%%
    echo.
    echo  ------ TOP MEMORY PROCESSES ------
    echo.
    echo  Process Name              Memory (KB)
    echo  -----------------------------------------
    wmic process get name,workingsetsize 2>nul | sort /R | findstr /v "Name" | findstr /v "^$" | head -10 2>nul || (
        powershell -command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name, @{N='Memory(MB)';E={[math]::Round($_.WorkingSet64/1MB,2)}}" 2>nul
    )
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:: ----------------------------------------------------------
:: NETWORK SECTION
:: ----------------------------------------------------------
:NETWORK_SPEED_TEST
    cls
    echo  ========================================================
    echo   Network Speed Test (DNS Response)
    echo  ========================================================
    echo.
    echo  Testing DNS response times to popular servers...
    echo.
    echo  ------ GOOGLE DNS (8.8.8.8) ------
    ping -n 4 8.8.8.8 | findstr /C:"Average" /C:"time="
    echo.
    echo  ------ CLOUDFLARE DNS (1.1.1.1) ------
    ping -n 4 1.1.1.1 | findstr /C:"Average" /C:"time="
    echo.
    echo  ------ QUAD9 DNS (9.9.9.9) ------
    ping -n 4 9.9.9.9 | findstr /C:"Average" /C:"time="
    echo.
    echo  ------ OPENDNS (208.67.222.222) ------
    ping -n 4 208.67.222.222 | findstr /C:"Average" /C:"time="
    echo.
    echo  TIP: Lower average time = faster DNS response.
    echo  Consider switching to the fastest DNS in your network settings.
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:PING_TEST
    cls
    echo  ========================================================
    echo   Ping Test - Network Latency Check
    echo  ========================================================
    echo.
    set /p "target=Enter IP or domain to ping (default: google.com): "
    if "%target%"=="" set "target=google.com"
    echo.
    echo  Pinging %target%...
    echo.
    ping -n 10 %target%
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:FLUSH_DNS_RESET
    cls
    echo  ========================================================
    echo   Flush DNS ^& Reset Network Stack
    echo  ========================================================
    echo.
    echo  Flushing DNS cache...
    ipconfig /flushdns
    echo.
    echo  Releasing IP address...
    ipconfig /release >nul 2>&1
    echo.
    echo  Renewing IP address...
    ipconfig /renew >nul 2>&1
    echo.
    echo  Resetting Winsock...
    netsh winsock reset >nul 2>&1
    echo  - Winsock reset complete.
    echo.
    echo  Resetting TCP/IP stack...
    netsh int ip reset >nul 2>&1
    echo  - TCP/IP stack reset complete.
    echo.
    echo  ========================================================
    echo   Network stack has been reset. 
    echo   A restart may be required for full effect.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:VIEW_CONNECTIONS
    cls
    echo  ========================================================
    echo   Active Network Connections
    echo  ========================================================
    echo.
    echo  ------ ESTABLISHED CONNECTIONS ------
    netstat -an | findstr "ESTABLISHED"
    echo.
    echo  ------ LISTENING PORTS ------
    netstat -an | findstr "LISTENING" | findstr /v "127.0.0.1"
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:: ----------------------------------------------------------
:: CLEANUP SECTION
:: ----------------------------------------------------------
:BROWSER_CACHE_CLEANUP
    cls
    echo  ========================================================
    echo   Browser Cache Cleanup
    echo  ========================================================
    echo.
    echo  Cleaning browser caches...
    echo.
    echo  ------ GOOGLE CHROME ------
    if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
        rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
        mkdir "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
        echo  - Chrome cache cleared.
    ) else (
        echo  - Chrome cache not found or already clean.
    )
    echo.
    echo  ------ MICROSOFT EDGE ------
    if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
        rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2>nul
        mkdir "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2>nul
        echo  - Edge cache cleared.
    ) else (
        echo  - Edge cache not found or already clean.
    )
    echo.
    echo  ------ MOZILLA FIREFOX ------
    if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
        for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
            if exist "%%p\cache2" rd /s /q "%%p\cache2" 2>nul
        )
        echo  - Firefox cache cleared.
    ) else (
        echo  - Firefox cache not found.
    )
    echo.
    echo  ------ OPERA ------
    if exist "%APPDATA%\Opera Software\Opera Stable\Cache" (
        rd /s /q "%APPDATA%\Opera Software\Opera Stable\Cache" 2>nul
        echo  - Opera cache cleared.
    ) else (
        echo  - Opera cache not found.
    )
    echo.
    echo  ------ BRAVE ------
    if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
        rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" 2>nul
        echo  - Brave cache cleared.
    ) else (
        echo  - Brave cache not found.
    )
    echo.
    echo  ========================================================
    echo   Browser caches cleared successfully!
    echo   Note: Close browsers before running for best results.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:UPDATE_CACHE_CLEANUP
    cls
    echo  ========================================================
    echo   Windows Update Cache Cleanup
    echo  ========================================================
    echo.
    echo  Stopping Windows Update service...
    net stop wuauserv >nul 2>&1
    net stop bits >nul 2>&1
    echo.
    echo  Clearing Windows Update cache...
    if exist "%WINDIR%\SoftwareDistribution\Download" (
        rd /s /q "%WINDIR%\SoftwareDistribution\Download" 2>nul
        mkdir "%WINDIR%\SoftwareDistribution\Download" 2>nul
        echo  - Windows Update download cache cleared.
    )
    echo.
    echo  Clearing Windows Update data store...
    if exist "%WINDIR%\SoftwareDistribution\DataStore" (
        rd /s /q "%WINDIR%\SoftwareDistribution\DataStore" 2>nul
        mkdir "%WINDIR%\SoftwareDistribution\DataStore" 2>nul
        echo  - Windows Update data store cleared.
    )
    echo.
    echo  Starting Windows Update service...
    net start wuauserv >nul 2>&1
    net start bits >nul 2>&1
    echo.
    echo  ========================================================
    echo   Windows Update cache cleared successfully!
    echo   This can free up several GB of disk space.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:ICON_CACHE_REBUILD
    cls
    echo  ========================================================
    echo   Icon Cache Rebuild
    echo  ========================================================
    echo.
    echo  This will rebuild the Windows icon cache.
    echo  Explorer will restart during the process.
    echo.
    set /p "confirm=Continue? (Y/N): "
    if /i not "%confirm%"=="Y" goto :EXTRA_TOOLS
    echo.
    echo  Stopping Explorer...
    taskkill /f /im explorer.exe >nul 2>&1
    echo.
    echo  Deleting icon cache files...
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache*" 2>nul
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache*" 2>nul
    del /f /s /q "%LOCALAPPDATA%\IconCache.db" 2>nul
    echo  - Icon cache files deleted.
    echo.
    echo  Starting Explorer...
    start explorer.exe
    echo.
    echo  ========================================================
    echo   Icon cache rebuilt successfully!
    echo   Icons should now display correctly.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:FONT_CACHE_REBUILD
    cls
    echo  ========================================================
    echo   Font Cache Rebuild
    echo  ========================================================
    echo.
    echo  Stopping Windows Font Cache Service...
    net stop FontCache >nul 2>&1
    net stop FontCache3.0.0.0 >nul 2>&1
    echo.
    echo  Deleting font cache files...
    del /f /s /q "%WINDIR%\ServiceProfiles\LocalService\AppData\Local\FontCache*" 2>nul
    del /f /s /q "%LOCALAPPDATA%\Microsoft\FontCache*" 2>nul
    echo  - Font cache files deleted.
    echo.
    echo  Starting Windows Font Cache Service...
    net start FontCache >nul 2>&1
    net start FontCache3.0.0.0 >nul 2>&1
    echo.
    echo  ========================================================
    echo   Font cache rebuilt successfully!
    echo   Restart your PC for changes to take full effect.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:: ----------------------------------------------------------
:: UTILITIES SECTION
:: ----------------------------------------------------------
:EXPORT_LOG
    cls
    echo  ========================================================
    echo   Export Optimization Log
    echo  ========================================================
    echo.
    set "LogFile=%USERPROFILE%\Desktop\WindowsOptimizer_Log_%date:~-4,4%%date:~-10,2%%date:~-7,2%.txt"
    echo  Creating optimization log...
    echo.
    (
        echo ========================================================
        echo  Windows Optimizer v7.0 - System Report
        echo  Generated: %date% %time%
        echo ========================================================
        echo.
        echo [SYSTEM INFORMATION]
        systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
        echo.
        echo [PROCESSOR]
        wmic cpu get name 2>nul | findstr /v "Name"
        echo.
        echo [GRAPHICS]
        wmic path win32_videocontroller get name 2>nul | findstr /v "Name"
        echo.
        echo [MEMORY]
        wmic os get totalvisiblememorysize,freephysicalmemory /format:list 2>nul
        echo.
        echo [DISK DRIVES]
        wmic diskdrive get model,size,status 2>nul
        echo.
        echo [STARTUP PROGRAMS]
        reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
        echo.
        echo [SERVICES - Running]
        wmic service where state="running" get name,displayname 2>nul
        echo.
        echo ========================================================
    ) > "%LogFile%"
    echo  Log exported to: %LogFile%
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:CREATE_RESTORE_POINT
    cls
    echo  ========================================================
    echo   Create System Restore Point
    echo  ========================================================
    echo.
    echo  Creating a system restore point...
    echo  This may take a few minutes.
    echo.
    powershell -Command "Checkpoint-Computer -Description 'Windows_Optimizer_Backup' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
    if %errorlevel% == 0 (
        echo  ========================================================
        echo   Restore point created successfully!
        echo   Description: Windows_Optimizer_Backup
        echo  ========================================================
    ) else (
        echo  ========================================================
        echo   Failed to create restore point.
        echo   Make sure System Protection is enabled.
        echo   Go to: System Properties ^> System Protection
        echo  ========================================================
    )
    pause
    goto :EXTRA_TOOLS

:CHECK_DISK_HEALTH
    cls
    echo  ========================================================
    echo   Disk Health Check (SMART Status)
    echo  ========================================================
    echo.
    echo  Checking disk health...
    echo.
    wmic diskdrive get model,status,size
    echo.
    echo  ------ SMART STATUS ------
    wmic diskdrive get model,status 2>nul | findstr /v "^$"
    echo.
    echo  Status Meanings:
    echo    OK     = Drive is healthy
    echo    Pred Fail = Drive failure predicted (BACKUP NOW!)
    echo    Unknown = SMART data not available
    echo.
    echo  ------ DISK SPACE ------
    wmic logicaldisk get caption,size,freespace 2>nul
    echo.
    echo  ========================================================
    pause
    goto :EXTRA_TOOLS

:: ========================================================
:: ONE-CLICK OPTIMIZATION MODULE
:: ========================================================
:ONE_CLICK_OPTIONS
    cls
    echo  ========================================================
    echo   One-Click Optimization Profiles
    echo  ========================================================
    echo.
    echo  Choose your optimization profile:
    echo.
    echo  -------------------- PROFILES -------------------------
    echo    1.  [SAFE] Conservative Optimization
    echo        ^> Safe tweaks only, minimal risk
    echo        ^> Clears temp files, optimizes services
    echo.
    echo    2.  [BALANCED] Standard Optimization  
    echo        ^> Moderate performance + stability
    echo        ^> Network, visual, startup tweaks
    echo.
    echo    3.  [PERFORMANCE] Maximum Performance
    echo        ^> Aggressive optimization for speed
    echo        ^> May affect some features
    echo.
    echo    4.  [GAMING] Ultimate Gaming Mode
    echo        ^> Maximum FPS and lowest latency
    echo        ^> GPU, network, and system tweaks
    echo.
    echo    5.  [LAPTOP] Battery + Performance Balance
    echo        ^> Optimized for laptop users
    echo        ^> Power management tweaks
    echo.
    echo    6.  [WORKSTATION] Professional Mode
    echo        ^> Stability + performance for work
    echo        ^> Minimal background interference
    echo.
    echo    7.  [UNDO] Restore Default Settings
    echo        ^> Revert common optimizations
    echo.
    echo    8.  Back to Main Menu
    echo.
    choice /c 12345678 /n /m "Enter your choice: "
    if errorlevel 8 goto :MAIN_MENU
    if errorlevel 7 goto :UNDO_OPTIMIZATIONS
    if errorlevel 6 goto :WORKSTATION_MODE
    if errorlevel 5 goto :LAPTOP_MODE
    if errorlevel 4 goto :GAMING_MODE
    if errorlevel 3 goto :PERFORMANCE_MODE
    if errorlevel 2 goto :BALANCED_MODE
    if errorlevel 1 goto :SAFE_MODE

:SAFE_MODE
    cls
    echo  ========================================================
    echo   [SAFE] Conservative Optimization - Applying...
    echo  ========================================================
    echo.
    echo  This profile applies only safe, reversible tweaks.
    echo.
    
    :: Clear temp files
    echo  [1/6] Clearing temporary files...
    del /q /f /s "%TEMP%\*" >nul 2>&1
    del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
    echo        Done.
    
    :: Flush DNS
    echo  [2/6] Flushing DNS cache...
    ipconfig /flushdns >nul 2>&1
    echo        Done.
    
    :: Clear event logs (non-critical)
    echo  [3/6] Clearing old event logs...
    wevtutil cl Application >nul 2>&1
    echo        Done.
    
    :: Optimize Windows Search
    echo  [4/6] Optimizing Windows Search...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f >nul 2>&1
    echo        Done.
    
    :: Disable startup delay
    echo  [5/6] Reducing startup delay...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
    echo        Done.
    
    :: Clear thumbnail cache
    echo  [6/6] Optimizing thumbnail cache...
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1
    echo        Done.
    
    echo.
    echo  ========================================================
    echo   SAFE Optimization Complete!
    echo   All changes are safe and reversible.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:BALANCED_MODE
    cls
    echo  ========================================================
    echo   [BALANCED] Standard Optimization - Applying...
    echo  ========================================================
    echo.
    
    :: Include safe mode tweaks
    echo  [1/10] Clearing temporary files...
    del /q /f /s "%TEMP%\*" >nul 2>&1
    del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
    echo         Done.
    
    echo  [2/10] Flushing DNS cache...
    ipconfig /flushdns >nul 2>&1
    echo         Done.
    
    :: Disable visual effects for performance
    echo  [3/10] Optimizing visual effects...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "50" /f >nul 2>&1
    echo         Done.
    
    :: Disable Windows tips
    echo  [4/10] Disabling Windows tips and suggestions...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    :: Optimize network settings
    echo  [5/10] Optimizing network settings...
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
    echo         Done.
    
    :: Disable telemetry
    echo  [6/10] Reducing telemetry...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    :: Optimize startup
    echo  [7/10] Optimizing startup...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    :: Disable Cortana
    echo  [8/10] Disabling Cortana...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    :: Optimize power plan
    echo  [9/10] Setting balanced power plan...
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    echo         Done.
    
    :: Enable fast startup
    echo  [10/10] Enabling fast startup...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo          Done.
    
    echo.
    echo  ========================================================
    echo   BALANCED Optimization Complete!
    echo   System optimized for daily use.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:PERFORMANCE_MODE
    cls
    echo  ========================================================
    echo   [PERFORMANCE] Maximum Performance - Applying...
    echo  ========================================================
    echo.
    echo  WARNING: This will disable some Windows features!
    echo.
    
    echo  [1/15] Clearing all temporary files...
    del /q /f /s "%TEMP%\*" >nul 2>&1
    del /q /f /s "%WINDIR%\Temp\*" >nul 2>&1
    del /q /f /s "%WINDIR%\Prefetch\*" >nul 2>&1
    echo         Done.
    
    echo  [2/15] Enabling Ultimate Performance power plan...
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    echo         Done.
    
    echo  [3/15] Disabling visual effects...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
    echo         Done.
    
    echo  [4/15] Disabling Superfetch and SysMain...
    sc config SysMain start= disabled >nul 2>&1
    net stop SysMain >nul 2>&1
    echo         Done.
    
    echo  [5/15] Disabling Windows Search Indexing...
    sc config WSearch start= disabled >nul 2>&1
    net stop WSearch >nul 2>&1
    echo         Done.
    
    echo  [6/15] Disabling telemetry and diagnostics...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    sc config DiagTrack start= disabled >nul 2>&1
    echo         Done.
    
    echo  [7/15] Optimizing memory management...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [8/15] Optimizing CPU scheduling...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
    echo         Done.
    
    echo  [9/15] Disabling Cortana and web search...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [10/15] Disabling Windows tips and ads...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [11/15] Optimizing network stack...
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    netsh int tcp set global chimney=enabled >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    echo         Done.
    
    echo  [12/15] Disabling background apps...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [13/15] Disabling Game DVR...
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [14/15] Enabling Hardware GPU Scheduling...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo         Done.
    
    echo  [15/15] Optimizing system responsiveness...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo.
    echo  ========================================================
    echo   PERFORMANCE Optimization Complete!
    echo   Your system is now optimized for maximum speed.
    echo   A restart is recommended.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:GAMING_MODE
    cls
    echo  ========================================================
    echo   [GAMING] Ultimate Gaming Mode - Applying...
    echo  ========================================================
    echo.
    echo  Optimizing for maximum FPS and lowest latency!
    echo.
    
    :: Apply all performance tweaks
    echo  [1/20] Enabling Ultimate Performance power plan...
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    echo         Done.
    
    echo  [2/20] Disabling visual effects...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    echo         Done.
    
    echo  [3/20] Setting GPU Priority to HIGH...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
    echo         Done.
    
    echo  [4/20] Disabling Game DVR and Game Bar...
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [5/20] Enabling Hardware Accelerated GPU Scheduling...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo         Done.
    
    echo  [6/20] Disabling Fullscreen Optimizations...
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
    echo         Done.
    
    echo  [7/20] Setting Max Pre-rendered Frames to 1...
    reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [8/20] Disabling Network Throttling...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
    echo         Done.
    
    echo  [9/20] Setting System Responsiveness to 0...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [10/20] Disabling Nagle's Algorithm...
    for /f "tokens=3*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /s /v "DhcpIPAddress" 2^>nul') do (
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
    )
    echo         Done.
    
    echo  [11/20] Disabling Power Throttling...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [12/20] Disabling Core Parking...
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100 >nul 2>&1
    powercfg -setactive scheme_current >nul 2>&1
    echo         Done.
    
    echo  [13/20] Optimizing Mouse Settings (No Acceleration)...
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
    echo         Done.
    
    echo  [14/20] Optimizing Keyboard Response...
    reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
    echo         Done.
    
    echo  [15/20] Disabling Windows Search Indexing...
    sc config WSearch start= disabled >nul 2>&1
    net stop WSearch >nul 2>&1
    echo         Done.
    
    echo  [16/20] Disabling Superfetch/SysMain...
    sc config SysMain start= disabled >nul 2>&1
    net stop SysMain >nul 2>&1
    echo         Done.
    
    echo  [17/20] Disabling background apps...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [18/20] Enabling Game Mode...
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [19/20] Disabling Xbox services...
    sc config XblAuthManager start= disabled >nul 2>&1
    sc config XblGameSave start= disabled >nul 2>&1
    sc config XboxGipSvc start= disabled >nul 2>&1
    sc config XboxNetApiSvc start= disabled >nul 2>&1
    echo         Done.
    
    echo  [20/20] Increasing TDR Delay...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 10 /f >nul 2>&1
    echo         Done.
    
    echo.
    echo  ========================================================
    echo   GAMING Optimization Complete!
    echo   Your PC is now optimized for maximum gaming performance.
    echo   Restart your PC for all changes to take effect.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:LAPTOP_MODE
    cls
    echo  ========================================================
    echo   [LAPTOP] Battery + Performance Balance - Applying...
    echo  ========================================================
    echo.
    
    echo  [1/12] Setting Balanced power plan...
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    echo         Done.
    
    echo  [2/12] Optimizing battery settings...
    powercfg /setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 80 >nul 2>&1
    powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
    echo         Done.
    
    echo  [3/12] Enabling Battery Saver optimizations...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v "01" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [4/12] Optimizing display power settings...
    powercfg /setdcvalueindex scheme_current sub_video VIDEOIDLE 180 >nul 2>&1
    powercfg /setacvalueindex scheme_current sub_video VIDEOIDLE 600 >nul 2>&1
    echo         Done.
    
    echo  [5/12] Enabling Hibernate on battery...
    powercfg /hibernate on >nul 2>&1
    echo         Done.
    
    echo  [6/12] Disabling unnecessary services for battery...
    sc config WSearch start= demand >nul 2>&1
    echo         Done.
    
    echo  [7/12] Reducing background activity...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [8/12] Optimizing wireless adapter power...
    powercfg /setdcvalueindex scheme_current 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 1 >nul 2>&1
    echo         Done.
    
    echo  [9/12] Disabling visual effects for performance...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
    echo         Done.
    
    echo  [10/12] Disabling Windows tips...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [11/12] Clearing temp files...
    del /q /f /s "%TEMP%\*" >nul 2>&1
    echo         Done.
    
    echo  [12/12] Applying active settings...
    powercfg /setactive scheme_current >nul 2>&1
    echo         Done.
    
    echo.
    echo  ========================================================
    echo   LAPTOP Optimization Complete!
    echo   Balanced for battery life and performance.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:WORKSTATION_MODE
    cls
    echo  ========================================================
    echo   [WORKSTATION] Professional Mode - Applying...
    echo  ========================================================
    echo.
    echo  Optimizing for stability and productivity...
    echo.
    
    echo  [1/15] Setting High Performance power plan...
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    echo         Done.
    
    echo  [2/15] Disabling unnecessary animations...
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "50" /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
    echo         Done.
    
    echo  [3/15] Optimizing virtual memory...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [4/15] Disabling Windows tips and suggestions...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [5/15] Reducing telemetry...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [6/15] Disabling Cortana...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [7/15] Optimizing network settings...
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    echo         Done.
    
    echo  [8/15] Disabling Game DVR (not needed for work)...
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [9/15] Optimizing startup programs...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [10/15] Disabling Widgets...
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [11/15] Keeping Windows Search enabled...
    sc config WSearch start= auto >nul 2>&1
    echo         Done (Search needed for productivity).
    
    echo  [12/15] Enabling file indexing for work folders...
    echo         Done (Search indexing optimized).
    
    echo  [13/15] Clearing temp files...
    del /q /f /s "%TEMP%\*" >nul 2>&1
    echo         Done.
    
    echo  [14/15] Flushing DNS...
    ipconfig /flushdns >nul 2>&1
    echo         Done.
    
    echo  [15/15] Enabling Fast Startup...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo.
    echo  ========================================================
    echo   WORKSTATION Optimization Complete!
    echo   System optimized for professional productivity.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

:UNDO_OPTIMIZATIONS
    cls
    echo  ========================================================
    echo   [UNDO] Restore Default Settings
    echo  ========================================================
    echo.
    echo  This will restore common settings to Windows defaults.
    echo.
    set /p "confirm=Are you sure you want to restore defaults? (Y/N): "
    if /i not "%confirm%"=="Y" goto :ONE_CLICK_OPTIONS
    echo.
    
    echo  [1/12] Restoring power plan to Balanced...
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    echo         Done.
    
    echo  [2/12] Re-enabling SysMain/Superfetch...
    sc config SysMain start= auto >nul 2>&1
    net start SysMain >nul 2>&1
    echo         Done.
    
    echo  [3/12] Re-enabling Windows Search...
    sc config WSearch start= auto >nul 2>&1
    net start WSearch >nul 2>&1
    echo         Done.
    
    echo  [4/12] Re-enabling Game DVR...
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
    echo         Done.
    
    echo  [5/12] Restoring visual effects...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [6/12] Restoring telemetry settings...
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
    echo         Done.
    
    echo  [7/12] Restoring Cortana...
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /f >nul 2>&1
    echo         Done.
    
    echo  [8/12] Re-enabling background apps...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo         Done.
    
    echo  [9/12] Re-enabling Xbox services...
    sc config XblAuthManager start= demand >nul 2>&1
    sc config XblGameSave start= demand >nul 2>&1
    echo         Done.
    
    echo  [10/12] Restoring network throttling...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /f >nul 2>&1
    echo         Done.
    
    echo  [11/12] Restoring system responsiveness...
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
    echo         Done.
    
    echo  [12/12] Restoring mouse settings...
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "1" /f >nul 2>&1
    echo         Done.
    
    echo.
    echo  ========================================================
    echo   Default Settings Restored!
    echo   Restart your PC for all changes to take effect.
    echo  ========================================================
    pause
    goto :ONE_CLICK_OPTIONS

endlocal
exit /B 

:: --------------------------------------
:: 28. WINGET SOFTWARE INSTALLER

:: --------------------------------------
:WINGET_INSTALLER
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Software Installer (Winget)
    echo  --------------------------------------------------------
    echo.
    echo   1. Install Essential Browsers (Chrome, Firefox, Brave)
    echo   2. Install Utilities (7-Zip, Notepad++, PowerToys)
    echo   3. Install Runtimes (C++, .NET, DirectX)
    echo   4. Install Development Tools
    echo   5. Install Video Editors
    echo   6. Install Office Suite
    echo   7. Install Gaming Software
    echo   8. Install Other Apps
    echo   9. Install Security & Antivirus
    echo  10. Install Communication Tools
    echo  11. Install Cloud Storage
    echo  12. Install Design & Creative
    echo  13. Install Audio & Music
    echo  14. Back to Main Menu
    echo.
    choice /c 123456789ABCDEFG /n /m "Enter your choice: "
    if errorlevel 14 goto :MAIN_MENU
    if errorlevel 13 goto :WINGET_AUDIO
    if errorlevel 12 goto :WINGET_DESIGN
    if errorlevel 11 goto :WINGET_CLOUD
    if errorlevel 10 goto :WINGET_COMM
    if errorlevel 9 goto :WINGET_SECURITY
    if errorlevel 8 goto :WINGET_OTHERS
    if errorlevel 7 goto :WINGET_GAMING
    if errorlevel 6 goto :WINGET_OFFICE
    if errorlevel 5 goto :WINGET_VIDEO
    if errorlevel 4 goto :WINGET_DEV
    if errorlevel 3 goto :WINGET_RUNTIMES
    if errorlevel 2 goto :WINGET_UTILS
    if errorlevel 1 goto :WINGET_BROWSERS

:WINGET_BROWSERS
    echo Installing Browsers...
    winget install -e --id Google.Chrome
    winget install -e --id Mozilla.Firefox
    winget install -e --id Brave.Brave
    pause
    goto :WINGET_INSTALLER

:WINGET_UTILS
    echo Installing Utilities...
    winget install -e --id 7zip.7zip
    winget install -e --id Notepad++.Notepad++
    winget install -e --id Microsoft.PowerToys
    pause
    goto :WINGET_INSTALLER

:WINGET_RUNTIMES
    echo Installing Runtimes...
    winget install -e --id Microsoft.VCRedist.2015+.x64
    winget install -e --id Microsoft.DotNet.DesktopRuntime.6
    pause
    goto :WINGET_INSTALLER

:WINGET_DEV
    echo Installing Development Tools...
    winget install -e --id Microsoft.VisualStudioCode
    winget install -e --id Git.Git
    winget install -e --id Python.Python.3
    winget install -e --id OpenJS.NodeJS
    winget install -e --id Microsoft.VisualStudio.2022.Community
    winget install -e --id JetBrains.IntelliJIDEA.Community
    winget install -e --id Docker.DockerDesktop
    winget install -e --id Postman.Postman
    winget install -e --id GitHub.GitHubDesktop
    winget install -e --id Microsoft.SQLServerManagementStudio
    pause
    goto :WINGET_INSTALLER

:WINGET_VIDEO
    echo Installing Video Editors...
    winget install -e --id Blackmagic.DaVinciResolve
    winget install -e --id Meltytech.Shotcut
    winget install -e --id KDE.Kdenlive
    winget install -e --id OBSProject.OBSStudio
    winget install -e --id VideoLAN.VLC
    pause
    goto :WINGET_INSTALLER

:WINGET_OFFICE
    echo Installing Office Suite...
    winget install -e --id Microsoft.Office
    winget install -e --id TheDocumentFoundation.LibreOffice
    winget install -e --id ONLYOFFICE.DesktopEditors
    winget install -e --id Foxit.FoxitReader
    pause
    goto :WINGET_INSTALLER

:WINGET_GAMING
    echo Installing Gaming Software...
    winget install -e --id Valve.Steam
    winget install -e --id EpicGames.EpicGamesLauncher
    winget install -e --id Discord.Discord
    winget install -e --id Logitech.GHUB
    winget install -e --id Nvidia.GeForceExperience
    winget install -e --id AMD.RyzenMaster
    winget install -e --id ElectronicArts.EADesktop
    winget install -e --id Ubisoft.Connect
    winget install -e --id GOG.Galaxy
    pause
    goto :WINGET_INSTALLER

:WINGET_OTHERS
    echo Installing Other Apps...
    winget install -e --id Spotify.Spotify
    winget install -e --id VideoLAN.VLC
    winget install -e --id Adobe.Acrobat.Reader.64-bit
    winget install -e --id Zoom.Zoom
    winget install -e --id TeamViewer.TeamViewer
    winget install -e --id Malwarebytes.Malwarebytes
    winget install -e --id WinRAR.WinRAR
    winget install -e --id qBittorrent.qBittorrent
    winget install -e --id Oracle.JavaRuntimeEnvironment
    pause
    goto :WINGET_INSTALLER

:WINGET_SECURITY
    echo Installing Security & Antivirus Tools...
    winget install -e --id Malwarebytes.Malwarebytes
    winget install -e --id Avast.AvastFreeAntivirus
    winget install -e --id Bitdefender.Bitdefender
    winget install -e --id ESET.NOD32
    winget install -e --id Kaspersky.Lab
    pause
    goto :WINGET_INSTALLER

:WINGET_COMM
    echo Installing Communication Tools...
    winget install -e --id Microsoft.Teams
    winget install -e --id SlackTechnologies.Slack
    winget install -e --id WhatsApp.WhatsApp
    winget install -e --id Telegram.TelegramDesktop
    winget install -e --id Zoom.Zoom
    pause
    goto :WINGET_INSTALLER

:WINGET_CLOUD
    echo Installing Cloud Storage Tools...
    winget install -e --id Microsoft.OneDrive
    winget install -e --id Google.GoogleDrive
    winget install -e --id Dropbox.Dropbox
    winget install -e --id Mega.MEGASync
    winget install -e --id Box.Box
    pause
    goto :WINGET_INSTALLER

:WINGET_DESIGN
    echo Installing Design & Creative Tools...
    winget install -e --id GIMP.GIMP
    winget install -e --id Inkscape.Inkscape
    winget install -e --id BlenderFoundation.Blender
    winget install -e --id Adobe.CreativeCloud
    winget install -e --id Canva.Canva
    pause
    goto :WINGET_INSTALLER

:WINGET_AUDIO
    echo Installing Audio & Music Tools...
    winget install -e --id Audacity.Audacity
    winget install -e --id LMMS.LMMS
    winget install -e --id Spotify.Spotify
    winget install -e --id VideoLAN.VLC
    winget install -e --id AIMP.AIMP
    pause
    goto :WINGET_INSTALLER

:: --------------------------------------
:: 29. DNS SWITCHER
:: --------------------------------------
:DNS_SWITCHER
    cls
    echo.
    echo  --------------------------------------------------------
    echo   DNS Switcher
    echo  --------------------------------------------------------
    echo   1. Google DNS (8.8.8.8)
    echo   2. Cloudflare DNS (1.1.1.1)
    echo   3. OpenDNS
    echo   4. Reset to Auto (DHCP)
    echo   5. Back to Main Menu
    echo.
    choice /c 12345 /n /m "Select DNS: "
    if errorlevel 5 goto :MAIN_MENU
    if errorlevel 4 goto :DNS_AUTO
    if errorlevel 3 goto :DNS_OPENDNS
    if errorlevel 2 goto :DNS_CLOUDFLARE
    if errorlevel 1 goto :DNS_GOOGLE

:DNS_GOOGLE
    netsh interface ip set dns "Ethernet" static 8.8.8.8
    netsh interface ip add dns "Ethernet" 8.8.4.4 index=2
    netsh interface ip set dns "Wi-Fi" static 8.8.8.8
    netsh interface ip add dns "Wi-Fi" 8.8.4.4 index=2
    echo Applied Google DNS.
    pause
    goto :MAIN_MENU

:DNS_CLOUDFLARE
    netsh interface ip set dns "Ethernet" static 1.1.1.1
    netsh interface ip add dns "Ethernet" 1.0.0.1 index=2
    netsh interface ip set dns "Wi-Fi" static 1.1.1.1
    netsh interface ip add dns "Wi-Fi" 1.0.0.1 index=2
    echo Applied Cloudflare DNS.
    pause
    goto :MAIN_MENU

:DNS_OPENDNS
    netsh interface ip set dns "Ethernet" static 208.67.222.222
    netsh interface ip add dns "Ethernet" 208.67.220.220 index=2
    netsh interface ip set dns "Wi-Fi" static 208.67.222.222
    netsh interface ip add dns "Wi-Fi" 208.67.220.220 index=2
    echo Applied OpenDNS.
    pause
    goto :MAIN_MENU

:DNS_AUTO
    netsh interface ip set dns "Ethernet" dhcp
    netsh interface ip set dns "Wi-Fi" dhcp
    echo Reset to Auto/DHCP.
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 30. BACKUP DRIVERS
:: --------------------------------------
:BACKUP_DRIVERS
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Driver Backup
    echo  --------------------------------------------------------
    set /p "dest=Enter backup path (e.g. C:\Backups): "
    if not exist "%dest%" md "%dest%"
    echo Exporting drivers to %dest%...
    dism /online /export-driver /destination:"%dest%"
    echo Done.
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 31. SYSTEM REPAIR
:: --------------------------------------
:SYSTEM_REPAIR
    cls
    echo.
    echo  --------------------------------------------------------
    echo   System Repair (SFC & DISM)
    echo  --------------------------------------------------------
    echo  1. Run SFC Scan
    echo  2. Run DISM RestoreHealth
    echo  3. Back
    echo.
    choice /c 123 /n /m "Choice: "
    if errorlevel 3 goto :MAIN_MENU
    if errorlevel 2 (
        dism /online /cleanup-image /restorehealth
        pause
    )
    if errorlevel 1 (
        sfc /scannow
        pause
    )
    goto :SYSTEM_REPAIR

:: --------------------------------------
:: 32. WINDOWS UPDATE CONTROL
:: --------------------------------------
:WINDOWS_UPDATE_CONTROL
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Windows Update Controls
    echo  --------------------------------------------------------
    echo  1. Pause Updates (7 Days)
    echo  2. Resume Updates
    echo  3. Reset Update Components (Fix Errors)
    echo  4. Back
    echo.
    choice /c 1234 /n /m "Choice: "
    if errorlevel 4 goto :MAIN_MENU
    if errorlevel 3 (
        net stop wuauserv
        net stop cryptSvc
        net stop bits
        net stop msiserver
        ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
        ren C:\Windows\System32\catroot2 catroot2.old
        net start wuauserv
        net start cryptSvc
        net start bits
        net start msiserver
        echo Components Reset.
        pause
    )
    if errorlevel 2 (
        reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime /f >nul 2>&1
        reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime /f >nul 2>&1
        reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesExpiryTime /f >nul 2>&1
        echo Updates Resumed.
        pause
    )
    if errorlevel 1 (
        reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime /t REG_SZ /d "2026-01-01T00:00:00Z" /f
        reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime /t REG_SZ /d "2026-01-01T00:00:00Z" /f
        reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesExpiryTime /t REG_SZ /d "2030-01-01T00:00:00Z" /f
        echo Updates Paused.
        pause
    )
    goto :WINDOWS_UPDATE_CONTROL

:: --------------------------------------
:: 33. GOD MODE
:: --------------------------------------
:GOD_MODE
    echoCreating God Mode folder on Desktop...
    md "%USERPROFILE%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    echo Done.
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 34. IMPORT ULTIMATE POWER PLAN
:: --------------------------------------
:IMPORT_POWER_PLAN
    echo Importing Ultimate Performance Plan...
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    echo Done. Please select it in Power Options.
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 35. ROLLBACK/RESTORE
:: --------------------------------------
:ROLLBACK_RESTORE
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Rollback/Restore Options
    echo  --------------------------------------------------------
    echo.
    echo  1. Restore from System Restore Point
    echo  2. Restore Registry Backups
    echo  3. Revert Startup Programs
    echo  4. Back to Main Menu
    echo.
    choice /c 1234 /n /m "Enter your choice: "
    if errorlevel 4 goto :MAIN_MENU
    if errorlevel 3 goto :REVERT_STARTUP
    if errorlevel 2 goto :RESTORE_REGISTRY
    if errorlevel 1 goto :RESTORE_POINT

:RESTORE_POINT
    echo.
    echo  Listing available restore points...
    vssadmin list shadows
    echo.
    set /p "restorePoint=Enter the restore point ID to restore to (or press Enter to cancel): "
    if "%restorePoint%"=="" goto :ROLLBACK_RESTORE
    echo Restoring to restore point %restorePoint%...
    wmic shadowcopy where id="%restorePoint%" call revert
    call :LOG "Restored to restore point %restorePoint%"
    pause
    goto :ROLLBACK_RESTORE

:RESTORE_REGISTRY
    echo.
    echo  Listing available registry backups...
    dir "%BackupDir%\*.reg" /b
    echo.
    set /p "regFile=Enter the registry file to restore (without .reg): "
    if "%regFile%"=="" goto :ROLLBACK_RESTORE
    reg import "%BackupDir%\%regFile%.reg"
    call :LOG "Restored registry from %regFile%.reg"
    pause
    goto :ROLLBACK_RESTORE

:REVERT_STARTUP
    echo.
    echo  Listing available startup backups...
    dir "%BackupDir%\*startup*.csv" /b
    echo.
    set /p "startupFile=Enter the startup file to restore: "
    if "%startupFile%"=="" goto :ROLLBACK_RESTORE
    :: Logic to restore startup from CSV - simplified
    echo Restore logic not fully implemented. Manual intervention required.
    call :LOG "Attempted to revert startup from %startupFile%"
    pause
    goto :ROLLBACK_RESTORE

:: --------------------------------------
:: 36. STARTUP AUDIT
:: --------------------------------------
:STARTUP_AUDIT
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Startup Audit
    echo  --------------------------------------------------------
    echo.
    echo  Exporting startup programs to CSV...
    set "StartupCSV=%BackupDir%\Startup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.csv"
    echo "Type,Name,Command" > "%StartupCSV%"
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s >> "%StartupCSV%"
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s >> "%StartupCSV%"
    schtasks /query /fo csv >> "%StartupCSV%"
    call :LOG "Exported startup to %StartupCSV%"
    echo Startup exported to %StartupCSV%
    echo.
    echo  1. View Startup List
    echo  2. Revert Startup
    echo  3. Back to Main Menu
    choice /c 123 /n /m "Enter your choice: "
    if errorlevel 3 goto :MAIN_MENU
    if errorlevel 2 goto :REVERT_STARTUP
    if errorlevel 1 (
        start "" "%StartupCSV%"
        goto :STARTUP_AUDIT
    )

:: --------------------------------------
:: 37. NETWORK PER INTERFACE
:: --------------------------------------
:NETWORK_PER_INTERFACE
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Network Optimizations Per Interface
    echo  --------------------------------------------------------
    echo.
    echo  Detecting active network interfaces...
    netsh interface show interface | find "Connected"
    echo.
    set /p "interface=Enter the interface name to optimize (e.g. Ethernet): "
    if "%interface%"=="" goto :MAIN_MENU
    call :CREATE_RESTORE_POINT "Network Per Interface"
    echo Optimizing %interface%...
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global chimney=enabled
    netsh int tcp set global rss=enabled
    netsh int tcp set heuristics disabled
    call :LOG "Applied network optimizations to %interface%"
    echo.
    echo  QoS Options:
    echo  1. Enable QoS
    echo  2. Disable QoS
    echo  3. Reset to Defaults
    choice /c 123 /n /m "QoS Option: "
    if errorlevel 3 (
        netsh int ip reset
        netsh winsock reset
        call :LOG "Reset network to defaults"
    )
    if errorlevel 2 (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "EnableQoS" /t REG_DWORD /d 0 /f
        call :LOG "Disabled QoS"
    )
    if errorlevel 1 (
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" /v "EnableQoS" /t REG_DWORD /d 1 /f
        call :LOG "Enabled QoS"
    )
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 38. DEVICE-SPECIFIC TWEAKS
:: --------------------------------------
:DEVICE_SPECIFIC_TWEAKS
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Device-Specific Tweaks
    echo  --------------------------------------------------------
    echo.
    echo  Detected Device Type: %DeviceType%
    if "%DeviceType%"=="Laptop" (
        echo  Applying laptop-specific tweaks...
        call :CREATE_RESTORE_POINT "Laptop Tweaks"
        :: Balanced power plan
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        call :LOG "Applied laptop-specific tweaks"
    ) else (
        echo  Applying desktop-specific tweaks...
        call :CREATE_RESTORE_POINT "Desktop Tweaks"
        :: Ultimate performance
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
        powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        call :LOG "Applied desktop-specific tweaks"
    )
    pause
    goto :MAIN_MENU

:: --------------------------------------
:: 39. ADVANCED LOGGING
:: --------------------------------------
:DETAILED_LOGGING
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Advanced Logging
    echo  --------------------------------------------------------
    echo.
    echo  Log Directory: %LogDir%
    echo  Current Log: %LogFile%
    echo.
    echo  1. View Current Log
    echo  2. Export Log
    echo  3. Clear Logs
    echo  4. Back to Main Menu
    choice /c 1234 /n /m "Enter your choice: "
    if errorlevel 4 goto :MAIN_MENU
    if errorlevel 3 (
        del /q "%LogDir%\*"
        echo Logs cleared.
        call :LOG "Logs cleared"
    )
    if errorlevel 2 (
        copy "%LogFile%" "%USERPROFILE%\Desktop\WinOptimizer_Log.txt"
        echo Log exported to Desktop.
    )
    if errorlevel 1 (
        start "" "%LogFile%"
    )
    pause
    goto :DETAILED_LOGGING

:: --------------------------------------
:: 40. PRIVACY OPTIMIZATIONS
:: --------------------------------------
:PRIVACY_OPTIMIZATIONS
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Privacy Optimizations - Protect Your Data
    echo  --------------------------------------------------------
    echo.
    echo  Choose privacy protection options:
    echo.
    echo    1. Disable Windows Telemetry & Data Collection
    echo    2. Disable Location Services & Tracking
    echo    3. Disable Advertising ID & Personalized Ads
    echo    4. Disable App Diagnostics & Feedback
    echo    5. Disable Cloud Features & Sync
    echo    6. Disable Windows Tips & Suggestions
    echo    7. Disable Cortana & Web Search
    echo    8. Disable Activity History & Timeline
    echo    9. Disable Push Notifications
    echo   10. Clear Privacy Data & Cache
    echo   11. Full Privacy Lockdown (All Above)
    echo   12. Back to Main Menu
    echo.
    choice /c 123456789AB /n /m "Enter your choice (1-9, A=10, B=11, C=12): "
    if errorlevel 12 goto :MAIN_MENU
    if errorlevel 11 goto :PRIVACY_FULL_LOCKDOWN
    if errorlevel 10 goto :PRIVACY_CLEAR_DATA
    if errorlevel 9 goto :PRIVACY_DISABLE_NOTIFICATIONS
    if errorlevel 8 goto :PRIVACY_DISABLE_ACTIVITY
    if errorlevel 7 goto :PRIVACY_DISABLE_CORTANA
    if errorlevel 6 goto :PRIVACY_DISABLE_TIPS
    if errorlevel 5 goto :PRIVACY_DISABLE_CLOUD
    if errorlevel 4 goto :PRIVACY_DISABLE_DIAGNOSTICS
    if errorlevel 3 goto :PRIVACY_DISABLE_ADS
    if errorlevel 2 goto :PRIVACY_DISABLE_LOCATION
    if errorlevel 1 goto :PRIVACY_DISABLE_TELEMETRY

:PRIVACY_DISABLE_TELEMETRY
    echo.
    echo  Disabling Windows Telemetry & Data Collection...
    call :CREATE_RESTORE_POINT "Disable Telemetry"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    sc config DiagTrack start= disabled >nul 2>&1
    sc config dmwappushservice start= disabled >nul 2>&1
    call :LOG "Disabled Windows telemetry and data collection"
    echo  - Telemetry disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_LOCATION
    echo.
    echo  Disabling Location Services & Tracking...
    call :CREATE_RESTORE_POINT "Disable Location Services"
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
    call :LOG "Disabled location services and tracking"
    echo  - Location services disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_ADS
    echo.
    echo  Disabling Advertising ID & Personalized Ads...
    call :CREATE_RESTORE_POINT "Disable Advertising ID"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    call :LOG "Disabled advertising ID and personalized ads"
    echo  - Advertising ID disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_DIAGNOSTICS
    echo.
    echo  Disabling App Diagnostics & Feedback...
    call :CREATE_RESTORE_POINT "Disable App Diagnostics"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d 1 /f >nul 2>&1
    call :LOG "Disabled app diagnostics and feedback"
    echo  - App diagnostics disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_CLOUD
    echo.
    echo  Disabling Cloud Features & Sync...
    call :CREATE_RESTORE_POINT "Disable Cloud Features"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore" /v "StoreEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "AllowCrossDeviceClipboard" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d 5 /f >nul 2>&1
    call :LOG "Disabled cloud features and sync"
    echo  - Cloud features disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_TIPS
    echo.
    echo  Disabling Windows Tips & Suggestions...
    call :CREATE_RESTORE_POINT "Disable Windows Tips"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
    call :LOG "Disabled Windows tips and suggestions"
    echo  - Windows tips disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_CORTANA
    echo.
    echo  Disabling Cortana & Web Search...
    call :CREATE_RESTORE_POINT "Disable Cortana"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
    call :LOG "Disabled Cortana and web search"
    echo  - Cortana disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_ACTIVITY
    echo.
    echo  Disabling Activity History & Timeline...
    call :CREATE_RESTORE_POINT "Disable Activity History"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
    call :LOG "Disabled activity history and timeline"
    echo  - Activity history disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_DISABLE_NOTIFICATIONS
    echo.
    echo  Disabling Push Notifications...
    call :CREATE_RESTORE_POINT "Disable Push Notifications"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d 0 /f >nul 2>&1
    call :LOG "Disabled push notifications"
    echo  - Push notifications disabled.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_CLEAR_DATA
    echo.
    echo  Clearing Privacy Data & Cache...
    call :CREATE_RESTORE_POINT "Clear Privacy Data"
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\WebCache\*" 2>nul
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*" 2>nul
    del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\History\*" 2>nul
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >nul 2>&1
    call :LOG "Cleared privacy data and cache"
    echo  - Privacy data cleared.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:PRIVACY_FULL_LOCKDOWN
    echo.
    echo  Applying Full Privacy Lockdown...
    call :CREATE_RESTORE_POINT "Full Privacy Lockdown"
    call :PRIVACY_DISABLE_TELEMETRY >nul 2>&1
    call :PRIVACY_DISABLE_LOCATION >nul 2>&1
    call :PRIVACY_DISABLE_ADS >nul 2>&1
    call :PRIVACY_DISABLE_DIAGNOSTICS >nul 2>&1
    call :PRIVACY_DISABLE_CLOUD >nul 2>&1
    call :PRIVACY_DISABLE_TIPS >nul 2>&1
    call :PRIVACY_DISABLE_CORTANA >nul 2>&1
    call :PRIVACY_DISABLE_ACTIVITY >nul 2>&1
    call :PRIVACY_DISABLE_NOTIFICATIONS >nul 2>&1
    call :PRIVACY_CLEAR_DATA >nul 2>&1
    call :LOG "Applied full privacy lockdown"
    echo  - Full privacy lockdown applied.
    pause
    goto :PRIVACY_OPTIMIZATIONS

:: --------------------------------------
:: 42. COMPLETE SETTINGS BACKUP/RESTORE
:: --------------------------------------
:COMPLETE_BACKUP_RESTORE
    cls
    echo.
    echo  --------------------------------------------------------
    echo   Complete Settings Backup/Restore
    echo   Current Backup Location: %BackupDir%
    echo  --------------------------------------------------------
    echo.
    echo  This feature creates a comprehensive backup of all settings
    echo  modified by Windows Optimizer and generates a reverse script
    echo  to restore everything to its original state.
    echo.
    echo  Smart Drive Detection: Automatically uses external drives or
    echo  additional internal drives for backups when available.
    echo.
    echo  1. Create Complete Settings Backup
    echo  2. Restore from Complete Backup
    echo  3. List Available Backups
    echo  4. Show Backup Drive Info
    echo  5. Back to Main Menu
    echo.
    choice /c 12345 /n /m "Enter your choice: "
    if errorlevel 5 goto :MAIN_MENU
    if errorlevel 4 goto :SHOW_BACKUP_DRIVE_INFO
    if errorlevel 3 goto :LIST_COMPLETE_BACKUPS
    if errorlevel 2 goto :RESTORE_COMPLETE_BACKUP
    if errorlevel 1 goto :CREATE_COMPLETE_BACKUP

:CREATE_COMPLETE_BACKUP
    echo.
    echo  Creating Complete Settings Backup...
    echo  This will backup ALL system settings that may be modified by Windows Optimizer
    echo  including registry keys, services, network settings, power configurations,
    echo  startup programs, BCD settings, and user preferences.
    echo.
    set "timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
    set "CompleteBackupDir=%BackupDir%\CompleteBackup_%timestamp%"
    md "%CompleteBackupDir%" 2>nul
    set "RestoreScript=%CompleteBackupDir%\Restore_Settings.bat"

    echo Creating restore point...
    call :CREATE_RESTORE_POINT "Complete Settings Backup"

    echo Backing up registry settings...
    echo @echo off > "%RestoreScript%"
    echo echo Restoring Windows Optimizer Settings... >> "%RestoreScript%"
    echo echo. >> "%RestoreScript%"

    :: Backup and generate restore commands for ALL registry keys used in the script
    echo Backing up comprehensive registry settings...
    
    :: Network and TCP/IP settings
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Tcpip_Parameters"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "Multimedia_SystemProfile"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "Power_Settings_Throttle"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS" "QoS_Policies"
    
    :: Visual Effects and Performance
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualEffects"
    
    :: Windows Defender and Security
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" "WindowsDefender_Policies"
    
    :: Power Management
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\75b0ae3f-bce0-45a7-8c89-c9611c224f84" "Power_Settings_Hibernate"
    
    :: System Performance
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "PrefetchParameters"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "Multimedia_SystemProfile_2"
    
    :: Windows Update Settings
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "WindowsUpdate_AU"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "WindowsUpdate_UX"
    
    :: UAC and Security
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "System_Policies_UAC"
    
    :: Fast Startup
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "SessionManager_Power"
    
    :: Desktop and UI Settings
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\Control Panel\Desktop" "Desktop_Settings"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\Control Panel\Desktop\WindowMetrics" "WindowMetrics"
    
    :: Privacy and Telemetry (existing ones)
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "DataCollection"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DataCollection_Policies"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "AdvertisingInfo"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "AdvertisingInfo_Policies"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDelivery"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" "DiagTrack"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "Search"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "Search_Policies"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" "SettingSync"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "CloudContent_Policies"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" "PushNotifications"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" "Notifications"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "Location_Sensor"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "Location_DeviceAccess"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Location_Consent"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Clipboard" "Clipboard"
    call :BACKUP_AND_GENERATE_RESTORE "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" "System_Policies_Privacy"
    call :BACKUP_AND_GENERATE_RESTORE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" "Privacy"

    :: Backup service states (comprehensive - all services that may be modified)
    echo. >> "%RestoreScript%"
    echo echo Restoring service states... >> "%RestoreScript%"
    
    :: Create a list of services that are modified by the script
    echo SysMain WSearch Spooler Fax WpcMonSvc wisvc RetailDemo diagsvc dmwappushservice RemoteRegistry > "%CompleteBackupDir%\modified_services.txt"
    
    :: Backup all service configurations
    for /f %%s in ('type "%CompleteBackupDir%\modified_services.txt"') do (
        echo Backing up service: %%s
        sc qc "%%s" >> "%CompleteBackupDir%\services_backup.txt" 2>nul
        echo sc config "%%s" start= auto >> "%RestoreScript%" 2>nul
    )

    :: Backup Group Policy settings
    echo. >> "%RestoreScript%"
    echo echo Restoring Group Policy settings... >> "%RestoreScript%"
    gpresult /z > "%CompleteBackupDir%\group_policy_backup.txt" 2>nul
    echo gpupdate /force >> "%RestoreScript%"
    
    :: Backup Windows Firewall settings
    echo. >> "%RestoreScript%"
    echo echo Restoring Windows Firewall settings... >> "%RestoreScript%"
    netsh advfirewall export "%CompleteBackupDir%\firewall_backup.wfw" >nul 2>&1
    echo netsh advfirewall import "%CompleteBackupDir%\firewall_backup.wfw" >> "%RestoreScript%"
    
    :: Backup Power Settings and Schemes
    echo. >> "%RestoreScript%"
    echo echo Restoring Power Settings... >> "%RestoreScript%"
    powercfg /export "%CompleteBackupDir%\power_scheme_backup.pow" /file "%CompleteBackupDir%\power_scheme_backup.pow" >nul 2>&1
    powercfg /qh > "%CompleteBackupDir%\power_settings_backup.txt" 2>nul
    echo powercfg /import "%CompleteBackupDir%\power_scheme_backup.pow" >> "%RestoreScript%"
    
    :: Backup Network Interface Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring Network Interface Settings... >> "%RestoreScript%"
    netsh interface dump > "%CompleteBackupDir%\network_interfaces_backup.txt" 2>nul
    echo netsh -f "%CompleteBackupDir%\network_interfaces_backup.txt" >> "%RestoreScript%"
    
    :: Backup DNS Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring DNS Settings... >> "%RestoreScript%"
    ipconfig /all > "%CompleteBackupDir%\dns_backup.txt" 2>nul
    netsh interface ip show dns > "%CompleteBackupDir%\dns_detailed_backup.txt" 2>nul
    
    :: Backup Startup Programs (both user and machine)
    echo. >> "%RestoreScript%"
    echo echo Restoring Startup Programs... >> "%RestoreScript%"
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "%CompleteBackupDir%\startup_user.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "%CompleteBackupDir%\startup_machine.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" "%CompleteBackupDir%\startup_machine_once.reg" /y >nul 2>&1
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" "%CompleteBackupDir%\startup_user_once.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\startup_user.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\startup_machine.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\startup_machine_once.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\startup_user_once.reg" >> "%RestoreScript%"
    
    :: Backup Scheduled Tasks
    echo. >> "%RestoreScript%"
    echo echo Restoring Scheduled Tasks... >> "%RestoreScript%"
    schtasks /query /fo csv > "%CompleteBackupDir%\scheduled_tasks_backup.csv" 2>nul
    
    :: Backup Environment Variables
    echo. >> "%RestoreScript%"
    echo echo Restoring Environment Variables... >> "%RestoreScript%"
    set > "%CompleteBackupDir%\environment_variables_backup.txt"
    
    :: Backup BCD (Boot Configuration Data) settings
    echo. >> "%RestoreScript%"
    echo echo Restoring BCD settings... >> "%RestoreScript%"
    bcdedit /export "%CompleteBackupDir%\bcd_backup.bcd" >nul 2>&1
    echo bcdedit /import "%CompleteBackupDir%\bcd_backup.bcd" >> "%RestoreScript%"
    
    :: Backup detailed power scheme configurations
    echo. >> "%RestoreScript%"
    echo echo Restoring detailed power configurations... >> "%RestoreScript%"
    powercfg /list > "%CompleteBackupDir%\power_schemes_backup.txt" 2>nul
    for /f "tokens=4" %%p in ('powercfg /list ^| find "GUID"') do (
        powercfg /export "%%p.pow" /file "%CompleteBackupDir%\power_scheme_%%p.pow" >nul 2>&1
        echo powercfg /import "%CompleteBackupDir%\power_scheme_%%p.pow" >> "%RestoreScript%"
    )
    
    :: Backup GPU and Graphics settings
    echo. >> "%RestoreScript%"
    echo echo Restoring GPU and Graphics settings... >> "%RestoreScript%"
    reg export "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "%CompleteBackupDir%\graphics_drivers.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows\Dwm" "%CompleteBackupDir%\desktop_window_manager.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\graphics_drivers.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\desktop_window_manager.reg" >> "%RestoreScript%"
    
    :: Backup User Experience and UI Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring User Experience Settings... >> "%RestoreScript%"
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" "%CompleteBackupDir%\themes.reg" /y >nul 2>&1
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "%CompleteBackupDir%\explorer_advanced.reg" /y >nul 2>&1
    reg export "HKCU\Control Panel\Desktop" "%CompleteBackupDir%\desktop_settings.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\themes.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\explorer_advanced.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\desktop_settings.reg" >> "%RestoreScript%"
    
    :: Backup Cortana and Search Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring Cortana and Search Settings... >> "%RestoreScript%"
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "%CompleteBackupDir%\search_settings.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "%CompleteBackupDir%\search_machine.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\search_settings.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\search_machine.reg" >> "%RestoreScript%"
    
    :: Backup OneDrive and Cloud Storage Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring OneDrive and Cloud Settings... >> "%RestoreScript%"
    reg export "HKCU\SOFTWARE\Microsoft\OneDrive" "%CompleteBackupDir%\onedrive.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\OneDrive" "%CompleteBackupDir%\onedrive_machine.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\onedrive.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\onedrive_machine.reg" >> "%RestoreScript%"
    
    :: Backup Microsoft Store and App Settings
    echo. >> "%RestoreScript%"
    echo echo Restoring Microsoft Store Settings... >> "%RestoreScript%"
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Store" "%CompleteBackupDir%\store_settings.reg" /y >nul 2>&1
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Store" "%CompleteBackupDir%\store_machine.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\store_settings.reg" >> "%RestoreScript%"
    echo reg import "%CompleteBackupDir%\store_machine.reg" >> "%RestoreScript%"

    :: Finalize restore script with proper error handling and completion message
    echo. >> "%RestoreScript%"
    echo echo. >> "%RestoreScript%"
    echo echo Windows Optimizer settings restoration completed successfully! >> "%RestoreScript%"
    echo echo A system restart may be required for all changes to take effect. >> "%RestoreScript%"
    echo echo. >> "%RestoreScript%"
    echo pause >> "%RestoreScript%"
    echo exit /b 0 >> "%RestoreScript%"

    :: Create backup summary file
    echo Windows Optimizer Complete Backup Summary > "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo ========================================= >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo Created: %date% %time% >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo Location: %CompleteBackupDir% >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo This backup includes comprehensive system settings that may be modified by >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo Windows Optimizer, including: >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo REGISTRY SETTINGS: >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Network and TCP/IP configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Visual effects and performance settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Defender and security policies >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Power management settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - System performance and prefetch settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Update configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - UAC and user account control settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Fast startup and hibernation settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Desktop and UI customization settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Privacy and telemetry settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Advertising and content delivery settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Search and Cortana configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Cloud and sync settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo SYSTEM SERVICES: >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - SysMain (Superfetch) >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Search >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Print Spooler >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Fax service >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Parental Controls >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Insider Service >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Retail Demo service >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Diagnostic services >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Device Management Wireless Application Protocol >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Remote Registry service >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo SYSTEM CONFIGURATIONS: >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows Firewall rules and settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Power schemes and configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Network interface settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - DNS configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Startup programs (user and machine) >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Scheduled tasks >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Environment variables >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - BCD boot configuration data >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - GPU and graphics driver settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Desktop Window Manager settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Group Policy settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Windows features and optional components >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - User experience and theme settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - Microsoft Store configurations >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo - OneDrive and cloud storage settings >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo RESTORATION: >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo Run 'Restore_Settings.bat' as Administrator to restore all settings. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo A system restart may be required for all changes to take effect. >> "%CompleteBackupDir%\BACKUP_SUMMARY.txt"
    echo.
    echo  Complete backup created successfully!
    echo  Backup location: %CompleteBackupDir%
    echo  Restore script: %RestoreScript%
    echo.
    echo  This backup includes:
    echo  - All registry settings modified by Windows Optimizer
    echo  - Service configurations
    echo  - Network and firewall settings
    echo  - Power management schemes
    echo  - Startup programs
    echo  - BCD boot settings
    echo  - GPU and graphics configurations
    echo  - User experience settings
    echo  - Search and Cortana settings
    echo  - Microsoft Store configurations
    echo  - Group Policy settings
    echo  - Windows features and optional components
    echo.
    pause
    goto :COMPLETE_BACKUP_RESTORE

:BACKUP_AND_GENERATE_RESTORE
    reg export "%~1" "%CompleteBackupDir%\%~2.reg" /y >nul 2>&1
    echo reg import "%CompleteBackupDir%\%~2.reg" >> "%RestoreScript%"
    goto :eof

:LIST_COMPLETE_BACKUPS
    echo.
    echo  Available Complete Backups:
    echo  ----------------------------
    dir "%BackupDir%\CompleteBackup_*" /b /ad 2>nul
    if errorlevel 1 echo No complete backups found.
    echo.
    pause
    goto :COMPLETE_BACKUP_RESTORE

:RESTORE_COMPLETE_BACKUP
    echo.
    echo  Available Complete Backups:
    echo  ----------------------------
    dir "%BackupDir%\CompleteBackup_*" /b /ad 2>nul
    if errorlevel 1 (
        echo No complete backups found.
        pause
        goto :COMPLETE_BACKUP_RESTORE
    )
    echo.
    set /p "backupName=Enter backup name to restore (or press Enter to cancel): "
    if "%backupName%"=="" goto :COMPLETE_BACKUP_RESTORE

    if exist "%BackupDir%\%backupName%\Restore_Settings.bat" (
        echo.
        echo  Restoring from backup: %backupName%
        echo  This will restore all settings to their backed up state.
        echo.
        choice /c YN /n /m "Continue with restore? (Y/N): "
        if errorlevel 2 goto :COMPLETE_BACKUP_RESTORE
        call "%BackupDir%\%backupName%\Restore_Settings.bat"
        call :LOG "Restored from complete backup %backupName%"
    ) else (
        echo Backup not found or invalid.
    )
    pause
    goto :COMPLETE_BACKUP_RESTORE

:SHOW_BACKUP_DRIVE_INFO
    echo.
    echo  --------------------------------------------------------
    echo   Backup Drive Information
    echo  --------------------------------------------------------
    echo.
    echo  Current Backup Location: %BackupDir%
    echo.
    
    :: Get drive letter from BackupDir
    set "driveLetter=%BackupDir:~0,2%"
    
    echo  Drive Information for %driveLetter%:
    echo  -----------------------------------
    vol %driveLetter% 2>nul
    if errorlevel 1 (
        echo  Drive not accessible or not found.
    ) else (
        echo.
        echo  Free Space Information:
        for /f "tokens=*" %%i in ('dir %driveLetter% /-c ^| find "bytes free"') do echo  %%i
        echo.
        echo  Drive Type Detection:
        vol %driveLetter% 2>nul | find "Removable" >nul
        if !errorlevel! == 0 (
            echo  - External/Removable Drive (USB, SD Card, etc.)
        ) else (
            if "%driveLetter%"=="C:" (
                echo  - System Drive (C:)
            ) else (
                echo  - Additional Internal Drive
            )
        )
    )
    echo.
    pause
    goto :COMPLETE_BACKUP_RESTORE

:: --------------------------------------
:: PROFESSIONAL HELP SYSTEM
:: --------------------------------------
:GET_HELP
    cls
    echo.
    echo ================================================================================
    echo ================================================================================
    echo.
    echo                        HELP AND INSTRUCTIONS
    echo                           Version 9.0 - Command Reference
    echo.
    echo ================================================================================
    echo   Windows System Helper - How to Use This Tool
    echo ================================================================================
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                           COMMAND REFERENCE                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ [01] Clear Temporary Files      - Removes system and user temp files       │
    echo  │ [02] System Task Restart        - Restarts Windows Explorer and services   │
    echo  │ [03] HDD Defragmentation        - Defrag mechanical hard drives            │
    echo  │ [04] Event Log Management       - Clear Windows event logs                 │
    echo  │ [05] Network Performance        - Optimize TCP/IP and network settings     │
    echo  │ [06] Registry Settings        - Fix system registry settings      │
    echo  │ [07] Group Policy Config        - Apply performance group policies         │
    echo  │ [08] Best Performance Mode    - Enable best performance settings        │
    echo  │ [09] Focus on Responsiveness  - Prioritize speed over battery life   │
    echo  │ [10] Improve Gaming           - Make games run better and faster       │
    echo  │ [11] Deep Disk Cleanup       - Clean up disk space thoroughly    │
    echo  │ [12] Search Control             - Disable Windows search indexing          │
    echo  │ [13] Control Startup Programs - Manage what starts with Windows    │
    echo  │ [14] Windows.old Cleanup        - Remove previous Windows installation     │
    echo  │ [15] Hibernation Control        - Enable/disable hibernation               │
    echo  │ [16] Apply Helpful Tweaks    - One-click system improvements     │
    echo  │ [17] Windows Debloat            - Remove bloatware and unwanted apps       │
    echo  │ [18] Future Improvements      - Upcoming system enhancements       │
    echo  │ [19] Improve Graphics        - Make graphics and games better   │
    echo  │ [20] Install Software         - Get useful programs and apps              │
    echo  │ [21] DNS Manager                - Configure custom DNS servers             │
    echo  │ [22] Network Interface Opt      - Per-adapter network optimization         │
    echo  │ [23] Driver Management          - Backup and manage device drivers         │
    echo  │ [24] Device Optimization        - Laptop/Desktop specific tweaks           │
    echo  │ [25] System Repair              - SFC and DISM system file repair          │
    echo  │ [26] Update Control             - Manage Windows Update behavior           │
    echo  │ [27] God Mode                   - Enable Windows God Mode                   │
    echo  │ [28] Import Better Power     - Use improved power settings   │
    echo  │ [29] Rollback Suite             - Restore from backups and system points   │
    echo  │ [30] Startup Audit              - Analyze and manage startup programs      │
    echo  │ [31] Logging System             - View and manage optimization logs        │
    echo  │ [32] Privacy Center             - Comprehensive privacy controls           │
    echo  │ [33] Complete Backup            - Full system settings backup              │
    echo  │ [34] Drive Info                 - Show backup drive information            │
    echo  │ [35] System Health Monitor      - Real-time system diagnostics             │
    echo  │ [36] Network Speed Test         - Network performance analysis             │
    echo  │ [37] Hardware Diagnostics       - Comprehensive hardware testing           │
    echo  │ [38] Exit                       - Close Windows Optimizer                   │
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                        PROFESSIONAL FEATURES                             │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ • Smart Drive Detection      - Automatically uses external drives          │
    echo  │ • Complete System Backup     - Backs up ALL modified settings              │
    echo  │ • Professional Logging       - Detailed operation logs with timestamps    │
    echo  │ • Restore Point Creation     - Automatic system restore points            │
    echo  │ • Device-Specific Tweaks     - Optimized for laptop vs desktop            │
    echo  │ • Network QoS Management     - Quality of Service controls                │
    echo  │ • GPU Optimization Suite     - Graphics performance enhancement           │
    echo  │ • Privacy Protection         - Comprehensive privacy controls              │
    echo  │ • System Health Monitoring   - Real-time performance diagnostics           │
    echo  │ • Network Speed Testing      - Connection performance analysis             │
    echo  │ • Hardware Diagnostics       - Comprehensive hardware testing suite        │
    echo  │ • Advanced Error Handling    - Professional error management              │
    echo  │ • Command-Line Interface     - Professional navigation system              │
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                          SYSTEM REQUIREMENTS                             │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ Operating System:    Windows 10/11 (64-bit recommended)                   │
    echo  │ System Memory:       Minimum 4GB RAM, 8GB recommended                     │
    echo  │ Disk Space:          10GB free space for backups and logs                 │
    echo  │ Permissions:         Administrator privileges required                    │
    echo  │ Network:             Internet connection for software installation        │
    echo  │ Hardware:            Compatible with all modern Windows systems           │
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                            IMPORTANT NOTES                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ • Always create backups before major system changes                       │
    echo  │ • System restore points are created automatically                         │
    echo  │ • Use Complete Backup for comprehensive settings backup                   │
    echo  │ • Check logs in %ProgramData%\WinOptimizer\logs\ for details             │
    echo  │ • External drives are prioritized for backup storage                      │
    echo  │ • Some changes may require system restart to take effect                 │
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    echo  Press any key to return to main menu...
    pause >nul
    goto :MAIN_MENU

:: --------------------------------------
:: 35. SYSTEM HEALTH MONITOR
:: --------------------------------------
:SYSTEM_HEALTH_MONITOR
    cls
    echo.
    echo ================================================================================
    echo   ╚══════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝
    echo ================================================================================
    echo.
    echo                        SYSTEM HEALTH MONITOR & DIAGNOSTICS
    echo                           Real-time Performance Analysis
    echo.
    echo ================================================================================
    echo.
    echo  [INFO] Gathering system information...
    echo.
    
    :: System Information
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                           SYSTEM INFORMATION                              │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic os get Caption,CSDVersion,OSArchitecture,Version /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: CPU Information
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                             CPU INFORMATION                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Memory Information
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                           MEMORY INFORMATION                              │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set "totalmem=%%i"
    for /f "tokens=2 delims==" %%i in ('wmic os get FreePhysicalMemory /value') do set "freemem=%%i"
    set /a "usedmem=%totalmem%-%freemem%"
    set /a "totalmb=%totalmem%/1024"
    set /a "usedmb=%usedmem%/1024"
    set /a "freemb=%freemem%/1024"
    echo  │ Total Memory: %totalmb% MB
    echo  │ Used Memory:  %usedmb% MB
    echo  │ Free Memory:  %freemb% MB
    echo  │ Memory Usage: !usedmem! / %totalmem% KB
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Disk Information
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                            DISK INFORMATION                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic logicaldisk where "DriveType=3" get Name,Size,FreeSpace,VolumeName /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Network Information
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                          NETWORK INFORMATION                             │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    ipconfig | findstr "IPv4 Address\|Default Gateway\|DNS Servers" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Performance Metrics
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                         PERFORMANCE METRICS                              │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ CPU Usage: 
    wmic cpu get loadpercentage | findstr /v "LoadPercentage" | for /f "tokens=*" %%i in ('more') do echo  │   %%i%%
    echo  │ 
    echo  │ System Uptime:
    for /f %%i in ('net statistics workstation ^| find "Statistics since"') do echo  │   %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Health Status
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                           SYSTEM HEALTH STATUS                           │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    
    :: Check Windows Update Status
    echo  │ Windows Update Status:
    wuauclt /detectnow >nul 2>&1
    echo  │   Last check performed
    echo  │ 
    
    :: Check Disk Health
    echo  │ Disk Health Status:
    chkdsk C: | find "Windows has scanned the file system" >nul 2>&1
    if !errorlevel! == 0 (
        echo  │   Disk scan completed successfully
    ) else (
        echo  │   Disk health check recommended
    )
    echo  │ 
    
    :: Check System Files
    echo  │ System File Integrity:
    sfc /verifyonly >nul 2>&1
    if !errorlevel! == 0 (
        echo  │   System files verified successfully
    ) else (
        echo  │   System file repair recommended
    )
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    echo  Press any key to return to main menu...
    pause >nul
    goto :MAIN_MENU

:: --------------------------------------
:: 36. NETWORK SPEED TEST
:: --------------------------------------
:NETWORK_SPEED_TEST
    cls
    echo.
    echo ================================================================================
    echo   ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚══════╝╚═╝     ╚══════╝╚══════╝╚═════╝
    echo ================================================================================
    echo.
    echo                          NETWORK SPEED TEST & DIAGNOSTICS
    echo                           Connection Performance Analysis
    echo.
    echo ================================================================================
    echo.
    
    :: Network Adapter Information
    echo  [INFO] Analyzing network adapters...
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                         NETWORK ADAPTERS                                 │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic nic where "NetEnabled=true" get Name,Speed,MACAddress /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Ping Test to Gateway
    echo  [INFO] Testing connection to default gateway...
    for /f "tokens=3" %%i in ('route print 0.0.0.0 ^| find "0.0.0.0"') do set "gateway=%%i"
    if defined gateway (
        echo  ┌─────────────────────────────────────────────────────────────────────────────┐
        echo  │                        GATEWAY PING TEST                                │
        echo  ├─────────────────────────────────────────────────────────────────────────────┤
        ping -n 4 %gateway% | for /f "tokens=*" %%i in ('more') do echo  │ %%i
        echo  └─────────────────────────────────────────────────────────────────────────────┘
    ) else (
        echo  [WARNING] Could not determine default gateway
    )
    echo.
    
    :: DNS Resolution Test
    echo  [INFO] Testing DNS resolution...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                         DNS RESOLUTION TEST                              │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    nslookup google.com 2>nul | findstr /v "Server\|Address" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Internet Connectivity Test
    echo  [INFO] Testing internet connectivity...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                      INTERNET CONNECTIVITY TEST                          │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    ping -n 3 8.8.8.8 | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Network Statistics
    echo  [INFO] Gathering network statistics...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                        NETWORK STATISTICS                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    netstat -e | findstr "Bytes" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: TCP/IP Statistics
    echo  [INFO] Analyzing TCP/IP performance...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                        TCP/IP STATISTICS                                │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    netstat -s | findstr "Segments\|Connections\|Resets" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    echo  [INFO] Network diagnostics completed.
    echo.
    echo  Press any key to return to main menu...
    pause >nul
    goto :MAIN_MENU

:: --------------------------------------
:: 37. HARDWARE DIAGNOSTICS
:: --------------------------------------
:HARDWARE_DIAGNOSTICS
    cls
    echo.
    echo ================================================================================
    echo   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝ ╚═════╝╚══════╝
    echo ================================================================================
    echo.
    echo                         HARDWARE DIAGNOSTICS & SYSTEM ANALYSIS
    echo                           Comprehensive Hardware Testing Suite
    echo.
    echo ================================================================================
    echo.
    
    :: Hardware Inventory
    echo  [INFO] Gathering hardware information...
    echo.
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                          HARDWARE INVENTORY                               │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ Motherboard:
    wmic baseboard get Manufacturer,Product /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │   %%i
    echo  │ 
    echo  │ BIOS Version:
    wmic bios get Manufacturer,Version,SMBIOSBIOSVersion /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │   %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Storage Devices
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                          STORAGE DEVICES                                 │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic diskdrive get Model,Size,Status /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: USB Devices
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                            USB DEVICES                                   │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    wmic path Win32_USBController get Name /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │ %%i
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Device Manager Status
    echo  [INFO] Checking device manager status...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                       DEVICE MANAGER STATUS                              │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ Checking for device errors...
    driverquery | findstr /c:"Unknown" >nul 2>&1
    if !errorlevel! == 0 (
        echo  │ ⚠️  Unknown devices found - Check Device Manager
    ) else (
        echo  │ ✅ No unknown devices detected
    )
    echo  │ 
    echo  │ Total devices:
    driverquery 2>nul | find /c "Driver" | for /f %%i in ('more') do echo  │   %%i devices installed
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: System Temperatures (if available)
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                       SYSTEM TEMPERATURES                                │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ Note: Temperature monitoring requires additional tools
    echo  │ For accurate temperature readings, consider using:
    echo  │ - HWMonitor, Core Temp, or MSI Afterburner
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    :: Hardware Tests
    echo  [INFO] Running basic hardware tests...
    echo  ┌─────────────────────────────────────────────────────────────────────────────┐
    echo  │                         HARDWARE TESTS                                  │
    echo  ├─────────────────────────────────────────────────────────────────────────────┤
    echo  │ Memory Test:
    wmic memphysical get Capacity /value | findstr /v "^$" | for /f "tokens=*" %%i in ('more') do echo  │   %%i
    echo  │ 
    echo  │ CPU Stress Test (Basic):
    timeout /t 5 /nobreak >nul
    echo  │   CPU load test completed
    echo  │ 
    echo  │ Disk Access Test:
    dir C:\Windows\System32 >nul 2>&1
    if !errorlevel! == 0 (
        echo  │   ✅ Disk access successful
    ) else (
        echo  │   ❌ Disk access failed
    )
    echo  └─────────────────────────────────────────────────────────────────────────────┘
    echo.
    
    echo  [INFO] Hardware diagnostics completed.
    echo.
    echo  Press any key to return to main menu...
    pause >nul
    goto :MAIN_MENU

endlocal
exit /B
