```markdown
# Manual API Test Cases

**Base URL:** `http://localhost:3009` (or as deployed)

---
## Authentication

**Test Case:** User Registration (Pengunjung)
*   **Purpose:** Verify new pengunjung registration.
*   **Endpoint:** `POST /api/auth/register`
*   **User Role/Authentication:** None
*   **Request Body:**
    ```json
    {
      "nama": "Test Pengunjung",
      "email": "pengunjung@example.com",
      "password": "password123",
      "telepon": "081234567890",
      "role": "pengunjung"
    }
    ```
*   **Expected Outcome:** Status 201 Created, returns user data (excluding password) and a JWT token. Save the token as `{{PENGUNJUNG_TOKEN}}` and user ID as `{{PENGUNJUNG_ID}}`.

---
**Test Case:** User Registration (Pengelola - for testing purposes, can be created by Admin too)
*   **Purpose:** Verify new pengelola registration.
*   **Endpoint:** `POST /api/auth/register`
*   **User Role/Authentication:** None (or Admin Token if restricted)
*   **Request Body:**
    ```json
    {
      "nama": "Test Pengelola",
      "email": "pengelola@example.com",
      "password": "password123",
      "telepon": "081234567891",
      "role": "pengelola"
    }
    ```
*   **Expected Outcome:** Status 201 Created, returns user data and token. Save token as `{{PENGELOLA_TOKEN}}` and user ID as `{{PENGELOLA_ID}}`.

---
**Test Case:** User Login (Pengunjung)
*   **Purpose:** Verify pengunjung login.
*   **Endpoint:** `POST /api/auth/login`
*   **User Role/Authentication:** None
*   **Request Body:**
    ```json
    {
      "email": "pengunjung@example.com",
      "password": "password123"
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns user data and a new JWT token. Update `{{PENGUNJUNG_TOKEN}}`.

---
**Test Case:** User Login (Pengelola)
*   **Purpose:** Verify pengelola login.
*   **Endpoint:** `POST /api/auth/login`
*   **User Role/Authentication:** None
*   **Request Body:**
    ```json
    {
      "email": "pengelola@example.com",
      "password": "password123"
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns user data and a new JWT token. Update `{{PENGELOLA_TOKEN}}`.

---
**Test Case:** User Login (Admin - assuming admin exists or created via seed/direct DB insert)
*   **Purpose:** Verify admin login.
*   **Endpoint:** `POST /api/auth/login`
*   **User Role/Authentication:** None
*   **Request Body:**
    ```json
    {
      "email": "admin@example.com", // Replace with actual admin email
      "password": "adminpassword"   // Replace with actual admin password
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns user data and a new JWT token. Save token as `{{ADMIN_TOKEN}}`.

---
## Wisata Management

**Test Case:** Create Wisata (as Admin)
*   **Purpose:** Verify Admin can create a new Wisata.
*   **Endpoint:** `POST /api/wisata`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Pantai Indah Test",
      "deskripsi": "Sebuah pantai yang sangat indah dengan pasir putih dan air jernih.",
      "lokasi": {
        "alamat": "Jl. Pantai Indah No. 1",
        "kota": "Testville",
        "provinsi": "Testnesia",
        "koordinat": {
          "latitude": -6.12345,
          "longitude": 106.12345
        }
      },
      "ticketTypes": [{ "name": "Umum", "price": 50000 }],  // Updated to new ticketTypes format
      "jamOperasional": {
        "seninJumat": "08:00 - 17:00",
        "sabtuMinggu": "07:00 - 18:00",
        "catatan": "Tutup pada hari libur nasional tertentu."
      },
      "kategori": ["Pantai", "Alam"],
      "pengelolaId": "{{PENGELOLA_ID}}" // Optional: assign to a pengelola
    }
    ```
*   **Expected Outcome:** Status 201 Created, returns the created Wisata data. Save the ID as `{{WISATA_ID_1}}`.

---
**Test Case:** Create Wisata (as Pengelola)
*   **Purpose:** Verify Pengelola can create a new Wisata.
*   **Endpoint:** `POST /api/wisata`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Gunung Tinggi Test",
      "deskripsi": "Gunung dengan pemandangan spektakuler.",
      "lokasi": {
        "alamat": "Jl. Gunung Tinggi No. 1",
        "kota": "MountainView",
        "provinsi": "Testnesia",
        "koordinat": {
          "latitude": -7.12345,
          "longitude": 107.12345
        }
      },
      "ticketTypes": [{ "name": "Pendaki", "price": 75000 }], // Updated to new ticketTypes format
      "jamOperasional": {
        "seninJumat": "06:00 - 16:00",
        "sabtuMinggu": "05:00 - 17:00"
      },
      "kategori": ["Gunung", "Alam", "Hiking"]
      // pengelolaId will be auto-assigned to {{PENGELOLA_ID}} by the backend if not admin
    }
    ```
*   **Expected Outcome:** Status 201 Created, returns the created Wisata data. Save the ID as `{{WISATA_ID_2}}`.

---
**Test Case:** Get All Wisata (Public)
*   **Purpose:** Verify anyone can fetch all Wisata.
*   **Endpoint:** `GET /api/wisata`
*   **User Role/Authentication:** None (or any token)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK, returns an array of Wisata (likely those 'published').

---
**Test Case:** Get Wisata by ID (Public)
*   **Purpose:** Verify anyone can fetch a specific Wisata by its ID.
*   **Endpoint:** `GET /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** None (or any token)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK, returns the details of Wisata with ID `{{WISATA_ID_1}}`.

