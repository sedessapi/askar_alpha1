# Online Scenarios: When Both Holder and Verifier Are Connected

**Last Updated**: October 4, 2025

---

## Overview

When **both holder (Askar Import) and verifier (Trust Bundle Verifier) have internet connectivity**, additional capabilities and verification options become available beyond pure offline operation.

---

## Architecture: Online Mode

```
HOLDER (Online)                 INTERNET                VERIFIER (Online)
┌─────────────────┐               │                    ┌──────────────────┐
│  Askar Import   │               │                    │  Trust Bundle    │
│                 │               │                    │  Verifier        │
│  Verification:  │               │                    │                  │
│  1. Trust Bundle│◄──────────────┼────────────────────│  1. Trust Bundle │
│  2. ACA-Py ✓    │               │                    │  2. ACA-Py ✓     │
│  3. Structural  │               │                    │  3. Structural   │
└─────────────────┘               │                    └──────────────────┘
         │                        │                             │
         │                        │                             │
         └────────────────────────┼─────────────────────────────┘
                                  │
                                  ↓
                    ┌──────────────────────────┐
                    │   SHARED CLOUD SERVICES  │
                    ├──────────────────────────┤
                    │                          │
                    │  • Traction ACA-Py       │
                    │    - Revocation checks   │
                    │    - Fresh crypto verify │
                    │    - Proof protocol      │
                    │                          │
                    │  • Trust Bundle Server   │
                    │    - Bundle sync         │
                    │    - Updates             │
                    │                          │
                    │  • Ledger (Indy)         │
                    │    - Schema queries      │
                    │    - CredDef queries     │
                    │    - Rev registry        │
                    │                          │
                    │  • Audit Services        │
                    │    - Verification logs   │
                    │    - Analytics           │
                    │    - Compliance reports  │
                    └──────────────────────────┘
```

---

## Use Case 1: Real-Time Revocation Checking

### Scenario: Employee Termination

**Context**: Employee was fired this morning, credential was revoked immediately.

```
TIMELINE:
09:00 AM - Employee terminated
09:05 AM - HR revokes employee credential on ledger
10:00 AM - Ex-employee tries to enter building

OFFLINE MODE (❌ Would Fail):
┌─────────────────┐              ┌──────────────────┐
│ Ex-Employee     │              │ Security Kiosk   │
│ Phone (Offline) │   Shows ──▶  │ (Offline)        │
│                 │   Badge      │                  │
│ Old trust bundle│              │ Old trust bundle │
│ says "VALID" ❌ │              │ says "VALID" ❌  │
│                 │              │ GRANTS ACCESS ❌ │
└─────────────────┘              └──────────────────┘
Problem: Neither device knows about revocation!

ONLINE MODE (✅ Works Correctly):
┌─────────────────┐              ┌──────────────────┐
│ Ex-Employee     │              │ Security Kiosk   │
│ Phone (Online)  │   Shows ──▶  │ (Online)         │
│                 │   Badge      │                  │
│ Checks ACA-Py   │              │ Checks ledger    │
│ sees "REVOKED"  │              │ sees "REVOKED"   │
│ Shows warning ⚠️│              │ DENIES ACCESS ✓  │
└─────────────────┘              └──────────────────┘
         │                                │
         └────────┬──────────────────────┘
                  ↓
      ┌──────────────────────┐
      │ Ledger/ACA-Py        │
      │ "Revoked at 09:05"   │
      └──────────────────────┘
```

**Benefits of Online**:
- ✅ **Instant revocation** - No delay between revocation and enforcement
- ✅ **Security** - Terminated employees can't use old credentials
- ✅ **Compliance** - Meets regulatory requirements for immediate access removal
- ✅ **Audit trail** - All access attempts logged centrally

**Real-World Examples**:
- Corporate building access after termination
- Bank account access after fraud detection
- Healthcare system access after license suspension
- Government facility access after security clearance revoked

