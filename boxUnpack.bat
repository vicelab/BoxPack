@echo off
SetLocal ENABLEDELAYEDEXPANSION 

rem The following is the location of 7zip on your system. Change, if you have it installed in a custom location...
set loc7zip="c:\Program Files\7-Zip\7z.exe"
rem --------------------------------------------------------------------------------------------------------

set rootDir="%CD%"
set homeDir="%CD%"
rem  echo.
rem echo call: %0 %1 %2 %3

if "%~1"=="-recursion-" (
    goto recursive 
) else (
    goto first
)

:first
    if not "%~1"=="" (
        if exist "%~dpnx1" (
            set rootDir="%~dpnx1"
            cd "%~dpnx1"
        )
    )
    echo                                                                                                by: Andreas Anderson
    echo               ---====++++ VICE Lab box Unpacker 1.3 ++++====----                                          9/03/2019
    echo.
    echo.
    echo This program is the companion program to box Packer: 
    echo   - It restores a tree containing box packer archives (*.boxPack.zip.*) back to its original state.
    echo   - Once an archive has been succefully extracted, it gets deleted to avoid the clutter of redundant data.
    echo                 (No deletion occurs if errors appear during extraction - user gets a notification and a log.)
    echo   - Unpacking a subtree of a packed tree will not cause problems.
	echo   - If a tree contains nested archives (highly unlikely), running boxUnpack repeatedly will fully extract them.  
    echo.                    ------------------------------------
    echo.
    echo There are two ways of running boxUnpack:
    echo  1) Place boxUnpack.bat at the root of any tree you want processed, and double-click.
    echo  2) Call boxUnpack from the command line with the tree root as the first parameter, e.g: 
    echo                 boxUnpack C:\mydata   (using no parameter defaults to the current directory)
    echo.
    echo.                    ====================================
    echo.
    echo *****  Ready to unpack folders branching from:
    echo          !cd!
    echo.
    CHOICE /C GC /M "Press G to go ahead, C to cancel."
    IF %ERRORLEVEL% equ 2 goto end    
    echo.
    echo Scanning for boxPack archives, and extracting...
    REM go through all subfolders
    for /d %%D in ("%cd%") do (
        call "%~dpnx0" -recursion- "%%~dpnxD" 
        cd %rootDir% 
    )
    echo !time!: done unpacking^^!
    for %%D in (%homeDir%) do %%~dD
    cd %homeDir%
    pause
goto end



:recursive
    REM go to the correct path 
    %~d2
    cd "%~dpnx2"
    rem echo i arrived in: !cd!
    rem echo I want to be in "%~dpnx2"
    rem cd
    Rem unpack all boxPack.zip files
    for %%F in (*.boxPack.zip.001) do (
        rem echo %%F
        for %%G in ("%%~nF") do (
            rem echo %%G
            for %%H in ("%%~nG") do (
                rem echo %%H
                echo !time!: %%~dpnH
                if exist "%%~dpnH" ( 
                    echo ...This folder is in CONFLICT with boxPack archive  ======= ^^!^^! Please resolve manually ^^!^^! ======= 
                    echo.
                ) else (
                    rem Extract Folders
                    %loc7zip% x "%%~F" > "%%~G.log"
                    findstr /c:"Everything is Ok" "%%~G.log" > NUL
                    if !errorlevel!==0 (
                        rem echo Extraction successful!
                        rem delete unpacked zip files if extraction was successful
                        del "%%~dpnxH.*"
                    ) else (
                        echo ======= ^^!^^! check %cd%.boxPack.log ^^!^^! =======
                    )
                )
            )
        )
    )
    REM go through all subfolders
    for /d %%D in (*.*) do (
        call "%~dpnx0" -recursion- "%%~dpnxD" 
        rem cd "%~dpnx2"
    )
goto end

:end
