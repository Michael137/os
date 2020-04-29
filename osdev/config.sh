SYSTEM_HEADER_PROJECTS="libc kernel"
PROJECTS="libc kernel"

export OS_NAME=occamos
export MAKE=make
export HOST=i686-elf

export AR=$HOME/opt/cross-compiler/bin/${HOST}-ar
export AS=$HOME/opt/cross-compiler/bin/${HOST}-as
export CC=$HOME/opt/cross-compiler/bin/${HOST}-gcc

export PREFIX=/usr
export EXEC_PREFIX=$PREFIX
export BOOTDIR=/boot
export LIBDIR=$EXEC_PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export CFLAGS='-O2 -g'
export CPPFLAGS=''

# Configure the cross-compiler to use the desired system root.
export SYSROOT="$(pwd)/sysroot"
export CC="$CC --sysroot=$SYSROOT"

# Work around that the -elf gcc targets doesn't have a system include directory
# because it was configured with --without-headers rather than --with-sysroot.
if echo "$HOST" | grep -Eq -- '-elf($|-)'; then
  export CC="$CC -isystem=$INCLUDEDIR"
fi
