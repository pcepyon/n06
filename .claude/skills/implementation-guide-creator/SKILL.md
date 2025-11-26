---
name: implementation-guide-creator
description: Create focused, contextual implementation guides for external services, libraries, and frameworks. Use when integrating third-party tools (APIs, SDKs, webhooks), implementing specific library features, or building with frameworks where targeted documentation would prevent errors. Creates "just-in-time" guides containing only relevant information for the specific implementation goal, avoiding context overload.
---

# Implementation Guide Creator

Create accurate, focused implementation guides that extract only necessary information from official documentation for a specific implementation goal.

## Environment

This skill is designed for **Claude Code** environment.

- **Skill location**: `~/.claude/skills/implementation-guide-creator/` (global) or `.claude/skills/implementation-guide-creator/` (project)
- **Output location**: `./docs/implementation/` (relative to project root)
- **Scripts location**: `./scripts/` (relative to this skill folder)

## The Problem This Solves

When integrating external services or implementing features with libraries/frameworks:
- **Full documentation is overwhelming** (50,000+ tokens)
- **AI agents hallucinate** when lacking specific knowledge
- **Generic examples don't match** the user's exact use case
- **Version mismatches** cause errors

This skill creates **just-in-time documentation** tailored to the user's specific goal.

## 6-Step Workflow

### Step 1: Identify What to Document

**Goal:** Understand exactly what the user wants to build and which tools they need.

Ask clarifying questions:
- What are you trying to build/integrate?
- Which library/framework/service?
- What specific features do you need?

**Example dialogue:**
```
User: "I want to integrate Kakao login"

You: "To create the best guide, I need to understand:
1. Are you using Next.js, React, or another framework?
2. Do you need just basic login, or also user profile/features?
3. Do you have a Kakao developer account already?"
```

**Output:** Clear understanding of:
- Target technology (library/framework/service)
- Implementation goal (what user wants to build)
- Required features (minimum set needed)

---

### Step 2: Analyze & Map Features

**Goal:** Break down the implementation into specific features that need documentation.

**For external services:**
Determine if SDK, API, and/or Webhook integration is needed.

Use this prompt pattern:
```
I'm integrating {service} into a {framework} project for {goal}.

Determine:
1. Do I need SDK, API, Webhook, or combination?
2. What are the essential features to accomplish {goal}?
3. What authentication/credentials are required?

Don't provide implementation yet - just identify what's needed.
```

**For libraries/frameworks:**
Use `references/feature-mapping/{technology}-features.md` to map goal → features.

Available mappings:
- `nextjs-features.md` - Next.js feature mapping
- `supabase-features.md` - Supabase feature mapping
- Create new mappings as needed for other technologies

**Run analysis script:**
```bash
# From skill directory
python ./scripts/analyze_implementation.py \
  --target "Next.js 15" \
  --goal "Multilingual MDX blog" \
  --features "i18n,dynamic-routes,mdx"
```

**Output:** List of specific features to document (e.g., "i18n routing, dynamic routes, MDX rendering")

---

### Step 3: Research & Extract Documentation

**Goal:** Gather targeted information from official sources about identified features only.

**Research strategy** (from `references/extraction-strategy.md`):
1. Start with official documentation
2. Cross-check with official example repositories
3. Verify with recent blog posts (< 6 months)
4. Check for known issues/breaking changes

**What to extract for each feature:**
- ✅ Setup/installation (1-3 steps)
- ✅ Core API/configuration
- ✅ One working example
- ✅ Breaking changes/gotchas
- ❌ Skip: Advanced features, alternatives, edge cases

**Prompt pattern for deep research:**
```
Research the following features for {technology}:
[List of features from Step 2]

For EACH feature, find:
1. Official documentation URL
2. Installation/setup steps
3. Core API methods/configuration
4. One concrete code example
5. Known issues or breaking changes (if any)

Prioritize:
1. Official docs (highest priority)
2. Official example repos
3. Recent blog posts (last 6 months)

Cross-verify information with multiple sources.
Today's date: {current_date}
Verify this is for the LTS version.
```

**Version verification** (see `references/version-tracking.md`):
- Prefer LTS versions
- Verify release date < 1 year
- Note breaking changes from previous versions

**Output:** Raw documentation notes organized by feature

---

### Step 4: Create Guide from Template

**Goal:** Generate structured guide using appropriate template.

**Select template:**
- `assets/templates/framework-guide.md` - For frameworks (Next.js, SvelteKit)
- `assets/templates/library-guide.md` - For libraries (React Query, Zustand)
- `assets/templates/service-integration.md` - For external services (Stripe, Kakao)

**Initialize guide:**
```bash
# From skill directory
python ./scripts/init_guide.py \
  --target "Next.js 15" \
  --goal "Multilingual MDX blog" \
  --type framework \
  --output "./docs/implementation/nextjs-i18n-blog.md"
```

**Fill in the guide following patterns from `references/guide-patterns.md`:**

**Pattern 1: Feature-First Structure**
```markdown
## Feature: i18n Routing

### Why This Matters for Your Goal
Blog needs Korean/English URLs like /ko/blog and /en/blog

### Setup
[Minimal installation steps]

### Your Implementation
[Contextualized code example for blog, not generic]

### Gotchas
[Breaking changes, known issues]
```

**Pattern 2: Contextual Examples**
❌ Generic: `fetch('/api/data')`
✅ Contextualized: `fetch('/api/blog/posts')`

