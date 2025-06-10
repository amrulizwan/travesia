import 'package:flutter/material.dart';
import 'package:travesia_app/utils/app_theme.dart';
import 'package:travesia_app/utils/custom_widgets.dart';
import 'package:travesia_app/models/user.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  final ReviewService reviewService;

  const ProfilePage({
    super.key,
    required this.authService,
    required this.reviewService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  int _totalReviews = 0;
  int _totalTickets = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userResponse = await widget.authService.getProfile();
      final user = User.fromJson(userResponse['user']);
      
      // Load additional stats
      final reviewsResponse = await widget.reviewService.getMyReviews();
      final reviews = reviewsResponse['data'] as List;
      
      setState(() {
        _currentUser = user;
        _totalReviews = reviews.length;
        _totalTickets = user.tickets.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await widget.authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() => _isLoggingOut = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          CustomWidgets.modernButton(
            text: 'Logout',
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            isLoading: _isLoggingOut,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileInfo(),
            _buildStatsSection(),
            _buildMenuSection(),
            const SizedBox(height: 100), // Space for bottom nav
          ],
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profil Saya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to settings
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: AppTheme.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Profile Picture and Basic Info
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 3),
                  boxShadow: AppTheme.softShadow,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.white,
                  backgroundImage: _currentUser?.fotoProfil != null
                      ? CachedNetworkImageProvider(_currentUser!.fotoProfil!)
                      : null,
                  child: _currentUser?.fotoProfil == null
                      ? Text(
                          _currentUser?.nama.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.nama ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleDisplayName(_currentUser?.role ?? 'pengunjung'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: CustomWidgets.modernCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: _currentUser?.email ?? '-',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Telepon',
              value: _currentUser?.telepon ?? '-',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: _getRoleDisplayName(_currentUser?.role ?? 'pengunjung'),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Bergabung',
              value: _formatDate(_currentUser?.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.rate_review_rounded,
              title: '$_totalReviews',
              subtitle: 'Reviews',
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.confirmation_num_rounded,
              title: '$_totalTickets',
              subtitle: 'Tiket',
              color: AppTheme.accentOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.favorite_rounded,
              title: '${_currentUser?.favoritWisata.length ?? 0}',
              subtitle: 'Favorit',
              color: AppTheme.error,
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
    required Color color,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
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

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'icon': Icons.edit_rounded,
        'title': 'Edit Profil',
        'subtitle': 'Perbarui informasi profil Anda',
        'onTap': () {
          // TODO: Navigate to edit profile
        },
      },
      {
        'icon': Icons.rate_review_rounded,
        'title': 'Reviews Saya',
        'subtitle': 'Lihat semua review yang telah Anda berikan',
        'onTap': () {
          Navigator.pushNamed(context, '/my-reviews');
        },
      },
      {
        'icon': Icons.confirmation_num_rounded,
        'title': 'Tiket Saya',
        'subtitle': 'Kelola tiket wisata Anda',
        'onTap': () {
          DefaultTabController.of(context)?.animateTo(2);
        },
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Wisata Favorit',
        'subtitle': 'Daftar wisata yang Anda sukai',
        'onTap': () {
          // TODO: Navigate to favorites
        },
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Bantuan',
        'subtitle': 'FAQ dan panduan penggunaan',
        'onTap': () {
          // TODO: Navigate to help
        },
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'Tentang Aplikasi',
        'subtitle': 'Informasi versi dan pengembang',
        'onTap': () {
          // TODO: Navigate to about
        },
      },
      {
        'icon': Icons.logout_rounded,
        'title': 'Logout',
        'subtitle': 'Keluar dari aplikasi',
        'onTap': _showLogoutDialog,
        'isDestructive': true,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: CustomWidgets.modernCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            ...menuItems.map((item) => _buildMenuItem(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              onTap: item['onTap'] as VoidCallback,
              isDestructive: item['isDestructive'] as bool? ?? false,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? AppTheme.error.withOpacity(0.1)
                      : AppTheme.backgroundOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? AppTheme.error : AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? AppTheme.error : AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'pengelola':
        return 'Pengelola Wisata';
      case 'pengunjung':
        return 'Pengunjung';
      default:
        return 'User';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }
}
