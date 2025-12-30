import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/user_provider.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/map_view.dart';
import 'views/trip_result_view.dart';
import 'views/alerts_view.dart';
import 'views/profile_view.dart';
import 'views/favorites_view.dart';
import 'views/avatars_view.dart';
import 'views/offline_maps_view.dart';
import 'views/admin_view.dart';
import 'views/lines_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const DoroWereApp());
}

class DoroWereApp extends StatelessWidget {
  const DoroWereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUser(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashView(),
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/map': (context) => const MapView(),
          '/trip-result': (context) => const TripResultView(),
          '/alerts': (context) => const AlertsView(),
          '/profile': (context) => const ProfileView(),
          '/favorites': (context) => const FavoritesView(),
          '/avatars': (context) => const AvatarsView(),
          '/offline-maps': (context) => const OfflineMapsView(),
          '/admin': (context) => const AdminView(),
          '/lines': (context) => const LinesView(),
        },
      ),
    );
  }
}
