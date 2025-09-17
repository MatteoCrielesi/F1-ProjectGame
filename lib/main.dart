import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'postgres_service.dart';
import 'game_page.dart';
import 'game_page_1.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = PostgresService();

  final pilota = await db.getPilota();
  print(pilota);
  runApp(const F1App());
}

class F1App extends StatelessWidget {
  const F1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Project',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      //home: const GamePage(),
      //home: const GamePage_1(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
    );
  }
}
