@echo off
SetLocal ENABLEDELAYEDEXPANSION 

rem   ********************** Random Tip: A good way to copy folder trees for archiving is:
rem                                   ROBOCOPY /s /xo /fft /z SOURCE_FOLDER DEST_FOLDER
rem                         Benefits: It does not overwrite newer files, and it is resumable when interrupted!

rem ----- SETTINGS ------------------------------------------------------------------------------------------------
rem The following are the basic parameters this program uses. Change to your desired values...
rem !!!!!!!!!! Careful with fSizeMax & fSizeMaxMB !!!!!!!!:
rem fSizeMax & fSizeMaxMB must be integers (no commas,decimal points, spaces, or funny business!). 
rem Since Batch is limited to 12-bit integers, file sizes over ~2GB cannot be compared numerically, but must be compared as padded strings. 

rem fSizeMax MUST BE EXACTLY fSizeMaxMB x 1048576!

set fSizeMaxMB=14305
set fSizeMax=14999879680
set /a fLimit=75
set loc7zip="c:\Program Files\7-Zip\7z.exe"
rem --------------------------------------------------------------------------------------------------------

set rootDir=%CD%
set homeDir=%CD%
rem echo.
rem echo call: %0 %1 %2 %3

if "%~1" == "-recursion-" (
    goto recursive 
) else (
    goto first
)

:first
    if not "%~1"=="" (
        if exist "%~dpnx1" (
            set rootDir=%~dpnx1
            cd "%~dpnx1"
        )
    )
    echo                                                                                                by: Andreas Anderson
    echo               ---====++++ VICE Lab box Packer 1.3 ++++====----                                            9/03/2019
    echo.
    echo.
    echo This program will scan a tree and convert all folders containing over %fLimit% items and files over %fSizeMaxMB% MB 
    echo     into ZIP archives (*.boxPack.zip.*). The parameters can be changed in the SETTINGS section of the source code.
    echo.
    echo This is useful if you want to archive your data to the cloud: 
    echo   - It avoids synchronization problems due to files above the cloud size limit.
    echo   - Having less files makes up/downloading significantly faster.
    echo   - Archiving only folders with many files means most of the tree remains browsable/accessible in a web interface.
    echo   - Once a folder has been succefully compressed, it gets deleted to avoid the clutter of redundant data.
    echo         (No deletion occurs if errors appear during archiving - user gets a notification and a log.)
    echo   - The folders can be restored by using the companion program, box Unpacker (recursive), or 7-Zip (manual).
    echo   - Re-packing an already (possibly partially) packed tree is OK. It may result in nested archives, but only if 
    echo         internal parameters were changed. In that case, running boxUnpack several times will resolve the issue.
    echo.                    ------------------------------------
    echo.
    echo There are two ways of running boxPack:
    echo  1) Place boxPack.bat at the root of any tree you want processed, and double-click.
    echo  2) Call boxPack from the command line with the tree root as the first parameter, e.g: 
    echo                       boxPack C:\mydata      (using no parameter defaults to the current directory)
    echo.
    echo.                    ====================================
    echo.
    echo *****  Ready to pack folders branching from:
    echo          !cd!
    echo.
    CHOICE /C GC /M "Press G to go ahead, C to cancel."
    IF %ERRORLEVEL% equ 2 goto end    
    echo.
    echo Scanning for folders with over %fLimit% items, files over %fSizeMaxMB% MB, and packing...
    echo.
    rem go through all subfolders
	call "%~dpnx0" -recursion- "%rootDir%"
    echo !time!: done packing^^!
    for %%D in (%homeDir%) do %%~dD
    cd %homeDir%
    pause
goto end



:recursive
    rem go to the correct path 
    rem echo %~dpnx2
    %~d2
    rem echo cd "%~dpnx2"
    cd "%~dpnx2"
    rem echo i arrived in: !cd!
    rem count all files that aren't boxPacks
    set /a nfil=0
    for  %%F in (*.*) do set /a nfil+=1
    for /d %%F in (*.*) do set /a nfil+=1
    for  %%F in (*.boxPack.zip.*) do set /a nfil-=1
    rem If there are too many files, zip the folder
    if %nfil% gtr %fLimit% (
        rem Pack dir
        echo !time!: %cd%
        if exist "%cd%.boxPack.zip.*" (
            echo ...This folder is in CONFLICT with boxPack archive  ======= ^^!^^! Please resolve manually ^^!^^! ======= 
            echo.
        ) else (
            rem echo %loc7zip% a -mm=Deflate64 -mx=1 -v%fSizeMaxMB%m -bsp1 "%%~dpnxA.boxPack.zip" "%cd%\"
            %loc7zip% a -mm=Deflate64 -mx=1 -v%fSizeMaxMB%m -bsp1 "%cd%.boxPack.zip" "%cd%\" >"%cd%.boxPack.log"
            findstr /c:"Everything is Ok" "%cd%.boxPack.log">nul
            if !errorlevel!==0 (
                rem echo Compression successful!
                cd.. & rd "%cd%" /s /q
            ) else (
                echo ======= ^^!^^! check %cd%.boxPack.log ^^!^^! =======
            )
        )
    ) else (
        rem go through all subfolders
        for /d %%D in (*.*) do (
            call "%~dpnx0" -recursion- "%%~dpnxD"
            cd "%~dpnx2"
        )
        rem Check if any files in current folder are too big
        for %%F in (*.*) do (
            set fSize=%%~zF
            set maxSize=%fSizeMax%
            rem pad the file sizes with zeros to do alphabetical comparison
            call :pad_to_match fSize maxSize
            rem echo %%~zF %%F 
            rem echo !fSize! file
            rem echo !maxSize! max
            rem echo %fSizeMax%
            if "!fSize!" gtr "!maxSize!" (
                echo !time!: %%~dpnxF
                %loc7zip% a -mm=Deflate64 -mx=1 -v%fSizeMaxMB%m -bsp1 "%%~dpnxF.boxPack.zip" "%%~dpnxF" >"%%~dpnxF.boxPack.log"
                findstr /c:"Everything is Ok" "%%~dpnxF.boxPack.log">nul
                if !errorlevel!==0 (
                    rem echo Compression successful!
                    del "%%~dpnxF"
                ) else (
                    echo ======= ^^!^^! check %%~dpnxF.boxPack.log ^^!^^! =======
                )
            )
        )
    )
goto end


:pad_to_match
rem pad_to_match strvar1 strvar2
Set "s1=#!%~1!"
Set "dig1=0"
For %%N in (16 8 4 2 1) do (
  if "!s1:~%%N,1!" neq "" (
    set /a "dig1+=%%N"
    set "s1=!s1:~%%N!"
  )
)

Set "s2=#!%~2!"
Set "dig2=0"
For %%N in (16 8 4 2 1) do (
  if "!s2:~%%N,1!" neq "" (
    set /a "dig2+=%%N"
    set "s2=!s2:~%%N!"
  )
)

if !dig1! gtr !dig2! (
    set /a dig=!dig1!
) else (
    set /a dig=!dig2!
)

set /a zeros2add=dig
set /a zeros2add+=-!dig1!
for /L %%N in (1,1,!zeros2add!) do (
    set %1=0!%~1!
)
set /a zeros2add=dig
set /a zeros2add+=-!dig2!
for /L %%N in (1,1,!zeros2add!) do (
    set %2=0!%~2!
)
Exit /b


:end
