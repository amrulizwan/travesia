import fetch from 'node-fetch';
import fs from 'fs';

const BASE_URL = 'https://trv.aisadev.id/api';

// Output file for saving results
const outputFile = 'api-test-results.json';
let allResults = [];

// Test credentials (will be obtained from seeded data)
let adminToken = '';
let pengelolaToken = '';
let pengunjungToken = '';
let testIds = {
  adminId: '',
  pengelolaId: '',
  pengunjungId: '',
  wisataId: '',
  provinceId: '',
  reviewId: '',
  ticketId: '',
};

// Helper function to make API calls
async function apiCall(method, endpoint, data = null, token = null, isFormData = false) {
  const headers = {
    'Content-Type': isFormData ? undefined : 'application/json',
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const options = {
    method,
    headers,
  };

  if (data) {
    if (isFormData) {
      options.body = data;
    } else {
      options.body = JSON.stringify(data);
    }
  }

  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, options);
    const result = await response.json();

    const testResult = {
      method,
      endpoint,
      status: response.status,
      request: data,
      response: result,
      timestamp: new Date().toISOString(),
    };

    allResults.push(testResult);

    console.log(`\n=== ${method} ${endpoint} ===`);
    console.log(`Status: ${response.status}`);
    console.log('Response:');
    console.log(JSON.stringify(result, null, 2));

    return { status: response.status, data: result };
  } catch (error) {
    const errorResult = {
      method,
      endpoint,
      status: 500,
      request: data,
      error: error.message,
      timestamp: new Date().toISOString(),
    };

    allResults.push(errorResult);

    console.error(`Error calling ${method} ${endpoint}:`, error.message);
    return { status: 500, error: error.message };
  }
}

// Test Authentication Endpoints
async function testAuthEndpoints() {
  console.log('\n🔐 TESTING AUTHENTICATION ENDPOINTS');

  // 1. Register Admin (for testing - normally done via seeder)
  await apiCall('POST', '/auth/register', {
    nama: 'Test Admin',
    email: 'admin@test.com',
    password: 'password123',
    telepon: '081234567890',
    role: 'admin',
  });

  // 2. Register Pengelola
  await apiCall('POST', '/auth/register', {
    nama: 'Test Pengelola',
    email: 'pengelola@test.com',
    password: 'password123',
    telepon: '081234567891',
    role: 'pengelola',
  });

  // 3. Register Pengunjung
  await apiCall('POST', '/auth/register', {
    nama: 'Test Pengunjung',
    email: 'pengunjung@test.com',
    password: 'password123',
    telepon: '081234567892',
    role: 'pengunjung',
  });

  // 4. Login Admin
  const adminLogin = await apiCall('POST', '/auth/login', {
    email: 'admin@test.com',
    password: 'password123',
  });
  if (adminLogin.data && adminLogin.data.token) {
    adminToken = adminLogin.data.token;
    testIds.adminId = adminLogin.data.user.id;
  }

  // 5. Login Pengelola
  const pengelolaLogin = await apiCall('POST', '/auth/login', {
    email: 'pengelola@test.com',
    password: 'password123',
  });
  if (pengelolaLogin.data && pengelolaLogin.data.token) {
    pengelolaToken = pengelolaLogin.data.token;
    testIds.pengelolaId = pengelolaLogin.data.user.id;
  }

  // 6. Login Pengunjung
  const pengunjungLogin = await apiCall('POST', '/auth/login', {
    email: 'pengunjung@test.com',
    password: 'password123',
  });
  if (pengunjungLogin.data && pengunjungLogin.data.token) {
    pengunjungToken = pengunjungLogin.data.token;
    testIds.pengunjungId = pengunjungLogin.data.user.id;
  }

  // 7. Get Profile (Admin)
  await apiCall('GET', '/auth/profile', null, adminToken);

  // 8. Update Profile
  await apiCall(
    'PUT',
    '/auth/profile',
    {
      nama: 'Updated Admin Name',
      telepon: '081234567899',
    },
    adminToken
  );

  // 9. Request Password Reset
  await apiCall('POST', '/auth/request-reset-password', {
    email: 'admin@test.com',
  });

  console.log('\nTokens obtained:');
  console.log('Admin Token:', adminToken ? 'OK' : 'FAILED');
  console.log('Pengelola Token:', pengelolaToken ? 'OK' : 'FAILED');
  console.log('Pengunjung Token:', pengunjungToken ? 'OK' : 'FAILED');
}

