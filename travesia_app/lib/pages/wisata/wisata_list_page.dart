import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../models/wisata.dart';
import '../../services/api_service.dart';
import '../../services/wisata_service.dart';
import 'wisata_detail_page.dart'; // Import WisataDetailPage

class WisataListPage extends StatefulWidget {
  final String? provinceId;

  const WisataListPage({super.key, this.provinceId});

  @override
  State<WisataListPage> createState() => _WisataListPageState();
}

class _WisataListPageState extends State<WisataListPage> {
  late final WisataService _wisataService;
  late Future<List<Wisata>> _wisataListFuture;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // In a real app, ApiService might be provided via DI (Provider, GetIt, etc.)
    final ApiService apiService = ApiService();
    _wisataService = WisataService(apiService);
    _fetchWisata();
  }

  Future<void> _fetchWisata() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (widget.provinceId != null) {
        // Add province filter to the API call
        _wisataListFuture = _wisataService.getWisataByProvince(widget.provinceId!);
      } else {
        _wisataListFuture = _wisataService.getAllWisata();
      }
      await _wisataListFuture;
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Wisata', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        elevation: 2.0,
        iconTheme: const IconThemeData(color: Colors.white), // For back button, if applicable
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWisata,
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _errorMessage == null) { // Initial loading
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    // Subsequent loading or error states will be handled by FutureBuilder
    // or if initial load failed, _errorMessage will be set.

    return FutureBuilder<List<Wisata>>(
      future: _wisataListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
          // This covers cases where future is re-triggered by refresh button
           return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (snapshot.hasError || _errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error ?? _errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchWisata,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak ada data wisata yang tersedia.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchWisata,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          );
        }

        final wisataList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: wisataList.length,
          itemBuilder: (context, index) {
            final wisata = wisataList[index];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WisataDetailPage(wisataId: wisata.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display image if available (first from gallery or a placeholder)
                      if (wisata.gallery.isNotEmpty && wisata.gallery.first.urlGambar.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            wisata.gallery.first.urlGambar,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                              ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.location_city, color: Colors.grey, size: 60),
                        ),
                      const SizedBox(height: 12.0),
                      Text(
                        wisata.nama,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        wisata.deskripsi.length > 100
                            ? '${wisata.deskripsi.substring(0, 100)}...'
                            : wisata.deskripsi,
                        style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red[400], size: 16.0),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              wisata.alamat, // Or wisata.lokasi.nama if preferred and available
                              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      if (wisata.averageRating != null && wisata.averageRating! > 0)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(
                              wisata.averageRating!.toStringAsFixed(1),
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '(${wisata.reviews.length} reviews)',
                              style: TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WisataDetailPage(wisataId: wisata.id),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Placeholder for CustomAppBar if not already defined
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   const CustomAppBar({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       backgroundColor: Colors.red,
//       elevation: 2.0,
//       iconTheme: IconThemeData(color: Colors.white),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
