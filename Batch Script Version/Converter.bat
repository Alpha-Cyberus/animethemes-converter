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
SETLOCAL

ENDLOCAL
EXIT /B

:Convert
SETLOCAL

ENDLOCAL
EXIT /B
