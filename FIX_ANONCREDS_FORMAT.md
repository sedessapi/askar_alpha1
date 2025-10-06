# Fix: AnonCreds Credential Format Support

## Issue Identified
The Verify Local page was only showing BASIC tier verification because:
1. AnonCreds credentials don't have an explicit `issuer` field
2. The issuer DID is embedded in the `schema_id` and `cred_def_id` fields

## Debug Output
```
📄 Credential keys: [cred_def_id, rev_reg, rev_reg_id, schema_id, signature, signature_correctness_proof, values, witness]
📝 Issuer: null  ❌
📝 Schema ID: 3WpwUcB7evEEZGTCeCYPvK:2:fig:1.0
📝 Cred Def ID: 3WpwUcB7evEEZGTCeCYPvK:3:CL:843:figCD
```

## Root Cause
The credential is in **AnonCreds format** (Hyperledger Indy/Aries standard), which uses:
- Schema ID format: `<issuer_did>:2:<schema_name>:<version>`
- Cred Def ID format: `<issuer_did>:3:CL:<schema_seq_no>:<tag>`

The issuer DID (`3WpwUcB7evEEZGTCeCYPvK`) is the first component of both IDs.

## Solution Applied

### File: `packages/trust_bundle_core/lib/src/services/verifier_service.dart`

#### Change 1: Extract Issuer from Schema ID or Cred Def ID

**Before:**
```dart
final issuer = credential['issuer'] as String?;
final schemaId = credential['schema_id'] as String?;
final credDefId = credential['cred_def_id'] as String?;
```

**After:**
```dart
String? issuer = credential['issuer'] as String?;
final schemaId = credential['schema_id'] as String?;
final credDefId = credential['cred_def_id'] as String?;

// For AnonCreds format, extract issuer from schema_id or cred_def_id
if (issuer == null && schemaId != null) {
  final parts = schemaId.split(':');
  if (parts.length >= 2) {
    issuer = parts[0];
    print('📝 Extracted issuer from schema_id: $issuer');
  }
}

if (issuer == null && credDefId != null) {
  final parts = credDefId.split(':');
  if (parts.length >= 2) {
    issuer = parts[0];
    print('📝 Extracted issuer from cred_def_id: $issuer');
  }
}
```

#### Change 2: Handle Trust Bundle Issuer Formats

The trust bundle might store issuers as:
- Plain DID strings: `"3WpwUcB7evEEZGTCeCYPvK"`
- Objects with DID field: `{"did": "3WpwUcB7evEEZGTCeCYPvK", ...}`

**Before:**
```dart
final trustedIssuers = (bundleContent['trusted_issuers'] as List?)
    ?.map((e) => e.toString())
    .toList() ?? [];
```

**After:**
```dart
final trustedIssuersRaw = bundleContent['trusted_issuers'] as List?;
final List<String> trustedIssuers = [];

if (trustedIssuersRaw != null) {
  for (var entry in trustedIssuersRaw) {
    if (entry is String) {
      trustedIssuers.add(entry);
    } else if (entry is Map) {
      final did = entry['did'] as String?;
      if (did != null) {
        trustedIssuers.add(did);
      }
    }
  }
}
```

## How It Works Now

### Step 1: Extract Issuer
```dart
schema_id = "3WpwUcB7evEEZGTCeCYPvK:2:fig:1.0"
                     ↓ split(':')[0]
issuer = "3WpwUcB7evEEZGTCeCYPvK"
```

### Step 2: Parse Trusted Issuers
```json
{
  "trusted_issuers": [
    {"did": "3WpwUcB7evEEZGTCeCYPvK", "schema_ids": [...], "cred_def_ids": [...]},
    {"did": "AnotherIssuerDID", ...}
  ]
}
```
Extracts: `["3WpwUcB7evEEZGTCeCYPvK", "AnotherIssuerDID"]`

### Step 3: Check if Issuer is Trusted
```dart
trustedIssuers.contains("3WpwUcB7evEEZGTCeCYPvK") // ✅ true
```

### Step 4: Verify Schema and Cred Def
- Look up schema by `schema_id`
- Look up cred def by `cred_def_id`

### Step 5: Return BEST Tier
```dart
VerificationResult(
  success: true,
  tier: VerificationTier.best,  // 🟢 GREEN BADGE
  message: 'Credential verified using Trust Bundle',
)
```

## Expected Output After Fix

```
I/flutter: 🔍 Attempting Trust Bundle verification...
I/flutter: 📄 Credential keys: [cred_def_id, schema_id, ...]
I/flutter: 📝 Issuer: null
I/flutter: 📝 Schema ID: 3WpwUcB7evEEZGTCeCYPvK:2:fig:1.0
I/flutter: 📝 Cred Def ID: 3WpwUcB7evEEZGTCeCYPvK:3:CL:843:figCD
I/flutter: 🔎 VerifierService: Starting credential verification
I/flutter: 📝 Extracted issuer from schema_id: 3WpwUcB7evEEZGTCeCYPvK  ✅
I/flutter: 🔑 Extracted values:
I/flutter:    Issuer: 3WpwUcB7evEEZGTCeCYPvK  ✅
I/flutter:    Schema ID: 3WpwUcB7evEEZGTCeCYPvK:2:fig:1.0
I/flutter:    Cred Def ID: 3WpwUcB7evEEZGTCeCYPvK:3:CL:843:figCD
I/flutter: 📦 Looking up bundle with ID 1...
I/flutter: ✅ Bundle found
I/flutter: 👥 Checking trusted issuers...
I/flutter: 📝 Trusted issuers count: X
I/flutter: ✅ Issuer is trusted
I/flutter: 📋 Looking up schema: 3WpwUcB7evEEZGTCeCYPvK:2:fig:1.0
I/flutter: ✅ Schema found
I/flutter: 🔑 Looking up cred def: 3WpwUcB7evEEZGTCeCYPvK:3:CL:843:figCD
I/flutter: ✅ Cred def found
I/flutter: 🎉 All checks passed - BEST tier verification!
```

## Supported Credential Formats

After this fix, the VerifierService supports:

### 1. W3C Verifiable Credentials
```json
{
  "issuer": "did:sov:...",
  "schema_id": "...",
  "cred_def_id": "..."
}
```

### 2. AnonCreds (Hyperledger Indy/Aries)
```json
{
  "schema_id": "<issuer>:2:<name>:<version>",
  "cred_def_id": "<issuer>:3:CL:<seq>:<tag>"
}
```

### 3. Mixed Formats
Any credential with at least `schema_id` or `cred_def_id` containing the issuer DID.

## Testing

1. Run the app: `flutter run`
2. Navigate to Verify Local
3. Open wallet and tap Verify on a credential
4. Should now see **BEST** tier (green badge) ✅

## Files Modified

- ✅ `packages/trust_bundle_core/lib/src/services/verifier_service.dart`
  - Added issuer extraction from schema_id/cred_def_id
  - Enhanced trusted issuer parsing to handle objects
  - Added debug logging for troubleshooting

## Backward Compatibility

✅ Still supports W3C VC format with explicit `issuer` field
✅ Now also supports AnonCreds format without `issuer` field
✅ Handles trust bundle with issuers as strings or objects
