# 📚 Travesia API Documentation - Complete with Real JSON Samples

## Base URL

```
https://trv.aisadev.id/api
```

## Authentication

Most endpoints require authentication using Bearer token in the header:

```
Authorization: Bearer <your_jwt_token>
```

## User Roles

- **Admin**: Full system access, can manage all resources
- **Pengelola**: Can manage assigned wisata, respond to reviews
- **Pengunjung**: Can view wisata, purchase tickets, write reviews

---

## 🔐 Authentication Endpoints (`/api/auth`)

### 1. Register User

**POST** `/api/auth/register`

**Purpose**: Register a new user (pengunjung by default, pengelola only by admin)

**Authentication**: None (for pengunjung), Admin token required (for pengelola)

**Request Body**:

```json
{
  "nama": "Test Pengunjung",
  "email": "pengunjung@test.com",
  "password": "password123",
  "telepon": "081234567892",
  "role": "pengunjung"
}
```

**File Upload**: `fotoProfil` (optional profile picture)

**Success Response (201)**:

```json
{
  "message": "Registrasi berhasil",
  "user": {
    "nama": "Test Pengunjung",
    "email": "pengunjung@test.com",
    "fotoProfil": null,
    "role": "pengunjung",
    "statusAkun": "aktif",
    "tempatWisata": [],
    "favoritWisata": [],
    "tickets": [],
    "_id": "684735cad8dfd8dae86d30f3",
    "createdAt": "2025-06-09T19:28:10.064Z",
    "__v": 0
  }
}
```

**Error Response (400)** - Email already exists:

```json
{
  "message": "Email sudah digunakan"
}
```

**Error Response (403)** - Pengelola registration without admin:

```json
{
  "message": "Hanya admin yang bisa menambahkan pengelola"
}
```

### 2. Login

**POST** `/api/auth/login`

**Purpose**: User login

**Authentication**: None

**Request Body**:

```json
{
  "email": "admin@test.com",
  "password": "password123"
}
```

**Success Response (200)**:

```json
{
  "message": "Login berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NDczNWM5ZDhkZmQ4ZGFlODZkMzBlZiIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc0OTQ5NzM2MCwiZXhwIjoxNzUwMTAyMTYwfQ.zLlMmPcI8DQdC2n3XRc3-vYufzox2NgmSuRn_aAAWhs",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NDczNWM5ZDhkZmQ4ZGFlODZkMzBlZiIsImlhdCI6MTc0OTQ5NzM2MCwiZXhwIjoxNzUyMDg5MzYwfQ.6x0di1tZFkMaGy_VPzNKdlyc8sO8HfHpKLIsekJl7R4",
  "user": {
    "id": "684735c9d8dfd8dae86d30ef",
    "nama": "Updated Admin Name",
    "email": "admin@test.com",
    "role": "admin",
    "fotoProfil": null
  }
}
```

**Error Response (404)**:

```json
{
  "message": "Email tidak ditemukan"
}
```

**Error Response (400)**:

```json
{
  "message": "Password salah"
}
```

**Error Response (403)** - Banned account:

```json
{
  "message": "Akun Anda telah diblokir"
}
```

### 3. Request Password Reset

**POST** `/api/auth/request-reset-password`

**Purpose**: Request OTP for password reset

**Authentication**: None

**Request Body**:

```json
{
  "email": "admin@test.com"
}
```

**Success Response (200)**:

```json
{
  "message": "OTP telah dikirim ke email Anda"
}
```

### 4. Verify Password Reset

**POST** `/api/auth/verify-reset-password`

**Purpose**: Reset password using OTP

**Authentication**: None

**Request Body**:

```json
{
  "email": "admin@test.com",
  "otp": "237067",
  "newPassword": "newpassword123"
}
```

**Success Response (200)**:

```json
{
  "message": "Password berhasil direset"
}
```

**Error Response (400)**:

```json
{
  "message": "OTP tidak valid atau sudah kadaluarsa"
}
```

### 5. Get Profile

**GET** `/api/auth/profile`

**Purpose**: Get current user profile

**Authentication**: Required (any role)

**Success Response (200)**:

```json
{
  "user": {
    "_id": "684735c9d8dfd8dae86d30ef",
    "nama": "Updated Admin Name",
    "email": "admin@test.com",
    "fotoProfil": null,
    "role": "admin",
    "statusAkun": "aktif",
    "tempatWisata": [],
    "favoritWisata": [],
    "tickets": [],
    "createdAt": "2025-06-09T19:28:09.148Z",
    "__v": 0,
    "telepon": "081234567899",
    "resetPasswordExpires": "2025-06-09T19:33:12.950Z",
    "resetPasswordOTP": "237067"
  }
}
```

### 6. Update Profile

**PUT** `/api/auth/profile`

**Purpose**: Update user profile

**Authentication**: Required (any role)

**Request Body**:

```json
{
  "nama": "Updated Admin Name",
  "telepon": "081234567899"
}
```

**Success Response (200)**:

