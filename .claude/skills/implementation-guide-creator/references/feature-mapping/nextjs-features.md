# Next.js Feature Mapping

Reference for mapping user goals to Next.js features and documentation.

## Routing Features

### i18n (Internationalization)
- **Use when:** Multilingual sites, locale-based content
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/internationalization
- **Related sections:**
  - App Router > Routing > Internationalization
  - Middleware for locale detection
- **Core APIs:** `middleware.ts`, `[locale]` dynamic segment, `next-intl` (recommended)
- **Keywords:** multilingual, language, locale, translation, i18n

### Dynamic Routes
- **Use when:** Content with unique identifiers (blog posts, products, users)
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes
- **Related sections:**
  - App Router > Routing > Dynamic Routes
  - Data Fetching > generateStaticParams
- **Core APIs:** `[slug]`, `[...slug]` (catch-all), `params` prop
- **Keywords:** blog, posts, articles, products, user profiles, dynamic content

### Parallel Routes
- **Use when:** Multiple views on same page (dashboard, tabs)
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/parallel-routes
- **Related sections:**
  - App Router > Routing > Parallel Routes
  - Advanced Routing Patterns
- **Core APIs:** `@folder` convention, `default.tsx`
- **Keywords:** dashboard, tabs, split view, multiple sections

### Intercepting Routes
- **Use when:** Modal overlays, preview without navigation
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes
- **Related sections:**
  - App Router > Routing > Intercepting Routes
  - Modal patterns
- **Core APIs:** `(..)folder` convention, combined with parallel routes
- **Keywords:** modal, overlay, preview, lightbox

## Data Fetching Features

### Server Actions
- **Use when:** Form submissions, mutations, direct server operations
- **Official docs:** https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations
- **Related sections:**
  - Data Fetching > Server Actions
  - Forms and Mutations
- **Core APIs:** `'use server'`, `action` prop, `formData`, `revalidatePath`
- **Keywords:** form, submit, create, update, delete, mutation, POST

### Data Fetching (Server Components)
- **Use when:** Fetching data for rendering (default approach)
- **Official docs:** https://nextjs.org/docs/app/building-your-application/data-fetching/fetching
- **Related sections:**
  - Data Fetching > Fetching Data
  - Server Components
  - Caching and Revalidation
- **Core APIs:** `fetch()` with caching, `async` components
- **Keywords:** load data, fetch, API call, database query

### Caching & Revalidation
- **Use when:** Performance optimization, real-time updates
- **Official docs:** https://nextjs.org/docs/app/building-your-application/caching
- **Related sections:**
  - Caching > Overview
  - Data Fetching > Revalidating
- **Core APIs:** `revalidatePath`, `revalidateTag`, `cache: 'no-store'`
- **Keywords:** refresh, update, cache, real-time, performance

## UI Features

### MDX
- **Use when:** Blog, documentation, content with React components
- **Official docs:** https://nextjs.org/docs/app/building-your-application/configuring/mdx
- **Related sections:**
  - Configuring > MDX
  - next.config.js setup
- **Core APIs:** `@next/mdx`, `createMDX()`, `mdx-components.tsx`
- **Keywords:** blog, markdown, content, documentation, MDX

### Metadata & SEO
- **Use when:** Every public-facing site (important!)
- **Official docs:** https://nextjs.org/docs/app/building-your-application/optimizing/metadata
- **Related sections:**
  - Optimizing > Metadata
  - SEO best practices
- **Core APIs:** `metadata` export, `generateMetadata()`, Open Graph
- **Keywords:** SEO, meta tags, title, description, social sharing

### Fonts Optimization
- **Use when:** Custom typography, brand fonts
- **Official docs:** https://nextjs.org/docs/app/building-your-application/optimizing/fonts
- **Related sections:**
  - Optimizing > Fonts
  - next/font
- **Core APIs:** `next/font/google`, `next/font/local`
- **Keywords:** fonts, typography, Google Fonts, custom fonts

### Images Optimization
- **Use when:** Displaying images (always use this!)
- **Official docs:** https://nextjs.org/docs/app/building-your-application/optimizing/images
- **Related sections:**
  - Optimizing > Images
  - next/image component
- **Core APIs:** `next/image`, `Image` component, `fill` prop
- **Keywords:** images, photos, gallery, thumbnails

## Authentication Features

### Middleware for Auth
- **Use when:** Route protection, session validation
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/middleware
- **Related sections:**
  - Routing > Middleware
  - Authentication patterns
- **Core APIs:** `middleware.ts`, `NextResponse.redirect()`
- **Keywords:** authentication, login, protected routes, auth guard

### Route Handlers (API Routes)
- **Use when:** REST API endpoints, webhooks
- **Official docs:** https://nextjs.org/docs/app/building-your-application/routing/route-handlers
- **Related sections:**
  - Routing > Route Handlers
  - API Routes patterns
- **Core APIs:** `route.ts`, `GET`, `POST`, `Request`, `Response`
- **Keywords:** API, endpoint, webhook, REST, backend

## Goal → Features Quick Reference

### "Blog with MDX and i18n"
→ MDX, i18n routing, dynamic routes, metadata, images

### "Dashboard with realtime data"
→ Server components, caching/revalidation, parallel routes, server actions

### "E-commerce product catalog"
→ Dynamic routes, images, metadata, generateStaticParams, server actions (cart)

### "SaaS app with authentication"
→ Middleware auth, route handlers, server actions, protected routes

### "Documentation site"
→ MDX, nested routing, search (via third-party), metadata

### "Social media feed"
→ Server components, infinite scroll (client), server actions (posts), images

## Version Notes

This mapping is for **Next.js 14-15 (App Router)**.

If user mentions Pages Router, suggest migrating or clarify their Next.js version.

## Common Mistakes to Prevent

1. **Don't suggest client components for data fetching** → Use server components by default
2. **Don't suggest getServerSideProps** → That's Pages Router, use Server Components
3. **Don't ignore metadata** → Always include for public sites
4. **Don't use regular <img>** → Always use next/image
5. **Don't hard-code locale** → Use middleware for i18n
