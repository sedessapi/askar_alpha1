# Askar Import - User Guide

Complete guide for using the Askar Import application to download, import, verify, and manage Aries Askar wallet data.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Phase 1: Download Export](#phase-1-download-export)
3. [Phase 2: Import to Wallet](#phase-2-import-to-wallet)
4. [Phase 3: Verify Credentials](#phase-3-verify-credentials)
5. [Export Credential JSON](#export-credential-json)
6. [Understanding Wallet Data](#understanding-wallet-data)
7. [Tips & Best Practices](#tips--best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites
- Askar export server URL (e.g., `http://mary9.com:9070`)
- Profile/tenant name
- Wallet encryption key (Base58-encoded 32-byte key)

### Basic Workflow
```
1. Download Export → 2. Import to Wallet → 3. Verify Credentials → 4. Export JSON
     (Phase 1)            (Phase 2)              (Phase 3)          (Feature)
```

---

## Phase 1: Download Export

### Step 1: Enter Server Details

1. Open the **Download** tab
2. Enter **Server URL**
   - Example: `http://mary9.com:9070`
   - Must include protocol (`http://` or `https://`)
3. Enter **Profile Name**
   - Your wallet/tenant identifier
   - Case-sensitive
4. Use **Paste** buttons (⌘+V on macOS) if copying from elsewhere

### Step 2: Check Server Health

1. Click **"Check Health"** button
2. Wait for response:
   - ✅ Green: "Server is healthy!"
   - ❌ Red: "Server health check failed"
3. If failed, verify:
   - Server URL is correct
   - Server is running
   - Network connectivity

### Step 3: Download Export

1. After successful health check, click **"Download Export JSON"**
2. Monitor progress in status messages
3. Export saved to device documents directory
4. View download summary:
   - Total records count
   - Categories breakdown
   - File location

### Step 4: View Downloaded Files

**View Current Export:**
- Click **"View File Contents"** to see JSON viewer

**Browse All Exports:**
- Click **"View All Files"** to see all downloaded exports
- Each file shows:
  - Filename
  - Modification date/time
  - File size
  - Quick actions (View, Delete)

### JSON Viewer Features

- **Toggle Format**: Switch between formatted and raw JSON
- **Copy to Clipboard**: Copy entire JSON content
- **Export Summary**: See statistics and categories
- **Syntax Highlighting**: Easy-to-read formatted JSON
- **Search**: Find specific content (browser Cmd+F)

---

## Phase 2: Import to Wallet

### Step 1: Create Wallet

1. Open the **Import** tab
2. Enter **Wallet Name**
   - Example: `my_wallet`
   - Used for database filename
3. Enter **Wallet Key** (Base58-encoded)
   - Example: `8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K`
   - ⚠️ **Important**: Save this key securely!
4. Click **"Create New Wallet"**
5. Wait for confirmation: "Wallet created successfully"

### Step 2: Select Export File

1. In **"Select Export File"** section
2. Browse available exports
3. Click to select file (highlights in blue)
4. File shows:
   - Filename
   - Modification date
   - Size

### Step 3: Import Data

1. With file selected, click **"Import Selected File"**
2. Monitor import progress:
   - Status updates in real-time
   - Shows "Importing entries..."
3. View import results:
   - Total entries imported
   - Failed entries (if any)
   - Per-category statistics
   - Success/failure breakdown

### Step 4: View Wallet Contents

1. After successful import, see **"Wallet Contents"** section
2. Shows:
   - Total entries count
   - Categories with counts
3. Click **"View All"** to browse entries

---

## Phase 3: Verify Credentials

### What is Verification?

Structural validation of credentials to ensure they are properly formatted. This is **offline validation** - no network calls or cryptographic signature verification.

### Supported Formats

✅ **W3C Verifiable Credentials**
- Standard format with `@context`, `credentialSubject`, `issuer`, `proof`

✅ **AnonCreds/Indy Credentials**
- Hyperledger Indy format with `schema_id`, `cred_def_id`, `values`, `signature`

✅ **Legacy Indy Credentials**
- Raw credentials with `values` or `attrs` fields

### How to Verify

1. Go to **Import** tab
2. Click **"View All"** entries
3. **Credentials are sorted to the top** for easy access
4. Click any credential entry
5. Click **"Verify Credential"** button
6. Results appear automatically below

### Understanding Results

#### Overall Verdict (Large Icon at Top)

**✓ VALID (Green)**
- All critical checks passed
- Credential is structurally sound
- May have minor warnings

**⚠ VALID WITH WARNINGS (Orange)**
- Credential is valid but has non-critical issues
- Common for AnonCreds (missing W3C fields is expected)
- Review warnings to understand differences

**✗ INVALID (Red)**
- Critical issues found
- Review failed checks
- May not be a credential (could be connection, schema, etc.)

#### Statistics Badges

Quick overview of check results:
- `✓ 12` - Passed checks
- `⚠ 3` - Warnings
- `✗ 2` - Failed checks
- `○ 1` - Skipped checks

#### Critical Issues Section (Red Box)

Shows immediately if any checks failed:
- Missing required fields
- Expired credentials
- Invalid formats
- etc.

#### Detailed Checks (Collapsible)

Organized by category:

**Structure**
- Required fields present
- Proper JSON format
- Credential type validation

**Dates**
- Issuance date validation
- Expiration checking
- Warns if expires soon (<30 days)

**Signatures**
- Proof/signature structure
- Required signature fields
- AnonCreds signature detection

**DIDs**
- DID format validation
- Issuer/subject DID checks
- Verification method validation

### AnonCreds Credentials

AnonCreds credentials typically show **"VALID WITH WARNINGS"**:

```
⚠ VALID WITH WARNINGS

Structure:
  ✓ credentialSubject - AnonCreds/Indy credential format detected
  ✓ proof - AnonCreds signature_correctness_proof present
  ⚠ @context - @context field missing (not W3C format)
  ⚠ issuer - issuer field missing (not W3C format)
```

**This is normal!** AnonCreds use a different structure than W3C VCs. Warnings about missing W3C fields are expected and don't indicate problems.

---

## Export Credential JSON

### Quick Copy Feature

Copy any credential's JSON with one click!

### How to Use

1. Open any credential (from View All)
2. Find **"Copy JSON"** button (bottom-left)
3. Click button
4. See green confirmation: "JSON copied to clipboard!"
5. Paste anywhere (Cmd+V or Ctrl+V)

### Features

✅ **Pretty-Printed** - 2-space indentation for readability
✅ **Auto-Format** - Parses strings and formats objects automatically
✅ **All Formats** - Works with any data type (credentials, schemas, etc.)
✅ **Error Handling** - Clear messages if copy fails

### Use Cases

**Save to File**
```bash
# After copying, save to file:
pbpaste > credential.json          # macOS
xclip -o > credential.json          # Linux
Get-Clipboard > credential.json    # Windows PowerShell
```

**Share with Team**
- Copy and paste into Slack/Email
- Use secure channels for sensitive data

**Debug Issues**
- Copy and inspect in external tools
- Use online JSON validators
- Compare multiple credentials

**Import Elsewhere**
- Copy from one wallet
- Import into another application

### Security Warning ⚠️

Credentials may contain PII (Personally Identifiable Information):
- ✅ Clear clipboard after use
- ✅ Use encrypted storage
- ✅ Share via secure channels only
- ❌ Don't paste in public forums
- ❌ Don't leave in clipboard overnight

---

## Understanding Wallet Data

### Why Multiple Data Types?

Aries Askar wallets are **complete identity ecosystems**, not just credential storage. They contain everything needed for credential management.

### Data Categories

#### 🎫 Credentials
**What**: Your verifiable credentials (diplomas, licenses, health records, etc.)
**Why**: The actual credentials you care about

#### 📋 Schemas
**What**: Data structure definitions for credentials
**Why**: Defines what fields credentials can have
**Analogy**: Blank form templates

#### 📜 Credential Definitions
**What**: Issuer-specific metadata about credential issuance
**Why**: Proves credentials are from legitimate issuers
**Analogy**: Notary's official seal

#### 🤝 Connections
**What**: Peer-to-peer connection records with other agents
**Why**: Maintains secure channels with issuers/verifiers
**Analogy**: Contacts in your phone

#### 🔐 DIDs (Decentralized Identifiers)
**What**: Your digital identities and associated keys
**Why**: Proves ownership of credentials
**Analogy**: Your passport number

#### 🔑 Keys
**What**: Cryptographic key pairs
**Why**: Signs and encrypts your data

#### 🚫 Revocation Registries
**What**: Tracks revoked credentials
**Why**: Checks if credentials are still valid

### Why Export All Types?

**Complete Wallet Migration**
- Credentials remain verifiable (need schemas + definitions)
- Relationships preserved (connections)
- Identity continuity (DIDs + keys)
- Full functionality (all components work together)

**Real-World Analogy**

Like moving to a new phone:
- 📸 Photos = Credentials (what you want)
- 📇 Contacts = Connections (who you know)
- 🆔 Accounts = DIDs & Keys (who you are)
- 📱 Apps = Schemas & Definitions (tools to use data)

You need **all of them** for your phone to work!

### Viewing by Category

In "View All" dialog, entries are grouped:
```
Wallet Entries (150 total)
├─ 🎫 credential (100 entries)         ← Always at top!
├─ 📋 schema (20 entries)
├─ 📜 credential_definition (15 entries)
├─ 🤝 connection (10 entries)
└─ 🔐 did (5 entries)
```

Each category:
- Has its own icon
- Shows entry count
- Can be expanded/collapsed
- Sorted with credentials first

---

## Tips & Best Practices

### Wallet Management

**Key Storage**
- ✅ Save wallet keys in password manager
- ✅ Use platform keychain (iOS Keychain, Android KeyStore)
- ❌ Never hardcode keys in applications
- ❌ Don't store keys in plain text files

**Backup Strategy**
- Export wallet regularly
- Store exports in encrypted backup
- Test restore process periodically
- Keep multiple backup copies

**Security**
- Use HTTPS for production servers
- Validate server certificates
- Use strong encryption keys (32 bytes random)
- Rotate keys periodically

### Import Best Practices

**Before Importing**
- Check export file integrity
- Verify file size is reasonable
- Review export summary
- Ensure sufficient storage space

**During Import**
- Don't interrupt the process
- Monitor progress messages
- Note any failed entries
- Check import statistics

**After Import**
- Verify total entry count
- Browse categories to confirm
- Test credential verification
- Confirm connections preserved

### Verification Tips

**When to Verify**
- After importing credentials
- Before presenting credentials
- When troubleshooting issues
- To understand credential structure

**Interpreting Results**
- Green (VALID) = Good to use
- Orange (WARNINGS) = Check warnings, usually OK for AnonCreds
- Red (INVALID) = Investigate failed checks

**Common Warnings**
- Missing W3C fields on AnonCreds → **Normal**
- Credential expires soon → **Important to note**
- Non-standard fields → **May be custom implementation**

---

## Troubleshooting

### Download Issues

**Problem**: "Server health check failed"
**Solutions**:
- Verify server URL includes protocol (`http://` or `https://`)
- Check server is running and accessible
- Test network connectivity
- Try HTTP instead of HTTPS for local servers
- Check firewall/proxy settings

**Problem**: "Profile not found (404)"
**Solutions**:
- Verify profile name spelling (case-sensitive)
- Check profile exists on server
- Contact server administrator
- Try different profile name

**Problem**: "Authentication required (401)"
**Solutions**:
- Server requires authentication (not currently supported)
- Contact server administrator
- Check if server configuration changed

### Import Issues

**Problem**: "Failed to open store"
**Solutions**:
- Verify wallet was created successfully
- Check wallet key is correct (Base58-encoded)
- Ensure wallet file exists
- Try creating new wallet
- Check file permissions

**Problem**: "Invalid JSON format"
**Solutions**:
- Re-download export file
- Check file isn't corrupted
- Verify export file is complete
- Try different export

**Problem**: "Some entries failed to import"
**Solutions**:
- Check import statistics for details
- Review failed entry names
- Verify export format matches expected structure
- May be non-standard data (usually OK if most succeed)

### Verification Issues

**Problem**: "Not a Verifiable Credential"
**Solution**: You selected a non-credential entry (connection, schema, etc.). This is expected - verification only works on credentials.

**Problem**: "All checks failed"
**Solutions**:
- May not be a credential
- Check if file is corrupted
- Verify JSON structure
- Try re-importing

**Problem**: "Credential expired"
**Solution**: The credential's expiration date has passed. Contact issuer for renewal.

### JSON Export Issues

**Problem**: "No data to copy"
**Solutions**:
- Credential value is null/empty
- Try re-importing wallet
- Check if entry loaded correctly

**Problem**: "Failed to copy"
**Solutions**:
- Check clipboard permissions (mobile)
- Restart application
- Try again
- Check system clipboard manager

**Problem**: "Pasted JSON not formatted"
**Solution**: Original data wasn't valid JSON. The raw string was copied. Format manually using online JSON formatter.

### Performance Issues

**Problem**: Slow import
**Solutions**:
- Large wallets take time (normal)
- Don't interrupt process
- Ensure device has sufficient resources
- Close other applications

**Problem**: App crashes during import
**Solutions**:
- Check available memory
- Try smaller export files
- Update to latest version
- Check device logs for errors

### UI Issues

**Problem**: "Can't find credential category"
**Solution**: Credential category is now **sorted to the top** automatically. If not visible, try refreshing the view.

**Problem**: "Verification results hidden"
**Solution**: Results auto-scroll into view. If not visible, manually scroll down or try verification again.

**Problem**: "Dialog too small to see all content"
**Solution**: Scroll within the dialog. On desktop, try resizing window.

---

## Need More Help?

### Resources
- **README.md** - Project overview and features
- **DEVELOPER_GUIDE.md** - Technical details and architecture
- **FAQ.md** - Common questions and answers

### Support
- GitHub Issues: [sedessapi/askar_import](https://github.com/sedessapi/askar_import/issues)
- Check existing issues first
- Provide detailed error messages
- Include steps to reproduce

### Contributing
- Report bugs via GitHub Issues
- Suggest features
- Submit pull requests
- Help improve documentation

---

**Version**: 1.0.0  
**Last Updated**: October 4, 2025  
**License**: See project LICENSE file
