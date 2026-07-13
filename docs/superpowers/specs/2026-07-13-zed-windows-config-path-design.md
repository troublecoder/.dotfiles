# Windows Zed 설정 경로 설계

## 목표

Zed 설정과 키맵을 운영체제별 실제 설정 경로에 배치한다.

- Windows: `AppData/Roaming/Zed/`
- macOS 및 Linux: `.config/zed/`

## 설계

`settings.json`과 `keymap.json`의 본문은 각각 chezmoi 공통 템플릿 한 곳에서 관리한다. 운영체제별 대상 파일은 공통 템플릿을 호출하는 얇은 파일로 두어 설정 내용이 중복되지 않게 한다.

Windows 대상 파일은 `home/AppData/Roaming/Zed/` 아래에 추가하고, 기존 `home/dot_config/zed/` 대상은 비 Windows에서만 적용한다. `.chezmoiignore`의 Windows 분기에서는 `AppData` 전체를 제외하지 않고 Zed 이외의 불필요한 AppData 항목을 계속 제외한다.

## 검증

- Windows의 `chezmoi target-path` 및 렌더링 결과가 `%APPDATA%\Zed`를 가리키는지 확인한다.
- Windows에서 `.config/zed`가 관리 대상에서 빠지는지 확인한다.
- 기존 테스트에 운영체제별 Zed 경로 조건을 추가한다.
- `chezmoi diff` 또는 동일한 임시 HOME 검증으로 설정과 키맵 본문이 유지되는지 확인한다.

## 범위

Zed의 `settings.json`과 `keymap.json` 경로만 변경한다. Zed 확장 저장 위치나 설정 내용은 변경하지 않는다.
