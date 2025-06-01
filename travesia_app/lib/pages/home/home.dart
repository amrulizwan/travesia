import 'package:flutter/material.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/pages/auth/login.dart';
import 'package:travesia_app/utils/alert_utils.dart';
import 'package:travesia_app/pages/wisata/wisata_list_page.dart'; // Import WisataListPage
import 'package:travesia_app/pages/ticket/my_tickets_page.dart'; // Import MyTicketsPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imageUrls = [
    'assets/images/slide1.png',
    'assets/images/slide2.png',
    'assets/images/slide3.jpg',
  ];

  final List<Map<String, String>> destinations = [
    {'name': 'Lombok', 'image': 'assets/images/slide1.png'},
    {'name': 'Bali', 'image': 'assets/images/slide2.png'},
    {'name': 'Jawa', 'image': 'assets/images/slide3.png'},
    {'name': 'Sumatera', 'image': 'assets/images/lombok.png'},
    {'name': 'Aceh', 'image': 'assets/images/nyale.png'},
    {'name': 'NTB', 'image': 'assets/images/sembalun.png'},
    {'name': 'Sumbawa', 'image': 'assets/images/slide1.png'},
  ];

  // New item for navigating to WisataListPage
  final Map<String, dynamic> _allWisataNavigationItem = {
    'name': 'Semua Wisata',
    'icon': Icons.tour_outlined,
  };

  final Map<String, dynamic> _myTicketsNavigationItem = {
    'name': 'Tiket Saya',
    'icon': Icons.confirmation_number_outlined,
  };

  AuthService? _authService;
  bool _isLoading = false;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getUserData();
    _initializeAuthService();
  }

  Future<void> _initializeAuthService() async {
    _authService = await AuthService.init();
  }

  Future<void> _handleLogout() async {
    if (_authService == null) {
      await _initializeAuthService();
    }

    setState(() => _isLoading = true);

    try {
      await _authService?.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void getUserData() async {
    if (_authService == null) {
      await _initializeAuthService();
    }

    setState(() => _isLoading = true);

    try {
      final userData = await _authService?.getUserInfo();
      if (userData != null) {
        setState(() {
          this.userData = userData;
        });
      } else {
        AlertUtils.showWarning(context, "Sesi anda habis,Silahkan Login!");
        await _handleLogout();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PopupMenuButton(
                            offset: const Offset(0, 40),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.person),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  userData.isNotEmpty
                                      ? userData['nama'] ?? 'User'
                                      : 'User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings, size: 20),
                                    SizedBox(width: 8),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, size: 20),
                                    SizedBox(width: 8),
                                    Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              switch (value) {
                                case 'settings':
                                  break;
                                case 'logout':
                                  await _handleLogout();
                                  break;
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 170,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(imageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.all(4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0 ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: destinations.length + 3, // +1 More, +1 Semua Wisata, +1 Tiket Saya
                        itemBuilder: (context, index) {
                          if (index == 0) { // "Semua Wisata"
                            return _buildGridNavigationItem(
                              _allWisataNavigationItem['name'] as String,
                              _allWisataNavigationItem['icon'] as IconData,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WisataListPage())),
                            );
                          }
                          if (index == 1) { // "Tiket Saya"
                            return _buildGridNavigationItem(
                              _myTicketsNavigationItem['name'] as String,
                              _myTicketsNavigationItem['icon'] as IconData,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTicketsPage())),
                            );
                          }

                          // Adjust index for destinations and "More" button
                          final itemIndex = index - 2;

                          if (itemIndex == destinations.length) { // "More" button
                            return InkWell(
                              onTap: () { /* TODO: Implement 'More' functionality */ },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.grid_view, color: Colors.black54),
                                    SizedBox(height: 4),
                                    Text('More', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            );
                          }
                          // Regular destination items
                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(destinations[itemIndex]['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destinations[itemIndex]['name']!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16), // Added spacing before articles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Article',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/slide1.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                            ),
                            // child: const Center(
                            //   child: Text('Festival bau nyale, harga nyale mahal...'),
                            // ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/slide3.png'),
                                fit: BoxFit.fitWidth,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                            ),
                            // child: const Center(
                            //   child: Text('Jalur di Sambalun sudah bagus, pemda...'),
                            // ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper widget for grid navigation items for cleaner code
  Widget _buildGridNavigationItem(String name, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red, size: 30),
            const SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
