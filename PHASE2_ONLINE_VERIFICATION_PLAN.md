# Phase 2: Online Verification with ACA-Py Backend

**Project**: Askar Import - Trust Bundle Integration  
**Phase**: 2.0 - Online Verification Implementation  
**Date**: October 6, 2025  
**Status**: Planning

---

## Executive Summary

Phase 2 introduces **online verification** capabilities by integrating with the ACA-Py backend wallet. This enables real-time cryptographic verification, revocation checking, and full proof protocol support while maintaining offline fallback capabilities from Phase 1.

**Key Decision**: Use **ACA-Py backend wallet** for online verification, not device FFI wallet.

---

## Architecture Decision: Device Wallet vs ACA-Py Wallet

### Current Architecture

```
DEVICE (Holder)                    BACKEND (ACA-Py)
┌──────────────────┐              ┌──────────────────┐
│  Askar Wallet    │              │  ACA-Py Wallet   │
│  (via FFI)       │◄─── sync ────│  (Original)      │
│                  │              │                  │
│  • Local copy    │              │  • Source        │
│  • Read-only     │              │  • Full features │
│  • Fast access   │              │  • Crypto ops    │
└──────────────────┘              └──────────────────┘
```

### **Decision: Use ACA-Py Backend Wallet for Online Verification** ✅

---

## Comparison Matrix: Device FFI Wallet vs ACA-Py Wallet

| Aspect | Device FFI Wallet | ACA-Py Backend Wallet |
|--------|-------------------|----------------------|
| **Speed** | ⚡ Very fast (local) | ⚠️ Network delay (~200-500ms) |
| **Accuracy** | ⚠️ May be stale/outdated | ✅ Always current |
| **Proof Protocol** | ❌ No support | ✅ Full DIDComm proof protocol |
| **Revocation Checking** | ❌ Limited/stale | ✅ Real-time from ledger |
| **ZKP Generation** | ❌ Not supported | ✅ Full zero-knowledge proofs |
| **Predicate Proofs** | ❌ No (age > 18, etc.) | ✅ Yes |
| **Offline Operation** | ✅ Works without network | ❌ Requires network |
| **Security** | ⚠️ Device-dependent | ✅ Server-secured + audited |
| **Audit Trail** | ❌ Local only (can be deleted) | ✅ Centralized + immutable |
| **Single Source of Truth** | ❌ Copy (sync lag) | ✅ Original wallet |
| **Compliance** | ❌ Limited logging | ✅ Meets regulatory requirements |
| **Cryptographic Operations** | ⚠️ Read-only | ✅ Full crypto capabilities |

### **Winner**: ACA-Py Backend Wallet (for online mode)

---

## Why Use ACA-Py Backend (Not Device Wallet)

### 1. **Single Source of Truth**

```
PROBLEM with Device Wallet:
┌─────────────────────────────────────────┐
│ Device wallet is a COPY (snapshot)      │
│ • May be stale/outdated                 │
│ • Sync delays create inconsistency      │
│ • No guarantee it matches backend       │
└─────────────────────────────────────────┘

Timeline Example:
10:00 AM - Backend: Credential revoked
10:05 AM - Device: Still shows valid ❌

SOLUTION with ACA-Py:
┌─────────────────────────────────────────┐
│ ACA-Py wallet is the ORIGINAL           │
│ • Always current                        │
│ • No sync delay                         │
│ • Single source of truth                │
└─────────────────────────────────────────┘
```

### 2. **Full Cryptographic Capabilities**

```
Device FFI Wallet (Limited):
- ✓ Read credentials
- ✓ List entries
- ✗ Present proof protocol
- ✗ Credential exchange
- ✗ ZKP generation
- ✗ Predicate proofs
- ✗ Selective disclosure

ACA-Py Wallet (Complete):
- ✓ Read credentials
- ✓ List entries
- ✓ Present proof protocol ✨
- ✓ Credential exchange ✨
- ✓ ZKP generation ✨
- ✓ Predicate proofs ✨
- ✓ Selective disclosure ✨
- ✓ Revocation checking ✨
- ✓ Tails file management ✨
```

### 3. **Proof Protocol Requirements**

