# Windows Zed Config Path Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Windows에서 Zed 설정과 키맵을 `%APPDATA%\Zed`에 배치하고 macOS 및 Linux의 기존 경로를 유지한다.

**Architecture:** Zed 설정 본문을 `.chezmoitemplates`에 한 번만 보관하고 운영체제별 대상 파일은 해당 공통 템플릿을 호출한다. `.chezmoiignore`가 Windows와 비 Windows에서 반대쪽 대상만 제외하도록 한다.

**Tech Stack:** chezmoi templates, POSIX shell test harness, Git

## Global Constraints

- Windows 대상은 `AppData/Roaming/Zed/`이다.
- macOS 및 Linux 대상은 `.config/zed/`이다.
- `settings.json`과 `keymap.json`의 내용은 변경하지 않는다.
- Zed 확장 저장 위치는 변경하지 않는다.

---

### Task 1: 운영체제별 Zed 대상 경로와 공통 템플릿

**Files:**
- Modify: `tests/test_chezmoi.sh`
- Create: `home/.chezmoitemplates/zed-settings.json.tmpl`
- Create: `home/.chezmoitemplates/zed-keymap.json.tmpl`
- Modify: `home/dot_config/zed/settings.json.tmpl`
- Modify: `home/dot_config/zed/keymap.json.tmpl`
- Create: `home/AppData/Roaming/Zed/settings.json.tmpl`
- Create: `home/AppData/Roaming/Zed/keymap.json.tmpl`
- Modify: `home/.chezmoiignore`

**Interfaces:**
- Consumes: chezmoi의 `.chezmoitemplates`와 `template` 함수
- Produces: Windows의 `AppData/Roaming/Zed/{settings,keymap}.json` 및 비 Windows의 `.config/zed/{settings,keymap}.json`

- [ ] **Step 1: 실패하는 경로 회귀 테스트 작성**

`tests/test_chezmoi.sh`에서 Windows 관리 목록은 `AppData/Roaming/Zed/settings.json`과 `keymap.json`을 포함하고 `.config/zed`를 제외하도록 단언한다. macOS/Linux에는 반대 단언을 추가한다.

- [ ] **Step 2: 테스트 실패 확인**

Run: `sh tests/test_chezmoi.sh`

Expected: `관리 대상에 AppData/Roaming/Zed/settings.json 경로가 없습니다.`로 실패한다.

- [ ] **Step 3: 최소 경로 및 템플릿 구현**

기존 두 Zed 템플릿 본문을 `home/.chezmoitemplates/`로 옮기고 네 대상 파일은 각각 `{{ template "zed-settings.json.tmpl" . }}` 또는 `{{ template "zed-keymap.json.tmpl" . }}`만 호출한다. `.chezmoiignore`는 Windows에서 `.config/zed`, 비 Windows에서 `AppData/`를 제외한다.

- [ ] **Step 4: 전체 테스트 통과 확인**

Run: `sh tests/test_chezmoi.sh`

Expected: `플랫폼별 관리 대상 검증을 통과했습니다.`와 exit code 0.

- [ ] **Step 5: 실제 Windows 설정 적용 및 검증**

Run: `chezmoi diff --exclude=scripts`, `chezmoi apply --exclude=scripts --verbose`, `chezmoi status --exclude=scripts`

Expected: `%APPDATA%\Zed`의 두 파일이 공통 템플릿 내용으로 갱신되고 적용 후 관련 차이가 없다.

- [ ] **Step 6: 변경 커밋과 푸시**

Run: `git add <관련 파일>; git commit -m "fix: Windows Zed 설정 경로 수정"; git push origin main`

Expected: 로컬 `main`과 `origin/main`이 같은 커밋을 가리킨다.
