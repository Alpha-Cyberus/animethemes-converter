@ECHO off
SETLOCAL EnableDelayedExpansion

GOTO :Main
GOTO :eof

:: Program header and footer, not much else.
:Main
	ECHO [1m---------------------------------------------[0m
	ECHO [35m        Animethemes Video Converter
	ECHO            v1.1.3 by Alpha Cyberus[0m
	ECHO [1m---------------------------------------------[0m
	CALL :Menu
	ECHO Have feedback or ideas for other fun little projects?
	ECHO Contact me at [35mhttps://github.com/Alpha-Cyberus/[0m
	PAUSE
EXIT /B

:: Simple menu responding to specific input (not case sensitive).
:: Ignore any other input request input again.
:Menu
SETLOCAL
	ECHO.
	ECHO [92mS[0m	: Scan files to convert
	ECHO [94mH[0m	: Help
	ECHO [91mE[0m	: Exit program
	ECHO.

	:Menu.Wronginput
	SET /P _input=
	IF /I %_input%==S ENDLOCAL & GOTO :Scanfiles
	IF /I %_input%==H ENDLOCAL & GOTO :Menuhelp
	IF /I %_input%==E EXIT /B
	GOTO :Menu.Wronginput
EXIT /B

:: Same as Readme file, then return to menu.
:Menuhelp
SETLOCAL
	ECHO ---[35m How to use Animethemes Converter [0m---
	ECHO.
	ECHO [94m1[0m. Install FFMPEG (essential plugin for video to mp3 conversion).
	ECHO    Instructions for download and install: https://youtu.be/r1AtmY-RMyQ?t=42.
	ECHO [94m2[0m. Go to https://themes.moe/ or www.reddit.com/r/AnimeThemes/wiki/index#wiki_themes to find and download videos.
	ECHO [94m3[0m. Put them all in one folder or sorted into subfolders.
	ECHO [94m4[0m. Put app files into that folder and run it.
	ECHO [94m5[0m. Scan for videos then convert to mp3s.
	ECHO    Note: The videos will be deleted after conversion.
	ECHO [94m6[0m. Enjoy your music!
	GOTO :Menu
EXIT /B

:: Scan current folder and all subfolders for any .webm (all videos from themes.moe are in this container), print them to screen with path and filename so user can review them.
:: Confirmation prompt with different key from previous to continue with process.
:Scanfiles
	SET /A "_total=0"
	ECHO [92mThe following files have been detected:[0m
	FOR /R %%V IN (".\*.webm") DO (
		ECHO %%~pnV
		SET /A "_total=_total+1"
	)
	ECHO [92mTotal videos: %_total%[0m
	ECHO.
	ECHO [92mC[0m	: Convert to mp3s
	ECHO  	  Note: Files with suffixes will be renamed to be more consistent.
	ECHO  	  The video files will be deleted after conversion. This process cannot be reversed.
	ECHO [91mE[0m	: Exit program
	ECHO.
	:Scan.Wronginput
		SETLOCAL
		SET /P _input=
		IF /I %_input%==C ENDLOCAL & GOTO :Processfiles
		IF /I %_input%==E ENDLOCAL & EXIT /B
	GOTO :Scan.Wronginput
EXIT /B

:: Loop through all videos in dir and subdirectories twice.
:: First loop- rename files then to convert them.
:: Clear up utility files and feedback to user.
:: Uses timer.bat to track and display how long the function takes.
:Processfiles
SETLOCAL
	CALL Timer.cmd start
	ECHO [92mRenaming videos...[0m
	:: Store path, filename, extension for easy use in sub-functions.
	:: Pass filename twice, as variable and function parameter so one can be changed and one can be a reference.
	FOR /R %%V IN (".\*.webm") DO (
		SET "_pth=%%~dpV"
		SET "_xtn=%%~xV"
		SET "_fname=%%~nV"
		CALL :Rename "%%~nV"
	)
	ECHO [92mVideos renamed. Beginning conversion process.[0m
	:: Pass path, filename, extension directly as parameters into function.
	SET /A "_counter=0"
	FOR /R %%V IN (".\*.webm") DO (
		CALL :ConvertClear "%%~dpV" "%%~nV" "%%~xV"
		SET /A "_counter=!_counter!+1"
		ECHO %%~nV Converted. [94mProgress: !_counter! / %_total%[0m
	)
	IF EXIST "converter.txt" (
		DEL "converter.txt"
	)
	ECHO.
	CALL Timer.cmd stop
	ECHO [1m---------------------------------------------
ENDLOCAL
EXIT /B

:: Some themes.moe files have random suffixes (anything after OP/ED[number]), detect these and call functions to remove them.
:: Write filename to .txt for FINDSTR. Update before final loop to reflect changed filenames.
:: Loop 1- Detect - suffix .
:: Loop 2/3- Detect v suffix.
:: Loop 4/5- Detect - between title and OP/ED.
:Rename
	ECHO %~1 > converter.txt
	FOR /F %%I IN ('FINDSTR /R "OP[0-9]*- ED[0-9]*-" converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Newfname- "%~1"
		)
	)
	FOR /F %%I IN ('FINDSTR /R "OP[0-9]*v" converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Newfnamev "%~1" "OP"
		)
	)
	FOR /F %%I IN ('FINDSTR /R "ED[0-9]*v" converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Newfnamev "%~1" "ED"
		)
	)
	ECHO %_fname% > converter.txt
	FOR /F %%I IN ('FINDSTR /R /C:"-OP[0-9]\>" converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :NewfnamespOP
		)
	)
	FOR /F %%I IN ('FINDSTR /R /C:"-ED[0-9]\>" converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :NewfnamespED
		)
	)
EXIT /B

:: Remove "-"+ all trailing characters suffix.
:Newfname-
	SET "_left=%_fname:-=" & set "_right=%"
	SET "_fname=!_fname:%_right%=@@@!"
	SET "_fname=%_fname:-@@@=%"
	REN "%_pth%%~1%_xtn%" "%_fname%%_xtn%"
EXIT /B

:: Remove "v"+ all trailing characters suffix.
:Newfnamev
	SET "_fname=!_fname:%~2=@@@!"
	SET "_left=%_fname:@@@=" & set "_right=%"
	SET "_rleft=%_right:v=" & set "_rright=%"
	SET "_fname=%_left%%~2%_rleft%"
	REN "%_pth%%~1%_xtn%" "%_fname%%_xtn%"
EXIT /B

:: Remove "-" between file and OP/ ED.
:NewfnamespOP
	SET "_fnamesp=%_fname:-OP= OP%"
	IF EXIST "%_pth%%_fnamesp%%_xtn%" (
		DEL "%_pth%%_fname%%_xtn%"
	) ELSE (
		REN "%_pth%%_fname%%_xtn%" "%_fnamesp%%_xtn%"
	)
EXIT /B

:NewfnamespED
	SET "_fnamesp=%_fname:-ED= ED%"
	IF EXIST "%_pth%%_fnamesp%%_xtn%" (
		DEL "%_pth%%_fname%%_xtn%"
	) ELSE (
		REN "%_pth%%_fname%%_xtn%" "%_fnamesp%%_xtn%"
	)
EXIT /B

:: Use FFMPEG for conversion. Parameters passed in when function was called. Delete video when done.
:ConvertClear
	ffmpeg -hide_banner -loglevel error -i "%~1%~2%~3" -codec:a libmp3lame -qscale:a 2 -metadata artist="Various" -metadata album="Anime Themes" -metadata genre="Anime" "%~1%~2.mp3"
	DEL "%~1%~2%~3"
REM FFMPEG used to encode MP3s. Instructions: https://trac.ffmpeg.org/wiki/Encode/MP3
REM MP3 output set to VBR ~190kbs as per recommended settings: https://wiki.hydrogenaud.io/index.php?title=LAME#Recommended_encoder_settings
EXIT /B