```
REAL VERIFICATION FLOW (Online):

Verifier → Proof Request
    ↓
    "Prove you're over 18"
    "Without revealing exact age"
    ↓
Holder (needs ACA-Py) → Generate ZKP
    ↓
    Uses ACA-Py's proof generation
    Creates zero-knowledge proof
    Applies predicates
    ↓
Holder → Verifier: Proof
    ↓
Verifier validates proof

❌ Device FFI cannot generate ZKPs!
✅ ACA-Py has full proof protocol!
```

### 4. **Revocation Checking**

```
Revocation requires:
- Access to revocation registry
- Witness generation
- Tails file handling
- Delta computation
- Real-time ledger queries

❌ Device FFI: Limited support, stale data
✅ ACA-Py: Full support, real-time
```

### 5. **Security & Compliance**

```
Device Wallet Risks:
- Device could be compromised
- Local wallet could be modified
- Logs can be deleted
- No audit trail
- Limited security hardening

ACA-Py Benefits:
- Server-side security
- Immutable audit logs
- Regulatory compliance (GDPR, HIPAA)
- Access controls
- Monitoring & alerting
```

---

## Recommended Verification Strategy

### **Hybrid Approach (Best of Both Worlds)**

```
OFFLINE MODE:
┌──────────────────────────────────┐
│  Use Device Wallet (FFI)         │
│  ✓ No network needed             │
│  ✓ Fast local access             │
│  ✓ Trust Bundle verification    │
│  ✓ Privacy-preserving            │
└──────────────────────────────────┘

ONLINE MODE:
┌──────────────────────────────────┐
│  Use ACA-Py Backend              │
│  ✓ Full proof protocol           │
│  ✓ Real-time revocation         │
│  ✓ ZKP generation               │
│  ✓ Complete verification        │
│  ✓ Audit trail                  │
└──────────────────────────────────┘
```

### **Decision Flow**

```
User initiates verification
        ↓
Is airplane mode ON?
        ↓
    ┌───┴───┐
   YES     NO
    │       │
    │       └─→ Is network available?
    │               ↓
    │           ┌───┴───┐
    │          YES     NO
    │           │       │
    │           │       └─→ OFFLINE MODE
    │           │           (Device wallet)
    │           │
    │           └─→ ONLINE MODE
    │               (ACA-Py backend)
    │               ↓
    │           Backend reachable?
    │               ↓
    │           ┌───┴───┐
    │          YES     NO
    │           │       │
    │           │       └─→ FALLBACK TO OFFLINE
    │           │
    │           └─→ Use ACA-Py (GOOD tier)
    │
    └─→ OFFLINE MODE
        ├─ Try Trust Bundle (BEST)
        └─ Fallback: Structural (BASIC)
```

---

## Phase 2 Sub-Phases (Incremental Development)

### **Phase 2.1: ACA-Py Backend Integration Foundation** 🏗️
*Duration: 3-5 days*

**Goal**: Establish connection to ACA-Py backend and basic API communication.

**Deliverables**:
- [ ] ACA-Py HTTP client service
- [ ] Connection health checking
- [ ] API authentication (if needed)
- [ ] Error handling & retry logic
- [ ] Configuration management (backend URL)
- [ ] Unit tests for API client

**Files to Create/Modify**:
- `lib/services/acapy_client.dart` (new)
- `lib/config/acapy_config.dart` (new)
- `test/services/acapy_client_test.dart` (new)

**Success Criteria**:
- ✅ Can ping ACA-Py health endpoint
- ✅ Can authenticate with backend
- ✅ Handles network errors gracefully
- ✅ Config can be changed by user

---

### **Phase 2.2: Basic Credential Verification via ACA-Py** 🔍
*Duration: 5-7 days*

**Goal**: Implement basic credential verification using ACA-Py backend wallet.

**Deliverables**:
- [ ] Credential verification API endpoint wrapper
- [ ] Convert device credential format to ACA-Py format
- [ ] Parse ACA-Py verification response
- [ ] Add GOOD tier to verification results
- [ ] Update UI to show GOOD tier badges
- [ ] Integration tests

**Files to Create/Modify**:
- `lib/services/acapy_verification_service.dart` (new)
- `lib/services/enhanced_verification_service.dart` (modify - add GOOD tier)
- `lib/ui/pages/verify_local_page.dart` (modify - show GOOD tier)

