import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Testing Backend Integration...\n');

  // Test 1: Health Check
  print('1. Testing Health Check...');
  try {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:5000/api/health'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    final httpResponse = await request.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    if (httpResponse.statusCode == 200) {
      print('✅ Health check passed');
      final data = json.decode(responseBody);
      print('   Status: ${data['data']['status']}');
      print('   Version: ${data['data']['version']}');
    } else {
      print('❌ Health check failed: ${httpResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Health check error: $e');
  }

  // Test 2: Emotion Constants
  print('\n2. Testing Emotion Constants...');
  try {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:5000/api/emotions/constants'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    final httpResponse = await request.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    if (httpResponse.statusCode == 200) {
      print('✅ Emotion constants retrieved');
      final data = json.decode(responseBody);
      print('   Available emotions: ${data['data']['emotions'].length}');
      print('   Core emotions: ${data['data']['coreEmotions'].length}');
    } else {
      print('❌ Emotion constants failed: ${httpResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Emotion constants error: $e');
  }

  // Test 3: Global Stats
  print('\n3. Testing Global Stats...');
  try {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:5000/api/emotions/global-stats'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    final httpResponse = await request.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    if (httpResponse.statusCode == 200) {
      print('✅ Global stats retrieved');
      final data = json.decode(responseBody);
      print('   Total emotions: ${data['data']['totalEmotions']}');
      print('   Active users: ${data['data']['activeUsers']}');
    } else {
      print('❌ Global stats failed: ${httpResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Global stats error: $e');
  }

  // Test 4: Emotion Feed
  print('\n4. Testing Emotion Feed...');
  try {
    final request = await HttpClient().getUrl(Uri.parse('http://localhost:5000/api/emotions/feed'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    final httpResponse = await request.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    
    if (httpResponse.statusCode == 200) {
      print('✅ Emotion feed retrieved');
      final data = json.decode(responseBody);
      print('   Feed items: ${data['data'].length}');
    } else {
      print('❌ Emotion feed failed: ${httpResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Emotion feed error: $e');
  }

  print('\n🎉 Backend integration test completed!');
} 