---
**Test Case:** Update Wisata (by Admin who created it or any Admin)
*   **Purpose:** Verify Admin can update Wisata details, including ticket types.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Pantai Indah Test Updated by Admin",
      "ticketTypes": [
        { "name": "Umum (Weekdays)", "price": 55000 },
        { "name": "Umum (Weekend)", "price": 65000 }
      ]
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns the updated Wisata data.

---
**Test Case:** Update Wisata (by Pengelola who manages it)
*   **Purpose:** Verify Pengelola can update their own Wisata details, including ticket types.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_2}}`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Gunung Tinggi Test Updated by Pengelola",
      "jamOperasional": {
        "seninJumat": "06:00 - 16:30",
        "sabtuMinggu": "05:00 - 17:30"
      },
      "ticketTypes": [
        { "name": "Pendaki (Reguler)", "price": 80000 },
        { "name": "Pendaki (Grup > 5 org)", "price": 70000 }
      ]
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns the updated Wisata data.

---
**Test Case:** Add Gambar Galeri (by Admin)
*   **Purpose:** Verify Admin can add an image to Wisata gallery.
*   **Endpoint:** `POST /api/wisata/{{WISATA_ID_1}}/gallery`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** Form-data with a field `gambar` containing an image file.
*   **Expected Outcome:** Status 200 OK or 201 Created, returns updated Wisata data with new gallery image URL. Save `gambarId` from response.

---
**Test Case:** Verifikasi Gambar Galeri (by Admin)
*   **Purpose:** Verify Admin can verify a gallery image.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_1}}/gallery/{{GAMBAR_ID_TO_VERIFY}}/verify`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** `{"status": "verified"}`
*   **Expected Outcome:** Status 200 OK, returns message and updated Wisata data.

---
## Ticket Purchasing Flow (as Pengunjung) - Updated for Flexible Tickets

**Test Case:** Create Ticket Transaction (Purchase with Flexible Ticket Types)
*   **Purpose:** Verify a 'pengunjung' can initiate a ticket purchase using flexible ticket types.
*   **Prerequisite:** Get `{{WISATA_ID_1}}` and find one of its `ticketTypes._id` (e.g., "Umum (Weekend)") and save as `{{TICKET_TYPE_ID_UMUM_WEEKEND}}`.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "itemsToPurchase": [
        { "ticketTypeId": "{{TICKET_TYPE_ID_UMUM_WEEKEND}}", "quantity": 2 }
      ]
    }
    ```
*   **Expected Outcome:** Status 201 Created. Returns `orderId`, `snapToken`, `ticketId`, `purchasedItems`, `totalPrice`. Save these as `{{ORDER_ID_1}}`, `{{SNAP_TOKEN_1}}`, and `{{TICKET_ID_1}}`. The ticket should be in 'pending' status.

---
**Test Case:** Create Ticket Transaction - Invalid Wisata ID (Flexible Tickets)
*   **Purpose:** Verify error handling for invalid Wisata ID with new ticket structure.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "INVALIDWISATAID",
      "itemsToPurchase": [ { "ticketTypeId": "{{TICKET_TYPE_ID_UMUM_WEEKEND}}", "quantity": 1 } ]
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request, with error message.

---
**Test Case:** Create Ticket Transaction - Wisata Not Found (Flexible Tickets)
*   **Purpose:** Verify error handling for non-existent Wisata ID with new ticket structure.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "605fe2e801ab3f001fde0000", // A valid ObjectId format but non-existent
      "itemsToPurchase": [ { "ticketTypeId": "{{TICKET_TYPE_ID_UMUM_WEEKEND}}", "quantity": 1 } ]
    }
    ```