---

## Use Case 2: Fresh Cryptographic Verification

### Scenario: High-Security Access

**Context**: Critical infrastructure requiring strongest possible verification.

```
VERIFICATION COMPARISON:

OFFLINE (Trust Bundle):
┌─────────────────────────────────────────┐
│ Trust Bundle Verification               │
├─────────────────────────────────────────┤
│ ✓ Signature valid                       │
│ ✓ Schema matches                        │
│ ✓ CredDef matches                       │
│ ✓ Structure correct                     │
│ ? Revocation unknown (stale bundle)     │
│ ? Issuer key rotated? (don't know)     │
└─────────────────────────────────────────┘
Last sync: 24 hours ago

ONLINE (ACA-Py + Ledger):
┌─────────────────────────────────────────┐
│ Online Cryptographic Verification       │
├─────────────────────────────────────────┤
│ ✓ Signature valid (checked now)         │
│ ✓ Schema matches (latest)               │
│ ✓ CredDef matches (latest)              │
│ ✓ Structure correct                     │
│ ✓ Revocation checked (real-time)       │
│ ✓ Issuer key current (real-time)       │
│ ✓ Timestamp verified                    │
│ ✓ Nonce prevents replay                │
└─────────────────────────────────────────┘
Verified: NOW
```

**Benefits of Online**:
- ✅ **Maximum security** - All checks are fresh, not cached
- ✅ **Current data** - Latest schema/creddef from ledger
- ✅ **Replay protection** - Fresh nonces prevent replay attacks
- ✅ **Key rotation** - Detects if issuer rotated keys

**Real-World Examples**:
- Nuclear facility access
- Financial transaction approval
- Medical prescription authorization
- Government classified system access

---

## Use Case 3: Dynamic Proof Requests

### Scenario: Adaptive Verification Requirements

**Context**: Verifier adjusts what to verify based on context.

```
OFFLINE (Static):
┌─────────────────────────────────────────────┐
│ Verifier requests fixed proof:              │
│ - Name                                      │
│ - Date of Birth                             │
│ - Citizenship                               │
│                                             │
│ Cannot adapt to situation                   │
└─────────────────────────────────────────────┘

ONLINE (Dynamic):
┌─────────────────────────────────────────────┐
│ Step 1: Initial Check                       │
│ Verifier: "Show age > 18"                   │
│ Holder: "I'm 25" ✓                          │
│                                             │
│ Step 2: Risk-Based Decision (Online Query)  │
│ Verifier checks database:                   │
│ → This person tried entry 5 times today     │
│ → Unusual pattern detected                  │
│                                             │
│ Step 3: Enhanced Verification               │
│ Verifier: "Now also show:                   │
│            - Full name                      │
│            - Photo credential               │
│            - Employment proof"              │
│                                             │
│ Holder provides additional proofs           │
└─────────────────────────────────────────────┘

WORKFLOW:
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Holder    │         │  Verifier    │         │    Risk     │
│   Device    │         │   Device     │         │   System    │
└──────┬──────┘         └──────┬───────┘         └──────┬──────┘
       │                       │                        │
       │  Initial Proof        │                        │
       │──────────────────────▶│                        │
       │                       │                        │
       │                       │  Check Risk Score      │
       │                       │───────────────────────▶│
       │                       │                        │
       │                       │  Score: HIGH ⚠️        │
       │                       │◀───────────────────────│
       │                       │                        │
       │  Additional Proof Req │                        │
       │◀──────────────────────│                        │
       │                       │                        │
       │  Enhanced Proof       │                        │
       │──────────────────────▶│                        │
       │                       │                        │
       │                       │  Log & Approve         │
       │                       │───────────────────────▶│
       │                       │                        │
       │  Access Granted ✓     │                        │
       │◀──────────────────────│                        │
```

