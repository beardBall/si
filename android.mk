
#**************************************************************************************************
#
#   raylib makefile for Android project (APK building)
#
#   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
#
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
#
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
#
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
#
#     3. This notice may not be removed or altered from any source distribution.
#
#**************************************************************************************************

# Define required raylib variables
PLATFORM               ?= PLATFORM_ANDROID
RAYLIB_PATH            ?= ..\..

# Define Android architecture (armeabi-v7a, arm64-v8a, x86, x86-64) and API version
# Starting in 2019 using ARM64 is mandatory for published apps,
# Starting on August 2020, minimum required target API is Android 10 (API level 29)
ANDROID_ARCH           ?= ARM64
ANDROID_API_VERSION     = 29

# Android required path variables
# NOTE: Starting with Android NDK r21, no more toolchain generation is required, NDK is the toolchain on itself
ifeq ($(OS),Windows_NT)
    ANDROID_NDK = C:/android-ndk
    ANDROID_TOOLCHAIN = $(ANDROID_NDK)/toolchains/llvm/prebuilt/windows-x86_64
else
    ANDROID_NDK ?= /Users/waqar/Library/Android/sdk/ndk/26.1.10909125/
    ANDROID_TOOLCHAIN = $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64
endif

ifeq ($(ANDROID_ARCH),ARM)
    ANDROID_ARCH_NAME   = armeabi-v7a
endif
ifeq ($(ANDROID_ARCH),ARM64)
    ANDROID_ARCH_NAME   = arm64-v8a
endif
ifeq ($(ANDROID_ARCH),x86)
    ANDROID_ARCH_NAME   = x86
endif
ifeq ($(ANDROID_ARCH),x86_64)
    ANDROID_ARCH_NAME   = x86_64
endif

# Required path variables
# NOTE: JAVA_HOME must be set to JDK (using OpenJDK 13)
JAVA_HOME              ?= C:/open-jdk
ANDROID_HOME           ?= C:/android-sdk
ANDROID_BUILD_TOOLS    ?= $(ANDROID_HOME)/build-tools/29.0.3
ANDROID_PLATFORM_TOOLS  = $(ANDROID_HOME)/platform-tools

# Android project configuration variables
PROJECT_NAME           ?= raylib_game
PROJECT_LIBRARY_NAME   ?= main
PROJECT_BUILD_ID       ?= android
PROJECT_BUILD_PATH     ?= $(PROJECT_BUILD_ID).$(PROJECT_NAME)
PROJECT_RESOURCES_PATH ?= resources
PROJECT_SOURCE_FILES   ?= raylib_game.c
NATIVE_APP_GLUE_PATH    = $(ANDROID_NDK)/sources/android/native_app_glue

# Some source files are placed in directories, when compiling to some 
# output directory other than source, that directory must pre-exist.
# Here we get a list of required folders that need to be created on
# code output folder $(PROJECT_BUILD_PATH)\obj to avoid GCC errors.
PROJECT_SOURCE_DIRS     = $(sort $(dir $(PROJECT_SOURCE_FILES)))

# Android app configuration variables
APP_LABEL_NAME         ?= rGame
APP_COMPANY_NAME       ?= raylib
APP_PRODUCT_NAME       ?= rgame
APP_VERSION_CODE       ?= 1
APP_VERSION_NAME       ?= 1.0
APP_ICON_LDPI          ?= $(RAYLIB_PATH)/logo/raylib_36x36.png
APP_ICON_MDPI          ?= $(RAYLIB_PATH)/logo/raylib_48x48.png
APP_ICON_HDPI          ?= $(RAYLIB_PATH)/logo/raylib_72x72.png
APP_SCREEN_ORIENTATION ?= landscape
APP_KEYSTORE_PASS      ?= raylib

# Library type used for raylib: STATIC (.a) or SHARED (.so/.dll)
RAYLIB_LIBTYPE         ?= STATIC

# Library path for libraylib.a/libraylib.so
RAYLIB_LIB_PATH         = $(RAYLIB_PATH)/src

# Define copy command depending on OS
ifeq ($(OS),Windows_NT)
    COPY_COMMAND ?= copy /Y
else
    COPY_COMMAND ?= cp -f
endif

# Shared libs must be added to APK if required
# NOTE: Generated NativeLoader.java automatically load those libraries
ifeq ($(RAYLIB_LIBTYPE),SHARED)
    PROJECT_SHARED_LIBS = lib/$(ANDROID_ARCH_NAME)/libraylib.so 
