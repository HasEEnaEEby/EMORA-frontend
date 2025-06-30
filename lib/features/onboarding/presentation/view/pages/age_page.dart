import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/onboarding_entity.dart';
import '../../view_model/bloc/onboarding_bloc.dart';
import '../../view_model/bloc/onboarding_event.dart';
import '../../widget/onboarding_button.dart';
import '../../widget/onboarding_option_button.dart';

class AgePage extends StatefulWidget {
  final OnboardingStepEntity step;
  final UserOnboardingEntity userData;
  final bool canContinue;
  final VoidCallback? onContinue;

  const AgePage({
    super.key,
    required this.step,
    required this.userData,
    this.canContinue = false,
    this.onContinue,
  });

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> with AutomaticKeepAliveClientMixin {
  String? _selectedAgeGroup;
  late List<String> _ageOptions;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedAgeGroup = widget.userData.ageGroup;

    final stepData = widget.step.data;
    // FIXED: Use the exact values from the backend API response
    // These are the display values that the backend sends and accepts
    _ageOptions =
        (stepData?['options'] as List<dynamic>?)?.cast<String>() ??
        ['less than 20s', '20s', '30s', '40s', '50s and above'];
  }

  void _onAgeGroupSelected(String ageGroup) {
    setState(() {
      _selectedAgeGroup = ageGroup;
    });

    // FIXED: Save the EXACT value that was selected (no conversion)
    // The backend accepts these display values directly
    context.read<OnboardingBloc>().add(SaveAgeGroup(ageGroup));
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
          _buildAgeOptions(),
          const Spacer(flex: 2),
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
      widget.step.description ??
          'We want to tailor your experience — your age helps us do that better.',
      style: TextStyle(
        color: Colors.grey[300],
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  Widget _buildAgeOptions() {
    return Column(
      children: _ageOptions.map((ageGroup) {
        final isSelected = _selectedAgeGroup == ageGroup;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionButton(
            text: ageGroup, // Use the exact value from backend (e.g., "20s")
            isSelected: isSelected,
            onTap: () => _onAgeGroupSelected(ageGroup), // Save the exact value
            icon: _getAgeIcon(ageGroup),
          ),
        );
      }).toList(),
    );
  }

  IconData _getAgeIcon(String ageGroup) {
    switch (ageGroup.toLowerCase()) {
      case 'less than 20s':
        return Icons.child_care;
      case '20s':
        return Icons.school;
      case '30s':
        return Icons.work;
      case '40s':
        return Icons.family_restroom;
      case '50s and above':
        return Icons.elderly;
      default:
        return Icons.person;
    }
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