**Benefits of Online**:
- ✅ **Context-aware** - Adjust verification based on risk
- ✅ **Fraud detection** - Check against central fraud database
- ✅ **Multi-step verification** - Progressive disclosure as needed
- ✅ **Business logic** - Apply complex rules from backend

**Real-World Examples**:
- Airport security (risk-based screening)
- Bank transactions (fraud detection)
- Healthcare access (emergency override checks)
- Border control (watch list checks)

---

## Use Case 4: Multi-Party Verification

### Scenario: Coordinated Verification Across Systems

**Context**: Multiple verifiers need to coordinate on same holder.

```
SCENARIO: International Airport Transit

HOLDER: Traveler with digital passport
VERIFIERS: Multiple checkpoints that need to coordinate

┌──────────────────────────────────────────────────────────┐
│                  AIRPORT SYSTEMS                         │
└──────────────────────────────────────────────────────────┘
                           ▲
                           │ All online, sharing data
                           │
    ┌──────────────────────┼──────────────────────┐
    │                      │                      │
    ↓                      ↓                      ↓
┌─────────┐          ┌─────────┐          ┌─────────┐
│ Check-In│          │ Security│          │  Gate   │
│  Desk   │          │  (TSA)  │          │  Agent  │
└─────────┘          └─────────┘          └─────────┘
    │                      │                      │
    │ Scans passport       │                      │
    │ Verifies online      │                      │
    │ Logs: "Checked in"   │                      │
    │                      │                      │
    │                      │ Scans same passport  │
    │                      │ Sees: "Already OK"   │
    │                      │ Adds: "Cleared TSA"  │
    │                      │                      │
    │                      │                      │ Scans again
    │                      │                      │ Sees full history:
    │                      │                      │ - Checked in ✓
    │                      │                      │ - TSA cleared ✓
    │                      │                      │ Adds: "Boarded"
    │                      │                      │
    └──────────────────────┴──────────────────────┘
                           │
                           ↓
              ┌──────────────────────┐
              │  Shared Audit Log    │
              ├──────────────────────┤
              │ 10:00 - Check-in ✓   │
              │ 10:15 - TSA ✓        │
              │ 10:45 - Boarded ✓    │
              └──────────────────────┘
```

**Benefits of Online**:
- ✅ **Coordination** - Each checkpoint sees what others did
- ✅ **Efficiency** - Skip redundant checks
- ✅ **Security** - Detect anomalies (e.g., boarded without TSA)
- ✅ **Compliance** - Complete audit trail

**Real-World Examples**:
- Airport security checkpoints
- Hospital admission (registration → triage → doctor → pharmacy)
- Court system (clerk → security → judge → bailiff)
- University registration (advisor → registrar → financial aid → ID office)

---

## Use Case 5: Credential Status Updates

### Scenario: Holder Self-Service Updates

**Context**: Holder wants to check credential status proactively.

```
HOLDER'S SELF-SERVICE DASHBOARD (Online):

┌──────────────────────────────────────────────┐
│  My Credentials - Askar Import               │
├──────────────────────────────────────────────┤
│                                              │
│  🎓 University Degree                        │
│     Status: ✅ VALID                         │
│     Expires: Never                           │
│     Issuer: MIT                              │
│     [Verify Now] [View Details]              │
│                                              │
│  💼 Professional License                     │
│     Status: ⚠️ EXPIRING SOON                │
│     Expires: Nov 1, 2025 (28 days)          │
│     Action: [Renew License]                  │
│                                              │
│  🏥 Health Insurance                         │
│     Status: ✅ VALID                         │
│     Last Verified: 2 hours ago              │
│     Issuer: Blue Cross                       │
│     [Check Coverage] [File Claim]            │
│                                              │
│  🚗 Driver's License                         │
│     Status: ❌ REVOKED                       │
│     Reason: DUI conviction                   │
│     Revoked: Sept 15, 2025                  │
│     [Appeal] [View Details]                  │
│                                              │
└──────────────────────────────────────────────┘

ONLINE FEATURES:
┌─────────────────────────────────────────────┐
│ When holder clicks "Verify Now":            │
│                                             │
│ 1. Check revocation status (real-time)     │
│ 2. Verify issuer still trusted             │
│ 3. Check for updates/amendments            │
│ 4. Refresh trust bundle                    │
│ 5. Show detailed status                    │
│                                             │
│ Benefits:                                   │
│ • Know before you show                     │
│ • Avoid embarrassment                      │
│ • Time to fix issues                       │
│ • Update credentials proactively           │
└─────────────────────────────────────────────┘
```

