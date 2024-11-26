import 'package:flutter/material.dart';
import 'api_service.dart'; // Your backend API service

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      try {
        await ApiService.register(username, password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please log in.')),
        );
        Navigator.pop(context); // Navigate back to the login page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
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
      appBar: AppBar(title: Text("Register")),
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
                validator: (value) => value?.isEmpty ?? true
                    ? 'Username is required'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Password is required'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                onChanged: (value) => confirmPassword = value,
                validator: (value) => value != password
                    ? 'Passwords do not match'
                    : null,
              ),
              SizedBox(height: 20.0),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleRegister,
                child: Text("Register"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the Login page
                },
                child: Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
