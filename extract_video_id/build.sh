#!/bin/sh
echo '0-start'
SOURCE=ru/kx13/extractvidid
BASE=/usr/lib
SDK="${BASE}/android-sdk"
BUILD_TOOLS="${SDK}/build-tools/29.0.3"
PLATFORM="${SDK}/platform-tools"
mkdir -p build/gen build/obj build/apk

echo '1----'

"${BUILD_TOOLS}/aapt" package -f -m -J build/gen/ -S res -M AndroidManifest.xml -I "${PLATFORM}/android.jar"

echo '2----'

javac -source 1.7 -target 1.7 -bootclasspath "${JAVA_HOME}/jre/lib/rt.jar" \
		 -classpath "${PLATFORM}/android.jar" -d build/obj \
		 build/gen/${SOURCE}/R.java java/${SOURCE}/MainActivity.java

echo '3----'

"${BUILD_TOOLS}/dx" --dex --output=build/apk/classes.dex build/obj/

echo '4----'

"${BUILD_TOOLS}/aapt" package -f -M AndroidManifest.xml -S res/  -I "${PLATFORM}/android.jar" \
		-F build/Extractor.unsigned.apk build/apk/

echo '5----'

"${BUILD_TOOLS}/zipalign" -f 4 build/Extractor.unsigned.apk build/Extractor.aligned.apk

echo '6----'

apksigner sign --ks keystore.jks \
        --ks-key-alias androidkey --ks-pass pass:android \
		--key-pass pass:android --out build/Extractor.apk \
		 build/Extractor.aligned.apk

echo '7-end'
