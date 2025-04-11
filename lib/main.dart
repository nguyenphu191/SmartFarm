import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_farm/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  runApp(const MyApp());
}

// final GoRouter _router = GoRouter(
//   initialLocation: '/', // Trang mặc định
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => Loginscreen(),
//     ),
//     GoRoute(
//       path: '/register',
//       builder: (context, state) => Signupscreen(),
//     ),
//     GoRoute(
//       path: '/home',
//       builder: (context, state) => HomeScreen(),
//     ),
//     GoRoute(
//       path: '/setting',
//       builder: (context, state) => SettingScreen(),
//     ),
//     GoRoute(
//       path: '/history',
//       builder: (context, state) => HistoryScreen(),
//     ),
//     GoRoute(
//       path: '/warning',
//       builder: (context, state) => WarningScreen(),
//     ),
//     GoRoute(
//       path: '/detail/:id',
//       builder: (context, state) {
//         final id = state.uri.queryParameters['id'] ?? '';
//         return DetailPlantScreen(
//           plantid: id,
//         );
//       },
//     ),
//   ],
// );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Farm App ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => Loginscreen(),
        },
      ),
    );
  }
}
