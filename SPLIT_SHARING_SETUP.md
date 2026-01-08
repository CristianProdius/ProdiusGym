# Split Sharing Setup Guide

## What Was Fixed

The split sharing feature was generating URLs that were **too long** (thousands of characters) because it embedded the entire split data in the URL. This has been fixed to use CloudKit's public database as the source of truth.

## Changes Made

### 1. CloudKitManager.swift
- **Simplified URL generation** to only include the split ID
- **Before:** `https://shadowlift.app/splits/{id}?data=<huge-base64-string>`
- **After:** `https://shadowlift.app/splits/{id}`
- Split data is stored in CloudKit public database and fetched on-demand

### 2. Info.plist
- Added `CFBundleURLTypes` to register the `shadowlift://` custom URL scheme
- This allows deep links like `shadowlift://import-split/{id}`

### 3. Gymly.entitlements
- Added `com.apple.developer.associated-domains` with `applinks:shadowlift.app`
- This enables Universal Links so web URLs automatically open the app

### 4. GymlyApp.swift
- Added `handleWebLink()` function to handle `https://shadowlift.app/splits/{id}` URLs
- App now handles both:
  - Custom URL scheme: `shadowlift://import-split/{id}`
  - Web URLs: `https://shadowlift.app/splits/{id}`

## How It Works Now

```
User shares split
    ↓
CloudKit saves to public database with record name "shared_{splitID}"
    ↓
Generates clean URL: https://shadowlift.app/splits/{splitID}
    ↓
Recipient taps link (in Messages, Safari, etc.)
    ↓
iOS opens Gymly app (via Universal Links)
    ↓
App fetches split from CloudKit public database
    ↓
Split imported successfully!
```

## Server-Side Configuration Required

⚠️ **IMPORTANT:** For Universal Links to work, you need to host a file at:
```
https://shadowlift.app/.well-known/apple-app-site-association
```

### apple-app-site-association File Content

Create this JSON file (no file extension):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.icservis.GymlyFitness",
        "paths": [
          "/splits/*"
        ]
      }
    ]
  }
}
```

**Replace `TEAM_ID` with your Apple Developer Team ID** (found in Apple Developer account)

### Server Configuration

1. Host the file at: `https://shadowlift.app/.well-known/apple-app-site-association`
2. File must be served with `Content-Type: application/json`
3. File must be accessible without redirects
4. HTTPS is required (not HTTP)

### Testing the File

Test the file is accessible:
```bash
curl -I https://shadowlift.app/.well-known/apple-app-site-association
```

Should return:
```
HTTP/2 200
content-type: application/json
```

## Testing the Integration

### 1. Share a Split
- Open Gymly app
- Navigate to a split
- Tap "More" (ellipsis) → "Share Split"
- You'll get a URL like: `https://shadowlift.app/splits/6CA27CD9-8102-4C4F-B860-81A8EDE52F8F`

### 2. Import via Web URL (after server setup)
- Send the URL via Messages to another device/person
- Tap the link → Should automatically open Gymly and import the split

### 3. Import via Deep Link (works immediately)
Convert the web URL to deep link format:
```
https://shadowlift.app/splits/{id}
↓
shadowlift://import-split/{id}
```

Example:
```
shadowlift://import-split/6CA27CD9-8102-4C4F-B860-81A8EDE52F8F
```

## Fallback Behavior

If CloudKit sharing fails, the app automatically falls back to file-based export (`.shadowliftsplit` files).

## CloudKit Public Database

Shared splits are stored in CloudKit's **public database** with:
- **Record Type:** `SharedSplit`
- **Record Name:** `shared_{splitID}`
- **Fields:**
  - `splitData` (Data) - Full split JSON
  - `splitName` (String) - Split name for preview
  - `splitDays` (Int) - Number of days
  - `totalExercises` (Int) - Total exercise count
  - `createdAt` (Date) - Share timestamp
  - `version` (Int) - Schema version for future compatibility

## Troubleshooting

### "Split not found" Error
- Split may not have been uploaded to CloudKit yet (check network connection)
- Split ID in URL doesn't match any record in CloudKit public database
- CloudKit public database permissions issue

### Universal Links Not Working
- `apple-app-site-association` file not configured correctly on server
- File not accessible or returns wrong Content-Type
- DNS/SSL issues with shadowlift.app domain
- Try the deep link format instead: `shadowlift://import-split/{id}`

### Share Sheet Shows Web URL but No App Option
- Universal Links take 24-48 hours to propagate after app installation
- Try uninstalling and reinstalling the app
- Make sure the `apple-app-site-association` file is properly hosted

## Next Steps

1. **Deploy the `apple-app-site-association` file** to shadowlift.app server
2. **Test on a real device** (Universal Links don't work in simulator)
3. **Share splits between devices** to verify end-to-end flow
4. **Monitor CloudKit usage** in CloudKit Dashboard (public database has limits)

## Benefits of This Approach

✅ **Short, shareable URLs** (~50 chars instead of thousands)
✅ **Works everywhere** - Messages, WhatsApp, Discord, email, etc.
✅ **No encoding issues** - Simple, clean URLs
✅ **Better UX** - URLs are readable: `shadowlift.app/splits/{id}`
✅ **Updateable** - Can update split data in CloudKit without changing URL
✅ **Scalable** - CloudKit handles the data storage and CDN
✅ **Privacy-focused** - Only share what you want, when you want

## Security Considerations

- Shared splits are **public** - anyone with the link can import them
- Split IDs are UUIDs - hard to guess but not secret
- No personal data is shared (no user profiles, progress photos, or workout history)
- Only the split structure (exercises, sets, reps) is shared

## CloudKit Quotas

CloudKit public database has limits:
- **Free tier:** 10GB storage, 2GB daily transfer
- Shared splits are small (~5-50KB each)
- Should handle thousands of shares before hitting limits
- Monitor usage in CloudKit Dashboard