**Benefits of Online**:
- ✅ **Proactive monitoring** - Check status before important events
- ✅ **Notifications** - Get alerts when credentials expire/revoke
- ✅ **Self-service** - Manage credentials independently
- ✅ **Peace of mind** - Know everything is current

**Real-World Examples**:
- Check license before job interview
- Verify insurance before doctor visit
- Check passport before booking flight
- Verify degree before applying to grad school

---

## Use Case 6: Cross-Jurisdiction Verification

### Scenario: International Credential Verification

**Context**: Credential issued in one country, verified in another.

```
OFFLINE (❌ Difficult):
┌───────────────────────────────────────────────┐
│ Problem: Trust bundles may not include        │
│          foreign issuer information           │
│                                               │
│ Holder in USA, credential from Canada        │
│ Verifier in USA has only USA trust bundle    │
│ → Cannot verify Canadian credential          │
└───────────────────────────────────────────────┘

ONLINE (✅ Works):
┌───────────────────────────────────────────────┐
│ Solution: Dynamic trust resolution            │
│                                               │
│ Step 1: Verifier receives credential          │
│ Step 2: Sees issuer DID from Canada          │
│ Step 3: Queries international registry       │
│ Step 4: Downloads Canadian issuer's trust    │
│         information dynamically               │
│ Step 5: Verifies credential                  │
│ Step 6: Caches for future use                │
└───────────────────────────────────────────────┘

WORKFLOW:
┌─────────────┐    ┌─────────────┐    ┌──────────────┐
│   Holder    │    │   Verifier  │    │ International│
│   (Canada)  │    │    (USA)    │    │   Registry   │
└──────┬──────┘    └──────┬──────┘    └───────┬──────┘
       │                  │                    │
       │ Canadian Degree  │                    │
       │─────────────────▶│                    │
       │                  │                    │
       │                  │ Unknown issuer?    │
       │                  │ Query registry     │
       │                  │───────────────────▶│
       │                  │                    │
       │                  │ Issuer info +      │
       │                  │ Trust anchor       │
       │                  │◀───────────────────│
       │                  │                    │
       │                  │ Verify credential  │
       │                  │ using downloaded   │
       │                  │ trust info ✓       │
       │                  │                    │
       │     Access ✓     │                    │
       │◀─────────────────│                    │
```

**Benefits of Online**:
- ✅ **Global interoperability** - Accept foreign credentials
- ✅ **Dynamic trust** - Don't need every issuer pre-loaded
- ✅ **Scalability** - Support unlimited jurisdictions
- ✅ **Compliance** - Meet international standards

**Real-World Examples**:
- International student admissions
- Foreign worker verification
- Medical license reciprocity
- Professional certification recognition

---

## Use Case 7: Audit and Compliance Logging

### Scenario: Regulatory Compliance Requirements

**Context**: Must log all verifications for regulatory compliance.

