import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For number formatting
import '../../models/wisata.dart';
import '../../models/jam_operasional.dart';
import '../../models/ticket_type.dart';
import '../../models/gallery_item.dart';
import '../../models/review.dart'; // Import Review model
import '../../services/api_service.dart';
import '../../services/wisata_service.dart';
import '../../services/ticket_service.dart';
import '../../services/review_service.dart'; // Import ReviewService
import '../../services/auth_service.dart'; // Import AuthService to check login status
import '../../utils/alert_utils.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import Rating Bar

class WisataDetailPage extends StatefulWidget {
  final String wisataId;

  const WisataDetailPage({super.key, required this.wisataId});

  @override
  State<WisataDetailPage> createState() => _WisataDetailPageState();
}

class _WisataDetailPageState extends State<WisataDetailPage> {
  late final ApiService _apiService;
  late final WisataService _wisataService;
  late final TicketService _ticketService;
  late final ReviewService _reviewService; // Add ReviewService
  late final AuthService _authService; // Add AuthService

  Future<Wisata>? _wisataDetailFuture;
  Future<List<Review>>? _reviewsFuture; // Future for reviews

  Map<String, int> _ticketQuantities = {};
  bool _isPurchasing = false;
  bool _isLoading = true;
  String? _errorMessage;

  // For review submission dialog
  final _reviewFormKey = GlobalKey<FormState>();
  final _reviewCommentController = TextEditingController();
  double _currentRating = 3.0; // Default rating
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _wisataService = WisataService(_apiService);
    _ticketService = TicketService(_apiService);
    _reviewService = ReviewService(_apiService); // Instantiate ReviewService
    _authService = AuthService(_apiService); // Instantiate AuthService

