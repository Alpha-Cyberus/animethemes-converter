@ECHO off
SETLOCAL EnableDelayedExpansion
GOTO :Main
GOTO :eof

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

:Menu
SETLOCAL
	ECHO.
	ECHO [92mS[0m	: Scan files to convert
	ECHO [94mH[0m	: Help
	ECHO [91mE[0m	: Exit program
	ECHO.
	SET /P M=
	IF /I %M%==S ENDLOCAL & GOTO :Scanfiles
	IF /I %M%==H ENDLOCAL & GOTO :Menuhelp
	IF /I %M%==E EXIT /B
EXIT /B

:Menuhelp
SETLOCAL
	ECHO ---[35m How to use Animethemes Converter [0m---
	ECHO.
	ECHO [94m1[0m. Go to https://themes.moe/ and download videos.
	ECHO [94m2[0m. Put them all in one folder or sorted into subfolders.
	ECHO [94m3[0m. Put converter.bat into that folder and run it.
	ECHO [94m4[0m. Scan for video files then convert to mp3s. Note: The videos will be deleted after conversion.
	ECHO [94m5[0m. Enjoy your music!
	ECHO.
	ECHO [92mS[0m	: Scan files to convert
	ECHO [91mE[0m	: Exit program
	SET /P M=
	IF /I %M%==S ENDLOCAL & GOTO :Scanfiles
	IF /I %M%==E EXIT /B
EXIT /B

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

:Processfiles
SETLOCAL
	FOR /R %%V IN (".\*.webm") DO (
		SET "_pth=%%~dpV"
		SET "_xtn=%%~xV"
		SET "_fname=%%~nV"
		SET /A _endloop=0
		CALL :Rename "%%~nV"
	)
	FOR /R %%V IN (".\*.webm") DO (
		SET "_pth=%%~dpV"
		SET "_xtn=%%~xV"
		SET "_fname=%%~nV"
		CALL :ConvertClear "%%~nV"
	)
	ECHO.
	ECHO [1m---------------------------------------------
	ECHO [92mConversion complete[0m
	IF EXIST "converter.txt" (
		DEL "converter.txt"
	)
ENDLOCAL
EXIT /B

:Rename
	ECHO %_fname% > converter.txt
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

:Newfname-
	SET "_left=%_fname:-=" & set "_right=%"
	SET "_fname=!_fname:%_right%=@@@!"
	SET "_fname=%_fname:-@@@=%"
	REN "%_pth%%~1%_xtn%" "%_fname%%_xtn%"
EXIT /B

:Newfnamev
	SET "_fname=!_fname:%~2=@@@!"
	SET "_left=%_fname:@@@=" & set "_right=%"
	SET "_rleft=%_right:v=" & set "_rright=%"
	SET "_fname=%_left%%~2%_rleft%"
	REN "%_pth%%~1%_xtn%" "%_fname%%_xtn%"
EXIT /B

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

:ConvertClear
	ffmpeg -i "%_pth%%_fname%%_xtn%" "%_pth%%_fname%.mp3"
	DEL "%_pth%%_fname%%_xtn%"
EXIT /B
