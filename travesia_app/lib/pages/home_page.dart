import 'package:flutter/material.dart';
import 'package:travesia_app/models/province.dart';
import 'package:travesia_app/models/wisata.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/province_service.dart';
import 'package:travesia_app/services/wisata_service.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final ProvinceService provinceService;
  final WisataService wisataService;

  const HomePage({
    Key? key,
    required this.authService,
    required this.provinceService,
    required this.wisataService,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> _provinces = [];
  bool _isLoadingProvinces = true;
  String? _errorProvinces;

  List<Wisata> _wisataList = [];
  bool _isLoadingWisata = true;
  String? _errorWisata;

  // bool _isLoggingOut = false; // REMOVED - Logout is now in ProfilePage

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchProvinces(),
      _fetchWisata(),
    ]);
  }

  Future<void> _fetchProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
      _errorProvinces = null;
    });
    try {
      final provinces = await widget.provinceService.getAllProvinces();
      if (mounted) {
        setState(() {
          _provinces = provinces;
          _isLoadingProvinces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorProvinces = "Failed to load provinces: ${e.toString()}";
          _isLoadingProvinces = false;
        });
      }
    }
  }

  Future<void> _fetchWisata() async {
    setState(() {
      _isLoadingWisata = true;
      _errorWisata = null;
    });
    try {
      // Assuming getAllWisata() might take parameters like page, limit in future
      // For now, let's call it without params, or with defaults if needed by service
      final wisata = await widget.wisataService.getAllWisata();
      if (mounted) {
        setState(() {
          _wisataList = wisata;
          _isLoadingWisata = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorWisata = "Failed to load wisata: ${e.toString()}";
          _isLoadingWisata = false;
        });
      }
    }
  }

  // Future<void> _logout() async { ... } // REMOVED - Logout logic moved to ProfilePage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travesia'), 
        // Removed actions (logout button) from here
        // actions: [ ... ], 
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            _buildSectionTitle(context, 'Explore Provinces'),
            _buildProvinceSection(),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Popular Destinations'),
            _buildWisataSection(),
            const SizedBox(height: 20),
             Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('My Profile'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/my-tickets'),
                    child: const Text('My Tickets'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProvinceSection() {
    if (_isLoadingProvinces) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    }
    if (_errorProvinces != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(_errorProvinces!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _fetchProvinces, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }
    if (_provinces.isEmpty) {
      return const Center(child: Text('No provinces found.'));
    }

    return SizedBox(
      height: 150, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _provinces.length,
        itemBuilder: (context, index) {
          final province = _provinces[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                // TODO: Implement navigation to province specific wisata list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on ${province.nama}')),
                );
              },
              child: Container(
                width: 120, // Adjust card width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: (province.gambarUrl != null && province.gambarUrl!.isNotEmpty)
                          ? Image.network(
                              province.gambarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, size: 40)),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ));
                              },
                            )
                          : const Center(child: Icon(Icons.map, size: 40, color: Colors.grey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        province.nama ?? 'Unnamed Province',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWisataSection() {
    if (_isLoadingWisata) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    }
    if (_errorWisata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(_errorWisata!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _fetchWisata, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }
    if (_wisataList.isEmpty) {
      return const Center(child: Text('No wisata destinations found.'));
    }

    // Using ListView for vertical scrolling; GridView could be an alternative
    return ListView.builder(
      shrinkWrap: true, // Important when ListView is inside another ListView
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this inner ListView
      itemCount: _wisataList.length,
      itemBuilder: (context, index) {
        final wisata = _wisataList[index];
        String? imageUrl;
        if (wisata.gambar != null && wisata.gambar!.isNotEmpty) {
            imageUrl = wisata.gambar![0].url; // Assuming first image is primary
        }


        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (wisata.id != null) {
                Navigator.pushNamed(context, '/wisata-detail', arguments: wisata.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Wisata ID is not available.')),
                );
              }
            },
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.broken_image, size: 50)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ));
                          },
                        )
                      : const Center(child: Icon(Icons.place, size: 50, color: Colors.grey)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wisata.nama ?? 'Unnamed Wisata',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wisata.lokasi?.nama ?? 'Unknown location',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // You could add rating here if available: e.g., Row with Icon(Icons.star) and Text
                        // Text('Rating: ${wisata.rating ?? 'N/A'}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
