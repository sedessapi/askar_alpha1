# UI Layout & Navigation Proposal

**Last Updated**: October 4, 2025  
**Purpose**: Define the final app structure with bottom navigation for future phases

---

## Overview

**Goal**: Create a professional, scalable UI structure that accommodates both Holder and Verifier modes with intuitive navigation.

**Approach**: Bottom Tab Navigation with mode-aware screens

---

## Proposed Bottom Navigation Bar

### 5-Tab Layout (Adaptive based on mode)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    SCREEN CONTENT                       │
│                                                         │
│                                                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  🏠      💳       📷       📋       ⚙️                   │
│  Home   Creds    Scan    Proofs  Settings              │
└─────────────────────────────────────────────────────────┘
```

---

## Tab-by-Tab Breakdown

### Tab 1: 🏠 Home (Dashboard)

**Purpose**: Quick overview and mode-specific actions

**Holder Mode View**:
```
┌──────────────────────────────────────┐
│  Askar Import - Holder Mode         │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │  📊 Statistics                 │ │
│  │                                │ │
│  │  • Total Credentials: 12       │ │
│  │  • Verified: 10                │ │
│  │  • Pending: 2                  │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🔄 Quick Actions              │ │
│  │                                │ │
│  │  [Import from Askar]           │ │
│  │  [Self-Verify All]             │ │
│  │  [Export Backup]               │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  📰 Recent Activity            │ │
│  │                                │ │
│  │  • Imported Driver License     │ │
│  │    2 hours ago                 │ │
│  │  • Verified Health Card        │ │
│  │    Yesterday                   │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

**Verifier Mode View**:
```
┌──────────────────────────────────────┐
│  Askar Import - Verifier Mode       │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │  📊 Today's Stats              │ │
│  │                                │ │
│  │  • Verifications: 47           │ │
│  │  • Successful: 45              │ │
│  │  • Failed: 2                   │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🔄 Quick Actions              │ │
│  │                                │ │
│  │  [Scan QR Code]                │ │
│  │  [Manual Verify]               │ │
│  │  [Sync Trust Bundle]           │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  📰 Recent Verifications       │ │
│  │                                │ │
│  │  ✅ Employee Badge - Valid     │ │
│  │     5 mins ago                 │ │
│  │  ❌ Visitor Pass - Expired     │ │
│  │     10 mins ago                │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

**Hybrid Mode View**:
- Shows both sections with toggle between holder/verifier stats

---

### Tab 2: 💳 Credentials (My Wallet)

**Purpose**: Manage personal credentials (Holder Mode)

**Layout**:
```
┌──────────────────────────────────────┐
│  My Credentials                 [+]  │
├──────────────────────────────────────┤
│  🔍 Search credentials...            │
│                                      │
│  📂 Categories                       │
│  ┌────────────────────────────────┐ │
│  │  🆔 Identity (3)               │ │
│  │  🏥 Health (2)                 │ │
│  │  🎓 Education (1)              │ │
│  │  💼 Employment (4)             │ │
│  │  📜 Other (2)                  │ │
│  └────────────────────────────────┘ │
│                                      │
│  📋 All Credentials                  │
│  ┌────────────────────────────────┐ │
│  │  🆔 Driver's License           │ │
│  │  Issued by: DMV                │ │
│  │  ✅ Verified (Trust Bundle)    │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  🏥 Health Insurance           │ │
│  │  Issued by: Blue Cross         │ │
│  │  ⚠️ Not verified               │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

**Features**:
- Search bar at top
- Category filters (collapsible)
- Credential cards with status badges
- Tap to view details
- Long press for quick actions (share, verify, delete)
- Floating Action Button (+) to import new credentials

**Hidden in Verifier-Only Mode**

---

### Tab 3: 📷 Scan (QR Scanner)

**Purpose**: Scan and verify credentials (Verifier Mode)

**Holder Mode View**:
```
┌──────────────────────────────────────┐
│  Present Credential                  │
├──────────────────────────────────────┤
│                                      │
│  Select credential to present:       │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  🆔 Driver's License           │ │
│  │  [Generate QR Code]            │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  🏥 Health Insurance           │ │
│  │  [Generate QR Code]            │ │
│  └────────────────────────────────┘ │
│                                      │
│  Or create custom presentation:      │
│  [Select Attributes]                 │
│                                      │
└──────────────────────────────────────┘
```

**Verifier Mode View**:
```
┌──────────────────────────────────────┐
│  Scan Credential                     │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │                                │ │
│  │    ┌────────────────────┐     │ │
│  │    │                    │     │ │
│  │    │   📷 CAMERA VIEW   │     │ │
│  │    │                    │     │ │
│  │    │   [QR SCAN AREA]   │     │ │
│  │    │                    │     │ │
│  │    └────────────────────┘     │ │
│  │                                │ │
│  └────────────────────────────────┘ │
│                                      │
│  Point camera at QR code             │
│                                      │
│  [Manual Entry]  [Gallery]           │
│                                      │
└──────────────────────────────────────┘
```

