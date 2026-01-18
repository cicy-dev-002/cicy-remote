@echo off
REM OpenCode MCP Configuration Script for Windows
REM This script helps configure the PyAutoGUI MCP server with OpenCode

echo PyAutoGUI MCP Server - OpenCode Configuration
echo ==============================================

REM Check if opencode is installed
opencode --version >nul 2>&1
if errorlevel 1 (
    echo Error: OpenCode is not installed. Please install it first:
    echo   curl -fsSL https://opencode.ai/install ^| bash
    goto :error
)

REM Determine config file location
if defined APPDATA (
    set "CONFIG_DIR=%APPDATA%\opencode"
) else (
    set "CONFIG_DIR=%USERPROFILE%\.config\opencode"
)

set "CONFIG_FILE=%CONFIG_DIR%\config.json"

echo OpenCode config location: %CONFIG_FILE%

REM Create config directory if it doesn't exist
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo Creating new OpenCode config file...
    echo {> "%CONFIG_FILE%"
    echo   "$schema": "https://opencode.ai/config.json",>> "%CONFIG_FILE%"
    echo   "mcp": {}>> "%CONFIG_FILE%"
    echo }>> "%CONFIG_FILE%"
)

REM Backup existing config
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATESTR=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIMESTR=%%a%%b
set "BACKUP_FILE=%CONFIG_FILE%.backup.%DATESTR%_%TIMESTR%"
copy "%CONFIG_FILE%" "%BACKUP_FILE%" >nul
echo Backup created: %BACKUP_FILE%

REM Get server URL from user
set /p SERVER_URL="Enter PyAutoGUI MCP server URL [http://localhost:8050/mcp]: "
if "%SERVER_URL%"=="" set SERVER_URL=http://localhost:8050/mcp

REM Create Python script to update config
set "TEMP_SCRIPT=%TEMP%\opencode_config.py"
echo import json > "%TEMP_SCRIPT%"
echo import os >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo config_file = r'%CONFIG_FILE%' >> "%TEMP_SCRIPT%"
echo server_url = r'%SERVER_URL%' >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo # Read existing config >> "%TEMP_SCRIPT%"
echo try: >> "%TEMP_SCRIPT%"
echo     with open(config_file, 'r') as f: >> "%TEMP_SCRIPT%"
echo         config = json.load(f) >> "%TEMP_SCRIPT%"
echo except (FileNotFoundError, json.JSONDecodeError): >> "%TEMP_SCRIPT%"
echo     config = {'$schema': 'https://opencode.ai/config.json'} >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo # Ensure mcp section exists >> "%TEMP_SCRIPT%"
echo if 'mcp' not in config: >> "%TEMP_SCRIPT%"
echo     config['mcp'] = {} >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo # Add PyAutoGUI server config >> "%TEMP_SCRIPT%"
echo config['mcp']['pyautogui'] = { >> "%TEMP_SCRIPT%"
echo     'type': 'remote', >> "%TEMP_SCRIPT%"
echo     'url': server_url, >> "%TEMP_SCRIPT%"
echo     'enabled': True, >> "%TEMP_SCRIPT%"
echo     'description': 'PyAutoGUI MCP Server - GUI automation tools for mouse control, keyboard input, screenshot capture, and visual debugging overlays' >> "%TEMP_SCRIPT%"
echo } >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo # Write updated config >> "%TEMP_SCRIPT%"
echo with open(config_file, 'w') as f: >> "%TEMP_SCRIPT%"
echo     json.dump(config, f, indent=2) >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo print(f'PyAutoGUI MCP server configured in OpenCode config: {config_file}') >> "%TEMP_SCRIPT%"
echo print(f'Server URL: {server_url}') >> "%TEMP_SCRIPT%"

REM Run the Python script
python "%TEMP_SCRIPT%"
if errorlevel 1 (
    echo Error: Failed to update OpenCode configuration
    goto :error
)

REM Clean up temp script
del "%TEMP_SCRIPT%"

echo.
echo ^✅ Configuration successful!
echo.
echo Next steps:
echo 1. Start the PyAutoGUI MCP server:
echo    start_server.bat
echo.
echo 2. In OpenCode, you can now use PyAutoGUI tools by adding 'use pyautogui' to your prompts
echo.
echo Example prompts:
echo   'Take a screenshot and save it as image.png. use pyautogui'
echo   'Move mouse to (100, 200) and click. use pyautogui'
echo   'Type "Hello World" using keyboard. use pyautogui'
goto :end

:error
echo.
echo ^❌ Configuration failed. Please check the error messages above.
pause
exit /b 1

:end
echo.
pause