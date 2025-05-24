import 'package:flutter/material.dart';
import 'pantallas/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal, // Cambiamos a un verde más suave
        scaffoldBackgroundColor: Colors.white, // Fondo blanco para una sensación más limpia
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 30, 
            fontWeight: FontWeight.bold, 
            color: Colors.teal, // Título en verde suave
          ),
          bodyMedium: TextStyle(
            fontSize: 18, 
            color: Colors.black54, // Texto en negro suave para una mejor lectura
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Fondo verde suave para los botones
            foregroundColor: Colors.white, // Texto blanco en los botones
            minimumSize: const Size(200, 50), // Tamaño de los botones
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}