# Viewing Imported Credentials

## Overview

After importing wallet entries, you can view all credentials in detail through the new "View All" button.

## How to View Credentials

### 1. After Import
Once you've successfully imported entries into your wallet, you'll see the **Wallet Contents** card showing:
- Total number of entries
- Breakdown by category

### 2. Click "View All" Button
Look for the **"View All"** button in the top-right corner of the Wallet Contents card.

### 3. Explore the Entries Dialog
The dialog shows:
- **Grouped by Category**: Credentials, Connections, DIDs, Keys, etc.
- **Expandable sections**: Click to expand/collapse categories
- **Entry count**: See how many entries in each category
- **Entry preview**: Name and truncated value

### 4. View Entry Details
Click on any entry to see:
- **Category**: The entry's category
- **Name**: Full entry name
- **Value**: Complete credential/data (selectable for copy)
- **Tags**: Associated tags (if any)

## Features

### Category Icons
Each category has a distinct icon:
- 🎫 **Credentials**: Card membership icon
- 👥 **Connections**: People icon
- 🔐 **DIDs**: Fingerprint icon
- 📋 **Schemas**: Schema icon
- 🔑 **Keys**: VPN key icon
- 🏷️ **Other**: Label icon

### Entry Actions
- **Tap entry**: View full details in popup
- **Long press**: Select text to copy
- **Expand/Collapse**: Toggle category sections

### Data Display
- **Truncated preview**: First 50 characters shown in list
- **Full view**: Click entry to see complete data
- **Selectable text**: Copy values directly from detail view
- **Monospace font**: Easy to read JSON/encoded data

## Example Workflow

```
1. Import wallet entries
   ↓
2. See "Wallet Contents" card with stats
   ↓
3. Click "View All" button
   ↓
4. Browse categories (Credentials, Connections, etc.)
   ↓
5. Click specific entry to see full details
   ↓
6. Copy credential data if needed
```

## Screenshots Reference

### Main Wallet Stats
```
┌─────────────────────────────────────┐
│ Wallet Contents        [View All] ← Click here
│ Total Entries: 25                   │
│                                     │
│ Categories:                         │
│  • credentials: 10                  │
│  • connections: 8                   │
│  • dids: 7                          │
└─────────────────────────────────────┘
```

### Entries Dialog
```
┌─────────────────────────────────────┐
│ 📂 Wallet Entries (25 total)    [×] │
├─────────────────────────────────────┤
│ ▼ 🎫 credentials (10 entries)       │
│    🔑 credential-123                 │
│       Value: {"@context":...        │
│    🔑 credential-456                 │
│       Value: {"@context":...        │
│                                     │
│ ▼ 👥 connections (8 entries)        │
│    🔑 connection-abc                 │
│       Value: {"did":"did:sov...     │
│                                     │
│ ▼ 🔐 dids (7 entries)               │
│    🔑 did:sov:XyZ123                │
│       Value: {"verkey":"Ed...       │
└─────────────────────────────────────┘
```

### Entry Details Dialog
```
┌─────────────────────────────────────┐
│ ℹ️ credential-123               [×] │
├─────────────────────────────────────┤
│ Category:  credentials              │
│ Name:      credential-123           │
│ ─────────────────────────────────   │
│ Value:                              │
│ ┌─────────────────────────────────┐ │
│ │ {                               │ │
│ │   "@context": [...],            │ │
│ │   "type": ["VerifiableCreden... │ │
│ │   "credentialSubject": {...}    │ │
│ │ }                               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Tags:                               │
│ [encrypted] [imported]              │
│                                     │
│                          [Close]    │
└─────────────────────────────────────┘
```

## Tips

### Finding Specific Credentials
1. Use the category grouping to narrow down
2. Look for recognizable names in the entry list
3. Use the search feature (if added in future)

### Copying Credential Data
1. Click entry to open details
2. Select the value text
3. Copy (Ctrl+C / Cmd+C)
4. Paste into your application

### Understanding Entry Structure
- **Name**: Unique identifier for the entry
- **Value**: The actual credential data (often JSON)
- **Category**: Type/classification (credentials, connections, etc.)
- **Tags**: Metadata flags (encrypted, etc.)

## Troubleshooting

### "No entries found in wallet"
- Import hasn't completed yet
- Wallet is empty
- Wrong wallet loaded

### "Error loading entries"
- Wallet file might be corrupted
- Incorrect raw key
- Database connection issue

### Can't see full value
- Click the entry to open detail dialog
- Value is displayed in a scrollable container
- Use text selection to copy if needed

## Advanced Usage

### Exporting Individual Entries
Currently, the app shows read-only views. To export specific credentials:
1. View the entry details
2. Copy the value
3. Paste into a text editor or application

### Filtering by Category
The entries are automatically grouped by category. Collapse/expand sections to focus on specific types.

### Searching (Future Feature)
A search bar could be added to filter entries by name or value. This would be helpful for wallets with many entries.

---

**Note**: All credential data is displayed from the encrypted Askar wallet. The values are decrypted only when viewing and are kept secure in the wallet storage.