// Test Province Endpoints
async function testProvinceEndpoints() {
  console.log('\n🗺️ TESTING PROVINCE ENDPOINTS');

  // 1. Get All Provinces (Public)
  const provinces = await apiCall('GET', '/provinces');
  if (provinces.data && provinces.data.data && provinces.data.data.length > 0) {
    testIds.provinceId = provinces.data.data[0].id;
  }

  // 2. Add Province (Admin only) - Need to create FormData for file upload
  // For now, test without file upload
  await apiCall(
    'POST',
    '/provinces',
    {
      name: 'Test Province',
      code: 'TP',
    },
    adminToken
  );

  // 3. Update Province
  if (testIds.provinceId) {
    await apiCall(
      'PUT',
      `/provinces/${testIds.provinceId}`,
      {
        name: 'Updated Province Name',
      },
      adminToken
    );
  }
}

// Test Wisata Endpoints
async function testWisataEndpoints() {
  console.log('\n🏞️ TESTING WISATA ENDPOINTS');

  // 1. Get All Wisata (Public)
  const wisatas = await apiCall('GET', '/wisata');
  if (wisatas.data && wisatas.data.data && wisatas.data.data.length > 0) {
    testIds.wisataId = wisatas.data.data[0].id;
  }

  // 2. Get Wisata by ID
  if (testIds.wisataId) {
    await apiCall('GET', `/wisata/${testIds.wisataId}`);
  }

  // 3. Get Wisata by Province
  if (testIds.provinceId) {
    await apiCall('GET', `/wisata/province/${testIds.provinceId}`);
  }

  // 4. Create Wisata (Admin)
  const createWisata = await apiCall(
    'POST',
    '/wisata',
    {
      nama: 'Test Wisata API',
      deskripsi: 'Wisata test dari API testing',
      lokasi: {
        alamat: 'Jl. Test API No. 1',
        koordinat: {
          lat: -8.123,
          lng: 116.456,
        },
      },
      ticketTypes: [
        {
          name: 'Umum',
          price: 50000,
        },
      ],
      provinceId: testIds.provinceId,
      jamOperasional: {
        buka: '08:00',
        tutup: '17:00',
      },
      kontak: {
        telepon: '081234567890',
        email: 'info@testwisata.com',
      },
    },
    adminToken
  );

  if (createWisata.data && createWisata.data.data) {
    testIds.wisataId = createWisata.data.data.id || createWisata.data.data._id;
  }

  // 5. Update Wisata
  if (testIds.wisataId) {
    await apiCall(
      'PUT',
      `/wisata/${testIds.wisataId}`,
      {
        nama: 'Updated Test Wisata',
        deskripsi: 'Updated description',
      },
      adminToken
    );
  }

  // 6. Change Wisata Pengelola (Admin only)
  if (testIds.wisataId && testIds.pengelolaId) {
    await apiCall(
      'PUT',
      `/wisata/${testIds.wisataId}/assign-pengelola`,
      {
        newPengelolaId: testIds.pengelolaId,
      },
      adminToken
    );
  }
}

// Test Admin User Management Endpoints
async function testAdminEndpoints() {
  console.log('\n👑 TESTING ADMIN USER MANAGEMENT ENDPOINTS');

  // 1. List All Users
  await apiCall('GET', '/admin/users', null, adminToken);

  // 2. List Users with pagination and filter
  await apiCall('GET', '/admin/users?page=1&limit=5&role=pengunjung', null, adminToken);

  // 3. Get User Details
  if (testIds.pengunjungId) {
    await apiCall('GET', `/admin/users/${testIds.pengunjungId}`, null, adminToken);
  }

  // 4. Update User Role
  if (testIds.pengunjungId) {
    await apiCall(
      'PUT',
      `/admin/users/${testIds.pengunjungId}/role`,
      {
        role: 'pengelola',
      },
      adminToken
    );
  }

  // 5. Manage User Account Status
  if (testIds.pengunjungId) {
    await apiCall(
      'PUT',
      `/admin/users/${testIds.pengunjungId}/status`,
      {
        statusAkun: 'nonaktif',
      },
      adminToken
    );
  }
}

