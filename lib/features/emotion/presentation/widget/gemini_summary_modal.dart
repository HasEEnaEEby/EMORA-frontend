import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiSummaryModal extends StatelessWidget {
  final String region;
  const GeminiSummaryModal({super.key, required this.region});

  Future<Map<String, dynamic>> _fetchInsights() async {
    final url = Uri.parse('http://localhost:8000/api/insight/$region');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'summary': data['data']['summary'] ?? 'No summary available.',
        'dominantEmotion': data['data']['dominantEmotion'] ?? 'Unknown',
        'emotionCount': data['data']['emotionCount'] ?? 0,
        'trend': data['data']['trend'] ?? 'stable',
        'topEmotions': data['data']['topEmotions'] ?? [],
        'communitySentiment': data['data']['communitySentiment'] ?? 'neutral',
      };
    } else {
      throw Exception('Failed to load insights');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchInsights(),
      builder: (context, snapshot) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                    ),
                    child: Icon(Icons.psychology, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Insights for ${region[0].toUpperCase()}${region.substring(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Real-time emotional intelligence',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              if (snapshot.connectionState == ConnectionState.waiting)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                        SizedBox(height: 16),
                        Text(
                          'Analyzing emotional patterns...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (snapshot.hasError)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (snapshot.hasData)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInsightCard(
                          'Summary',
                          snapshot.data!['summary'],
                          Icons.summarize,
                          Color(0xFF4CAF50),
                        ),
                        
                        SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Dominant Emotion',
                                snapshot.data!['dominantEmotion'],
                                Icons.sentiment_satisfied,
                                Color(0xFFFFD700),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Emotion Count',
                                '${snapshot.data!['emotionCount']}',
                                Icons.people,
                                Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildInsightCard(
                          'Trend',
                          'Emotional trend is ${snapshot.data!['trend']}',
                          Icons.trending_up,
                          Color(0xFFFF9800),
                        ),
                        
                        SizedBox(height: 16),
                        
                        _buildInsightCard(
                          'Community Sentiment',
                          'Overall sentiment is ${snapshot.data!['communitySentiment']}',
                          Icons.favorite,
                          Color(0xFFE91E63),
                        ),
                        
                        SizedBox(height: 16),
                        
                        if (snapshot.data!['topEmotions'] is List && 
                            (snapshot.data!['topEmotions'] as List).isNotEmpty)
                          _buildTopEmotionsCard(snapshot.data!['topEmotions']),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopEmotionsCard(List emotions) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFF8B5CF6).withValues(alpha: 0.1),
        border: Border.all(color: Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_emotions, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text(
                'Top Emotions',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((emotion) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF8B5CF6).withValues(alpha: 0.2),
                ),
                child: Text(
                  emotion.toString().toUpperCase(),
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 