*   **Expected Outcome:** Status 404 Not Found, with error message.

---
**Test Case:** Create Ticket Transaction - Invalid ticketTypeId
*   **Purpose:** Verify error for invalid ticketTypeId.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "itemsToPurchase": [ { "ticketTypeId": "INVALID_ID_FORMAT", "quantity": 1 } ]
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request, e.g., "Invalid ticketTypeId format...".

---
**Test Case:** Create Ticket Transaction - ticketTypeId Not Found in Wisata
*   **Purpose:** Verify error for ticketTypeId not belonging to the Wisata.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "itemsToPurchase": [ { "ticketTypeId": "605fe2e801ab3f001fde0001", "quantity": 1 } ] // Valid format, but likely not in WISATA_ID_1
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request, e.g., "Ticket type with ID ... not found...".

---
**Test Case:** Get User's Tickets (Flexible Tickets)
*   **Purpose:** Verify a 'pengunjung' can retrieve their list of tickets (check `purchasedItems`).
*   **Endpoint:** `GET /api/tickets/my-tickets`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns an array of tickets. The ticket `{{TICKET_ID_1}}` should be present with `paymentStatus: 'pending'` and correct `purchasedItems`.

---
## Midtrans Notification Simulation (largely unchanged, but verify gross_amount)

**Test Case:** Simulate Midtrans 'success' notification (Flexible Tickets)
*   **Purpose:** Verify successful payment notification with flexible tickets.
*   **Endpoint:** `POST /api/tickets/midtrans-notification`
*   **User Role/Authentication:** None
*   **Request Body:** (Ensure `order_id` is `{{ORDER_ID_1}}` and `gross_amount` matches the `totalPrice` from the purchase response)
    ```json
    {
      "transaction_time": "2024-03-15 10:00:00",
      "transaction_status": "capture",
      "transaction_id": "MIDTRANS-TRX-ID-SUCCESS-001",
      "status_message": "midtrans payment notification",
      "status_code": "200",
      "signature_key": "YOUR_CALCULATED_SIGNATURE_KEY_IF_VERIFYING",
      "settlement_time": "2024-03-15 10:05:00",
      "payment_type": "credit_card",
      "order_id": "{{ORDER_ID_1}}",
      "merchant_id": "YOUR_MIDTRANS_MERCHANT_ID_PLACEHOLDER",
      "gross_amount": "130000.00", // Example: 2x "Umum (Weekend)" @ 65000
      "fraud_status": "accept",
      "currency": "IDR"
    }
    ```
*   **Expected Outcome:** Status 200 OK. The ticket `{{TICKET_ID_1}}` should now have `paymentStatus: 'success'`.

---
## Sales Viewing (Updated for Flexible Tickets)

**Test Case:** Get Sales by Wisata (Admin, Flexible Tickets)
*   **Purpose:** Verify Admin can view sales data, check `totalTicketsSold` from `purchasedItems`.
*   **Endpoint:** `GET /api/tickets/sales/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Sales data includes `totalRevenue` and `totalTicketsSold` correctly calculated from `purchasedItems` of successful tickets.

---
## Admin User Management

**Test Case:** Admin - List All Users (Default Pagination)
*   **Purpose:** Verify Admin can list all users.
*   **Endpoint:** `GET /api/admin/users`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Response contains paginated list of users, totalPages, currentPage, totalUsers.

---
**Test Case:** Admin - List Users (with Pagination and Role Filter)
*   **Purpose:** Verify Admin can list 'pengunjung' users with specific pagination.
*   **Endpoint:** `GET /api/admin/users?page=1&limit=5&role=pengunjung`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Response contains paginated list of 'pengunjung' users (max 5), totalPages, currentPage, totalUsers. User `{{PENGUNJUNG_ID}}` should be in this list if created.

---
**Test Case:** Admin - Get User by ID
*   **Purpose:** Verify Admin can get details of a specific user.
*   **Endpoint:** `GET /api/admin/users/{{PENGUNJUNG_ID}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Response contains details for user `{{PENGUNJUNG_ID}}` (excluding password). Save another user's ID as `{{USER_ID_FOR_TESTING}}`.

---
**Test Case:** Admin - Update User Role (e.g., Pengunjung to Pengelola)
*   **Purpose:** Verify Admin can update a user's role.
*   **Endpoint:** `PUT /api/admin/users/{{USER_ID_FOR_TESTING}}/role`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "role": "pengelola"
    }
    ```
*   **Expected Outcome:** Status 200 OK. User `{{USER_ID_FOR_TESTING}}` now has role 'pengelola'. Verify with Get User by ID.

---
**Test Case:** Admin - Update User Role (Invalid Role)
*   **Purpose:** Verify error handling for invalid role update.
*   **Endpoint:** `PUT /api/admin/users/{{USER_ID_FOR_TESTING}}/role`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "role": "subscriber"
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request. Message indicates invalid role.

---
**Test Case:** Admin - Manage User Account Status (e.g., Ban User)
*   **Purpose:** Verify Admin can change a user's account status.
*   **Endpoint:** `PUT /api/admin/users/{{USER_ID_FOR_TESTING}}/status`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "statusAkun": "banned"
    }
    ```
