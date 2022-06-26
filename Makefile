APP_NAME := Asteroids
# This is provided by `semantic-release`
# APP_VERSION :=

ASSETS_DIR := assets
BUILD_DIR := build
DIST_DIR := dist
TOOLS_DIR := tools

STEAM_ASSETS_DIR := $(ASSETS_DIR)/steam

STEAM_HOME := $(HOME)/Library/Application\ Support/Steam
STEAM_CONFIG_DIR := $(STEAM_HOME)/config
STEAM_CONFIG_FILE := $(STEAM_HOME)/config/config.vdf
STEAM_SSFN_FILE := $(STEAM_HOME)/$(STEAM_SSFN_NAME)

# Tools

BOB_PATH := $(TOOLS_DIR)/bob.jar
BOB_VERSION := 1.3.3
BOB_SHA256 := d734a32e43087d6780bbf9269a227efb1438ef20e9f0c3541af1456eb5368d56

RCEDIT_PATH := $(TOOLS_DIR)/rcedit.exe
RCEDIT_VERSION := 1.1.1
RCEDIT_SHA256 := 02e8e8c5d430d8b768980f517b62d7792d690982b9ba0f7e04163cbc1a6e7915

BUTLER_PATH := $(TOOLS_DIR)/butler/butler
BUTLER_VERSION := 15.21.0
BUTLER_SHA256 := af8fc2e7c4d4a2e2cb9765c343a88ecafc0dccc2257ecf16f7601fcd73a148ec

STEAMCMD_PATH := $(TOOLS_DIR)/steamcmd/steamcmd
STEAMCMD_SHA256 := 8ecc17c8988e5acadcc78e631c48490f76150f2dfaa6cf8d7b4b67b097bd753b

# Outputs

COMMON_DIST_CHANGELOG := $(DIST_DIR)/CHANGELOG.md

WINDOWS_DIST_DIR := $(DIST_DIR)/windows
WINDOWS_DIST_APP := $(WINDOWS_DIST_DIR)/$(APP_NAME)
WINDOWS_DIST_ZIP := $(WINDOWS_DIST_DIR)/$(APP_NAME)-windows.zip

MACOS_DIST_DIR := $(DIST_DIR)/macos
MACOS_DIST_APP := $(MACOS_DIST_DIR)/$(APP_NAME).app
MACOS_DIST_DMG := $(MACOS_DIST_DIR)/$(APP_NAME)-macos.dmg

LINUX_DIST_DIR := $(DIST_DIR)/linux
LINUX_DIST_APP := $(LINUX_DIST_DIR)/$(APP_NAME)
LINUX_DIST_ZIP := $(LINUX_DIST_DIR)/$(APP_NAME)-linux.zip

WEB_DIST_DIR := $(DIST_DIR)/web
WEB_DIST_APP := $(WEB_DIST_DIR)/$(APP_NAME)
WEB_DIST_ZIP := $(WEB_DIST_DIR)/$(APP_NAME)-web.zip

# Targets

.PHONY: release
release:
	npx semantic-release

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -rf manifest.*

.PHONY: all
all:
	$(MAKE) version
	$(MAKE) common
	$(MAKE) windows
	$(MAKE) macos
	$(MAKE) linux
	$(MAKE) web

.PHONY: version
version:
	perl -i -pe 's/0.0.0-development/$(APP_VERSION)/g;' -pe 's/2100000000/$(subst .,,$(APP_VERSION))/g;' game.project

.PHONY: publish
publish:
	$(MAKE) publish-itchio
	$(MAKE) publish-steam

.PHONY: publish-itchio
publish-itchio:
	$(MAKE) publish-itchio-windows
	$(MAKE) publish-itchio-macos
	$(MAKE) publish-itchio-linux
	$(MAKE) publish-itchio-web

.PHONY: publish-itchio-windows
publish-itchio-windows: $(WINDOWS_DIST_ZIP) $(BUTLER_PATH)
	$(BUTLER_PATH) push $< $(BUTLER_PROJECT):windows --userversion $(APP_VERSION)

.PHONY: publish-itchio-macos
publish-itchio-macos: $(MACOS_DIST_APP) $(BUTLER_PATH)
	$(BUTLER_PATH) push $< $(BUTLER_PROJECT):macos --userversion $(APP_VERSION)

.PHONY: publish-itchio-linux
publish-itchio-linux: $(LINUX_DIST_ZIP) $(BUTLER_PATH)
	$(BUTLER_PATH) push $< $(BUTLER_PROJECT):linux --userversion $(APP_VERSION)

.PHONY: publish-itchio-web
publish-itchio-web: $(WEB_DIST_ZIP) $(BUTLER_PATH)
	$(BUTLER_PATH) push $< $(BUTLER_PROJECT):web --userversion $(APP_VERSION)

.PHONY: publish-steam
publish-steam: $(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).txt \
		$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_COMMON_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_WINDOWS_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_MACOS_DEPOT_ID).vdf \
		$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_LINUX_DEPOT_ID).vdf \
		$(STEAM_CONFIG_FILE) \
		$(STEAM_SSFN_FILE) \
		$(STEAMCMD_PATH) \
		$(WINDOWS_DIST_APP) $(MACOS_DIST_APP) $(LINUX_DIST_APP)
	$(STEAMCMD_PATH) +runscript "../../$<"

$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).txt: $(STEAM_ASSETS_DIR)/app_build_1000.txt
	cat $< | envsubst > $@

