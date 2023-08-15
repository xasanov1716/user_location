import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:user_locations/provider/address_call_provider.dart';
import 'package:user_locations/provider/location_provider.dart';
import 'package:user_locations/provider/user_locations_provider.dart';
import 'package:user_locations/servis/api_service.dart';
import 'package:user_locations/ui/splash_screen/splash_screen.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserLocationsProvider()),
      ChangeNotifierProvider(create: (context) => LocationProvider()),
      ChangeNotifierProvider(
          create: (context) => AddressCallProvider(apiService: ApiService())),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
