use aries_askar::{Store, StoreKeyMethod};
use std::ffi::{c_char, CString, CStr};
use std::path::Path;
use std::collections::HashMap;
use tokio::runtime::Builder;
use serde_json::{json, Value};

/// Provisions a new Askar wallet (called a "Store").
///
/// # Arguments
/// * `db_path_ptr` - A C string pointer to the database path (e.g., "/path/to/my_wallet.db").
/// * `raw_key_ptr` - A C string pointer to the raw key for encrypting the wallet.
///
/// # Returns
/// A C string pointer containing a JSON object:
/// - `{"success": true}` on success.
/// - `{"success": false, "error": "message"}` on failure.
#[no_mangle]
pub extern "C" fn provision_wallet(db_path_ptr: *const c_char, raw_key_ptr: *const c_char) -> *mut c_char {
    let runtime = Builder::new_current_thread().enable_all().build().unwrap();

    let result_json = runtime.block_on(async {
        let db_path_cstr = unsafe { CStr::from_ptr(db_path_ptr) };
        let db_path = match db_path_cstr.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid db_path: {}", e)}).to_string(),
        };

        let key_cstr = unsafe { CStr::from_ptr(raw_key_ptr) };
        let raw_key = match key_cstr.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid raw_key: {}", e)}).to_string(),
        };

        let spec_uri = format!("sqlite://{}", db_path);

        // Remove existing DB file if it exists
        if Path::new(db_path).exists() {
            let _ = std::fs::remove_file(db_path);
        }

        match Store::provision(
            &spec_uri,
            StoreKeyMethod::RawKey,
            raw_key.into(),
            None,
            true,
        ).await {
            Ok(_) => json!({"success": true}).to_string(),
            Err(e) => json!({"success": false, "error": format!("Provisioning failed: {}", e)}).to_string(),
        }
    });

    CString::new(result_json).unwrap().into_raw()
}

