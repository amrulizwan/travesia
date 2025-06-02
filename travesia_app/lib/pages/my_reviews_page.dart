import 'package:flutter/material.dart';
import 'package:travesia_app/models/review.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class MyReviewsPage extends StatefulWidget {
  final ReviewService reviewService;

  const MyReviewsPage({Key? key, required this.reviewService}) : super(key: key);

  @override
  _MyReviewsPageState createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  List<Review> _myReviews = [];
  bool _isLoading = true;
  String? _error;

  final dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
  }

  Future<void> _fetchMyReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reviewsData = await widget.reviewService.getMyReviews();
      if (mounted) {
        setState(() {
          _myReviews = reviewsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load your reviews: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
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
              ElevatedButton(onPressed: _fetchMyReviews, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }
    if (_myReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('You have not written any reviews yet.'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _fetchMyReviews,
                child: const Text('Refresh'),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _myReviews.length,
        itemBuilder: (context, index) {
          final review = _myReviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.wisata?.nama ?? 'Wisata Name Not Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: review.rating?.toDouble() ?? 0.0,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${review.rating?.toString() ?? 'N/A'})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.komentar ?? 'No comment.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      review.createdAt != null ? dateFormatter.format(review.createdAt!) : 'Date unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