    _fetchWisataDetails();
    _fetchReviews(); // Fetch reviews initially
  }

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _fetchWisataDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _wisataDetailFuture = _wisataService.getWisataById(widget.wisataId);
    });
    try {
      await _wisataDetailFuture;
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _reviewsFuture = _reviewService.getReviewsForWisata(widget.wisataId);
    });
    // Error handling will be done by the FutureBuilder for reviews
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Wisata', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        elevation: 2.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    return FutureBuilder<Wisata>(
      future: _wisataDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
           // Handles cases where future is re-triggered (e.g. by a refresh not implemented here yet)
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return _buildErrorWidget('Data wisata tidak ditemukan.');
        }

        final wisata = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGallerySection(wisata.gallery),
              const SizedBox(height: 20),
              Text(
                wisata.nama,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              _buildRatingSection(wisata.averageRating, wisata.reviews.length),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.description_outlined, 'Deskripsi', wisata.deskripsi),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on_outlined, 'Alamat', wisata.alamat),
              if (wisata.lokasi != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 36.0), // Align with text of InfoRow
                  child: Text(
                    '${wisata.lokasi!.nama} (Kota/Kab)', // Assuming lokasi.nama is city/regency
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // TODO: Add map link if coordinates are available
              // if (wisata.koordinat.latitude != 0 && wisata.koordinat.longitude != 0)
              //   _buildMapLink(wisata.koordinat),
              _buildInfoRow(Icons.contact_phone_outlined, 'Kontak', wisata.kontak),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.language_outlined, 'Website', wisata.website, isLink: true),
              const SizedBox(height: 16),
              _buildSectionTitle('Jam Operasional'),
              _buildJamOperasionalSection(wisata.jamOperasional),
              const SizedBox(height: 16),
              _buildSectionTitle('Tiket'),
              _buildTicketSelectionSection(wisata.jenisTiket, wisata.id),
              const SizedBox(height: 24),
              _buildSectionTitle('Ulasan Pengunjung'),
              _buildWriteReviewButton(), // Button to open review dialog
              _buildReviewsSection(), // Display reviews
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $errorMsg',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWisataDetails,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[600]),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              isLink
                  ? InkWell(
                      onTap: () { /* TODO: Implement launch URL */ },
                      child: Text(
                        value.isNotEmpty ? value : 'Tidak tersedia',
                        style: TextStyle(fontSize: 16, color: value.isNotEmpty ? Colors.blue : Colors.grey[700], decoration: value.isNotEmpty ? TextDecoration.underline : TextDecoration.none),
                      ),
                    )
                  : Text(
                      value.isNotEmpty ? value : 'Tidak tersedia',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection(List<GalleryItem> gallery) {
    if (gallery.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          final item = gallery[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            margin: const EdgeInsets.only(right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                item.urlGambar,
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSection(double? averageRating, int reviewCount) {
    if (averageRating == null || averageRating == 0) {
      return const Text('Belum ada rating', style: TextStyle(fontSize: 16, color: Colors.grey));
    }
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 24),
        const SizedBox(width: 8),
        Text(
          averageRating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '($reviewCount ulasan)',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildJamOperasionalSection(List<JamOperasional> jamOperasional) {
    if (jamOperasional.isEmpty) {
      return const Text('Informasi jam operasional tidak tersedia.', style: TextStyle(fontSize: 16));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: jamOperasional.map((jo) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(jo.hari, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              Expanded(flex: 3, child: Text('${jo.jamBuka} - ${jo.jamTutup}', style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTicketSelectionSection(List<TicketType> ticketTypes, String wisataId) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (ticketTypes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Informasi tiket tidak tersedia untuk wisata ini.', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      );
    }

    double totalPrice = 0;
    _ticketQuantities.forEach((ticketTypeId, quantity) {
      final ticketType = ticketTypes.firstWhere((tt) => tt.id == ticketTypeId, orElse: () => throw Exception("Invalid ticket type ID"));
      totalPrice += ticketType.harga * quantity;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ticketTypes.map((ticket) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(ticket.deskripsi, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(ticket.harga),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah:', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: _isPurchasing ? null : () {
                              setState(() {
                                if ((_ticketQuantities[ticket.id] ?? 0) > 0) {
                                  _ticketQuantities[ticket.id] = (_ticketQuantities[ticket.id] ?? 0) - 1;
                                }
                              });
                            },
                          ),
                          Text('${_ticketQuantities[ticket.id] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: _isPurchasing ? null : () {
                              setState(() {
                                // Check against stock if available: ticket.stok
                                _ticketQuantities[ticket.id] = (_ticketQuantities[ticket.id] ?? 0) + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
        if (totalPrice > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Harga:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormatter.format(totalPrice),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        Center(
          child: ElevatedButton(
            onPressed: (_ticketQuantities.values.any((qty) => qty > 0) && !_isPurchasing)
              ? () => _handlePurchase(wisataId)
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: _isPurchasing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Pesan Tiket', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase(String wisataId) async {
    setState(() => _isPurchasing = true);

    final itemsToPurchase = _ticketQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {'ticketTypeId': entry.key, 'quantity': entry.value})
        .toList();

    if (itemsToPurchase.isEmpty) {
      AlertUtils.showError(context, 'Pilih minimal satu tiket untuk dipesan.');
      setState(() => _isPurchasing = false);
      return;
    }

    try {
      final result = await _ticketService.purchaseTicket(wisataId, itemsToPurchase);
      // Assuming result contains orderId, snapToken, etc.
      AlertUtils.showSuccess(
        context,
        'Pembelian Berhasil!\nOrder ID: ${result['orderId']}\nSNAP Token: ${result['snapToken']}\nLanjutkan pembayaran di halaman "Tiket Saya".',
        duration: const Duration(seconds: 7) // Longer duration for user to read
      );
      setState(() {
        _ticketQuantities.clear(); // Clear quantities after successful purchase
      });
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      AlertUtils.showError(context, 'Gagal melakukan pemesanan: $errorMessage');
    } finally {
      if(mounted) setState(() => _isPurchasing = false);
    }
  }

  Widget _buildWriteReviewButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit_note, color: Colors.white),
          label: const Text('Tulis Ulasan', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () async {
            bool loggedIn = await _authService.isLoggedIn();
            if (!loggedIn) {
              AlertUtils.showError(context, 'Anda harus login untuk menulis ulasan.');
              // Optionally navigate to login page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              return;
            }
            // TODO: Optionally check if user has a purchased ticket for this wisata
            // This might involve calling ticketService.getMyTickets() and checking.
            // For now, we allow opening the dialog, API will do the final check.
            _showReviewDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
        ),
      ),
    );
  }

  void _showReviewDialog() {
    _currentRating = 3.0; // Reset rating
    _reviewCommentController.clear(); // Clear previous comment

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // To update rating within the dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tulis Ulasan Anda'),
              content: Form(
                key: _reviewFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Berikan rating Anda:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: _currentRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                           setDialogState(() { // Use setDialogState to update dialog's UI
                            _currentRating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reviewCommentController,
                        decoration: InputDecoration(
                          labelText: 'Komentar Anda',
                          hintText: 'Bagaimana pengalaman Anda?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Komentar tidak boleh kosong.';
                          }
                          if (value.length < 10) {
                            return 'Komentar minimal 10 karakter.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: _isSubmittingReview
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim Ulasan', style: TextStyle(color: Colors.white)),
                  onPressed: _isSubmittingReview ? null : () {
                    if (_reviewFormKey.currentState!.validate()) {
                       // Use setDialogState for UI changes within dialog before async call
                      setDialogState(() => _isSubmittingReview = true);
                      _submitReview().then((_) {
                        // After async call, ensure dialog is still mounted before popping
                        if (Navigator.of(context).canPop()) {
                           Navigator.of(context).pop();
                        }
                      }).whenComplete(() {
                        // Ensure to reset loading state even if dialog was dismissed early
                        // Check mounted for the main page state, not dialog state here
                        if(mounted) {
                           setState(() => _isSubmittingReview = false);
                        } else {
                           _isSubmittingReview = false; // Reset if page not mounted
                        }
                      });
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

  Future<void> _submitReview() async {
    // No need to call setState for _isSubmittingReview here as dialog state handles it
    // For main page state: if(mounted) setState(() => _isSubmittingReview = true);

    try {
      final result = await _reviewService.createReview(
        widget.wisataId,
        _currentRating.toInt(),
        _reviewCommentController.text,
        // ticketId: "optional_ticket_id_if_available_and_required"
        // TODO: Get relevant ticketId if required by API for validation
      );

      if (result['success'] == true) {
        AlertUtils.showSuccess(context, result['message'] ?? 'Ulasan berhasil dikirim!');
        _fetchReviews(); // Refresh the reviews list
        // Also potentially refresh wisata details if average rating changes
        _fetchWisataDetails();
      } else {
        AlertUtils.showError(context, result['message'] ?? 'Gagal mengirim ulasan.');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring("Exception: ".length);
      }
      AlertUtils.showError(context, 'Gagal mengirim ulasan: $errorMessage');
    }
    // Resetting _isSubmittingReview is handled by the .whenComplete in _showReviewDialog
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.red)));
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gagal memuat ulasan: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('Belum ada ulasan untuk wisata ini.', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))),
          );
        }

        final reviews = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // To be used within SingleChildScrollView
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.user?.nama ?? 'Pengguna Anonim',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(review.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: review.rating.toDouble(),
                      itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 18.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.komentar,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    // TODO: Add Pengelola Response if available in Review model
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
