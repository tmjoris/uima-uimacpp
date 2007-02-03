@ECHO OFF
SETLOCAL

REM check args
if "%~1" == "" (
	echo ERROR: SDK target directory not specified
	echo ------
	echo   Usage: buildsdk targetDirectory [clean]
	echo     Builds SDK for distribution.
	echo     The uimacpp solution must be built and installed by running
	echo       winmake in the src directory of the uimacpp extract. 
	echo     The doxygen documentation must be built by running the buildocs.cmd
	echo       in the docs directory of the uimacpp extract.
	echo     Requires the following environment variables:
	echo       UIMA_INSTALLDIR - "install" location of uimacpp build.
	echo                      Defaults to the currentdirectory\install
	echo       UIMA_DOCDIR - location of uimacpp docs.
	echo                         Defaults to UIMA_INSTALLDIR\..\docs
	echo       UIMA_EXAMPLESDIR - location of examples.
	echo                         Defaults to UIMA_INSTALLDIR\..\examples
	echo       UIMA_SCRIPTATORSDIR - location of perl/python/tcl scriptators.
	echo                         Defaults to UIMA_INSTALLDIR\..\scriptators
	echo       UIMA_LICENSEDIR - location of licenses.
	echo                         Defaults to UIMA_INSTALLDIR\..\license
	echo       APR_HOME - root of the APR install. Required.
	echo       ICU_HOME - root of the ICU install. Required.
	echo       XERCES_HOME - root of the XERCES install. Required.
    echo       MSVCRT_HOME - directory with required msvc*.dll files
	goto error
)

set TARGET_DIR=%~1%

if not exist %TARGET_DIR% mkdir %TARGET_DIR%
if not exist %TARGET_DIR% (
	echo ERROR: Could not create %TARGET_DIR%
	goto error
)
set UIMA_DIR=%TARGET_DIR%\uimacpp


if "%APR_HOME%" == "" goto Missing
if "%ICU_HOME%" == "" goto Missing
if "%XERCES_HOME%" == "" goto Missing


echo.
echo SDK directory tree will be built in %UIMA_DIR%
echo.
REM set default values if not set
ECHO check environment values and set default values
if "%UIMA_INSTALLDIR%"=="" set UIMA_INSTALLDIR=%CD%\install
if "%UIMA_DOCDIR%" == "" set UIMA_DOCDIR=%UIMA_INSTALLDIR%\..\docs
if "%UIMA_EXAMPLESDIR%" == "" set UIMA_EXAMPLESDIR=%UIMA_INSTALLDIR%\..\examples
if "%UIMA_SCRIPTATORSDIR%" == "" set UIMA_SCRIPTATORSDIR=%UIMA_INSTALLDIR%\..\scriptators
if "%UIMA_LICENSEDIR%" == "" set UIMA_LICENSEDIR=%UIMA_INSTALLDIR%\..\licenses
if "%UIMA_TESTSRCDIR%" == "" set UIMA_TESTSRCDIR=%UIMA_INSTALLDIR%\..\src\test\src

REM if not exist "%UIMA_INSTALLDIR%"\bin\runAECpp.exe goto uimaInstallPathInvalid
if not exist "%UIMA_INSTALLDIR%"\include\uima\api.hpp (
	echo ERROR: UIMA_INSTALLDIR "%UIMA_INSTALLDIR%" is invalid.
	echo Build and install UIMA C++ first. 
	echo 	devenv src\uimacpp.sln
	goto error
)

if not exist "%UIMA_DOCDIR%"\html\index.html (
	echo ERROR: UIMACPP doxygen docs not found in %UIMA_DOCDIR%
	echo run the builddocs script in the %UIMA_DOCDIR% directory. 
	goto error
)

if not exist "%APR_HOME%"\include (
	echo ERROR: APR_HOME "%APR_HOME%" is invalid.
	goto error
)

if not exist "%ICU_HOME%"\include (
	echo ERROR: ICU_HOME "%ICU_HOME%" is invalid.
	goto error
)

if not exist "%XERCES_HOME%"\include (
	echo ERROR: XERCES_HOME "%XERCES_HOME%" is invalid.
	goto error
)

