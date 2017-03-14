.PHONY: all dist clean
BINARY_NAME := dataextractor
APP_NAME := streamsets-dataextractor
VERSION := 0.0.1
DIR=.
BuiltDate := `date +%FT%T%z`

# Go setup
GO=go
TEST=go test

DEPENDENCIES := github.com/hpcloud/tail/... \
    github.com/BurntSushi/toml \
    github.com/satori/go.uuid

# Sources and Targets
EXECUTABLES :=dist/bin/$(BINARY_NAME)
# Build Binaries setting main.version and main.build vars
LDFLAGS :=-ldflags "-X github.com/streamsets/dataextractor/lib/common.Version=${VERSION} -X github.com/streamsets/dataextractor/lib/common.BuiltBy=$$USER -X github.com/streamsets/dataextractor/lib/common.BuiltDate=${BuiltDate}"

# Package target
PACKAGE :=$(DIR)/dist/$(APP_NAME)-$(VERSION).tar.gz

DEPENDENCIES_DIR := $(DEPENDENCIES)

.DEFAULT: dist

all: | $(EXECUTABLES)

$(DEPENDENCIES_DIR):
	@echo Downloading $@
	$(GO) get $@

dist/bin/$(BINARY_NAME): main.go $(DEPENDENCIES_DIR)

$(EXECUTABLES):
	$(GO) build $(LDFLAGS) -o $@ $<

test:
	$(TEST) -r -cover

clean:
	@echo Cleaning Workspace...
	rm -dRf dist

$(PACKAGE): all
	@echo Packaging Binaries...
	@mkdir -p tmp/$(APP_NAME)/bin
	@cp -R dist/bin/ tmp/$(APP_NAME)/bin
	@cp -R $(DIR)/etc/ dist/etc
	@cp -R $(DIR)/etc/ tmp/$(APP_NAME)/etc
	@mkdir dist/logs
	@mkdir -p tmp/$(APP_NAME)/logs
	@mkdir dist/data
	@mkdir -p tmp/$(APP_NAME)/data
	@mkdir -p $(DIR)/dist/
	tar -cf $@ -C tmp $(APP_NAME);
	@rm -rf tmp

dist: $(PACKAGE)
