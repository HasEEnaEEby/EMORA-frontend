import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/onboarding_entity.dart';
import '../../view_model/bloc/onboarding_bloc.dart';
import '../../view_model/bloc/onboarding_event.dart';
import '../../view_model/bloc/onboarding_state.dart';
import '../../widget/onboarding_button.dart';
import '../../widget/onboarding_option_button.dart';

class PronounsPage extends StatefulWidget {
  final OnboardingStepEntity step;
  final UserOnboardingEntity userData;
  final bool canContinue;
  final VoidCallback? onContinue;

  const PronounsPage({
    super.key,
    required this.step,
    required this.userData,
    this.canContinue = false,
    this.onContinue,
  });

  @override
  State<PronounsPage> createState() => _PronounsPageState();
}

class _PronounsPageState extends State<PronounsPage>
    with AutomaticKeepAliveClientMixin {
  String? _selectedPronouns;
  late List<String> _pronounOptions;
  bool _isSaving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedPronouns = widget.userData.pronouns;
    final stepData = widget.step.data;

    // FIXED: Use the exact values from the backend API response
    // These are the display values that the backend sends and accepts
    _pronounOptions =
        (stepData?['options'] as List<dynamic>?)?.cast<String>() ??
        ['She / Her', 'He / Him', 'They / Them', 'Other'];
  }

  void _onPronounSelected(String pronouns) {
    // Prevent multiple selections while saving
    if (_isSaving) return;

    setState(() {
      _selectedPronouns = pronouns;
      _isSaving = true;
    });

    // FIXED: Save the EXACT value that was selected (no conversion)
    // The backend accepts these display values directly
    context.read<OnboardingBloc>().add(SavePronouns(pronouns));
  }

  void _handleContinue() {
    // Only allow continue if not currently saving
    if (!_isSaving && widget.onContinue != null) {
      widget.onContinue!();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingStepsLoaded) {
          // Reset saving state when data is loaded
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 1),
            _buildHeaderText(),
            const SizedBox(height: 32),
            _buildDescriptionText(),
            const SizedBox(height: 40),
            _buildPronounOptions(),
            const Spacer(flex: 2),
            _buildContinueButton(),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildPronounOptions() {
    return Column(
      children: _pronounOptions.map((pronoun) {
        final isSelected = _selectedPronouns == pronoun;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionButton(
            text:
                pronoun, // Use the exact value from backend (e.g., "She / Her")
            isSelected: isSelected,
            onTap: () => _onPronounSelected(pronoun), // Save the exact value
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    // Show loading state if saving, otherwise check if can continue
    final canContinue = !_isSaving && widget.canContinue;

    return OnboardingButton(
      text: _isSaving ? 'Saving...' : 'Continue',
      isEnabled: canContinue,
      onPressed: canContinue ? _handleContinue : null,
      icon: _isSaving ? null : Icons.arrow_forward,
    );
  }
}