// Test Review Endpoints
async function testReviewEndpoints() {
  console.log('\n⭐ TESTING REVIEW ENDPOINTS');

  // 1. Create Review (Pengunjung)
  const createReview = await apiCall(
    'POST',
    '/reviews',
    {
      wisataId: testIds.wisataId,
      rating: 5,
      comment: 'Tempat yang sangat indah! Recommended banget.',
    },
    pengunjungToken
  );

  if (createReview.data && createReview.data.data) {
    testIds.reviewId = createReview.data.data.id || createReview.data.data._id;
  }

  // 2. Get Reviews for Wisata (Public)
  if (testIds.wisataId) {
    await apiCall('GET', `/reviews/wisata/${testIds.wisataId}`);
  }

  // 3. Get My Reviews (Pengunjung)
  await apiCall('GET', '/reviews/my-reviews', null, pengunjungToken);

  // 4. Get Review by ID
  if (testIds.reviewId) {
    await apiCall('GET', `/reviews/${testIds.reviewId}`);
  }

  // 5. Update Review (Pengunjung)
  if (testIds.reviewId) {
    await apiCall(
      'PUT',
      `/reviews/${testIds.reviewId}`,
      {
        rating: 4,
        comment: 'Updated review - masih bagus tapi ada yang bisa diperbaiki',
      },
      pengunjungToken
    );
  }

  // 6. Pengelola Respond to Review
  if (testIds.reviewId) {
    await apiCall(
      'PUT',
      `/reviews/${testIds.reviewId}/respond`,
      {
        responseText: 'Terima kasih atas reviewnya! Kami akan terus meningkatkan pelayanan.',
      },
      pengelolaToken
    );
  }

  // 7. Admin Set Review Status
  if (testIds.reviewId) {
    await apiCall(
      'PUT',
      `/reviews/${testIds.reviewId}/status`,
      {
        status: 'approved',
      },
      adminToken
    );
  }
}

// Test Ticket Endpoints
async function testTicketEndpoints() {
  console.log('\n🎫 TESTING TICKET ENDPOINTS');

  // 1. Purchase Ticket (Pengunjung)
  if (testIds.wisataId) {
    // First, get wisata details to get ticket type ID
    const wisataDetails = await apiCall('GET', `/wisata/${testIds.wisataId}`);
    if (wisataDetails.data && wisataDetails.data.data && wisataDetails.data.data.ticketTypes) {
      const ticketTypeId = wisataDetails.data.data.ticketTypes[0]._id || wisataDetails.data.data.ticketTypes[0].id;

      const purchaseTicket = await apiCall(
        'POST',
        '/tickets/purchase',
        {
          wisataId: testIds.wisataId,
          itemsToPurchase: [
            {
              ticketTypeId: ticketTypeId,
              quantity: 2,
            },
          ],
        },
        pengunjungToken
      );
    }
  }

  // 2. Get My Tickets (Pengunjung)
  await apiCall('GET', '/tickets/my-tickets', null, pengunjungToken);

  // 3. Get Sales by Wisata (Admin/Pengelola)
  if (testIds.wisataId) {
    await apiCall('GET', `/tickets/sales/${testIds.wisataId}`, null, adminToken);
  }
}

// Main test function
async function runAllTests() {
  console.log('🚀 STARTING API ENDPOINT TESTING');
  console.log('Base URL:', BASE_URL);
  console.log('='.repeat(50));

  try {
    // Test all endpoints in sequence
    await testAuthEndpoints();
    await testProvinceEndpoints();
    await testWisataEndpoints();
    await testAdminEndpoints();
    await testReviewEndpoints();
    await testTicketEndpoints(); // Save test IDs for future reference
    fs.writeFileSync('test-ids.json', JSON.stringify(testIds, null, 2));

    // Save all API results
    fs.writeFileSync(outputFile, JSON.stringify(allResults, null, 2));

    console.log('\n✅ All tests completed!');
    console.log('Test IDs saved to test-ids.json');
    console.log(`API results saved to ${outputFile}`);
  } catch (error) {
    console.error('❌ Test failed:', error);
    // Save results even if failed
    fs.writeFileSync(outputFile, JSON.stringify(allResults, null, 2));
  }
}

// Run the tests
runAllTests();
