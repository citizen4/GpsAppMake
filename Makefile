# Environment variables
ANDROID_HOME ?=

# Variables
project     := gpsapp
package     := kc87.gpsapp

# Build tools & SDK versions
build_tools := 25.0.2
target      := android-25

AAPT=$(ANDROID_HOME)/build-tools/$(build_tools)/aapt
ZIPALIGN=$(ANDROID_HOME)/build-tools/$(build_tools)/zipalign
JACK=java -jar $(ANDROID_HOME)/build-tools/$(build_tools)/jack.jar -D jack.java.source.version=8
ANDROID_JAR=$(ANDROID_HOME)/platforms/$(target)/android.jar

src_dir     := src
res_dir     := res
lib_dir			:= lib

gen_dir     := build/generated
int_dir     := build/intermediate
out_dir     := build/output

sources     := $(shell find $(src_dir) -name '*.java')
resources   := $(shell find $(res_dir) -type f)
libraries   := $(shell find $(lib_dir) -name '*.jar')
generated   := $(gen_dir)/$(shell echo $(package) | tr '.' '/')/R.java


# Final zipaligned APK
$(out_dir)/$(project).apk: $(out_dir)/$(project)-unaligned.apk
	@echo -n Zipaligning...
	@$(ZIPALIGN) -f 4 $< $@
	@echo Done.

# Packaging the APK
$(out_dir)/$(project)-unaligned.apk: $(out_dir) AndroidManifest.xml $(resources) $(int_dir)/classes.dex
	@echo -n Packaging...
	@$(AAPT) package -f -M AndroidManifest.xml -I $(ANDROID_JAR) -S $(res_dir) -F $@
	@cd $(int_dir) && $(AAPT) add $(abspath $@) classes.dex > /dev/null
	@echo Done.
	@echo -n Signing the APK...
	@jarsigner -verbose \
		-keystore ~/.android/debug.keystore \
		-storepass android \
		-keypass android \
		$@ \
		androiddebugkey \
		> /dev/null
	@echo Done.

# Compilation & dexing w/ Jack
$(int_dir)/classes.dex: $(int_dir) $(sources) $(generated)
	@echo -n Compiling with Jack...
	@$(JACK) --classpath $(ANDROID_JAR) $(foreach lib,$(libraries),--import $(lib)) \
		--output-dex $(int_dir) $(sources) $(generated)
	@echo Done.

# Generating R.java based on the manifest and resources
$(generated): $(gen_dir) AndroidManifest.xml $(resources)
	$(info VAR is $(generated))
	@echo -n Generating R.java... 
	@$(AAPT) package -f -M AndroidManifest.xml -I $(ANDROID_JAR) -S $(res_dir) -J $(gen_dir) -m
	@echo Done.

# Subfolders in build/
$(gen_dir) $(out_dir) $(int_dir):
	@mkdir -p $@

.PHONY: clean
clean:
	rm -rf build

.PHONY: install
install: $(out_dir)/$(project).apk
	adb install -r $<

.PHONY: uninstall
uninstall:
	adb uninstall $(package)

.PHONY: run
run:
	adb shell am start $(package)/.MainActivity
