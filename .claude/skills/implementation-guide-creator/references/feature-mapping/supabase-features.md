# Supabase Feature Mapping

Reference for mapping user goals to Supabase features and documentation.

## Authentication Features

### Email/Password Auth
- **Use when:** Standard user registration and login
- **Official docs:** https://supabase.com/docs/guides/auth/auth-email
- **Related sections:**
  - Auth > Email Auth
  - Sign up, Sign in, Sign out
- **Core APIs:** `signUp()`, `signInWithPassword()`, `signOut()`
- **Keywords:** signup, login, register, email, password

### OAuth Providers
- **Use when:** Social login (Google, GitHub, etc.)
- **Official docs:** https://supabase.com/docs/guides/auth/social-login
- **Related sections:**
  - Auth > Social Login
  - Provider configuration
- **Core APIs:** `signInWithOAuth()`, provider configs
- **Keywords:** Google login, GitHub auth, social login, OAuth

### Session Management
- **Use when:** Checking auth state, protected routes
- **Official docs:** https://supabase.com/docs/guides/auth/sessions
- **Related sections:**
  - Auth > Sessions
  - Server-side auth
  - onAuthStateChange
- **Core APIs:** `getSession()`, `getUser()`, `onAuthStateChange()`
- **Keywords:** session, current user, logged in, auth state

### Row Level Security (RLS)
- **Use when:** Securing database access (ALWAYS!)
- **Official docs:** https://supabase.com/docs/guides/auth/row-level-security
- **Related sections:**
  - Auth > Row Level Security
  - Policies
- **Core APIs:** RLS policies, `auth.uid()`
- **Keywords:** security, permissions, access control, RLS

## Database Features

### CRUD Operations
- **Use when:** Reading/writing data (most common)
- **Official docs:** https://supabase.com/docs/guides/database/overview
- **Related sections:**
  - Database > Queries
  - Insert, Select, Update, Delete
- **Core APIs:** `from()`, `select()`, `insert()`, `update()`, `delete()`
- **Keywords:** query, fetch, create, read, update, delete, CRUD

### Realtime Subscriptions
- **Use when:** Live updates, chat, collaborative features
- **Official docs:** https://supabase.com/docs/guides/realtime
- **Related sections:**
  - Realtime > Overview
  - Channel subscriptions
  - Database changes
- **Core APIs:** `channel()`, `on('postgres_changes')`, `subscribe()`
- **Keywords:** realtime, live, websocket, chat, notifications, updates

### Joins & Relations
- **Use when:** Related data, foreign keys
- **Official docs:** https://supabase.com/docs/guides/database/joins-and-nesting
- **Related sections:**
  - Database > Joins
  - Foreign key relations
- **Core APIs:** `.select('*, table2(*)')`, foreign key syntax
- **Keywords:** join, relation, foreign key, nested data

### Full-Text Search
- **Use when:** Search functionality
- **Official docs:** https://supabase.com/docs/guides/database/full-text-search
- **Related sections:**
  - Database > Full-Text Search
  - textSearch function
- **Core APIs:** `textSearch()`, `tsquery`, `tsvector`
- **Keywords:** search, find, query, text search

## Storage Features

### File Upload
- **Use when:** User uploads (images, documents, etc.)
- **Official docs:** https://supabase.com/docs/guides/storage
- **Related sections:**
  - Storage > Uploads
  - Bucket policies
- **Core APIs:** `upload()`, `buckets`, storage policies
- **Keywords:** upload, file, image, document, storage

### Public/Private Files
- **Use when:** Controlling file access
- **Official docs:** https://supabase.com/docs/guides/storage/security/access-control
- **Related sections:**
  - Storage > Security
  - Bucket policies
  - RLS for storage
- **Core APIs:** Bucket policies, `getPublicUrl()`, `createSignedUrl()`
- **Keywords:** public files, private files, signed URLs

## Edge Functions

### Serverless Functions
- **Use when:** Backend logic, API routes, webhooks
- **Official docs:** https://supabase.com/docs/guides/functions
- **Related sections:**
  - Edge Functions > Overview
  - Deploying functions
- **Core APIs:** Deno runtime, `serve()`, function deployment
- **Keywords:** serverless, function, API, backend, webhook

## Goal → Features Quick Reference

### "User authentication system"
→ Email auth OR OAuth, session management, RLS policies

### "Realtime chat app"
→ Auth, database CRUD, realtime subscriptions, RLS

### "Blog with user posts"
→ Auth, database CRUD, RLS (user-owned posts), storage (images)

### "Social media app"
→ Auth, database with relations, realtime, storage, full-text search

### "File sharing platform"
→ Auth, storage with policies, database (file metadata), signed URLs

### "Dashboard with live data"
→ Auth, database queries, realtime subscriptions

### "SaaS with API"
→ Auth, database, edge functions, RLS

## Version Notes

This mapping is for **Supabase v2** (current stable).

Always check for breaking changes in client library updates.

## Client Library Setup

### JavaScript/TypeScript
```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

### With Next.js (App Router)
Use `@supabase/ssr` package for server-side:
```typescript
import { createServerClient } from '@supabase/ssr'
```

## Common Mistakes to Prevent

1. **Don't skip RLS policies** → Database will be publicly accessible!
2. **Don't use service role key client-side** → Security risk
3. **Don't forget to enable realtime** → Must be enabled per table
4. **Don't hardcode credentials** → Use environment variables
5. **Don't forget storage policies** → Files won't be accessible

## Integration Patterns

### Next.js + Supabase Auth
1. Create Supabase client
2. Middleware for session refresh
3. Server components for protected routes
4. RLS policies on database

### Supabase Realtime Pattern
1. Create subscription channel
2. Listen to postgres_changes
3. Update UI on changes
4. Cleanup on unmount

### File Upload Pattern
1. Upload to storage bucket
2. Save metadata to database
3. Apply RLS policies to both
4. Generate signed URL if private
