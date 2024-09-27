import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<String> sendPasswordRequest({
    required String username,
    required String email,
    required String employeeCode,
  }) async {
    final url = Uri.parse('https://kohr-mailer.onrender.com/sendpassword');

    final body = jsonEncode({
      'username': username,
      'email': email,
      'employeeCode': employeeCode,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String password = responseData['password'];
        return password;
      } else {
        throw Exception(
            "Failed to send password, status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception caught: $error");
      throw Exception("An error occurred: $error");
    }
  }

  Future<void> sendWarningRequest({
    required String username,
    required String email,
    required String date,
  }) async {
    final url = Uri.parse('https://kohr-mailer.onrender.com/warning');

    final body = jsonEncode({
      'username': username,
      'email': email,
      'date': date,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Success: ${responseData['message']}");
      } else {
        throw Exception(
            "Failed to send warning, status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception caught: $error");
      throw Exception("An error occurred: $error");
    }
  }
}