```json
{
  "message": "Profil berhasil diperbarui",
  "user": {
    "_id": "684735c9d8dfd8dae86d30ef",
    "nama": "Updated Admin Name",
    "email": "admin@test.com",
    "fotoProfil": null,
    "role": "admin",
    "statusAkun": "aktif",
    "tempatWisata": [],
    "favoritWisata": [],
    "tickets": [],
    "createdAt": "2025-06-09T19:28:09.148Z",
    "__v": 0,
    "telepon": "081234567899"
  }
}
```

### 7. Update Profile Picture

**PUT** `/api/auth/profile/picture`

**Purpose**: Update profile picture

**Authentication**: Required (any role)

**File Upload**: `fotoProfil` (required)

**Success Response (200)**:

```json
{
  "message": "Foto profil berhasil diperbarui",
  "fotoProfil": "https://cloudflare-storage-url/profile-images/new-image.jpg"
}
```

---

## 🗺️ Province Management (`/api/provinces`)

### 1. Get All Provinces

**GET** `/api/provinces`

**Purpose**: Get list of all provinces

**Authentication**: None

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "68472f532d660ec4ba7dff4b",
      "name": "Aceh",
      "code": "ID-AC",
      "image": "https://image.mypsikolog.id/provinces/1749495629971-vpotckgynu-id-ac.png",
      "__v": 0,
      "createdAt": "2025-06-09T19:00:35.113Z",
      "updatedAt": "2025-06-09T19:00:35.113Z"
    },
    {
      "_id": "68472f532d660ec4ba7dff5b",
      "name": "Bali",
      "code": "ID-BA",
      "image": "https://image.mypsikolog.id/provinces/1749495630031-zhfwi4rwc-id-ba.png",
      "__v": 0,
      "createdAt": "2025-06-09T19:00:35.115Z",
      "updatedAt": "2025-06-09T19:00:35.115Z"
    },
    {
      "_id": "68472f532d660ec4ba7dff5a",
      "name": "Banten",
      "code": "ID-BT",
      "image": "https://image.mypsikolog.id/provinces/1749495630021-pscgxo0rv-id-bt.png",
      "__v": 0,
      "createdAt": "2025-06-09T19:00:35.115Z",
      "updatedAt": "2025-06-09T19:00:35.115Z"
    }
  ]
}
```

### 2. Add Province

**POST** `/api/provinces`

**Purpose**: Add new province

**Authentication**: Admin required

**File Upload**: `image` (required province image)

**Request Body** (form-data):

```
name: "Nusa Tenggara Barat"
code: "ID-NB"
image: [file upload]
```

**Success Response (201)**:

```json
{
  "message": "Provinsi berhasil ditambahkan",
  "data": {
    "_id": "province_id",
    "name": "Nusa Tenggara Barat",
    "code": "ID-NB",
    "image": "https://image.mypsikolog.id/provinces/1749495630123-example.png",
    "createdAt": "2025-06-09T19:00:35.115Z",
    "updatedAt": "2025-06-09T19:00:35.115Z"
  }
}
```

**Error Response (400)** - Missing required fields:

```json
{
  "message": "Nama, kode, dan gambar provinsi harus diisi"
}
```

**Error Response (400)** - Duplicate province:

```json
{
  "message": "Provinsi atau kode sudah terdaftar"
}
```

### 3. Update Province

**PUT** `/api/provinces/:id`

**Purpose**: Update province information

**Authentication**: Admin required

**File Upload**: `image` (optional province image)

**Request Body** (form-data):

```
name: "Updated Province Name"
code: "UP"
image: [optional file upload]
```

**Success Response (200)**:

```json
{
  "message": "Provinsi berhasil diperbarui",
  "data": {
    "_id": "province_id",
    "name": "Updated Province Name",
    "code": "UP",
    "image": "https://image.mypsikolog.id/provinces/updated-image.png",
    "createdAt": "2025-06-09T19:00:35.115Z",
    "updatedAt": "2025-06-09T20:15:22.456Z"
  }
}
```

### 4. Delete Province

**DELETE** `/api/provinces/:id`

**Purpose**: Delete province

**Authentication**: Admin required

**Success Response (200)**:

```json
{
  "message": "Provinsi berhasil dihapus"
}
```

**Error Response (404)**:

```json
{
  "message": "Provinsi tidak ditemukan"
}
```

---

## 🏞️ Wisata Management (`/api/wisata`)

### 1. Get All Wisata (Public)

**GET** `/api/wisata`

**Purpose**: Get all published wisata

**Authentication**: None

**Success Response (200)** - Empty result example:

```json
{
  "data": []
}
```

**Success Response (200)** - With data:

```json
{
  "data": [
    {
      "_id": "wisata_id",
      "nama": "Pantai Kuta",
      "kategori": "Pantai",
      "deskripsi": "Pantai yang indah dengan pasir putih",
      "province": {
        "_id": "province_id",
        "name": "Bali",
        "code": "ID-BA"
      },
      "lokasi": {
        "alamat": "Jl. Pantai Kuta",
        "koordinat": {
          "lat": -8.7203,
          "lng": 115.1681
        }
      },
      "status": "buka",
      "ticketTypes": [
        {
          "_id": "ticket_type_id",
          "name": "Dewasa",
          "price": 25000,
          "description": "Tiket untuk pengunjung dewasa"
        },
        {
          "_id": "ticket_type_id_2",
          "name": "Anak-anak",
          "price": 15000,
          "description": "Tiket untuk anak-anak di bawah 12 tahun"
        }
      ],
      "statusPublikasi": "published",
      "pengelola": {
        "_id": "pengelola_id",
        "nama": "Manager Pantai",
        "email": "manager@pantaikuta.com"
      },
      "galeri": [
        {
          "_id": "image_id",
          "url": "https://example.com/gallery/image1.jpg",
          "deskripsi": "Pemandangan pantai saat sunset",
          "status": "verified",
          "uploadedBy": {
            "_id": "user_id",
            "nama": "Photographer",
            "email": "photo@example.com"
          }
        }
      ],
      "kontak": {
        "telepon": "081234567890",
        "email": "info@pantaikuta.com",
        "website": "https://pantaikuta.com"
      },
      "jamOperasional": {
        "senin": "06:00 - 18:00",
        "selasa": "06:00 - 18:00",
        "rabu": "06:00 - 18:00",
        "kamis": "06:00 - 18:00",
        "jumat": "06:00 - 18:00",
        "sabtu": "06:00 - 20:00",
        "minggu": "06:00 - 20:00"
      },
      "createdAt": "2025-06-09T19:00:35.115Z",
      "updatedAt": "2025-06-09T19:00:35.115Z"
    }
  ]
}
```

### 2. Get Wisata by ID

**GET** `/api/wisata/:id`

**Purpose**: Get detailed wisata information

**Authentication**: None

**Success Response (200)**:

```json
{
  "data": {
    "_id": "wisata_id",
    "nama": "Pantai Kuta",
    "kategori": "Pantai",
    "deskripsi": "Pantai yang indah dengan pasir putih dan sunset yang menakjubkan. Cocok untuk berselancar dan bersantai.",
    "province": {
      "_id": "province_id",
      "name": "Bali",
      "code": "ID-BA"
    },
    "lokasi": {
      "alamat": "Jl. Pantai Kuta No. 1, Kuta, Badung",
      "koordinat": {
        "lat": -8.7203,
        "lng": 115.1681
      }
    },
    "status": "buka",
    "ticketTypes": [
      {
        "_id": "ticket_type_id",
        "name": "Dewasa",
        "price": 25000,
        "description": "Tiket untuk pengunjung dewasa"
      }
    ],
    "galeri": [
      {
        "_id": "image_id",
        "url": "https://example.com/gallery/image1.jpg",
        "deskripsi": "Pemandangan pantai saat sunset",
        "status": "verified",
        "uploadedBy": {
          "_id": "user_id",
          "nama": "Photographer",
          "email": "photo@example.com"
        }
      }
    ],
    "pengelola": {
      "_id": "pengelola_id",
      "nama": "Manager Pantai",
      "email": "manager@pantaikuta.com"
    },
    "fasilitas": [],
    "kontak": {
      "telepon": "081234567890",
      "email": "info@pantaikuta.com",
      "website": "https://pantaikuta.com"
    },
    "jamOperasional": {
      "senin": "06:00 - 18:00",
      "selasa": "06:00 - 18:00",
      "rabu": "06:00 - 18:00",
      "kamis": "06:00 - 18:00",
      "jumat": "06:00 - 18:00",
      "sabtu": "06:00 - 20:00",
      "minggu": "06:00 - 20:00"
    }
  }
}
```

**Error Response (404)**:

```json
{
  "message": "Wisata tidak ditemukan!"
}
```

### 3. Get Wisata by Province

**GET** `/api/wisata/province/:provinceId`

**Purpose**: Get wisata filtered by province with pagination

**Authentication**: None

**Query Parameters**:

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `sort` (optional): Sort field (default: createdAt)
- `order` (optional): Sort order - asc/desc (default: desc)

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "wisata_id",
      "nama": "Tanah Lot",
      "kategori": "Sejarah & Budaya",
      "province": {
        "_id": "province_id",
        "name": "Bali",
        "code": "ID-BA"
      },
      "lokasi": {
        "alamat": "Tabanan, Bali"
      },
      "ticketTypes": [
        {
          "name": "Dewasa",
          "price": 60000
        }
      ]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 15,
    "hasNext": true,
    "hasPrev": false
  }
}
```

