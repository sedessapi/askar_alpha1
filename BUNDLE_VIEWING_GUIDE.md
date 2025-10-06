# Bundle Viewing Guide

This guide explains how to view trust bundle contents using two complementary methods.

## Method 1: Isar Inspector (Developer Tool) 🔍

The Isar Inspector is a web-based tool that provides direct access to the database.

### How to Access:

1. Run your Flutter app in debug mode:
   ```bash
   flutter run -d emulator-5554
   ```

2. Look for the Isar Inspector URL in the terminal output:
   ```
   ╔══════════════════════════════════════════════════════╗
   ║                 ISAR CONNECT STARTED                 ║
   ╟──────────────────────────────────────────────────────╢
   ║ https://inspect.isar.dev/3.1.0+1/#/52750/...        ║
   ╚══════════════════════════════════════════════════════╝
   ```

3. Click the URL to open in your browser

### What You Can Do:

- **Browse Collections**: View all BundleRec, SchemaRec, and CredDefRec records
- **Search & Filter**: Find specific records by ID
- **Live Updates**: See database changes in real-time
- **Query Data**: Execute custom Isar queries
- **Export Data**: Copy/export records for analysis

### Best For:
- Debugging database issues
- Verifying data integrity
- Advanced inspection and queries
- Development and testing

---

## Method 2: In-App Expandable Cards (User-Friendly) 📱

Expandable cards in the Trust Bundle Settings page provide a user-friendly view.

### How to Access:

1. Open the app
2. Tap the **Settings icon** (⚙️) on the home page
3. Tap **"Preview Bundle"** to fetch the latest bundle
4. Scroll down to see expandable sections

### Available Sections:

#### 📋 Trusted Issuers Card
- Lists all trusted DIDs
- Expand each DID to see:
  - Schema IDs they can issue
  - Credential Definition IDs they can use
- Shows issuer count in title

#### 📄 Schemas Card
- Lists all schemas with names and versions
- Expand each schema to see:
  - Full schema ID
  - Attribute names (as chips)
- Color-coded: Blue

#### 🔑 Credential Definitions Card
- Lists all credential definitions with tags
- Expand each cred def to see:
  - Full credential definition ID
  - Associated schema ID
  - Type (e.g., "CL")
- Color-coded: Orange

### Best For:
- Quick overview of bundle contents
- Understanding trust relationships
- User-friendly exploration
- Production use

---

## When to Use Which Method?

| Task | Isar Inspector | In-App Cards |
|------|----------------|--------------|
| Quick preview before saving | ❌ | ✅ |
| See what's in database | ✅ | ❌ |
| User-friendly viewing | ❌ | ✅ |
| Debug database issues | ✅ | ❌ |
| Production environment | ❌ | ✅ |
| Development/testing | ✅ | ✅ |
| Export/copy data | ✅ | ❌ |

---

## Workflow Example:

1. **Preview** using in-app cards to see what will be downloaded
2. **Save to Database** to persist the bundle locally
3. **Verify** using Isar Inspector that data was saved correctly
4. **Browse** using in-app cards for day-to-day use

---

## Tips:

- **Isar Inspector** only works while the app is running in debug mode
- **In-app cards** show preview data (not yet saved) until you tap "Save to Database"
- **Database Contents** card always shows what's actually in Isar
- Use **Isar Inspector** URL from the latest terminal session (changes each run)
