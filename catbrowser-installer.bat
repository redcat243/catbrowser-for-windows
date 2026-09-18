@echo off
setlocal EnableDelayedExpansion

set "INSTALL_DIR=%ProgramFiles%\CatBrowser"
set "DESKTOP_DIR=%PUBLIC%\Desktop"
set "TEMP_DIR=%TEMP%\CatBrowserInstaller"
set "RELEASE_URL=https://github.com/redcat243/githubactionstuff/releases/download/eee/Catbrowser-Windows.zip"

:: 1. Display VBScript GUI Warning Popup
mkdir "%TEMP_DIR%" 2>nul
set "WARN_VBS=%TEMP_DIR%\warning.vbs"
echo Result = MsgBox("Warning: CatBrowser Setup will install files to Program Files and create desktop shortcuts. Do you want to proceed?", 33, "CatBrowser Installer Warning") > "%WARN_VBS%"
echo If Result = 2 Then WScript.Quit(1) >> "%WARN_VBS%"

cscript //nologo "%WARN_VBS%"
if %errorLevel% neq 0 (
    echo Setup aborted by user.
    rmdir /s /q "%TEMP_DIR%" 2>nul
    exit /b
)

:: 2. Check and request Administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Workspace setup...
mkdir "%INSTALL_DIR%" 2>nul

:: 3. Download release package via curl
echo Downloading CatBrowser release package...
curl -L -o "%TEMP_DIR%\CatBrowser.zip" "%RELEASE_URL%"

:: 4. Decompress ZIP contents directly into Program Files
echo Extracting executable and web assets...
powershell -Command "Expand-Archive -Path '%TEMP_DIR%\CatBrowser.zip' -DestinationPath '%INSTALL_DIR%' -Force"

:: 5. Generate VBScript to create Desktop shortcut
echo Creating Desktop shortcut...
set "SHORTCUT_VBS=%TEMP_DIR%\CreateShortcut.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%SHORTCUT_VBS%"
echo sLinkFile = "%DESKTOP_DIR%\CatBrowser.lnk" >> "%SHORTCUT_VBS%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%SHORTCUT_VBS%"
echo oLink.TargetPath = "%INSTALL_DIR%\CatBrowser.exe" >> "%SHORTCUT_VBS%"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%SHORTCUT_VBS%"
echo oLink.Description = "Launch CatBrowser" >> "%SHORTCUT_VBS%"
echo oLink.Save >> "%SHORTCUT_VBS%"

cscript //nologo "%SHORTCUT_VBS%"

:: 6. Cleanup temporary workspace
echo Cleaning up installer environment...
rmdir /s /q "%TEMP_DIR%"

echo Setup complete! CatBrowser is installed and available on your Desktop.
echo check for a blank thing in the tray icons that you can hover over click that to go back to the catbrowser home.
echo right click to go foward and back.
echo copy this and paste it into file explorer to see about catbrowser C:\Users\replacethiswithyourusername\Program Files\Catbrowser and click sammy.html to see about catbrowser.
pause
