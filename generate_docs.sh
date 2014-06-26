#if [ ${CONFIGURATION} == "Release" ]; then
APPLEDOC_PATH=`which appledoc`
if [ $APPLEDOC_PATH ]; then
$APPLEDOC_PATH \
--project-name "Whisper-iOS-SDK" \
--project-company "Whisper" \
--company-id "sh.whisper" \
--output "Whisper-iOS-SDKDocs" \
--keep-undocumented-objects \
--keep-undocumented-members \
--ignore "*.m" \
--ignore AppDelegate.h \
--ignore ViewController.h  \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
./WhisperImageTest
fi;
#fi;
