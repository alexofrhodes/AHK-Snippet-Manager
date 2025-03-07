@echo off
setlocal enabledelayedexpansion

:: Define AutoHotkey installation directory
SET "AhkDir=C:\Program Files\AutoHotkey"
SET "ahk2exe=%AhkDir%\Compiler\Ahk2Exe.exe"
SET "Compiler=%AhkDir%\v2\AutoHotkey64.exe"

:: Locate the only .ahk file in the batch script's directory
set "thisBatDir=%~dp0"
set "ahk="
set "foundMultiple=false"
set "fileList="

for %%F in ("%thisBatDir%*.ahk") do (
    if not defined ahk (
        set "ahk=%%F"
    ) else (
        set "foundMultiple=true"
        set "fileList=!fileList!%%F\n"
    )
)

if "%foundMultiple%"=="true" (
    echo Multiple AHK files found. Please specify one manually:
    echo.
    echo Found files:
    echo -------------------------------------
    echo %fileList%
    echo -------------------------------------
    pause
    exit /b
)

:: Generate ICO file name from AHK file name
set "ico=%ahk:.ahk=.ico%"

:: Check if the ICO file exists
if exist "%ico%" (
    "%ahk2exe%" /in "%ahk%" /base "%Compiler%" /icon "%ico%"
) else (
    echo Icon file not found, compiling without icon...
    "%ahk2exe%" /in "%ahk%" /base "%Compiler%"
)

echo.
pause
