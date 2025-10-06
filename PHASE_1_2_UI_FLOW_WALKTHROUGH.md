# Phase 1.2 UI Flow Walkthrough

## User Experience Flow

### Scenario: User Verifies a Credential with Trust Bundle

#### Step 1: User Opens a Credential
**Location:** Credentials Page
- User navigates to the Credentials tab
- User sees a list of stored credentials
- User taps on a credential to view details

**Current UI:** 
- Shows credential metadata (name, category, timestamp)
- Shows JSON content
- Shows tags
- Has a "Verify Credential" button

#### Step 2: User Clicks "Verify Credential"
**What Happens:**
1. Button shows loading state: "Verifying..."
2. Spinner appears on the button
3. Button is disabled during verification

**Behind the Scenes:**
- `_verifyCredential()` method is called
- State updates: `_isVerifying = true`, `_verificationResult = null`

#### Step 3: Enhanced Verification Service Runs
**Three-Tier Verification Process:**

##### Tier 1: Structural Verification (Always Runs First)
- **Fast Check** (~50-100ms)
- Validates JSON structure
- Checks required fields (@context, type, credentialSubject, issuer, proof)
- Validates dates (issuanceDate, expirationDate)
- Checks DID formats
- **Result:** Pass/Warning/Fail

If structural fails → Stop here, show FAILED tier

##### Tier 2: Trust Bundle Verification (BEST Tier)
- **Fast Check** (~100-200ms, all offline)
- Extract credential fields:
  - `issuer`: "did:example:123..."
  - `schema_id`: "GvLGiRogTfuRHj..."
  - `cred_def_id`: "CsQY9MGeD3CQP4yU..."

**Verification Steps:**
1. **Check Bundle Exists**
   ```
   Query: Get bundle record (ID = 1) from Isar
   If null → NO_BUNDLE tier (red badge)
   ```

2. **Check Trusted Issuer**
   ```
   Query: Parse bundle.content → trusted_issuers list
   Check: issuer in trusted_issuers?
   If not → FAILED tier: "Issuer is not trusted"
   ```

3. **Check Schema Exists**
   ```
   Query: isar.schemaRecs.getBySchemaId(schema_id)
   If null → FAILED tier: "Schema not found in trust bundle"
   ```

4. **Check Credential Definition Exists**
   ```
   Query: isar.credDefRecs.getByCredDefId(cred_def_id)
   If null → FAILED tier: "Credential definition not found"
   ```

5. **All Checks Pass**
   ```
   Result: BEST tier (green badge)
   Message: "Credential verified using Trust Bundle"
   Details: {issuer, schema_id, cred_def_id, bundle_version, network}
   ```

##### Tier 3: Online Ledger Verification (GOOD Tier) - Future
- **Slower** (~1-3 seconds, requires internet)
- Only attempted if Trust Bundle verification fails
- Contacts ACA-Py or ledger directly
- Cryptographically verifies signatures
- **Result:** GOOD tier (blue badge) if successful

##### Tier 4: Fallback (BASIC Tier)
- If both Trust Bundle and Online fail
- Only structural verification passed
- **Result:** BASIC tier (amber badge)
- Message: "Credential is structurally valid (basic verification only)"

#### Step 4: UI Updates with Results

**New UI Section Appears Below Verify Button:**

```
┌─────────────────────────────────────────────────────┐
│  ═══════════════════════════════════════════════   │
│         📋 VERIFICATION RESULTS                      │
│  ═══════════════════════════════════════════════   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                                                      │
│     ✅           BEST                                │
│                                                      │
│     Verified using offline Trust Bundle              │
│                                                      │
│  ───────────────────────────────────────────────    │
│                                                      │
│  Issuer: did:example:123abc...                       │
│  Schema: GvLGiRogTfuRHj...                          │
│  Credential Definition: CsQY9MGeD3CQP4yU...         │
│  Bundle Version: 1.0.0                              │
│  Network: sovrin:mainnet                             │
│                                                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  ═════════════════════════════════════════════      │
│         ✓ VERIFICATION DETAILS                      │
│  ═════════════════════════════════════════════      │
└─────────────────────────────────────────────────────┘

[Detailed verification checks expand below...]
```

## Technical Implementation Flow

### Code Execution Path