**API Endpoint** (to implement on backend or mock):
```
POST /api/v1/credentials/verify
{
  "credential": { /* AnonCreds credential */ },
  "check_revocation": true
}

Response:
{
  "verified": true,
  "checks": {
    "signature": "valid",
    "schema": "valid",
    "cred_def": "valid",
    "revocation": "not_revoked"
  },
  "timestamp": "2025-10-06T..."
}
```

**Success Criteria**:
- ✅ Can verify credential via ACA-Py
- ✅ Shows GOOD tier in UI (green badge)
- ✅ Displays verification details
- ✅ Handles backend errors (falls back to BEST/BASIC)

---

### **Phase 2.3: Real-Time Revocation Checking** 🚫
*Duration: 4-6 days*

**Goal**: Implement real-time revocation status checking via ACA-Py.

**Deliverables**:
- [ ] Revocation status query via ACA-Py
- [ ] Revocation registry integration
- [ ] Display revocation status in UI
- [ ] Warning when credential is revoked
- [ ] Revocation timestamp display
- [ ] Cache revocation status (short TTL)

**Files to Create/Modify**:
- `lib/services/acapy_revocation_service.dart` (new)
- `lib/models/revocation_status.dart` (new)
- `lib/ui/pages/verify_local_page.dart` (modify - show revocation)
- `lib/ui/pages/sync_wallet_page.dart` (modify - show revocation warnings)

**Success Criteria**:
- ✅ Checks revocation status in real-time
- ✅ Shows revoked credentials with red badge
- ✅ Displays revocation timestamp
- ✅ Works for non-revocable credentials too
- ✅ Caches results to avoid repeated queries

---

### **Phase 2.4: Tier Selection & Fallback Logic** 🎯
*Duration: 3-4 days*

**Goal**: Implement intelligent tier selection based on network availability.

**Deliverables**:
- [ ] Network connectivity detection
- [ ] Automatic tier selection logic
- [ ] Fallback cascade (GOOD → BEST → BASIC)
- [ ] User notification of tier used
- [ ] Performance metrics (verification time)
- [ ] Tier selection preferences (user can force offline)

**Files to Create/Modify**:
- `lib/services/network_service.dart` (new)
- `lib/services/tier_selection_service.dart` (new)
- `lib/services/enhanced_verification_service.dart` (modify - add tier logic)
- `lib/ui/widgets/tier_badge.dart` (enhance)

**Logic Flow**:
```dart
Future<VerificationResult> verifyCredential(credential) async {
  // 1. Check if airplane mode
  if (airplaneMode) {
    return await verifyOffline(credential);
  }
  
  // 2. Try GOOD tier (ACA-Py)
  try {
    return await verifyWithAcaPy(credential);
  } catch (e) {
    log('GOOD tier failed: $e');
  }
  
  // 3. Fallback to BEST tier (Trust Bundle)
  try {
    return await verifyWithTrustBundle(credential);
  } catch (e) {
    log('BEST tier failed: $e');
  }
  
  // 4. Fallback to BASIC tier (Structural)
  return await verifyStructure(credential);
}
```

**Success Criteria**:
- ✅ Automatically selects best available tier
- ✅ Falls back gracefully on failure
- ✅ Shows user which tier was used
- ✅ Respects airplane mode setting
- ✅ Logs tier selection for debugging

---

### **Phase 2.5: Proof Protocol Support (Presentation)** 🎭
*Duration: 7-10 days*

**Goal**: Enable full proof presentation protocol via ACA-Py.

**Deliverables**:
- [ ] Proof request parsing
- [ ] Proof generation via ACA-Py
- [ ] Selective disclosure support
- [ ] Predicate proofs (age > 18, etc.)
- [ ] Proof presentation to verifier
- [ ] Proof verification UI

**Files to Create/Modify**:
- `lib/services/proof_presentation_service.dart` (new)
- `lib/models/proof_request.dart` (new)
- `lib/models/proof_presentation.dart` (new)
- `lib/ui/pages/proof_request_page.dart` (new)
- `lib/ui/pages/proof_presentation_page.dart` (new)

