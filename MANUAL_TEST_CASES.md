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
      "hargaTiket": {
        "dewasa": 50000,
        "anakAnak": 25000
      },
      "jamOperasional": {
        "seninJumat": "08:00 - 17:00",
        "sabtuMinggu": "07:00 - 18:00",
        "catatan": "Tutup pada hari libur nasional tertentu."
      },
      "kategori": ["Pantai", "Alam"],
      "pengelola": "{{PENGELOLA_ID}}" // Optional: assign to a pengelola
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
      "hargaTiket": {
        "dewasa": 75000,
        "anakAnak": 40000
      },
      "jamOperasional": {
        "seninJumat": "06:00 - 16:00",
        "sabtuMinggu": "05:00 - 17:00"
      },
      "kategori": ["Gunung", "Alam", "Hiking"],
      "pengelola": "{{PENGELOLA_ID}}" // Pengelola will be automatically assigned if not admin
    }
    ```
*   **Expected Outcome:** Status 201 Created, returns the created Wisata data. Save the ID as `{{WISATA_ID_2}}`.

---
**Test Case:** Get All Wisata (Public)
*   **Purpose:** Verify anyone can fetch all Wisata.
*   **Endpoint:** `GET /api/wisata`
*   **User Role/Authentication:** None (or any token)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK, returns an array of Wisata.

---
**Test Case:** Get Wisata by ID (Public)
*   **Purpose:** Verify anyone can fetch a specific Wisata by its ID.
*   **Endpoint:** `GET /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** None (or any token)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK, returns the details of Wisata with ID `{{WISATA_ID_1}}`.

---
**Test Case:** Update Wisata (by Admin who created it or any Admin)
*   **Purpose:** Verify Admin can update Wisata details.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Pantai Indah Test Updated",
      "hargaTiket": {
        "dewasa": 55000,
        "anakAnak": 30000
      }
    }
    ```
*   **Expected Outcome:** Status 200 OK, returns the updated Wisata data.

---
**Test Case:** Update Wisata (by Pengelola who manages it)
*   **Purpose:** Verify Pengelola can update their own Wisata details.
*   **Endpoint:** `PUT /api/wisata/{{WISATA_ID_2}}`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "nama": "Gunung Tinggi Test Updated by Pengelola",
      "jamOperasional": {
        "seninJumat": "06:00 - 16:30",
        "sabtuMinggu": "05:00 - 17:30"
      }
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
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK, returns message and updated Wisata data.

---
## Ticket Purchasing Flow (as Pengunjung)

**Test Case:** Create Ticket Transaction (Purchase Ticket)
*   **Purpose:** Verify a 'pengunjung' can initiate a ticket purchase.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "quantity": {
        "dewasa": 2,
        "anakAnak": 1
      }
    }
    ```
*   **Expected Outcome:** Status 201 Created. Returns `orderId`, `snapToken`, and `ticketId`. Save these as `{{ORDER_ID_1}}`, `{{SNAP_TOKEN_1}}`, and `{{TICKET_ID_1}}`. The ticket should be in 'pending' status.

---
**Test Case:** Create Ticket Transaction - Invalid Wisata ID
*   **Purpose:** Verify error handling for invalid Wisata ID.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "INVALIDWISATAID",
      "quantity": { "dewasa": 1 }
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request, with error message.