**Hybrid Mode View**:
- Toggle between "Present" and "Verify" modes
- Default to camera scanner

---

### Tab 4: 📋 Proofs/Verifications (History)

**Purpose**: View verification history and create proof requests

**Holder Mode View** (Presentation History):
```
┌──────────────────────────────────────┐
│  Presentation History                │
├──────────────────────────────────────┤
│  📅 Filter: [All] [This Week] [Month]│
│                                      │
│  ┌────────────────────────────────┐ │
│  │  📤 Presented Driver's License │ │
│  │  To: Security Checkpoint       │ │
│  │  Oct 4, 2025 - 10:30 AM        │ │
│  │  Status: ✅ Accepted           │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  📤 Presented Health Card      │ │
│  │  To: Hospital Registration     │ │
│  │  Oct 3, 2025 - 2:15 PM         │ │
│  │  Status: ✅ Accepted           │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│                                      │
│  [Export Log]                        │
└──────────────────────────────────────┘
```

**Verifier Mode View** (Verification Log):
```
┌──────────────────────────────────────┐
│  Verification Log                    │
├──────────────────────────────────────┤
│  📅 Filter: [All] [Today] [This Week]│
│  🏷️  Type: [All] [✅ Valid] [❌ Invalid]│
│                                      │
│  ┌────────────────────────────────┐ │
│  │  ✅ Employee Badge              │ │
│  │  Holder: John Smith            │ │
│  │  Tier: Trust Bundle (Offline)  │ │
│  │  Oct 4, 2025 - 11:45 AM        │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  ❌ Visitor Pass                │ │
│  │  Holder: Jane Doe              │ │
│  │  Reason: Expired               │ │
│  │  Oct 4, 2025 - 11:30 AM        │ │
│  │                           [>]  │ │
│  └────────────────────────────────┘ │
│                                      │
│  [Export Report] [Statistics]        │
└──────────────────────────────────────┘
```

---

### Tab 5: ⚙️ Settings

**Purpose**: App configuration and preferences

**Layout**:
```
┌──────────────────────────────────────┐
│  Settings                            │
├──────────────────────────────────────┤
│                                      │
│  🎭 Mode Configuration               │
│  ┌────────────────────────────────┐ │
│  │  Current Mode: Hybrid          │ │
│  │  [Change Mode]                 │ │
│  └────────────────────────────────┘ │
│                                      │
│  🔐 Security                         │
│  ┌────────────────────────────────┐ │
│  │  • Biometric Lock        [ON]  │ │
│  │  • Auto-lock timeout     5min  │ │
│  │  • Secure storage        [ON]  │ │
│  └────────────────────────────────┘ │
│                                      │
│  🌐 Network & Sync                   │
│  ┌────────────────────────────────┐ │
│  │  • ACA-Py Server               │ │
│  │    https://traction.example... │ │
│  │    [Configure]                 │ │
│  │  • Trust Bundle Server         │ │
│  │    [Configure]                 │ │
│  │  • Auto-sync             [ON]  │ │
│  │    Last sync: 2 hours ago      │ │
│  │    [Sync Now]                  │ │
│  └────────────────────────────────┘ │
│                                      │
│  🎨 Appearance                       │
│  ┌────────────────────────────────┐ │
│  │  • Theme: System Default       │ │
│  │  • Color scheme: Blue          │ │
│  └────────────────────────────────┘ │
│                                      │
│  ℹ️ About                            │
│  ┌────────────────────────────────┐ │
│  │  • Version: 1.0.0              │ │
│  │  • Help & Support              │ │
│  │  • Privacy Policy              │ │
│  │  • Licenses                    │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
```

---

## Adaptive Navigation Based on Mode

### Holder Mode (Bottom Nav):
```
┌───────────────────────────────────────────────┐
│  🏠      💳       📤       📋       ⚙️         │
│  Home   Creds   Present  History Settings    │
└───────────────────────────────────────────────┘
```

### Verifier Mode (Bottom Nav):
```
┌───────────────────────────────────────────────┐
│  🏠      📷       📋       📊       ⚙️         │
│  Home   Scan     Log     Stats   Settings    │
└───────────────────────────────────────────────┘
```

### Hybrid Mode (Bottom Nav):
```
┌───────────────────────────────────────────────┐
│  🏠      💳       📷       📋       ⚙️         │
│  Home   Wallet   Scan    Activity Settings   │
└───────────────────────────────────────────────┘
```

---

## AppBar Design

### Standard AppBar
```
┌──────────────────────────────────────┐
│  [☰]  Askar Import        [🔔] [⋮]  │
└──────────────────────────────────────┘
```

**Elements**:
- Left: Hamburger menu (drawer for secondary features)
- Center: App title + current mode badge
- Right: Notifications icon, More options menu