**API Endpoints**:
```
POST /api/v1/proofs/create
{
  "proof_request": { /* DIDComm proof request */ },
  "credentials": [ /* selected credentials */ ],
  "self_attested": { /* optional self-attested */ }
}

Response:
{
  "proof": { /* generated proof */ },
  "proof_format": "indy",
  "presentation_exchange_id": "..."
}
```

**Success Criteria**:
- ✅ Can generate proofs via ACA-Py
- ✅ Supports selective disclosure
- ✅ Supports predicates
- ✅ Shows proof request to user
- ✅ User can approve/reject proof request

---

### **Phase 2.6: UI/UX Enhancements for Online Mode** 🎨
*Duration: 4-5 days*

**Goal**: Polish UI to clearly show online vs offline verification.

**Deliverables**:
- [ ] Enhanced tier badges (GOOD/BEST/BASIC)
- [ ] Animated verification progress
- [ ] Network status indicator (more prominent)
- [ ] Verification details modal
- [ ] Performance metrics display
- [ ] Error messages improved
- [ ] Loading states enhanced

**Files to Create/Modify**:
- `lib/ui/widgets/tier_badge.dart` (enhance)
- `lib/ui/widgets/verification_progress.dart` (new)
- `lib/ui/widgets/verification_details_modal.dart` (new)
- `lib/ui/pages/verify_local_page.dart` (modify - better UX)

**UI Mockup**:
```
┌────────────────────────────────────┐
│  Verifying Credential...           │
├────────────────────────────────────┤
│  [████████░░] 80%                  │
│                                    │
│  ✓ Signature Valid                │
│  ✓ Schema Verified                │
│  ✓ Issuer Trusted                 │
│  🔄 Checking Revocation...         │
│                                    │
│  Using: GOOD Tier (ACA-Py)        │
│  Time: 1.2s                       │
└────────────────────────────────────┘
```

**Success Criteria**:
- ✅ Clear visual distinction between tiers
- ✅ Users understand which mode is active
- ✅ Loading states prevent confusion
- ✅ Error messages are actionable
- ✅ Performance metrics visible

---

### **Phase 2.7: Audit Logging & Analytics** 📊
*Duration: 3-4 days*

**Goal**: Implement comprehensive logging for compliance and debugging.

**Deliverables**:
- [ ] Local verification logs
- [ ] Backend audit trail integration
- [ ] Analytics dashboard (basic)
- [ ] Export logs to JSON/CSV
- [ ] Privacy-preserving logging
- [ ] Compliance report generation

**Files to Create/Modify**:
- `lib/services/audit_log_service.dart` (new)
- `lib/models/verification_log.dart` (new)
- `lib/ui/pages/audit_logs_page.dart` (new)
- `lib/ui/pages/analytics_page.dart` (new)

**Log Format**:
```json
{
  "timestamp": "2025-10-06T10:30:00Z",
  "credential_id": "hash_of_credential",
  "verification_tier": "GOOD",
  "result": "success",
  "duration_ms": 1234,
  "checks": {
    "signature": "valid",
    "revocation": "not_revoked"
  },
  "network_mode": "online",
  "device_id": "hash_of_device"
}
```

**Success Criteria**:
- ✅ All verifications logged locally
- ✅ Logs synced to backend (if online)
- ✅ Can view verification history
- ✅ Can export logs
- ✅ Privacy preserved (no PII)

---

### **Phase 2.8: Testing & Performance Optimization** 🚀
*Duration: 5-7 days*

**Goal**: Comprehensive testing and performance optimization.

**Deliverables**:
- [ ] Unit tests for all new services
- [ ] Integration tests for ACA-Py integration
- [ ] End-to-end tests for verification flows
- [ ] Performance benchmarks
- [ ] Load testing
- [ ] Error scenario testing
- [ ] Security audit

**Test Coverage Goals**:
- Unit tests: >85%
- Integration tests: All critical paths
- E2E tests: All user flows

**Performance Targets**:
- GOOD tier: <2 seconds
- BEST tier: <500ms
- BASIC tier: <100ms
- Fallback time: <5 seconds