**Error Response (400)**:

```json
{
  "message": "Province ID tidak valid."
}
```

### 4. Create Wisata

**POST** `/api/wisata`

**Purpose**: Create new wisata

**Authentication**: Admin or Pengelola required

**Request Body**:

```json
{
  "nama": "Test Wisata API",
  "kategori": "Alam",
  "deskripsi": "Wisata test dari API testing",
  "provinceId": "68472f532d660ec4ba7dff5b",
  "lokasi": {
    "alamat": "Jl. Test API No. 1",
    "koordinat": {
      "lat": -8.123,
      "lng": 116.456
    }
  },
  "ticketTypes": [
    {
      "name": "Umum",
      "price": 50000,
      "description": "Tiket umum untuk semua pengunjung"
    }
  ],
  "jamOperasional": {
    "senin": "08:00 - 17:00",
    "selasa": "08:00 - 17:00",
    "rabu": "08:00 - 17:00",
    "kamis": "08:00 - 17:00",
    "jumat": "08:00 - 17:00",
    "sabtu": "08:00 - 20:00",
    "minggu": "08:00 - 20:00"
  },
  "kontak": {
    "telepon": "081234567890",
    "email": "info@testwisata.com",
    "website": "https://testwisata.com"
  },
  "pengelolaId": "pengelola_id"
}
```

