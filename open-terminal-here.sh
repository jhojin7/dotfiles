#!/bin/bash
# https://www.google.com/search?q=%EB%A7%A5+%ED%8C%8C%EC%9D%B8%EB%8D%94+%EC%9A%B0%ED%81%B4%EB%A6%AD+open+in+xxx+%EB%A9%94%EB%89%B4+%EB%84%A3%EA%B8%B0&fbs=ADc_l-aN0CWEZBOHjofHoaMMDiKpaEWjvZ2Py1XXV8d8KvlI3p-ML-906rRL_m6h4jR-tdAeyw6pOVABma0FfM0NmtARdcuGnZVoiSrEQCt2b10nLvZ0LhSQsg9u5oWDBvgT9QLe3UlVQUDJFLkMg_4LK00caA_hrDaanLJZIWatkXHLiFTe967Gh5z8lh_o--IXUvztv2Ic1whN8_2dcXuq7Cz5Mb2zDg&aep=10&ntc=1&mstk=AUtExfDIr75w_EvcQvGABxP7Ike8JoRsoKWfz48WN4mJhxSZXGJoQkuV29K064dzrje66v7D49O_z4hxN57_bR_GYImhYhPzgxZBDvFC0MOVXLc7lEzUHwgCHq1ZEPfl1QuAcD3U8qJCAiFUKsQ83iHaTMFxVF6X4L_lua7Bi2XriB8RuA0R4iKv-OoWLiRgi__4NRqkigUQ4cg_C3vWxug2oz_agI8ECQRLlyuKdHRQrrZyzdbj2CotljDNPbnFbBPrnp4nZBzWLBRDGKLykhvSrty7msGPEt0b3hL52nGYUtGtF3agP2WRDFFGzaojs5vFFr_WkcxCGOC91Q&aioh=3&csuir=1&mtid=GWEEav3SLL7n2roP27_twA4&udm=50
# 💡 추가되는 유용 기능 3가지여기서 터미널 열기 (Open Terminal Here): 선택한 폴더 경로로 터미널을 즉시 실행합니다.선택 항목 경로 복사 (Copy Path): 파일이나 폴더의 절대 경로를 클립보드에 바로 복사합니다.영구 삭제 (Delete Permanently): 휴지통을 거치지 않고 선택한 파일을 즉시 완전히 삭제합니다.

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# 기존 불필요한 Cursor 메뉴 삭제
rm -rf "$SERVICES_DIR/Open in Cursor.workflow"

# 공통 템플릿 생성 함수
create_workflow() {
    local menu_name="$1"
    local shell_script="$2"
    local target_dir="$SERVICES_DIR/${menu_name}.workflow"
    
    rm -rf "$target_dir"
    mkdir -p "$target_dir/Contents"

    # Info.plist
    cat <<EOF > "$target_dir/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "apple.com">
<plist version="1.0"><dict>
<key>NSServices</key><array><dict>
<key>NSBackgroundColorName</key><string>background</string>
<key>NSIconName</key><string>NSActionTemplate</string>
<key>NSMenuItem</key><dict><key>default</key><string>${menu_name}</string></dict>
<key>NSMessage</key><string>runWorkflowAsService</string>
<key>NSRequiredContext</key><dict><key>NSApplicationIdentifier</key><string>com.apple.finder</string></dict>
<key>NSReturnTypes</key><array/>
<key>NSSendTypes</key><array><string>public.item</string></array>
</dict></array></dict></plist>
EOF

    # document.wflow
    cat <<EOF > "$target_dir/Contents/document.wflow"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "apple.com">
<plist version="1.0"><dict>
<key>actions</key><array><dict><key>action</key><dict>
<key>ActionBundlePath</key><string>/System/Library/Automator/Run Shell Script.action</string>
<key>ActionName</key><string>Run Shell Script</string>
<key>ActionParameters</key><dict>
<key>COMMAND_STRING</key><string>${shell_script}</string>
<key>inputMethod</key><integer>1</integer>
<key>shell</key><string>/bin/zsh</string>
</dict>
</dict></dict></array>
<key>workflowMetaData</key><dict>
<key>inputTypeIdentifier</key><string>com.apple.Automator.fileSystemObject</string>
<key>outputTypeIdentifier</key><string>com.apple.Automator.nothing</string>
<key>presentationMode</key><integer>15</integer>
<key>serviceApplicationBundleID</key><string>com.apple.finder</string>
<key>serviceApplicationPath</key><string>/System/Library/CoreServices/Finder.app</string>
<key>serviceInputTypeIdentifier</key><string>com.apple.Automator.fileSystemObject</string>
<key>serviceOutputTypeIdentifier</key><string>com.apple.Automator.nothing</string>
<key>workflowTypeIdentifier</key><string>com.apple.Automator.servicesMenu</string>
</dict></dict></plist>
EOF
    echo "✅ 생성 완료: ${menu_name}"
}

# 1. 여기서 터미널 열기 스크립트
script_terminal='for f in "$@"; do
    if [ -d "$f" ]; then
        open -a Terminal "$f"
    else
        open -a Terminal "$(dirname "$f")"
    fi
done'
create_workflow "여기서 터미널 열기" "$script_terminal"

# 2. 경로 복사 스크립트
script_copy_path='paths=""
for f in "$@"; do
    paths+="$f"$'\n'
done
echo -n "${paths%?}" | pbcopy'
create_workflow "선택 항목 경로 복사" "$script_copy_path"

# 3. 영구 삭제 스크립트
script_delete='osascript -e "display dialog \"선택한 파일을 완전히 삭제하시겠습니까? (휴지통을 거치지 않음)\" buttons {\"취소\", \"삭제\"} default button \"취소\" with icon caution"
if [ $? -eq 0 ]; then
    for f in "$@"; do
        rm -rf "$f"
    done
fi'
create_workflow "영구 삭제" "$script_delete"

# 캐시 리셋 및 Finder 재시작
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
killall Finder
echo "🎉 추가 기능 설정이 완료되었습니다!"

