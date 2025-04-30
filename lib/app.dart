import 'package:flutter/material.dart';
import 'register_routes.dart';

class SmartNotes extends StatelessWidget {
  const SmartNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Notes',
      initialRoute: AppRoutes.home,  // Use a more meaningful route here
      routes: AppRoutes.getRoutes(),

      // ✅ Apply consistent theming
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple, // Optional: your brand color
        fontFamily: 'Roboto', // Optional: or use GoogleFonts
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),


    );
  }
}
