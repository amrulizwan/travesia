import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../models/purchased_item.dart';
import '../../services/api_service.dart';
import '../../services/ticket_service.dart';
import '../../services/auth_service.dart'; // For checking login status

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late final ApiService _apiService;
  late final TicketService _ticketService;
  late final AuthService _authService;
  Future<List<Ticket>>? _myTicketsFuture;
  bool _isAuthInitialized = false;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _ticketService = TicketService(_apiService);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _authService = await AuthService.init();
      setState(() {
        _isAuthInitialized = true;
      });
      await _checkLoginAndFetchTickets();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize authentication service';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLoginAndFetchTickets() async {
    if (!_isAuthInitialized) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool loggedIn = await _authService.isLoggedIn();
      if (!mounted) return;

      setState(() {
        _isLoggedIn = loggedIn;
      });

      if (_isLoggedIn) {
        await _fetchTickets();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Anda harus login untuk melihat tiket Anda.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTickets() async {
    // Ensure future is only set if not already completed or in progress from a previous call
    // This is a simplified check; more robust would involve checking future's state.
    if (_myTicketsFuture == null || _isLoading == false) {
      setState(() {
        _isLoading = true; // Set loading true when fetching starts
        _errorMessage = null;
        _myTicketsFuture = _ticketService.getMyTickets();
      });
    }

    try {
      await _myTicketsFuture;
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
        title: const Text('Tiket Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        elevation: 2.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: _fetchTickets,
              backgroundColor: Colors.red,
              tooltip: 'Refresh Tiket',
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (!_isLoggedIn && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'Silakan login untuk melihat tiket Anda.',
                  style:
                      const TextStyle(fontSize: 16, color: Colors.redAccent)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login page - assuming LoginPage path
                  // Navigator.of(context).pushReplacementNamed('/login'); // Or your login route
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Login Sekarang',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      // Handles initial loading and loading during refresh
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    // If there was an error during fetch after login (and not initial loading)
    if (_errorMessage != null && !_isLoading) {
      return _buildErrorWidget(_errorMessage!);
    }

    return FutureBuilder<List<Ticket>>(
      future: _myTicketsFuture,
      builder: (context, snapshot) {
        // This connection state check is for when the future is actively running
        // _isLoading handles the initial phase or manual refresh loading.
        if (snapshot.connectionState == ConnectionState.waiting &&
            _isLoading == false) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Anda belum memiliki tiket.',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchTickets, // Refresh
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cek Ulang',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ));
        }

        final tickets = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _buildTicketCard(ticket);
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(String errorMsg) {
    // Remove "Exception: " prefix if present for cleaner display
    final displayError = errorMsg.startsWith("Exception: ")
        ? errorMsg.substring("Exception: ".length)
        : errorMsg;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $displayError',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _isLoggedIn ? _fetchTickets : _checkLoginAndFetchTickets,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    // Attempt to get the first Wisata name from items, if available
    String? firstWisataName = 'Nama Wisata Tidak Tersedia';
    if (ticket.items.isNotEmpty && ticket.items.first.wisata != null) {
      firstWisataName = ticket.items.first.wisata!.nama;
    } else if (ticket.items.isNotEmpty &&
        ticket.items.first.idWisata.isNotEmpty) {
      // Potentially fetch wisata name by idWisata if needed, for now placeholder
      firstWisataName =
          'Wisata ID: ${ticket.items.first.idWisata.substring(0, 8)}...';
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstWisataName, // Displaying first wisata name as a title for the ticket
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
            const SizedBox(height: 4),
            Text('Order ID: ${ticket.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.event_available, 'Tgl Pembelian:',
                dateFormatter.format(ticket.tanggalPembelian)),
            _buildDetailRow(
                Icons.payment, 'Status:', ticket.statusPembayaran.toUpperCase(),
                valueColor: ticket.statusPembayaran.toLowerCase() == 'paid'
                    ? Colors.green[700]
                    : Colors.orange[700]),
            if (ticket.kodePembayaran != null &&
                ticket.kodePembayaran!.isNotEmpty)
              _buildDetailRow(
                  Icons.qr_code, 'Kode Pembayaran:', ticket.kodePembayaran!),
            if (ticket.tanggalKedaluwarsaPembayaran != null)
              _buildDetailRow(Icons.timer_off_outlined, 'Bayar Sebelum:',
                  dateFormatter.format(ticket.tanggalKedaluwarsaPembayaran!)),
            const SizedBox(height: 12),
            const Text('Detail Item:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...ticket.items
                .map((item) =>
                    _buildPurchasedItemDetail(item, currencyFormatter))
                .toList(),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Harga:',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormatter.format(ticket.totalHarga),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.red[400]),
          const SizedBox(width: 8),
          Text('$label ',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight:
                      valueColor != null ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedItemDetail(PurchasedItem item, NumberFormat formatter) {
    String itemName = item.jenisTiket?.nama ?? 'Item Tiket';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text('$itemName (x${item.jumlah})',
                  style: const TextStyle(fontSize: 14))),
          Text(formatter.format(item.subtotal),
              style: TextStyle(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }
}
