import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EnhancedEmotionEntryModal extends StatefulWidget {
  final Function(String emotion, int intensity, String? context, List<String> tags, Position? location, bool isPrivate, bool isAnonymous) onEmotionLogged;

  const EnhancedEmotionEntryModal({
    super.key,
    required this.onEmotionLogged,
  });

  @override
  State<EnhancedEmotionEntryModal> createState() => _EnhancedEmotionEntryModalState();
}

class _EnhancedEmotionEntryModalState extends State<EnhancedEmotionEntryModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form state
  String _selectedEmotion = '';
  int _selectedIntensity = 3;
  final TextEditingController _contextController = TextEditingController();
  List<String> _selectedTags = [];
  Position? _currentLocation;
  bool _isLoadingLocation = false;
  
  // Privacy options
  String _privacyOption = 'private'; // 'private' or 'community'
  bool _isAnonymous = false;

  // Available emotions with emojis
  final List<EmotionOption> _emotions = [
    EmotionOption('happiness', '😊', 'Happy', Colors.green),
    EmotionOption('excitement', '🤩', 'Excited', Colors.orange),
    EmotionOption('gratitude', '🙏', 'Grateful', Colors.purple),
    EmotionOption('contentment', '😌', 'Content', Colors.blue),
    EmotionOption('calm', '😌', 'Calm', Colors.teal),
    EmotionOption('sadness', '😢', 'Sad', Colors.blue),
    EmotionOption('anger', '😠', 'Angry', Colors.red),
    EmotionOption('fear', '😰', 'Afraid', Colors.purple),
    EmotionOption('anxiety', '😰', 'Anxious', Colors.orange),
    EmotionOption('frustration', '😤', 'Frustrated', Colors.red),
  ];

  // Available tags
  final List<String> _availableTags = [
    'work', 'family', 'friends', 'health', 'exercise',
    'food', 'sleep', 'weather', 'music', 'travel',
    'study', 'creative', 'social', 'alone', 'stress'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Handle and Title - Fixed at top
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ).createShader(bounds),
                      child: const Text(
                        'How are you feeling right now?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Emotion Selection
                      _buildEmotionSelection(),

                      const SizedBox(height: 24),

                      // Intensity Selection
                      if (_selectedEmotion.isNotEmpty) _buildIntensitySelection(),

                      if (_selectedEmotion.isNotEmpty) const SizedBox(height: 24),

                      // Context Input
                      _buildContextInput(),

                      const SizedBox(height: 24),

                      // Tags Selection
                      _buildTagsSelection(),

                      const SizedBox(height: 24),

                      // Location Toggle
                      _buildLocationToggle(),

                      const SizedBox(height: 24),

                      // Privacy Options
                      _buildPrivacyOptions(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Action Buttons - Fixed at bottom
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '😊 Select your emotion',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _emotions.map((emotion) {
            final isSelected = _selectedEmotion == emotion.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedEmotion = emotion.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? emotion.color.withOpacity(0.2)
                      : const Color(0xFF1A1A2E).withOpacity(0.5),
                  border: Border.all(
                    color: isSelected
                        ? emotion.color
                        : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emotion.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      emotion.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 How intense is this feeling?',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(5, (index) {
            final intensity = index + 1;
            final isSelected = _selectedIntensity == intensity;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIntensity = intensity),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? const Color(0xFF8B5CF6).withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey[600]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${intensity}',
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _getIntensityLabel(intensity),
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[500],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💭 What\'s happening? (optional)',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contextController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Describe what\'s on your mind...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF1A1A2E).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTagsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏷️ Tags (optional)',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? const Color(0xFF8B5CF6).withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey[600]!,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationToggle() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: _currentLocation != null ? const Color(0xFF8B5CF6) : Colors.grey[500],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 Add location',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentLocation != null)
                Text(
                  'Location captured',
                  style: TextStyle(
                    color: const Color(0xFF8B5CF6),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: _currentLocation != null,
          onChanged: (value) {
            if (value) {
              _getCurrentLocation();
            } else {
              setState(() => _currentLocation = null);
            }
          },
          activeColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildPrivacyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔒 Privacy',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Privacy Options
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _privacyOption = 'private'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _privacyOption == 'private'
                        ? const Color(0xFF8B5CF6).withOpacity(0.2)
                        : const Color(0xFF1A1A2E).withOpacity(0.5),
                    border: Border.all(
                      color: _privacyOption == 'private'
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey[600]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock,
                        color: _privacyOption == 'private'
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey[400],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Private',
                        style: TextStyle(
                          color: _privacyOption == 'private'
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Log only',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _privacyOption = 'community'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _privacyOption == 'community'
                        ? const Color(0xFF8B5CF6).withOpacity(0.2)
                        : const Color(0xFF1A1A2E).withOpacity(0.5),
                    border: Border.all(
                      color: _privacyOption == 'community'
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey[600]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.public,
                        color: _privacyOption == 'community'
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey[400],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Community',
                        style: TextStyle(
                          color: _privacyOption == 'community'
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Share with others',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Anonymous toggle for community posts
        if (_privacyOption == 'community') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.visibility_off,
                color: _isAnonymous ? const Color(0xFF8B5CF6) : Colors.grey[500],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post anonymously',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hide your identity from the community',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
                activeColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final canSubmit = _selectedEmotion.isNotEmpty;
    final isCommunityPost = _privacyOption == 'community';
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[400],
              side: BorderSide(color: Colors.grey[600]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit ? _logEmotion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? const Color(0xFF8B5CF6) : Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isCommunityPost ? 'Post to Community' : 'Log Emotion',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _getIntensityLabel(int intensity) {
    switch (intensity) {
      case 1: return 'Very\nMild';
      case 2: return 'Mild';
      case 3: return 'Moderate';
      case 4: return 'Strong';
      case 5: return 'Very\nStrong';
      default: return '';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      // Handle location error
    }
  }

  void _logEmotion() {
    if (_selectedEmotion.isEmpty) return;
    
    // Always log the emotion privately first
    widget.onEmotionLogged(
      _selectedEmotion,
      _selectedIntensity,
      _contextController.text.trim().isEmpty ? null : _contextController.text.trim(),
      _selectedTags,
      _currentLocation,
      _privacyOption == 'private',
      _isAnonymous,
    );
    
    Navigator.pop(context);
  }
}

class EmotionOption {
  final String id;
  final String emoji;
  final String label;
  final Color color;

  EmotionOption(this.id, this.emoji, this.label, this.color);
} 