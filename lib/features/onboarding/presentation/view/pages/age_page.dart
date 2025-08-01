import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/backend_mapping.dart';
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
  late List<Map<String, String>> _ageOptions;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedAgeGroup = widget.userData.ageGroup;
    _initializeAgeOptions();
  }

  void _initializeAgeOptions() {
    _ageOptions = [
      {'display': 'less than 20s', 'value': 'Under 18', 'icon': 'child_care'},
      {'display': '20s', 'value': '18-24', 'icon': 'school'},
      {'display': '30s', 'value': '25-34', 'icon': 'work'},
      {'display': '40s', 'value': '35-44', 'icon': 'family_restroom'},
      {'display': '50s and above', 'value': '45-54', 'icon': 'business'},
    ];

    final stepData = widget.step.data;
    if (stepData != null && stepData['options'] is List) {
      final apiOptions = stepData['options'] as List<dynamic>? ?? [];

      print('. Raw API options received: $apiOptions');

      final List<Map<String, String>> apiMappedOptions = [];

      for (final option in apiOptions) {
        if (option is Map<String, dynamic>) {
          final apiValue = option['value']?.toString() ?? '';
          final label = option['label']?.toString() ?? apiValue;

          final backendValue = BackendValues.normalizeAgeGroupFromApi(apiValue);

          String displayValue = label;
          for (final standardOption in _ageOptions) {
            if (standardOption['value'] == backendValue) {
              displayValue = standardOption['display']!;
              break;
            }
          }

          apiMappedOptions.add({
            'display': displayValue,
            'value': backendValue,
            'icon': _getIconForAgeGroup(backendValue),
          });
        }
      }

      if (apiMappedOptions.isNotEmpty) {
        _ageOptions = apiMappedOptions;
        print('. Using API options mapped to backend values');
      } else {
        print('. API options invalid, using default options');
      }
    } else {
      print('. No API options found, using default options');
    }

    print('. Final age options:');
    for (final option in _ageOptions) {
      print('  "${option['display']}" -> "${option['value']}"');
    }

    if (_selectedAgeGroup != null) {
      final isValidSelection = _ageOptions.any(
        (option) => option['value'] == _selectedAgeGroup,
      );
      if (!isValidSelection) {
        print(
          '. Current selection "$_selectedAgeGroup" not in available options, clearing selection',
        );
        _selectedAgeGroup = null;
      } else {
        print('. Current selection "$_selectedAgeGroup" is valid');
      }
    }
  }

  String _getIconForAgeGroup(String ageGroup) {
    switch (ageGroup) {
      case 'Under 18':
        return 'child_care';
      case '18-24':
        return 'school';
      case '25-34':
        return 'work';
      case '35-44':
        return 'family_restroom';
      case '45-54':
        return 'business';
      case '55-64':
        return 'elderly';
      case '65+':
        return 'elderly';
      default:
        return 'person';
    }
  }

  void _onAgeGroupSelected(String backendAgeGroupValue) {
    setState(() {
      _selectedAgeGroup = backendAgeGroupValue;
    });

    if (!BackendValues.isValidBackendAgeGroup(backendAgeGroupValue)) {
      print('. ERROR: Invalid backend age group: "$backendAgeGroupValue"');
      print('. Valid options: ${BackendValues.validBackendAgeGroups}');
      return;
    }

    final displayValue = BackendValues.getFrontendAgeGroup(
      backendAgeGroupValue,
    );

    print('. Age group selected:');
    print('  . Display: "$displayValue"');
    print('  . Backend: "$backendAgeGroupValue"');
    print(
      '  . Valid: ${BackendValues.isValidBackendAgeGroup(backendAgeGroupValue)}',
    );

    context.read<OnboardingBloc>().add(SaveAgeGroup(backendAgeGroupValue));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

final headerSpace = 120.0; 
final buttonSpace = 80.0;  
final paddingSpace = 48.0; 
final spacingBetween = 32.0 + 40.0; 
    
    final optionsAvailableSpace = availableHeight - headerSpace - buttonSpace - paddingSpace - spacingBetween;
final optionHeight = (optionsAvailableSpace / _ageOptions.length) - 8; 
final finalOptionHeight = optionHeight.clamp(44.0, 56.0); 

    print('. Layout calculations:');
    print('  Screen height: $screenHeight');
    print('  Available height: $availableHeight');
    print('  Options space: $optionsAvailableSpace');
    print('  Option height: $finalOptionHeight');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: headerSpace,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Expanded(child: _buildHeaderText()),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
height: 48, 
                child: _buildDescriptionText(),
              ),
              
              const SizedBox(height: 40),
              
              Expanded(
                child: _ageOptions.length > 5 
                    ? _buildScrollableOptions(finalOptionHeight)
                    : _buildFixedOptions(finalOptionHeight),
              ),
              
              SizedBox(
                height: buttonSpace,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(child: _buildContinueButton()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.step.title,
                  style: const TextStyle(
                    color: Colors.white,
fontSize: 28, 
                    fontWeight: FontWeight.w600,
height: 1.1, 
                  ),
                ),
                const TextSpan(
                  text: ' ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.step.subtitle,
          style: const TextStyle(
            color: Color(0xFF8B5FBF),
fontSize: 28, 
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      widget.step.description,
      style: TextStyle(
        color: Colors.grey[300],
fontSize: 14, 
        fontWeight: FontWeight.w400,
height: 1.3, 
      ),
maxLines: 3, 
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildScrollableOptions(double optionHeight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: _ageOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final ageOption = entry.value;
          final displayText = ageOption['display']!;
          final backendValue = ageOption['value']!;
          final iconName = ageOption['icon'] ?? 'person';
          final isSelected = _selectedAgeGroup == backendValue;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _ageOptions.length - 1 ? 8 : 0,
            ),
            child: OnboardingOptionButton(
              text: displayText,
              isSelected: isSelected,
              onTap: () => _onAgeGroupSelected(backendValue),
              icon: _getIconData(iconName),
height: optionHeight, 
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFixedOptions(double optionHeight) {
    return Column(
      children: _ageOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final ageOption = entry.value;
        final displayText = ageOption['display']!;
        final backendValue = ageOption['value']!;
        final iconName = ageOption['icon'] ?? 'person';
        final isSelected = _selectedAgeGroup == backendValue;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: index < _ageOptions.length - 1 ? 8 : 0,
            ),
            child: OnboardingOptionButton(
              text: displayText,
              isSelected: isSelected,
              onTap: () => _onAgeGroupSelected(backendValue),
              icon: _getIconData(iconName),
height: double.infinity, 
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'child_care':
        return Icons.child_care;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'business':
        return Icons.business;
      case 'elderly':
        return Icons.elderly;
      default:
        return Icons.person;
    }
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: OnboardingButton(
        text: 'Continue',
        isEnabled: widget.canContinue,
        onPressed: widget.onContinue,
        icon: Icons.arrow_forward,
      ),
    );
  }
}
