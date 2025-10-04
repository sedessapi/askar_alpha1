# Verification Capabilities Timeline

**Last Updated**: October 4, 2025  
**Purpose**: Track when each verification type becomes available across development phases

---

## Quick Answer to "What phase will there be online verification and offline verification?"

### **1. Online Verification (ACA-Py):**

- ⚠️ **Code exists but NOT TESTED** (Phase 0 - current state)
  - Location: `lib/services/acapy_client.dart` and `lib/services/hybrid_verification_service.dart`
  - Implementation complete
  - Can verify credentials via REST API to Traction ACA-Py server
  - **Needs testing with real server to confirm it works**

- ✅ **Enhanced version: Phase 3** (integrated into 3-tier system)
  - Will be part of `EnhancedVerificationService`
  - Same functionality, better integration
  - Automatic tier selection and fallback logic
  - **This is when ACA-Py verification gets tested and goes live**

### **2. Offline Verification:**

#### **A. Offline Structural (Format Validation):**

- ✅ **ALREADY WORKING** (Phase 0 - current state)
  - Location: `lib/services/credential_verifier.dart`
  - Checks JSON format, required fields, data types
  - No cryptographic verification
  - Validated and tested

#### **B. Offline Crypto (Trust Bundle):**

- 🎯 **Phase 3** (NEW - cryptographic verification)
  - Ed25519 signature verification
  - SHA-256 hash verification
  - Full cryptographic checking offline
  - **This is the NEW capability being added**
  - Works completely offline after trust bundle is synced

### **Summary:**

**Phase 3 is the critical milestone** because that's when:
- Offline crypto verification goes live (NEW capability)
- Online ACA-Py verification gets TESTED and integrated (existing code)
- All three tiers work together with automatic fallback
- You get the complete 3-tier verification system

**Before Phase 3**: You have offline structural (tested)  
**After Phase 3**: You have offline crypto (Trust Bundle) + online crypto (ACA-Py tested) + offline structural

The **big unlock** is **offline cryptographic verification** in **Phase 3**! 🎉  
**Plus**: Online ACA-Py verification gets properly tested and integrated!

---

## Current State (Before Phase 1)

### ✅ Available Now:

**1. Offline Structural Verification (ACTIVE)**
- Location: `lib/services/credential_verifier.dart`
- Type: Format validation only
- Capability: Checks JSON structure, required fields, data types
- Limitation: No cryptographic signature verification
- Status: ✅ Production ready and tested

### ⚠️ Implemented But Not Yet Tested:

**2. Online Verification via ACA-Py (CODE EXISTS)**
- Location: `lib/services/acapy_client.dart`, `lib/services/hybrid_verification_service.dart`
- Type: Cryptographic verification via REST API
- Capability: Full crypto verification when network available
- Limitation: Requires internet connection and ACA-Py server
- Status: ⚠️ Code written but not tested/verified as working

### ❌ Not Yet Available:

**3. Offline Crypto Verification (PENDING)**
- Type: Trust Bundle with Ed25519 + SHA-256
- Target: Phase 3 completion
- Status: ⏳ Waiting for implementation

---

## Phase-by-Phase Verification Status

### Phase 0: Current State (Day 0 - NOW)

**Goal**: Existing verification capabilities

**Status**: Already implemented and working

**Verification Impact**: Baseline functionality

**Activities**:
- Offline structural verification operational (`credential_verifier.dart`)
- Online ACA-Py verification operational (`acapy_client.dart`)
- Basic hybrid verification service (`hybrid_verification_service.dart`)
- Import credentials from Askar exports
- Display credentials in UI
- JSON export functionality

**Verification Available at End of Phase 0**:
```
✅ Offline Structural (ACTIVE & TESTED)
   - Format validation
   - JSON structure checks
   - Required fields validation
   - No cryptographic verification

⚠️ Online ACA-Py (CODE EXISTS - NOT TESTED)
   - REST API client implemented
   - Hybrid service implemented
   - Not yet verified as working
   - Needs testing with real Traction ACA-Py server

❌ Offline Crypto (NOT YET)
   - Trust Bundle not integrated
   - No offline cryptographic verification
```

**Deliverable**: Current working app with structural verification only

---

### Phase 1: Extract Trust Bundle Core (Days 1-3)

**Goal**: Create standalone crypto verification package

**Status**: Building the foundation

**Verification Impact**: NONE YET (just creating package)

**Activities**:
- Extract ManifestVerifier from Trust Bundle Verifier app
- Create `trust_bundle_core` Flutter package
- Implement Ed25519 signature verification
- Implement SHA-256 hash verification
- Add did:key resolution
- Write unit tests for crypto functions
- Verify package compiles and tests pass

**Verification Available at End of Phase 1**:
```
✅ Offline Structural (existing & tested)
⚠️ Online ACA-Py (code exists, not tested)
❌ Offline Crypto (package ready but not integrated)
```