### Mode Indicator Badge
```
Holder Mode:    [👤 Holder]   (Blue)
Verifier Mode:  [✓ Verifier]  (Green)
Hybrid Mode:    [⚡ Hybrid]    (Purple)
```

---

## Drawer Menu (Hamburger)

**Purpose**: Future-proof navigation for advanced features and experimental functionality

### Full Drawer Layout
```
┌──────────────────────────────────────┐
│  ╔════════════════════════════════╗  │
│  ║  Askar Import Pro              ║  │
│  ║  👤 Hybrid Mode                ║  │
│  ╚════════════════════════════════╝  │
├──────────────────────────────────────┤
│                                      │
│  🏠 Core Features                    │
│  ├─ 📥 Import from Askar             │
│  ├─ 📤 Export Credentials            │
│  ├─ 🔄 Sync Trust Bundle             │
│  └─ 📊 View All Statistics           │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  🔧 Advanced Tools                   │
│  ├─ 🧪 Developer Mode                │
│  ├─ 🔍 Credential Inspector          │
│  ├─ 🗂️  Batch Operations             │
│  └─ 📋 Schema Manager                │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  🔐 Account & Security               │
│  ├─ 👤 Login / Sign Up               │
│  ├─ 🚪 Logout                        │
│  ├─ 🔑 Manage Bearer Tokens          │
│  ├─ 🛡️  Two-Factor Auth              │
│  └─ 🔄 Sync Across Devices           │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  🌐 Network & Integration            │
│  ├─ 🔗 DID Management                │
│  ├─ 🌉 Bridge to Other Wallets       │
│  ├─ 📡 Issuer Connections            │
│  └─ 🔐 Key Management                │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  📚 Resources                        │
│  ├─ ❓ Help & Tutorials              │
│  ├─ 📖 Documentation                 │
│  ├─ 🎓 Learning Center               │
│  └─ 📧 Contact Support               │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  ℹ️  About                           │
│  ├─ 📱 Version 1.0.0                 │
│  ├─ 🏛️  Licenses                     │
│  ├─ 🔒 Privacy Policy                │
│  └─ 📜 Terms of Service              │
│                                      │
└──────────────────────────────────────┘
```

### Drawer Sections Explained

#### 1. **Core Features** (Phase 1-3)
```
📥 Import from Askar          [Implemented]
   - Import wallet exports
   - Batch import support

📤 Export Credentials         [Implemented]
   - JSON export
   - Selective export
   - Encrypted backup (future)

🔄 Sync Trust Bundle          [Phase 3]
   - Manual sync
   - Auto-sync settings
   - Sync history

📊 View All Statistics        [Phase 4+]
   - Comprehensive dashboard
   - Charts and graphs
   - Export reports
```

#### 2. **Advanced Tools** (Future Features - Drawer Ready)
```
🧪 Developer Mode             [Future]
   - Debug logs
   - Network inspector
   - Raw JSON viewer
   - Test credentials

🔍 Credential Inspector       [Future]
   - Deep inspection tool
   - Signature analysis
   - Schema validation
   - Proof verification details

🗂️ Batch Operations           [Future]
   - Bulk verify credentials
   - Batch export
   - Mass update
   - Cleanup tools

📋 Schema Manager             [Future]
   - View cached schemas
   - Download new schemas
   - Schema explorer
   - CredDef browser
```

#### 3. **Account & Security** (Authentication - Drawer Ready)
```
👤 Login / Sign Up            [Future]
   - Email/password login
   - Social login (Google, Apple)
   - Create account
   - Forgot password

🚪 Logout                     [Future]
   - Sign out of account
   - Clear local session
   - Revoke bearer tokens
   - Optional: Keep credentials locally

🔑 Manage Bearer Tokens       [Future]
   - View active tokens
   - Refresh tokens
   - Token expiry management
   - Revoke specific tokens
   - API key management

🛡️ Two-Factor Auth            [Future]
   - Enable/disable 2FA
   - Authenticator app setup
   - SMS verification
   - Backup codes

🔄 Sync Across Devices        [Future]
   - Cloud sync settings
   - Conflict resolution
   - Selective sync
   - Sync history
```

#### 4. **Network & Integration** (Advanced - Drawer Ready)
```
🔗 DID Management             [Future]
   - View DIDs
   - Create new DIDs
   - DID resolver
   - Key rotation

🌉 Bridge to Other Wallets    [Future]
   - Export to other formats
   - Import from competitors
   - Migration tools
   - Compatibility checker

📡 Issuer Connections         [Future]
   - Connect to issuers
   - Credential offers
   - Invitation manager
   - Trust anchor configuration

🔐 Key Management             [Future]
   - View keys
   - Backup keys
   - Recovery tools
   - Hardware key support
```

