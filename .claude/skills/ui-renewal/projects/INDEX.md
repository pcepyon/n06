# UI Renewal Projects Index

**Last Updated**: 2025-11-22

---

## Completed Projects

| Screen/Feature | Framework | Status | Last Updated | Documents | Components |
|---------------|-----------|--------|--------------|-----------|------------|
| Email Signin Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signin-screen/20251122-proposal-v1.md), [Implementation](email-signin-screen/20251122-implementation-v1.md) | 4 (AuthHeroSection, GabiumTextField, GabiumButton...) |
| Email Signup Screen | Flutter | ✅ Completed | 2025-11-22 | [Proposal](email-signup-screen/20251122-proposal-v1.md), [Implementation](email-signup-screen/20251122-implementation-v1.md) | 6 (AuthHeroSection, GabiumTextField, GabiumButton...) |
| Home Dashboard | Flutter | ✅ Completed | 2025-11-22 | [Proposal](home-dashboard/20251122-proposal-v1.md), [Implementation](home-dashboard/20251122-implementation-v1.md), [Verification](home-dashboard/20251122-verification-v1.md) | 2 (GabiumBottomNavigation, ScaffoldWithBottomNav) |

---

## Planned Projects

| Screen/Feature | Priority | Framework | Notes | Reusable Components |
|---------------|----------|-----------|-------|---------------------|
| Password Reset Screen | High | Flutter | 기존 컴포넌트 재사용 가능 | AuthHeroSection, GabiumTextField, GabiumButton, GabiumToast |
| Onboarding Screen | Medium | Flutter | 새로운 컴포넌트 필요 가능성 | GabiumButton, GabiumTextField |

---

## Summary Statistics

- **Total Completed Projects**: 3
- **Total Frameworks**: 1 (Flutter)
- **Design System Version**: Gabium Design System v1.0

---

## Component Reusability Matrix

| Component | Created In | Also Used In | Reuse Count |
|-----------|-----------|--------------|-------------|
| GabiumBottomNavigation | Home Dashboard | All main screens (Weight Tracking, Dose Schedule, Coping Guide, Settings) | 5 |
| AuthHeroSection | Email Signin Screen | Email Signup Screen | 2 |
| ConsentCheckbox | Email Signup Screen | - | 1 |
| GabiumButton | Email Signin Screen | Email Signup Screen, Home Dashboard | 3 |
| GabiumTextField | Email Signin Screen | Email Signup Screen | 2 |
| GabiumToast | Email Signin Screen | Email Signup Screen, Home Dashboard | 3 |
| PasswordStrengthIndicator | Email Signup Screen | - | 1 |
| ScaffoldWithBottomNav | Home Dashboard | All main screens | 5 |

---

## Next Steps

1. **Continue UI Renewal**: Start Phase 2A for next screen
2. **Expand Component Library**: Create new components as needed
3. **Update Design System**: Add new patterns/tokens as project evolves
4. **Export Design Tokens**: Generate Flutter ThemeData, JSON, CSS for development

---

**For New Projects**:
1. Create new directory under `projects/`
2. Start with Phase 2A (Analysis)
3. Follow document naming convention: `{YYYYMMDD}-{type}-v{N}.md`
4. Update this INDEX.md when project completes
