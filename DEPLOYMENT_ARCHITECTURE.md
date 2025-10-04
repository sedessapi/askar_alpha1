# Deployment Architecture: Holder vs Verifier

**Last Updated**: October 4, 2025

---

## Core Principle: Separate Roles, Separate Deployments

### 📱 **Askar Import = HOLDER Application**
- **Who uses it**: Credential holders (users who OWN credentials)
- **Where deployed**: Personal devices (phones, tablets, laptops)
- **Primary function**: Store and present credentials
- **Security model**: User controls their own credentials

### 🔍 **Trust Bundle Verifier = VERIFIER Application**  
- **Who uses it**: Credential verifiers (entities who CHECK credentials)
- **Where deployed**: Verifier's devices or cloud servers
- **Primary function**: Verify presented credentials
- **Security model**: Verifier controls verification logic

---

## Real-World Analogies

### Physical World Equivalent

```
HOLDER = Person with Physical ID Card
├── Carries wallet with ID cards
├── Shows ID when asked
├── Controls what information to share
└── One person, one wallet

VERIFIER = Security Guard / Clerk
├── Has training to check IDs
├── Has tools to verify authenticity
├── Checks IDs from many people
└── One verifier, many checks per day
```

### Digital World Implementation

```
HOLDER = Askar Import App
├── Stores digital credentials
├── Creates presentations/proofs
├── Controls disclosure
└── Deployed on user's phone

VERIFIER = Trust Bundle Verifier App
├── Has cryptographic verification tools
├── Has trust bundles for validation
├── Verifies credentials from many holders
└── Deployed on verifier's device/server
```

---

## Deployment Models

### Model 1: **Face-to-Face Verification**

```
┌──────────────────────────────────────────────┐
│            PHYSICAL LOCATION                 │
│         (Airport, Office, Store)             │
├──────────────────────────────────────────────┤
│                                              │
│  👤 HOLDER                  👮 VERIFIER      │
│  ┌─────────────┐           ┌─────────────┐  │
│  │ Personal    │           │ Company     │  │
│  │ Phone       │           │ Tablet      │  │
│  │             │           │             │  │
│  │ Askar       │  Shows ──▶│ Trust       │  │
│  │ Import      │  QR Code  │ Bundle      │  │
│  │             │           │ Verifier    │  │
│  └─────────────┘           └─────────────┘  │
│                                              │
│  • User controls phone     • Org owns device│
│  • Has credentials         • Verifies all   │
│  • Shows when asked          visitors       │
└──────────────────────────────────────────────┘
```

**Examples**:
- **Border Control**: Traveler's phone → Immigration officer's tablet
- **Building Security**: Employee's phone → Security kiosk at entrance
- **Age Verification**: Customer's phone → Retail clerk's handheld scanner
- **Conference Check-in**: Attendee's phone → Registration desk tablet

**Key Points**:
- ✅ Two separate physical devices in same location
- ✅ Holder and verifier never share devices
- ✅ Communication via QR code, NFC, or Bluetooth
- ✅ Both can work offline

---

### Model 2: **Remote/Online Verification**

```
┌─────────────────┐                    ┌──────────────────┐
│  HOLDER         │                    │  VERIFIER        │
│  (Anywhere)     │                    │  (Cloud/Remote)  │
│                 │                    │                  │
│  📱 Phone/      │    Internet        │  ☁️ Server/     │
│     Laptop      │    ═══════════════▶│     API         │
│                 │    HTTPS POST      │                  │
│  Askar Import   │    /verify         │  Trust Bundle    │
│                 │                    │  Verifier API    │
│  • At home      │                    │  • Data center   │
│  • On the go    │                    │  • Multi-tenant  │
│  • Any location │                    │  • High scale    │
└─────────────────┘                    └──────────────────┘
```

**Examples**:
- **Online Banking**: Customer opens account from home
- **Telemedicine**: Patient proves insurance remotely
- **Job Application**: Candidate submits degree verification online
- **E-Government**: Citizen accesses services via web portal

**Key Points**:
- ✅ Holder and verifier in different locations
- ✅ Communication via internet (HTTPS API)
- ✅ Verifier typically in cloud for scalability
- ✅ Holder still uses personal device

---

### Model 3: **Self-Verification (Special Case)**