**Deliverable**: Standalone `trust_bundle_core` package with passing tests

---

### Phase 2: Add Mode Configuration (Day 4)

**Goal**: Add holder/verifier/hybrid mode switching

**Status**: Adding UI infrastructure

**Verification Impact**: NONE (just UI changes)

**Activities**:
- Create `AppModeConfig` class
- Add mode selector UI
- Implement mode persistence (SharedPreferences)
- Add mode indicator in app bar
- No verification logic changes

**Verification Available at End of Phase 2**:
```
✅ Offline Structural (existing & tested)
⚠️ Online ACA-Py (code exists, not tested)
❌ Offline Crypto (package ready but not integrated)
```

**Deliverable**: Mode switching UI with persisted preferences

---

### Phase 3: Integrate Trust Bundle (Days 5-7) ⭐ **CRITICAL PHASE**

**Goal**: Enable 3-tier verification system

**Status**: THIS IS WHERE CRYPTO VERIFICATION GOES LIVE!

**Verification Impact**: MAJOR UPGRADE - All three verification methods become active

**Activities**:
- Add `trust_bundle_core` dependency to `pubspec.yaml`
- Initialize Trust Bundle database (Isar)
- Create `TrustBundleService` wrapper
- Create `EnhancedVerificationService` with 3-tier logic
- Replace `HybridVerificationService` with enhanced version
- Update UI to show verification tier badges
- Test all three tiers with real credentials
- Test automatic fallback logic

**Verification Available at End of Phase 3**:
```
✅ Tier 1: Trust Bundle - Offline Crypto (NEW! 🎉)
   - Ed25519 signature verification
   - SHA-256 hash verification
   - did:key resolution
   - Works offline
   - BEST verification method

✅ Tier 2: ACA-Py - Online Crypto (ENHANCED)
   - REST API verification
   - Full cryptographic checks
   - Requires network connection
   - GOOD verification method

✅ Tier 3: Structural - Offline Format (EXISTING)
   - JSON structure validation
   - Required fields check
   - No cryptographic verification
   - FALLBACK verification method
```

**Automatic Fallback Logic**:
```
1. Try Trust Bundle (offline crypto)
   ↓ (if unavailable or fails)
2. Try ACA-Py (online crypto)
   ↓ (if offline or fails)
3. Use Structural (format only)
```

**UI Updates**:
- 🟢 Green badge: "BEST - Trust Bundle" (offline crypto verified)
- 🔵 Blue badge: "GOOD - ACA-Py" (online crypto verified)
- 🟠 Orange badge: "LIMITED - Structural" (format only)

**Deliverable**: Complete 3-tier verification system operational

**KEY MILESTONE**: ⭐ **This is the first fully cryptographic offline verification!**

---

### Phase 4: Add Verifier Mode UI (Days 8-11)

**Goal**: Enable verifying others' credentials

**Status**: Adding verifier-specific features

**Verification Impact**: Same engine, new interfaces

**Activities**:
- Create QR scanner page (`scan_verify_page.dart`)
- Create manual verification page (`manual_verify_page.dart`)
- Create trust bundle sync page (`bundle_sync_page.dart`)
- Create verification log page (`verification_log_page.dart`)
- Add verification history tracking
- Test verifier mode end-to-end

**Verification Available at End of Phase 4**:
```
✅ Tier 1: Trust Bundle - Offline Crypto
✅ Tier 2: ACA-Py - Online Crypto
✅ Tier 3: Structural - Offline Format

PLUS: New UI for verifying others' credentials
- QR code scanning
- Manual credential verification
- Audit logging
- Trust bundle synchronization
```

**Use Cases Enabled**:
- Security guard scanning visitor badges
- HR verifying employee credentials
- Healthcare worker checking patient insurance
- Inspector verifying contractor licenses

**Deliverable**: Verifier mode fully functional with all verification tiers

---

### Phase 5: Polish & Production Ready (Days 12-14)

**Goal**: Production-ready release

**Status**: Final refinements

**Verification Impact**: Visual improvements + monitoring

**Activities**:
- Add tier indicators throughout UI
- Show verification attempt history
- Create settings page for configuration
- Add verification statistics/dashboard
- Performance optimization
- Comprehensive testing
- Documentation updates
- Release preparation

**Verification Available at End of Phase 5**:
```
✅ Tier 1: Trust Bundle - Offline Crypto
✅ Tier 2: ACA-Py - Online Crypto
✅ Tier 3: Structural - Offline Format

PLUS: Production UX
- Tier badges with colors and icons
- Verification attempt timeline
- Settings for trust bundle configuration
- Statistics and reporting
- Optimized performance
```

**Deliverable**: Production-ready app with professional UX

---

## Summary Table

