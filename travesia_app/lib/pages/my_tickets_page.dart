import 'package:flutter/material.dart';
import 'package:travesia_app/models/ticket.dart';
import 'package:travesia_app/services/ticket_service.dart';
import 'package:intl/intl.dart'; // For date and currency formatting

class MyTicketsPage extends StatefulWidget {
  final TicketService ticketService;

  const MyTicketsPage({Key? key, required this.ticketService}) : super(key: key);

  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyTickets();
  }

  Future<void> _fetchMyTickets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ticketsData = await widget.ticketService.getMyTickets();
      if (mounted) {
        setState(() {
          _tickets = ticketsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load tickets: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }
  
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _fetchMyTickets, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }
    if (_tickets.isEmpty) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('You have no tickets yet.'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _fetchMyTickets, child: const Text('Refresh'))
            ],
          ),
        );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.wisata?.nama ?? 'Wisata Name Not Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Order ID:', ticket.orderId ?? 'N/A'),
                  _buildDetailRow('Status:', ticket.paymentStatus ?? 'N/A', 
                    valueColor: _getStatusColor(ticket.paymentStatus)),
                  _buildDetailRow('Total Price:', currencyFormatter.format(ticket.totalPrice ?? 0)),
                  _buildDetailRow('Purchase Date:', ticket.createdAt != null ? dateFormatter.format(ticket.createdAt!) : 'N/A'),
                  const SizedBox(height: 10),
                  Text('Purchased Items:', style: Theme.of(context).textTheme.titleMedium),
                  if (ticket.purchasedItems != null && ticket.purchasedItems!.isNotEmpty)
                    ...ticket.purchasedItems!.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        '- ${item.ticketType?.nama ?? 'Ticket'} (x${item.quantity ?? 0}) @ ${currencyFormatter.format(item.priceAtPurchase ?? 0)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ))
                  else
                    const Text('No items found for this ticket.', style: TextStyle(fontStyle: FontStyle.italic)),
                  
                  // Optionally, add a button to view payment details or retry payment if applicable
                  // if (ticket.paymentStatus == 'PENDING' && ticket.snapToken != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: ElevatedButton(
                  //       onPressed: () { /* TODO: Handle Midtrans payment view */ },
                  //       child: Text('Complete Payment'),
                  //     ),
                  //   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: valueColor))),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAID':
      case 'SETTLEMENT': // Midtrans status
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
      case 'EXPIRED': // Midtrans status
      case 'FAILURE': // Midtrans status
        return Colors.red;
      default:
        return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }
}
