import 'package:flutter/material.dart';
import 'package:travesia_app/models/wisata.dart';
import 'package:travesia_app/models/ticket_type.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/ticket_service.dart';
import 'package:intl/intl.dart'; // For currency formatting

class TicketPurchasePage extends StatefulWidget {
  final String wisataId;
  final WisataService wisataService;
  final TicketService ticketService;

  const TicketPurchasePage({
    Key? key,
    required this.wisataId,
    required this.wisataService,
    required this.ticketService,
  }) : super(key: key);

  @override
  _TicketPurchasePageState createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  Wisata? _wisata;
  bool _isLoadingWisata = true;
  String? _errorWisata;
  bool _isPurchasing = false;

  Map<String, int> _ticketQuantities = {}; // Key: ticketTypeId, Value: quantity

  @override
  void initState() {
    super.initState();
    _fetchWisataDetails();
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
          // Initialize quantities
          _wisata?.ticketTypes?.forEach((ticketType) {
            if (ticketType.id != null) {
              _ticketQuantities[ticketType.id!] = 0;
            }
          });
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

  void _updateQuantity(String ticketTypeId, int change) {
    setState(() {
      _ticketQuantities.update(ticketTypeId, (value) {
        final newValue = value + change;
        return newValue >= 0 ? newValue : 0; // Ensure quantity doesn't go below 0
      }, ifAbsent: () => change > 0 ? change : 0);
    });
  }

  double _calculateSubtotal(TicketType ticketType) {
    final quantity = _ticketQuantities[ticketType.id!] ?? 0;
    return (ticketType.harga ?? 0) * quantity;
  }

  double _calculateTotalPrice() {
    double total = 0;
    _wisata?.ticketTypes?.forEach((ticketType) {
      if (ticketType.id != null) {
        total += _calculateSubtotal(ticketType);
      }
    });
    return total;
  }

  Future<void> _handlePurchase() async {
    final itemsToPurchase = _ticketQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {'ticketTypeId': entry.key, 'quantity': entry.value})
        .toList();

    if (itemsToPurchase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ticket.')),
      );
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final result = await widget.ticketService.purchaseTickets(
        widget.wisataId,
        itemsToPurchase,
      );

      if (mounted) {
        // Display snapToken and orderId (simplified Midtrans handling for now)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Purchase Initiated'),
            content: Text(
                'Order ID: ${result.orderId}\nSnap Token: ${result.snapToken}\n\nUse this token to complete payment (simulation).'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/my-tickets');
                },
                child: const Text('OK & Go to My Tickets'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }
  
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    if (_isLoadingWisata) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Tickets...')),
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
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
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

    if (_wisata == null) { // Should not happen if error is null and not loading
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Wisata details are not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Tickets for ${_wisata!.nama ?? 'Wisata'}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  _wisata!.nama ?? 'Wisata Destination',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select your tickets:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_wisata!.ticketTypes == null || _wisata!.ticketTypes!.isEmpty)
                  const Text('No ticket types available for this destination.')
                else
                  ..._wisata!.ticketTypes!.map((ticketType) {
                    if (ticketType.id == null) return const SizedBox.shrink();
                    final quantity = _ticketQuantities[ticketType.id!] ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticketType.nama ?? 'Ticket', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(currencyFormatter.format(ticketType.harga ?? 0)),
                            if (ticketType.deskripsi != null && ticketType.deskripsi!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(ticketType.deskripsi!, style: Theme.of(context).textTheme.bodySmall),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _updateQuantity(ticketType.id!, -1),
                                  tooltip: 'Decrease quantity',
                                ),
                                Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(ticketType.id!, 1),
                                  tooltip: 'Increase quantity',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalPrice = _calculateTotalPrice();
    final selectedItems = _wisata?.ticketTypes
        ?.where((tt) => tt.id != null && (_ticketQuantities[tt.id!] ?? 0) > 0)
        .toList();

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(0), // No margin if it's at the bottom
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (selectedItems == null || selectedItems.isEmpty)
              const Text('No tickets selected yet.')
            else
              ...selectedItems.map((ticketType) {
                final quantity = _ticketQuantities[ticketType.id!] ?? 0;
                final subtotal = _calculateSubtotal(ticketType);
                return ListTile(
                  title: Text('${ticketType.nama} (x$quantity)'),
                  trailing: Text(currencyFormatter.format(subtotal)),
                  dense: true,
                );
              }),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Price:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(currencyFormatter.format(totalPrice), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (totalPrice == 0 || _isPurchasing) ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isPurchasing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
