# 🚀 Travesia API Quick Reference

## Base URL

```
https://trv.aisadev.id/api
```

## Authentication Header

```
Authorization: Bearer YOUR_JWT_TOKEN
```

---

## 📋 Quick Endpoint Reference

### 🔐 Authentication

| Method | Endpoint                       | Auth | Purpose            |
| ------ | ------------------------------ | ---- | ------------------ |
| POST   | `/auth/register`               | None | Register user      |
| POST   | `/auth/login`                  | None | User login         |
| GET    | `/auth/profile`                | ✅   | Get profile        |
| PUT    | `/auth/profile`                | ✅   | Update profile     |
| PUT    | `/auth/profile/picture`        | ✅   | Update profile pic |
| POST   | `/auth/request-reset-password` | None | Request OTP        |
| POST   | `/auth/verify-reset-password`  | None | Reset password     |

### 🗺️ Provinces

| Method | Endpoint         | Auth  | Purpose            |
| ------ | ---------------- | ----- | ------------------ |
| GET    | `/provinces`     | None  | List all provinces |
| POST   | `/provinces`     | Admin | Add province       |
| PUT    | `/provinces/:id` | Admin | Update province    |
| DELETE | `/provinces/:id` | Admin | Delete province    |

### 🏞️ Wisata

| Method | Endpoint                                    | Auth            | Purpose            |
| ------ | ------------------------------------------- | --------------- | ------------------ |
| GET    | `/wisata`                                   | None            | List all wisata    |
| GET    | `/wisata/:id`                               | None            | Get wisata details |
| GET    | `/wisata/province/:provinceId`              | None            | Wisata by province |
| POST   | `/wisata`                                   | Admin/Pengelola | Create wisata      |
| PUT    | `/wisata/:id`                               | Admin/Owner     | Update wisata      |
| DELETE | `/wisata/:id`                               | Admin/Owner     | Delete wisata      |
| POST   | `/wisata/:id/gallery`                       | Admin/Owner     | Upload image       |
| PUT    | `/wisata/:wisataId/gallery/:imageId/verify` | Admin           | Verify image       |
| PUT    | `/wisata/:id/assign-pengelola`              | Admin           | Change manager     |

### 👑 Admin Users

| Method | Endpoint                      | Auth  | Purpose       |
| ------ | ----------------------------- | ----- | ------------- |
| GET    | `/admin/users`                | Admin | List users    |
| GET    | `/admin/users/:userId`        | Admin | User details  |
| PUT    | `/admin/users/:userId/role`   | Admin | Update role   |
| PUT    | `/admin/users/:userId/status` | Admin | Update status |

### ⭐ Reviews

| Method | Endpoint                     | Auth        | Purpose            |
| ------ | ---------------------------- | ----------- | ------------------ |
| POST   | `/reviews`                   | Pengunjung  | Create review      |
| GET    | `/reviews/wisata/:wisataId`  | None        | Reviews for wisata |
| GET    | `/reviews/my-reviews`        | Pengunjung  | My reviews         |
| GET    | `/reviews/:reviewId`         | None        | Review details     |
| PUT    | `/reviews/:reviewId`         | Owner       | Update review      |
| DELETE | `/reviews/:reviewId`         | Owner/Admin | Delete review      |
| PUT    | `/reviews/:reviewId/respond` | Pengelola   | Respond to review  |
| PUT    | `/reviews/:reviewId/status`  | Admin       | Set review status  |

### 🎫 Tickets

| Method | Endpoint                         | Auth        | Purpose         |
| ------ | -------------------------------- | ----------- | --------------- |
| POST   | `/tickets/purchase`              | Pengunjung  | Purchase ticket |
| GET    | `/tickets/my-tickets`            | Pengunjung  | My tickets      |
| POST   | `/tickets/midtrans-notification` | None        | Payment webhook |
| GET    | `/tickets/sales/:wisataId`       | Admin/Owner | Sales data      |

---

## 🎯 Common Request Examples

### Login

```bash
curl -X POST https://trv.aisadev.id/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

### Create Wisata

```bash
curl -X POST https://trv.aisadev.id/api/wisata \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "Pantai Paradise",
    "kategori": "Pantai",
    "deskripsi": "Pantai indah",
    "provinceId": "PROVINCE_ID",
    "ticketTypes": [{"name": "Dewasa", "price": 50000}],
    "lokasi": {"alamat": "Jl. Paradise", "koordinat": {"lat": -8.123, "lng": 116.456}}
  }'
```

### Purchase Ticket

```bash
curl -X POST https://trv.aisadev.id/api/tickets/purchase \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "wisataId": "WISATA_ID",
    "itemsToPurchase": [{"ticketTypeId": "TICKET_TYPE_ID", "quantity": 2}]
  }'
```

### Submit Review

```bash
curl -X POST https://trv.aisadev.id/api/reviews \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "wisataId": "WISATA_ID",
    "rating": 5,
    "comment": "Amazing place!"
  }'
```

---

## 📊 Response Status Codes

| Code | Meaning      |
| ---- | ------------ |
| 200  | Success      |
| 201  | Created      |
| 400  | Bad Request  |
| 401  | Unauthorized |
| 403  | Forbidden    |
| 404  | Not Found    |
| 500  | Server Error |

---

## 🔑 User Roles & Permissions

### Admin

- ✅ All endpoints
- ✅ User management
- ✅ Content moderation
- ✅ Province management

### Pengelola

- ✅ Manage assigned wisata
- ✅ Upload gallery images
- ✅ Respond to reviews
- ✅ View sales data
- ❌ User management
- ❌ Province management

### Pengunjung

- ✅ View content
- ✅ Purchase tickets
- ✅ Write/manage reviews
- ✅ Update profile
- ❌ Admin functions
- ❌ Wisata management

---

## 🛠️ File Upload Fields

| Field        | Endpoint                                  | Required | Purpose         |
| ------------ | ----------------------------------------- | -------- | --------------- |
| `fotoProfil` | `/auth/register`, `/auth/profile/picture` | No       | Profile picture |
| `gambar`     | `/wisata/:id/gallery`                     | Yes      | Gallery image   |
| `image`      | `/provinces`                              | Yes      | Province image  |

---

## 📱 Testing Credentials

| Role       | Email               | Password    |
| ---------- | ------------------- | ----------- |
| Admin      | admin@test.com      | password123 |
| Pengunjung | pengunjung@test.com | password123 |

---

_Quick Reference for Travesia API v1.0_