if not "%MSVCRT_HOME%" == "" goto msvcrt_set
        set MSVCRT_HOME=C:\Program Files\Microsoft Visual Studio .NET 2003\SDK\v1.1\bin
        echo MSVCRT_HOME undefined: trying: "%MSVCRT_HOME%"

:msvcrt_set
if exist "%MSVCRT_HOME%" goto msvcrt_exists
        echo ERROR: MSVCRT_HOME "%MSVCRT_HOME%" is invalid.
        goto error
:msvcrt_exists

if not exist "%UIMA_SCRIPTATORSDIR%"\uima.i (
	echo ERROR: UIMA_SCRIPTATORSDIR "%UIMA_SCRIPTATORSDIR%" is invalid.
	goto error
)

if "%2" == "clean" (
  echo removing %UIMA_DIR%
  rmdir %UIMA_DIR% /s /q
)

if exist %UIMA_DIR% (
	echo ERROR: directory %UIMA_DIR% already exists. Please use "clean" option
	goto error
)

REM Create the top-level directories
mkdir %UIMA_DIR%
mkdir %UIMA_DIR%\bin
mkdir %UIMA_DIR%\lib
mkdir %UIMA_DIR%\data
mkdir %UIMA_DIR%\docs
mkdir %UIMA_DIR%\include
mkdir %UIMA_DIR%\examples
mkdir %UIMA_DIR%\scriptators
mkdir %UIMA_DIR%\licenses

echo.
echo copying from %UIMA_INSTALLDIR%...
xcopy /Q /Y %UIMA_INSTALLDIR%\bin\uima.dll %UIMA_DIR%\bin
xcopy /Q /Y %UIMA_INSTALLDIR%\bin\uimaD.dll %UIMA_DIR%\bin
xcopy /Q /Y %UIMA_INSTALLDIR%\bin\runAECpp.exe %UIMA_DIR%\bin
xcopy /Q /Y %UIMA_INSTALLDIR%\bin\runAECppD.exe %UIMA_DIR%\bin
xcopy /Q /Y %UIMA_INSTALLDIR%\data\resourceSpecifierSchema.xsd %UIMA_DIR%\data
xcopy /Q /Y %UIMA_INSTALLDIR%\lib\uima.lib %UIMA_DIR%\lib
xcopy /Q /Y %UIMA_INSTALLDIR%\lib\uimaD.lib %UIMA_DIR%\lib
mkdir %UIMA_DIR%\include\uima
xcopy /Q /Y %UIMA_INSTALLDIR%\include\uima\* %UIMA_DIR%\include\uima

echo.
echo copying from %UIMA_DOCDIR%...
xcopy /Q /Y %UIMA_DOCDIR%\QuickStart.html %UIMA_DIR%\docs
xcopy /Q /Y %UIMA_DOCDIR%\uimadoxytags.tag %UIMA_DIR%\docs
mkdir %UIMA_DIR%\docs\html
xcopy /Q /Y %UIMA_DOCDIR%\html\* %UIMA_DIR%\docs\html

echo.
echo copying from %UIMA_EXAMPLESDIR%...
xcopy /Q /Y %UIMA_EXAMPLESDIR%\*.html %UIMA_DIR%\examples
mkdir %UIMA_DIR%\examples\data
xcopy /Q /Y %UIMA_EXAMPLESDIR%\data\* %UIMA_DIR%\examples\data
mkdir %UIMA_DIR%\examples\descriptors
xcopy /Q /Y %UIMA_EXAMPLESDIR%\descriptors\*.xml %UIMA_DIR%\examples\descriptors\*.xml
mkdir %UIMA_DIR%\examples\src
xcopy /Q /Y %UIMA_EXAMPLESDIR%\src\*.cpp %UIMA_DIR%\examples\src
xcopy /Q /Y %UIMA_EXAMPLESDIR%\src\*.vcproj %UIMA_DIR%\examples\src
xcopy /Q /Y %UIMA_EXAMPLESDIR%\src\*.sln %UIMA_DIR%\examples\src
REM copy the following file separately, as it is part of the fvt suite
xcopy /Q /Y %UIMA_TESTSRCDIR%\SofaStreamHandlerFile.cpp %UIMA_DIR%\examples\src
xcopy /Q /Y %UIMA_TESTSRCDIR%\SimpleTextSegmenter.cpp %UIMA_DIR%\examples\src

