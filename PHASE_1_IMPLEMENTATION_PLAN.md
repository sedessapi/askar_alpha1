# Phase 1 Implementation Plan: Trust Bundle Integration

This document breaks down the implementation of Phase 1 into two manageable, incremental sub-phases.

## Phase 1.1: Bundle Ingestion, Storage, and Viewing

**Goal**: To successfully download the trust bundle, process it, store it in a local Isar database, and create a UI to view the status and contents of that database. At the end of this sub-phase, we will have tangible proof that we can handle the trust bundle data, even before we use it for verification.

**Key Tasks**:

1.  **Create the `trust_bundle_core` Package**: Set up the new Dart package that will house all the new logic.
2.  **Define Isar Schemas**: Create the data models (`SchemaRec`, `CredDefRec`, etc.) that will define the structure of our new Isar database.
3.  **Implement the Bundle Client**: Write the networking code to download the `bundle.json` from the `http://mary9.com:9090/bundle` endpoint.
4.  **Build the Ingestion Service**: Create the logic that parses the downloaded JSON and populates the Isar database with the schemas, credential definitions, and other artifacts. This service would also verify the manifest's signature to ensure the bundle is authentic.
5.  **Develop the UI for Viewing**: Create the "Trust Bundle Settings" page where a user can:
    *   Trigger the sync process manually.
    *   See the "Last Synced" timestamp.
    *   View the counts of cached artifacts (e.g., "Schemas: 1,523", "Credential Definitions: 2,840").

**Deliverable**: A settings screen where you can press "Sync", watch it download and process, and see the artifact counts appear.

---

## Phase 1.2: Implementing and Integrating the Verification Logic

**Goal**: With the trust bundle data now locally cached in Isar, the next step is to use that data to perform a full cryptographic verification of a credential and display the result in the UI.

**Key Tasks**:

1.  **Implement the Verifier**: Build the core `verifyCredential` function within the `trust_bundle_core` package. This function will:
    *   Take a credential as input.
    *   Perform fast, indexed lookups against the Isar database to find the required schema and credential definition.
    *   Check if the credential's issuer is in the trusted list.
    *   Return a detailed `VerificationResult`.
2.  **Create the `EnhancedVerificationService`**: In the main `askar_alpha1` app, create this new service to orchestrate the 3-tier logic. Initially, it will just call our new `trust_bundle_core` verifier.
3.  **Integrate with the UI**:
    *   Update the "Verify" button's action to use the new `EnhancedVerificationService`.
    *   Implement the new UI components to display the **"BEST / Trust Bundle" tier** result, with the green color, icon, and descriptive text.

**Deliverable**: The app can now verify a credential using the offline trust bundle and correctly displays the "BEST" verification tier in the UI.
