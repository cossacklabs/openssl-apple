# Set default goal for "make"
.DEFAULT_GOAL := specs

ifeq ($(MAKECMDGOALS),)
GOAL := $(.DEFAULT_GOAL)
else
GOAL := $(MAKECMDGOALS)
endif


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
	@./build-libssl.sh
	@mkdir -p $(OUTPUT)
	@touch $(OUTPUT)/done.build

## Force rebuild of OpenSSL binaries
rebuild:
	@./build-libssl.sh
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
	@echo "    git commit -em \"OpenSSL $$(cat "$(OUTPUT)/version")\""
	@echo
	@echo "Submit a pull request against the \"cossacklabs\" branch."
	@echo "Wait for it to be merged, then prepare a signed release tag:"
	@echo
	@echo "    git checkout cossacklabs"
	@echo "    git pull"
	@echo "    git tag -sem \"OpenSSL $$(cat "$(OUTPUT)/version")\" v$$(cat "$(OUTPUT)/version")"
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