#### 5. **Resources** (Always Available)
```
❓ Help & Tutorials           [Phase 5]
   - Getting started guide
   - Video tutorials
   - FAQs
   - Troubleshooting

📖 Documentation              [Phase 5]
   - User guide
   - Technical docs
   - API reference
   - Best practices

🎓 Learning Center            [Future]
   - SSI concepts
   - How verifiable credentials work
   - Interactive demos
   - Certification courses

📧 Contact Support            [Phase 5]
   - Email support
   - Chat support (future)
   - Bug reports
   - Feature requests
```

#### 6. **About** (Always Available)
```
📱 Version 1.0.0              [Always]
   - Build number
   - Update checker
   - Release notes
   - What's new

🏛️ Licenses                   [Always]
   - Open source licenses
   - Third-party notices
   - Credits

🔒 Privacy Policy             [Always]
   - Data handling
   - Privacy practices
   - User rights

📜 Terms of Service           [Always]
   - Usage terms
   - Disclaimers
   - Legal notices
```

### Drawer Item States

#### Active Items (Clickable)
```dart
ListTile(
  leading: Icon(Icons.upload, color: Colors.blue),
  title: Text('Import from Askar'),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => _navigateToImport(),
)
```

#### Coming Soon Items (Greyed Out)
```dart
ListTile(
  enabled: false,
  leading: Icon(Icons.science, color: Colors.grey),
  title: Text('Developer Mode'),
  trailing: Chip(
    label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
    backgroundColor: Colors.grey[300],
  ),
)
```

#### Beta/Experimental Items
```dart
ListTile(
  leading: Icon(Icons.build, color: Colors.orange),
  title: Row(
    children: [
      Text('Schema Manager'),
      SizedBox(width: 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'BETA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
      ),
    ],
  ),
  onTap: () => _navigateToSchemaManager(),
)
```

### Implementation Code

```dart
// lib/ui/navigation/app_drawer.dart

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          _buildDrawerHeader(context),
          
          // Core Features
          _buildSectionHeader('Core Features'),
          _buildDrawerItem(
            icon: Icons.upload_file,
            title: 'Import from Askar',
            onTap: () => _navigateToImport(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.download,
            title: 'Export Credentials',
            onTap: () => _navigateToExport(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.sync,
            title: 'Sync Trust Bundle',
            onTap: () => _navigateToSync(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.analytics,
            title: 'View All Statistics',
            onTap: () => _navigateToStats(context),
            isActive: true,
          ),
          
          const Divider(),
          
          // Advanced Tools (Future)
          _buildSectionHeader('Advanced Tools'),
          _buildDrawerItem(
            icon: Icons.science,
            title: 'Developer Mode',
            badge: 'Coming Soon',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.search,
            title: 'Credential Inspector',
            badge: 'Coming Soon',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            title: 'Batch Operations',
            badge: 'Planned',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.schema,
            title: 'Schema Manager',
            badge: 'Planned',
            isActive: false,
          ),
          
          const Divider(),
          
          // Account & Security (Future - Authentication)
          _buildSectionHeader('Account & Security'),
          _buildDrawerItem(
            icon: Icons.login,
            title: 'Login / Sign Up',
            badge: 'Coming Soon',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            badge: 'Coming Soon',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.vpn_key,
            title: 'Manage Bearer Tokens',
            badge: 'Future',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.security,
            title: 'Two-Factor Auth',
            badge: 'Future',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.sync_alt,
            title: 'Sync Across Devices',
            badge: 'Future',
            isActive: false,
          ),
          
          const Divider(),
          
          // Network & Integration (Future)
          _buildSectionHeader('Network & Integration'),
          _buildDrawerItem(
            icon: Icons.link,
            title: 'DID Management',
            badge: 'Future',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.swap_horiz,
            title: 'Bridge to Other Wallets',
            badge: 'Future',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.connect_without_contact,
            title: 'Issuer Connections',
            badge: 'Future',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.vpn_key,
            title: 'Key Management',
            badge: 'Future',
            isActive: false,
          ),
          
          const Divider(),
          
          // Resources
          _buildSectionHeader('Resources'),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Tutorials',
            onTap: () => _navigateToHelp(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.book,
            title: 'Documentation',
            onTap: () => _openDocumentation(),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.school,
            title: 'Learning Center',
            badge: 'Coming Soon',
            isActive: false,
          ),
          _buildDrawerItem(
            icon: Icons.email,
            title: 'Contact Support',
            onTap: () => _contactSupport(),
            isActive: true,
          ),
          
          const Divider(),
          
          // About
          _buildSectionHeader('About'),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'Version 1.0.0',
            onTap: () => _showAbout(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.gavel,
            title: 'Licenses',
            onTap: () => _showLicenses(context),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(),
            isActive: true,
          ),
          _buildDrawerItem(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () => _openTerms(),
            isActive: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.account_balance_wallet, 
                       size: 30, 
                       color: Colors.blue[700]),
          ),
          const SizedBox(height: 12),
          const Text(
            'Askar Import Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Hybrid Mode',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    String? badge,
    bool isActive = true,
  }) {
    return ListTile(
      enabled: isActive,
      leading: Icon(
        icon,
        color: isActive ? Colors.blue[700] : Colors.grey,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.orange[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.orange[800] : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
      trailing: isActive
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: isActive ? onTap : null,
    );
  }
}
```

