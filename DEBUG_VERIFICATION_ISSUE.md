# Debug: Verify Local Only Shows BASIC Tier

## Issue
The Verify Local page only shows BASIC tier verification even though:
- There is a valid credential in the Askar wallet
- The trust bundle contains the same credential artifacts

## Root Cause Analysis

The issue is likely due to **credential field name mismatch** between:
1. How credentials are stored in the Askar wallet
2. What the VerifierService expects to extract

### Expected Credential Structure
The VerifierService expects these fields:
```dart
{
  "issuer": "did:sov:...",
  "schema_id": "schema_id_value",
  "cred_def_id": "cred_def_id_value",
  ...
}
```

### Possible Credential Structures in Wallet

#### AnonCreds Format (Hyperledger Aries)
```json
{
  "cred_def_id": "Th7MpTaRZVRYnPiabds81Y:3:CL:17:tag",
  "schema_id": "Th7MpTaRZVRYnPiabds81Y:2:BasicScheme:1.0",
  "issuer_id": "Th7MpTaRZVRYnPiabds81Y",  // ❌ NOT "issuer"
  ...
}
```

#### W3C VC Format
```json
{
  "issuer": "did:sov:Th7MpTaRZVRYnPiabds81Y",  // ✅ Correct field name
  "credentialSchema": {  // ❌ Different structure
    "id": "schema_id_value"
  },
  ...
}
```

## Debug Steps Added

I've added extensive debug logging to help identify the issue:

### 1. Enhanced Verification Service
Location: `lib/services/enhanced_verification_service.dart`

Logs:
- 🔍 Credential keys available
- 📝 Values extracted for issuer, schema_id, cred_def_id
- ✅ Bundle verification result
- ⚠️ Why verification didn't return BEST tier

### 2. Verifier Service
Location: `packages/trust_bundle_core/lib/src/services/verifier_service.dart`

Logs:
- 📄 Credential structure (all keys)
- 🔑 Extracted values (issuer, schema_id, cred_def_id)
- 📦 Bundle lookup result
- 👥 Trusted issuers list
- 📋 Schema lookup result
- 🔑 Credential definition lookup result
- 🎉 Success message if all checks pass

## How to Debug

### Step 1: Run the app with console visible
```bash
flutter run
```

### Step 2: Open Verify Local page
1. Navigate to "Verify Local" from home
2. Open your wallet
3. Tap "Verify" on a credential

### Step 3: Check console output
Look for these emoji markers:
- 🔍 = Starting verification
- 📄 = Credential structure
- 🔑 = Extracted values
- ✅ = Success
- ❌ = Failure
- ⚠️ = Warning

### Step 4: Identify the issue

#### If you see "Missing required fields"
The credential structure doesn't match. Check the credential keys output.

**Common Mismatches:**
- `issuer_id` instead of `issuer`
- `cred_def` instead of `cred_def_id`
- Nested structures instead of flat fields

**Solution:** Update VerifierService to handle different formats

#### If you see "Issuer is not in the trusted issuers list"
The issuer DID doesn't match exactly.

**Common Issues:**
- Different DID format (did:sov vs did:key)
- Extra/missing prefixes
- Case sensitivity

**Solution:** Check the exact issuer format in both places

#### If you see "Schema not found"
The schema_id format doesn't match database entries.

**Solution:** Check schema_id format in both credential and trust bundle

#### If you see "Cred def not found"
The cred_def_id format doesn't match database entries.

**Solution:** Check cred_def_id format in both credential and trust bundle

## Likely Solutions

### Solution 1: Handle Multiple Credential Formats

Update `VerifierService.verifyCredential()` to try multiple field names:

```dart
// Try multiple field names for issuer
final issuer = credential['issuer'] as String? ??
    credential['issuer_id'] as String? ??
    credential['issuerId'] as String?;

// Try multiple field names for schema_id
final schemaId = credential['schema_id'] as String? ??
    credential['schemaId'] as String? ??
    (credential['credentialSchema'] as Map?)?['id'] as String?;

// Try multiple field names for cred_def_id
final credDefId = credential['cred_def_id'] as String? ??
    credential['cred_def'] as String? ??
    credential['credDefId'] as String?;
```

### Solution 2: Normalize Issuer DID Format

Ensure issuer DIDs are compared in the same format:

```dart
// Normalize DID format (remove did:sov: prefix if present)
String normalizeDid(String did) {
  return did.replaceFirst(RegExp(r'^did:[^:]+:'), '');
}

// Compare normalized DIDs
final normalizedIssuer = normalizeDid(issuer);
final normalizedTrustedIssuers = trustedIssuers.map(normalizeDid).toList();

if (!normalizedTrustedIssuers.contains(normalizedIssuer)) {
  // Not trusted
}
```

### Solution 3: Add Credential Format Detection

```dart
enum CredentialFormat {
  anoncreds,
  w3cVc,
  unknown,
}

CredentialFormat detectFormat(Map<String, dynamic> credential) {
  if (credential.containsKey('issuer_id') && credential.containsKey('cred_def_id')) {
    return CredentialFormat.anoncreds;
  }
  if (credential.containsKey('issuer') && credential.containsKey('credentialSubject')) {
    return CredentialFormat.w3cVc;
  }
  return CredentialFormat.unknown;
}
```

## Quick Test

After running the app and verifying a credential, paste the console output here to determine the exact issue.

Look for these specific lines:
```
📄 Credential structure: [list of keys]
🔑 Extracted values:
   Issuer: <value or null>
   Schema ID: <value or null>
   Cred Def ID: <value or null>
```

## Expected Outcome

Once the field names match correctly, you should see:
```
🔎 VerifierService: Starting credential verification
📄 Credential structure: [issuer, schema_id, cred_def_id, ...]
🔑 Extracted values:
   Issuer: did:sov:...
   Schema ID: ...
   Cred Def ID: ...
📦 Looking up bundle with ID 1...
✅ Bundle found: ...
👥 Checking trusted issuers...
📝 Trusted issuers count: X
✅ Issuer is trusted
📋 Looking up schema: ...
✅ Schema found: ...
🔑 Looking up cred def: ...
✅ Cred def found
🎉 All checks passed - BEST tier verification!
```

## Files Modified

- `lib/services/enhanced_verification_service.dart` - Added debug logging
- `packages/trust_bundle_core/lib/src/services/verifier_service.dart` - Added debug logging

## Next Steps

1. Run the app and verify a credential
2. Copy the console output
3. Identify which check is failing
4. Apply the appropriate solution above
5. Test again

Once we identify the exact issue from the console output, I can provide a precise fix!
