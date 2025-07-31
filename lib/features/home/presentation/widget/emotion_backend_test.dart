import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../core/utils/logger.dart';
import 'backend_integration_service.dart';

class EmotionBackendTest extends StatefulWidget {
  const EmotionBackendTest({super.key});

  @override
  State<EmotionBackendTest> createState() => _EmotionBackendTestState();
}

class _EmotionBackendTestState extends State<EmotionBackendTest> {
  late EmotionBackendService _emotionService;
  bool _isLoading = false;
  String _statusMessage = 'Ready to test EMORA backend connection';
  Color _statusColor = Colors.grey;
  Map<String, dynamic>? _testResults;

  @override
  void initState() {
    super.initState();
    _emotionService = di.sl<EmotionBackendService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'EMORA Backend Test',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),

            _buildTestButtons(),
            const SizedBox(height: 20),

            if (_testResults != null) _buildResultsDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            _isLoading
                ? Icons.sync
                : _statusColor == Colors.green
                ? Icons.check_circle
                : _statusColor == Colors.red
                ? Icons.error
                : Icons.info,
            size: 48,
            color: _statusColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Backend Status',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _statusColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
                strokeWidth: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Tests',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        _buildTestButton(
          'Health Check',
          'Test backend connectivity',
          Icons.favorite,
          Colors.green,
          _testHealthCheck,
        ),
        const SizedBox(height: 12),

        _buildTestButton(
          'Global Stats',
          'Get global emotion statistics',
          Icons.bar_chart,
          Colors.blue,
          _testGlobalStats,
        ),
        const SizedBox(height: 12),

        _buildTestButton(
          'Global Heatmap',
          'Get global emotion heatmap',
          Icons.map,
          Colors.orange,
          _testGlobalHeatmap,
        ),
        const SizedBox(height: 12),

        _buildTestButton(
          'Emotion Feed',
          'Get public emotion feed',
          Icons.feed,
          Colors.purple,
          _testEmotionFeed,
        ),
        const SizedBox(height: 12),

        _buildTestButton(
          'Venting Session',
          'Submit anonymous venting session',
          Icons.psychology,
          Colors.pink,
          _testVentingSession,
        ),
        const SizedBox(height: 12),

        _buildTestButton(
          'Run All Tests',
          'Execute complete test suite',
          Icons.play_arrow,
          const Color(0xFF8B5CF6),
          _runAllTests,
        ),
      ],
    );
  }

  Widget _buildTestButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsDisplay() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Test Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _testResults!.entries.map((entry) {
                final isSuccess = entry.value['success'] == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              entry.value['message'] ??
                                  (isSuccess ? 'Success' : 'Failed'),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testHealthCheck() async {
    await _runTest('Health Check', () async {
      final isHealthy = await _emotionService.checkBackendHealth();
      return {
        'success': isHealthy,
        'message': isHealthy
            ? 'Backend is healthy and responding'
            : 'Backend health check failed',
      };
    });
  }

  Future<void> _testGlobalStats() async {
    await _runTest('Global Stats', () async {
      final stats = await _emotionService.getGlobalEmotionStats();
      return {
        'success': stats != null,
        'message': stats != null
            ? 'Retrieved global stats with ${stats.totalEmotions} total emotions'
            : 'Failed to retrieve global stats',
      };
    });
  }

  Future<void> _testGlobalHeatmap() async {
    await _runTest('Global Heatmap', () async {
      final heatmapData = await _emotionService.getGlobalEmotionMap();
      return {
        'success': heatmapData.isNotEmpty,
        'message': heatmapData.isNotEmpty
            ? 'Retrieved ${heatmapData.length} heatmap locations'
            : 'No heatmap data available',
      };
    });
  }

  Future<void> _testEmotionFeed() async {
    await _runTest('Emotion Feed', () async {
      final feed = await _emotionService.getEmotionFeed();
      return {
        'success': feed.isNotEmpty,
        'message': feed.isNotEmpty
            ? 'Retrieved ${feed.length} emotion entries'
            : 'No emotion feed data available',
      };
    });
  }

  Future<void> _testVentingSession() async {
    await _runTest('Venting Session', () async {
      final success = await _emotionService.submitVentingSession(
        sessionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        duration: 120,
        emotionBefore: 'anger',
        emotionAfter: 'calm',
        intensity: {'before': 0.8, 'after': 0.3},
        thoughts: 'This is a test venting session from the Flutter app',
      );
      return {
        'success': success,
        'message': success
            ? 'Venting session submitted successfully'
            : 'Failed to submit venting session',
      };
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running comprehensive test suite...';
      _statusColor = Colors.orange;
      _testResults = {};
    });

    await _testHealthCheck();
    await _testGlobalStats();
    await _testGlobalHeatmap();
    await _testEmotionFeed();
    await _testVentingSession();

    final allPassed = _testResults!.values.every(
      (result) => result['success'] == true,
    );

    setState(() {
      _isLoading = false;
      _statusMessage = allPassed
          ? 'All tests passed! EMORA backend integration successful.'
          : 'Some tests failed. Check results for details.';
      _statusColor = allPassed ? Colors.green : Colors.red;
    });
  }

  Future<void> _runTest(
    String testName,
    Future<Map<String, dynamic>> Function() testFunction,
  ) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running $testName...';
      _statusColor = Colors.orange;
    });

    try {
      final result = await testFunction();
      setState(() {
        _testResults = _testResults ?? {};
        _testResults![testName] = result;

        if (!_isRunningAllTests()) {
          _isLoading = false;
          _statusMessage = result['success']
              ? '$testName completed successfully'
              : '$testName failed';
          _statusColor = result['success'] ? Colors.green : Colors.red;
        }
      });

      Logger.info(
        '. Test completed: $testName - ${result['success'] ? 'SUCCESS' : 'FAILED'}',
      );
    } catch (e) {
      setState(() {
        _testResults = _testResults ?? {};
        _testResults![testName] = {
          'success': false,
          'message': 'Exception: ${e.toString()}',
        };

        if (!_isRunningAllTests()) {
          _isLoading = false;
          _statusMessage = '$testName failed with exception';
          _statusColor = Colors.red;
        }
      });

      Logger.error('. Test failed: $testName', e);
    }
  }

  bool _isRunningAllTests() {
    return _testResults != null && _testResults!.length < 5;
  }
}