```
┌──────────────────────────────────┐
│   SINGLE DEVICE                  │
│   (User's Phone)                 │
│                                  │
│   ┌────────────────────────┐    │
│   │  Askar Import          │    │
│   │  (Holder App)          │    │
│   │                        │    │
│   │  Credentials:          │    │
│   │  • Stored locally      │    │
│   │  • Can be viewed       │    │
│   │                        │    │
│   │  NEW - Self-Verify:    │    │
│   │  • Uses Trust Bundle   │    │
│   │    crypto engine       │    │
│   │  • Checks own creds    │    │
│   │  • Before presenting   │    │
│   └────────────────────────┘    │
│                                  │
│   User verifies their own        │
│   credentials before showing     │
│   to external verifier           │
└──────────────────────────────────┘
```

**Purpose of Self-Verification**:
- ✅ **Check validity before presenting**: Don't embarrass yourself with expired credential
- ✅ **Troubleshooting**: Understand why verification might fail
- ✅ **Confidence**: Know your credentials are valid
- ✅ **Privacy**: Verify locally without revealing to anyone

**Use Cases**:
- Check if credential expired before job interview
- Verify new credential was issued correctly
- Test credential before important verification
- Debug verification issues

---

## Integration Architecture

### Current State (Before Integration)

```
HOLDER SIDE                          VERIFIER SIDE
┌─────────────────────┐             ┌──────────────────────┐
│ Askar Import        │             │ Trust Bundle         │
│                     │             │ Verifier             │
│ • Import creds      │             │                      │
│ • Store creds       │             │ • Verify creds       │
│ • Browse creds      │             │ • Trust bundles      │
│ • View JSON         │             │ • Crypto engine      │
│                     │             │ • Offline capable    │
│ NO VERIFICATION     │             │                      │
│ (just viewing)      │             │ FULL VERIFICATION    │
└─────────────────────┘             └──────────────────────┘
```

**Problem**: Holder can't verify their own credentials

---

### Target State (After Integration)

```
HOLDER SIDE                          VERIFIER SIDE
┌─────────────────────┐             ┌──────────────────────┐
│ Askar Import        │             │ Trust Bundle         │
│ (Enhanced)          │             │ Verifier             │
│                     │             │                      │
│ • Import creds      │             │ • Verify creds       │
│ • Store creds       │             │ • Trust bundles      │
│ • Browse creds      │             │ • Crypto engine      │
│ • View JSON         │             │ • Offline capable    │
│                     │             │                      │
│ NEW:                │             │ SAME:                │
│ • Self-verify creds │◄────────────│ • Shared crypto core │
│ • 3-tier system:    │  Extracted  │ • Same trust bundles │
│   1. Trust Bundle   │  Library    │ • Same algorithms    │
│   2. ACA-Py         │             │                      │
│   3. Structural     │             │                      │
└─────────────────────┘             └──────────────────────┘
```

**Solution**: Share cryptographic verification engine between both apps

---

## Shared Components

### What Gets Shared

```
┌──────────────────────────────────────────────┐
│      trust_bundle_core (Shared Library)      │
├──────────────────────────────────────────────┤
│                                              │
│  Cryptographic Verification Engine:          │
│  • Ed25519 signature verification           │
│  • SHA-256 hash validation                   │
│  • AnonCreds proof verification              │
│  • Trust bundle management                   │
│  • Revocation checking                       │
│                                              │
└──────────────────────────────────────────────┘
                    ▲       ▲
                    │       │
        ┌───────────┘       └───────────┐
        │                               │
┌───────────────┐             ┌──────────────────┐
│ Askar Import  │             │ Trust Bundle     │
│ (Uses core)   │             │ Verifier         │
│               │             │ (Uses core)      │
│ + Wallet mgmt │             │ + Presentation   │
│ + UI for user │             │   receiving      │
│ + Self-verify │             │ + Audit logging  │
└───────────────┘             └──────────────────┘
```

### What Stays Separate

**Askar Import Only**:
- Credential import from Askar exports
- Wallet management UI
- Credential browsing
- Personal data storage
- User-centric features

**Trust Bundle Verifier Only**:
- Presentation receiving (QR/NFC scanner)
- Audit logging and reporting
- Multi-holder verification tracking
- Verifier-centric features
- Enterprise integrations

---

## Security Boundaries

### Data Isolation

```
HOLDER'S DEVICE                      VERIFIER'S DEVICE
┌─────────────────────┐             ┌──────────────────────┐
│ Askar Import        │             │ Trust Bundle         │
│                     │             │ Verifier             │
│ Database:           │             │                      │
│ • User's creds      │             │ Database:            │
│ • Private keys      │             │ • Verification logs  │
│ • Metadata          │             │ • Trust bundles      │
│                     │             │ • No holder data!    │
│ NEVER leaves device │             │                      │
└─────────────────────┘             └──────────────────────┘
```

