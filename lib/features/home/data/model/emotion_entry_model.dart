// lib/features/home/data/model/enhanced_emotion_entry_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmotionEntryModel extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String emotion;
  final int intensity;
  final String note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final Map<String, dynamic>? context;
  final String timeOfDay;
  final String privacy;
  final bool isAnonymous;
  final bool shareToCommunity;
  final Map<String, dynamic>? metadata;

  const EmotionEntryModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.emotion,
    required this.intensity,
    required this.note,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.hasLocation,
    this.latitude,
    this.longitude,
    this.locationName,
    this.context,
    required this.timeOfDay,
    this.privacy = 'private',
    this.isAnonymous = false,
    this.shareToCommunity = false,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    emotion,
    intensity,
    note,
    tags,
    createdAt,
    updatedAt,
    hasLocation,
    latitude,
    longitude,
    locationName,
    context,
    timeOfDay,
    privacy,
    isAnonymous,
    shareToCommunity,
    metadata,
  ];

  // Helper getters
  String get formattedTime => DateFormat('HH:mm').format(createdAt.toLocal());
  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt.toLocal());
  String get formattedDateTime => DateFormat('MMM dd, yyyy HH:mm').format(createdAt.toLocal());
  
  String get intensityLabel {
    switch (intensity) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }

  Color get intensityColor {
    switch (intensity) {
      case 1:
        return Colors.red.shade300;
      case 2:
        return Colors.orange.shade300;
      case 3:
        return Colors.yellow.shade300;
      case 4:
        return Colors.lightGreen.shade300;
      case 5:
        return Colors.green.shade400;
      default:
        return Colors.grey.shade300;
    }
  }

  String get emotionEmoji {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
        return '😊';
      case 'excitement':
        return '🤩';
      case 'love':
        return '💝';
      case 'gratitude':
        return '🙏';
      case 'contentment':
        return '😌';
      case 'pride':
        return '😎';
      case 'relief':
        return '😮‍💨';
      case 'hope':
        return '✨';
      case 'enthusiasm':
        return '🔥';
      case 'serenity':
      case 'bliss':
        return '😇';
      case 'sadness':
        return '😢';
      case 'anger':
        return '😠';
      case 'fear':
        return '😨';
      case 'anxiety':
        return '😰';
      case 'frustration':
        return '😤';
      case 'disappointment':
        return '😞';
      case 'loneliness':
        return '🥺';
      case 'stress':
        return '😓';
      case 'guilt':
        return '😣';
      case 'shame':
        return '😳';
      case 'jealousy':
        return '😒';
      case 'regret':
        return '😔';
      case 'calm':
      case 'peaceful':
        return '😌';
      case 'neutral':
        return '😐';
      case 'focused':
        return '🤔';
      case 'curious':
        return '🤨';
      case 'thoughtful':
      case 'contemplative':
      case 'reflective':
        return '🧐';
      case 'alert':
        return '👀';
      case 'balanced':
        return '⚖️';
      default:
        return '😊';
    }
  }

  Color get moodColor {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
      case 'love':
      case 'gratitude':
      case 'contentment':
      case 'pride':
      case 'relief':
      case 'hope':
      case 'enthusiasm':
      case 'serenity':
      case 'bliss':
        return const Color(0xFF4CAF50); // Green for positive
      case 'sadness':
      case 'anger':
      case 'fear':
      case 'anxiety':
      case 'frustration':
      case 'disappointment':
      case 'loneliness':
      case 'stress':
      case 'guilt':
      case 'shame':
      case 'jealousy':
      case 'regret':
        return const Color(0xFFFF6B6B); // Red for negative
      case 'calm':
      case 'peaceful':
      case 'neutral':
      case 'focused':
      case 'curious':
      case 'thoughtful':
      case 'contemplative':
      case 'reflective':
      case 'alert':
      case 'balanced':
        return const Color(0xFFFFD700); // Yellow for neutral
      default:
        return const Color(0xFF8B5CF6); // Purple for unknown
    }
  }

  bool get isPositiveEmotion {
    const positiveEmotions = [
      'joy', 'happiness', 'excitement', 'love', 'gratitude', 'contentment',
      'pride', 'relief', 'hope', 'enthusiasm', 'serenity', 'bliss'
    ];
    return positiveEmotions.contains(emotion.toLowerCase());
  }

  bool get isNegativeEmotion {
    const negativeEmotions = [
      'sadness', 'anger', 'fear', 'anxiety', 'frustration', 'disappointment',
      'loneliness', 'stress', 'guilt', 'shame', 'jealousy', 'regret'
    ];
    return negativeEmotions.contains(emotion.toLowerCase());
  }

  bool get isNeutralEmotion {
    const neutralEmotions = [
      'calm', 'peaceful', 'neutral', 'focused', 'curious', 'thoughtful',
      'contemplative', 'reflective', 'alert', 'balanced'
    ];
    return neutralEmotions.contains(emotion.toLowerCase());
  }

  // Factory constructor from JSON (backend format)
  factory EmotionEntryModel.fromJson(Map<String, dynamic> json) {
    return EmotionEntryModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: json['type']?.toString() ?? '',
      emotion: json['emotion']?.toString() ?? json['type']?.toString() ?? '',
      intensity: (json['intensity'] ?? 3).toInt(),
      note: json['note']?.toString() ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      hasLocation: json['hasLocation'] ?? false,
      latitude: json['latitude']?.toDouble() ?? json['location']?['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble() ?? json['location']?['longitude']?.toDouble(),
      locationName: json['locationName'] ?? json['location']?['name'],
      context: json['context'] is Map<String, dynamic> 
          ? json['context'] as Map<String, dynamic>
          : null,
      timeOfDay: json['context']?['timeOfDay'] ?? _determineTimeOfDay(),
      privacy: json['privacy'] ?? 'private',
      isAnonymous: json['isAnonymous'] ?? false,
      shareToCommunity: json['shareToCommunity'] ?? false,
      metadata: json['metadata'] is Map<String, dynamic> 
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  // Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'emotion': emotion,
      'intensity': intensity,
      'note': note,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'hasLocation': hasLocation,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'context': context,
      'timeOfDay': timeOfDay,
      'privacy': privacy,
      'isAnonymous': isAnonymous,
      'shareToCommunity': shareToCommunity,
      'metadata': metadata,
    };
  }

  // Copy with method
EmotionEntryModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? emotion,
    int? intensity,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasLocation,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? context,
    String? timeOfDay,
    String? privacy,
    bool? isAnonymous,
    bool? shareToCommunity,
    Map<String, dynamic>? metadata,
  }) {
    return EmotionEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasLocation: hasLocation ?? this.hasLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      context: context ?? this.context,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      privacy: privacy ?? this.privacy,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      shareToCommunity: shareToCommunity ?? this.shareToCommunity,
      metadata: metadata ?? this.metadata,
    );
  }

  static String _determineTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  @override
  String toString() {
    return 'EmotionEntryModel(id: $id, emotion: $emotion, intensity: $intensity, note: $note, createdAt: $createdAt)';
  }
}

// Enhanced Emotion Card Widget
class EnhancedEmotionCard extends StatelessWidget {
  final EmotionEntryModel emotion;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showFullDetails;
  final bool isSelected;

  const EnhancedEmotionCard({
    Key? key,
    required this.emotion,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showFullDetails = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isSelected ? 8 : 2,
      color: isSelected 
          ? emotion.moodColor.withOpacity(0.1)
          : const Color(0xFF1A1A2E),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? emotion.moodColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (emotion.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildNoteSection(),
                ],
                if (emotion.tags.isNotEmpty && showFullDetails) ...[
                  const SizedBox(height: 12),
                  _buildTagsSection(),
                ],
                if (showFullDetails) ...[
                  const SizedBox(height: 12),
                  _buildMetadataSection(),
                ],
                if (showFullDetails && (onEdit != null || onDelete != null)) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: emotion.intensityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            emotion.emotionEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    emotion.emotion.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: emotion.intensityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      emotion.intensityLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    emotion.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  if (emotion.hasLocation) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    if (emotion.locationName != null) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          emotion.locationName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
        _buildIntensityIndicator(),
      ],
    );
  }

  Widget _buildIntensityIndicator() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          height: 4,
          width: 20,
          decoration: BoxDecoration(
            color: index < emotion.intensity
                ? emotion.intensityColor
                : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Text(
        emotion.note,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: emotion.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: emotion.moodColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: emotion.moodColor.withOpacity(0.5),
            ),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: emotion.moodColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetadataRow('Time of Day', emotion.timeOfDay.capitalize()),
        _buildMetadataRow('Date', emotion.formattedDate),
        if (emotion.privacy != 'private')
          _buildMetadataRow('Privacy', emotion.privacy.capitalize()),
        if (emotion.shareToCommunity)
          _buildMetadataRow('Shared', 'Yes'),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onEdit != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: emotion.moodColor,
                side: BorderSide(color: emotion.moodColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 12),
        if (onDelete != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
      ],
    );
  }
}

// Enhanced Today's Journey Widget
class EnhancedTodaysJourneyWidget extends StatelessWidget {
  final List<EmotionEntryModel> todaysEmotions;
  final Function(EmotionEntryModel)? onEmotionTap;
  final VoidCallback? onViewAll;

  const EnhancedTodaysJourneyWidget({
    Key? key,
    required this.todaysEmotions,
    this.onEmotionTap,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (todaysEmotions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildEmotionTimeline(),
          if (todaysEmotions.length > 3) ...[
            const SizedBox(height: 16),
            _buildViewAllButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.timeline,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Today\'s Journey',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          '${todaysEmotions.length} ${todaysEmotions.length == 1 ? 'entry' : 'entries'}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionTimeline() {
    final displayEmotions = todaysEmotions.take(3).toList();
    
    return Column(
      children: displayEmotions.asMap().entries.map((entry) {
        final index = entry.key;
        final emotion = entry.value;
        final isLast = index == displayEmotions.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: emotion.moodColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey.shade600,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Emotion content
            Expanded(
              child: GestureDetector(
                onTap: () => onEmotionTap?.call(emotion),
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: emotion.moodColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: emotion.moodColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            emotion.emotionEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            emotion.emotion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            emotion.formattedTime,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (emotion.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          emotion.note,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildViewAllButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onViewAll,
        icon: const Icon(Icons.visibility, size: 16),
        label: Text('View All ${todaysEmotions.length} Emotions'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8B5CF6),
          side: const BorderSide(color: Color(0xFF8B5CF6)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            'No emotions logged today',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your emotional journey by logging your first feeling of the day!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// String extension for capitalize
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}