# Design System Version History

This document tracks all versions of the Design System and their changes.

## Version Format

- **Major version (X.0)**: Breaking changes, complete redesign
- **Minor version (X.Y)**: New components, token additions, non-breaking changes
- **Patch version (X.Y.Z)**: Bug fixes, documentation updates (optional)

## Current Version

**Latest:** v1.0 (Gabium Design System v1.0)
**File:** `gabium-design-system-v1.0.md`

---

## Version Log

### v1.0 (2025-11-22)

**Status:** ✅ Current
**File:** `gabium-design-system-v1.0.md`
**Created by:** Phase 1 - Initial Design System Creation

**Changes:**
- Initial design system created
- Color palette established (Primary: #4ADE80, Neutral scale)
- Typography scale defined (xs: 12px → 3xl: 28px)
- Spacing system (8px-based scale)
- Component registry initialized
- Border radius and shadow scales

**Projects using this version:**
- email-signup-screen
- email-signin-screen
- home-dashboard

**Breaking Changes:** N/A (initial version)

---

## Adding New Version

When updating the Design System:

1. **Save new version file:**
   ```bash
   cp gabium-design-system.md gabium-design-system-v1.1.md
   # Make changes to gabium-design-system-v1.1.md
   ```

2. **Update symlink:**
   ```bash
   ln -sf gabium-design-system-v1.1.md gabium-design-system.md
   ```

3. **Update this VERSION_HISTORY.md:**
   ```markdown
   ### v1.1 (YYYY-MM-DD)

   **Status:** ✅ Current
   **File:** `gabium-design-system-v1.1.md`
   **Updated by:** [Phase/Reason]

   **Changes:**
   - Added new color: Secondary (#...)
   - New component: Card
   - Updated spacing: Added 3xl (64px)

   **Projects using this version:**
   - [list projects]

   **Breaking Changes:**
   - Changed Primary color from #4ADE80 to #... (affects all buttons)
   ```

4. **Mark previous version as archived:**
   ```markdown
   ### v1.0 (2025-11-22)

   **Status:** 📦 Archived
   **File:** `gabium-design-system-v1.0.md`
   ...
   ```

---

## Rollback Procedure

To rollback to a previous version:

```bash
# 1. Update symlink to old version
ln -sf gabium-design-system-v1.0.md gabium-design-system.md

# 2. Update VERSION_HISTORY.md
# Mark v1.1 as archived, v1.0 as current

# 3. Update affected projects
# Projects using v1.1 need to be reviewed
```

---

## Impacted Projects by Version

When a Design System version changes, list affected projects:

**v1.0 → v1.1 Migration:**
- ✅ email-signup-screen (migrated)
- ✅ home-dashboard (migrated)
- ⏳ email-signin-screen (pending)

---

## Best Practices

1. **Use semantic versioning:** Major.Minor[.Patch]
2. **Document breaking changes:** Always list what changed
3. **Keep old versions:** Never delete previous version files
4. **Track project usage:** Know which projects use which version
5. **Update symlink:** Always point to latest version
6. **Test migrations:** Verify projects still work after DS update
