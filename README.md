# PartyVibe 🎉

A Progressive Web App for social gatherings. No app download needed — guests scan a QR code and join instantly.

## What's in this folder

```
partyvibe-project/
│
├── partyvibe-supabase.html   ← The app (Supabase backend) ✅
│
├── partyvibe-setup.sql       ← Run this in Supabase SQL Editor first
│
├── .env.local                ← Your Supabase credentials
│
├── stitch/                   ← Design mockups (one screen.png per screen)
│
└── utils/supabase/
    ├── client.ts             ← Browser client helper (for Next.js)
    ├── server.ts             ← Server client helper (for Next.js)
    └── middleware.ts         ← Middleware helper (for Next.js)
```

> **Design:** the UI follows the **Stitch** mockups in `stitch/` — a dark-navy
> base with a hot-pink neon accent and a warm-gold secondary. The host's **Party
> Vibe** chip (Neon Night · Golden Hour · Tropical · Chill · Retro) recolours the
> whole app for that event.

---

## Quick Start (5 steps)

### Step 1 — Run the database setup
1. Go to [supabase.com](https://supabase.com) → your project
2. Open **SQL Editor** → New Query
3. Paste the entire contents of `partyvibe-setup.sql` → click **Run**

This creates:
- `events` table
- `guests` table
- `quiz_answers` table
- `photos` table
- `increment_reaction()` SQL function
- Row Level Security policies
- Realtime enabled on guests + photos
- `partyvibe` storage bucket

### Step 2 — Credentials are already set
Your `.env.local` already has your live credentials.
The credentials are also pre-filled at the top of `partyvibe-supabase.html`:

```js
const SUPABASE_URL = 'https://zkxajwmyffymzkwnmvvg.supabase.co';
const SUPABASE_KEY = 'sb_publishable_jDhqCshcUJQFpgiVbtuBrQ_v_6lLnaf';
```

### Step 3 — Deploy the HTML file
Deploy `partyvibe-supabase.html` to any static host:

**Vercel (recommended):**
```bash
npx vercel --prod
```

**Netlify:**
Drag and drop the HTML file at [app.netlify.com/drop](https://app.netlify.com/drop)

**GitHub Pages:**
Push the HTML file renamed to `index.html` in a repo, enable Pages.

### Step 4 — Host a party
1. Open the deployed URL
2. Click **Host a Gathering**
3. Fill in party name, theme, pick colours and font
4. Click **Activate** — a QR code appears
5. Display the QR code on a screen or print it

### Step 5 — Guests join
1. Guests scan the QR code with their phone camera
2. Enter their name → take a selfie → pick a game
3. Play **Hot Take Showdown** to find matches
4. Play **Be the Memory Hero** to take group photos

---

## Features

| Feature | Description |
|---|---|
| 🎨 5 Party Vibes | Neon Night, Golden Hour, Tropical, Chill, Retro |
| 🔤 5 Font Options | Jakarta (default), Syne, Georgia, Mono, Trebuchet |
| 🔥 Hot Take Showdown | 4-question quiz → match by answer similarity → selfie reveal |
| 📸 Memory Hero | Surprise group photo themes → shared gallery |
| ❤️ Reactions | Heart, Fire, Laugh, Wow on every photo |
| 🔒 Privacy | Selfies shown to matches only, purged at event end |
| ⚡ Realtime | Guest joins + gallery photos update live via Supabase |
| 📱 PWA | Works on any phone browser, no install needed |

---

## If you want to use Next.js instead

Install the packages:
```bash
npm install @supabase/supabase-js @supabase/ssr
```

The `utils/supabase/` helpers are ready to use in any Next.js 13+ App Router project.
Copy your `.env.local` to your Next.js project root.

---

## Purging data after an event

In the Host Panel → **End Event & Purge All Data**

This will:
- Delete all selfie images from Supabase Storage
- Delete all group photos from Supabase Storage  
- Mark the event as `purged = true` in the database
- Clear guest selfie URLs from the guests table

---

## Supabase Project Details

- **Project URL:** `https://zkxajwmyffymzkwnmvvg.supabase.co`
- **Storage bucket:** `partyvibe` (public)
- **Realtime tables:** `guests`, `photos`
