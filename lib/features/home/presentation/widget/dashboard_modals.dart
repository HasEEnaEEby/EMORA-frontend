// lib/features/home/presentation/widget/dashboard_modals.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/utils/logger.dart';

// MoodCapsule Model Class
class MoodCapsule {
  final String emotion;
  final Color color;
  final double intensity;
  final String time;
  final String note;

  MoodCapsule({
    required this.emotion,
    required this.color,
    required this.intensity,
    required this.time,
    required this.note,
  });
}

// Mood Update Modal
class MoodUpdateModal extends StatefulWidget {
  final String currentMood;
  final Function(String) onMoodUpdated;

  const MoodUpdateModal({
    super.key,
    required this.currentMood,
    required this.onMoodUpdated,
  });

  @override
  State<MoodUpdateModal> createState() => _MoodUpdateModalState();
}

class _MoodUpdateModalState extends State<MoodUpdateModal>
    with SingleTickerProviderStateMixin {
  String selectedMood = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> moods = [
    {
      'name': 'cloudy hug',
      'description': 'Cozy and contemplative',
      'color': const Color(0xFF87CEEB),
      'icon': '☁️',
    },
    {
      'name': 'golden warmth',
      'description': 'Radiant and optimistic',
      'color': const Color(0xFFFFD700),
      'icon': '☀️',
    },
    {
      'name': 'deep ocean',
      'description': 'Profound and mysterious',
      'color': const Color(0xFF4682B4),
      'icon': '🌊',
    },
    {
      'name': 'forest whisper',
      'description': 'Grounded and peaceful',
      'color': const Color(0xFF4CAF50),
      'icon': '🌲',
    },
    {
      'name': 'purple dream',
      'description': 'Creative and imaginative',
      'color': const Color(0xFF8B5CF6),
      'icon': '🔮',
    },
    {
      'name': 'coral sunset',
      'description': 'Vibrant and energetic',
      'color': const Color(0xFFFF6B6B),
      'icon': '🌅',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedMood = widget.currentMood;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleMoodSelection(String mood) {
    setState(() {
      selectedMood = mood;
    });
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Log selection
    Logger.info('Mood selected: $mood');
  }

  void _updateMood() {
    if (selectedMood.isEmpty) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Update mood
    widget.onMoodUpdated(selectedMood);
    
    // Close modal
    Navigator.pop(context);
    
    // Show success message
    NavigationService.showSuccessSnackBar(
      'Mood updated to "$selectedMood" 💜',
    );
    
    // Log update
    Logger.info('Mood updated to: $selectedMood');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How are you feeling?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose what describes your mood today',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Mood Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: moods.length,
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final isSelected = selectedMood == mood['name'];
                        
                        return GestureDetector(
                          onTap: () => _handleMoodSelection(mood['name']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        mood['color'].withOpacity(0.3),
                                        mood['color'].withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? mood['color'].withOpacity(0.6)
                                    : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mood['color'].withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Mood Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: mood['color'].withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      mood['icon'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Mood Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today feels like a ${mood['name']}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey[300],
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mood['description'],
                                        style: TextStyle(
                                          color: isSelected 
                                              ? Colors.white.withOpacity(0.8) 
                                              : Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Selection Indicator
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: mood['color'],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedMood.isNotEmpty ? _updateMood : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedMood.isNotEmpty 
                            ? const Color(0xFF8B5CF6) 
                            : Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: selectedMood.isNotEmpty 
                            ? const Color(0xFF8B5CF6).withOpacity(0.3) 
                            : null,
                      ),
                      child: Text(
                        selectedMood.isNotEmpty ? 'Update Mood' : 'Select a mood',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Mood Capsule Detail Dialog
class MoodCapsuleDetailDialog extends StatefulWidget {
  final MoodCapsule capsule;

  const MoodCapsuleDetailDialog({super.key, required this.capsule});

  @override
  State<MoodCapsuleDetailDialog> createState() => _MoodCapsuleDetailDialogState();
}

class _MoodCapsuleDetailDialogState extends State<MoodCapsuleDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.capsule.color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.capsule.color.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Capsule
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.capsule.color.withOpacity(0.8),
                            widget.capsule.color.withOpacity(0.4),
                            widget.capsule.color.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.6, 0.8, 1.0],
                        ),
                        border: Border.all(
                          color: widget.capsule.color.withOpacity(0.6),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.capsule.color.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: widget.capsule.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Emotion Title
                    Text(
                      widget.capsule.emotion.toUpperCase(),
                      style: TextStyle(
                        color: widget.capsule.color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Time
                    Text(
                      widget.capsule.time,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.capsule.note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Intensity Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Intensity: ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (index) {
                            final isActive = index < (widget.capsule.intensity * 5).round();
                            return Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? widget.capsule.color
                                    : Colors.grey[700],
                                shape: BoxShape.circle,
                                boxShadow: isActive ? [
                                  BoxShadow(
                                    color: widget.capsule.color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(widget.capsule.intensity * 100).round()}%',
                          style: TextStyle(
                            color: widget.capsule.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.capsule.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: widget.capsule.color.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Venting Modal
class VentingModal extends StatefulWidget {
  const VentingModal({super.key});

  @override
  State<VentingModal> createState() => _VentingModalState();
}

class _VentingModalState extends State<VentingModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String selectedEmotion = 'Overwhelmed';
  bool _isSubmitting = false;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> emotions = [
    {'name': 'Overwhelmed', 'color': const Color(0xFFFF6B6B), 'icon': '😰'},
    {'name': 'Anxious', 'color': const Color(0xFF9370DB), 'icon': '😟'},
    {'name': 'Frustrated', 'color': const Color(0xFFFF8C00), 'icon': '😤'},
    {'name': 'Sad', 'color': const Color(0xFF87CEEB), 'icon': '😢'},
    {'name': 'Angry', 'color': const Color(0xFFDC143C), 'icon': '😠'},
    {'name': 'Confused', 'color': const Color(0xFFDDA0DD), 'icon': '😵'},
    {'name': 'Lonely', 'color': const Color(0xFF708090), 'icon': '😔'},
    {'name': 'Stressed', 'color': const Color(0xFFB22222), 'icon': '😫'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Auto-focus text field after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color get _selectedEmotionColor {
    final emotion = emotions.firstWhere(
      (e) => e['name'] == selectedEmotion,
      orElse: () => emotions[0],
    );
    return emotion['color'];
  }

  Future<void> _submitVent() async {
    if (_controller.text.trim().isEmpty) {
      NavigationService.showErrorSnackBar('Please share what\'s on your mind');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Log the vent
      Logger.info('Vent submitted: $selectedEmotion - ${_controller.text.length} characters');
      
      if (mounted) {
        Navigator.pop(context);
        NavigationService.showSuccessSnackBar(
          'Your feelings have been shared safely. You\'re not alone. 💜',
        );
      }
    } catch (e) {
      Logger.error('Error submitting vent', e);
      if (mounted) {
        NavigationService.showErrorSnackBar('Failed to share. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vent It Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Let it all out. This is a safe space.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Emotion Selection
              Text(
                'How are you feeling?',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emotions.length,
                  itemBuilder: (context, index) {
                    final emotion = emotions[index];
                    final isSelected = selectedEmotion == emotion['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEmotion = emotion['name'];
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    emotion['color'].withOpacity(0.8),
                                    emotion['color'].withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? emotion['color'].withOpacity(0.8)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              emotion['icon'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              emotion['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Text Input
              Text(
                'What\'s on your mind?',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedEmotionColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Express yourself freely...\n\nYour words are safe here. Share what\'s troubling you, what you\'re thinking about, or just let it all out.',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Character Count
              if (_controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_controller.text.length} characters',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedEmotionColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: _selectedEmotionColor.withOpacity(0.3),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Share Safely',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Privacy Note
              Text(
                '🔒 Your words are anonymous and secure. You\'re not alone in this.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Journal Modal
class JournalModal extends StatefulWidget {
  const JournalModal({super.key});

  @override
  State<JournalModal> createState() => _JournalModalState();
}

class _JournalModalState extends State<JournalModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  String selectedPrompt = 'What are you grateful for today?';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> journalPrompts = [
    {
      'prompt': 'What are you grateful for today?',
      'icon': '🙏',
      'color': const Color(0xFF4CAF50),
    },
    {
      'prompt': 'What made you smile recently?',
      'icon': '😊',
      'color': const Color(0xFFFFD700),
    },
    {
      'prompt': 'What progress have you made?',
      'icon': '🌱',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'prompt': 'What would you tell your past self?',
      'icon': '💭',
      'color': const Color(0xFF2196F3),
    },
    {
      'prompt': 'What are you looking forward to?',
      'icon': '✨',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'prompt': 'What lesson did you learn today?',
      'icon': '📚',
      'color': const Color(0xFF9C27B0),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Auto-focus text field after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color get _selectedPromptColor {
    final prompt = journalPrompts.firstWhere(
      (p) => p['prompt'] == selectedPrompt,
      orElse: () => journalPrompts[0],
    );
    return prompt['color'];
  }

  Future<void> _saveJournalEntry() async {
    if (_controller.text.trim().isEmpty) {
      NavigationService.showErrorSnackBar('Please write something in your journal');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Log the journal entry
      Logger.info('Journal entry saved: $selectedPrompt - ${_controller.text.length} characters');
      
      if (mounted) {
        Navigator.pop(context);
        NavigationService.showSuccessSnackBar(
          'Journal entry saved successfully 📝',
        );
      }
    } catch (e) {
      Logger.error('Error saving journal entry',e);
      if (mounted) {
        NavigationService.showErrorSnackBar('Failed to save entry. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recovery Journal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reflect on your growth and healing journey.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Prompt Selection
              Text(
                'Choose a reflection prompt:',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: journalPrompts.length,
                  itemBuilder: (context, index) {
                    final prompt = journalPrompts[index];
                    final isSelected = selectedPrompt == prompt['prompt'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPrompt = prompt['prompt'];
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    prompt['color'].withOpacity(0.3),
                                    prompt['color'].withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? prompt['color'].withOpacity(0.6)
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: prompt['color'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  prompt['icon'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                prompt['prompt'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Selected Prompt Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedPromptColor.withOpacity(0.2),
                      _selectedPromptColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedPromptColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  selectedPrompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Text Input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedPromptColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts here...\n\nTake your time to reflect deeply. There\'s no rush - this is your space for healing and growth.',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Word Count
              if (_controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_controller.text.split(' ').where((word) => word.isNotEmpty).length} words',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveJournalEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPromptColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: _selectedPromptColor.withOpacity(0.3),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Privacy Note
              Text(
                '💝 Your journal entries are private and secure. Keep growing!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}