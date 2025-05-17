import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/provider/auth_provider.dart';
import 'package:smart_farm/provider/care_plan_provider.dart'
    show CarePlanProvider;
import 'package:smart_farm/provider/location_provider.dart';
import 'package:smart_farm/provider/plant_provider.dart';
import 'package:smart_farm/provider/season_provider.dart';
import 'package:smart_farm/provider/sensor_provider.dart';
import 'package:smart_farm/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SeasonProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => CarePlanProvider()),
        ChangeNotifierProxyProvider2<LocationProvider, SeasonProvider,
            SensorProvider>(
          create: (_) => SensorProvider(),
          update: (_, locationProvider, seasonProvider, sensorProvider) {
            sensorProvider!.setProviders(locationProvider, seasonProvider);
            return sensorProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Farm App ',
        home: Loginscreen(),
      ),
    );
  }
}
