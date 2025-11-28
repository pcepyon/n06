# Changelog

## Writing Rules

1. **Newest entries at top** (reverse chronological order)
2. **Date format**: `## YYYY-MM-DD`
3. **Type tags**: `[feat]`, `[fix]`, `[refactor]`, `[docs]`, `[test]`, `[chore]`
4. **One-line summary**: What changed and why, keep it concise
5. **Related files**: Key file paths (optional)

### Example
```
## 2025-01-15

- [feat] Add user profile edit feature
  - `features/profile/presentation/screens/profile_edit_screen.dart`
- [fix] Handle auto-logout on token expiration
```

---

## 2025-11-29

- [docs] CLAUDE.md 간소화 및 문서 메타데이터 시스템 추가
  - 407줄 → 125줄 (70% 감소)
  - `docs/INDEX.md` 생성, 핵심 문서 8개에 Frontmatter 추가
- [docs] 커밋 프로세스에 changelog 단계 통합
  - `claude.md`

