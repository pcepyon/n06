# Guide Writing Patterns

This document contains proven patterns for writing effective implementation guides.

## Pattern 1: Feature-First Structure

Start each feature section with context, then implementation.

### Template
```markdown
## Feature X: [Name]

### Why This Matters for Your Goal
[1-2 sentences connecting feature to user's goal]

### Installation/Setup
[Minimal steps to enable feature]

### Your Implementation
[Contextualized code example]

### Gotchas
[Known issues, if any]
```

### Example
```markdown
## Feature 1: Dynamic Routes

### Why This Matters for Your Goal
Blog posts need unique URLs like `/blog/my-first-post` using slugs.

### Setup
Create file: `app/blog/[slug]/page.tsx`

### Your Implementation
```typescript
export default function BlogPost({ 
  params 
}: { 
  params: { slug: string } 
}) {
  // Fetch and render blog post by slug
}
```

### Gotchas
⚠️ Brackets `[slug]` create dynamic segment, not query param
```

## Pattern 2: Progressive Disclosure

Organize information from essential to optional.

### Structure
1. **Context** - What and why (always needed)
2. **Basic Setup** - Minimum viable implementation
3. **Core Usage** - Essential features
4. **Integration** - How features work together
5. **Optional Enhancements** - Nice to have (clearly marked)

### Example
```markdown
## Authentication

### Basic Setup (Required)
[Email/password login]

### Core Usage
[Login, logout, session check]

### Integration
[Protecting routes, accessing user data]

### Optional: OAuth Providers
⚡ Optional enhancement if needed later...
```

## Pattern 3: Contextual Examples

Don't show generic examples. Show examples specific to user's domain.

### Bad (Generic)
```typescript
// Fetch data
const data = await fetch('/api/data')
```

### Good (Contextualized)
```typescript
// Fetch blog posts for homepage
const posts = await fetch('/api/blog/posts')
```

### Bad (Generic)
```typescript
export default function Page({ params }: { params: { id: string } }) {
  return <div>ID: {params.id}</div>
}
```

### Good (Contextualized)
```typescript
export default function BlogPost({ params }: { params: { slug: string } }) {
  return <article className="blog-post">
    {/* Blog post content using slug */}
  </article>
}
```

## Pattern 4: Integration Section

Always include a "Putting It All Together" section that shows:
1. Complete file structure
2. How features interconnect
3. One full working example

### Template
```markdown
## Integration: Putting It All Together

### File Structure
```
project/
  app/
    [feature-a]/
    [feature-b]/
  components/
  lib/
```

### How Features Connect
[Explanation of data flow, dependencies]

### Complete Working Example
```typescript
// Full code that demonstrates all features working together
```
```

### Example
```markdown
## Integration: Putting It All Together

### File Structure
```
blog/
  app/
    [locale]/          # i18n routing
      blog/
        [slug]/        # Dynamic routes
          page.tsx     # MDX rendering
  content/
    en/blog/
    ko/blog/
  middleware.ts        # Locale detection
```

### How It Works
1. Middleware detects locale from URL/headers
2. Dynamic route loads MDX from `content/{locale}/blog/{slug}.mdx`
3. MDX rendered with custom components

### Complete Example
[Full working implementation]
```

## Pattern 5: Testing Checklist

Always include actionable test items, not vague suggestions.

### Bad (Vague)
```markdown
- [ ] Test the feature
- [ ] Check it works
- [ ] Make sure there are no errors
```

### Good (Specific)
```markdown
- [ ] Visit `/ko/blog/test-post` → Shows Korean content
- [ ] Visit `/en/blog/test-post` → Shows English content
- [ ] MDX components render (images, code blocks)
- [ ] Change locale in URL → Content updates
- [ ] Check browser console → No errors
```

## Pattern 6: Gotchas Section

Document known issues, breaking changes, and common mistakes.

### Format
```markdown
### Gotchas

⚠️ **[Breaking Change Title]**: [Description]
💡 **[Tip Title]**: [Helpful advice]
🐛 **[Known Issue Title]**: [Workaround]
```

### Example
```markdown
### Gotchas

⚠️ **v5 Breaking Change**: `getServerSession` signature changed
```typescript
// Old (v4)
const session = await getServerSession(req, res)

// New (v5)  
const session = await getServerSession(authOptions)
```

💡 **Tip**: Use `middleware.ts` for locale detection, not `getServerSideProps`

🐛 **Known Issue**: MDX images require `next/image` import in `mdx-components.tsx`
```

## Pattern 7: Minimal External Links

Include links judiciously:
- ✅ Official docs for each major feature
- ✅ Official example repositories
- ❌ Blog posts, tutorials (unless exceptional)
- ❌ API reference (unless specific need)

### Good
```markdown
## References
- [Official i18n Docs](https://nextjs.org/docs/app/building-your-application/routing/internationalization)
- [Example Repository](https://github.com/vercel/next.js/tree/canary/examples/i18n)
```

### Bad (Too Many)
```markdown
## References
- [Official Docs](...)
- [Tutorial 1](...)
- [Tutorial 2](...)
- [Blog Post](...)
- [Stack Overflow Discussion](...)
- [Reddit Thread](...)
```

## Anti-Patterns to Avoid

### ❌ Kitchen Sink Approach
Don't include every possible configuration option.

### ❌ Copy-Paste from Docs
Don't reproduce official docs verbatim. Contextualize and adapt.

### ❌ Multiple Solutions
Don't show 3 different ways to do the same thing. Pick one best approach.

### ❌ Over-Explaining
Code should be self-documenting. Don't write essays explaining what code shows.

### ❌ Premature Optimization
Don't include performance tips unless critical to the goal.

## Quality Checklist

Before finalizing a guide, verify:

- [ ] Every feature section has "Why this matters" context
- [ ] Code examples use domain-specific terminology
- [ ] There's a complete integration example
- [ ] Testing checklist is specific and actionable
- [ ] Gotchas section documents known issues
- [ ] No redundant information
- [ ] Length is appropriate (aim for 2,000-4,000 tokens)
- [ ] Version numbers are specified
- [ ] Official docs are linked for each feature

## Template Selection Guide

### Use Framework Guide Template When:
- Working with full-stack frameworks (Next.js, SvelteKit, Remix)
- Multiple interconnected features
- Need routing, data fetching, rendering patterns

### Use Library Guide Template When:
- Single-purpose libraries (React Query, Zustand, Zod)
- Focused functionality
- No routing or full-stack concerns

### Use Service Integration Template When:
- External APIs (Stripe, Twilio, SendGrid)
- Authentication providers (Auth0, Clerk, Supabase Auth)
- Third-party services requiring API keys/webhooks