**Success Criteria**:
- ✅ All tests passing
- ✅ Performance meets targets
- ✅ Security vulnerabilities addressed
- ✅ Error handling comprehensive
- ✅ Ready for production

---

## Phase 2 Timeline Summary

```
Phase 2.1: ACA-Py Integration         [3-5 days]   Week 1
Phase 2.2: Basic Verification         [5-7 days]   Week 1-2
Phase 2.3: Revocation Checking        [4-6 days]   Week 2
Phase 2.4: Tier Selection             [3-4 days]   Week 2-3
Phase 2.5: Proof Protocol             [7-10 days]  Week 3-4
Phase 2.6: UI/UX Enhancements         [4-5 days]   Week 4
Phase 2.7: Audit Logging              [3-4 days]   Week 5
Phase 2.8: Testing & Optimization     [5-7 days]   Week 5-6

TOTAL: 34-48 days (5-7 weeks)
```

---

## Technical Architecture

### **Component Diagram**

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  UI Layer (Pages & Widgets)                  │  │
│  │  - Verify Local Page                         │  │
│  │  - Tier Badges                               │  │
│  │  - Verification Progress                     │  │
│  └──────────────────────────────────────────────┘  │
│                       ↓                             │
│  ┌──────────────────────────────────────────────┐  │
│  │  Enhanced Verification Service               │  │
│  │  (Tier Selection & Orchestration)            │  │
│  └──────────────────────────────────────────────┘  │
│           ↓              ↓              ↓           │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │   GOOD     │  │   BEST     │  │   BASIC    │   │
│  │  (ACA-Py)  │  │  (Trust    │  │ (Struct.)  │   │
│  │            │  │  Bundle)   │  │            │   │
│  └────────────┘  └────────────┘  └────────────┘   │
│        ↓                                            │
│  ┌──────────────────────────────────────────────┐  │
│  │  ACA-Py Client Service                       │  │
│  │  - HTTP client                               │  │
│  │  - Authentication                            │  │
│  │  - Error handling                            │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
                       ↓ HTTP
            ┌──────────────────────┐
            │  ACA-Py Backend      │
            │  (Traction/Cloud)    │
            ├──────────────────────┤
            │  - Wallet (source)   │
            │  - Proof protocol    │
            │  - Revocation        │
            │  - Ledger access     │
            └──────────────────────┘
                       ↓
            ┌──────────────────────┐
            │  Indy Ledger         │
            │  (BCovrin/MainNet)   │
            └──────────────────────┘
```

---

## API Specification

### **Endpoints to Implement/Integrate**

#### 1. Credential Verification

```http
POST /api/v1/credentials/verify
Content-Type: application/json
Authorization: Bearer <token>

Request:
{
  "credential": {
    "schema_id": "...",
    "cred_def_id": "...",
    "values": { ... },
    "signature": { ... },
    ...
  },
  "check_revocation": true,
  "verification_mode": "full"  // or "quick"
}

Response:
{
  "verified": true,
  "tier": "GOOD",
  "timestamp": "2025-10-06T10:30:00Z",
  "checks": {
    "signature": "valid",
    "schema": "valid",
    "cred_def": "valid",
    "issuer": "trusted",
    "revocation": "not_revoked"
  },
  "details": {
    "issuer_did": "...",
    "issued_at": "...",
    "revocation_checked_at": "..."
  },
  "performance": {
    "duration_ms": 1234
  }
}
```

#### 2. Revocation Status

```http
GET /api/v1/credentials/{cred_id}/revocation-status
Authorization: Bearer <token>

Response:
{
  "revoked": false,
  "revocation_registry_id": "...",
  "checked_at": "2025-10-06T10:30:00Z",
  "cache_ttl_seconds": 300
}
```

#### 3. Proof Generation

```http
POST /api/v1/proofs/create
Content-Type: application/json
Authorization: Bearer <token>

Request:
{
  "proof_request": {
    "name": "age_verification",
    "version": "1.0",
    "requested_attributes": { ... },
    "requested_predicates": {
      "age_over_18": {
        "name": "age",
        "p_type": ">=",
        "p_value": 18
      }
    }
  },
  "credentials": [ /* selected credentials */ ]
}