### Benefits of This Drawer Approach

✅ **Future-Proof**: Shows users what's coming  
✅ **Clear Roadmap**: "Coming Soon" badges communicate progress  
✅ **Organized**: Features grouped logically  
✅ **Discoverable**: Advanced features don't clutter main navigation  
✅ **Expandable**: Easy to add new items as features develop  
✅ **Professional**: Shows planning and vision  
✅ **User Expectation**: Users know what to expect in future updates  

### Phased Activation Plan

**Phase 1**: Core features + drawer skeleton (all future items greyed)  
**Phase 2-3**: Enable Trust Bundle sync  
**Phase 4**: Enable statistics dashboard  
**Phase 5+**: Gradually activate advanced features as developed  

This way, users see the app's potential from day one! 🚀

---

## Navigation Flow Examples

### Example 1: Holder Importing Credential
```
1. Start at 🏠 Home
2. Tap [Import from Askar] button
3. Navigate to import screen (full screen)
4. Select file
5. Import completes
6. Navigate to 💳 Credentials tab
7. See newly imported credential
```

### Example 2: Verifier Scanning Badge
```
1. Start at 🏠 Home
2. Tap [Scan QR Code] button OR
3. Navigate to 📷 Scan tab
4. Camera opens
5. Scan QR code
6. Verification result shows (modal/overlay)
7. Tap "View Details" → Full verification screen
8. Verification logged in 📋 Log tab
```

### Example 3: Self-Verification (Holder)
```
1. Navigate to 💳 Credentials
2. Tap on a credential
3. View credential details
4. Tap "Verify" button
5. Verification runs (all 3 tiers)
6. Result shows with tier badge
7. History updated in 📋 Activity
```

---

## Color Scheme & Design Tokens

### Primary Colors
```dart
// Material Design 3 Theme
primaryColor: Colors.blue[700]        // Main brand color
secondaryColor: Colors.teal[500]      // Accent color
backgroundColor: Colors.grey[50]      // Light background

// Mode Colors
holderModeColor: Colors.blue          // Holder features
verifierModeColor: Colors.green       // Verifier features
hybridModeColor: Colors.purple        // Hybrid mode

// Verification Tier Colors
tierBest: Colors.green[600]           // Trust Bundle
tierGood: Colors.blue[600]            // ACA-Py
tierLimited: Colors.orange[600]       // Structural
tierFailed: Colors.red[600]           // Failed
```

### Typography
```dart
// Headings
headline1: 24px, bold
headline2: 20px, semibold
headline3: 18px, semibold

// Body
body1: 16px, regular
body2: 14px, regular

// Captions
caption: 12px, regular
```

### Spacing
```dart
// Padding
paddingSmall: 8px
paddingMedium: 16px
paddingLarge: 24px

// Border Radius
radiusSmall: 8px
radiusMedium: 12px
radiusLarge: 16px
```

---

## Key UI Components

### 1. Credential Card
```
┌────────────────────────────────────┐
│  🆔 Driver's License               │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Issued by: Department of Motor... │
│  Issued: Jan 15, 2023              │
│  Expires: Jan 15, 2028             │
│                                    │
│  [✅ Trust Bundle]      [View >]   │
└────────────────────────────────────┘
```

### 2. Verification Result Card
```
┌────────────────────────────────────┐
│  ✅ Verification Successful        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Tier: Trust Bundle (BEST)         │
│  Method: Offline Crypto            │
│  Time: < 100ms                     │
│                                    │
│  Credential: Employee Badge        │
│  Holder: John Smith                │
│  Issuer: ACME Corporation          │
│                                    │
│  [View Details] [Log to Report]    │
└────────────────────────────────────┘
```

### 3. Status Badge
```
✅ Verified      (Green, filled)
⚠️ Unverified    (Orange, outlined)
❌ Invalid       (Red, filled)
🔄 Verifying...  (Blue, animated)
📦 Offline       (Grey)
```

### 4. Tier Badge
```
🟢 BEST      (Trust Bundle - Green)
🔵 GOOD      (ACA-Py - Blue)
🟠 LIMITED   (Structural - Orange)
```

---

## Implementation Structure

