# Version Tracking & LTS Verification

Guide for ensuring guides reference current, stable versions.

## Why Version Matters

- **Breaking changes** can make old documentation incorrect
- **Security updates** are critical for production apps
- **LTS versions** provide stability and long-term support
- **Deprecated APIs** should not be recommended

## Version Strategy

### Prefer LTS (Long-Term Support)
- More stable
- Better documentation
- Longer support period
- Fewer breaking changes

### Check Release Date
- Documentation should be < 1 year old
- If older, verify still valid
- Note any deprecations

## How to Find Current Versions

### Next.js
```bash
# Check latest stable
npm info next version

# Check for LTS tag
npm view next versions --json | grep -A5 -B5 "lts"
```

**Official:** https://github.com/vercel/next.js/releases

Look for tags like: `v14.0.0` (major versions are typically LTS)

### React
```bash
npm info react version
```

**Official:** https://react.dev/versions

### Supabase
**Client library:**
```bash
npm info @supabase/supabase-js version
```

**Platform:** Check dashboard - they auto-update backend

**Official:** https://github.com/supabase/supabase-js/releases

### Node.js
```bash
node --version
```

**Official:** https://nodejs.org/en/about/previous-releases

Look for "LTS" designation (e.g., Node 20 LTS)

## Verification Checklist

Before finalizing guide:

- [ ] Version numbers specified for all major dependencies
- [ ] Versions are current stable or LTS
- [ ] Release date is within last 12 months
- [ ] No deprecated APIs included
- [ ] Breaking changes documented in "Gotchas"

## Common Version-Related Issues

### Issue: Code examples don't work
**Cause:** Using outdated API from previous version
**Fix:** Check official migration guide

### Issue: TypeScript errors
**Cause:** Type definitions changed
**Fix:** Update to matching @types package

### Issue: Import errors
**Cause:** Package structure changed
**Fix:** Check changelog for import path changes

## Breaking Changes to Watch For

### Next.js (v13 → v14 → v15)
- `next/navigation` vs `next/router`
- App Router vs Pages Router
- Server Components vs Client Components
- `metadata` API changes
- `generateStaticParams` vs `getStaticPaths`

### React (v17 → v18)
- Automatic batching
- Suspense changes
- `createRoot` vs `render`
- Concurrent features

### Supabase (v1 → v2)
- Client initialization syntax
- Auth helpers changed
- Storage API updates
- Realtime syntax

## Documentation Sources Priority

When cross-referencing:

1. **Official docs** (highest priority)
   - Most accurate
   - Updated regularly
   - Example: https://nextjs.org/docs

2. **Official GitHub repos**
   - Check CHANGELOG.md
   - Read release notes
   - Example issues/discussions

3. **Official example repositories**
   - Verified working code
   - Best practices
   - Example: https://github.com/vercel/next.js/tree/canary/examples

4. **Recent blog posts** (last 6 months)
   - Preferably from official sources
   - Cross-verify information
   - Check publication date

5. **Community resources** (use sparingly)
   - Stack Overflow for specific issues
   - Must be recent (< 6 months)
   - Verify against official docs

## Version Specification Format

In guides, always specify versions:

### Good
```markdown
## Context
- **Next.js:** 15.0.3 (App Router)
- **React:** 18.2.0
- **Node.js:** 20.10.0 LTS
- **Last Updated:** 2025-11-08
```

### Bad
```markdown
## Context
- Using Next.js
- Latest React
- Updated recently
```

## Handling Version Mismatches

If user is on older version:

1. **Check if feature exists** in their version
2. **Note differences** in implementation
3. **Suggest upgrade** if critical features missing
4. **Provide fallback** if upgrade not possible

Example:
```markdown
### Version Note
This guide uses Next.js 15. If you're on v14:
- Use `metadata` API (same)
- Server Actions syntax is identical
- ⚠️ Parallel routes require v15 - consider upgrading
```

## Checking for Deprecations

### Next.js
Check: https://nextjs.org/docs/messages/deprecated-features

### React
Check: https://react.dev/warnings

### Supabase
Check: Release notes at https://github.com/supabase/supabase-js/releases

## Quick Reference: Current Stable Versions (as of Nov 2025)

**Note:** Verify these before finalizing guide!

- **Next.js:** 15.x (App Router recommended)
- **React:** 18.x or 19.x (check compatibility)
- **Node.js:** 20.x LTS or 22.x LTS
- **TypeScript:** 5.x
- **Supabase JS:** 2.x
- **Prisma:** 5.x
- **TailwindCSS:** 3.x

## Auto-Update Strategy

For guides that may be used months later:

1. Include version check command
2. Link to migration guides
3. Note which features are stable (unlikely to change)
4. Flag experimental features

Example:
```markdown
## Before You Start

Check your Next.js version:
```bash
npx next --version
```

This guide requires Next.js 14+. If upgrading:
[Next.js 13 → 14 Migration Guide](...)
```
