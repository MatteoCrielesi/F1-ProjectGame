import 'package:flutter/material.dart';
import 'splash_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  
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
      
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
    );
  }
}
