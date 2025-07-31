import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';

class EnhancedEmotionEntryModal extends StatefulWidget {
  final Function({String? emotionType, int? intensity, String? note})? onEmotionLogged;
  final Function()? onCommunityPostCreated;

  const EnhancedEmotionEntryModal({
    super.key,
    this.onEmotionLogged,
    this.onCommunityPostCreated,
  });

  @override
  State<EnhancedEmotionEntryModal> createState() => _EnhancedEmotionEntryModalState();
}

class _EnhancedEmotionEntryModalState extends State<EnhancedEmotionEntryModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String selectedEmotion = '';
  int intensity = 3;
  bool shareToCommunity = false;
  bool isLoading = false;
  String? errorMessage;

  final List<Map<String, dynamic>> emotions = [
    {'name': 'joy', 'emoji': '😊', 'color': '#10B981'},
    {'name': 'sadness', 'emoji': '😢', 'color': '#3B82F6'},
    {'name': 'anger', 'emoji': '😠', 'color': '#EF4444'},
    {'name': 'fear', 'emoji': '😨', 'color': '#8B5CF6'},
    {'name': 'surprise', 'emoji': '😲', 'color': '#F59E0B'},
    {'name': 'disgust', 'emoji': '🤢', 'color': '#6366F1'},
    {'name': 'love', 'emoji': '🥰', 'color': '#EC4899'},
    {'name': 'excitement', 'emoji': '🤩', 'color': '#F59E0B'},
    {'name': 'anxiety', 'emoji': '😰', 'color': '#8B5CF6'},
    {'name': 'calm', 'emoji': '😌', 'color': '#10B981'},
    {'name': 'frustration', 'emoji': '😤', 'color': '#F59E0B'},
    {'name': 'gratitude', 'emoji': '🙏', 'color': '#10B981'},
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F0F23),
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E).withOpacity(0.95),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 0,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.5,
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                              Colors.transparent,
                              const Color(0xFF6366F1).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                      ),
                    ),
                    
                    Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildEmotionSelection(),
                                const SizedBox(height: 32),
                                _buildIntensitySlider(),
                                const SizedBox(height: 32),
                                _buildNoteField(),
                                const SizedBox(height: 24),
                                _buildTagsField(),
                                const SizedBox(height: 24),
                                _buildCommunityToggle(),
                                const SizedBox(height: 40),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF8B5CF6),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Logging your emotion...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.15),
            const Color(0xFF6366F1).withOpacity(0.08),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log Your Emotion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling right now?',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _handleClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Emotion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: emotions.length,
          itemBuilder: (context, index) {
            final emotion = emotions[index];
            final isSelected = selectedEmotion == emotion['name'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedEmotion = emotion['name'];
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Color(int.parse(emotion['color'].replaceAll('#', '0xFF'))).withOpacity(0.8),
                            Color(int.parse(emotion['color'].replaceAll('#', '0xFF'))).withOpacity(0.6),
                          ],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF2A2A3E),
                  border: Border.all(
                    color: isSelected
                        ? Color(int.parse(emotion['color'].replaceAll('#', '0xFF')))
                        : Colors.grey[600]!.withOpacity(0.5),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(int.parse(emotion['color'].replaceAll('#', '0xFF'))).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.2 : 1.0,
                    child: Text(
                      emotion['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Intensity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$intensity/5',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.grey[700],
            thumbColor: const Color(0xFF8B5CF6),
            overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) {
              setState(() {
                intensity = value.round();
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mild',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            Text(
              'Intense',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1B4B).withOpacity(0.8),
                const Color(0xFF312E81).withOpacity(0.6),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _noteController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'How are you feeling? Share your thoughts...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1B4B).withOpacity(0.8),
                const Color(0xFF312E81).withOpacity(0.6),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _tagsController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'work, family, weather, friends...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            maxLength: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withOpacity(0.8),
            const Color(0xFF312E81).withOpacity(0.6),
            const Color(0xFF4C1D95).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: shareToCommunity
                    ? [
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                        const Color(0xFF6366F1).withOpacity(0.2),
                      ]
                    : [
                        Colors.grey[600]!.withOpacity(0.3),
                        Colors.grey[700]!.withOpacity(0.2),
                      ],
              ),
            ),
            child: Icon(
              shareToCommunity
                  ? Icons.share_rounded
                  : Icons.share_outlined,
              color: shareToCommunity ? const Color(0xFF8B5CF6) : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share to Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  shareToCommunity
                      ? 'Your emotion will be shared with the community'
                      : 'Keep this emotion private',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: shareToCommunity,
            onChanged: (value) {
              setState(() {
                shareToCommunity = value;
              });
              HapticFeedback.selectionClick();
            },
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isValid = selectedEmotion.isNotEmpty;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isValid
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              )
            : null,
        color: isValid ? null : Colors.grey[700],
        boxShadow: isValid
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid ? _handleSubmit : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              'Log Emotion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (selectedEmotion.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Logger.info('🔄 Logging emotion: $selectedEmotion with intensity: $intensity');

      final emotionData = {
        'type': selectedEmotion,
        'intensity': intensity,
        'note': _noteController.text.trim(),
        'tags': _parseTags(_tagsController.text.trim()),
        'location': await _getCurrentLocation(),
        'shareToCommunity': shareToCommunity,
      };

      final emotionResponse = await _logEmotionToBackend(emotionData);
      
      if (emotionResponse != null) {
        Logger.info('✅ Emotion logged successfully: ${emotionResponse['id']}');

        if (shareToCommunity) {
          await _createCommunityPost(emotionResponse, emotionData);
        }

        await _refreshData();

        widget.onEmotionLogged?.call(
          emotionType: emotionData['type'] as String?,
          intensity: emotionData['intensity'] as int?,
          note: emotionData['note'] as String?,
        );
        if (shareToCommunity) {
          widget.onCommunityPostCreated?.call();
        }

        _handleClose();
      }
    } catch (error) {
      Logger.error('❌ Error logging emotion: $error');
      setState(() {
        errorMessage = 'Failed to log emotion. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _logEmotionToBackend(Map<String, dynamic> emotionData) async {
    try {
      final apiService = GetIt.instance<ApiService>();
      
      Logger.info('🔄 Sending emotion data to backend:', emotionData);
      Logger.info('🔄 API Base URL: ${AppConfig.apiBaseUrl}');
      Logger.info('🔄 Endpoint: /api/emotions');
      
      final response = await apiService.post(
        '/api/emotions',
        data: {
          'type': emotionData['type'],
          'intensity': emotionData['intensity'],
          'note': emotionData['note'],
          'tags': emotionData['tags'],
          'location': emotionData['location'],
          'shareToCommunity': emotionData['shareToCommunity'],
        },
      );

      Logger.info('✅ Backend response received:', {
        'statusCode': response.statusCode,
        'data': response.data,
      });

      if (response.statusCode == 201) {
        final emotion = response.data['data']['emotion'];
        Logger.info('✅ Emotion logged successfully with ID: ${emotion['id']}');
        return emotion;
      } else {
        Logger.error('❌ Backend returned error status: ${response.statusCode}');
        Logger.error('❌ Response data: ${response.data}');
        throw Exception('Failed to log emotion: ${response.statusCode} - ${response.data}');
      }
    } catch (error) {
      Logger.error('❌ Backend emotion logging error: $error');
      Logger.error('❌ Error details:', error);
      rethrow;
    }
  }

  Future<void> _createCommunityPost(Map<String, dynamic> emotion, Map<String, dynamic> emotionData) async {
    try {
      final apiService = GetIt.instance<ApiService>();
      
      final postData = {
        'emotionId': emotion['id'],
        'type': emotionData['type'],
        'intensity': emotionData['intensity'],
        'note': emotionData['note'],
        'tags': emotionData['tags'],
        'location': emotionData['location'],
        'isPublic': true,
      };

      final response = await apiService.post(
        '/api/community',
        data: postData,
      );

      if (response.statusCode == 201) {
        Logger.info('✅ Community post created successfully');
      } else {
        Logger.warning('⚠️ Failed to create community post: ${response.statusCode}');
      }
    } catch (error) {
      Logger.error('❌ Community post creation error: $error');
    }
  }

  Future<void> _refreshData() async {
    try {
      Logger.info('✅ Emotion logged successfully, data will be refreshed');
    } catch (error) {
      Logger.error('❌ Error refreshing data: $error');
    }
  }

  List<String> _parseTags(String tagsText) {
    if (tagsText.isEmpty) return [];
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>?> _getCurrentLocation() async {
    try {
      return {
        'latitude': 37.785834,
        'longitude': -122.406417,
        'name': 'San Francisco, CA',
      };
    } catch (error) {
      Logger.warning('⚠️ Could not get location: $error');
      return null;
    }
  }

  void _handleClose() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      Navigator.pop(context);
    });
  }
} 