/// Opens an existing wallet and inserts a sample entry.
#[no_mangle]
pub extern "C" fn insert_entry(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char,
    entry_name_ptr: *const c_char,
    entry_value_ptr: *const c_char,
) -> *mut c_char {
    let runtime = Builder::new_current_thread().enable_all().build().unwrap();

    let result_json = runtime.block_on(async {
        let db_path = match unsafe { CStr::from_ptr(db_path_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid db_path: {}", e)}).to_string(),
        };

        let raw_key = match unsafe { CStr::from_ptr(raw_key_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid raw_key: {}", e)}).to_string(),
        };

        let entry_name = match unsafe { CStr::from_ptr(entry_name_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid entry_name: {}", e)}).to_string(),
        };

        let entry_value = match unsafe { CStr::from_ptr(entry_value_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid entry_value: {}", e)}).to_string(),
        };

        let spec_uri = format!("sqlite://{}", db_path);

        let store = match Store::open(&spec_uri, Some(StoreKeyMethod::RawKey), raw_key.into(), None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to open store: {}", e)}).to_string(),
        };

        let mut session = match store.session(None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to create session: {}", e)}).to_string(),
        };

        match session.insert("item", entry_name, entry_value.as_bytes(), None, None).await {
            Ok(_) => json!({"success": true}).to_string(),
            Err(e) => json!({"success": false, "error": format!("Failed to insert entry: {}", e)}).to_string(),
        }
    });

    CString::new(result_json).unwrap().into_raw()
}

/// Lists all entries in the wallet.
#[no_mangle]
pub extern "C" fn list_entries(db_path_ptr: *const c_char, raw_key_ptr: *const c_char) -> *mut c_char {
    let runtime = Builder::new_current_thread().enable_all().build().unwrap();

    let result_json = runtime.block_on(async {
        let db_path = match unsafe { CStr::from_ptr(db_path_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid db_path: {}", e)}).to_string(),
        };

        let raw_key = match unsafe { CStr::from_ptr(raw_key_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid raw_key: {}", e)}).to_string(),
        };

        let spec_uri = format!("sqlite://{}", db_path);

        let store = match Store::open(&spec_uri, Some(StoreKeyMethod::RawKey), raw_key.into(), None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to open store: {}", e)}).to_string(),
        };

        let mut session = match store.session(None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to create session: {}", e)}).to_string(),
        };

        let mut entries = Vec::new();
        // Fetch ALL entries regardless of category (None = all categories)
        match session.fetch_all(None, None, None, false).await {
            Ok(all_rows) => {
                for entry in all_rows {
                    let name = entry.name.to_string();
                    let category = entry.category.to_string();
                    let value = match String::from_utf8(entry.value.to_vec()) {
                        Ok(v) => v,
                        Err(_) => "<binary data>".to_string(),
                    };
                    
                    // Parse tags if available
                    let mut tags = Vec::new();
                    for tag in entry.tags {
                        tags.push(json!({
                            "name": tag.name(),
                            "value": tag.value()
                        }));
                    }
                    
                    entries.push(json!({
                        "name": name,
                        "category": category,
                        "value": value,
                        "tags": tags
                    }));
                }
                json!({"success": true, "entries": entries}).to_string()
            }
            Err(e) => json!({"success": false, "error": format!("Failed to fetch entries: {}", e)}).to_string(),
        }
    });

    CString::new(result_json).unwrap().into_raw()
}

/// Imports entries from an Askar export JSON into the wallet.
///
/// # Arguments
/// * `db_path_ptr` - A C string pointer to the database path.
/// * `raw_key_ptr` - A C string pointer to the raw key.
/// * `json_data_ptr` - A C string pointer to the export JSON data.
///
/// # Returns
/// A C string pointer containing:
/// - `{"success": true, "imported": count, "failed": count, "categories": {...}}` on success.
/// - `{"success": false, "error": "message"}` on failure.
///
/// Expected JSON structure:
/// ```json
/// {
///   "category1": [
///     {"name": "key1", "value": {...}, "tags": {"tag1": "val1"}},
///     ...
///   ],
///   "category2": [...]
/// }
/// ```
#[no_mangle]
pub extern "C" fn import_bulk_entries(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char,
    json_data_ptr: *const c_char,
) -> *mut c_char {
    let runtime = Builder::new_current_thread().enable_all().build().unwrap();

    let result_json = runtime.block_on(async {
        // Parse inputs
        let db_path = match unsafe { CStr::from_ptr(db_path_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid db_path: {}", e)}).to_string(),
        };

        let raw_key = match unsafe { CStr::from_ptr(raw_key_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid raw_key: {}", e)}).to_string(),
        };

        let json_data = match unsafe { CStr::from_ptr(json_data_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid json_data: {}", e)}).to_string(),
        };

        // Parse the export JSON
        let export_data: serde_json::Value = match serde_json::from_str(json_data) {
            Ok(v) => v,
            Err(e) => return json!({"success": false, "error": format!("Invalid JSON format: {}", e)}).to_string(),
        };

        let export_map = match export_data.as_object() {
            Some(m) => m,
            None => return json!({"success": false, "error": "JSON root must be an object"}).to_string(),
        };

        // Open the wallet
        let spec_uri = format!("sqlite://{}", db_path);
        let store = match Store::open(&spec_uri, Some(StoreKeyMethod::RawKey), raw_key.into(), None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to open store: {}", e)}).to_string(),
        };

        let mut session = match store.session(None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to create session: {}", e)}).to_string(),
        };

        let mut total_imported = 0;
        let mut total_failed = 0;
        let mut category_stats: HashMap<String, serde_json::Value> = HashMap::new();

        // Process each category
        for (category, items) in export_map {
            let items_array: Vec<Value> = match items.as_array() {
                Some(arr) => arr.clone(),
                None => {
                    // Single item, not an array
                    if let Some(_obj) = items.as_object() {
                        vec![items.clone()]
                    } else {
                        continue;
                    }
                }
            };

            let mut cat_imported = 0;
            let mut cat_failed = 0;

            for item in items_array {
                let item_obj = match item.as_object() {
                    Some(o) => o,
                    None => {
                        cat_failed += 1;
                        continue;
                    }
                };

                // Extract name, value, and tags
                let name = match item_obj.get("name").and_then(|v| v.as_str()) {
                    Some(n) => n,
                    None => {
                        cat_failed += 1;
                        continue;
                    }
                };

                let value_json = item_obj.get("value").unwrap_or(&serde_json::Value::Null);
                let value_bytes = serde_json::to_vec(value_json).unwrap_or_default();

                // Parse tags into HashMap<String, String>
                let mut tags: HashMap<String, String> = HashMap::new();
                if let Some(tags_obj) = item_obj.get("tags").and_then(|v| v.as_object()) {
                    for (k, v) in tags_obj {
                        if let Some(v_str) = v.as_str() {
                            tags.insert(k.clone(), v_str.to_string());
                        } else {
                            // Convert non-string values to strings
                            tags.insert(k.clone(), v.to_string());
                        }
                    }
                }

                // Convert tags to Option<Vec<aries_askar::entry::EntryTag>>
                let askar_tags = if tags.is_empty() {
                    None
                } else {
                    Some(
                        tags.iter()
                            .map(|(k, v)| aries_askar::entry::EntryTag::Encrypted(k.clone(), v.clone()))
                            .collect::<Vec<_>>()
                    )
                };

                // Insert into Askar
                match session.insert(
                    category,
                    name,
                    &value_bytes,
                    askar_tags.as_deref(),
                    None,
                ).await {
                    Ok(_) => {
                        cat_imported += 1;
                        total_imported += 1;
                    }
                    Err(e) => {
                        eprintln!("Failed to insert {}/{}: {}", category, name, e);
                        cat_failed += 1;
                        total_failed += 1;
                    }
                }
            }

            category_stats.insert(
                category.clone(),
                json!({
                    "imported": cat_imported,
                    "failed": cat_failed
                })
            );
        }

        json!({
            "success": true,
            "imported": total_imported,
            "failed": total_failed,
            "categories": category_stats
        }).to_string()
    });

    CString::new(result_json).unwrap().into_raw()
}

/// Lists all categories and their entry counts in the wallet.
#[no_mangle]
pub extern "C" fn list_categories(db_path_ptr: *const c_char, raw_key_ptr: *const c_char) -> *mut c_char {
    let runtime = Builder::new_current_thread().enable_all().build().unwrap();

    let result_json = runtime.block_on(async {
        let db_path = match unsafe { CStr::from_ptr(db_path_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid db_path: {}", e)}).to_string(),
        };

        let raw_key = match unsafe { CStr::from_ptr(raw_key_ptr) }.to_str() {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Invalid raw_key: {}", e)}).to_string(),
        };

        let spec_uri = format!("sqlite://{}", db_path);

        let store = match Store::open(&spec_uri, Some(StoreKeyMethod::RawKey), raw_key.into(), None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to open store: {}", e)}).to_string(),
        };

        let mut session = match store.session(None).await {
            Ok(s) => s,
            Err(e) => return json!({"success": false, "error": format!("Failed to create session: {}", e)}).to_string(),
        };

        // Fetch all entries without category filter to discover categories
        let mut category_counts: HashMap<String, i32> = HashMap::new();
        
        match session.fetch_all(None, None, None, false).await {
            Ok(all_rows) => {
                for entry in all_rows {
                    let category = entry.category.to_string();
                    *category_counts.entry(category).or_insert(0) += 1;
                }
                json!({
                    "success": true,
                    "categories": category_counts,
                    "total": category_counts.values().sum::<i32>()
                }).to_string()
            }
            Err(e) => json!({"success": false, "error": format!("Failed to fetch entries: {}", e)}).to_string(),
        }
    });

    CString::new(result_json).unwrap().into_raw()
}

/// Frees memory allocated by Rust for returned strings.
#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    if s.is_null() { return; }
    unsafe {
        let _ = CString::from_raw(s);
    }
}
