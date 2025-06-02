import 'package:flutter/material.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/pages/auth/login.dart';
import 'package:travesia_app/utils/alert_utils.dart';
import 'package:travesia_app/pages/wisata/wisata_list_page.dart'; // Import WisataListPage
import 'package:travesia_app/pages/ticket/my_tickets_page.dart'; // Import MyTicketsPage
import '../../models/province.dart';
import '../../services/province_service.dart';
import '../../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProvinceService _provinceService;
  late Future<List<Province>> _provincesFuture;
  bool _isLoading = false;

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

  late AuthService _authService;
  Map<String, dynamic> userData = {};

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeAndGetData();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });

    final apiService = ApiService();
    _provinceService = ProvinceService(apiService);
    _fetchProvinces();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndGetData() async {
    _authService = await AuthService.init();
    await getUserData();
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      await _authService.logout();
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

  Future<void> getUserData() async {
    setState(() => _isLoading = true);

    try {
      final userData = await _authService.getUserInfo();
      if (userData != null) {
        setState(() {
          this.userData = userData;
        });
      } else {
        if (!mounted) return;
        AlertUtils.showWarning(context, "Sesi anda habis, Silahkan Login!");
        await _handleLogout();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchProvinces() async {
    setState(() => _isLoading = true);
    _provincesFuture = _provinceService.getAllProvinces();
    setState(() => _isLoading = false);
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
                        controller: _pageController,
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
                            color: index == _currentPage
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<List<Province>>(
                        future: _provincesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(color: Colors.red),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    ElevatedButton(
                                      onPressed: _fetchProvinces,
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final provinces = snapshot.data ?? [];

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount:
                                provinces.length + 1, // +1 for More button
                            itemBuilder: (context, index) {
                              if (index == provinces.length) {
                                // "More" button
                                return InkWell(
                                  onTap: () {
                                    /* TODO: Implement 'More' functionality */
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.grid_view,
                                            color: Colors.black54),
                                        SizedBox(height: 4),
                                        Text('More',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final province = provinces[index];
                              return Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(province.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    province.name,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
  Widget _buildGridNavigationItem(
      String name, IconData icon, VoidCallback onTap) {
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

  Widget _buildProvinceCard(Province province) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to province detail or wisata list filtered by province
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WisataListPage(provinceId: province.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  province.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    province.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kode: ${province.code}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
