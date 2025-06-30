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
  late List<String> _avatarOptions;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.userData.selectedAvatar;

    final stepData = widget.step.data;
    _avatarOptions =
        (stepData?['avatars'] as List<dynamic>?)?.cast<String>() ??
        [
          'panda',
          'elephant',
          'horse',
          'rabbit',
          'fox',
          'zebra',
          'bear',
          'pig',
          'raccoon',
        ];
  }

  void _onAvatarSelected(String avatar) {
    setState(() {
      _selectedAvatar = avatar;
    });

    // Save to BLoC
    context.read<OnboardingBloc>().add(SaveAvatar(avatar));
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
          _buildAvatarGrid(),
          const Spacer(flex: 1),
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
    return Expanded(
      flex: 3,
      child: AvatarSelectionGrid(
        avatars: _avatarOptions,
        selectedAvatar: _selectedAvatar,
        onAvatarSelected: _onAvatarSelected,
      ),
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
