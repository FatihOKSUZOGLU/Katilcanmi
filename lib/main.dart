import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/payment_view_model.dart';
import 'screens/payment_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PaymentViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // 👈 zorla dark
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(),
        ),
        cardTheme: const CardThemeData(color: Color(0xFF181616), elevation: 2),
      ),
      home: const PaymentScreen(),
    );
  }
}
