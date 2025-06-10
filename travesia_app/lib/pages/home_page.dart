import 'package:flutter/material.dart';
import 'package:travesia_app/utils/app_theme.dart';
import 'package:travesia_app/utils/custom_widgets.dart';
import 'package:travesia_app/models/province.dart';
import 'package:travesia_app/models/wisata.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/province_service.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:travesia_app/services/ticket_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final ProvinceService provinceService;
  final WisataService wisataService;
  final ReviewService reviewService;
  final TicketService ticketService;

  const HomePage({
    super.key,
    required this.authService,
    required this.provinceService,
    required this.wisataService,
    required this.reviewService,
    required this.ticketService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> _provinces = [];
  List<Wisata> _featuredWisata = [];
  List<Wisata> _popularWisata = [];
  bool _isLoading = true;
  String? _userName;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load user profile
      final profile = await widget.authService.getProfile();
      _userName = profile['user']['nama'];

      // Load provinces and wisata
      final provinces = await widget.provinceService.getProvinces();
      final allWisata = await widget.wisataService.getAllWisata();

      setState(() {
        _provinces = provinces.take(6).toList(); // Show only 6 provinces
        _featuredWisata = allWisata.take(5).toList(); // Featured carousel
        _popularWisata = allWisata.skip(5).take(10).toList(); // Popular list
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (_isLoading) 
                  _buildLoadingState()
                else ...[
                  _buildFeaturedSection(),
                  _buildQuickStats(),
                  _buildProvincesSection(),
                  _buildPopularSection(),
                ],
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      _userName ?? 'Traveler',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Jelajahi keindahan Indonesia',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        onTap: () {
          // Navigate to explore page with search focus
          DefaultTabController.of(context)?.animateTo(1);
        },
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Cari destinasi wisata...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.grey),
          suffixIcon: const Icon(Icons.tune_rounded, color: AppTheme.primaryOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    if (_featuredWisata.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Destinasi Pilihan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: _featuredWisata.length,
          itemBuilder: (context, index, realIndex) {
            final wisata = _featuredWisata[index];
            return _buildFeaturedCard(wisata);
          },
          options: CarouselOptions(
            height: 240,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() => _carouselIndex = index);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _featuredWisata.asMap().entries.map((entry) {
            return Container(
              width: _carouselIndex == entry.key ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _carouselIndex == entry.key 
                    ? AppTheme.primaryOrange 
                    : AppTheme.grey.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Wisata wisata) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/wisata-detail', arguments: wisata.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              wisata.galeri.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: wisata.galeri.first.url,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.lightGrey,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.lightGrey,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: AppTheme.grey,
                      ),
                    ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisata.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.white,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            wisata.lokasi.alamat,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (wisata.ticketTypes.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mulai Rp ${wisata.ticketTypes.first.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.location_city_rounded,
              title: '${_provinces.length}+',
              subtitle: 'Provinsi',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.explore_rounded,
              title: '${_featuredWisata.length + _popularWisata.length}+',
              subtitle: 'Destinasi',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              title: '4.8',
              subtitle: 'Rating',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryOrange,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvincesSection() {
    if (_provinces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jelajahi Provinsi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to explore page
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _provinces.length,
            itemBuilder: (context, index) {
              final province = _provinces[index];
              return _buildProvinceCard(province);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceCard(Province province) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: CustomWidgets.modernCard(
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.zero,
        onTap: () {
          Navigator.pushNamed(context, '/province-wisata', arguments: province.id);
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: province.image,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 60,
                  width: 60,
                  color: AppTheme.lightGrey,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 60,
                  width: 60,
                  color: AppTheme.lightGrey,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              province.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection() {
    if (_popularWisata.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Destinasi Popular',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _popularWisata.length.clamp(0, 3), // Show only 3
          itemBuilder: (context, index) {
            final wisata = _popularWisata[index];
            return _buildPopularCard(wisata);
          },
        ),
      ],
    );
  }

  Widget _buildPopularCard(Wisata wisata) {
    return CustomWidgets.modernCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () {
        Navigator.pushNamed(context, '/wisata-detail', arguments: wisata.id);
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: wisata.galeri.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: wisata.galeri.first.url,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 80,
                      width: 80,
                      color: AppTheme.lightGrey,
                    ),
                  )
                : Container(
                    height: 80,
                    width: 80,
                    color: AppTheme.lightGrey,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wisata.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  wisata.lokasi.alamat,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wisata.kategori,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepOrange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (wisata.ticketTypes.isNotEmpty)
                      CustomWidgets.priceTag(
                        price: 'Rp ${wisata.ticketTypes.first.price}',
                        fontSize: 14,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Featured loading
        const SizedBox(height: 20),
        CustomWidgets.shimmerContainer(
          width: double.infinity,
          height: 240,
          borderRadius: 20,
        ),
        
        // Stats loading
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: CustomWidgets.shimmerContainer(width: 100, height: 80)),
            const SizedBox(width: 12),
            Expanded(child: CustomWidgets.shimmerContainer(width: 100, height: 80)),
            const SizedBox(width: 12),
            Expanded(child: CustomWidgets.shimmerContainer(width: 100, height: 80)),
          ],
        ),
        
        // List loading
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CustomWidgets.shimmerContainer(width: 80, height: 80),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidgets.shimmerContainer(width: 200, height: 16),
                        const SizedBox(height: 8),
                        CustomWidgets.shimmerContainer(width: 150, height: 14),
                        const SizedBox(height: 8),
                        CustomWidgets.shimmerContainer(width: 100, height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
