# UI Renewal Projects Index

**Last Updated**: 2025-11-22

---

## Active Projects

| Screen/Feature | Framework | Status | Last Updated | Documents | Components |
|---------------|-----------|--------|--------------|-----------|------------|
| Email Signup Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signup-screen/20251122-proposal-v1.md), [Implementation](email-signup-screen/20251122-implementation-v1.md) | 6 (AuthHeroSection, GabiumTextField, GabiumButton, PasswordStrengthIndicator, ConsentCheckbox, GabiumToast) |
| Email Signin Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signin-screen/20251122-proposal-v1.md), [Implementation](email-signin-screen/20251122-implementation-v1.md) | 4 (AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast) |

---

## Planned Projects

| Screen/Feature | Priority | Framework | Notes | Reusable Components |
|---------------|----------|-----------|-------|---------------------|
| Password Reset Screen | High | Flutter | 기존 컴포넌트 재사용 가능 | AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast |
| Onboarding Screen | Medium | Flutter | 새로운 컴포넌트 필요 가능성 | GabiumButton, GabiumTextField |
| Home Dashboard | High | Flutter | 데이터 시각화 컴포넌트 신규 필요 | - |

---

## Summary Statistics

- **Total Completed Projects**: 2
- **Total Components Created**: 6
- **Component Reuse Rate**: 4/6 (67%) - Email Signin 화면에서 4개 재사용
- **Frameworks**: Flutter
- **Design System Version**: Gabium Design System v1.0

---

## Component Reusability Matrix

| Component | Created In | Also Used In | Reuse Count |
|-----------|-----------|--------------|-------------|
| AuthHeroSection | Email Signup | Email Signin | 2 |
| GabiumTextField | Email Signup | Email Signin | 2 |
| GabiumButton | Email Signup | Email Signin | 2 |
| GabiumToast | Email Signup | Email Signin | 2 |
| PasswordStrengthIndicator | Email Signup | - | 1 |
| ConsentCheckbox | Email Signup | - | 1 |

---

## Next Steps

1. **Continue UI Renewal**: Start Phase 2A for next screen (Password Reset recommended)
2. **Expand Component Library**: Create new components as needed
3. **Update Design System**: Add new patterns/tokens as project evolves
4. **Export Design Tokens**: Generate Flutter ThemeData, JSON, CSS for development

---

**For New Projects**:
1. Create new directory under `projects/`
2. Start with Phase 2A (Analysis)
3. Follow document naming convention: `{YYYYMMDD}-{type}-v{N}.md`
4. Update this INDEX.md when project completes