endif

# Compiler and archiver
ifeq ($(ANDROID_ARCH),ARM)
    CC = $(ANDROID_TOOLCHAIN)/bin/armv7a-linux-androideabi$(ANDROID_API_VERSION)-clang
    AR = $(ANDROID_TOOLCHAIN)/bin/arm-linux-androideabi-ar
endif
ifeq ($(ANDROID_ARCH),ARM64)
    CC = $(ANDROID_TOOLCHAIN)/bin/aarch64-linux-android$(ANDROID_API_VERSION)-clang
    AR = $(ANDROID_TOOLCHAIN)/bin/aarch64-linux-android-ar
endif
ifeq ($(ANDROID_ARCH),x86)
    CC = $(ANDROID_TOOLCHAIN)/bin/i686-linux-android$(ANDROID_API_VERSION)-clang
    AR = $(ANDROID_TOOLCHAIN)/bin/i686-linux-android-ar
endif
ifeq ($(ANDROID_ARCH),x86_64)
    CC = $(ANDROID_TOOLCHAIN)/bin/x86_64-linux-android$(ANDROID_API_VERSION)-clang
    AR = $(ANDROID_TOOLCHAIN)/bin/x86_64-linux-android-ar
endif

# Compiler flags for arquitecture
ifeq ($(ANDROID_ARCH),ARM)
    CFLAGS = -std=c99 -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16
endif
ifeq ($(ANDROID_ARCH),ARM64)
    CFLAGS = -std=c99 -target aarch64 -mfix-cortex-a53-835769
endif
# Compilation functions attributes options
CFLAGS += -ffunction-sections -funwind-tables -fstack-protector-strong -fPIC
# Compiler options for the linker
CFLAGS += -Wall -Wa,--noexecstack -Wformat -Werror=format-security -no-canonical-prefixes
# Preprocessor macro definitions
CFLAGS += -DANDROID -DPLATFORM_ANDROID -D__ANDROID_API__=$(ANDROID_API_VERSION)

# Paths containing required header files
INCLUDE_PATHS = -I. -I$(RAYLIB_PATH)/src -I$(NATIVE_APP_GLUE_PATH)

# Linker options
LDFLAGS = -Wl,-soname,lib$(PROJECT_LIBRARY_NAME).so -Wl,--exclude-libs,libatomic.a 
LDFLAGS += -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -Wl,--fatal-warnings 
# Force linking of library module to define symbol
LDFLAGS += -u ANativeActivity_onCreate
# Library paths containing required libs
LDFLAGS += -L. -L$(PROJECT_BUILD_PATH)/obj -L$(PROJECT_BUILD_PATH)/lib/$(ANDROID_ARCH_NAME) -L$(ANDROID_TOOLCHAIN)\sysroot\usr\lib

# Define any libraries to link into executable
# if you want to link libraries (libname.so or libname.a), use the -lname
LDLIBS = -lm -lc -lraylib -llog -landroid -lEGL -lGLESv2 -lOpenSLES -ldl

# Generate target objects list from PROJECT_SOURCE_FILES
OBJS = $(patsubst %.c, $(PROJECT_BUILD_PATH)/obj/%.o, $(PROJECT_SOURCE_FILES))

# Android APK building process... some steps required...
# NOTE: typing 'make' will invoke the default target entry called 'all'
# TODO: Use apksigner for APK signing, jarsigner is not recommended
all: create_temp_project_dirs \
     copy_project_required_libs \
     copy_project_resources \
     generate_loader_script \
     generate_android_manifest \
     generate_apk_keystore \
     config_project_package \
     compile_project_code \
     compile_project_class \
     compile_project_class_dex \
     create_project_apk_package \
     sign_project_apk_package \
     zipalign_project_apk_package

# WARNING: About build signing process:
#  - If using apksigner, zipalign must be used before the APK file has been signed.
#  - If using jarsigner (not recommended), zipalign must be used after the APK file has been signed.
# REF: https://developer.android.com/tools/zipalign
# REF: https://developer.android.com/tools/apksigner

