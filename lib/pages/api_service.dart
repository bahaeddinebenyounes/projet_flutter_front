import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.56.1:8080/api/users'; // Your backend URL
  static const String baseUrl1 = 'http://192.168.56.1:8080/api/level-times'; // Your backend URL

  static Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Registration failed: ${response.body}');
    }
  }
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if the response contains the required keys
        if (jsonResponse.containsKey('username') && jsonResponse['username'] != null) {
          return jsonResponse; // Return the response with the username
        } else {
          throw Exception('Username is missing in the response');
        }
      } catch (e) {
        throw Exception('Login response is not in valid JSON format: $e');
      }
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }



  static Future<void> submitLevelTime(String userId, int level, int time) async {
    try {
      final requestBody = {
        'user_id': userId,
        'level': level,
        'time': time,
      };

      print("Submitting payload: $requestBody"); // Log the request body

      final response = await http.post(
        Uri.parse('$baseUrl1/record'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        print("Level and time submitted successfully!");
      } else {
        print("Failed to submit level time: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to submit level time.");
      }
    } catch (e) {
      print("Error in submitLevelTime: $e");
      throw Exception("Error submitting level time: $e");
    }
  }




}