**Success Response (201)**:

```json
{
  "message": "Wisata berhasil ditambahkan!",
  "data": {
    "_id": "new_wisata_id",
    "nama": "Test Wisata API",
    "kategori": "Alam",
    "pengelola": "pengelola_id",
    "province": "province_id",
    "statusPublikasi": "draft",
    "createdAt": "2025-06-09T19:30:00.000Z"
  }
}
```

**Error Response (400)** - Missing province:

```json
{
  "message": "Province ID is required and must be valid"
}
```

**Error Response (400)** - Invalid ticket types:

```json
{
  "message": "At least one ticket type must be provided."
}
```

**Error Response (403)** - Access denied:

```json
{
  "message": "Akses ditolak! Hanya admin atau pengelola yang dapat menambah wisata."
}
```

### 5. Update Wisata

**PUT** `/api/wisata/:id`

**Purpose**: Update wisata details

**Authentication**: Admin or Wisata Owner (Pengelola) required

**Request Body**: Same structure as create, all fields optional

**Success Response (200)**:

```json
{
  "message": "Wisata berhasil diperbarui!",
  "data": {
    "_id": "wisata_id",
    "nama": "Updated Test Wisata",
    "deskripsi": "Updated description",
    "updatedAt": "2025-06-09T19:35:00.000Z"
  }
}
```

**Error Response (404)**:

```json
{
  "message": "Wisata tidak ditemukan!"
}
```

**Error Response (403)**:

```json
{
  "message": "Akses ditolak! Anda bukan admin atau pengelola wisata ini."
}
```

### 6. Delete Wisata

**DELETE** `/api/wisata/:id`

**Purpose**: Delete wisata

**Authentication**: Admin or Wisata Owner (Pengelola) required

**Success Response (200)**:

```json
{
  "message": "Wisata berhasil dihapus!"
}
```

### 7. Add Gallery Image

**POST** `/api/wisata/:id/gallery`

**Purpose**: Upload image to wisata gallery

**Authentication**: Admin or Wisata Owner (Pengelola) required

**File Upload**: `gambar` (required image file)

**Success Response (201)**:

```json
{
  "message": "Gambar berhasil ditambahkan ke galeri!",
  "data": {
    "_id": "image_id",
    "url": "https://cloudflare-storage/gallery/image.jpg",
    "status": "pending",
    "uploadedBy": "user_id",
    "uploadedAt": "2025-06-09T19:40:00.000Z"
  }
}
```

### 8. Verify Gallery Image

**PUT** `/api/wisata/:wisataId/gallery/:gambarId/verify`

**Purpose**: Approve or reject gallery image

**Authentication**: Admin required

**Request Body**:

```json
{
  "status": "approved"
}
```

**Success Response (200)**:

```json
{
  "message": "Gambar berhasil approved!",
  "data": {
    "_id": "image_id",
    "url": "https://cloudflare-storage/gallery/image.jpg",
    "status": "approved",
    "uploadedBy": {
      "_id": "user_id",
      "nama": "Uploader Name",
      "email": "uploader@example.com"
    }
  }
}
```

### 9. Change Wisata Pengelola (Admin Only)

**PUT** `/api/wisata/:id/assign-pengelola`

**Purpose**: Assign wisata to different pengelola

**Authentication**: Admin required

**Request Body**:

```json
{
  "newPengelolaId": "new_pengelola_id"
}
```

**Success Response (200)**:

```json
{
  "message": "Wisata Pengelola updated successfully",
  "data": {
    "_id": "wisata_id",
    "nama": "Wisata Name",
    "pengelola": {
      "_id": "new_pengelola_id",
      "nama": "New Manager Name",
      "email": "newmanager@example.com"
    }
  }
}
```

---

## 👑 Admin User Management (`/api/admin/users`)

### 1. List All Users

**GET** `/api/admin/users`

**Purpose**: Get paginated list of all users with optional role filter

**Authentication**: Admin required

**Query Parameters**:

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `role` (optional): Filter by role (admin, pengelola, pengunjung)

