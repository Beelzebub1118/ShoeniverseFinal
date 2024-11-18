import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shoeniverse/Loadingscreen.dart';
import 'bag_provider.dart'; // BagProvider for shopping cart state


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BagProvider()), // Add BagProvider for cart state
      ],
      child: MaterialApp(
        title: 'Shoeniverse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoadingScreen(), // Set LogReg as the starting screen
      ),
    );
  }
}
