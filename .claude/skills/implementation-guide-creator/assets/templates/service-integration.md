# {goal} - {target} Integration Guide

## Context
- **Service:** {target}
- **Integration Goal:** {goal}
- **Integration Type:** [SDK / API / Webhook / All]
- **Last Updated:** {date}
- **Service Version/API Version:** [Version if applicable]

---

## Overview

**What you're integrating:** [Brief description of the service]

**Why you need it:** [How it fits into your goal]

**What you'll set up:**
- [ ] [Component 1, e.g., SDK installation]
- [ ] [Component 2, e.g., API authentication]
- [ ] [Component 3, e.g., Webhook endpoint]

---

## Prerequisites

Before starting, ensure you have:
- [ ] Account created at [{target}](URL)
- [ ] [Other requirement, e.g., verified email]
- [ ] [Other requirement, e.g., payment method if needed]

---

## Part 1: Credentials & Configuration

### Step 1: Generate API Keys

1. [Detailed steps to get credentials]
2. [Include screenshots or exact navigation path]
3. [What to save and where]

**Credentials you'll need:**
- `API_KEY` / `PUBLIC_KEY`: [What it's for]
- `SECRET_KEY` / `PRIVATE_KEY`: [What it's for]
- `WEBHOOK_SECRET`: [If applicable]

### Step 2: Environment Variables

```env
# .env.local
{TARGET}_API_KEY=your_public_key_here
{TARGET}_SECRET_KEY=your_secret_key_here
{TARGET}_WEBHOOK_SECRET=your_webhook_secret_here
```

⚠️ **Security:** Never commit `.env.local` to git. Add to `.gitignore`.

---

## Part 2: SDK Installation (if applicable)

### Installation
```bash
npm install {package-name}
```

### Initialization
```typescript
// lib/{service}.ts
import { ServiceClient } from '{package-name}'

export const {service}Client = new ServiceClient({
  apiKey: process.env.{TARGET}_API_KEY!,
  secretKey: process.env.{TARGET}_SECRET_KEY!,
})
```

---

## Part 3: API Integration (if applicable)

### Authentication

```typescript
// How to authenticate API requests
const headers = {
  'Authorization': `Bearer ${process.env.{TARGET}_API_KEY}`,
  'Content-Type': 'application/json',
}
```

### Core Endpoints

#### Endpoint 1: [Action Name]
**Purpose:** [What this does for your goal]

```typescript
// [Filename]
const response = await fetch('https://api.{service}.com/v1/[endpoint]', {
  method: 'POST',
  headers,
  body: JSON.stringify({
    // Request body
  })
})

const data = await response.json()
```

**Response:**
```json
{
  // Expected response structure
}
```

#### Endpoint 2: [Action Name]
[Similar structure]

---

## Part 4: Webhook Setup (if applicable)

### Step 1: Create Webhook Endpoint

```typescript
// app/api/webhooks/{service}/route.ts
import { headers } from 'next/headers'

export async function POST(req: Request) {
  const body = await req.text()
  const signature = headers().get('{service}-signature')
  
  // Verify webhook signature
  const isValid = verifyWebhookSignature(body, signature)
  if (!isValid) {
    return new Response('Invalid signature', { status: 401 })
  }
  
  const event = JSON.parse(body)
  
  // Handle different event types
  switch (event.type) {
    case '[event_type_1]':
      // Handle event
      break
    case '[event_type_2]':
      // Handle event
      break
  }
  
  return new Response('OK', { status: 200 })
}

function verifyWebhookSignature(body: string, signature: string): boolean {
  // Verification logic from {service} documentation
  const expectedSignature = /* compute signature */
  return signature === expectedSignature
}
```

### Step 2: Register Webhook URL

1. Go to [{Service} Dashboard](URL)
2. Navigate to [Path to webhooks section]
3. Add webhook URL: `https://your-domain.com/api/webhooks/{service}`
4. Select events: [List relevant events]
5. Save and note the webhook secret

---

## Your Implementation

Complete example combining all parts:

```typescript
// [Filename] - Full integration for {goal}
[Complete working code that uses SDK/API/Webhooks for the specific goal]
```

---

## Testing Your Integration

### Test Checklist
- [ ] Credentials configured correctly
- [ ] SDK/API call successful: [Test specific call]
- [ ] Webhook endpoint responds to test events
- [ ] Error handling works (test with invalid data)
- [ ] Production environment variables set

### How to Test

**SDK/API:**
```typescript
// test-{service}.ts
// Simple test script
```

**Webhooks:**
Use [{Service}]'s test webhook feature or tools like:
- Webhook testing dashboard (if available)
- `curl` command to simulate webhook

```bash
curl -X POST http://localhost:3000/api/webhooks/{service} \
  -H "Content-Type: application/json" \
  -H "{Service}-Signature: test_signature" \
  -d '{"type":"test","data":{}}'
```

---

## Error Handling

### Common Errors

#### Error 1: `[Error Code/Message]`
**Cause:** [Why this happens]
**Solution:** [How to fix]

#### Error 2: Authentication Failed
**Cause:** Invalid API key or signature
**Solution:**
- Verify API keys in `.env.local`
- Check key hasn't expired
- Ensure using correct environment (test vs prod)

#### Error 3: Webhook Signature Invalid
**Cause:** Signature verification failing
**Solution:**
- Verify webhook secret is correct
- Check signature algorithm matches docs
- Ensure raw body is used (not parsed JSON)

---

## Validation Checklist

Cross-check your implementation against official docs:

- [ ] API URLs match official documentation
- [ ] Authentication method is correct
- [ ] Request/response formats match specs
- [ ] Webhook signature verification follows official method
- [ ] Error codes handled according to docs
- [ ] Rate limits considered

---

## References

- [Official Documentation](URL)
- [API Reference](URL)
- [Webhook Documentation](URL)
- [SDK Documentation](URL) (if using SDK)
- [Example Repository](URL) (if available)

---

## Production Checklist

Before going live:
- [ ] Production API keys configured
- [ ] Webhook URL uses HTTPS
- [ ] Error logging set up
- [ ] Rate limiting handled
- [ ] Monitoring for failed webhooks
- [ ] Test mode disabled
