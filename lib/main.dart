import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'scuderie_page.dart';
import 'ranking_page.dart';

void main() {
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
