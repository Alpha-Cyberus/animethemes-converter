@ECHO off
SETLOCAL EnableDelayedExpansion
GOTO :Main
GOTO :eof

:: Program header and footer, not much else.
:Main
	ECHO [1m---------------------------------------------[0m
	ECHO [35m        Animethemes Video Converter
	ECHO            v1.0 by Alpha Cyberus[0m
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
	:Wronginput
	SET /P M=
	IF /I %M%==S ENDLOCAL & GOTO :Scanfiles
	IF /I %M%==H ENDLOCAL & GOTO :Menuhelp
	IF /I %M%==E EXIT /B
	GOTO :Wronginput
EXIT /B

:: Same as Readme file, then return to menu.
:Menuhelp
SETLOCAL
	ECHO ---[35m How to use Animethemes Converter [0m---
	ECHO.
	ECHO [94m1[0m. Install FFMPEG (essential plugin for video to mp3 conversion).
	ECHO    Recommended version for Windows: ffmpeg-release-essentials.7z https://www.gyan.dev/ffmpeg/builds/
	ECHO [94m2[0m. Go to https://themes.moe/ and download videos.
	ECHO [94m3[0m. Put them all in one folder or sorted into subfolders.
	ECHO [94m4[0m. Put converter.bat into that folder and run it.
	ECHO [94m5[0m. Scan for videos then convert to mp3s.
	ECHO    Note: The videos will be deleted after conversion.
	ECHO [94m6[0m. Enjoy your music!
	GOTO :Menu
EXIT /B

:: Scan current folder and all subfolders for any .webm (all videos from themes.moe are in this container), print them to screen with path and filename so user can review them.
:: Confirmation prompt with different key from previous to continue with process.
:Scanfiles
SETLOCAL
	ECHO --- [35mThe following files have been detected:[0m ---
	FOR /R %%V IN (".\*.webm") DO (
		ECHO %%~pnV
	)
	ECHO.
	ECHO [92mC[0m	: Convert to mp3s
	ECHO Note: The videos will be deleted after conversion. [4mThis process cannot be reversed.[0m
	ECHO [91mE[0m	: Exit program
	ECHO.
	SET /P M=
	IF /I %M%==C ENDLOCAL & GOTO :Processfiles
	IF /I %M%==E EXIT /B
EXIT /B

:: Loop through all videos in dir and subdirectories twice.
:: First loop- rename files then to convert them.
:: Clear up utility files and feedback to user.
:Processfiles
SETLOCAL
	:: Store path, filename, extension for easy use in sub-functions.
	:: Pass filename twice, as variable and function parameter so one can be changed and one can be a reference.
	FOR /R %%V IN (".\*.webm") DO (
		SET "_pth=%%~dpV"
		SET "_xtn=%%~xV"
		SET "_fname=%%~nV"
		CALL :Rename "%%~nV"
	)
	:: Pass path, filename, extension directly as parameters into function.
	FOR /R %%V IN (".\*.webm") DO (
		CALL :ConvertClear "%%~dpV" "%%~nV" "%%~xV"
	)
	IF EXIST "converter.txt" (
		DEL "converter.txt"
	)
	ECHO.
	ECHO [1m---------------------------------------------
	ECHO [92mConversion complete[0m
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
	ffmpeg -i "%~1%~2%~3" -codec:a libmp3lame -qscale:a 2 "%~1%~2.mp3"
	DEL "%~1%~2%~3"
REM FFMPEG used to encode MP3s. Instructions: https://trac.ffmpeg.org/wiki/Encode/MP3
REM MP3 output set to VBR ~190kbs as per recommended settings: https://wiki.hydrogenaud.io/index.php?title=LAME#Recommended_encoder_settings
EXIT /B
