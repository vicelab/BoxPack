@echo off
SetLocal ENABLEDELAYEDEXPANSION 
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
    echo               ---====++++ VICE Lab box Packer Conflict Finder 1.3 ++++====----                            9/03/2019
    echo.
    echo.
    echo This program will scan a tree for possible conflicts when running box (un)Packer:
    echo.
    echo   - Running the program lists all the folders that have eponymous boxPack archives (*.boxPack.zip.*) next to them.
    echo   - Such occurrences are usually a sign of incomplete archival/extraction of that folder.
    echo   - The log found in the same folder as the archive may hold a clue to the nature of the problem.
    echo       Logs of successful archivals/extractions contain the phrase "Everything is Ok". 
    echo   - Conflict resolution is usually as simple as finding if the folder or the archive containing incomplete data,
    echo                  deleting the incomplete item, and re-running the interrupted (un)packing process.
    echo.                    ------------------------------------
    echo.
    echo There are two ways of running boxPack-Conflict_finder:
    echo  1) Place boxPack-Conflict_finder.bat at the root of any tree you want processed, and double-click.
    echo  2) Call boxPack-Conflict_finder from the command line with the tree root as the first parameter, e.g: 
    echo                  boxPack-Conflict_finder C:\mydata      (using no parameter defaults to the current directory)
    echo.
    echo.                    ====================================
    echo.
    echo *****  Ready to unpack folders branching from:
    echo          !cd!
    echo.
    CHOICE /C GC /M "Press G to go ahead, C to cancel."
    IF %ERRORLEVEL% equ 2 goto end    
    echo.
    echo Scanning for conflicting items...
    REM go through all subfolders
    for /d %%D in (*.*) do (
        call "%~dpnx0" -recursion- "%%~dpnxD" 
        cd %rootDir% 
    )
    echo done scanning^^!
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
                if exist "%%~dpnH" ( 
                    echo %%~dpnH
                    echo ...This folder is in CONFLICT with boxPack archive  ======= ^^!^^! Please resolve manually ^^!^^! ======= 
                    echo.
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
