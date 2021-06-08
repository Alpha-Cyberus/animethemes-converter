@ECHO off
SETLOCAL EnableDelayedExpansion
cd C:\Users\petad\Music\Anime
GOTO :Main
PAUSE
GOTO :eof

:Main
REM loop all .webm vids in folder + subfolders
REM For each, call :Rename to neaten filenames and remove duplicate versions
REM For each, call :Convert to convert to MP3

FOR /R %%v IN (".\*.webm") DO (
	CALL :Rename %%~nv
	CALL :Convert %%~nv
	)
EXIT /B

:Rename
REM find all -OP*-, remove the end, remove trailing char, replace - with space
REM find all -OP*v, delete file
REM repeat with EP
SETLOCAL

REM does the filename contain OP and then a -?
SET "_filename=%~1"
SET _opep=-OP?v
SET _test=%_filename:-OP?v=%
SET _
ECHO .

REM IF NOT !_test!==!_filename! (
REM 		ECHO "---Different"
REM 		) ELSE (
REM 		ECHO "---Is the same"
REM 		)

rem SET "_cities=Aberdeen, London, Edinburgh" && ECHO !_cities!
rem SET _dummy=!_cities:London=! && ECHO !_dummy!

rem IF NOT !_dummy! == !_cities! (ECHO "NOT") ELSE (ECHO "IS")


ENDLOCAL
EXIT /B

:Convert
SETLOCAL

ENDLOCAL
EXIT /B
