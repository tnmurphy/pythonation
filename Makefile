# pythonation - provide  multiple versions of Python
#
# Copyright (c) 2025 Timothy Norman Murphy
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
# THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# all built pythons go here:
PYTHON_INSTALL_ROOT = /usr/local/python


# NOTE: you should  add the shared library paths for each version into
# /etc/ld.so.conf.d/python.conf OR to add these paths to 
# LD_LIBRARY_PATH in the environment.
# e.g. $(PYTHON_INSTALL_ROOT)/3.13.3/lib

# run `make install-all` to build and install all versions of python
# run `make install-python-<version>` to build and install a specific version of python
#

SRCDIR=.
VERSIONS := 3.14.0_b1 3.13.3__nogil 3.13.3__jit 3.12.10 3.11.12 3.9.22 3.8.20
PYTHON_3.13.2_CUSTOM_OPTS := --disable-gil 


# NON-CONFIGURABLE OPTIONS #####################
#
SHELL:=/bin/bash
SPACE:=

BASE_VERSION_EXP := (^[0-9]+\.[0-9]+\.[0-9]+)([a-z]+[0-9]+)?

.PHONY: install-all
install-all:

# Macro for building a custom python which might comprise
# a specific version of python with custom build options. 
define build_python

SPLIT_VERSION_$(1):=$(subst _, ,$(subst __,_*_,$(1)))
PYTHON_$(1)_VERSION:=$$(word 1,$$(SPLIT_VERSION_$(1)))
PYTHON_$(1)_RC:=$$(subst *,,$$(word 2,$$(SPLIT_VERSION_$(1))))
PYTHON_$(1)_CUSTOM:=$$(subst *,,$$(word 3,$$(SPLIT_VERSION_$(1))))

PYTHON_$1_TARNAME:=Python-$$(PYTHON_$(1)_VERSION)$$(PYTHON_$(1)_RC).tar.xz
PYTHON_$1_TAR:=$(SRCDIR)/$$(PYTHON_$1_TARNAME)

PYTHON_$1_BUILD:=$(SRCDIR)/build-$1

#  Installation location /usr/local/python/<version>
PYTHON_$1_TARGET_PATH:=$(PYTHON_INSTALL_ROOT)/python/$1

$$(info ==== PARAMETERS FOR $(1):)
$$(info SPLIT=$$(SPLIT_VERSION_$(1)))
$$(info PYTHON_VERSION="$$(PYTHON_$(1)_VERSION)")
$$(info PYTHON_RC="$$(PYTHON_$(1)_RC)")
$$(info PYTHON_CUSTOM="$$(PYTHON_$(1)_CUSTOM)")
$$(info python $(1) makefile "$$(SRCDIR)/Python-$(1)/Makefile")
$$(info python $(1) tarfile: "$$(PYTHON_$1_TAR)")
$$(info python $(1) build dir: "$$(PYTHON_$1_BUILD)")


.PHONY: python-$(1)
python-$(1): $$(PYTHON_$1_BUILD)/Makefile
	@echo "Building Python $(1)"
	cd "$$(PYTHON_$1_BUILD)" &&  {\
	CFLAGS="$$$${CFLAGS} -fno-semantic-interposition"; \
	make EXTRA_CFLAGS="$$$$CFLAGS" -j6;\
	}

$$(PYTHON_$1_BUILD)/Makefile: $$(PYTHON_$1_TAR)
	@echo "Configuring Python $(1): DEPENDS=$$(^)"
	mkdir -p "$$(PYTHON_$1_BUILD)"; \
	tar -xf $$(^) --strip-components=1 -C "$$(PYTHON_$1_BUILD)"
	cd "$$(PYTHON_$1_BUILD)" &&  {\
	CFLAGS="$$$${CFLAGS} -fno-semantic-interposition"; \
	./configure --prefix=$$(PYTHON_$1_TARGET_PATH) \
	            --enable-shared \
	            --with-computed-gotos \
	            --with-lto \
	            --enable-ipv6 \
	            --with-system-expat \
	            --with-dbmliborder=gdbm:ndbm \
	            --with-system-ffi \
	            --with-system-libmpdec \
	            --enable-loadable-sqlite-extensions \
	            --without-ensurepip \
	            --with-tzpath=/usr/share/zoneinfo \
		    $$(PYTHON_$(1)_CUSTOM_OPTS) \
                    --enable-optimizations; \
	}

install-python-$1: python-$1
	@echo "Installing Python $1"
	cd "$$(PYTHON_$1_BUILD)" &&  {\
	sudo make install; \
	}

.PHONY: build-all
build-all: python-$1

.PHONY: install-all
install-all: install-python-$1

$$(PYTHON_$1_TAR):
	wget -P $(SRCDIR) https://www.python.org/ftp/python/$$(PYTHON_$1_VERSION)/$$(PYTHON_$1_TARNAME)

endef

$(foreach version,$(VERSIONS),$(eval $(call build_python,$(version))))

help:
	@echo "Versions you can build: $(VERSIONS)" 
	@echo "Individual version targets:" 
	@echo "    build: $(foreach version,$(VERSIONS),python-$(version))"
	@echo "    install: $(foreach version,$(VERSIONS),install-python-$(version))"