*   **Expected Outcome:** Status 200 OK. User `{{USER_ID_FOR_TESTING}}` now has status 'banned'. Verify with Get User by ID. Banned user should not be able to login.

---
**Test Case:** Admin - Manage User Account Status (Activate User)
*   **Purpose:** Verify Admin can re-activate a user's account.
*   **Endpoint:** `PUT /api/admin/users/{{USER_ID_FOR_TESTING}}/status`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "statusAkun": "aktif"
    }
    ```
*   **Expected Outcome:** Status 200 OK. User `{{USER_ID_FOR_TESTING}}` now has status 'aktif'.

---
## Admin Assign/Change Pengelola for Wisata

**Test Case:** Admin - Create Wisata and Assign Specific Pengelola
*   **Purpose:** Verify Admin can create a Wisata and assign it to a specific Pengelola (`{{PENGELOLA_ID}}` created earlier).
*   **Endpoint:** `POST /api/wisata`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Wisata Danau Admin Assign",
      "deskripsi": "Danau yang dikelola oleh {{PENGELOLA_ID}}.",
      "lokasi": { "alamat": "Jl. Danau Admin", "koordinat": { "lat": -6.20, "lng": 106.80 } }, // Slightly different coords
      "ticketTypes": [{ "name": "Perahu", "price": 25000 }],
      "pengelolaId": "{{PENGELOLA_ID}}"
    }
    ```
*   **Expected Outcome:** Status 201 Created. Wisata data shows `pengelola` field matching `{{PENGELOLA_ID}}`. Save new Wisata ID as `{{WISATA_ID_ADMIN_ASSIGNED}}`. Pengelola `{{PENGELOLA_ID}}` should have this Wisata in their `tempatWisata` list.

---
**Test Case:** Admin - Change Pengelola of an Existing Wisata
*   **Purpose:** Verify Admin can change the Pengelola for an existing Wisata.
*   **Prerequisite:** Create a second 'pengelola' user, get their ID as `{{PENGELOLA_ID_2}}`.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_ADMIN_ASSIGNED}}/assign-pengelola`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "newPengelolaId": "{{PENGELOLA_ID_2}}"
    }
    ```
*   **Expected Outcome:** Status 200 OK. Wisata `{{WISATA_ID_ADMIN_ASSIGNED}}` now has `pengelola` as `{{PENGELOLA_ID_2}}`. Old pengelola `{{PENGELOLA_ID}}` should no longer have this Wisata in `tempatWisata`. New pengelola `{{PENGELOLA_ID_2}}` should now have it.

---
**Test Case:** Admin - Change Pengelola to a Non-Pengelola User
*   **Purpose:** Verify error when assigning Wisata to a user who is not a 'pengelola'. Use `{{PENGUNJUNG_ID}}`.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_ADMIN_ASSIGNED}}/assign-pengelola`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "newPengelolaId": "{{PENGUNJUNG_ID}}"
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request. Message indicates the user is not a 'pengelola'.

---
## Review System

**Test Case:** Pengunjung - Create Review for a Wisata (after successful ticket)
*   **Purpose:** Verify Pengunjung can post a review for a Wisata they have a ticket for.
*   **Prerequisite:** Pengunjung `{{PENGUNJUNG_TOKEN}}` must have a 'success' ticket for `{{WISATA_ID_1}}`. Assume `{{ORDER_ID_1}}` payment was successful and its `_id` is `{{TICKET_ID_1}}`.
*   **Endpoint:** `POST /api/reviews`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "rating": 5,
      "comment": "Tempatnya sangat bagus dan tiketnya beragam!",
      "ticketId": "{{TICKET_ID_1}}" // Optional: if ticketId is used by backend for stricter validation
    }
    ```
