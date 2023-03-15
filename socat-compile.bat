@ECHO OFF
REM -- Automates cygwin installation and cygwin 1.7.4.4 compilation
REM -- Sources: 
REM --- https://github.com/rtwolf/cygwin-auto-install
REM --- https://gist.github.com/wjrogers/1016065
REM --- https://github.com/valorisa/socat-1.7.4.4_for_Windows
 
SETLOCAL

SET SCRIPTDIR=%CD%
SET TEMPDIR=I:\Tmp

REM -- change to C:\Temp 
if NOT EXIST %TEMPDIR% (
	mkdir %TEMPDIR%
)
cd /d %TEMPDIR%

REM -- Download the Cygwin installer
IF NOT EXIST cygwin-setup64.exe (
	ECHO cygwin-setup64.exe NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority normal https://cygwin.com/setup-x86_64.exe %CD%\\cygwin-setup64.exe
) ELSE (
	ECHO cygwin-setup64.exe found! Skipping installer download...
)
 
REM -- Configure our paths
SET SITE=http://ucmirror.canterbury.ac.nz/cygwin
SET LOCALDIR=%CD%
SET ROOTDIR=I:\Cygwin\cygwin64
SET CYGWINROOTDIR=\
SET SOCAT=socat-1.7.4.4
SET SOCAT_REQUIRED_CYGWIN_RUNTIME_LIBS=crypto-1.1 ncursesw-10 readline7 ssl-1.1 win1 wrap-0 z

 
REM -- These are the packages we will install to compile socat (in addition to the default packages)
SET PACKAGES=wget,gcc-g++,gcc-core,make,gcc-fortran,gcc-objc,gcc-objc++,libkrb5-devel,libkrb5_3,libreadline-devel,libssl-devel,libwrap-devel,tcp_wrappers
 

IF NOT EXIST "%ROOTDIR%\bin\bash.exe" (
	REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
	REM -- Do it!
	ECHO *** INSTALLING DEFAULT PACKAGES
	call cygwin-setup64 --quiet-mode --no-desktop --download --local-install --no-verify -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%"
	ECHO.
	ECHO Please wait with continuation until cygwin setup completes.
	pause
) ELSE (
	ECHO Cygwin default packages already installed.
)

REM %ROOTDIR%\bin\cygcheck.exe -c can be used to compare our package
REM list with the installed list. We just check for one file to keep it simple...
IF NOT EXIST "%ROOTDIR%\lib\libwrap.dll.a" (

	ECHO.
	ECHO *** INSTALLING CUSTOM PACKAGES
	call cygwin-setup64 -q -d -D -L -X -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %PACKAGES%

	REM -- Show what we did
	ECHO.
	ECHO.
	ECHO cygwin installation updated
	ECHO  - %PACKAGES%
	ECHO.
	ECHO.
	ECHO Please wait with continuation until cygwin setup completes.
	pause
) ELSE (
	ECHO Cygwin custom packages already installed.
	ECHO Skipping cygwin-setup64 call.
)
 


REM -- Change to Cygwin Root folder
CD %ROOTDIR%

REM -- Download socat
IF NOT EXIST %SOCAT:~0%.tar.gz (
	ECHO %SOCAT:~0%.tar.gz NOT found! Downloading Socat...
	bitsadmin /transfer socatDownloadJob /download /priority normal "http://www.dest-unreach.org/socat/download/%SOCAT:~0%.tar.gz" "%CD%\%SOCAT:~0%.tar.gz"
) ELSE (
	ECHO %SOCAT:~0%.tar.gz found! Skipping socat download...
)

REM Proceed in bash script
cd %SCRIPTDIR%
copy "%SCRIPTDIR%\socat-compile.sh" "%ROOTDIR%\."
%ROOTDIR%\bin\bash.exe --login -c "cd / && ls && ./socat-compile.sh"


ECHO.
ECHO Socat is compiled and installed! You should see an error that socat expected two inputs but none were given, below.
ECHO.
ECHO.

REM -- test Socat
%ROOTDIR%\%SOCAT%\release\socat.exe

PAUSE
EXIT /B 0
