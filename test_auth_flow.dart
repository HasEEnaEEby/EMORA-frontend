// test_auth_flow.dart - Test authentication flow after fixes
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Authentication Flow...');
  
  const baseUrl = 'http://localhost:8000';
  
  // Test user credentials that should be working
  final testUser = {
    'username': 'sofiya',
    'password': 'Haseenakc@123',
  };
  
  try {
    // Step 1: Test Login
    print('\n🔐 Step 1: Testing login...');
    
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(testUser),
    );
    
    print('📤 Login Request: ${testUser['username']}');
    print('📨 Response Status: ${loginResponse.statusCode}');
    print('📥 Response Body: ${loginResponse.body}');
    
    if (loginResponse.statusCode == 200) {
      final data = jsonDecode(loginResponse.body);
      
      if (data['success'] == true) {
        print('✅ Login successful!');
        
        final token = data['data']['token'];
        final user = data['data']['user'];
        
        print('🔑 Token received: ${token.substring(0, 20)}...');
        print('👤 User: ${user['username']}');
        
        // Step 2: Test authenticated request
        print('\n🔒 Step 2: Testing authenticated request...');
        
        final homeResponse = await http.get(
          Uri.parse('$baseUrl/api/user/home-data'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        print('📨 Home Data Status: ${homeResponse.statusCode}');
        print('📥 Home Data Body: ${homeResponse.body}');
        
        if (homeResponse.statusCode == 200) {
          print('✅ Authenticated request successful!');
        } else {
          print('❌ Authenticated request failed');
        }
        
      } else {
        print('❌ Login failed: ${data['message']}');
      }
    } else {
      print('❌ Login request failed: ${loginResponse.statusCode}');
      print('📥 Error: ${loginResponse.body}');
    }
    
  } catch (e) {
    print('💥 Test failed with exception: $e');
  }
  
  print('\n🏁 Authentication flow test completed');
} 