```
User taps "Verify Credential"
        ↓
_verifyCredential() in credentials_page.dart
        ↓
Extract credential value from widget.entry
        ↓
Call: enhancedService.verifyCredential(value)
        ↓
EnhancedVerificationService.verifyCredential()
        ├─→ Step 1: Parse credential (JSON → Map)
        ├─→ Step 2: CredentialVerifier.verify() [Structural]
        │           ├─→ Check @context
        │           ├─→ Check type
        │           ├─→ Check credentialSubject
        │           ├─→ Check issuer
        │           ├─→ Check proof
        │           ├─→ Check dates
        │           └─→ Check DIDs
        │
        ├─→ Step 3: If structural OK, try Trust Bundle
        │           ↓
        │   VerifierService.verifyCredential()
        │           ├─→ Extract issuer, schema_id, cred_def_id
        │           ├─→ Query: isar.bundleRecs.get(1)
        │           ├─→ Parse: bundle.content → trusted_issuers
        │           ├─→ Check: issuer in trusted_issuers
        │           ├─→ Query: isar.schemaRecs.getBySchemaId()
        │           ├─→ Query: isar.credDefRecs.getByCredDefId()
        │           └─→ Return: VerificationResult
        │                       {tier: BEST, success: true, details}
        │
        ├─→ Step 4: If Trust Bundle fails, try Online (future)
        │           [Not yet implemented, will fall to BASIC]
        │
        └─→ Step 5: Return EnhancedVerificationResult
                    {
                      structuralResult,
                      tier: "BEST",
                      tierDescription: "Verified using offline Trust Bundle",
                      success: true,
                      message: "Credential verified using Trust Bundle",
                      details: {issuer, schema_id, ...}
                    }
        ↓
Back to _verifyCredential()
        ↓
setState(() {
  _enhancedResult = result;
  _verificationResult = result.structuralResult;
  _isVerifying = false;
})
        ↓
UI Rebuilds
        ↓
_buildTierBadge() renders green BEST badge
        ↓
_buildVerificationResults() renders detailed checks
```

## UI Components Breakdown

### 1. Tier Badge Widget
**Purpose:** Show verification tier prominently