# Create required temp directories for APK building
create_temp_project_dirs:
ifeq ($(OS),Windows_NT)
	if not exist $(PROJECT_BUILD_PATH) mkdir $(PROJECT_BUILD_PATH) 
	if not exist $(PROJECT_BUILD_PATH)\obj mkdir $(PROJECT_BUILD_PATH)\obj
	if not exist $(PROJECT_BUILD_PATH)\obj mkdir $(PROJECT_BUILD_PATH)\obj\src
	if not exist $(PROJECT_BUILD_PATH)\src mkdir $(PROJECT_BUILD_PATH)\src
	if not exist $(PROJECT_BUILD_PATH)\src\com mkdir $(PROJECT_BUILD_PATH)\src\com
	if not exist $(PROJECT_BUILD_PATH)\src\com\$(APP_COMPANY_NAME) mkdir $(PROJECT_BUILD_PATH)\src\com\$(APP_COMPANY_NAME)
	if not exist $(PROJECT_BUILD_PATH)\src\com\$(APP_COMPANY_NAME)\$(APP_PRODUCT_NAME) mkdir $(PROJECT_BUILD_PATH)\src\com\$(APP_COMPANY_NAME)\$(APP_PRODUCT_NAME)
	if not exist $(PROJECT_BUILD_PATH)\lib mkdir $(PROJECT_BUILD_PATH)\lib
	if not exist $(PROJECT_BUILD_PATH)\lib\$(ANDROID_ARCH_NAME) mkdir $(PROJECT_BUILD_PATH)\lib\$(ANDROID_ARCH_NAME)
	if not exist $(PROJECT_BUILD_PATH)\bin mkdir $(PROJECT_BUILD_PATH)\bin
	if not exist $(PROJECT_BUILD_PATH)\res mkdir $(PROJECT_BUILD_PATH)\res
	if not exist $(PROJECT_BUILD_PATH)\res\drawable-ldpi mkdir $(PROJECT_BUILD_PATH)\res\drawable-ldpi
	if not exist $(PROJECT_BUILD_PATH)\res\drawable-mdpi mkdir $(PROJECT_BUILD_PATH)\res\drawable-mdpi
	if not exist $(PROJECT_BUILD_PATH)\res\drawable-hdpi mkdir $(PROJECT_BUILD_PATH)\res\drawable-hdpi
	if not exist $(PROJECT_BUILD_PATH)\res\values mkdir $(PROJECT_BUILD_PATH)\res\values
	if not exist $(PROJECT_BUILD_PATH)\assets mkdir $(PROJECT_BUILD_PATH)\assets
	if not exist $(PROJECT_BUILD_PATH)\assets\$(PROJECT_RESOURCES_PATH) mkdir $(PROJECT_BUILD_PATH)\assets\$(PROJECT_RESOURCES_PATH)
	if not exist $(PROJECT_BUILD_PATH)\obj\screens mkdir $(PROJECT_BUILD_PATH)\obj\screens
else	
	mkdir -p $(PROJECT_BUILD_PATH) 
	mkdir -p $(PROJECT_BUILD_PATH)/obj
	mkdir -p $(PROJECT_BUILD_PATH)/obj/src
	mkdir -p $(PROJECT_BUILD_PATH)/src
	mkdir -p $(PROJECT_BUILD_PATH)/src/com
	mkdir -p $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)
	mkdir -p $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)
	mkdir -p $(PROJECT_BUILD_PATH)/lib
	mkdir -p $(PROJECT_BUILD_PATH)/lib/$(ANDROID_ARCH_NAME)
	mkdir -p $(PROJECT_BUILD_PATH)/bin
	mkdir -p $(PROJECT_BUILD_PATH)/res
	mkdir -p $(PROJECT_BUILD_PATH)/res/drawable-ldpi
	mkdir -p $(PROJECT_BUILD_PATH)/res/drawable-mdpi
	mkdir -p $(PROJECT_BUILD_PATH)/res/drawable-hdpi
	mkdir -p $(PROJECT_BUILD_PATH)/res/values
	mkdir -p $(PROJECT_BUILD_PATH)/assets
	mkdir -p $(PROJECT_BUILD_PATH)/assets/$(PROJECT_RESOURCES_PATH)
	mkdir -p $(PROJECT_BUILD_PATH)/obj/screens
endif
	$(foreach dir, $(PROJECT_SOURCE_DIRS), $(call create_dir, $(dir)))

define create_dir
    mkdir -p $(PROJECT_BUILD_PATH)/obj/$(1)
endef
    
# Copy required shared libs for integration into APK
# NOTE: If using shared libs they are loaded by generated NativeLoader.java
copy_project_required_libs:
ifeq ($(RAYLIB_LIBTYPE),SHARED)
	$(COPY_COMMAND) $(RAYLIB_LIB_PATH)/libraylib.so $(PROJECT_BUILD_PATH)/lib/$(ANDROID_ARCH_NAME)/libraylib.so 