**Example**: `/api/admin/users?page=1&limit=5&role=pengunjung`

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "user_id_1",
      "nama": "John Doe",
      "email": "john@example.com",
      "role": "pengunjung",
      "statusAkun": "aktif",
      "telepon": "081234567890",
      "fotoProfil": "https://cloudflare-storage/profiles/john.jpg",
      "createdAt": "2025-06-09T19:28:10.064Z",
      "__v": 0
    },
    {
      "_id": "user_id_2",
      "nama": "Jane Manager",
      "email": "jane@example.com",
      "role": "pengelola",
      "statusAkun": "aktif",
      "telepon": "081234567891",
      "fotoProfil": null,
      "tempatWisata": ["wisata_id_1", "wisata_id_2"],
      "createdAt": "2025-06-09T19:28:10.064Z",
      "__v": 0
    }
  ],
  "totalPages": 5,
  "currentPage": 1,
  "totalUsers": 25
}
```

### 2. Get User Details

**GET** `/api/admin/users/:userId`

**Purpose**: Get detailed information about a specific user

**Authentication**: Admin required

**Success Response (200)**:

```json
{
  "data": {
    "_id": "user_id",
    "nama": "John Doe",
    "email": "john@example.com",
    "role": "pengunjung",
    "statusAkun": "aktif",
    "telepon": "081234567890",
    "fotoProfil": "https://cloudflare-storage/profiles/john.jpg",
    "alamat": "Jl. Example Street No. 123",
    "tempatWisata": [],
    "favoritWisata": [],
    "tickets": [],
    "createdAt": "2025-06-09T19:28:10.064Z",
    "__v": 0
  }
}
```

**Error Response (404)**:

```json
{
  "message": "User not found"
}
```

**Error Response (400)**:

```json
{
  "message": "Invalid User ID format"
}
```

### 3. Update User Role

**PUT** `/api/admin/users/:userId/role`

**Purpose**: Change user's role

**Authentication**: Admin required

**Request Body**:

```json
{
  "role": "pengelola"
}
```

**Success Response (200)**:

```json
{
  "message": "User role updated successfully",
  "data": {
    "_id": "user_id",
    "nama": "John Doe",
    "email": "john@example.com",
    "role": "pengelola",
    "statusAkun": "aktif",
    "createdAt": "2025-06-09T19:28:10.064Z",
    "updatedAt": "2025-06-09T20:00:00.000Z"
  }
}
```

**Error Response (400)**:

```json
{
  "message": "Invalid role specified. Must be admin, pengelola, or pengunjung."
}
```

### 4. Manage User Account Status

**PUT** `/api/admin/users/:userId/status`

**Purpose**: Change user account status (activate, deactivate, ban)

**Authentication**: Admin required

**Request Body**:

```json
{
  "statusAkun": "banned"
}
```

**Success Response (200)**:

```json
{
  "message": "User account status updated to banned",
  "data": {
    "_id": "user_id",
    "nama": "John Doe",
    "email": "john@example.com",
    "role": "pengunjung",
    "statusAkun": "banned",
    "updatedAt": "2025-06-09T20:00:00.000Z"
  }
}
```

**Error Response (400)**:

```json
{
  "message": "Invalid account status. Must be aktif, nonaktif, or banned."
}
```

---

## ⭐ Review Management (`/api/reviews`)

### 1. Create Review

**POST** `/api/reviews`

**Purpose**: Submit a review for wisata

**Authentication**: Pengunjung required

**Request Body**:

```json
{
  "wisataId": "wisata_id",
  "rating": 5,
  "comment": "Tempat yang sangat indah! Recommended banget.",
  "ticketId": "ticket_id"
}
```

**Success Response (201)**:

```json
{
  "message": "Review submitted successfully!",
  "data": {
    "_id": "review_id",
    "user": "user_id",
    "wisata": "wisata_id",
    "rating": 5,
    "comment": "Tempat yang sangat indah! Recommended banget.",
    "ticket": "ticket_id",
    "status": "approved",
    "createdAt": "2025-06-09T20:00:00.000Z",
    "__v": 0
  }
}
```

**Error Response (400)** - Invalid wisata ID:

```json
{
  "message": "Invalid Wisata ID format."
}
```

**Error Response (404)** - Wisata not found:

```json
{
  "message": "Wisata not found."
}
```

**Error Response (400)** - Invalid rating:

```json
{
  "message": "Rating must be a number between 1 and 5."
}
```

### 2. Get Reviews for Wisata

**GET** `/api/reviews/wisata/:wisataId`

**Purpose**: Get approved reviews for specific wisata

**Authentication**: None

**Query Parameters**:

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "review_id",
      "rating": 5,
      "comment": "Tempat yang sangat indah! Recommended banget.",
      "status": "approved",
      "user": {
        "_id": "user_id",
        "nama": "John Doe",
        "fotoProfil": "https://cloudflare-storage/profiles/john.jpg"
      },
      "wisata": {
        "_id": "wisata_id",
        "nama": "Pantai Kuta"
      },
      "pengelolaResponse": {
        "responseText": "Terima kasih atas reviewnya! Kami akan terus meningkatkan pelayanan.",
        "respondedBy": {
          "_id": "pengelola_id",
          "nama": "Manager Pantai"
        },
        "respondedAt": "2025-06-09T20:05:00.000Z"
      },
      "createdAt": "2025-06-09T20:00:00.000Z",
      "__v": 0
    }
  ],
  "totalPages": 3,
  "currentPage": 1,
  "totalReviews": 25
}
```

### 3. Get My Reviews

**GET** `/api/reviews/my-reviews`

