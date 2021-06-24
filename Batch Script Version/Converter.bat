@ECHO on
SETLOCAL EnableDelayedExpansion
cd C:\Users\petad\Music\Anime
GOTO :Main
GOTO :eof

:Main
SETLOCAL
	FOR /R %%V IN (".\*.webm") DO (
		SET "_pth=%%~dpV"
		SET "_xtn=%%~xV"
		SET "_fname=%%~nV"
		CALL :Rename
		CALL :ConvertClear "%%~nV"
	)
ENDLOCAL
PAUSE
EXIT /B

:Rename
	ECHO %_fname% > converter.txt

	SET "_findme=-.*-"
	FOR /F %%I IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Newfname- %_fname%
			EXIT /B
		)
	)

	SET "_findme=-.*v"
	FOR /F %%I IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			CALL :Newfnamev %_fname%
			EXIT /B
		)
	)
EXIT /B

:Newfname-
	set "_left=%_fname:-=" & set "_right=%"
	set "_fname=!_fname:%_right%=@@@!"
	set "_fname=%_fname:-@@@=%"
EXIT /B

:Newfnamev
	set "_left=%_fname:-=" & set "_right=%"
	set "_rleft=%_right:v=" & set "_rright=%"
	set "_fname=!_left! !_rleft!"
	echo !_fname!
EXIT /B

:ConvertClear
	ffmpeg -n -i "%_pth%%~1%_xtn%" "%_pth%%_fname%.mp3"
	DEL "%_pth%%~1%_xtn%"
EXIT /B
