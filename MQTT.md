部分冲突

| 包名       | 现有版本 | 目标版本 | 是否重装(加入buildroot) | 是否使用pip | 是否完成配置 |
| ---------- | -------- | -------- | ----------------------- | ----------- | ------------ |
| numpy      | 1.18.2   | 1.21.6   | 1                       |             | 1            |
| PIllow     | 4.2.1    | 9.2.0    | 1                       | 1           | 1            |
| protobuf   | 3.6      | 4.21.3   |                         | 1           | 1            |
| psutil     | 5.6.3    | 5.6.2    | 1                       |             | 1            |
| PyYAML     | 3.12     | 6.0      | 1                       |             | 1            |
| setuptools | 60.7.0   | 47.1.0   | 0                       | 0           | 1            |

没有

| 包名          | 现有版本 | 目标版本 | 是否使用pip | 加入buildroot | 是否完成配置 |
| ------------- | -------- | -------- | ----------- | ------------- | ------------ |
| imutils       |          | 0.5.4    | 1           |               |              |
| matplotlib    | 3.4.3    | 3.4.3    |             |               | 1            |
| pafy          |          | 0.5.5    | 1           |               | 1            |
| pandas        |          | 1.3.3    | 1           |               | 1            |
| pycocotools   |          | 2.0.4    | 1           |               |              |
| pyzbar        |          | 0.1.9    | 1           |               | 1            |
| scipy         |          | 1.7.3    | 1           |               |              |
| Shapely       |          | 1.7.1    | 1           |               |              |
|               |          |          |             |               |              |
| opencv-python |          | 3        | 1           |               |              |

正常buildroot

| 包名     | 现有版本 | 目标版本 | 使用buildroot |
| -------- | -------- | -------- | ------------- |
| requests | 2.22.0   | 2.22.0   |               |
|          |          |          |               |
|          |          |          |               |

h -c numpy/random/mtrand/mtrand.c





source "package/python-pyyaml/Config.in.host"



```
config BR2_PACKAGE_PYTHON_CERTIFI
	bool "python-certifi"
	help
	  Python package for providing Mozilla's CA Bundle.

	  https://pypi.python.org/pypi/certifi
	  
config BR2_PACKAGE_HOST_PYTHON_CERTIFI
	bool "host-python-certifi"
	help
	  Python package for providing Mozilla's CA Bundle.

	  https://pypi.python.org/pypi/certifi
```

```
config BR2_PACKAGE_PYTHON_PYYAML
	bool "python-pyyaml"
	select BR2_PACKAGE_LIBYAML
	help
	  The PyYAML package contains binding to the libyaml API.


config BR2_PACKAGE_HOST_PYTHON_PYYAML
	bool "host-python-pyyaml"
	select BR2_PACKAGE_HOST_LIBYAML
	help
	  The PyYAML package contains binding to the libyaml API.

	  http://pyyaml.org/

```

python-pandas.mk

```
################################################################################
#
# python-pandas
#
################################################################################

PYTHON_PANDAS_VERSION = 1.3.3
PYTHON_PANDAS_SOURCE = pandas-$(PYTHON_PANDAS_VERSION).tar.gz
PYTHON_MATPLOTLIB_SITE = https://files.pythonhosted.org/packages/71/65/3ab03ef46613e66880dba5b2c2cb5836938f0219389a11c10cfdc617e836/pandas-1.3.3.tar.gz
PYTHON_PANDAS_LICENSE = Python-2.0
PYTHON_PANDAS_LICENSE_FILES = LICENSE
PYTHON_PANDAS_DEPENDENCIES = \
	setuptools \
	host-python-cython \
	host-python-numpy  \
	
PYTHON_PANDAS_SETUP_TYPE = setuptools

define PYTHON_PANDAS_COPY_SETUP_CFG
	cp $(PYTHON_PANDAS_PKGDIR)/setup.cfg $(@D)/setup.cfg
endef

PYTHON_PANDAS_PRE_CONFIGURE_HOOKS += PYTHON_PANDAS_COPY_SETUP_CFG

$(eval $(python-package))
$(eval $(host-python-package))
```

python-pandas.hash

```
# sha256 from https://pypi.org/project/pandas/#files
sha256	272c8cb14aa9793eada6b1ebe81994616e647b5892a370c7135efb2924b701df  pandas-1.3.3.tar.gz
# Locally computed sha256 checksums
sha256	989582be44f5d226df5d9bf8fe394a2333804c36ba96107aa2bde92d00b3ee9f  LICENSE
```

Config.in

```
config BR2_PACKAGE_PYTHON_PANDAS
	bool "python-pandas"
	depends on BR2_PACKAGE_PYTHON3
	depends on BR2_PACKAGE_PYTHON_NUMPY_ARCH_SUPPORTS
	depends on BR2_TOOLCHAIN_USES_GLIBC || BR2_TOOLCHAIN_USES_MUSL # python-numpy
	select BR2_PACKAGE_PYTHON_SETUPTOOLS # runtime
	select BR2_PACKAGE_PYTHON_NUMPY # runtime
	select BR2_PACKAGE_PYTHON3_ZLIB # runtime
	select BR2_PACKAGE_ZLIB # runtime
	help
		Pandas is a Python package that provides fast, flexible, and expressive data structures designed to 		make working with "relational" or "labeled" data both easy and intuitive. It aims to be the 				fundamental high-level building block for doing practical, real world data analysis in Python. 
		https://github.com/pandas-dev/pandas
```



```
opencv-python: 只包含opencv库的主要模块. 一般不推荐安装.
opencv-contrib-python: 包含主要模块和contrib模块, 功能基本完整, 推荐安装.
opencv-python-headless: 和opencv-python一样, 但是没有GUI功能, 无外设系统可用.
opencv-contrib-python-headless: 和opencv-contrib-python一样但是没有GUI功能. 无外设系统可用.
```

```
#https://blog.csdn.net/jiaken2660/article/details/104132060

解决opencv_contrib文件缺失问题
```

openblas,lapackam



```
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://ports.ubuntu.com/ubuntu-ports/ focal main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://ports.ubuntu.com/ubuntu-ports/ focal universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu bionic partner
# deb-src http://archive.canonical.com/ubuntu bionic partner

deb http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-security universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ bionic-security multiverse
```

BR2_PACKAGE_LAPACK_ARCH_SUPPORTS

BR2_TOOLCHAIN_HAS_FORTRAN