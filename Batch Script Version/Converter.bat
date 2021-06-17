@ECHO off
SETLOCAL EnableDelayedExpansion
cd C:\Users\petad\Music\Anime

GOTO :Main
PAUSE
GOTO :eof

:Main
REM loop all .webm vids in folder + subfolders
REM For each, call :Rename to neaten filenames and remove duplicate versions. First for the OPs then for the EDs
REM For each, call :Convert to convert to MP3
SETLOCAL
	FOR /R %%v IN (".\*.webm") DO (
		SET "_pth=%%~dpv"
		SET "_xtn=%%~xv"
		CALL :Rename "%%~nv" OP
		CALL :Convert %%~nv
	)
ENDLOCAL
EXIT /B

:Rename
REM write filename to converter.txt
REM check if -OP*- exists, if yes then remove the end, rename videofile
REM check if -OP*v exists, if yes then delete the videofile
SETLOCAL
	ECHO %~1 > converter.txt
	SET "_findme=-%~2.*-"

	FOR /F %%i IN ('FINDSTR /R /C:!_findme! converter.txt') DO (
		IF !ERRORLEVEL! EQU 0 (
			:: Match
			CALL :RenameShorten "%%i"
		) ELSE (
			:: No match
			ECHO "no match"
		)
	)
ENDLOCAL
EXIT /B

:RenameShorten
SETLOCAL
	REM match found
	echo "doesthiswork !_pth! !_xtn!"
	ECHO "FOUNDME=%~1"
	ECHO "mypath=%~2"
	ECHO "extension=%~3"

	set "_base=%~1"
	set "_left=%_base:-=" & set "_right=%"
	ECHO base=!_base!
	ECHO left=!_left!
	ECHO right=!_right!
	set "_base=!_base:%_right%=@@@!"
	ECHO !_base!
	ECHO base=!_base!
	set "_base=!_base:-@@@=!"
	ECHO BASE=!_base!

	::REN  %~1.%~2 !_base!.%~2

ENDLOCAL
EXIT /B

:Convert
SETLOCAL

ENDLOCAL
EXIT /B