$(STEAM_ASSETS_DIR)/app_build_$(STEAM_APP_ID).vdf: $(STEAM_ASSETS_DIR)/app_build_1000.vdf
	cat $< | envsubst > $@

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_COMMON_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1001.vdf
	cat $< | envsubst > $@

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_WINDOWS_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1002.vdf
	cat $< | envsubst > $@

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_MACOS_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1003.vdf
	cat $< | envsubst > $@

$(STEAM_ASSETS_DIR)/depot_build_$(STEAM_LINUX_DEPOT_ID).vdf: $(STEAM_ASSETS_DIR)/depot_build_1004.vdf
	cat $< | envsubst > $@

$(STEAM_CONFIG_FILE):
	mkdir -p $(STEAM_CONFIG_DIR)
	echo "$(STEAM_CONFIG_CONTENTS)" | base64 -d > "$@"
	chmod 777 "$@"

$(STEAM_SSFN_FILE):
	mkdir -p $(STEAM_CONFIG_DIR)
	echo "$(STEAM_SSFN_CONTENTS)" | base64 -d > "$@"
	chmod 777 "$@"

common: $(COMMON_DIST_CHANGELOG)
windows: $(WINDOWS_DIST_ZIP) $(WINDOWS_DIST_APP)
macos: $(MACOS_DIST_DMG) $(MACOS_DIST_APP)
linux: $(LINUX_DIST_ZIP) $(LINUX_DIST_APP)
web: $(WEB_DIST_ZIP)

$(COMMON_DIST_CHANGELOG): CHANGELOG.md
	mkdir -p `dirname $@`
	cp $< $@

$(WINDOWS_DIST_ZIP): $(WINDOWS_DIST_APP)
	(cd $< && zip -rX ../$(notdir $@) .)

$(WINDOWS_DIST_APP): $(BOB_PATH) $(RCEDIT_PATH)
	java -jar $(BOB_PATH) --archive --bundle-output $(WINDOWS_DIST_DIR) --platform x86_64-win32 resolve distclean build bundle
	wine64 $(RCEDIT_PATH) $(WINDOWS_DIST_APP)/Asteroids.exe --set-file-version $(APP_VERSION)
	wine64 $(RCEDIT_PATH) $(WINDOWS_DIST_APP)/Asteroids.exe --set-product-version $(APP_VERSION)

$(MACOS_DIST_DMG): $(MACOS_DIST_APP)
	-npx create-dmg --overwrite $< $(MACOS_DIST_DIR)
	mv $(MACOS_DIST_DIR)/*.dmg $@

$(MACOS_DIST_APP): $(BOB_PATH)
	java -jar $(BOB_PATH) --archive --bundle-output $(MACOS_DIST_DIR) --platform x86_64-darwin resolve distclean build bundle

$(LINUX_DIST_ZIP): $(LINUX_DIST_APP)
	(cd $< && zip -rX ../$(notdir $@) .)

$(LINUX_DIST_APP): $(BOB_PATH)
	java -jar $(BOB_PATH) --archive --bundle-output $(LINUX_DIST_DIR) --platform x86_64-linux resolve distclean build bundle

$(WEB_DIST_ZIP): $(WEB_DIST_APP)
	(cd $< && zip -rX ../$(notdir $@) .)

$(WEB_DIST_APP): $(BOB_PATH)
	java -jar $(BOB_PATH) --archive --bundle-output $(WEB_DIST_DIR) --platform js-web resolve distclean build bundle

$(BOB_PATH):
	curl -L -o /tmp/bob.jar https://github.com/defold/defold/releases/download/$(BOB_VERSION)/bob.jar
	echo "$(BOB_SHA256) /tmp/bob.jar" | sha256sum --check
	mkdir -p `dirname $(BOB_PATH)`
	mv /tmp/bob.jar $(BOB_PATH)
	java -jar $(BOB_PATH) --version

$(RCEDIT_PATH):
	curl -L -o /tmp/rcedit.exe https://github.com/electron/rcedit/releases/download/v$(RCEDIT_VERSION)/rcedit-x64.exe
	echo "$(RCEDIT_SHA256) /tmp/rcedit.exe" | sha256sum --check
	mkdir -p `dirname $(RCEDIT_PATH)`
	mv /tmp/rcedit.exe $(RCEDIT_PATH)
	wine64 $(RCEDIT_PATH) --help

$(BUTLER_PATH):
	curl -L -o /tmp/butler.zip https://broth.itch.ovh/butler/darwin-amd64/$(BUTLER_VERSION)/archive/default
	echo "$(BUTLER_SHA256) /tmp/butler.zip" | sha256sum --check
	mkdir -p `dirname $(BUTLER_PATH)`
	unzip /tmp/butler.zip -d `dirname $(BUTLER_PATH)`
	rm /tmp/butler.zip
	$(BUTLER_PATH) --version

$(STEAMCMD_PATH):
	curl -L -o /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz
	echo "$(STEAMCMD_SHA256) /tmp/steamcmd.tar.gz" | sha256sum --check
	mkdir -p `dirname $(STEAMCMD_PATH)`
	tar zxvf /tmp/steamcmd.tar.gz -C `dirname $(STEAMCMD_PATH)`
	rm /tmp/steamcmd.tar.gz
	while ! $(STEAMCMD_PATH) +help +quit; do sleep 1; done
