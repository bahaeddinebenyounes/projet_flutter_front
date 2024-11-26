import 'package:flutter/material.dart';
import 'package:project_flutter/pages/register_page.dart';
import 'home_page.dart';  // Import the Home page
import 'api_service.dart'; // Your backend API service

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      try {
        // Call the API to login
        final user = await ApiService.login(username, password);
        // Navigate to the Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(size: 8, user: user),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) => username = value,
                validator: (value) => value?.isEmpty ?? true ? 'Username is required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) => value?.isEmpty ?? true ? 'Password is required' : null,
              ),
              SizedBox(height: 20.0),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleLogin,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text("Don’t have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