| Phase | Days | Offline Structural | Offline Crypto | Online ACA-Py | Status |
|-------|------|-------------------|----------------|---------------|--------|
| **Phase 0 (Current)** | 0 | ✅ Tested | ❌ No | ⚠️ Code exists | Existing code |
| **Phase 1** | 1-3 | ✅ Tested | 📦 Package ready | ⚠️ Code exists | Building foundation |
| **Phase 2** | 4 | ✅ Tested | 📦 Package ready | ⚠️ Code exists | Adding UI modes |
| **Phase 3** | 5-7 | ✅ Fallback | ✅ **LIVE!** 🎉 | ✅ **TESTED!** 🎉 | **3-tier active** ⭐ |
| **Phase 4** | 8-11 | ✅ Fallback | ✅ Active | ✅ Tested | + Verifier UI |
| **Phase 5** | 12-14 | ✅ Fallback | ✅ Active | ✅ Tested | + Polish & UX |

---

## Verification Type Details

### 1. Offline Structural Verification

**Available**: Now (pre-Phase 1)

**How it works**:
```dart
// Checks:
- JSON is valid and parsable
- Required fields present (credentialSubject, issuer, etc.)
- Data types correct (strings, objects, arrays)
- Schema reference exists
- Credential definition reference exists

// Does NOT check:
- Digital signatures
- Cryptographic integrity
- Issuer authenticity
- Tampering detection
```

**Use Case**: Quick format validation, fallback when crypto unavailable

**Tier**: 3 (Lowest confidence)

---

### 2. Online Crypto Verification (ACA-Py)

**Available**: Now (basic), Phase 3 (enhanced)

**How it works**:
```dart
// Via REST API to Traction ACA-Py server:
- Sends credential to /credential/verify endpoint
- ACA-Py performs full cryptographic verification:
  * Signature verification
  * Issuer DID resolution
  * Revocation status check (if applicable)
  * Schema validation
  * Credential definition validation
- Returns verified: true/false

// Requirements:
- Network connection
- ACA-Py server reachable
- Server has necessary schemas/credDefs
```

**Use Case**: Real-time verification with revocation checks

**Tier**: 2 (Good confidence)

---

### 3. Offline Crypto Verification (Trust Bundle)

**Available**: Phase 3 (NEW!)

**How it works**:
```dart
// Using trust_bundle_core package:
- Load trust bundle (pre-synced schemas + credDefs)
- Extract credential signature
- Resolve issuer's public key via did:key
- Verify Ed25519 signature
- Compute SHA-256 hash of credential
- Compare against manifest hash
- Validate schema matches
- Validate credDef matches

// Requirements:
- Trust bundle synced (can be done offline after initial sync)
- Issuer in trusted keys list
- Schema and credDef in local database

// Works completely offline after sync
```

**Use Case**: High-confidence verification without network

**Tier**: 1 (Best confidence)

---

## Key Milestones

### Milestone 0: Current State (Day 0 - NOW)
- ✅ Offline structural verification (tested and working)
- ⚠️ ACA-Py client code (written but not tested)
- ✅ Credential import from Askar
- ✅ JSON export functionality
- 📍 Starting point for enhancements

### Milestone 1: Package Ready (End of Phase 1)
- ✅ `trust_bundle_core` package compiled
- ✅ All crypto tests passing
- ✅ Can verify test credentials independently
- 📦 Ready to integrate into main app

### Milestone 2: Mode Switching (End of Phase 2)
- ✅ Holder/Verifier/Hybrid modes working
- ✅ Mode persists across app restarts
- ✅ UI adapts based on mode
- 🎨 Foundation for role-based features

### Milestone 3: Full Crypto Verification ⭐ (End of Phase 3)
- ✅ All three verification tiers operational
- ✅ Automatic tier selection and fallback
- ✅ Offline crypto verification working
- ✅ Tier badges showing in UI
- 🎯 **MAJOR CAPABILITY UNLOCK**
- 🚀 **RECOMMENDED FIRST DEPLOYMENT POINT**

### Milestone 4: Verifier Features (End of Phase 4)
- ✅ QR scanning operational
- ✅ Manual verification working
- ✅ Trust bundle sync functional
- ✅ Verification logging complete
- 👮 Verifier mode fully usable

### Milestone 5: Production Ready (End of Phase 5)
- ✅ All features polished
- ✅ Comprehensive testing complete
- ✅ Documentation updated
- ✅ Performance optimized
- 🏭 Ready for production deployment

---

## Deployment Recommendations

### Option 1: Deploy After Phase 3 (Recommended) ⭐
**Why**: Complete 3-tier verification system operational
- Holders can self-verify with crypto
- Full offline crypto capability
- Enhanced online verification
- Automatic fallback
- **Best value-to-risk ratio**

### Option 2: Deploy After Phase 4
**Why**: Full verifier capabilities included
- Everything from Phase 3
- Plus verifier mode for inspectors
- QR scanning ready
- Audit logging operational

