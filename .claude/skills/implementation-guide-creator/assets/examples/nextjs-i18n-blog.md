# Multilingual MDX Blog - Next.js 15 Guide

## Context
- **Goal:** Multilingual blog with MDX content (Korean/English)
- **Stack:** Next.js 15 (App Router), MDX, next-intl
- **Required Features:** i18n routing, dynamic routes, MDX rendering, metadata
- **Last Updated:** 2025-11-08
- **Official Docs Version:** Next.js 15.0

---

## Architecture Overview

This blog uses locale-based routing where each blog post exists in multiple languages.

```
blog/
  app/
    [locale]/              # Locale routing (ko, en)
      blog/
        page.tsx           # Blog list page
        [slug]/
          page.tsx         # Individual blog post
  content/
    ko/blog/
      post1.mdx
    en/blog/
      post1.mdx
  middleware.ts            # Locale detection
```

---

## Feature 1: i18n Routing Setup

### Why This Matters for Your Goal
Blog needs Korean and English versions with URLs like `/ko/blog/post` and `/en/blog/post`.

### Installation
```bash
npm install next-intl
```

### Configuration

**Step 1: Create middleware for locale detection**
```typescript
// middleware.ts
import createMiddleware from 'next-intl/middleware';

export default createMiddleware({
  locales: ['ko', 'en'],
  defaultLocale: 'ko',
  localePrefix: 'always' // Always show locale in URL
});

export const config = {
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)']
};
```

**Step 2: Create i18n configuration**
```typescript
// i18n.ts
import { getRequestConfig } from 'next-intl/server';

export default getRequestConfig(async ({ locale }) => ({
  messages: (await import(`./messages/${locale}.json`)).default
}));
```

### Your Implementation
```typescript
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';

export default async function LocaleLayout({
  children,
  params: { locale }
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

### Gotchas

⚠️ **Breaking change in Next.js 15**: `locale` is now in `params`, not a separate prop

💡 **Tip**: Use `localePrefix: 'always'` to avoid SEO issues with duplicate content

---

## Feature 2: Dynamic Routes + MDX

### Why This Matters for Your Goal
Each blog post has a unique slug (URL identifier) and is written in MDX for rich content.

### Installation
```bash
npm install @next/mdx @mdx-js/loader @mdx-js/react @types/mdx
npm install gray-matter # For frontmatter parsing
```

### Configuration

**Step 1: Configure Next.js for MDX**
```javascript
// next.config.mjs
import createMDX from '@next/mdx'

/** @type {import('next').NextConfig} */
const nextConfig = {
  pageExtensions: ['js', 'jsx', 'md', 'mdx', 'ts', 'tsx'],
}

const withMDX = createMDX({
  options: {
    remarkPlugins: [],
    rehypePlugins: [],
  },
})

export default withMDX(nextConfig)
```

**Step 2: Create MDX components**
```typescript
// mdx-components.tsx
import type { MDXComponents } from 'mdx/types'
import Image from 'next/image'

export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    img: (props) => (
      <Image
        {...props}
        width={800}
        height={600}
        alt={props.alt || ''}
      />
    ),
    ...components,
  }
}
```

### Your Implementation

**Step 1: Create blog post files**
```mdx
---
title: "My First Blog Post"
date: "2025-11-08"
description: "This is my first blog post"
---

# {frontmatter.title}

This is **MDX** content with React components!

<CustomComponent />
```

**Step 2: Create dynamic route page**
```typescript
// app/[locale]/blog/[slug]/page.tsx
import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'

interface BlogPostProps {
  params: {
    locale: string
    slug: string
  }
}

export default async function BlogPost({ params }: BlogPostProps) {
  const { locale, slug } = params
  
  // Read MDX file
  const filePath = path.join(
    process.cwd(),
    'content',
    locale,
    'blog',
    `${slug}.mdx`
  )
  const fileContent = fs.readFileSync(filePath, 'utf-8')
  const { data, content } = matter(fileContent)
  
  // Import and render MDX
  const { default: MDXContent } = await import(
    `@/content/${locale}/blog/${slug}.mdx`
  )
  
  return (
    <article className="prose lg:prose-xl mx-auto">
      <h1>{data.title}</h1>
      <time>{data.date}</time>
      <MDXContent />
    </article>
  )
}

// Generate static params for all blog posts
export async function generateStaticParams() {
  const locales = ['ko', 'en']
  const params = []
  
  for (const locale of locales) {
    const postsDirectory = path.join(process.cwd(), 'content', locale, 'blog')
    const filenames = fs.readdirSync(postsDirectory)
    
    for (const filename of filenames) {
      params.push({
        locale,
        slug: filename.replace(/\.mdx$/, ''),
      })
    }
  }
  
  return params
}
```

### Gotchas

⚠️ **MDX requires absolute imports**: Use `@/` alias in tsconfig.json

💡 **Tip**: Use `gray-matter` to parse frontmatter from MDX files

---

## Feature 3: Metadata & SEO

### Why This Matters for Your Goal
Each blog post needs proper SEO metadata in the correct language.

### Your Implementation
```typescript
// app/[locale]/blog/[slug]/page.tsx
import { Metadata } from 'next'