### File Organization
```
lib/
├── main.dart
├── app.dart                          # Main app widget
├── ui/
│   ├── navigation/
│   │   ├── app_navigation.dart       # Bottom nav scaffold
│   │   ├── app_drawer.dart           # Drawer menu
│   │   └── navigation_routes.dart    # Route definitions
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   ├── holder_home.dart
│   │   │   ├── verifier_home.dart
│   │   │   └── hybrid_home.dart
│   │   ├── credentials/
│   │   │   ├── credentials_page.dart
│   │   │   ├── credential_detail_page.dart
│   │   │   └── credential_card.dart
│   │   ├── scan/
│   │   │   ├── scan_page.dart
│   │   │   ├── present_page.dart
│   │   │   └── qr_scanner.dart
│   │   ├── proofs/
│   │   │   ├── proofs_page.dart
│   │   │   ├── verification_log_page.dart
│   │   │   └── presentation_history_page.dart
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       ├── mode_settings.dart
│   │       ├── network_settings.dart
│   │       └── security_settings.dart
│   ├── widgets/
│   │   ├── verification_result_card.dart
│   │   ├── tier_badge.dart
│   │   ├── status_badge.dart
│   │   ├── mode_indicator.dart
│   │   └── quick_action_button.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
└── config/
    └── app_mode.dart                 # Mode configuration
```

---

## Phase 1 Implementation Checklist

### Week 1: UI Refactoring

**Day 1-2: Navigation Structure**
- [ ] Create bottom navigation scaffold
- [ ] Implement mode-aware tab switching
- [ ] Add app drawer
- [ ] Create navigation routes

**Day 2-3: Screen Scaffolds**
- [ ] Create home page variants (holder/verifier/hybrid)
- [ ] Create credentials list page
- [ ] Create scan/present page skeleton
- [ ] Create proofs/log page skeleton
- [ ] Create settings page

**Day 3-4: Reusable Components**
- [ ] Design credential card widget
- [ ] Design verification result card
- [ ] Create tier badges
- [ ] Create status badges
- [ ] Create mode indicator

**Day 4-5: Theme & Polish**
- [ ] Implement Material Design 3 theme
- [ ] Add color scheme
- [ ] Add animations and transitions
- [ ] Test on different screen sizes
- [ ] Dark mode support (optional)

**Day 5: Integration**
- [ ] Connect existing credential verifier to new UI
- [ ] Migrate import functionality
- [ ] Test all navigation flows
- [ ] Update documentation

---

## Benefits of This Approach

✅ **Scalable**: Easy to add new tabs or features  
✅ **Intuitive**: Standard bottom nav pattern  
✅ **Mode-Aware**: Adapts to holder/verifier/hybrid modes  
✅ **Professional**: Modern Material Design 3 look  
✅ **Consistent**: Reusable components throughout  
✅ **Future-Proof**: Structure supports all planned features  

---

## Migration Strategy

### Existing Features → New UI

**Current wallet_import_page.dart**:
- Import functionality → Home page quick action
- Credential list → Credentials tab
- Credential detail → New detail page
- Verification → Embedded in credential detail

**Keeps Backward Compatibility**:
- All existing verification logic unchanged
- Just rewraps in new navigation structure
- Can migrate screen by screen

---

**Status**: UI Layout Proposed  
**Next Step**: Review and approve layout  
**Implementation**: Phase 1 (alongside trust_bundle_core)  
**Timeline**: 4-5 days for complete UI refactor

---

## Authentication Integration Example (Future Phase)

When authentication features are implemented, here's how the drawer will work:

### Dynamic Drawer Header

**Logged Out State**:
```dart
DrawerHeader(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[700]!, Colors.blue[500]!],
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: Icon(Icons.person_outline, size: 30, color: Colors.blue),
      ),
      SizedBox(height: 12),
      Text(
        'Askar Import Pro',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      TextButton.icon(
        icon: Icon(Icons.login, size: 14, color: Colors.white70),
        label: Text('Sign in for cloud sync', 
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
        onPressed: () => _navigateToLogin(context),
      ),
    ],
  ),
)
```

**Logged In State**:
```dart
DrawerHeader(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue[700]!, Colors.blue[500]!],
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      CircleAvatar(
        radius: 30,
        backgroundImage: user.photoUrl != null 
            ? NetworkImage(user.photoUrl!) 
            : null,
        backgroundColor: Colors.white,
        child: user.photoUrl == null 
            ? Text(user.initials, 
                   style: TextStyle(fontSize: 24, color: Colors.blue[700]))
            : null,
      ),
      SizedBox(height: 12),
      Text(
        user.name,
        style: TextStyle(color: Colors.white, fontSize: 18, 
                        fontWeight: FontWeight.bold),
      ),
      Text(
        user.email,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      Row(
        children: [
          _buildModeChip(),
          SizedBox(width: 8),
          if (hasActiveToken)
            Icon(Icons.cloud_done, size: 14, color: Colors.white70),
        ],
      ),
    ],
  ),
)
```

### Dynamic Auth Menu Items

