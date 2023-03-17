USE_CACHE ?= yes
ARCH ?= $(shell uname -m)
ifeq (${ARCH}, arm64)
	ARCH = aarch64
	# Presently buggy because --cache-dir is presumed to be both a source
	# and a destination.  See melange#329.
	USE_CACHE = no
endif

MELANGE_DIR ?= ../melange
MELANGE ?= ${MELANGE_DIR}/melange
KEY ?= local-melange.rsa
REPO ?= $(shell pwd)/packages
SOURCE_DATE_EPOCH ?= 0
CACHE_DIR ?= gs://wolfi-sources/

WOLFI_SIGNING_PUBKEY ?= https://packages.wolfi.dev/os/wolfi-signing.rsa.pub
WOLFI_PROD ?= https://packages.wolfi.dev/os

MELANGE_OPTS += --repository-append ${REPO}
MELANGE_OPTS += --keyring-append ${KEY}.pub
MELANGE_OPTS += --signing-key ${KEY}
MELANGE_OPTS += --pipeline-dir ${MELANGE_DIR}/pipelines
MELANGE_OPTS += --arch ${ARCH}
MELANGE_OPTS += --env-file build-${ARCH}.env
MELANGE_OPTS += --namespace wolfi
MELANGE_OPTS += --generate-index false
MELANGE_OPTS += ${MELANGE_EXTRA_OPTS}

ifeq (${USE_CACHE}, yes)
	MELANGE_OPTS += --cache-dir ${CACHE_DIR}
endif

ifeq (${BUILDWORLD}, no)
MELANGE_OPTS += -k ${WOLFI_SIGNING_PUBKEY}
MELANGE_OPTS += -r ${WOLFI_PROD}
endif

define build-package

packages/$(1): packages/${ARCH}/$(1)-$(2).apk
packages/${ARCH}/$(1)-$(2).apk: ${KEY}
	mkdir -p ./$(1)/
	SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH} ${MELANGE} build $(1).yaml ${MELANGE_OPTS} --source-dir ./$(if $(3),$(3),$(1))/

PACKAGES += packages/${ARCH}/$(1)-$(2).apk
PACKAGES_LOG := $(PACKAGES_LOG)"${ARCH}|$(1)|$(2)\n"

endef

all: ${KEY} .build-packages

${KEY}:
	${MELANGE} keygen ${KEY}

clean:
	rm -rf packages/${ARCH}

# The list of packages to be built.
#
# Use the `build-package` macro for packages which require a source
# directory, like `glibc/` or `busybox/`.
# arg 1 = package name
# arg 2 = package version
# arg 3 = override source directory, defaults to package name, useful if you want to reuse the same subfolder for multiple packages
$(eval $(call build-package,foo,1.2.3-r0))
$(eval $(call build-package,bar,2.3.4-r0))


.build-packages: ${PACKAGES}
	echo XXXX1
	echo ${PACKAGES}
	

	echo ${PACKAGES_LOG} > packages.log
	echo XXXX2
dev-container:
	docker run --privileged --rm -it -v "${PWD}:${PWD}" -w "${PWD}" cgr.dev/chainguard/sdk:latest
