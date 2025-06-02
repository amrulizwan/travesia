import 'package:flutter/material.dart';
import 'package:travesia_app/models/user.dart';
import 'package:travesia_app/models/wisata.dart'; // Import Wisata model
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/wisata_service.dart'; // Import WisataService

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  final WisataService wisataService; // Add WisataService

  const ProfilePage({
    Key? key,
    required this.authService,
    required this.wisataService, // Add to constructor
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoadingUser = true;
  bool _isLoggingOut = false;

  List<Wisata> _managedWisataDetails = [];
  bool _isLoadingManagedWisata = false;
  String? _errorManagedWisata;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUserData();
    // _fetchManagedWisataDetails will be called within _loadUserData if applicable
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
      // Reset managed wisata list when reloading user data
      _managedWisataDetails = [];
      _isLoadingManagedWisata = false;
      _errorManagedWisata = null;
    });
    try {
      final user = await widget.authService.getUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
        // If user is pengelola and has tempatWisata, fetch their details
        if (_currentUser != null &&
            _currentUser!.role == 'pengelola' &&
            _currentUser!.tempatWisata != null &&
            _currentUser!.tempatWisata!.isNotEmpty) {
          _fetchManagedWisataDetails();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          // Optionally show an error message for user data loading itself
          print("Error loading user data: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not load user profile: ${e.toString()}')),
          );
        });
      }
    }
  }

  Future<void> _fetchManagedWisataDetails() async {
    if (_currentUser == null || _currentUser!.tempatWisata == null || _currentUser!.tempatWisata!.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingManagedWisata = true;
      _errorManagedWisata = null;
    });

    List<Wisata> details = [];
    String? errorOccurred;
    try {
      for (String wisataId in _currentUser!.tempatWisata!) {
        try {
          final wisata = await widget.wisataService.getWisataById(wisataId);
          details.add(wisata);
        } catch (e) {
          print("Error fetching details for wisata ID $wisataId: $e");
          // Collect first error, or a general one
          errorOccurred ??= "Could not load details for some managed wisata.";
        }
      }
    } catch (e) { // Catch any broader error during iteration/setup
        errorOccurred = "An unexpected error occurred while fetching managed wisata.";
    }


    if (mounted) {
      setState(() {
        _managedWisataDetails = details;
        _isLoadingManagedWisata = false;
        _errorManagedWisata = errorOccurred;
         if (errorOccurred != null && details.isEmpty){ // If a general error happened and no details were fetched
            // Potentially show a more prominent error for the whole section
         } else if (errorOccurred != null && details.isNotEmpty){
            // Some details loaded, some failed. Show a less intrusive error.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorOccurred)),
            );
         }
      });
    }
  }


  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });
    try {
      await widget.authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged out.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData, // Use _loadInitialData for refresh
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  _buildUserInfoSection(context),
                  if (_currentUser?.role == 'pengelola') ...[
                    const SizedBox(height: 16),
                    _buildManagedWisataSection(context),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.article_outlined), // Keep this icon
                    title: const Text('My Reviews'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/my-reviews'); // Ensure this route exists
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.confirmation_number_outlined), // Keep this icon
                    title: const Text('My Tickets'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/my-tickets'); // Ensure this route exists
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined), // Keep this icon
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to Edit Profile Page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile page not yet implemented.')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: _isLoggingOut
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.error))
                        : Icon(Icons.logout, color: Theme.of(context).colorScheme.error), // Keep this icon
                    title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    onTap: _isLoggingOut ? null : _handleLogout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    final String userName = _currentUser?.nama ?? 'Guest User';
    final String userEmail = _currentUser?.email ?? 'No email';
    final String? profilePictureUrl = _currentUser?.fotoProfil;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
              ? NetworkImage(profilePictureUrl)
              : null, // Handled by child
          child: (profilePictureUrl == null || profilePictureUrl.isEmpty)
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),
        Text(userName, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(userEmail, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildManagedWisataSection(BuildContext context) {
    // This title should only show if the user is 'pengelola' and the section is relevant
    if (_currentUser?.role != 'pengelola' || (_currentUser!.tempatWisata == null && !_isLoadingManagedWisata)) {
        // Don't show the section title if not a pengelola or if they have no assigned wisata spots (and not loading)
        if (_currentUser!.tempatWisata != null && _currentUser!.tempatWisata!.isEmpty && !_isLoadingManagedWisata) {
             // Show a specific message if pengelola has no wisata assigned yet
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('My Managed Wisata', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('You are not managing any wisata destinations yet.'),
                    const Divider(height: 24),
                ],
            );
        }
        return const SizedBox.shrink(); // Or don't even call this widget
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Managed Wisata', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_isLoadingManagedWisata)
          const Center(child: CircularProgressIndicator())
        else if (_errorManagedWisata != null && _managedWisataDetails.isEmpty)
          // Only show big error if nothing loaded at all
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 4),
                Text(_errorManagedWisata!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                 ElevatedButton(onPressed: _fetchManagedWisataDetails, child: const Text('Retry Managed Wisata'))
              ]),
            ),
          )
        else if (_managedWisataDetails.isEmpty && _currentUser!.tempatWisata!.isNotEmpty && _errorManagedWisata == null)
             // This case means IDs exist, loading finished, no errors, but no details (should be rare if IDs are valid)
            const Text('Could not load details for your managed wisata spots.')
        else if (_managedWisataDetails.isEmpty && (_currentUser!.tempatWisata == null || _currentUser!.tempatWisata!.isEmpty))
            const Text('You are not managing any wisata destinations yet.') // Should be caught by earlier check too
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _managedWisataDetails.length,
            itemBuilder: (context, index) {
              final wisata = _managedWisataDetails[index];
              return ListTile(
                leading: const Icon(Icons.store_mall_directory_outlined),
                title: Text(wisata.nama ?? 'Unnamed Wisata'),
                subtitle: Text(wisata.lokasi?.nama ?? 'Unknown location'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (wisata.id != null) {
                    Navigator.pushNamed(context, '/wisata-detail', arguments: wisata.id);
                  }
                },
              );
            },
          ),
        const Divider(height: 24), // Divider after the section
      ],
    );
  }
}