```dart
// Account & Security section adapts based on auth state
_buildSectionHeader('Account & Security'),

if (!isAuthenticated) ...[
  // Show login when logged out
  _buildDrawerItem(
    icon: Icons.login,
    title: 'Login / Sign Up',
    subtitle: 'Enable cloud features',
    onTap: () => _navigateToLogin(context),
    isActive: true,
  ),
] else ...[
  // Show account management when logged in
  _buildDrawerItem(
    icon: Icons.person,
    title: user.name,
    subtitle: 'Manage your account',
    onTap: () => _navigateToProfile(context),
    isActive: true,
  ),
  _buildDrawerItem(
    icon: Icons.vpn_key,
    title: 'Bearer Tokens',
    subtitle: 'Expires in ${tokenExpiresIn}',
    onTap: () => _navigateToTokens(context),
    isActive: true,
    trailing: tokenNeedsRefresh 
        ? Icon(Icons.warning, color: Colors.orange, size: 20)
        : null,
  ),
  _buildDrawerItem(
    icon: Icons.security,
    title: 'Two-Factor Auth',
    subtitle: has2FA ? '✓ Enabled' : 'Not enabled',
    onTap: () => _navigateTo2FA(context),
    isActive: true,
  ),
  _buildDrawerItem(
    icon: Icons.sync_alt,
    title: 'Sync Across Devices',
    subtitle: lastSynced != null 
        ? 'Last: ${lastSynced}'
        : 'Not configured',
    onTap: () => _navigateToSync(context),
    isActive: true,
  ),
  Divider(),
  _buildDrawerItem(
    icon: Icons.logout,
    title: 'Logout',
    onTap: () => _confirmLogout(context),
    isActive: true,
    textColor: Colors.red,
  ),
],
```

### Bearer Token Management Screen

```dart
// lib/ui/screens/settings/bearer_token_page.dart

class BearerTokenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bearer Tokens'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showTokenHelp(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Current Active Token
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Active Token',
                           style: TextStyle(fontSize: 18, 
                                          fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  _buildTokenInfo('Status', 'Valid', Colors.green),
                  _buildTokenInfo('Expires', authService.tokenExpiry, null),
                  _buildTokenInfo('Type', 'Bearer', null),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            authService.maskedToken,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18),
                          onPressed: () => _copyToken(context),
                          tooltip: 'Copy full token',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          label: Text('Refresh Token'),
                          onPressed: () => authService.refreshToken(),
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton(
                        child: Text('Revoke', 
                                    style: TextStyle(color: Colors.red)),
                        onPressed: () => _confirmRevokeToken(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Token Usage
          Text('Used For', 
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildServiceCard('ACA-Py Server', 
                           'Online credential verification', 
                           Icons.verified_user),
          _buildServiceCard('Trust Bundle Server', 
                           'Trust bundle downloads', 
                           Icons.shield),
          _buildServiceCard('Cloud Sync', 
                           'Multi-device credential sync', 
                           Icons.cloud),
          
          SizedBox(height: 24),
          
          // Security Info
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Security Notice',
                           style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Tokens are stored securely using platform encryption\n'
                    '• Tokens auto-refresh 5 minutes before expiry\n'
                    '• Revoked tokens cannot be reused\n'
                    '• Logout revokes all active tokens',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTokenInfo(String label, String value, Color? valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, 
               style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: valueColor,
               )),
        ],
      ),
    );
  }
  
  Widget _buildServiceCard(String title, String description, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(description, style: TextStyle(fontSize: 12)),
        trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
      ),
    );
  }
}
```

### Authentication Service

```dart
// lib/services/auth_service.dart

class AuthService extends ChangeNotifier {
  User? _user;
  String? _bearerToken;
  DateTime? _tokenExpiry;
  Timer? _refreshTimer;
  
  // Getters
  bool get isAuthenticated => _user != null;
  bool get hasActiveToken => 
      _bearerToken != null && 
      (_tokenExpiry?.isAfter(DateTime.now()) ?? false);
  
  User? get user => _user;
  
  String get maskedToken {
    if (_bearerToken == null) return 'No token';
    final token = _bearerToken!;
    if (token.length < 20) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
  }
  
  String get tokenExpiry {
    if (_tokenExpiry == null) return 'No expiry';
    final formatter = DateFormat('MMM d, y h:mm a');
    return formatter.format(_tokenExpiry!);
  }
  
  String? get tokenExpiresIn {
    if (_tokenExpiry == null) return null;
    final diff = _tokenExpiry!.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Expired';
  }
  
  bool get tokenNeedsRefresh {
    if (_tokenExpiry == null) return false;
    final diff = _tokenExpiry!.difference(DateTime.now());
    return diff.inMinutes < 5; // Refresh if less than 5 minutes left
  }
  
  // Methods
  Future<void> login(String email, String password) async {
    try {
      final response = await _authApi.login(email, password);
      _user = response.user;
      _bearerToken = response.token;
      _tokenExpiry = response.expiry;
      
      // Save securely
      await _secureStorage.write(key: 'bearer_token', value: _bearerToken);
      await _secureStorage.write(key: 'token_expiry', 
                                  value: _tokenExpiry!.toIso8601String());
      
      // Start auto-refresh timer
      _startTokenRefreshTimer();
      
      notifyListeners();
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
  
  Future<void> refreshToken() async {
    if (_bearerToken == null) return;
    
    try {
      final response = await _authApi.refreshToken(_bearerToken!);
      _bearerToken = response.token;
      _tokenExpiry = response.expiry;
      
      await _secureStorage.write(key: 'bearer_token', value: _bearerToken);
      await _secureStorage.write(key: 'token_expiry', 
                                  value: _tokenExpiry!.toIso8601String());
      
      notifyListeners();
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      throw AuthException('Token refresh failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      // Revoke token on server
      if (_bearerToken != null) {
        await _authApi.revokeToken(_bearerToken!);
      }
    } catch (e) {
      // Log but don't throw - still clear local state
      print('Token revocation failed: $e');
    }
    
    _user = null;
    _bearerToken = null;
    _tokenExpiry = null;
    _refreshTimer?.cancel();
    
    await _secureStorage.delete(key: 'bearer_token');
    await _secureStorage.delete(key: 'token_expiry');
    
    notifyListeners();
  }
  
  String? getBearerToken() => _bearerToken;
  
  void _startTokenRefreshTimer() {
    _refreshTimer?.cancel();
    
    if (_tokenExpiry == null) return;
    
    // Refresh 5 minutes before expiry
    final refreshTime = _tokenExpiry!.subtract(Duration(minutes: 5));
    final delay = refreshTime.difference(DateTime.now());
    
    if (delay.isNegative) {
      // Token already near expiry, refresh now
      refreshToken();
    } else {
      _refreshTimer = Timer(delay, () => refreshToken());
    }
  }
}
```

