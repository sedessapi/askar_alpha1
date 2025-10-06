#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Provisions a new Askar wallet (called a "Store").
 *
 * # Arguments
 * * `db_path_ptr` - A C string pointer to the database path (e.g., "/path/to/my_wallet.db").
 * * `raw_key_ptr` - A C string pointer to the raw key for encrypting the wallet.
 *
 * # Returns
 * A C string pointer containing a JSON object:
 * - `{"success": true}` on success.
 * - `{"success": false, "error": "message"}` on failure.
 */
char *provision_wallet(const char *db_path_ptr, const char *raw_key_ptr);

/**
 * Opens an existing wallet and inserts a sample entry.
 */
char *insert_entry(const char *db_path_ptr,
                   const char *raw_key_ptr,
                   const char *entry_name_ptr,
                   const char *entry_value_ptr);

/**
 * Lists all entries in the wallet.
 */
char *list_entries(const char *db_path_ptr, const char *raw_key_ptr);

/**
 * Imports entries from an Askar export JSON into the wallet.
 *
 * # Arguments
 * * `db_path_ptr` - A C string pointer to the database path.
 * * `raw_key_ptr` - A C string pointer to the raw key.
 * * `json_data_ptr` - A C string pointer to the export JSON data.
 *
 * # Returns
 * A C string pointer containing:
 * - `{"success": true, "imported": count, "failed": count, "categories": {...}}` on success.
 * - `{"success": false, "error": "message"}` on failure.
 *
 * Expected JSON structure:
 * ```json
 * {
 *   "category1": [
 *     {"name": "key1", "value": {...}, "tags": {"tag1": "val1"}},
 *     ...
 *   ],
 *   "category2": [...]
 * }
 * ```
 */
char *import_bulk_entries(const char *db_path_ptr,
                          const char *raw_key_ptr,
                          const char *json_data_ptr);

/**
 * Lists all categories and their entry counts in the wallet.
 */
char *list_categories(const char *db_path_ptr, const char *raw_key_ptr);

/**
 * Frees memory allocated by Rust for returned strings.
 */
void free_string(char *s);