### Option 3: Deploy After Phase 5
**Why**: Maximum polish and production readiness
- Everything from Phase 4
- Plus professional UX
- Full documentation
- Optimized performance
- **Best for public release**

---

## Testing Strategy Per Phase

### Phase 1 Testing:
```bash
cd trust_bundle_core
flutter test
# Verify all crypto tests pass
```

### Phase 2 Testing:
```bash
# Manual testing:
1. Switch between modes
2. Restart app - verify mode persists
3. Check existing features still work
```

### Phase 3 Testing: ⭐ CRITICAL
```bash
# Test each tier independently:
1. Offline crypto (trust bundle):
   - Sync trust bundle
   - Disable network
   - Verify credential
   - Should show green "BEST" badge

2. Online crypto (ACA-Py):
   - Disable trust bundle
   - Enable network
   - Verify credential
   - Should show blue "GOOD" badge

3. Structural fallback:
   - Disable trust bundle
   - Disable network
   - Verify credential
   - Should show orange "LIMITED" badge

# Test automatic fallback:
4. Start with all enabled
   - Should try trust bundle first
   - Fall back to ACA-Py if trust bundle fails
   - Fall back to structural if both fail
```

### Phase 4 Testing:
```bash
# Test verifier mode:
1. Switch to verifier mode
2. Sync trust bundle
3. Generate test QR code (from holder mode)
4. Scan with verifier mode
5. Verify shows in audit log
```

### Phase 5 Testing:
```bash
# Full regression testing:
1. Test all modes (holder/verifier/hybrid)
2. Test all verification tiers
3. Test offline scenarios
4. Test online scenarios
5. Performance benchmarks
6. UI/UX review
```

---

## Risk Mitigation

### Phase 3 Risks (Critical Phase):
**Risk**: Trust bundle integration breaks existing verification
**Mitigation**: Keep structural verification as guaranteed fallback

**Risk**: Crypto verification too slow
**Mitigation**: Performance benchmarks, async processing, caching

**Risk**: Trust bundle database corruption
**Mitigation**: Validation on sync, atomic transactions, backup/restore

### Phase 4 Risks:
**Risk**: QR scanning doesn't work on all devices
**Mitigation**: Manual verification as alternative, platform-specific testing

### Phase 5 Risks:
**Risk**: Integration bugs discovered late
**Mitigation**: Comprehensive testing phase, beta testing program

---

## Success Criteria

### Phase 1 Success:
- ✅ Package compiles without errors
- ✅ All unit tests pass
- ✅ Can verify Ed25519 signatures
- ✅ Can validate SHA-256 hashes
- ✅ did:key resolution works

### Phase 2 Success:
- ✅ Mode switching works
- ✅ Mode persists across restarts
- ✅ UI updates correctly
- ✅ No regressions in existing features

### Phase 3 Success: ⭐
- ✅ Trust bundle verification works offline
- ✅ ACA-Py verification works online
- ✅ Structural verification always available
- ✅ Automatic fallback logic correct
- ✅ Tier badges display properly
- ✅ All three tiers tested with real credentials

### Phase 4 Success:
- ✅ QR scanning functional
- ✅ Manual verification works
- ✅ Trust bundle syncs successfully
- ✅ Verification logs saved and displayed
- ✅ Verifier mode fully operational

### Phase 5 Success:
- ✅ All features polished
- ✅ Documentation complete
- ✅ Performance acceptable (<100ms verification)
- ✅ No critical bugs
- ✅ Ready for production deployment

---

## Timeline Estimate

| Phase | Duration | Cumulative | Key Deliverable |
|-------|----------|------------|-----------------|
| Phase 0 | Complete | Day 0 | Current working app |
| Phase 1 | 2-3 days | Days 1-3 | Package ready |
| Phase 2 | 1 day | Day 4 | Mode switching |
| Phase 3 | 2-3 days | Days 5-7 | **Crypto verification live** ⭐ |
| Phase 4 | 3-4 days | Days 8-11 | Verifier mode |
| Phase 5 | 2-3 days | Days 12-14 | Production ready |
| **Total** | **10-14 days** | **2 weeks** | **Full system** |

---

## Next Steps

**Immediate Action**: Begin Phase 1 - Extract Trust Bundle Core Package

**Preparation Required**:
1. Access to Trust Bundle Verifier source code (✅ Available)
2. Development environment ready (✅ Flutter installed)
3. Git repository for `trust_bundle_core` package
4. Test credentials for verification testing

**Ready to Start**: Phase 1 can begin immediately

---

**Status**: Timeline Documented  
**Critical Milestone**: Phase 3 completion = Full crypto verification  
**Deployment Target**: End of Phase 3 or Phase 4  
**Production Ready**: End of Phase 5