**Critical Security Principle**:
- 🔒 Holder's credentials stay on holder's device
- 🔒 Private keys NEVER sent to verifier
- 🔒 Only zero-knowledge proofs are shared
- 🔒 Verifier only sees revealed attributes (minimal disclosure)

---

## Communication Protocols

### Local (Offline) Communication

```
HOLDER PHONE ──QR Code──▶ VERIFIER TABLET
             ──NFC──────▶
             ──Bluetooth▶
             ──WiFi-Direct▶

Data transmitted:
• Credential presentation (signed proof)
• Revealed attributes only
• No private keys
• No full credential (unless holder chooses)
```

### Remote (Online) Communication

```
HOLDER PHONE ──HTTPS API──▶ VERIFIER SERVER

POST /api/verify
{
  "presentation": {...},
  "nonce": "...",
  "revealed_attrs": [...]
}

Response:
{
  "verified": true,
  "timestamp": "...",
  "verifier_did": "..."
}
```

---

## Deployment Checklist

### For Holder (Askar Import)

- [ ] Install on user's personal device
- [ ] Import credentials from Askar export
- [ ] Sync trust bundles (if using offline crypto)
- [ ] Configure ACA-Py endpoint (if using online fallback)
- [ ] Test self-verification
- [ ] Ready to present credentials

### For Verifier (Trust Bundle Verifier)

- [ ] Deploy on verifier's device or cloud
- [ ] Configure trust bundle server
- [ ] Sync trust bundles from authority
- [ ] Set up presentation receiving (QR scanner, API endpoint)
- [ ] Configure audit logging
- [ ] Test verification workflow

### For Integration (Shared Core)

- [ ] Extract `trust_bundle_core` package
- [ ] Publish to package repository
- [ ] Update Askar Import to use core
- [ ] Verify Trust Bundle Verifier uses same core
- [ ] Test both apps verify identically
- [ ] Document shared API

---

## FAQ

### Q: Can one app be both holder and verifier?

**A**: Technically yes, but **not recommended** for these reasons:
- Confusing UX (two very different roles)
- Security concerns (mixing personal and professional data)
- Different device requirements (personal phone vs enterprise tablet)
- Better to keep separate and focused

**Exception**: Self-verification is OK (holder verifying their own credentials)

---

### Q: Do holder and verifier need to be connected?

**A**: Only momentarily during verification:
- **Offline**: Brief local connection (QR scan takes < 1 second)
- **Online**: Brief API call (verification < 5 seconds)
- **No persistent connection** needed

---

### Q: Can verifier work without holder?

**A**: No, verifier needs credentials from holder to verify:
1. Holder presents credential
2. Verifier checks it
3. Verifier returns result

---

### Q: Can holder work without verifier?

**A**: Yes! Holder can:
- Store credentials
- View credentials
- **Self-verify** (using integrated Trust Bundle engine)
- Prepare for presentation

---

### Q: Where is the blockchain/ledger?

**A**: Neither app directly accesses ledger:
- **Trust Bundles** contain pre-fetched ledger data (schemas, cred defs)
- Bundles synced periodically from authority server
- Authority server handles ledger queries
- Apps work offline with cached data

---

### Q: What additional capabilities when both holder and verifier are online?

**A**: Many powerful features become available! See **ONLINE_SCENARIOS.md** for details:

1. **Real-time revocation checking** - Immediate enforcement
2. **Fresh cryptographic verification** - Latest data from ledger
3. **Dynamic proof requests** - Adaptive verification
4. **Multi-party coordination** - Multiple checkpoints
5. **Credential status updates** - Proactive monitoring
6. **Cross-jurisdiction verification** - International credentials
7. **Audit and compliance logging** - Regulatory requirements
8. **Emergency overrides** - Flexible access control

**Best approach**: Hybrid architecture that works offline but leverages online when available!

---

## Summary

| Aspect | Askar Import (Holder) | Trust Bundle Verifier |
|--------|----------------------|----------------------|
| **User** | Credential holder | Credential verifier |
| **Device** | Personal (phone) | Org device or cloud |
| **Data** | User's credentials | Verification logs |
| **Function** | Store & present | Receive & verify |
| **Deployment** | One per user | One per verifier org |
| **Network** | Optional (3-tier) | Optional (has bundles) |

**Key Insight**: Two apps, two roles, deployed separately, but sharing the same cryptographic verification core for consistency.

---

**Version**: 1.0.0  
**Status**: Architecture Documented  
**Next**: Extract trust_bundle_core and integrate
