# Set default goal for "make"
.DEFAULT_GOAL := specs

ifeq ($(MAKECMDGOALS),)
GOAL := $(.DEFAULT_GOAL)
else
GOAL := $(MAKECMDGOALS)
endif


#===== Versioning ==============================================================

## OpenSSL version to build
VERSION ?= 1.1.1h

## Extra version of the distributed package
PACKAGE_VERSION ?= 2
export PACKAGE_VERSION

MIN_IOS_SDK = 10.0
MIN_OSX_SDK = 10.11
export MIN_IOS_SDK MIN_OSX_SDK

BUILD_ARCHS   += ios_i386 ios_x86_64 ios_arm64 ios_armv7s ios_armv7
BUILD_ARCHS   += mac_x86_64
BUILD_TARGETS += ios-sim-cross-i386 ios-sim-cross-x86_64
BUILD_TARGETS += ios64-cross-arm64 ios-cross-armv7s ios-cross-armv7
BUILD_TARGETS += macos64-x86_64

# Automatically enable Apple Silicon support if running with Xcode 12.2+
# unless the user has decided explicitly.
ifeq ($(APPLE_SILICON_SUPPORT),)
xcode_version := $(shell xcodebuild -version | awk '/Xcode/ {print $$2}')
ifeq ($(shell printf '%s\n' "12.2" "$(xcode_version)" | sort -V | head -1),12.2)
APPLE_SILICON_SUPPORT := yes
endif
endif

# Not all currently used Xcode versions support building for Apple Silicon.
# Enable this architecture only when requested.
ifeq ($(APPLE_SILICON_SUPPORT),yes)
BUILD_ARCHS   += mac_arm64
BUILD_TARGETS += macos64-arm64
# FIXME(ilammy, 2020-10-22): iOS Simulator build for arm64 temporarily disabled.
# A single framework cannot contain both iOS and iOS Simulator arm64 slices.
# XCFrameworks should be able to support this combination in the future.
# BUILD_TARGETS += ios-sim-cross-arm64
endif

BUILD_FLAGS += --version=$(VERSION)
BUILD_FLAGS += --archs="$(BUILD_ARCHS)"
BUILD_FLAGS += --targets="$(BUILD_TARGETS)"
BUILD_FLAGS += --min-ios-sdk=$(MIN_IOS_SDK)
BUILD_FLAGS += --min-macos-sdk=$(MIN_OSX_SDK)


#===== Building ================================================================

## Output directory
OUTPUT ?= output

## Build OpenSSL binaries
build: $(OUTPUT)/done.build
ifeq ($(GOAL),build)
	@echo "Now you can package OpenSSL binaries:"
	@echo
	@echo "    make package"
	@echo
endif

.PHONY: build

$(OUTPUT)/done.build:
	@./build-libssl.sh $(BUILD_FLAGS)
	@mkdir -p $(OUTPUT)
	@touch $(OUTPUT)/done.build

## Force rebuild of OpenSSL binaries
rebuild:
	@./build-libssl.sh $(BUILD_FLAGS)
	@mkdir -p $(OUTPUT)
	@touch $(OUTPUT)/done.build
ifeq ($(GOAL),rebuild)
	@echo "Now you can package OpenSSL binaries:"
	@echo
	@echo "    make package"
	@echo
endif

.PHONY: rebuild


#===== Packaging ===============================================================

## Prepare OpenSSL packages for upload
packages: $(OUTPUT)/done.packages
ifeq ($(GOAL),packages)
	@echo "Now you can update package specs:"
	@echo
	@echo "    make specs"
	@echo
endif

.PHONY: packages

$(OUTPUT)/done.packages: $(OUTPUT)/done.build
	@scripts/create-packages.sh
	@mkdir -p $(OUTPUT)
	@touch $(OUTPUT)/done.packages


#===== Spec updates ============================================================

## Update package spec files
specs: $(OUTPUT)/done.specs
ifeq ($(GOAL),specs)
	@echo "Now you can commit the changes:"
	@echo
	@echo "    git add -p"
	@echo "    git commit -em \"OpenSSL $(VERSION)\""
	@echo
	@echo "Submit a pull request against the \"cossacklabs\" branch."
	@echo "Wait for it to be merged, then prepare a signed release tag:"
	@echo
	@echo "    git checkout cossacklabs"
	@echo "    git pull"
	@echo
	@echo "    # The tag must contain the 'semversified' version of OpenSSL"
	@echo "    # (e.g., $$(cat "$(OUTPUT)/version") instead of $(VERSION))"
	@echo "    git tag -sem \"OpenSSL $(VERSION)\" v$$(cat "$(OUTPUT)/version")"
	@echo "    git push --tags"
	@echo
	@echo "Finally, create a pre-release on GitHub from this tag:"
	@echo
	@echo "    https://github.com/cossacklabs/openssl-apple/releases/new"
	@echo
	@echo "and attach the following files to the release:"
	@echo
	@find $(OUTPUT) -type f -name 'openssl-*.zip' | sort | sed 's/^/    /g'
	@echo
endif

.PHONY: specs

$(OUTPUT)/done.specs: $(OUTPUT)/done.packages
	@scripts/update-specs.sh
	@mkdir -p $(OUTPUT)
	@touch $(OUTPUT)/done.specs


#===== Miscellaneous ===========================================================

## Remove build artifacts
clean:
	@rm -rf bin lib src frameworks include/openssl
	@rm -rf $(OUTPUT)

.PHONY: clean