```
OFFLINE (❌ Limited):
┌───────────────────────────────────────┐
│ Local logs only on verifier device    │
│ • Not centralized                     │
│ • Can be deleted                      │
│ • Hard to audit                       │
│ • No analytics                        │
└───────────────────────────────────────┘

ONLINE (✅ Comprehensive):
┌───────────────────────────────────────┐
│ Centralized audit logging             │
│ • Every verification logged           │
│ • Immutable records                   │
│ • Real-time analytics                 │
│ • Compliance reports                  │
│ • Anomaly detection                   │
└───────────────────────────────────────┘

AUDIT TRAIL EXAMPLE:
┌──────────────────────────────────────────────┐
│  Verification Audit Log - October 4, 2025    │
├──────────────────────────────────────────────┤
│                                              │
│ Timestamp    │ Holder DID │ Credential │ Result │ Verifier │
│──────────────┼────────────┼────────────┼────────┼──────────│
│ 09:15:23 AM  │ did:key:z6│ Degree     │ ✓ PASS │ Guard-01 │
│ 09:16:45 AM  │ did:key:z7│ License    │ ❌ FAIL│ Guard-01 │
│ 09:17:12 AM  │ did:key:z8│ Badge      │ ✓ PASS │ Guard-02 │
│ 09:18:55 AM  │ did:key:z9│ License    │ ⚠️ WARN│ Guard-01 │
│                           │            │ (expiring) │       │
│                                              │
│ Analytics:                                   │
│ • Total verifications today: 1,234          │
│ • Success rate: 94.2%                       │
│ • Average time: 1.8 seconds                 │
│ • Anomalies detected: 3                     │
│ • Most verified credential: Employee Badge  │
│                                              │
│ Compliance Reports:                          │
│ [Export to CSV] [Generate PDF] [Send to API]│
└──────────────────────────────────────────────┘
```

**Benefits of Online**:
- ✅ **Regulatory compliance** - Meet audit requirements (GDPR, HIPAA, etc.)
- ✅ **Forensics** - Investigate security incidents
- ✅ **Analytics** - Understand usage patterns
- ✅ **Billing** - Charge based on verifications
- ✅ **SLA monitoring** - Track performance

**Real-World Examples**:
- Healthcare (HIPAA compliance logs)
- Financial services (KYC audit trails)
- Government (access control logs)
- Enterprise (SOC 2 compliance)

---

## Use Case 8: Emergency Override and Exceptions

### Scenario: Emergency Access with Verification

**Context**: Medical emergency requires immediate access despite credential issues.

```
OFFLINE (❌ Rigid):
┌───────────────────────────────────────┐
│ Credential expired → Access DENIED    │
│ No override mechanism                 │
│ Patient in danger                     │
│ Cannot help ❌                        │
└───────────────────────────────────────┘

ONLINE (✅ Flexible):
┌───────────────────────────────────────┐
│ Emergency Override Flow               │
│                                       │
│ 1. Credential check fails             │
│ 2. Doctor declares emergency          │
│ 3. System checks online:              │
│    - Is this really an emergency?     │
│    - Is doctor authorized for this?   │
│    - What's the risk level?           │
│ 4. Senior supervisor notified         │
│ 5. Emergency access granted           │
│ 6. All actions logged                 │
│ 7. Post-emergency review              │
└───────────────────────────────────────┘

WORKFLOW:
┌─────────────┐    ┌─────────────┐    ┌──────────────┐
│   Doctor    │    │   System    │    │  Supervisor  │
│  (Holder)   │    │  (Verifier) │    │   (Online)   │
└──────┬──────┘    └──────┬──────┘    └───────┬──────┘
       │                  │                    │
       │ Show credential  │                    │
       │─────────────────▶│                    │
       │                  │                    │
       │                  │ Credential expired │
       │                  │ ❌ DENY            │
       │                  │                    │
       │ EMERGENCY MODE   │                    │
       │─────────────────▶│                    │
       │                  │                    │
       │                  │ Alert supervisor   │
       │                  │───────────────────▶│
       │                  │                    │
       │                  │    Approve? ✓      │
       │                  │◀───────────────────│
       │                  │                    │
       │ TEMP ACCESS ✓    │                    │
       │ (2 hours)        │                    │
       │◀─────────────────│                    │
       │                  │                    │
       │ All actions      │                    │
       │ logged for review│                    │
       │─────────────────▶│                    │
```

