# 가이드라인

## 공통

- "request_user_input이 default_mode에서도 실행되게 개조해줘 그리고 클로드의 AskUserQuestion의 탁월한 interview UX처럼 기능하게 소스코드를 조사한다음 최적화해줘"
- 워크스페이스의 .worktree를 워크트리 베이스 디렉토리로 사용하고 병렬 서브 에이전트 사용을 권장한다.

## 파이썬

- 가능하다면 code-index를 사용한다.
- 가능하다면 debugmcp를 사용한다.
- 파이썬은 uv 환경을 사용하기 때문에 실행이나 패키지 설치시 주의가 필요하다.

## 커밋

- 커밋 메시지는 반드시 `prefix: 내용` 형식으로 작성한다.
- prefix는 아래 중 하나를 사용한다.
  - `init`: 프로젝트 초기 구성, 시작점 생성, 기본 설정
  - `feat`: 새로운 기능 추가
  - `fix`: 버그 수정
  - `refactor`: 동작 변화 없는 구조 개선
  - `chore`: 설정, 의존성, 개발환경, 기타 유지보수 작업
  - `docs`: 문서 수정
  - `style`: 동작 영향 없는 코드 스타일 수정
  - `test`: 테스트 추가 및 수정
  - `perf`: 성능 개선
  - `build`: 빌드, 패키징, 배포 설정 변경
  - `ci`: CI/CD 설정 변경
- prefix를 제외한 나머지 커밋 메시지는 한글로 작성한다.
- main에 반영할때는 머지보다는 스쿼시로 적용을 권장한다.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
