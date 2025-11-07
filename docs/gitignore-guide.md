# .gitignore 설정 가이드

GLP-1 MVP 프로젝트의 .gitignore 설정을 설명합니다.

## 주요 카테고리

### 1. Flutter/Dart 관련
```gitignore
# 빌드 아티팩트
/build/
.dart_tool/
.packages
.pub-cache/
.pub/

# Flutter 플러그인
.flutter-plugins
.flutter-plugins-dependencies
```

**이유**: 빌드 아티팩트와 의존성 캐시는 로컬 환경마다 다르므로 버전 관리 제외

### 2. 코드 생성 파일
```gitignore
*.g.dart
*.freezed.dart
*.gr.dart
*.config.dart
```

**이유**:
- Riverpod, Isar 등의 코드 생성 파일
- `build_runner`로 재생성 가능
- 병합 충돌 방지
- 리포지토리 크기 감소

**재생성 방법**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Isar 데이터베이스
```gitignore
*.isar
*.isar.lock
isar_inspector/
```

**이유**:
- 로컬 개발 DB 파일
- 개인 테스트 데이터 포함
- 각 개발자 환경마다 독립적으로 생성

### 4. Firebase 설정
```gitignore
**/firebase_options.dart
**/google-services.json
**/GoogleService-Info.plist
.firebase/
```

**이유**:
- API 키와 민감한 설정 정보 포함
- 환경별로 다른 설정 필요 (dev/staging/prod)

**관리 방법**:
1. Template 파일 생성
   ```dart
   // firebase_options.template.dart
   class DefaultFirebaseOptions {
     static const apiKey = 'YOUR_API_KEY';
     // ...
   }
   ```
2. 실제 파일은 별도 관리 (환경변수, 시크릿 매니저)

### 5. 환경 변수 & 시크릿
```gitignore
.env
.env.local
.env.*.local
secrets.json
credentials.json
*.pem
*.key
*.p12
**/key.properties
```

**이유**:
- OAuth 클라이언트 ID/Secret
- API 키
- 서명 키
- 민감한 설정 정보

**관리 방법**:
```bash
# .env.template 파일 제공
KAKAO_NATIVE_APP_KEY=your_key_here
NAVER_CLIENT_ID=your_id_here
NAVER_CLIENT_SECRET=your_secret_here
```

### 6. 테스트 커버리지
```gitignore
coverage/
test/.test_coverage.dart
.test_coverage.dart
lcov.info
```

**이유**:
- CI/CD에서 생성되는 리포트
- 로컬 개발 중 생성되는 임시 파일

**확인 방법**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 7. Patrol E2E
```gitignore
patrol_cli.log
.patrol/
```

**이유**:
- Patrol 테스트 실행 로그
- 임시 아티팩트

### 8. 플랫폼별 생성 파일

#### iOS
```gitignore
**/ios/**/Pods/
**/ios/**/xcuserdata
**/ios/Flutter/GeneratedPluginRegistrant.*
```

#### Android
```gitignore
**/android/.gradle
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.*
*.jks
*.keystore
```

#### macOS/Windows/Linux
```gitignore
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/windows/flutter/generated_plugin_registrant.cc
**/linux/flutter/generated_plugin_registrant.cc
```

### 9. 에디터 설정

#### VS Code (선택적 포함)
```gitignore
.vscode/*
!.vscode/settings.json      # 팀 공유 설정 포함
!.vscode/tasks.json         # 빌드 태스크 포함
!.vscode/launch.json        # 디버그 설정 포함
!.vscode/extensions.json    # 추천 확장 프로그램 포함
```

#### IntelliJ/Android Studio (제외)
```gitignore
.idea/
*.iml
```

## 버전 관리에 포함해야 하는 파일

### ✅ 포함
- `.metadata` - Flutter SDK 버전 추적
- `pubspec.yaml` - 의존성 정의
- `pubspec.lock` - 의존성 잠금
- `analysis_options.yaml` - Lint 규칙
- `build.yaml` - 코드 생성 설정
- `.vscode/` (선택사항) - 팀 공유 설정

### ❌ 제외
- 빌드 아티팩트 (`/build/`)
- 코드 생성 파일 (`*.g.dart`)
- 환경 변수 (`.env`)
- 시크릿 (`.key`, `.pem`)
- 로컬 DB (`.isar`)
- 커버리지 리포트 (`coverage/`)

## 보안 체크리스트

### 1. 커밋 전 확인
```bash
# Firebase 설정 파일 체크
git status | grep -E "(firebase_options|google-services|GoogleService-Info)"

# 환경 변수 체크
git status | grep -E "(.env|secrets.json|credentials.json)"

# 키 파일 체크
git status | grep -E "(.key|.pem|.p12|key.properties|.jks|.keystore)"
```

### 2. 이미 커밋된 민감 정보 제거
```bash
# Git 히스토리에서 완전 제거
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all

# 강제 푸시 (주의!)
git push origin --force --all
```

### 3. .gitignore 검증
```bash
# 무시되는 파일 확인
git status --ignored

# 특정 파일이 무시되는지 체크
git check-ignore -v path/to/file
```

## 문제 해결

### Q: 코드 생성 파일이 자꾸 변경으로 표시됩니다
```bash
# 이미 추적 중인 파일 제거
git rm --cached **/*.g.dart
git commit -m "chore: remove generated files from git"
```

### Q: .env 파일을 실수로 커밋했습니다
```bash
# 최신 커밋에서만 제거
git rm --cached .env
git commit --amend -m "chore: remove .env from git"

# 히스토리에서 완전 제거 (위 보안 체크리스트 참고)
```

### Q: Firebase 설정 파일 관리는 어떻게 하나요?
1. Template 파일 생성 및 커밋
2. CI/CD에서 환경별 실제 파일 주입
3. 로컬 개발: 시크릿 매니저 또는 안전한 저장소에서 복사

## CI/CD 설정

### GitHub Actions 예시
```yaml
- name: Setup Firebase Options
  run: |
    echo "${{ secrets.FIREBASE_OPTIONS }}" > lib/firebase_options.dart

- name: Setup Android Keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/keystore.jks
```

### 환경 변수 주입
```yaml
- name: Setup Environment
  run: |
    echo "KAKAO_NATIVE_APP_KEY=${{ secrets.KAKAO_KEY }}" >> .env
    echo "NAVER_CLIENT_ID=${{ secrets.NAVER_ID }}" >> .env
```

## 참고 자료

- [Flutter .gitignore 공식 가이드](https://docs.flutter.dev/get-started/install)
- [Git Secret Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase 보안 모범 사례](https://firebase.google.com/docs/projects/api-keys)
