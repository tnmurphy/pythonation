## pythonation ##

**Author: Timothy N Murphy <tnmurphy@gmail.com>**

I often want to build a suite of different python versions so that I
can try out the various features or different performance optimisations.
Sometimes it's just the classic problem of needing to do development on
projects that require a different version from the one that's installed
with my operating system.

So you can use pyenv but those versions are prebuilt and that means you
can't e.g. build python with your own choice of compiler options.

## Requirements ##

Only Linux is supported at this time. It might work on a Mac and possibly
in cygwin but it cannot build for vanilla windows.

Your operating system has to have a basic set of development tools
installed to use this. At minimum:

* GNU Make > 3.81
* GCC 
* libraries roughly corresponding to 
*  bzip2  expat  gdbm  libffi  libnsl  libxcrypt  openssl  zlib  tzdata  mpdecimal
*  The names used by your package manager will change from one distribution to the next. There are some standard ways to get the build dependencies for your system python on each distro which will be enough for pythonation

## What you get at the end ##

The makefile builds a list of python versions which are specified in the configurable section at the top.

For example: 

```
VERSIONS := 3.12.10 3.11.12 3.9.22
```

...this will build 3 separate versions of python.
Once built you can install all of them with

```
  $ sudo make install
```

The install location defaults to /usr/local/python/*VERSION* where VERSION comes from the VERSIONS variable explained above.  It can be altered by setting the following variable in the configurable section at the top of the makefile:
```
PYTHON_INSTALL_ROOT = /usr/local/python
```

In the example above the 3 versions of python would be installed in:

```
/usr/local/python/3.12.0
/usr/local/python/3.11.12
/usr/local/python/3.9.22
```

### Release Candidates ###

Here is an example of how to build python 3.14.0 beta 1:
```
VERSIONS := 3.14.0_b1
```

### Custom Versions ###

Sometimes what we want to do is build the same python with different options.  The version specifier has a special format to support this and support release candidates.  You write the version as a 3-element tuple separated by '_' (underscore) like this: VERSION_RELEASECANDIDATE_CUSTOMID.

Here is an example for 3.13.3.  there's no RELEASECANTIDATE here because these are released versions so you see a double  underscore before the CUSTOMID which is just an ID that will be used to refer in future to your different builds of the same python version.
```
VERSIONS := 3.13.3__nogil 3.13.3__jit 
```

So this will build 2 separate builds of python 3.13.3 and they will install in 
```
/usr/local/python/3.13.3__nogil
   and
/usr/local/python/3.13.3__jit
```

BUT WHAT USE IS THIS? Both of these builds will be the same unless you specify some options which are going to make them different.  The options you can specify are all fed to the 'configure' script. You do it by adding variables into the configurable section of the makefile like so: PYTHON_VERSION_RELEASECANDIDATE_CUSTOMD_CUSTOM_OPTS:=_OPTIONS_

For Example:
```
PYTHON_3.13.3__nogil_CUSTOM_OPTS:=--disable-gil
PYTHON_3.13.3__jit_CUSTOM_OPTS:=--enable-experimental-jit=yes
```


## How to build all your pythons ##

All you have to do to get going is type

```
    $ make
```

And then wait a long time for the various python versions to get built.  If you have a lot of cores you can try to use a -j option but it can be confusing if there are errors.

my_module.o can be compiled from my_module.c by instructions supplied
in the body of your makefile.

