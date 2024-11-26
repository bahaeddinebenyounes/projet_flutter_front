import 'package:flutter/material.dart';
import 'package:project_flutter/pages/login_page.dart';
import 'package:project_flutter/pages/register_page.dart';

void main() {
  runApp(App());  // This runs the App widget
}

// The root widget of your application
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData.dark(),
      home: LoginPage(),  // Set the login page as the home page
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