**Visual Design:**
- **BEST Tier (Green)**
  - Border: Green (#4CAF50)
  - Background: Light green (rgba)
  - Icon: ✅ verified
  - Text: "BEST" in large bold letters
  - Subtitle: "Verified using offline Trust Bundle"

- **GOOD Tier (Blue)**
  - Border: Blue (#2196F3)
  - Icon: ☁️ cloud_done
  - Text: "GOOD"
  - Subtitle: "Verified using online ledger"

- **BASIC Tier (Amber)**
  - Border: Amber (#FFC107)
  - Icon: ℹ️ info_outline
  - Text: "BASIC"
  - Subtitle: "Basic structural verification only"

- **FAILED Tier (Red)**
  - Border: Red (#F44336)
  - Icon: ⚠️ error_outline
  - Text: "FAILED"
  - Subtitle: Error message

**Details Section:**
- Shows verification context
- Displays issuer DID
- Shows schema ID
- Shows credential definition ID
- Shows bundle version and network

### 2. Verification Details Section
**Purpose:** Show granular verification checks

**Existing Widget:** `_buildVerificationResults()`
- Shows all structural checks
- Categorized by: Structure, Dates, Signature, DIDs
- Each check shows: ✅ Passed, ⚠️ Warning, ❌ Failed, ⏭️ Skipped
- Expandable sections for details

**Integration:**
- Tier badge appears ABOVE verification details
- Provides high-level verdict before diving into details
- Both sections work together to give complete picture

## User Scenarios

### Scenario A: Happy Path - BEST Tier

```
User Action: Verify credential
             ↓
Tier Check:  BEST ✅
             ├─ Bundle exists ✅
             ├─ Issuer trusted ✅
             ├─ Schema found ✅
             └─ Cred def found ✅
             ↓
UI Shows:    Green "BEST" badge
             "Verified using offline Trust Bundle"
             Details: issuer, schema, cred def, bundle info
             ↓
User Sees:   High confidence - credential is legitimate
             Can trust the credential content
             All verification passed offline (fast & private)
```

### Scenario B: No Bundle - NO_BUNDLE Tier

```
User Action: Verify credential
             ↓
Tier Check:  NO_BUNDLE ⚠️
             └─ Bundle query returns null
             ↓
UI Shows:    Red "NO_BUNDLE" badge
             "No trust bundle found in database"
             Suggestion: "Sync trust bundle in Settings"
             ↓
User Sees:   Cannot verify against trust bundle
             Needs to sync bundle first
             Clear action: Go to Trust Bundle Settings
```

### Scenario C: Untrusted Issuer - FAILED Tier

```
User Action: Verify credential
             ↓
Tier Check:  FAILED ❌
             ├─ Bundle exists ✅
             └─ Issuer NOT in trusted list ❌
             ↓
UI Shows:    Red "FAILED" badge
             "Issuer is not in the trusted issuers list"
             Details: shows the issuer DID
             ↓
User Sees:   Credential from unknown/untrusted source
             Should not trust this credential
             Issuer not recognized by trust bundle
```

### Scenario D: Missing Schema - FAILED Tier

```
User Action: Verify credential
             ↓
Tier Check:  FAILED ❌
             ├─ Bundle exists ✅
             ├─ Issuer trusted ✅
             └─ Schema NOT found ❌
             ↓
UI Shows:    Red "FAILED" badge
             "Schema not found in trust bundle"
             Details: shows the schema_id
             ↓
User Sees:   Credential uses unknown schema
             Schema might be new/custom
             Bundle may need updating
```

### Scenario E: Basic Structural Only - BASIC Tier

```
User Action: Verify credential
             ↓
Tier Check:  BASIC ⚠️
             ├─ Structural checks ✅
             ├─ Trust bundle unavailable or
             │   Issuer not in list or
             │   Schema/CredDef missing
             └─ Online verification unavailable
             ↓
UI Shows:    Amber "BASIC" badge
             "Basic structural verification only"
             Warning: Signatures not cryptographically verified
             ↓
User Sees:   Credential is well-formed
             But cannot verify authenticity
             Use with caution
```

## State Management

### Component State Variables

```dart
class _CredentialDetailDialogState extends State<CredentialDetailDialog> {
  VerificationResult? _verificationResult;      // Existing
  EnhancedVerificationResult? _enhancedResult; // NEW
  bool _isVerifying = false;                    // Existing
  final ScrollController _scrollController = ScrollController();
  
  // ...
}
```

### State Transitions

```
Initial State:
_verificationResult = null
_enhancedResult = null
_isVerifying = false
        ↓ User clicks Verify
        ↓
Verifying State:
_verificationResult = null
_enhancedResult = null
_isVerifying = true
        ↓ Verification completes
        ↓
Result State:
_verificationResult = VerificationResult{...}  // Structural
_enhancedResult = EnhancedVerificationResult{  // Enhanced
  tier: "BEST",
  success: true,
  structuralResult: _verificationResult,
  details: {...}
}
_isVerifying = false
```

## Animation & UX Polish

### Button States
```dart
// Before verification
[Verify Credential] ← enabled, primary color

// During verification
[⏳ Verifying...] ← disabled, spinner animating

// After verification
[Verify Credential] ← enabled again, can re-verify
```

### Results Appearance
```dart
// Results fade in after verification completes
AnimatedOpacity(
  opacity: _enhancedResult != null ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: _buildTierBadge(),
)

// Auto-scroll to results
Future.delayed(Duration(milliseconds: 300), () {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: Duration(milliseconds: 500),
    curve: Curves.easeOut,
  );
});
```

### Tier Badge Animation
- Badge slides in from top with bounce effect
- Border pulses once on first appearance
- Icon scales up slightly for emphasis

## Summary

**User Flow:**
1. Open credential → 2. Tap verify → 3. See tier badge → 4. Review details → 5. Understand trust level

**Technical Flow:**
1. Parse credential → 2. Structural checks → 3. Trust bundle lookup → 4. Return tier → 5. Render UI

**Key UX Principles:**
- **Immediate Feedback:** Loading states, spinner
- **Clear Hierarchy:** Tier badge first, then details
- **Color Coding:** Green=best, Blue=good, Amber=basic, Red=failed
- **Actionable:** If failed, show why and what to do
- **Fast:** Trust bundle checks complete in <200ms
- **Offline:** Works without internet (BEST tier)