endif
ifeq ($(RAYLIB_LIBTYPE),STATIC)
	$(COPY_COMMAND) $(RAYLIB_LIB_PATH)/libraylib.a $(PROJECT_BUILD_PATH)/lib/$(ANDROID_ARCH_NAME)/libraylib.a 
endif

# Copy project required resources: strings.xml, icon.png, assets
# NOTE: Required strings.xml is generated and game resources are copied to assets folder
copy_project_resources:
	$(COPY_COMMAND) $(APP_ICON_LDPI) $(PROJECT_BUILD_PATH)/res/drawable-ldpi/icon.png
	$(COPY_COMMAND) $(APP_ICON_MDPI) $(PROJECT_BUILD_PATH)/res/drawable-mdpi/icon.png
	$(COPY_COMMAND) $(APP_ICON_HDPI) $(PROJECT_BUILD_PATH)/res/drawable-hdpi/icon.png
ifeq ($(OS),Windows_NT)
	@echo ^<?xml version="1.0" encoding="utf-8"^?^> > $(PROJECT_BUILD_PATH)/res/values/strings.xml
	@echo ^<resources^>^<string name="app_name"^>$(APP_LABEL_NAME)^</string^>^</resources^> >> $(PROJECT_BUILD_PATH)/res/values/strings.xml
	if exist $(PROJECT_RESOURCES_PATH) C:\Windows\System32\xcopy $(PROJECT_RESOURCES_PATH) $(PROJECT_BUILD_PATH)\assets\$(PROJECT_RESOURCES_PATH) /Y /E /F
else
	@echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $(PROJECT_BUILD_PATH)/res/values/strings.xml 
	@echo "<resources><string name=\"app_name\">$(APP_LABEL_NAME)</string></resources>" >> $(PROJECT_BUILD_PATH)/res/values/strings.xml
	@[ -d "$(PROJECT_RESOURCES_PATH)" ] || cp -rf $(PROJECT_RESOURCES_PATH) $(PROJECT_BUILD_PATH)/assets/$(PROJECT_RESOURCES_PATH)	
endif

# Generate NativeLoader.java to load required shared libraries
# NOTE: Probably not the bet way to generate this file... but it works.
generate_loader_script:
ifeq ($(OS),Windows_NT)
	@echo package com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME); > $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo. >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo public class NativeLoader extends android.app.NativeActivity { >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo     static { >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
ifeq ($(RAYLIB_LIBTYPE),SHARED)
	@echo         System.loadLibrary("raylib"); >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
endif
	@echo         System.loadLibrary("$(PROJECT_LIBRARY_NAME)"); >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java 
	@echo     } >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo } >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
else	
	@echo "package com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME);" > $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo "" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo "public class NativeLoader extends android.app.NativeActivity {" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo "    static {" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
ifeq ($(RAYLIB_LIBTYPE),SHARED)
	@echo "       System.loadLibrary(\"raylib\");" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
endif
	@echo "        System.loadLibrary(\"$(PROJECT_LIBRARY_NAME)\");" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java 
	@echo "    }" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
	@echo "}" >> $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java
endif

# Generate AndroidManifest.xml with all the required options
# NOTE: Probably not the bet way to generate this file... but it works.
generate_android_manifest:
ifeq ($(OS),Windows_NT)
	@echo ^<?xml version="1.0" encoding="utf-8"^?^> > $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo         package="com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME)"  >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo         android:versionCode="$(APP_VERSION_CODE)" android:versionName="$(APP_VERSION_NAME)" ^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo     ^<uses-sdk android:minSdkVersion="$(ANDROID_API_VERSION)" /^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo     ^<uses-feature android:glEsVersion="0x00020000" android:required="true" /^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo     ^<application android:allowBackup="false" android:label="@string/app_name" android:icon="@drawable/icon" ^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo         ^<activity android:name="com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME).NativeLoader" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             android:theme="@android:style/Theme.NoTitleBar.Fullscreen" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             android:configChanges="orientation|keyboardHidden|screenSize" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             android:screenOrientation="$(APP_SCREEN_ORIENTATION)" android:launchMode="singleTask" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             android:clearTaskOnLaunch="true"^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             ^<meta-data android:name="android.app.lib_name" android:value="$(PROJECT_LIBRARY_NAME)" /^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             ^<intent-filter^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo                 ^<action android:name="android.intent.action.MAIN" /^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo                 ^<category android:name="android.intent.category.LAUNCHER" /^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo             ^</intent-filter^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo         ^</activity^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo     ^</application^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo ^</manifest^> >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
