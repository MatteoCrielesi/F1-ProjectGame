import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'postgres_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = PostgresService();

  final users = await db.getPilota();
  print(users);
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
      //home: const TireLoader(),
      //home: const ScuderiePage(),
      //home: const RankingPage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
    );
  }
}
