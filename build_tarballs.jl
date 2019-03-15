# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libantic"
version = v"0.0.1"

# Collection of sources required to build libantic
sources = [
    "https://github.com/wbhart/antic.git" =>
    "6f99431e87a60f215f8b450abc7da96a373094c2",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
if [ $target != "x86_64-w64-mingw32" ]; then
  cd $WORKSPACE/srcdir;
  cd antic/;
  ./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix --with-flint=$prefix;
  make -j${nproc};
  make install;
else
  cd $WORKSPACE/srcdir;
  cd antic/;
  ./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix --with-flint=$prefix;
  if [ ! -f $prefx/lib/libflint-13.dll ]; then cp $prefix/bin/libflint-13.dll $prefix/lib/; fi
  if [ ! -f $prefx/lib/libflint.dll ]; then cp $prefix/bin/libflint.dll $prefix/lib/; fi
  #cp -n $prefix/bin/libflint-13.dll $prefix/bin/libflint.dll $prefix/lib/;
  make -j${nproc};
  make install;
  rm $WORKSPACE/destdir/bin/libflint-13.dll
  rm $WORKSPACE/destdir/bin/libflint.dll
  cd $prefix/lib
  mv libantic.so libantic.dll
fi

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Windows(:x86_64),
    MacOS(:x86_64),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libantic", :libantic)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaMath/GMPBuilder/releases/download/v6.1.2-2/build_GMP.v6.1.2.jl",
    "https://github.com/JuliaMath/MPFRBuilder/releases/download/v4.0.1-3/build_MPFR.v4.0.1.jl",
    "https://github.com/thofma/Flint2Builder/releases/download/2b8f8acb/build_libflint.v2.0.0-b8f8acb317c265db99f828e7baf3266f07f92a7.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