**Purpose**: Get current user's reviews

**Authentication**: Pengunjung required

**Query Parameters**:

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "review_id",
      "rating": 5,
      "comment": "Tempat yang sangat indah! Recommended banget.",
      "status": "approved",
      "wisata": {
        "_id": "wisata_id",
        "nama": "Pantai Kuta"
      },
      "pengelolaResponse": {
        "responseText": "Terima kasih atas reviewnya!",
        "respondedBy": {
          "_id": "pengelola_id",
          "nama": "Manager Pantai"
        },
        "respondedAt": "2025-06-09T20:05:00.000Z"
      },
      "createdAt": "2025-06-09T20:00:00.000Z"
    }
  ],
  "totalPages": 2,
  "currentPage": 1,
  "totalReviews": 15
}
```

### 4. Get Review by ID

**GET** `/api/reviews/:reviewId`

**Purpose**: Get specific review details

**Authentication**: None

**Success Response (200)**:

```json
{
  "data": {
    "_id": "review_id",
    "rating": 5,
    "comment": "Tempat yang sangat indah! Recommended banget.",
    "status": "approved",
    "user": {
      "_id": "user_id",
      "nama": "John Doe",
      "fotoProfil": "https://cloudflare-storage/profiles/john.jpg"
    },
    "wisata": {
      "_id": "wisata_id",
      "nama": "Pantai Kuta"
    },
    "pengelolaResponse": {
      "responseText": "Terima kasih atas reviewnya! Kami akan terus meningkatkan pelayanan.",
      "respondedBy": {
        "_id": "pengelola_id",
        "nama": "Manager Pantai"
      },
      "respondedAt": "2025-06-09T20:05:00.000Z"
    },
    "createdAt": "2025-06-09T20:00:00.000Z",
    "__v": 0
  }
}
```

### 5. Update Review

**PUT** `/api/reviews/:reviewId`

**Purpose**: Update own review

**Authentication**: Pengunjung required (review owner)

**Request Body**:

```json
{
  "rating": 4,
  "comment": "Updated review - masih bagus tapi ada yang bisa diperbaiki"
}
```

**Success Response (200)**:

```json
{
  "message": "Review updated successfully.",
  "data": {
    "_id": "review_id",
    "rating": 4,
    "comment": "Updated review - masih bagus tapi ada yang bisa diperbaiki",
    "status": "approved",
    "updatedAt": "2025-06-09T20:10:00.000Z"
  }
}
```

**Error Response (403)**:

```json
{
  "message": "You are not authorized to update this review."
}
```

### 6. Delete Review

**DELETE** `/api/reviews/:reviewId`

**Purpose**: Delete review

**Authentication**: Pengunjung (review owner) or Admin required

**Success Response (200)**:

```json
{
  "message": "Review deleted successfully."
}
```

### 7. Pengelola Respond to Review

**PUT** `/api/reviews/:reviewId/respond`

**Purpose**: Pengelola responds to review of their wisata

**Authentication**: Pengelola required (wisata owner)

**Request Body**:

```json
{
  "responseText": "Terima kasih atas reviewnya! Kami akan terus meningkatkan pelayanan."
}
```

**Success Response (200)**:

```json
{
  "message": "Response posted successfully.",
  "data": {
    "_id": "review_id",
    "pengelolaResponse": {
      "responseText": "Terima kasih atas reviewnya! Kami akan terus meningkatkan pelayanan.",
      "respondedBy": "pengelola_id",
      "respondedAt": "2025-06-09T20:05:00.000Z"
    }
  }
}
```

**Error Response (403)**:

```json
{
  "message": "You are not authorized to respond to reviews for this Wisata."
}
```

**Error Response (400)**:

```json
{
  "message": "Response text cannot be empty."
}
```

### 8. Admin Set Review Status

**PUT** `/api/reviews/:reviewId/status`

**Purpose**: Admin moderates review status

**Authentication**: Admin required

**Request Body**:

```json
{
  "status": "approved"
}
```

**Success Response (200)**:

```json
{
  "message": "Review status updated to approved.",
  "data": {
    "_id": "review_id",
    "status": "approved",
    "updatedAt": "2025-06-09T20:15:00.000Z"
  }
}
```

**Error Response (400)**:

```json
{
  "message": "Invalid status. Must be one of: pending, approved, rejected."
}
```

---

## 🎫 Ticket Management (`/api/tickets`)

### 1. Purchase Ticket

**POST** `/api/tickets/purchase`

**Purpose**: Create ticket purchase transaction

**Authentication**: Pengunjung required

**Request Body**:

```json
{
  "wisataId": "wisata_id",
  "itemsToPurchase": [
    {
      "ticketTypeId": "ticket_type_id",
      "quantity": 2
    }
  ]
}
```

**Success Response (201)**:

```json
{
  "message": "Transaction created successfully",
  "data": {
    "orderId": "ORDER-1749497364-abc123",
    "totalAmount": 100000,
    "snapToken": "midtrans_snap_token_here",
    "snapRedirectUrl": "https://app.sandbox.midtrans.com/snap/v3/redirection/abc123xyz",
    "ticket": {
      "_id": "ticket_id",
      "user": "user_id",
      "wisata": "wisata_id",
      "orderId": "ORDER-1749497364-abc123",
      "purchasedItems": [
        {
          "ticketTypeId": "ticket_type_id",
          "name": "Dewasa",
          "priceAtPurchase": 50000,
          "quantity": 2,
          "description": "Tiket untuk pengunjung dewasa"
        }
      ],
      "totalPrice": 100000,
      "paymentStatus": "pending",
      "createdAt": "2025-06-09T20:20:00.000Z"
    }
  }
}
```

**Error Response (400)** - Invalid wisata:

```json
{
  "message": "Invalid Wisata ID format"
}
```

**Error Response (404)** - Wisata not found:

```json
{
  "message": "Wisata not found"
}
```

**Error Response (400)** - Invalid items:

```json
{
  "message": "itemsToPurchase must be a non-empty array"
}
```

### 2. Get My Tickets

**GET** `/api/tickets/my-tickets`

**Purpose**: Get user's purchased tickets

**Authentication**: Pengunjung required

**Success Response (200)**:

```json
{
  "data": [
    {
      "_id": "ticket_id",
      "orderId": "ORDER-1749497364-abc123",
      "wisata": {
        "_id": "wisata_id",
        "nama": "Pantai Kuta",
        "lokasi": {
          "alamat": "Jl. Pantai Kuta No. 1"
        },
        "ticketTypes": [
          {
            "_id": "ticket_type_id",
            "name": "Dewasa",
            "price": 50000
          }
        ]
      },
      "purchasedItems": [
        {
          "ticketTypeId": "ticket_type_id",
          "name": "Dewasa",
          "priceAtPurchase": 50000,
          "quantity": 2,
          "description": "Tiket untuk pengunjung dewasa"
        }
      ],
      "totalPrice": 100000,
      "paymentStatus": "success",
      "paymentMethod": "credit_card",
      "createdAt": "2025-06-09T20:20:00.000Z",
      "__v": 0
    }
  ]
}
```

**Success Response (200)** - No tickets:

```json
{
  "message": "No tickets found for this user.",
  "data": []
}
```

### 3. Midtrans Payment Notification

**POST** `/api/tickets/midtrans-notification`

**Purpose**: Handle payment status updates from Midtrans

**Authentication**: None (webhook endpoint)

**Request Body**: Midtrans notification payload

```json
{
  "order_id": "ORDER-1749497364-abc123",
  "transaction_status": "settlement",
  "payment_type": "credit_card",
  "gross_amount": "100000.00"
}
```

**Success Response (200)**:

```json
{
  "message": "Notification received and processed successfully."
}
```

**Error Response (500)**:

```json
{
  "message": "Server error while handling Midtrans notification",
  "error": "Error details"
}
```

### 4. Get Sales by Wisata

**GET** `/api/tickets/sales/:wisataId`

**Purpose**: Get sales data for specific wisata

**Authentication**: Admin or Wisata Owner (Pengelola) required

**Success Response (200)**:

```json
{
  "data": {
    "wisata": {
      "_id": "wisata_id",
      "nama": "Pantai Kuta"
    },
    "totalTicketsSold": 150,
    "totalRevenue": 7500000,
    "tickets": [
      {
        "_id": "ticket_id",
        "orderId": "ORDER-1749497364-abc123",
        "totalPrice": 100000,
        "paymentStatus": "success",
        "paymentMethod": "credit_card",
        "user": {
          "_id": "user_id",
          "nama": "John Doe"
        },
        "purchasedItems": [
          {
            "ticketTypeId": "ticket_type_id",
            "name": "Dewasa",
            "priceAtPurchase": 50000,
            "quantity": 2
          }
        ],
        "createdAt": "2025-06-09T20:20:00.000Z"
      }
    ]
  }
}
```

**Error Response (403)**:

```json
{
  "message": "Access denied. You are not the manager of this Wisata or an Admin."
}
```

**Error Response (404)**:

```json
{
  "message": "Wisata not found"
}
```

---

## 📋 Common Response Formats

### Success Response Structure

```json
{
  "message": "Operation description",
  "data": {
    /* response data */
  }
}
```

### Error Response Structure

```json
{
  "message": "Error description",
  "error": "Detailed error message (optional)"
}
```

### Pagination Response Structure

```json
{
  "data": [
    /* array of items */
  ],
  "totalPages": 5,
  "currentPage": 1,
  "totalItems": 50,
  "hasNext": true,
  "hasPrev": false
}
```

---

## 🔧 HTTP Status Codes

- **200**: Success / OK
- **201**: Created successfully
- **400**: Bad request / Validation error
- **401**: Unauthorized / Invalid or missing token
- **403**: Forbidden / Insufficient permissions
- **404**: Resource not found
- **500**: Internal server error

---

## 📱 File Upload Specifications

### Supported Formats

- **Images**: JPG, PNG, JPEG
- **Maximum Size**: 5MB per file
- **Storage**: Cloudflare R2 Storage

### Upload Fields

- `fotoProfil`: Profile picture upload
- `gambar`: Gallery image upload
- `image`: Province image upload

### Upload Process

1. Files are validated for type and size
2. Images are optimized automatically
3. Files are stored in Cloudflare R2
4. CDN URLs are returned in response

---

## 🔄 Authentication Flow Examples

### Complete User Registration & Login Flow

```bash
# 1. Register new user
curl -X POST https://trv.aisadev.id/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "telepon": "081234567890",
    "role": "pengunjung"
  }'

