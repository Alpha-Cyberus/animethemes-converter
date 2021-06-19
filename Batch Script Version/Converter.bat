@ECHO off
SETLOCAL EnableDelayedExpansion
cd C:\Users\petad\Music\Anime

GOTO :Main
PAUSE
GOTO :eof

:Main
SETLOCAL
	FOR /R %%v IN (".\*.webm") DO (
		SET "_pth=%%~dpv"
		SET "_xtn=%%~xv"

		CALL :TidyUp "%%~nv"
		CALL :Convert "%%~nv"
	)
ENDLOCAL
EXIT /B

:TidyUp
SETLOCAL
	echo "%~1"
	ECHO %~1 > converter.txt

	SET "_findme=-OP.*-"
	FOR /F %%i IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Rename "%%i"
			EXIT /B
		)
	)

	SET "_findme=-ED.*-"
	FOR /F %%i IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Rename "%%i"
			EXIT /B
		)
	)

	SET "_findme=-OP.*v"
	FOR /F %%i IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			EXIT /B
		)
	)

	SET "_findme=-ED.*v"
	FOR /F %%i IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			EXIT /B
		)
	)
ENDLOCAL
EXIT /B

:Rename
SETLOCAL
	set "_base=%~1"
	set "_left=%_base:-=" & set "_right=%"
	set "_base=!_base:%_right%=@@@!"
	set "_base=%_base:-@@@=%"
	echo %_base%

	:: ren "%_pth%%~1%_xtn%" "%_base%%_xtn%"
ENDLOCAL
EXIT /B

:Remove
SETLOCAL

ENDLOCAL
EXIT /B

:Convert
SETLOCAL

ENDLOCAL
EXIT /B
