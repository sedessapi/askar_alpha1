# Rust Compatibility Fix

## Problem

The project encountered compilation errors when building with modern Rust toolchains (1.90.0+):

```
error[E0599]: no function or associated item named `generate` found for struct `Box<KeyT<...>>`
  --> aries-askar-0.3.1/src/kms/local_key.rs:41:50
   |
41 |  Box::<AnyKey>::generate(alg, BlsKeyGen::new(seed)?)?
   |                 ^^^^^^^^ function or associated item not found in `Box<KeyT<...>>`
```

### Root Cause

`aries-askar v0.3.1` from crates.io contains code that's incompatible with Rust 1.90+ due to changes in the `Box` API. The crate was calling `Box::generate()` which no longer exists in the standard library.

## Solution

Applied a Cargo patch to use `aries-askar v0.3.2` directly from the GitHub repository, which contains fixes for modern Rust compatibility.

### Changes Made

1. **Updated `/Cargo.toml`** (workspace root):
   ```toml
   [workspace]
   resolver = "2"
   members = [
       "rust_lib/ffi_bridge"
   ]

   [patch.crates-io]
   aries-askar = { git = "https://github.com/hyperledger/aries-askar", tag = "v0.3.2" }
   ```

2. **Fixed type error in `/rust_lib/ffi_bridge/src/lib.rs`**:
   - Changed `items_array` from reference to owned `Vec<Value>`
   - Added `Value` to imports from `serde_json`
   
   ```rust
   // Before
   use serde_json::json;
   let items_array = match items.as_array() {
       Some(arr) => arr,
       None => vec![items.clone()]
   };

   // After  
   use serde_json::{json, Value};
   let items_array: Vec<Value> = match items.as_array() {
       Some(arr) => arr.clone(),
       None => vec![items.clone()]
   };
   ```

3. **Updated documentation** in `BUILD_INSTRUCTIONS.md` to explain the patch.

## Verification

Build now succeeds with Rust 1.90.0:

```bash
cd rust_lib/ffi_bridge
cargo build --release --target aarch64-apple-darwin
# ✅ Finished `release` profile [optimized] target(s) in 3.01s
```

## Impact

- **Compatibility**: Now works with Rust 1.90.0+ (latest stable)
- **Dependencies**: Uses `aries-askar v0.3.2` from git instead of v0.3.1 from crates.io
- **Functionality**: No changes to API or behavior - purely a compatibility fix

## Notes for Future Maintenance

- If you encounter similar build errors, check if a newer version of `aries-askar` is available on crates.io
- The patch can be removed once `aries-askar v0.3.2` or newer is published to crates.io
- Monitor the [aries-askar releases](https://github.com/hyperledger/aries-askar/releases) for updates

## Testing

To test the fix on your system:

```bash
# 1. Clean previous builds
cd /Users/itzmi/dev/offline/tests/askar_import
rm -rf target Cargo.lock

# 2. Build for your platform
cd rust_lib/ffi_bridge
cargo build --release --target aarch64-apple-darwin  # macOS ARM
# or
cargo build --release --target x86_64-apple-darwin   # macOS Intel

# 3. For Android, use the build script:
./build_android.sh
```

## References

- [Aries Askar GitHub](https://github.com/hyperledger/aries-askar)
- [Aries Askar v0.3.2 Release](https://github.com/hyperledger/aries-askar/releases/tag/v0.3.2)
- [Rust Box API Changes](https://doc.rust-lang.org/std/boxed/struct.Box.html)
