#!/bin/bash
#
# Contiuation of socat-compile.bat

SOCAT_TAR="$(find / -maxdepth 1 -type f -name 'socat*.tar.gz' | tail -n 1)"
SOCAT_DIR="${SOCAT_TAR%.tar.gz}"

# If older version installed and tar.gz was deleted use existing variant
OLDER_SOCAT_DIR="$(find / -maxdepth 1 -type d -name 'socat*' | tail -n 1)"
test -z "${SOCAT_DIR}" && SOCAT_DIR="${OLDER_SOCAT_DIR}"

SOCAT_REQUIRED_CYGWIN_RUNTIME_LIBS="crypto-1.1 ncursesw-10 readline7 ssl-1.1 win1 wrap-0 z"

if [ "i686" = "$(uname -m)" ] ; then
	# Add extra dependeny for 32 bit version
	SOCAT_REQUIRED_CYGWIN_RUNTIME_LIBS="$SOCAT_REQUIRED_CYGWIN_RUNTIME_LIBS gcc_s-1"
fi

# Extracting source files
echo "Tar file: $SOCAT_TAR"
if [ ! -f "$SOCAT_TAR" -a ! -d "$SOCAT_DIR" ] ; then
	echo "Can not find sofar tar.gz-file!"
	exit -1
fi

if [ -z "$SOCAT_DIR" -o ! -d "$SOCAT_DIR" ] ; then
	echo "Extract tar file"
	tar -xzf "$SOCAT_TAR"
	SOCAT_DIR="$(find / -maxdepth 1 -type d -name 'socat*' | tail -n 1)"
fi

echo "Source folder: $SOCAT_DIR"
if [ ! -d "$SOCAT_DIR" ] ; then
	echo "Can not find socat source folder"
	exit -1
fi

cd "$SOCAT_DIR"

# Configure
if [ ! -f Makefile ] ; then
	./configure
fi

# Compiling
echo "Build socat"
make

# Export required files
echo "Build release"
mkdir -p release
cp -u socat.exe release/.
for LIBNAME in $SOCAT_REQUIRED_CYGWIN_RUNTIME_LIBS ; do 
	echo "Copy $LIBNAME"
	cp -u "/bin/cyg${LIBNAME}.dll" "release/."
done