export async function generateMetadata({ params }: BlogPostProps): Promise<Metadata> {
  const { locale, slug } = params
  const filePath = path.join(process.cwd(), 'content', locale, 'blog', `${slug}.mdx`)
  const fileContent = fs.readFileSync(filePath, 'utf-8')
  const { data } = matter(fileContent)
  
  return {
    title: data.title,
    description: data.description,
    alternates: {
      canonical: `/${locale}/blog/${slug}`,
      languages: {
        'ko': `/ko/blog/${slug}`,
        'en': `/en/blog/${slug}`,
      },
    },
  }
}
```

### Gotchas

💡 **SEO Tip**: Always provide `alternates.languages` for multilingual content

---

## Integration: Putting It All Together

### Complete File Structure
```
blog/
  app/
    [locale]/
      layout.tsx           # i18n provider
      page.tsx             # Homepage
      blog/
        page.tsx           # Blog list
        [slug]/
          page.tsx         # Blog post (dynamic route)
  content/
    ko/
      blog/
        first-post.mdx
        second-post.mdx
    en/
      blog/
        first-post.mdx
        second-post.mdx
  messages/
    ko.json                # Translations
    en.json
  middleware.ts            # Locale detection
  mdx-components.tsx       # MDX component customization
  i18n.ts                  # i18n config
  next.config.mjs          # MDX configuration
```

### How Features Connect

1. **User visits** `/ko/blog/first-post`
2. **Middleware** detects `ko` locale
3. **Next.js** routes to `app/[locale]/blog/[slug]/page.tsx`
4. **Server component** loads `content/ko/blog/first-post.mdx`
5. **MDX** renders with custom components
6. **Metadata** generates SEO tags in Korean

### Complete Blog List Page
```typescript
// app/[locale]/blog/page.tsx
import Link from 'next/link'
import { useTranslations } from 'next-intl'
import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'

export default function BlogList({
  params: { locale }
}: {
  params: { locale: string }
}) {
  const t = useTranslations('Blog')
  
  // Get all blog posts
  const postsDirectory = path.join(process.cwd(), 'content', locale, 'blog')
  const filenames = fs.readdirSync(postsDirectory)
  
  const posts = filenames.map((filename) => {
    const slug = filename.replace(/\.mdx$/, '')
    const filePath = path.join(postsDirectory, filename)
    const fileContent = fs.readFileSync(filePath, 'utf-8')
    const { data } = matter(fileContent)
    
    return {
      slug,
      title: data.title,
      date: data.date,
      description: data.description,
    }
  })
  
  return (
    <div className="max-w-4xl mx-auto py-12">
      <h1 className="text-4xl font-bold mb-8">{t('title')}</h1>
      <div className="space-y-8">
        {posts.map((post) => (
          <article key={post.slug} className="border-b pb-8">
            <Link href={`/${locale}/blog/${post.slug}`}>
              <h2 className="text-2xl font-semibold hover:text-blue-600">
                {post.title}
              </h2>
            </Link>
            <time className="text-gray-500">{post.date}</time>
            <p className="mt-2">{post.description}</p>
          </article>
        ))}
      </div>
    </div>
  )
}
```

---

## Testing Checklist

- [ ] Visit `/ko/blog` → Shows Korean blog list
- [ ] Visit `/en/blog` → Shows English blog list
- [ ] Click blog post → Correct language content displays
- [ ] MDX components render (headings, images, code blocks)
- [ ] Change URL from `/ko/blog/post` to `/en/blog/post` → Language switches
- [ ] Check page source → Meta tags in correct language
- [ ] Check browser console → No errors or warnings

---

## Common Issues & Solutions

### Issue 1: MDX Import Error
**Symptom:** `Cannot find module '@/content/...'`
**Solution:** Ensure `tsconfig.json` has path alias:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

### Issue 2: Images in MDX Don't Load
**Symptom:** Images show as broken links
**Solution:** Add proper Next.js Image configuration in `mdx-components.tsx`:
```typescript
img: (props) => (
  <Image
    src={props.src || ''}
    alt={props.alt || ''}
    width={800}
    height={600}
  />
)
```

### Issue 3: Locale Not Detected
**Symptom:** Always shows default locale
**Solution:** Check `middleware.ts` matcher pattern excludes API routes and static files

---

## References

- [Official i18n Docs](https://nextjs.org/docs/app/building-your-application/routing/internationalization)
- [Official MDX Docs](https://nextjs.org/docs/app/building-your-application/configuring/mdx)
- [next-intl Documentation](https://next-intl-docs.vercel.app/)
- [Example Repository](https://github.com/vercel/next.js/tree/canary/examples/app-dir-i18n-routing)