**Benefits of Online**:
- ✅ **Life-saving flexibility** - Override in genuine emergencies
- ✅ **Accountability** - All overrides logged and reviewed
- ✅ **Risk management** - Real-time supervisor approval
- ✅ **Audit trail** - Prevent abuse of emergency access

**Real-World Examples**:
- Hospital ER access with expired credentials
- Fire department forced entry override
- Police emergency warrant approval
- Nuclear facility emergency shutdown access

---

## Comparison Matrix: Offline vs Online

| Feature | Offline Only | Online Only | Hybrid (Best) |
|---------|-------------|-------------|---------------|
| **Revocation checking** | ❌ Stale | ✅ Real-time | ✅ Real-time |
| **Works without network** | ✅ Yes | ❌ No | ✅ Yes (fallback) |
| **Issuer key rotation** | ❌ May miss | ✅ Current | ✅ Current |
| **Dynamic proof requests** | ❌ Static | ✅ Dynamic | ✅ Dynamic |
| **Multi-party coordination** | ❌ No | ✅ Yes | ✅ Yes |
| **Credential status updates** | ❌ Manual | ✅ Real-time | ✅ Real-time |
| **Cross-jurisdiction** | ❌ Limited | ✅ Yes | ✅ Yes |
| **Audit logging** | ⚠️ Local only | ✅ Centralized | ✅ Centralized |
| **Emergency override** | ❌ Rigid | ✅ Flexible | ✅ Flexible |
| **Privacy** | ✅ Maximum | ⚠️ Network calls | ✅ Choice |
| **Performance** | ✅ Instant | ⚠️ Network delay | ✅ Best available |
| **Setup complexity** | ✅ Simple | ⚠️ Complex | ⚠️ Moderate |

---

## Recommendations by Scenario Type

### Choose **Offline Only** when:
- ✅ Maximum privacy required
- ✅ Network unreliable/unavailable
- ✅ Low-risk verifications
- ✅ Simple use cases
- ✅ No regulatory logging needed

### Choose **Online Only** when:
- ✅ Real-time revocation critical
- ✅ High-security requirements
- ✅ Regulatory compliance needed
- ✅ Complex business logic required
- ✅ Network always available

### Choose **Hybrid** (RECOMMENDED) when:
- ✅ Want best of both worlds
- ✅ Need reliability + security
- ✅ Network availability varies
- ✅ Production deployment
- ✅ Enterprise use cases

---

## Implementation Priority

For **Askar Import + Trust Bundle Verifier integration**, implement in this order:

### Phase 1: Offline Foundation ✅
- Trust Bundle verification (offline crypto)
- Structural verification (fallback)
- Basic UI

### Phase 2: Online Enhancement 🚧  
- ACA-Py integration (current work)
- Real-time revocation checking
- Connectivity detection

### Phase 3: Advanced Online Features 📋
- Dynamic proof requests
- Cross-jurisdiction support
- Emergency overrides
- Audit logging

### Phase 4: Hybrid Intelligence 🎯
- Smart tier selection
- Predictive caching
- Risk-based verification
- Machine learning optimization

---

## Summary

**Online connectivity enables powerful features**:

1. **Real-time revocation** - Critical for security
2. **Fresh verification** - Maximum assurance
3. **Dynamic adaptation** - Context-aware verification
4. **Multi-party coordination** - Enterprise workflows
5. **Status monitoring** - Proactive management
6. **Global interoperability** - Cross-jurisdiction
7. **Compliance logging** - Regulatory requirements
8. **Emergency flexibility** - Life-safety overrides

**Hybrid architecture provides**:
- ✅ Offline reliability (trust bundles)
- ✅ Online power (ACA-Py + services)
- ✅ Automatic fallback (best available)
- ✅ User transparency (show tier used)

---

**Next Step**: Implement 3-tier verification system in Askar Import! 🚀
