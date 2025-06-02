import 'package:flutter/material.dart';
import 'package:travesia_app/models/wisata.dart';
import 'package:travesia_app/models/review.dart';
import 'package:travesia_app/models/ticket_type.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:travesia_app/models/wisata.dart';
import 'package:travesia_app/models/review.dart';
import 'package:travesia_app/models/ticket_type.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WisataDetailPage extends StatefulWidget {
  final String wisataId;
  final WisataService wisataService;
  final ReviewService reviewService;

  const WisataDetailPage({
    Key? key,
    required this.wisataId,
    required this.wisataService,
    required this.reviewService,
  }) : super(key: key);

  @override
  _WisataDetailPageState createState() => _WisataDetailPageState();
}

class _WisataDetailPageState extends State<WisataDetailPage> {
  Wisata? _wisata;
  List<Review> _reviews = [];
  bool _isLoadingWisata = true;
  String? _errorWisata;
  bool _isLoadingReviews = true;
  String? _errorReviews;
  bool _isSubmittingReview = false; // New state for review submission

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Use Future.wait to run both fetches concurrently for faster loading
    await Future.wait([
      _fetchWisataDetails(),
      _fetchReviews(),
    ]);
  }

  Future<void> _fetchWisataDetails() async {
    setState(() {
      _isLoadingWisata = true;
      _errorWisata = null;
    });
    try {
      final wisataData = await widget.wisataService.getWisataById(widget.wisataId);
      if (mounted) {
        setState(() {
          _wisata = wisataData;
          _isLoadingWisata = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorWisata = "Failed to load wisata details: ${e.toString()}";
          _isLoadingWisata = false;
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _errorReviews = null;
    });
    try {
      final reviewsData = await widget.reviewService.getReviewsForWisata(widget.wisataId);
      if (mounted) {
        setState(() {
          _reviews = reviewsData;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorReviews = "Failed to load reviews: ${e.toString()}";
          _isLoadingReviews = false;
        });
      }
    }
  }
  
  Widget _buildStarRating(double rating) {
    // Fallback star display if flutter_rating_bar is not available
    List<Widget> stars = [];
    int fullStars = rating.floor();
    int halfStars = (rating - fullStars >= 0.5) ? 1 : 0;
    int emptyStars = 5 - fullStars - halfStars;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (halfStars == 1) {
      stars.add(Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.amber, size: 18));
    }
    return Row(children: stars);
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingWisata) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorWisata != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(_errorWisata!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _fetchWisataDetails, child: const Text('Retry'))
              ],
            ),
          ),
        ),
      );
    }

    if (_wisata == null) { // Should ideally not happen if _errorWisata is null and not loading
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Wisata details are not available.')),
      );
    }

    final wisata = _wisata!;

    return Scaffold(
      appBar: AppBar(
        title: Text(wisata.nama ?? 'Detail Wisata'),
      ),
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: _fetchData,
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderImage(wisata),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wisata.nama ?? 'No Name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(wisata.lokasi?.nama ?? 'No Location', style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Description'),
                  Text(wisata.deskripsi ?? 'No description available.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  if (wisata.gambar != null && wisata.gambar!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Gallery'),
                    _buildImageGallery(wisata.gambar!),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionTitle(context, 'Tickets'),
                  _buildTicketInfoSection(wisata.ticketTypes ?? []),
                  const SizedBox(height: 16),
                  if (wisata.fasilitas != null && wisata.fasilitas!.isNotEmpty) ...[
                     _buildSectionTitle(context, 'Facilities'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: wisata.fasilitas!.map((f) => Chip(label: Text(f))).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionTitle(context, 'Contact'),
                  Text(wisata.kontak ?? 'No contact information.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Operational Hours'),
                  Text(wisata.jamOperasional ?? 'Not specified.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Reviews'),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(Wisata wisata) {
    String? imageUrl;
    if (wisata.gambar != null && wisata.gambar!.isNotEmpty) {
      imageUrl = wisata.gambar![0].url; // Use first gallery image as header
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
      );
    }
    return Image.network(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGallery(List<GalleryItem> gallery) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          final item = gallery[index];
          if (item.url == null || item.url!.isEmpty) return const SizedBox.shrink();
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(right: 8.0),
            child: Image.network(
              item.url!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                const Center(child: Icon(Icons.broken_image)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTicketInfoSection(List<TicketType> ticketTypes) {
    if (ticketTypes.isEmpty) {
      return const Text('No ticket information available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ticketTypes.map((ticket) => ListTile(
              title: Text(ticket.nama ?? 'Unnamed Ticket'),
              trailing: Text('Rp ${ticket.harga?.toStringAsFixed(0) ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              dense: true,
            )),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/purchase-ticket', arguments: {'wisataId': widget.wisataId});
            },
            child: const Text('Buy Ticket'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    if (_isLoadingReviews) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()));
    }
    if (_errorReviews != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 36),
              const SizedBox(height: 8),
              Text(_errorReviews!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _fetchReviews, child: const Text('Retry Reviews'))
            ],
          ),
      );
    }
    if (_reviews.isEmpty) {
      return const Text('No reviews yet.');
    }
    return Column(
      children: [
        ..._reviews.map((review) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(review.user?.nama ?? 'Anonymous'),
            subtitle: Text(review.komentar ?? ''),
            trailing: _buildStarRating(review.rating?.toDouble() ?? 0.0), 
            // Example if flutter_rating_bar was available:
            // trailing: RatingBarIndicator(
            //     rating: review.rating?.toDouble() ?? 0.0,
            //     itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
            //     itemCount: 5,
            //     itemSize: 15.0,
            // ),
          ),
        )).toList(),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () => _showWriteReviewDialog(context),
          child: const Text('Write a Review'),
        ),
      ],
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    double _currentRating = 3.0; // Default rating
    String _comment = '';
    String? _dialogError;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage dialog's own state for error and loading
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Write Your Review'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Rate this wisata (1-5 stars):'),
                      RatingBar.builder(
                        initialRating: _currentRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          _currentRating = rating;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Your Comment',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _comment = value ?? '';
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your comment';
                          }
                          return null;
                        },
                        maxLines: 3,
                      ),
                      if (_dialogError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_dialogError!, style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: _isSubmittingReview ? null : () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: _isSubmittingReview 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) 
                      : const Text('Submit'),
                  onPressed: _isSubmittingReview ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setDialogState(() {
                        _isSubmittingReview = true;
                        _dialogError = null;
                      });
                      try {
                        await widget.reviewService.createReview(
                          wisataId: widget.wisataId,
                          rating: _currentRating.toInt(),
                          komentar: _comment,
                          // ticketId is optional, omitting for now
                        );
                        Navigator.of(dialogContext).pop(); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted successfully!')),
                        );
                        _fetchReviews(); // Refresh reviews on the main page
                      } catch (e) {
                        setDialogState(() {
                          _dialogError = e.toString().replaceFirst("Exception: ", "");
                        });
                      } finally {
                         setDialogState(() {
                          _isSubmittingReview = false;
                        });
                      }
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }
  

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), // Made title bold
    );
  }
}
