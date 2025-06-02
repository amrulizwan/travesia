import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/province_service.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:travesia_app/services/ticket_service.dart';
import 'package:travesia_app/pages/auth/login_page.dart';
import 'package:travesia_app/pages/auth/register_page.dart';
import 'package:travesia_app/pages/my_reviews_page.dart'; // Import MyReviewsPage
import 'package:travesia_app/pages/home_page.dart';
import 'package:travesia_app/pages/profile_page.dart';
import 'package:travesia_app/pages/my_tickets_page.dart';
import 'package:travesia_app/pages/wisata_detail_page.dart';
import 'package:travesia_app/pages/ticket_purchase_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important for async main
  final authService = await AuthService.init(); // Initialize AuthService
  final provinceService = ProvinceService(authService.apiService); // Create ProvinceService
  final wisataService = WisataService(authService.apiService);   // Create WisataService
  final reviewService = ReviewService(authService.apiService);   // Create ReviewService
  final ticketService = TicketService(authService.apiService);   // Create TicketService
  final bool loggedIn = await authService.isLoggedIn(); // Check login status
  runApp(MainApp(
    authService: authService,
    provinceService: provinceService,
    wisataService: wisataService,
    reviewService: reviewService,
    ticketService: ticketService, // Pass TicketService
    isLoggedIn: loggedIn,
  ));
}

class MainApp extends StatelessWidget {
  final AuthService authService;
  final ProvinceService provinceService;
  final WisataService wisataService;
  final ReviewService reviewService;
  final TicketService ticketService; // Add TicketService field
  final bool isLoggedIn;

  const MainApp({
    Key? key,
    required this.authService,
    required this.provinceService,
    required this.wisataService,
    required this.reviewService,
    required this.ticketService, // Add to constructor
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travesia App',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginPage(authService: authService),
        '/register': (context) => RegisterPage(authService: authService),
        '/home': (context) => HomePage(
              authService: authService,
              provinceService: provinceService,
              wisataService: wisataService,
            ),
        '/profile': (context) => ProfilePage(
              authService: authService, 
              wisataService: wisataService, // Pass WisataService
            ),
        '/my-tickets': (context) => MyTicketsPage(ticketService: ticketService),
        '/wisata-detail': (context) {
          final String wisataId = ModalRoute.of(context)!.settings.arguments as String;
          return WisataDetailPage(
            wisataId: wisataId,
            wisataService: wisataService,
            reviewService: reviewService,
          );
        },
        '/purchase-ticket': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final String wisataId = args['wisataId'] as String;
          return TicketPurchasePage(
            wisataId: wisataId,
            wisataService: wisataService,
            ticketService: ticketService,
          );
        },
        '/my-reviews': (context) => MyReviewsPage(reviewService: reviewService), // Add MyReviewsPage route
      },
      // Optional: Add a home fallback or an unknown route handler
      // home: isLoggedIn ? HomePage(authService: authService) : LoginPage(authService: authService),
      // onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => Text('Page not found')),
    );
  }
}