**Pattern 3: Integration Section**
Always include "Putting It All Together" showing:
- Complete file structure
- How features interconnect
- Full working example

**Key principles:**
- Use domain-specific terminology (e.g., "blog posts" not "items")
- Include only requested features (no "nice to haves")
- Make examples runnable and complete
- Keep total length 2,000-4,000 tokens

**Save guide to:** `./docs/implementation/{service-or-feature}.md`

---

### Step 5: Validate Guide

**Goal:** Ensure guide is complete and accurate.

**Run validation script:**
```bash
# From skill directory
python ./scripts/validate_guide.py ./docs/implementation/{filename}.md
```

**Checks performed:**
- Required sections present (Context, Installation, Implementation, Testing)
- Version numbers specified
- Code examples included
- Testing checklist provided
- Reference links to official docs

**Manual verification:**
- Read through guide as if you're implementing it
- Verify code examples are specific to the goal
- Check that no unnecessary features included
- Ensure version numbers are current

**Fix any errors** reported by validator before proceeding.

---

### Step 6: Deliver & Use Guide

**Goal:** Provide guide to user and show how to use it in implementation.

**Deliver guide:**
```markdown
I've created an implementation guide at:
./docs/implementation/{filename}.md

This guide contains focused documentation for {goal}, including only the features you need.
```

**Show how to use in prompts:**
```markdown
When implementing, reference the guide in your prompts:

"Implement Kakao login integration. 
Follow the guide at ./docs/implementation/kakao-auth.md exactly."

This ensures the AI agent uses accurate, tested information instead of guessing.
```

**Testing:**
Encourage user to follow the Testing Checklist in the guide to verify implementation.

---

## Example Guides

See `assets/examples/` for complete example guides:
- `nextjs-i18n-blog.md` - Multilingual blog with MDX
- More examples as you create them

These demonstrate proper structure and level of detail.

---

## Quick Reference: Common Scenarios

### Scenario 1: External Service Integration
"Integrate Stripe payment into my SaaS"
→ Use service-integration template
→ Identify: SDK + Webhook needed
→ Extract: Setup, API methods, webhook handling
→ Create guide at `./docs/external/stripe-payment.md`

### Scenario 2: Framework Feature Implementation  
"Build Next.js app with authentication"
→ Use framework-guide template
→ Map features: middleware auth, route handlers, server actions
→ Extract from official Next.js docs
→ Create guide at `./docs/implementation/nextjs-auth.md`

### Scenario 3: Library Usage
"Use React Query for data fetching in my dashboard"
→ Use library-guide template
→ Identify: queries, mutations, caching
→ Extract usage patterns
→ Create guide at `./docs/implementation/react-query-dashboard.md`

---

## Best Practices

1. **Always verify versions** - Use LTS when available
2. **Extract, don't copy** - Paraphrase and contextualize documentation
3. **Stay focused** - Only include features needed for the goal
4. **Test specificity** - Code examples should use domain terms
5. **Link to official docs** - Always provide source references
6. **Validate thoroughly** - Run validation script and manual checks

---

## When NOT to Use This Skill

Don't create guides for:
- ❌ Well-known, stable concepts Claude already knows (e.g., "How to use React hooks")
- ❌ Questions answerable with existing knowledge
- ❌ One-off questions that don't need persistent documentation
- ❌ Very simple integrations with perfect official quick-starts

DO use when:
- ✅ Integrating external services (APIs, SDKs, webhooks)
- ✅ Using libraries Claude doesn't know well
- ✅ Building complex features requiring multiple library features
- ✅ User mentions errors/hallucinations in previous attempts
- ✅ Implementation requires combining multiple technologies

---

## Troubleshooting

**Issue:** Guide is too long (>5,000 tokens)
**Solution:** You're including too much. Review `extraction-strategy.md` and remove:
- Advanced features not needed for goal
- Multiple ways to do same thing
- Lengthy explanations

**Issue:** Validation fails - missing code examples
**Solution:** Ensure each feature section has at least one code block

**Issue:** Code examples are too generic
**Solution:** Replace generic terms with domain-specific ones from user's goal

**Issue:** Can't find official documentation
**Solution:** Use web search to locate current docs, verify date and version

---

## Claude Code Specific Notes

### Running Scripts

Scripts are located in the `scripts/` folder relative to this skill:

```bash
# If skill is at ~/.claude/skills/implementation-guide-creator/
python ~/.claude/skills/implementation-guide-creator/scripts/analyze_implementation.py --help

# Or navigate to skill directory first
cd ~/.claude/skills/implementation-guide-creator
python ./scripts/analyze_implementation.py --target "Next.js 15" --goal "Blog" --features "mdx,i18n"
```

### Output Location

All generated guides should be saved to the project's `./docs/implementation/` directory:

```bash
# Ensure directory exists
mkdir -p ./docs/implementation

# Generate guide
python ./scripts/init_guide.py \
  --target "Supabase" \
  --goal "User authentication" \
  --type service \
  --output "./docs/implementation/supabase-auth.md"
```

### Reading References

References are in the `references/` folder:

```bash
# Read extraction strategy
cat ~/.claude/skills/implementation-guide-creator/references/extraction-strategy.md

# Check feature mapping
cat ~/.claude/skills/implementation-guide-creator/references/feature-mapping/nextjs-features.md
```
