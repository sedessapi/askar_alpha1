# Quick Reference: Holder vs Verifier

## One-Line Answer

**Yes, you are 100% correct:**
- ✅ **Askar Import** = Holder app (deployed on user's personal device)
- ✅ **Trust Bundle Verifier** = Verifier app (deployed on verifier's separate device or cloud)

---

## The Simple Picture

```
HOLDER'S PHONE              VERIFIER'S DEVICE/CLOUD
┌─────────────┐            ┌──────────────────┐
│   Askar     │            │  Trust Bundle    │
│   Import    │  Shows ──▶ │  Verifier        │
│             │  credential│                  │
│ "I have ID" │            │ "Let me check    │
│             │            │  if it's valid"  │
└─────────────┘            └──────────────────┘
```

---

## Real-World Examples

### Example 1: Airport
- **Holder**: Traveler's phone with Askar Import (has digital passport)
- **Verifier**: Immigration officer's tablet with Trust Bundle Verifier
- **Process**: Scan QR code → Verify → Allow entry

### Example 2: Office Building  
- **Holder**: Employee's phone with Askar Import (has employee credential)
- **Verifier**: Security kiosk with Trust Bundle Verifier
- **Process**: Tap NFC → Verify → Unlock door

### Example 3: Online Banking
- **Holder**: Customer's phone with Askar Import (has identity credential)
- **Verifier**: Bank's cloud server with Trust Bundle Verifier API
- **Process**: Send proof via API → Verify → Open account

---

## Integration Goal

**Share the verification engine** so Askar Import (holder) can:
1. Self-verify credentials before presenting (avoid embarrassment)
2. Use same crypto as Trust Bundle Verifier (consistency)
3. Fall back to ACA-Py or structural when trust bundle unavailable

---

## Documents Created

1. **DEPLOYMENT_ARCHITECTURE.md** - Full deployment guide with diagrams
2. **TRUST_BUNDLE_INTEGRATION.md** - Technical integration plan
3. **This file** - Quick reference

---

**Next Step**: Share Trust Bundle Verifier code so we can extract the core! 🚀
