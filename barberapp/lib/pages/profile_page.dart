// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'login_register_page.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String profileImageUrl = '';
  bool showPassword = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    final response = await http.get(
      Uri.parse('http://127.0.0.1:3000/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      setState(() {
        name = data['name'];
        email = data['email'];
        profileImageUrl = data['profile_image_url'] ?? '';
      });
    } else {
      print('Failed to fetch profile data');
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Upload the image to the server
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:3000/upload-profile-image'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        // Update profile image URL
        final responseData = await response.stream.bytesToString();
        setState(() {
          profileImageUrl = jsonDecode(responseData)['profile_image_url'];
        });
      } else {
        print('Failed to upload profile image');
      }
    }
  }

  Future<void> _resetPassword() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/send-reset-email'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset email sent successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email')),
      );
    }
  }

  Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken'); // Șterge token-ul
  await prefs.setBool('isLoggedIn', false); // Marchează ca delogat
  
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()),); // Navighează la Login/Register
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Name: $name', style: TextStyle(fontSize: 18)),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Text(
                  'Password: ${showPassword ? 'password123' : '********'}',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Reset Password'),
            ),
            ElevatedButton(
              onPressed: logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
