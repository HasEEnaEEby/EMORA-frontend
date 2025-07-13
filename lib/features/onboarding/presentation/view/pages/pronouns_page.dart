// lib/features/onboarding/presentation/view/pages/pronouns_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/onboarding_entity.dart';
import '../../view_model/bloc/onboarding_bloc.dart';
import '../../view_model/bloc/onboarding_event.dart';
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
  late List<Map<String, String>> _pronounOptions;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedPronouns = widget.userData.pronouns;
    _initializePronounOptions();
  }

  void _initializePronounOptions() {
    final stepData = widget.step.data;

    // ✅ FIXED: Use exact backend values for both display and value
    final defaultPronounOptions = [
      {'display': 'She / Her', 'value': 'She / Her'},
      {'display': 'He / Him', 'value': 'He / Him'},
      {'display': 'They / Them', 'value': 'They / Them'},
      {'display': 'Other', 'value': 'Other'},
    ];

    // Try to get options from API response first
    if (stepData != null && stepData['options'] is List) {
      final apiOptions = stepData['options'] as List<dynamic>;
      _pronounOptions = apiOptions
          .map((option) {
            if (option is Map<String, dynamic>) {
              final value = option['value']?.toString() ?? '';
              final label = option['label']?.toString() ?? value;
              return {'display': label, 'value': value};
            } else if (option is String) {
              // Handle simple string options
              final normalized = _normalizePronounValue(option);
              return {'display': option, 'value': normalized};
            } else {
              final optionStr = option.toString();
              final normalized = _normalizePronounValue(optionStr);
              return {'display': optionStr, 'value': normalized};
            }
          })
          .where(
            (option) =>
                option['display']!.isNotEmpty && option['value']!.isNotEmpty,
          )
          .toList();

      print(
        '🔧 Pronoun options from API: ${_pronounOptions.map((o) => '"${o['value']}" (${o['display']})').join(', ')}',
      );
    } else {
      // Fallback to default options if API doesn't provide them
      _pronounOptions = defaultPronounOptions;
      print(
        '🔧 Pronoun options from default: ${_pronounOptions.map((o) => '"${o['value']}" (${o['display']})').join(', ')}',
      );
    }

    // Validate that the current selection is in the available options
    if (_selectedPronouns != null) {
      final isValidSelection = _pronounOptions.any(
        (option) => option['value'] == _selectedPronouns,
      );
      if (!isValidSelection) {
        print(
          '⚠️ Current selection "$_selectedPronouns" not in available options, clearing selection',
        );
        _selectedPronouns = null;
      }
    }
  }

  String _normalizePronounValue(String input) {
    // ✅ FIXED: Normalize to exact backend format
    switch (input.toLowerCase().replaceAll(' ', '').replaceAll('/', '')) {
      case 'sheher':
        return 'She / Her';
      case 'hehim':
        return 'He / Him';
      case 'theythem':
        return 'They / Them';
      case 'other':
        return 'Other';
      default:
        // If already in correct format, keep it
        if (['She / Her', 'He / Him', 'They / Them', 'Other'].contains(input)) {
          return input;
        }
        return 'Other'; // Safe fallback
    }
  }

  void _onPronounsSelected(String pronounValue) {
    setState(() {
      _selectedPronouns = pronounValue;
    });

    print('💾 Saving pronouns: "$pronounValue"');
    print(
      '📋 Available options: ${_pronounOptions.map((o) => '"${o['value']}"').join(', ')}',
    );

    context.read<OnboardingBloc>().add(SavePronouns(pronounValue));
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
          _buildPronounOptions(),
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
      children: _pronounOptions.map((pronounOption) {
        final displayText = pronounOption['display']!;
        final value = pronounOption['value']!;
        final isSelected = _selectedPronouns == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OnboardingOptionButton(
            text: displayText,
            isSelected: isSelected,
            onTap: () => _onPronounsSelected(value),
            icon: _getPronounIcon(value),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPronounIcon(String pronouns) {
    switch (pronouns.toLowerCase()) {
      case 'she/her':
        return Icons.person;
      case 'he/him':
        return Icons.person;
      case 'they/them':
        return Icons.people;
      case 'other':
        return Icons.person_outline;
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