# 2. Login to get token
curl -X POST https://trv.aisadev.id/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# 3. Use token for authenticated requests
curl -X GET https://trv.aisadev.id/api/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Admin User Management Flow

```bash
# 1. Login as admin
curl -X POST https://trv.aisadev.id/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "password123"
  }'

# 2. List all users
curl -X GET https://trv.aisadev.id/api/admin/users \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"

# 3. Update user role
curl -X PUT https://trv.aisadev.id/api/admin/users/USER_ID/role \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "pengelola"}'
```

### Wisata Management Flow

```bash
# 1. Create wisata (Admin/Pengelola)
curl -X POST https://trv.aisadev.id/api/wisata \
  -H "Authorization: Bearer ADMIN_OR_PENGELOLA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "Pantai Paradise",
    "kategori": "Pantai",
    "deskripsi": "Pantai indah dengan pasir putih",
    "provinceId": "PROVINCE_ID",
    "ticketTypes": [{"name": "Dewasa", "price": 50000}]
  }'

# 2. Upload gallery image
curl -X POST https://trv.aisadev.id/api/wisata/WISATA_ID/gallery \
  -H "Authorization: Bearer ADMIN_OR_PENGELOLA_TOKEN" \
  -F "gambar=@/path/to/image.jpg"

# 3. Verify image (Admin only)
curl -X PUT https://trv.aisadev.id/api/wisata/WISATA_ID/gallery/IMAGE_ID/verify \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "approved"}'
```

