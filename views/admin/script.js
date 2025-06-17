document.addEventListener('DOMContentLoaded', function() {
    // Function to get the JWT token (replace with actual token retrieval)
    function getAuthToken() {
        // For now, using a placeholder. In a real app, this would come from localStorage, cookies, etc.
        // after admin login. The API docs mention: admin@test.com / password123
        // This token is an EXAMPLE and WILL EXPIRE.
        // You'd typically get this after a login API call.
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NDczNWM5ZDhkZmQ4ZGFlODZkMzBlZiIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc0OTQ5NzM2MCwiZXhwIjoxNzUwMTAyMTYwfQ.zLlMmPcI8DQdC2n3XRc3-vYufzox2NgmSuRn_aAAWhs';
    }

    // Base URL for the API
    const API_BASE_URL = 'https://trv.aisadev.id/api';

    // Function to fetch data from the API
    async function fetchData(endpoint, params = {}) {
        const token = getAuthToken();
        let url = `${API_BASE_URL}${endpoint}`;

        if (Object.keys(params).length > 0) {
            url += '?' + new URLSearchParams(params).toString();
        }

        try {
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            if (!response.ok) {
                console.error(`API Error: ${response.status} - ${response.statusText}`);
                const errorData = await response.json().catch(() => null);
                console.error('Error details:', errorData);
                return null;
            }
            return await response.json();
        } catch (error) {
            console.error('Fetch error:', error);
            return null;
        }
    }

    // --- Dashboard Summary Population ---
    if (document.getElementById('total-users')) {
        // Fetch total users
        fetchData('/admin/users', { limit: 1 }).then(data => {
            if (data && data.totalUsers !== undefined) {
                document.getElementById('total-users').textContent = data.totalUsers;
            } else {
                document.getElementById('total-users').textContent = 'N/A';
                console.error('Failed to fetch total users or data format incorrect:', data);
            }
        });
    }

    if (document.getElementById('total-provinces')) {
        // Fetch total provinces (API doesn't have a count, so fetch all and count)
        // Note: This is not ideal for large datasets. API should provide counts.
        fetchData('/provinces').then(data => {
            if (data && data.data && Array.isArray(data.data)) {
                document.getElementById('total-provinces').textContent = data.data.length;
            } else {
                document.getElementById('total-provinces').textContent = 'N/A';
                console.error('Failed to fetch provinces or data format incorrect:', data);
            }
        });
    }

    if (document.getElementById('total-wisata')) {
        // Fetch total wisata (API doesn't have a count for all wisata, only by province or all *published*)
        // Assuming '/api/wisata' gets all for admin, or we count published ones.
        // For a true admin count, a dedicated endpoint or admin version of /api/wisata would be better.
        // Let's use the public one for now and assume it's sufficient for a summary.
        fetchData('/wisata').then(data => {
            if (data && data.data && Array.isArray(data.data)) {
                document.getElementById('total-wisata').textContent = data.data.length;
            } else {
                document.getElementById('total-wisata').textContent = 'N/A';
                console.error('Failed to fetch wisata or data format incorrect:', data);
            }
        });
    }

    if (document.getElementById('pending-reviews')) {
        // Fetch pending reviews (API needs filtering for 'pending' status, not directly available)
        // The `/api/reviews/wisata/:wisataId` gets approved reviews.
        // `/api/reviews/:reviewId/status` is for admin to *set* status.
        // This requires an admin endpoint to list reviews by status.
        // For now, we'll put a placeholder.
        // A more robust solution would be an endpoint like /api/admin/reviews?status=pending
        fetchData('/admin/reviews', { status: 'pending', limit: 1 }).then(data => { // Hypothetical endpoint
            if (data && data.totalReviews !== undefined) { // Assuming it might return totalReviews for pending
                document.getElementById('pending-reviews').textContent = data.totalReviews;
            } else {
                 // Fallback: Fetch all reviews for a specific known wisata and count pending ones manually
                 // This is highly inefficient and not scalable.
                 // For now, display N/A due to lack of a direct endpoint.
                document.getElementById('pending-reviews').textContent = 'N/A';
                console.warn('No direct API endpoint for pending reviews count. Displaying N/A.');
            }
        });
    }

    // --- Navigation Active State ---
    // Sets the active class on the current page's navigation link
    const currentPage = window.location.pathname.split('/').pop();
    if (currentPage) {
        const navLinks = document.querySelectorAll('nav ul li a');
        navLinks.forEach(link => {
            if (link.getAttribute('href') === currentPage) {
                link.classList.add('active');
            }
        });
    }


    // --- Placeholder for User Management Page ---
    if (window.location.pathname.endsWith('users.html')) {
        // loadUsers();
        console.log("User management page specific script would run here.");
    }

    // --- Placeholder for Province Management Page ---
    if (window.location.pathname.endsWith('provinces.html')) {
        // loadProvinces();
        console.log("Province management page specific script would run here.");
    }

    // --- Placeholder for Wisata Management Page ---
    if (window.location.pathname.endsWith('wisata.html')) {
        // loadWisata();
        console.log("Wisata management page specific script would run here.");
    }

    // --- Placeholder for Review Management Page ---
    if (window.location.pathname.endsWith('reviews.html')) {
        // loadReviews();
        console.log("Review management page specific script would run here.");
    }

});

// Example function to load users (to be implemented)
async function loadUsers() {
    // const usersData = await fetchData('/admin/users');
    // if (usersData && usersData.data) {
    //     const userTableBody = document.getElementById('user-table-body'); // Assuming a table exists
    //     userTableBody.innerHTML = ''; // Clear existing rows
    //     usersData.data.forEach(user => {
    //         const row = userTableBody.insertRow();
    //         row.insertCell().textContent = user.nama;
    //         row.insertCell().textContent = user.email;
    //         row.insertCell().textContent = user.role;
    //         row.insertCell().textContent = user.statusAkun;
    //         // Add action buttons (edit, delete, change role)
    //     });
    // }
}