else
	@echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "        package=\"com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME)\" " >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "        android:versionCode=\"$(APP_VERSION_CODE)\" android:versionName=\"$(APP_VERSION_NAME)\" >" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "    <uses-sdk android:minSdkVersion=\"$(ANDROID_API_VERSION)\" />" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "    <uses-feature android:glEsVersion=\"0x00020000\" android:required=\"true\" />" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "    <application android:allowBackup=\"false\" android:label=\"@string/app_name\" android:icon=\"@drawable/icon\" >" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "        <activity android:name=\"com.$(APP_COMPANY_NAME).$(APP_PRODUCT_NAME).NativeLoader\"" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            android:theme=\"@android:style/Theme.NoTitleBar.Fullscreen\"" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "             android:configChanges=\"orientation|keyboardHidden|screenSize\"" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            android:screenOrientation=\"$(APP_SCREEN_ORIENTATION)\" android:launchMode=\"singleTask\"" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            android:clearTaskOnLaunch=\"true\">" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            <meta-data android:name=\"android.app.lib_name\" android:value=\"$(PROJECT_LIBRARY_NAME)\" />" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            <intent-filter>" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "                <action android:name=\"android.intent.action.MAIN\" />" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "                <category android:name=\"android.intent.category.LAUNCHER\" />" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "            </intent-filter>" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "        </activity>" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "    </application>" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
	@echo "</manifest>" >> $(PROJECT_BUILD_PATH)/AndroidManifest.xml
endif

# Generate storekey for APK signing: $(PROJECT_NAME).keystore
# NOTE: Configure here your Distinguished Names (-dname) if required!
generate_apk_keystore: 
ifeq ($(OS),Windows_NT)
	if not exist $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).keystore $(JAVA_HOME)/bin/keytool -genkeypair -validity 10000 -dname "CN=$(APP_COMPANY_NAME),O=Android,C=ES" -keystore $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).keystore -storepass $(APP_KEYSTORE_PASS) -keypass $(APP_KEYSTORE_PASS) -alias $(PROJECT_NAME)Key -keyalg RSA
else
	@[ -f "$(PROJECT_BUILD_PATH)/$(PROJECT_NAME).keystore" ] || $(JAVA_HOME)/bin/keytool -genkeypair -validity 10000 -dname "CN=$(APP_COMPANY_NAME),O=Android,C=ES" -keystore $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).keystore -storepass $(APP_KEYSTORE_PASS) -keypass $(APP_KEYSTORE_PASS) -alias $(PROJECT_NAME)Key -keyalg RSA
endif

# Config project package and resource using AndroidManifest.xml and res/values/strings.xml
# NOTE: Generates resources file: src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/R.java
config_project_package:
	$(ANDROID_BUILD_TOOLS)/aapt package -f -m -S $(PROJECT_BUILD_PATH)/res -J $(PROJECT_BUILD_PATH)/src -M $(PROJECT_BUILD_PATH)/AndroidManifest.xml -I $(ANDROID_HOME)/platforms/android-$(ANDROID_API_VERSION)/android.jar

# Compile native_app_glue code as static library: obj/libnative_app_glue.a
compile_native_app_glue:
	$(CC) -c $(NATIVE_APP_GLUE_PATH)/android_native_app_glue.c -o $(PROJECT_BUILD_PATH)/obj/native_app_glue.o $(CFLAGS)
	$(AR) rcs $(PROJECT_BUILD_PATH)/obj/libnative_app_glue.a $(PROJECT_BUILD_PATH)/obj/native_app_glue.o

# Compile project code into a shared library: lib/lib$(PROJECT_LIBRARY_NAME).so 
compile_project_code: $(OBJS)
	$(CC) -o $(PROJECT_BUILD_PATH)/lib/$(ANDROID_ARCH_NAME)/lib$(PROJECT_LIBRARY_NAME).so $(OBJS) -shared $(INCLUDE_PATHS) $(LDFLAGS) $(LDLIBS)

# Compile all .c files required into object (.o) files
# NOTE: Those files will be linked into a shared library
$(PROJECT_BUILD_PATH)/obj/%.o:%.c
	$(CC) -c $^ -o $@ $(INCLUDE_PATHS) $(CFLAGS) --sysroot=$(ANDROID_TOOLCHAIN)/sysroot 
    