### Using Bearer Token in HTTP Requests

```dart
// lib/services/acapy_client.dart (Updated)

class AcaPyClient {
  final AuthService _authService;
  final String baseUrl;
  
  AcaPyClient({
    required this.baseUrl,
    required AuthService authService,
  }) : _authService = authService;
  
  Future<Map<String, dynamic>> verifyCredential(
    Map<String, dynamic> credential,
  ) async {
    return _makeAuthenticatedRequest(
      'POST',
      '/credential/verify',
      body: credential,
    );
  }
  
  Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    int retries = 1,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    // Add bearer token if authenticated
    final token = _authService.getBearerToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    final uri = Uri.parse('$baseUrl$path');
    late http.Response response;
    
    if (method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
    }
    
    // Handle 401 - token expired or invalid
    if (response.statusCode == 401 && retries > 0) {
      // Try to refresh token
      try {
        await _authService.refreshToken();
        // Retry request with new token
        return _makeAuthenticatedRequest(method, path, 
                                         body: body, 
                                         retries: retries - 1);
      } catch (e) {
        throw AuthException('Authentication failed: $e');
      }
    }
    
    if (response.statusCode >= 400) {
      throw ApiException(
        'API request failed: ${response.statusCode}',
        response.body,
      );
    }
    
    return json.decode(response.body);
  }
}
```

### Settings Page Auth Status

```dart
// In SettingsPage, show authentication status:

Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(
          authService.isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
          color: authService.isAuthenticated ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text('Account Status'),
        subtitle: authService.isAuthenticated
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signed in as ${authService.user?.email}'),
                  if (authService.tokenNeedsRefresh)
                    Text(
                      '⚠️ Token expires soon',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                ],
              )
            : Text('Not signed in - Local only mode'),
        trailing: authService.isAuthenticated
            ? null
            : ElevatedButton(
                child: Text('Sign In'),
                onPressed: () => _navigateToLogin(context),
              ),
      ),
      if (authService.hasActiveToken)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.timer, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Token expires in ${authService.tokenExpiresIn}'),
              Spacer(),
              if (authService.tokenNeedsRefresh)
                TextButton(
                  child: Text('Refresh Now'),
                  onPressed: () => authService.refreshToken(),
                ),
            ],
          ),
        ),
    ],
  ),
)
```

---

## Benefits of This Authentication Approach

✅ **Progressive Enhancement**: Works offline-first, adds cloud features when authenticated  
✅ **Secure by Default**: Tokens in secure storage, auto-refresh, platform encryption  
✅ **Developer Friendly**: Single `AuthService` for all API calls  
✅ **User Transparent**: Auto-refresh happens in background  
✅ **Fail-Safe**: If auth fails, falls back to local-only mode  
✅ **Multi-Service Ready**: One token for ACA-Py + Trust Bundle + Cloud Sync  
✅ **Standard OAuth Flow**: Compatible with standard bearer token implementations  

---

## Authentication Feature Timeline

| Phase | Authentication Features |
|-------|------------------------|
| **Phase 0-2** | None (local-only) |
| **Phase 3** | Optional: Bearer token for ACA-Py (if server requires) |
| **Phase 4** | Login/Logout UI + Bearer token management |
| **Phase 5+** | Full auth: 2FA, cloud sync, device management |

**Current Status**: Drawer designed with auth placeholders  
**Implementation**: Future phase (after core verification working)  
**Design Ready**: Complete UI and service architecture documented

````
