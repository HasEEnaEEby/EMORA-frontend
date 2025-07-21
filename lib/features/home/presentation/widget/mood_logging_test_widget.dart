import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../emotion/services/mood_emotion_service.dart';

class MoodLoggingTestWidget extends StatefulWidget {
  const MoodLoggingTestWidget({super.key});

  @override
  State<MoodLoggingTestWidget> createState() => _MoodLoggingTestWidgetState();
}

class _MoodLoggingTestWidgetState extends State<MoodLoggingTestWidget> {
  final _moodService = MoodEmotionService(GetIt.instance<DioClient>());
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Logging Test'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Logging Debug Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testQuickMoodLog,
              child: const Text('Test Quick Mood Log'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testEndpoints,
              child: const Text('Test All Endpoints'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetMoods,
              child: const Text('Test Get Moods'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _clearResults,
              child: const Text('Clear Results'),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'No tests run yet' : _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '${DateTime.now().toIso8601String()}: $result\n';
    });
  }

  Future<void> _testQuickMoodLog() async {
    setState(() => _isLoading = true);
    try {
      _addResult('🧪 Testing quick mood log...');
      final success = await _moodService.quickLogMood('happiness', 4);
      _addResult('✅ Quick mood log result: $success');
    } catch (e) {
      _addResult('❌ Quick mood log failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testEndpoints() async {
    setState(() => _isLoading = true);
    try {
      _addResult('🧪 Testing all endpoints...');
      final results = await _moodService.testAllEndpoints();
      _addResult('📊 Endpoint results: $results');
    } catch (e) {
      _addResult('❌ Endpoint test failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetMoods() async {
    setState(() => _isLoading = true);
    try {
      _addResult('🧪 Testing get moods...');
      final moods = await _moodService.getUserMoodsEmotions(limit: 5);
      _addResult('📊 Retrieved ${moods.length} moods/emotions');
      
      if (moods.isNotEmpty) {
        final first = moods.first;
        _addResult('📝 First entry: ${first['type']} (${first['intensity']}) at ${first['timestamp']}');
      }
    } catch (e) {
      _addResult('❌ Get moods failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearResults() {
    setState(() => _testResults = '');
  }
} 