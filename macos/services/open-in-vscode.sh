#!/bin/bash


# '''
# https://share.google/aimode/wCyZuZ6TjP1AM7gXW
#macOS의 우클릭 '빠른 동작(Quick Action)' 메뉴는 내부적으로 ~/Library/Services/ 경로에 .workflow 패키지(폴더 형태)로 저장됩니다.터미널을 열고 아래 스크립트 전체를 복사하여 붙여넣으면 'Open in VS Code'와 'Open in Cursor' 메뉴가 Finder 우클릭에 즉시 자동 생성됩니다.
# 2. 사용 방법터미널(Terminal.app)을 실행합니다.위 스크립트 블록 전체를 복사(Cmd + C)한 뒤 터미널 창에 붙여넣고(Cmd + V) 엔터를 누릅니다.스크립트 실행이 끝나면 Finder가 자동으로 껐다 켜지며 바로 적용됩니다.파일이나 폴더를 우클릭한 뒤 [빠른 동작] 메뉴에 진입하면 Open in VS Code 또는 Open in Cursor가 표시됩니다.만약 다른 앱(예: PyCharm 등)을 추가하고 싶다면 스크립트 하단의 create_quick_action "메뉴이름" "애플리케이션이름" 구조를 수정하여 터미널에 재실행하면 됩니다.혹시 VS Code나 Cursor 외에 추가하고 싶은 다른 특정 앱이 있거나, 단축키 지정 방법이 궁금하시면 말씀해 주세요!
#

# 1. 빠른 동작 저장 경로 생성
SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# 2. 빠른 동작 생성을 위한 공통 함수 정의
create_quick_action() {
    local menu_name="$1"
    local app_name="$2"
    local target_dir="$SERVICES_DIR/${menu_name}.workflow"
    local plist_path="$target_dir/Contents/Info.plist"
    local script_path="$target_dir/Contents/document.wflow"

    # 기존 동일 명칭 메뉴 삭제 후 초기화
    rm -rf "$target_dir"
    mkdir -p "$target_dir/Contents"

    # Info.plist 기본 메타데이터 생성
    cat <<EOF > "$plist_path"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "apple.com">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSBackgroundColorName</key>
            <string>background</string>
            <key>NSIconName</key>
            <string>NSActionTemplate</string>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>${menu_name}</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>
            <key>NSReturnTypes</key>
            <array/>
            <key>NSSendTypes</key>
            <array>
                <string>public.item</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

    # 우클릭 시 선택한 파일/폴더를 지정 앱으로 여는 워크플로우 엔진 작성
    cat <<EOF > "$script_path"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "apple.com">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>521</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.string</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <dict/>
                    <key>CheckedForUserDefaultShell</key>
                    <dict/>
                    <key>inputMethod</key>
                    <dict/>
                    <key>shell</key>
                    <dict/>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.string</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>for f in "\$@"
do
    open -a "${app_name}" "\$f"
done</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/zsh</string>
                    <key>source</key>
                    <string></string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.Automator.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>Category</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
                <key>InputUUID</key>
                <string>INPUT_UUID_PLACEHOLDER</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                </array>
                <key>OutputUUID</key>
                <string>OUTPUT_UUID_PLACEHOLDER</string>
                <key>UUID</key>
                <string>ACTION_UUID_PLACEHOLDER</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>arguments</key>
                <dict>
                    <key>0</key>
                    <dict>
                        <key>default value</key>
                        <integer>0</integer>
                        <key>name</key>
                        <string>inputMethod</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                    </dict>
                    <key>1</key>
                    <dict>
                        <key>default value</key>
                        <false/>
                        <key>name</key>
                        <string>CheckedForUserDefaultShell</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                    </dict>
                    <key>2</key>
                    <dict>
                        <key>default value</key>
                        <string></string>
                        <key>name</key>
                        <string>source</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                    </dict>
                    <key>3</key>
                    <dict>
                        <key>default value</key>
                        <string></string>
                        <key>name</key>
                        <string>COMMAND_STRING</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                    </dict>
                    <key>4</key>
                    <dict>
                        <key>default value</key>
                        <string>/bin/sh</string>
                        <key>name</key>
                        <string>shell</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                    </dict>
                </dict>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>applicationBundleIDsByPath</key>
        <dict/>
        <key>applicationPaths</key>
        <array/>
        <key>inputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>outputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>presentationMode</key>
        <integer>15</integer>
        <key>processesInput</key>
        <false/>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>serviceApplicationPath</key>
        <string>/System/Library/CoreServices/Finder.app</string>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <false/>
        <key>systemImageName</key>
        <string>NSActionTemplate</string>
        <key>useAutomaticInputType</key>
        <false/>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

    echo "✅ 생성 완료: '${menu_name}' (대상 앱: ${app_name})"
}

# 3. 메뉴 등록 실행 (원하는 앱 이름으로 변경 가능)
create_quick_action "Open in VS Code" "Visual Studio Code"
# create_quick_action "Open in Cursor" "Cursor"

# 4. Finder 캐시 갱신 및 재시작
echo "🔄 Finder 및 시스템 메뉴 캐시 갱신 중..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
killall Finder

echo "🎉 모든 작업이 완료되었습니다! Finder에서 파일/폴더를 우클릭하여 '빠른 동작'을 확인하세요."

