# Documentation Extraction Strategy

## Core Principle

**Extract only what's needed for the specific implementation goal.**

The goal is NOT to include comprehensive documentation, but rather to create a focused, contextual guide that includes only the features and information necessary for the user's specific implementation.

## The Problem with Full Documentation

- **Context overload**: Full docs can be 50,000+ tokens
- **Irrelevant information**: 80% of content may be unrelated to user's goal
- **Cognitive load**: User has to filter what's relevant
- **Maintenance burden**: Full docs change frequently

## Just-in-Time Documentation Approach

### Step 1: Identify Minimum Viable Features

Ask: "What is the absolute minimum set of features needed to achieve this goal?"

**Example:**
- Goal: "Simple blog with authentication"
- ✅ Need: routing, auth, data fetching
- ❌ Don't need: internationalization, middleware, streaming

### Step 2: Find Official Doc Sections

For each feature, locate:
1. **Setup/Installation section** - How to enable the feature
2. **Core API/Usage section** - Basic usage patterns
3. **One concrete example** - Preferably from official examples

### Step 3: Extract Selectively

For each section, extract:
- ✅ Configuration steps
- ✅ Core API methods/components
- ✅ One working example
- ✅ Breaking changes (if any)
- ❌ Skip: Advanced features, edge cases, alternatives

### Step 4: Contextualize

Transform generic documentation into goal-specific guidance:

**Generic (from docs):**
```typescript
// Dynamic routes
export default function Page({ params }) {
  return <div>{params.id}</div>
}
```

**Contextualized (for blog):**
```typescript
// Blog post dynamic route
export default function BlogPost({ params }) {
  return <article>{params.slug}</article>
}
```

## Extraction Checklist

For each feature, ensure you have:

- [ ] **Why it matters** - Brief explanation of why this feature is needed for the goal
- [ ] **Setup** - How to install/configure (1-3 steps max)
- [ ] **Usage** - Core API/methods (not exhaustive)
- [ ] **Example** - One contextualized code example
- [ ] **Gotchas** - Known issues specific to this version (1-3 items)

## Red Flags (Over-Extraction)

Stop if you're including:
- Multiple ways to do the same thing
- "Advanced" or "Edge cases" sections
- Complete API reference
- Performance optimization details
- Lengthy explanations that rephrase what code shows

## What to Skip

### Always Skip
- Changelog/release notes (unless breaking changes)
- Community packages/alternatives
- Comparison with other solutions
- Historical context ("Why we built this")
- Contributor guides

### Usually Skip
- Advanced configurations
- Performance tuning
- Debugging techniques
- Migration guides (unless user is migrating)

### Sometimes Include
- Error handling (if critical)
- TypeScript types (if using TypeScript)
- Testing approach (if user mentioned testing)

## Version Management

Always specify and verify:
- **LTS version**: Prefer stable, long-term support versions
- **Release date**: Ensure docs are from recent releases (< 1 year)
- **Breaking changes**: Note any changes from previous major version

## Cross-Verification

Before finalizing extraction:
1. Check official example repositories
2. Look for recent issues (GitHub/StackOverflow)
3. Verify with 2-3 recent blog posts
4. Test code examples if possible

## Example: Good vs Bad Extraction

### Bad (Too Much)
```markdown
## Authentication

Next.js supports multiple authentication patterns...
[10 paragraphs about different auth strategies]
[Complete API reference for 5 auth libraries]
[Edge cases for session management]
[Performance considerations]
```

### Good (Focused)
```markdown
## Authentication Setup

### Why This Matters for Your Goal
User login is required for accessing protected blog admin pages.

### Setup
```bash
npm install next-auth
```

### Configuration
```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth'

export const authOptions = {
  providers: [/* your providers */]
}

export default NextAuth(authOptions)
```

### Usage in Your Blog Admin
```typescript
// app/admin/page.tsx
import { getServerSession } from 'next-auth'

export default async function AdminPage() {
  const session = await getServerSession()
  if (!session) redirect('/login')
  // Your admin UI
}
```

### Gotchas
⚠️ **v5 breaking change**: `getServerSession` now requires explicit authOptions import
```