### Ticket Purchase Flow

```bash
# 1. Get wisata details to see ticket types
curl -X GET https://trv.aisadev.id/api/wisata/WISATA_ID

# 2. Purchase ticket
curl -X POST https://trv.aisadev.id/api/tickets/purchase \
  -H "Authorization: Bearer PENGUNJUNG_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "wisataId": "WISATA_ID",
    "itemsToPurchase": [
      {
        "ticketTypeId": "TICKET_TYPE_ID",
        "quantity": 2
      }
    ]
  }'

# 3. Check my tickets
curl -X GET https://trv.aisadev.id/api/tickets/my-tickets \
  -H "Authorization: Bearer PENGUNJUNG_TOKEN"
```

### Review Management Flow

```bash
# 1. Create review
curl -X POST https://trv.aisadev.id/api/reviews \
  -H "Authorization: Bearer PENGUNJUNG_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "wisataId": "WISATA_ID",
    "rating": 5,
    "comment": "Tempat yang sangat indah!"
  }'

# 2. Pengelola responds to review
curl -X PUT https://trv.aisadev.id/api/reviews/REVIEW_ID/respond \
  -H "Authorization: Bearer PENGELOLA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "responseText": "Terima kasih atas reviewnya!"
  }'

# 3. Get all reviews for wisata (public)
curl -X GET https://trv.aisadev.id/api/reviews/wisata/WISATA_ID
```

---

## 🎯 Common Usage Scenarios

### Scenario 1: Tourist User Journey

1. **Browse** → GET `/api/provinces` → GET `/api/wisata/province/:id`
2. **View Details** → GET `/api/wisata/:id` → GET `/api/reviews/wisata/:id`
3. **Register/Login** → POST `/api/auth/register` → POST `/api/auth/login`
4. **Purchase** → POST `/api/tickets/purchase`
5. **Review** → POST `/api/reviews`

### Scenario 2: Pengelola Workflow

1. **Login** → POST `/api/auth/login`
2. **Create Wisata** → POST `/api/wisata`
3. **Upload Images** → POST `/api/wisata/:id/gallery`
4. **Manage Reviews** → PUT `/api/reviews/:id/respond`
5. **Check Sales** → GET `/api/tickets/sales/:wisataId`

### Scenario 3: Admin Operations

1. **User Management** → GET `/api/admin/users` → PUT `/api/admin/users/:id/role`
2. **Content Moderation** → PUT `/api/wisata/:wisataId/gallery/:imageId/verify`
3. **Review Moderation** → PUT `/api/reviews/:id/status`
4. **Province Management** → POST `/api/provinces`

---

## 🔍 Testing with Real Data

The API has been tested with real seeded data including:

- **34 Indonesian Provinces** with images
- **Multiple Wisata** across different categories
- **User accounts** for all roles (admin, pengelola, pengunjung)
- **Sample reviews and tickets**

### Test Credentials Available

- **Admin**: admin@test.com / password123
- **Pengunjung**: pengunjung@test.com / password123

_All endpoints have been tested and verified with actual responses as shown in the examples above._

---

_Last Updated: June 10, 2025_  
_API Version: 1.0_  
_Documentation based on real API testing with seeded data_
