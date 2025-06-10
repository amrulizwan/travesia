import 'package:flutter/material.dart';
import 'package:travesia_app/utils/app_theme.dart';
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/services/province_service.dart';
import 'package:travesia_app/services/wisata_service.dart';
import 'package:travesia_app/services/review_service.dart';
import 'package:travesia_app/services/ticket_service.dart';
import 'package:travesia_app/pages/auth/login_page.dart';
import 'package:travesia_app/pages/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthService.init();
  final provinceService = ProvinceService(authService.apiService);
  final wisataService = WisataService(authService.apiService);
  final reviewService = ReviewService(authService.apiService);
  final ticketService = TicketService(authService.apiService);
  final bool loggedIn = await authService.isLoggedIn();
  
  runApp(TravesiaApp(
    authService: authService,
    provinceService: provinceService,
    wisataService: wisataService,
    reviewService: reviewService,
    ticketService: ticketService,
    isLoggedIn: loggedIn,
  ));
}

class TravesiaApp extends StatelessWidget {
  final AuthService authService;
  final ProvinceService provinceService;
  final WisataService wisataService;
  final ReviewService reviewService;
  final TicketService ticketService;
  final bool isLoggedIn;

  const TravesiaApp({
    super.key,
    required this.authService,
    required this.provinceService,
    required this.wisataService,
    required this.reviewService,
    required this.ticketService,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travesia - Jelajahi Indonesia',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn 
          ? MainNavigation(
              authService: authService,
              provinceService: provinceService,
              wisataService: wisataService,
              reviewService: reviewService,
              ticketService: ticketService,
            )
          : LoginPage(authService: authService),
      routes: {
        '/login': (context) => LoginPage(authService: authService),
        '/main': (context) => MainNavigation(
              authService: authService,
              provinceService: provinceService,
              wisataService: wisataService,
              reviewService: reviewService,
              ticketService: ticketService,
            ),
      },
    );
  }
}
