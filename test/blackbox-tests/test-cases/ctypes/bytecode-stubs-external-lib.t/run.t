
Build an example library as a DLL and set up the environment so that it looks
like a system/distro library that can be probed with pkg-config and dynamically
loaded.

DYLD_LIBRARY_PATH="$LIBEX" LD_LIBRARY_PATH="$LIBEX"  PKG_CONFIG_PATH="$LIBEX/pkgconfig" PKG_CONFIG_ARGN="--define-prefix"  dune exec ./example.bc --display=short
Reference output


The program is run as bytecode wihout linking in either the stub stub dll or
external dll.


Run the program in bytecode

  $ LIBEX=$(realpath "$PWD/../libexample")
  $ tree $LIBEX
  /workspace_root/test/blackbox-tests/test-cases/ctypes/libexample
  |-- example.h -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/example.h
  |-- libexample.a -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/libexample.a
  |-- libexample.so -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/libexample.so
  `-- pkgconfig
      `-- libexample.pc -> ../../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/pkgconfig/libexample.pc
  
  1 directory, 4 files
  $ DYLD_LIBRARY_PATH="$LIBEX" LD_LIBRARY_PATH="$LIBEX"  PKG_CONFIG_PATH="$LIBEX/pkgconfig" PKG_CONFIG_ARGN="--define-prefix" dune build stubgen/dllexamplelib_stubs.so
  + cc -shared -undefined dynamic_lookup -Wl,-w   -g -o stubgen/dllexamplelib_stubs.so stubgen/libexample__c_cout_generated_functions__Function_description__Functions.o  -L/workspace_root/test/blackbox-tests/test-cases/ctypes/libexample -lexample   
  + ar rcs stubgen/libexamplelib_stubs.a  stubgen/libexample__c_cout_generated_functions__Function_description__Functions.o

  $ CAML_LD_LIBRARY_PATH="$LIBEX/_build/default/stubgen" DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$LIBEX" LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LIBEX"  PKG_CONFIG_PATH="$LIBEX/pkgconfig" PKG_CONFIG_ARGN="--define-prefix"  dune build --display=short ./example.bc
      ocamldep stubgen/.examplelib.objs/examplelib__C.impl.d
    pkg-config stubgen/.pkg-config/libexample.cflags
    pkg-config stubgen/.pkg-config/libexample.libs
  libexample__function_gen__Function_description__Functions stubgen/libexample__c_generated_functions__Function_description__Functions.ml
      ocamldep stubgen/.examplelib.objs/examplelib__Libexample__c_generated_functions__Function_description__Functions.impl.d
        ocamlc stubgen/.examplelib.objs/byte/examplelib__Libexample__c_generated_functions__Function_description__Functions.{cmi,cmo,cmt}
        ocamlc stubgen/.examplelib.objs/byte/examplelib__C.{cmi,cmo,cmt}
        ocamlc .example.eobjs/byte/dune__exe__Example.{cmi,cmti}
        ocamlc stubgen/examplelib.cma
        ocamlc .example.eobjs/byte/dune__exe__Example.{cmo,cmt}
        ocamlc example.bc

  $ tree $LIBEX
  /workspace_root/test/blackbox-tests/test-cases/ctypes/libexample
  |-- example.h -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/example.h
  |-- libexample.a -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/libexample.a
  |-- libexample.so -> ../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/libexample.so
  `-- pkgconfig
      `-- libexample.pc -> ../../../../../../../../../default/test/blackbox-tests/test-cases/ctypes/libexample/pkgconfig/libexample.pc
  
  1 directory, 4 files
 

Explictly set LIBRARY_PATH at runtime,otherwise dlopen cannot find libexample. (TODO, fix with rpath and clean after install?)

  $ DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$LIBEX" CAML_LD_LIBRARY_PATH="$CAML_LD_LIBRARY_PATH:$PWD/_build/default/stubgen" ocamlrun _build/default/example.bc --display=short2>&1|sed  's/.sandbox\/[^/]*/SANDBOX_ID/g'
  4

Verify libexample is referenced in stubs.

TODO: example of manual/relative paths  
osx:
install_name_tool -id libexample.so @rpath/libexample.so
#Then some other tool sets @rpath.
- Use @rpath when building/linking
- 


  $ install_name_tool -change libexample.so ../libexample/libexample.so _build/default/stubgen/dllexamplelib_stubs.so
  $ ls _build/default/stubgen/../../../../libexample
  example.h
  libexample.a
  libexample.so
  pkgconfig
  $ otool -l _build/default/stubgen/dllexamplelib_stubs.so |grep -A3 RPATH
  [1]
  $ otool -L _build/default/stubgen/dllexamplelib_stubs.so
  _build/default/stubgen/dllexamplelib_stubs.so:
  	stubgen/dllexamplelib_stubs.so (compatibility version 0.0.0, current version 0.0.0)
  	../libexample/libexample.so (compatibility version 0.0.0, current version 0.0.0)
  	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)

  $ ls ../libexample
  example.h
  libexample.a
  libexample.so
  pkgconfig
  $ echo "STRING $TESTCASE_ROOT"|  sed 's/a//'
  STRING 
  $ echo "$LIBEX"
  /workspace_root/test/blackbox-tests/test-cases/ctypes/libexample

  $ echo $PWD
  $TESTCASE_ROOT
  $ ocamlrun -I _build/default/stubgen _build/default/example.bc --display=short2>&1|sed
  4


Trace of pkg-config flags

  $ cat _build/default/stubgen/.pkg-config/libexample.cflags
  -I/workspace_root/test/blackbox-tests/test-cases/ctypes/libexample
  $ cat _build/default/stubgen/.pkg-config/libexample.libs
  -L/workspace_root/test/blackbox-tests/test-cases/ctypes/libexample -lexample