Response:
{
  "proof": { /* generated proof */ },
  "presentation_exchange_id": "..."
}
```

#### 4. Health Check

```http
GET /api/v1/health
Response:
{
  "status": "healthy",
  "services": {
    "wallet": "ok",
    "ledger": "ok",
    "database": "ok"
  },
  "version": "1.0.0"
}
```

---

## Configuration

### **ACA-Py Backend Settings**

```yaml
# config/acapy_config.yaml

acapy:
  base_url: "https://traction.example.com"
  api_version: "v1"
  timeout_seconds: 30
  retry_attempts: 3
  
authentication:
  type: "bearer"  # or "api_key"
  # token: "..." # Configured at runtime
  
verification:
  default_tier: "GOOD"
  fallback_enabled: true
  cache_duration_seconds: 300
  check_revocation: true
  
performance:
  connection_pool_size: 5
  max_concurrent_requests: 3
```

---

## Security Considerations

### **Authentication**

- Use secure token storage (Flutter Secure Storage)
- Implement token refresh mechanism
- Support multiple auth methods (Bearer, API Key, mTLS)

### **Data Privacy**

- Never log full credential data
- Hash credential IDs in logs
- Encrypt local verification logs
- Respect user privacy preferences

### **Network Security**

- Enforce HTTPS only
- Certificate pinning (optional)
- Request signing (optional)
- Rate limiting handling

---

## Success Metrics

### **Phase 2 Success Criteria**

#### Functional:
- ✅ Can verify credentials via ACA-Py (GOOD tier)
- ✅ Real-time revocation checking works
- ✅ Automatic fallback to offline tiers
- ✅ Proof protocol support (basic)
- ✅ All sub-phases completed

#### Performance:
- ✅ GOOD tier: <2 seconds average
- ✅ Fallback: <5 seconds max
- ✅ 99% uptime (with fallback)

#### Quality:
- ✅ >85% test coverage
- ✅ Zero critical bugs
- ✅ Security audit passed

#### User Experience:
- ✅ Clear tier indication
- ✅ Smooth offline/online transitions
- ✅ Informative error messages

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| ACA-Py backend unavailable | Medium | High | Automatic fallback to offline |
| Network latency issues | High | Medium | Timeout + fallback, caching |
| API changes breaking app | Low | High | API versioning, integration tests |
| Authentication complexity | Medium | Medium | Use standard OAuth/Bearer tokens |
| Performance degradation | Medium | Medium | Caching, load testing, optimization |
| Privacy concerns | Low | High | Privacy-preserving logging, encryption |

---

## Next Steps After Phase 2

### **Phase 3: Advanced Features** (Future)
- Machine learning tier prediction
- Offline queue for later verification
- Multi-verifier coordination
- Cross-jurisdiction support
- Enhanced analytics dashboard

---

## Appendix: Code Examples

### **ACA-Py Client Service (Skeleton)**

```dart
// lib/services/acapy_client.dart

class AcaPyClient {
  final String baseUrl;
  final http.Client _httpClient;
  
  AcaPyClient(this.baseUrl) : _httpClient = http.Client();
  
  Future<bool> healthCheck() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/v1/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> verifyCredential(
    Map<String, dynamic> credential, {
    bool checkRevocation = true,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/api/v1/credentials/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getToken()}',
      },
      body: jsonEncode({
        'credential': credential,
        'check_revocation': checkRevocation,
      }),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw AcaPyException('Verification failed: ${response.statusCode}');
    }
  }
  
  String _getToken() {
    // Get token from secure storage
    return 'your_token_here';
  }
}
```

---

## Summary

Phase 2 transforms the app from **offline-only** to a **hybrid online/offline** verification system:

- ✅ **Offline (Phase 1)**: Trust Bundle + Structural verification
- ✅ **Online (Phase 2)**: ACA-Py backend verification + Real-time revocation
- ✅ **Hybrid**: Automatic tier selection with graceful fallback

**Key Advantage**: Use ACA-Py backend wallet as single source of truth for online verification while maintaining offline capabilities.

**Development Approach**: Incremental sub-phases allow for continuous testing and deployment.

**Timeline**: 5-7 weeks for complete Phase 2 implementation.

---

**Ready to begin Phase 2.1: ACA-Py Backend Integration Foundation!** 🚀