*   **Expected Outcome:** Status 201 Created. Returns the new review data. Save review ID as `{{REVIEW_ID_1}}`.

---
**Test Case:** Pengunjung - Create Review (No Prior Ticket Purchase for a specific Wisata)
*   **Purpose:** Verify error if Pengunjung tries to review without a successful ticket for *that specific* Wisata.
*   **Endpoint:** `POST /api/reviews`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_2}}", // Assuming user has no successful ticket for WISATA_ID_2
      "rating": 4,
      "comment": "Ingin mencoba kesini, tapi belum pernah beli tiket."
    }
    ```
*   **Expected Outcome:** Status 403 Forbidden. Message indicates requirement of a purchased ticket for *this* Wisata.

---
**Test Case:** Public - Get Approved Reviews for Wisata
*   **Purpose:** Verify anyone can fetch approved reviews for a Wisata.
*   **Endpoint:** `GET /api/reviews/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** None
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns a paginated list of approved reviews for `{{WISATA_ID_1}}`. `{{REVIEW_ID_1}}` should be in this list.

---
**Test Case:** Pengunjung - Get My Reviews
*   **Purpose:** Verify Pengunjung can retrieve their own reviews.
*   **Endpoint:** `GET /api/reviews/my-reviews`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns a paginated list of reviews submitted by `{{PENGUNJUNG_ID}}`. `{{REVIEW_ID_1}}` should be here.

---
**Test Case:** Pengunjung - Update Own Review
*   **Purpose:** Verify Pengunjung can update their own review.
*   **Endpoint:** `PUT /api/reviews/{{REVIEW_ID_1}}`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "rating": 4,
      "comment": "Update: Tempatnya masih bagus, tapi agak ramai di akhir pekan."
    }
    ```
*   **Expected Outcome:** Status 200 OK. Returns the updated review data.

---
**Test Case:** Pengelola - Respond to a Review
*   **Purpose:** Verify Pengelola of the Wisata can respond to a review. (User `{{PENGELOLA_ID}}` should be pengelola of `{{WISATA_ID_1}}`).
*   **Endpoint:** `PUT /api/reviews/{{REVIEW_ID_1}}/respond`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "responseText": "Terima kasih atas ulasan Anda! Kami akan terus berusaha meningkatkan pelayanan."
    }
    ```
*   **Expected Outcome:** Status 200 OK. The review `{{REVIEW_ID_1}}` now includes the pengelola's response.

---
**Test Case:** Admin - Set Review Status (e.g., Reject a review)
*   **Purpose:** Verify Admin can change the status of a review.
*   **Endpoint:** `PUT /api/reviews/{{REVIEW_ID_1}}/status`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "status": "rejected"
    }
    ```
*   **Expected Outcome:** Status 200 OK. Review `{{REVIEW_ID_1}}` now has status 'rejected'. It should not appear in public listing of approved reviews.

---
**Test Case:** Pengunjung - Delete Own Review
*   **Purpose:** Verify Pengunjung can delete their own review. (Set status back to 'approved' first if previously rejected for testing flow, or use a new review ID).
*   **Endpoint:** `DELETE /api/reviews/{{REVIEW_ID_1}}`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Review `{{REVIEW_ID_1}}` is deleted.

---
**Test Case:** Admin - Delete Any Review
*   **Purpose:** Verify Admin can delete any review. (Re-create a review first if `{{REVIEW_ID_1}}` was deleted, get `{{NEW_REVIEW_ID_FOR_ADMIN_DELETE}}`).
*   **Endpoint:** `DELETE /api/reviews/{{NEW_REVIEW_ID_FOR_ADMIN_DELETE}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Review is deleted.
---
**Test Case:** Delete Wisata (as Admin) - Re-check after all other tests
*   **Purpose:** Verify Admin can delete a Wisata (ensure this doesn't cause issues with linked tickets/reviews - though they might become orphaned if not handled by DB/app logic).
*   **Endpoint:** `DELETE /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK or 204 No Content.
```