echo.
echo copying from %APR_HOME%...
mkdir %UIMA_DIR%\include\apr
xcopy /Q /Y %APR_HOME%\include\apr*.h %UIMA_DIR%\include\apr
xcopy /Q /Y %APR_HOME%\Release\libapr*.dll %UIMA_DIR%\bin
xcopy /Q /Y %APR_HOME%\Release\libapr*.lib %UIMA_DIR%\lib

echo.
echo copying from %ICU_HOME%...
mkdir %UIMA_DIR%\include\unicode
xcopy /S /Q /Y %ICU_HOME%\include\unicode %UIMA_DIR%\include\unicode
xcopy /Q /Y %ICU_HOME%\bin\icu*.dll %UIMA_DIR%\bin
xcopy /Q /Y %ICU_HOME%\lib\icu*.lib %UIMA_DIR%\lib

echo.
echo copying from %XERCES_HOME%...
mkdir %UIMA_DIR%\include\xercesc
xcopy /S /Q /Y %XERCES_HOME%\include\xercesc %UIMA_DIR%\include\xercesc
xcopy /Q /Y %XERCES_HOME%\bin\xerces-c*.dll %UIMA_DIR%\bin
xcopy /Q /Y %XERCES_HOME%\lib\xerces-c*.lib %UIMA_DIR%\lib

echo.
echo copying MSVC redistribution libs
xcopy /q /y "%MSVCRT_HOME%"\msvc*.dll %UIMA_DIR%\bin

echo.
echo copying the scriptators...
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\uima.i %UIMA_DIR%\scriptators
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\ThreadAnnotator.h %UIMA_DIR%\scriptators

echo.
echo copying the Perl scriptator...
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\perl\Perl.html %UIMA_DIR%\docs	
mkdir %UIMA_DIR%\scriptators\perl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\perl\*.cpp %UIMA_DIR%\scriptators\perl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\perl\*.pl  %UIMA_DIR%\scriptators\perl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\perl\*.xml %UIMA_DIR%\scriptators\perl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\perl\Makefile %UIMA_DIR%\scriptators\perl

echo.
echo copying Python scriptator...
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\python\Python.html %UIMA_DIR%\docs	
mkdir %UIMA_DIR%\scriptators\python
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\python\*.cpp %UIMA_DIR%\scriptators\python
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\python\*.py  %UIMA_DIR%\scriptators\python
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\python\*.xml %UIMA_DIR%\scriptators\python
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\python\Makefile %UIMA_DIR%\scriptators\python

echo.
echo copying Tcl scriptator...
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\tcl\Tcl.html %UIMA_DIR%\docs	
mkdir %UIMA_DIR%\scriptators\tcl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\tcl\*.cpp %UIMA_DIR%\scriptators\tcl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\tcl\*.tcl %UIMA_DIR%\scriptators\tcl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\tcl\*.xml %UIMA_DIR%\scriptators\tcl
xcopy /Q /Y %UIMA_SCRIPTATORSDIR%\tcl\Makefile %UIMA_DIR%\scriptators\tcl

echo.
echo copying licenses...

REM add copyof  Apache SDK licences here
mkdir %UIMA_DIR%\licenses\apr
xcopy /Q /Y %APR_HOME%\LICENSE* %UIMA_DIR%\licenses\apr
if not exist %UIMA_DIR%\licenses\icu mkdir %UIMA_DIR%\licenses\icu
xcopy /Q /Y %ICU_HOME%\LICENSE* %UIMA_DIR%\licenses\icu
if not exist %UIMA_DIR%\licenses\xerces mkdir %UIMA_DIR%\licenses\xerces
xcopy /Q /Y %XERCES_HOME%\LICENSE* %UIMA_DIR%\licenses\xerces

echo DONE SDK image in %UIMA_DIR%
goto end

:Missing
echo APR_HOME and ICU_HOME and XERCES_HOME must all be specified
echo and must contain the directories produced by their "install" builds
goto end

:error
echo FAILED: UIMA C++ SDK was not built.

:end