---
**Test Case:** Create Ticket Transaction - Wisata Not Found
*   **Purpose:** Verify error handling for non-existent Wisata ID.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "605fe2e801ab3f001fde0000", // A valid ObjectId format but non-existent
      "quantity": { "dewasa": 1 }
    }
    ```
*   **Expected Outcome:** Status 404 Not Found, with error message.

---
**Test Case:** Create Ticket Transaction - Zero Quantity
*   **Purpose:** Verify error for zero quantity.
*   **Endpoint:** `POST /api/tickets/purchase`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:**
    ```json
    {
      "wisataId": "{{WISATA_ID_1}}",
      "quantity": { "dewasa": 0, "anakAnak": 0 }
    }
    ```
*   **Expected Outcome:** Status 400 Bad Request, e.g., "At least one ticket...".

---
**Test Case:** Get User's Tickets
*   **Purpose:** Verify a 'pengunjung' can retrieve their list of tickets.
*   **Endpoint:** `GET /api/tickets/my-tickets`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns an array of tickets. The ticket `{{TICKET_ID_1}}` should be present with `paymentStatus: 'pending'`.

---
## Midtrans Notification Simulation

**Test Case:** Simulate Midtrans 'success' notification
*   **Purpose:** Verify the system correctly handles a successful payment notification from Midtrans.
*   **Endpoint:** `POST /api/tickets/midtrans-notification`
*   **User Role/Authentication:** None (Webhook endpoint)
*   **Request Body:**
    ```json
    {
      "transaction_time": "2024-03-15 10:00:00",
      "transaction_status": "capture",
      "transaction_id": "MIDTRANS-TRX-ID-SUCCESS-001",
      "status_message": "midtrans payment notification",
      "status_code": "200",
      "signature_key": "YOUR_CALCULATED_SIGNATURE_KEY_IF_VERIFYING", // For now, not strictly checked by controller
      "settlement_time": "2024-03-15 10:05:00",
      "payment_type": "credit_card",
      "order_id": "{{ORDER_ID_1}}",
      "merchant_id": "YOUR_MIDTRANS_MERCHANT_ID_PLACEHOLDER",
      "gross_amount": "125000.00", // Match the total price for 2 dewasa @ 50k, 1 anak @ 25k for WISATA_ID_1
      "fraud_status": "accept",
      "currency": "IDR"
    }
    ```
*   **Expected Outcome:** Status 200 OK. The ticket `{{TICKET_ID_1}}` should now have `paymentStatus: 'success'`, `paidAt` populated, `transactionId` updated, and `paymentMethod` set.

---
**Test Case:** Get User's Tickets (After Success Notification)
*   **Purpose:** Verify the ticket status is updated after a successful notification.
*   **Endpoint:** `GET /api/tickets/my-tickets`
*   **User Role/Authentication:** Pengunjung Token (`Bearer {{PENGUNJUNG_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. The ticket `{{TICKET_ID_1}}` should have `paymentStatus: 'success'`.

---
**Test Case:** Simulate Midtrans 'pending' notification (e.g., for bank transfer)
*   **Purpose:** Verify handling of a pending payment notification. (Create a new order first)
*   **Endpoint:** `POST /api/tickets/midtrans-notification`
*   **User Role/Authentication:** None
*   **Request Body (New Order - `{{ORDER_ID_2}}`):**
    ```json
    {
      "transaction_time": "2024-03-15 11:00:00",
      "transaction_status": "pending",
      "transaction_id": "MIDTRANS-TRX-ID-PENDING-001",
      "status_message": "midtrans payment notification",
      "status_code": "201", // Or other relevant pending code
      "signature_key": "YOUR_CALCULATED_SIGNATURE_KEY_IF_VERIFYING",
      "payment_type": "bank_transfer",
      "order_id": "{{ORDER_ID_2}}", // Assume this is a NEW orderId from a new purchase
      "merchant_id": "YOUR_MIDTRANS_MERCHANT_ID_PLACEHOLDER",
      "gross_amount": "75000.00",
      "fraud_status": "accept", // Or it might not be present for pending
      "currency": "IDR",
      "va_numbers": [{"bank": "bca", "va_number": "1234567890"}]
    }
    ```
*   **Expected Outcome:** Status 200 OK. The ticket `{{TICKET_ID_2}}` (from the new purchase) should remain/be set to `paymentStatus: 'pending'`.

**Note:** For the 'pending' test, you'd first create another transaction like the first one, get `{{ORDER_ID_2}}` and `{{TICKET_ID_2}}`, then send this notification.

---
**Test Case:** Simulate Midtrans 'failure/expired' notification (e.g., for an existing pending order)
*   **Purpose:** Verify handling of a failed or expired payment notification.
*   **Endpoint:** `POST /api/tickets/midtrans-notification`
*   **User Role/Authentication:** None
*   **Request Body (Using `{{ORDER_ID_2}}` which was pending):**
    ```json
    {
      "transaction_time": "2024-03-16 11:00:00", // Later time
      "transaction_status": "expire", // or "deny" or "cancel"
      "transaction_id": "MIDTRANS-TRX-ID-PENDING-001", // Same transaction_id as the pending one
      "status_message": "midtrans payment notification",
      "status_code": "200", // Midtrans usually sends 200 OK for the notification itself
      "signature_key": "YOUR_CALCULATED_SIGNATURE_KEY_IF_VERIFYING",
      "payment_type": "bank_transfer",
      "order_id": "{{ORDER_ID_2}}",
      "merchant_id": "YOUR_MIDTRANS_MERCHANT_ID_PLACEHOLDER",
      "gross_amount": "75000.00",
      "fraud_status": "accept", // Or as applicable
      "currency": "IDR"
    }
    ```
*   **Expected Outcome:** Status 200 OK. The ticket `{{TICKET_ID_2}}` should now have `paymentStatus: 'expired'` (or 'failed'/'cancelled' based on `transaction_status`).

---
## Sales Viewing

**Test Case:** Get Sales by Wisata (as Admin for `WISATA_ID_1`)
*   **Purpose:** Verify Admin can view sales data for a specific Wisata.
*   **Endpoint:** `GET /api/tickets/sales/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns sales data including total revenue, total tickets sold, and a list of successful ticket transactions for `{{WISATA_ID_1}}`. Ticket `{{TICKET_ID_1}}` (if successful) should be in this list.

---
**Test Case:** Get Sales by Wisata (as Pengelola for their `WISATA_ID_2`)
*   **Purpose:** Verify Pengelola can view sales data for their managed Wisata.
*   **Endpoint:** `GET /api/tickets/sales/{{WISATA_ID_2}}`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK. Returns sales data for `{{WISATA_ID_2}}`. If no successful sales, it should indicate that.

---
**Test Case:** Get Sales by Wisata (Pengelola tries to access Admin's Wisata sales)
*   **Purpose:** Verify Pengelola cannot access sales data for Wisata they don't manage.
*   **Endpoint:** `GET /api/tickets/sales/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Pengelola Token (`Bearer {{PENGELOLA_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 403 Forbidden.

---
**Test Case:** Delete Wisata (as Admin)
*   **Purpose:** Verify Admin can delete a Wisata.
*   **Endpoint:** `DELETE /api/wisata/{{WISATA_ID_1}}`
*   **User Role/Authentication:** Admin Token (`Bearer {{ADMIN_TOKEN}}`)
*   **Request Body:** None
*   **Expected Outcome:** Status 200 OK or 204 No Content, with a success message. Subsequent GET for `{{WISATA_ID_1}}` should be 404.

```