# Compile project .java code into .class (Java bytecode) 
compile_project_class:
	$(JAVA_HOME)/bin/javac -verbose -source 1.7 -target 1.7 -d $(PROJECT_BUILD_PATH)/obj -bootclasspath $(JAVA_HOME)/jre/lib/rt.jar -classpath $(ANDROID_HOME)/platforms/android-$(ANDROID_API_VERSION)/android.jar -d $(PROJECT_BUILD_PATH)/obj $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/R.java $(PROJECT_BUILD_PATH)/src/com/$(APP_COMPANY_NAME)/$(APP_PRODUCT_NAME)/NativeLoader.java

# Compile .class files into Dalvik executable bytecode (.dex)
# NOTE: Since Android 5.0, Dalvik interpreter (JIT) has been replaced by ART (AOT)
compile_project_class_dex:
	$(ANDROID_BUILD_TOOLS)/dx --verbose --dex --output=$(PROJECT_BUILD_PATH)/bin/classes.dex $(PROJECT_BUILD_PATH)/obj

# Create Android APK package: bin/$(PROJECT_NAME).unsigned.apk
# NOTE: Requires compiled classes.dex and lib$(PROJECT_LIBRARY_NAME).so
# NOTE: Use -A resources to define additional directory in which to find raw asset files
create_project_apk_package:
	$(ANDROID_BUILD_TOOLS)/aapt package -f -M $(PROJECT_BUILD_PATH)/AndroidManifest.xml -S $(PROJECT_BUILD_PATH)/res -A $(PROJECT_BUILD_PATH)/assets -I $(ANDROID_HOME)/platforms/android-$(ANDROID_API_VERSION)/android.jar -F $(PROJECT_BUILD_PATH)/bin/$(PROJECT_NAME).unsigned.apk $(PROJECT_BUILD_PATH)/bin
	cd $(PROJECT_BUILD_PATH) && $(ANDROID_BUILD_TOOLS)/aapt add bin/$(PROJECT_NAME).unsigned.apk lib/$(ANDROID_ARCH_NAME)/lib$(PROJECT_LIBRARY_NAME).so $(PROJECT_SHARED_LIBS)

# Create signed APK package using generated Key: bin/$(PROJECT_NAME).signed.apk 
sign_project_apk_package:
	$(JAVA_HOME)/bin/jarsigner -keystore $(PROJECT_BUILD_PATH)/$(PROJECT_NAME).keystore -storepass $(APP_KEYSTORE_PASS) -keypass $(APP_KEYSTORE_PASS) -signedjar $(PROJECT_BUILD_PATH)/bin/$(PROJECT_NAME).signed.apk $(PROJECT_BUILD_PATH)/bin/$(PROJECT_NAME).unsigned.apk $(PROJECT_NAME)Key

# Create zip-aligned APK package: $(PROJECT_NAME).apk 
zipalign_project_apk_package:
	$(ANDROID_BUILD_TOOLS)/zipalign -f 4 $(PROJECT_BUILD_PATH)/bin/$(PROJECT_NAME).signed.apk $(PROJECT_NAME).apk

# Install $(PROJECT_NAME).apk to default emulator/device
# NOTE: Use -e (emulator) or -d (device) parameters if required
install:
	$(ANDROID_PLATFORM_TOOLS)/adb install $(PROJECT_NAME).apk
    
# Check supported ABI for the device (armeabi-v7a, arm64-v8a, x86, x86_64)
check_device_abi:
	$(ANDROID_PLATFORM_TOOLS)/adb shell getprop ro.product.cpu.abi

# Monitorize output log coming from device, only raylib tag
logcat:
	$(ANDROID_PLATFORM_TOOLS)/adb logcat -c
	$(ANDROID_PLATFORM_TOOLS)/adb logcat raylib:V *:S
    
# Install and monitorize $(PROJECT_NAME).apk to default emulator/device
deploy:
	$(ANDROID_PLATFORM_TOOLS)/adb install $(PROJECT_NAME).apk
	$(ANDROID_PLATFORM_TOOLS)/adb logcat -c
	$(ANDROID_PLATFORM_TOOLS)/adb logcat raylib:V *:S

#$(ANDROID_PLATFORM_TOOLS)/adb logcat *:W

# Clean everything
clean:
ifeq ($(OS),Windows_NT)
	del $(PROJECT_BUILD_PATH)\* /f /s /q
	rmdir $(PROJECT_BUILD_PATH) /s /q
else
	rm -r $(PROJECT_BUILD_PATH)
endif
	@echo Cleaning done