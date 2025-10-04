# Frequently Asked Questions (FAQ)

Quick answers to common questions about Askar Import.

---

## General Questions

### What is Askar Import?

A Flutter application for downloading, importing, verifying, and managing Aries Askar wallet data. It helps migrate wallets between systems and provides tools for credential verification.

### What platforms are supported?

- ✅ iOS (iPhone/iPad)
- ✅ Android (Phone/Tablet)
- ✅ macOS (Desktop)
- ✅ Windows (Desktop)
- ✅ Linux (Desktop)
- ✅ Web (Browser)

### Is this production-ready?

This is a demonstration/development tool. For production use:
- Implement proper key management (platform keychain)
- Add authentication if needed
- Enhance error handling and logging
- Add comprehensive testing
- Consider security audits

---

## Usage Questions

### Why does my downloaded JSON have more than just credentials?

Aries Askar wallets are **complete identity ecosystems** containing:
- 🎫 Credentials (your verifiable credentials)
- 📋 Schemas (data structure definitions)
- 📜 Credential Definitions (issuer metadata)
- 🤝 Connections (relationships with other agents)
- 🔐 DIDs (your digital identities)
- 🔑 Keys (cryptographic keys)
- 🚫 Revocation data (validity checks)

All are needed for credentials to remain verifiable and functional. See **USER_GUIDE.md** → "Understanding Wallet Data" for details.

### How do I generate a wallet encryption key?

**Secure method** (production):
```bash
# Generate random 32 bytes and encode as Base58
openssl rand 32 | base58
```

**Demo key** (testing only):
```
8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K
```

⚠️ **Never use demo keys in production!**

### Why does verification show "VALID WITH WARNINGS" for my AnonCreds credential?

This is **normal and expected**! AnonCreds use a different structure than W3C credentials:
- Missing `@context` → Expected (not W3C format)
- Missing `issuer` (uses `cred_def_id` instead) → Expected
- Has `values`, `schema_id`, `signature` → AnonCreds format

Warnings about missing W3C fields don't indicate problems with AnonCreds credentials.

### Can I import only credentials without other data?

Currently, no. The import process imports all categories to maintain wallet integrity. Future versions may add selective import.

**Workaround**: After import, you can use "View All" to see entries grouped by category and focus on credentials (sorted to top).

### Is verification cryptographically secure?

No. Verification is **structural validation only**:
- ✅ Checks required fields present
- ✅ Validates dates
- ✅ Checks signature structure
- ❌ Does NOT verify cryptographic signatures
- ❌ Does NOT check revocation status
- ❌ Does NOT resolve DIDs from ledger

This is an **offline tool** without network access to public key infrastructure.

### Why can't I see verification results?

Results now **auto-scroll into view** after verification. If still not visible:
1. Try scrolling down manually
2. Look for large verdict icon (✓/⚠/✗)
3. Check "VERIFICATION RESULTS" header
4. Try verifying again

### Where are downloaded files stored?

Platform-specific app documents directory:
- **iOS**: `Documents/` (visible in Files app)
- **Android**: `app-specific storage/Documents/`
- **macOS**: `~/Library/Containers/com.example.askar_import/Documents/`
- **Windows**: `%APPDATA%/askar_import/Documents/`
- **Linux**: `~/.local/share/askar_import/documents/`

Use "View All Files" to see file paths.

---

## Troubleshooting

### "Server health check failed"

**Possible causes:**
- Server URL incorrect or missing protocol (`http://` or `https://`)
- Server not running
- Network connectivity issues
- Firewall blocking connection

**Solutions:**
1. Verify URL format: `http://server.com:port`
2. Test server accessibility in browser
3. Try HTTP instead of HTTPS for local servers
4. Check firewall/proxy settings

### "Profile not found (404)"

**Causes:**
- Profile name misspelled (case-sensitive!)
- Profile doesn't exist on server

**Solutions:**
- Double-check spelling and case
- Contact server administrator
- Try different profile name

### "Failed to open store"

**Causes:**
- Wallet not created
- Wrong encryption key
- File permissions issue
- Corrupted wallet file

**Solutions:**
1. Create wallet first (Phase 2, Step 1)
2. Verify key is correct Base58-encoded 32 bytes
3. Check file exists at wallet path
4. Try creating new wallet

### "Some entries failed to import"

**Normal behavior** if:
- A few entries fail out of hundreds → Usually OK
- Non-standard data formats → Expected
- Check import statistics for details

**Concerning** if:
- Most entries fail → Check export format
- Specific category fails entirely → May be format issue

Review "Import Results" section for per-category breakdown.

### "No data to copy" when exporting JSON

**Causes:**
- Entry has null/empty value
- Entry not loaded correctly

**Solutions:**
- Try re-importing wallet
- Check if other entries work
- Verify wallet loaded successfully

### Build fails with "Failed to lookup symbol"

**Cause**: Rust native libraries not built or not found

**Solutions:**
```bash
cd rust_lib
./build_android.sh
cd ..
flutter clean
flutter pub get
flutter run
```

