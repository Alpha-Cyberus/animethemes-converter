@ECHO on
SETLOCAL EnableDelayedExpansion
CD C:\Users\petad\Music\Anime
GOTO :Main
GOTO :eof

:Main
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
		DEL "converter.txt"
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
	rem old search string "-[a-Z][a-Z][0-9]\>"
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
