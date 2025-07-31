import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/onboarding_entity.dart';
import '../../view_model/bloc/onboarding_bloc.dart';
import '../../view_model/bloc/onboarding_event.dart';
import '../../widget/avatar_selection_grid.dart';
import '../../widget/onboarding_button.dart';

class AvatarPage extends StatefulWidget {
  final OnboardingStepEntity step;
  final UserOnboardingEntity userData;
  final bool canContinue;
  final VoidCallback? onContinue;

  const AvatarPage({
    super.key,
    required this.step,
    required this.userData,
    this.canContinue = false,
    this.onContinue,
  });

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage>
    with AutomaticKeepAliveClientMixin {
  String? _selectedAvatar;
late List<dynamic> _avatarOptions; 

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.userData.selectedAvatar;
    _initializeAvatarOptions();
  }

  void _initializeAvatarOptions() {
    final stepData = widget.step.data;

    final defaultAvatars = [
      'panda',
      'elephant',
      'horse',
      'rabbit',
      'fox',
      'zebra',
      'bear',
      'pig',
      'raccoon',
      'cat',
      'dog',
      'lion',
    ];

    if (stepData != null) {
      List<dynamic> apiAvatars = [];

      if (stepData['avatars'] is List) {
        apiAvatars = stepData['avatars'] as List<dynamic>? ?? [];
      } else if (stepData['options'] is List) {
        apiAvatars = stepData['options'] as List<dynamic>? ?? [];
      } else if (stepData is List) {
        apiAvatars = stepData as List<dynamic>;
      }

      if (apiAvatars.isNotEmpty) {
        _avatarOptions = apiAvatars;
        print('. Avatar options from API: ${_avatarOptions.length} items');

        for (int i = 0; i < _avatarOptions.length && i < 3; i++) {
          print(
            '  Avatar $i: ${_avatarOptions[i]} (${_avatarOptions[i].runtimeType})',
          );
        }
      } else {
        _avatarOptions = defaultAvatars;
        print(
          '. Avatar options from default (API structure empty): ${_avatarOptions.length} items',
        );
      }
    } else {
      _avatarOptions = defaultAvatars;
      print(
        '. Avatar options from default (no API data): ${_avatarOptions.length} items',
      );
    }

    if (_selectedAvatar != null) {
      final extractedValues = _avatarOptions.map(_extractAvatarValue).toList();
      final isValidSelection = extractedValues.contains(_selectedAvatar);

      if (!isValidSelection) {
        print(
          '. Current selection "$_selectedAvatar" not in available options, clearing selection',
        );
        _selectedAvatar = null;
      }
    }
  }

  String _extractAvatarValue(dynamic avatar) {
    if (avatar is String) {
      return avatar;
    } else if (avatar is Map<String, dynamic>) {
      return avatar['value']?.toString() ??
          avatar['name']?.toString() ??
          avatar['id']?.toString() ??
          avatar['avatar']?.toString() ??
          avatar.toString();
    } else {
      return avatar.toString();
    }
  }

  void _onAvatarSelected(String avatarValue) {
    setState(() {
      _selectedAvatar = avatarValue;
    });

    print('. Saving avatar: "$avatarValue"');
    print(
      '. Available options: ${_avatarOptions.map(_extractAvatarValue).join(', ')}',
    );

    context.read<OnboardingBloc>().add(SaveAvatar(avatarValue));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          _buildHeaderText(),
          const SizedBox(height: 32),
          _buildDescriptionText(),
          const SizedBox(height: 40),
          Expanded(flex: 3, child: _buildAvatarGrid()),
          const SizedBox(height: 20),
          _buildContinueButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const TextSpan(
                text: ' ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Text(
          widget.step.subtitle,
          style: const TextStyle(
            color: Color(0xFF8B5FBF),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      widget.step.description,
      style: TextStyle(
        color: Colors.grey[300],
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  Widget _buildAvatarGrid() {
    if (_avatarOptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No avatars available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return AvatarSelectionGrid(
avatars: _avatarOptions, 
      selectedAvatar: _selectedAvatar,
      onAvatarSelected: _onAvatarSelected,
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
    );
  }

  Widget _buildContinueButton() {
    return OnboardingButton(
      text: 'Continue',
      isEnabled: widget.canContinue,
      onPressed: widget.onContinue,
      icon: Icons.arrow_forward,
    );
  }
}