### NDK-related build errors

**Cause**: NDK path misconfigured or wrong version

**Solutions:**
1. Install NDK 29.0.13113456 specifically
2. Update `.cargo/config.toml` with correct NDK path
3. Update `rust_lib/build_android.sh` with NDK_HOME
4. See **DEVELOPER_GUIDE.md** → "Build Instructions"

---

## Feature Questions

### Can I export to formats other than JSON?

Currently only JSON. Future versions may add:
- YAML export
- XML export
- CSV for tabular data
- Custom formats

### Can I import from other wallet types?

Currently only supports Askar export format. Other formats would require:
- Format conversion tool
- Updated import logic
- Format-specific validation

### Will you add cryptographic verification?

Not planned for offline tool. Cryptographic verification requires:
- Network access to resolve DIDs
- Access to issuer public keys
- Revocation registry checking
- Complex PKI infrastructure

Consider this a **structural validation tool**, not a full verifier.

### Can I batch export multiple credentials?

Currently exports individual credentials. Future enhancements may include:
- Multi-select in "View All"
- Export all credentials at once
- Filter and export specific categories

### Does it work offline?

**Yes** for:
- ✅ Importing wallets
- ✅ Viewing entries
- ✅ Verifying credentials (structural)
- ✅ Exporting JSON

**No** for:
- ❌ Downloading exports (needs server)
- ❌ Health checks (needs server)

---

## Security Questions

### Is my wallet data secure?

**Encryption**: Wallets encrypted with AES-256 (via Aries Askar)

**Key Security**: Keys only in memory, never persisted (unless you save them)

**Network**: Downloads over HTTP/HTTPS (use HTTPS in production)

**Storage**: Files in app-private storage (platform sandboxed)

**Best practices**:
- Use strong random keys (32 bytes)
- Store keys in platform keychain (iOS Keychain, Android KeyStore)
- Use HTTPS for production servers
- Clear sensitive data from clipboard after use

### Should I commit wallet keys to git?

**Absolutely NOT!** Keys in code = security disaster

**Instead:**
- Generate keys at runtime
- Store in platform secure storage
- Use environment variables for development
- Never hardcode production keys

### Can others access my clipboard after export?

**Yes**, clipboard is not secure:
- Other apps can read clipboard
- Clipboard may sync to cloud (iCloud, etc.)

**Recommendations**:
- Clear clipboard after pasting: `Cmd+C` on empty text
- Don't leave credentials in clipboard
- Use secure channels for sharing

### What happens if I lose my wallet key?

**Wallet is permanently inaccessible.** Askar uses strong encryption - no backdoor or recovery.

**Prevention**:
- ✅ Store keys in password manager
- ✅ Keep encrypted backups
- ✅ Document key location
- ✅ Use key derivation from master password

---

## Performance Questions

### How long does import take?

Depends on wallet size:
- Small (< 100 entries): Seconds
- Medium (100-1000 entries): Tens of seconds
- Large (1000+ entries): Minutes

**Factors**:
- Device performance
- Storage speed
- Entry complexity
- Platform (native faster than web)

### Can I cancel import?

Not currently. Import runs to completion. Future versions may add cancellation.

**Workaround**: If import hangs, restart app and try again with smaller export.

### Why is the app slow on Web?

Web platform limitations:
- No native Rust libraries (uses WASM or pure Dart)
- Browser security restrictions
- Network-based storage may be slower

For best performance, use **native platforms** (iOS, Android, macOS, Windows, Linux).

---

## Advanced Questions

### Can I use this with other Indy/Aries wallets?

Depends on export format compatibility:
- ✅ Aries Askar exports (native support)
- ⚠️ Indy SDK exports (may work with format adjustments)
- ❌ Aries Framework JavaScript (different format)
- ❌ Other wallet types (conversion needed)

### How do I contribute?

1. Fork repository: [sedessapi/askar_import](https://github.com/sedessapi/askar_import)
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

See **DEVELOPER_GUIDE.md** → "Contributing"

### Where's the source code?

GitHub: [sedessapi/askar_import](https://github.com/sedessapi/askar_import)

### What's the license?

Check the `LICENSE` file in the repository.

---

## Getting More Help

### Documentation
- **USER_GUIDE.md** - Complete user guide
- **DEVELOPER_GUIDE.md** - Technical documentation
- **README.md** - Project overview

### Support
- **GitHub Issues**: [Report bugs or request features](https://github.com/sedessapi/askar_import/issues)
- **Discussions**: Ask questions in GitHub Discussions

### Resources
- [Aries Askar Docs](https://github.com/hyperledger/aries-askar)
- [Hyperledger Indy](https://www.hyperledger.org/use/hyperledger-indy)
- [W3C Verifiable Credentials](https://www.w3.org/TR/vc-data-model/)

---

**Have a question not answered here?**  
Open an issue on GitHub or check the other documentation files!

**Version**: 1.0.0  
**Last Updated**: October 4, 2025
