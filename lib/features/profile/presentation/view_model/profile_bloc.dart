// ============================================================================
// 2. FIXED PROFILE BLOC - lib/features/profile/presentation/view_model/profile_bloc.dart
// ============================================================================

import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/get_current_user.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/achievement_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/user_preferences_entity.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/export_user_data.dart';
import '../../domain/usecase/get_achievements.dart';
import '../../domain/usecase/get_user_preferences.dart';
import '../../domain/usecase/get_user_profile.dart';
import '../../domain/usecase/update_user_preferences.dart';
import '../../domain/usecase/update_user_profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final GetUserPreferences _getUserPreferences;
  final UpdateUserPreferences _updateUserPreferences;
  final GetAchievements _getAchievements;
  final ExportUserData _exportUserData;
  final GetCurrentUser _getCurrentUser;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required GetUserPreferences getUserPreferences,
    required UpdateUserPreferences updateUserPreferences,
    required GetAchievements getAchievements,
    required ExportUserData exportUserData,
    required GetCurrentUser getCurrentUser,
  }) : _getUserProfile = getUserProfile,
       _updateUserProfile = updateUserProfile,
       _getUserPreferences = getUserPreferences,
       _updateUserPreferences = updateUserPreferences,
       _getAchievements = getAchievements,
       _exportUserData = exportUserData,
       _getCurrentUser = getCurrentUser,
       super(const ProfileInitial()) {
    // Register all event handlers
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<UpdateSettings>(_onUpdateSettings); // CRITICAL: This was missing
    on<LoadAchievements>(_onLoadAchievements);
    on<ExportData>(_onExportData);
    on<ClearProfileError>(_onClearProfileError);

    Logger.info('✅ ProfileBloc initialized with all event handlers');
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Logger.info('👤 Loading user profile...');
      emit(const ProfileLoading());

      // Get current user first
      final currentUserResult = await _getCurrentUser(NoParams());

      await currentUserResult.fold(
        (failure) async {
          Logger.error('❌ Failed to get current user: ${failure.message}');
          emit(ProfileError(message: 'Please log in to view your profile'));
        },
        (currentUser) async {
          try {
            // Get profile using current user's profile method
            final profileResult = await _getUserProfile.getCurrentUserProfile();

            await profileResult.fold(
              (failure) async {
                Logger.error('❌ Failed to load profile: ${failure.message}');
                emit(
                  ProfileError(
                    message: 'Failed to load profile. Please try again.',
                  ),
                );
              },
              (profile) async {
                Logger.info('✅ Profile loaded: ${profile.username}');

                // Load preferences and achievements in parallel
                UserPreferencesEntity? preferences;
                List<AchievementEntity> achievements = [];

                // Load preferences
                try {
                  final preferencesResult = await _getUserPreferences(
                    GetUserPreferencesParams(userId: currentUser.id),
                  );

                  preferencesResult.fold(
                    (failure) {
                      Logger.warning(
                        '⚠️ Failed to load preferences: ${failure.message}',
                      );
                      // Use default preferences
                      preferences = const UserPreferencesEntity();
                    },
                    (prefs) {
                      preferences = prefs;
                      Logger.info('✅ Preferences loaded successfully');
                    },
                  );
                } catch (e) {
                  Logger.error('💥 Preferences loading error: $e');
                  preferences = const UserPreferencesEntity();
                }

                // Load achievements
                try {
                  final achievementsResult = await _getAchievements(
                    GetAchievementsParams(userId: currentUser.id),
                  );

                  achievementsResult.fold(
                    (failure) {
                      Logger.warning(
                        '⚠️ Failed to load achievements: ${failure.message}',
                      );
                    },
                    (achs) {
                      achievements = achs;
                      Logger.info(
                        '✅ ${achievements.length} achievements loaded',
                      );
                    },
                  );
                } catch (e) {
                  Logger.error('💥 Achievements loading error: $e');
                }

                // Emit loaded state with all data
                emit(
                  ProfileLoaded(
                    profile: profile,
                    preferences: preferences,
                    achievements: achievements,
                  ),
                );
              },
            );
          } catch (e) {
            Logger.error('💥 Profile loading critical error: $e');
            emit(
              ProfileError(message: 'Failed to load profile: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      Logger.error('💥 LoadProfile handler error: $e');
      emit(
        ProfileError(
          message: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // For refresh, just reload the profile
    add(const LoadProfile());
  }


Future<void> _onUpdateProfile(
  UpdateProfile event,
  Emitter<ProfileState> emit,
) async {
  if (state is ProfileLoaded) {
    final currentState = state as ProfileLoaded;

    emit(
      ProfileUpdating(
        profile: currentState.profile,
        preferences: currentState.preferences,
        achievements: currentState.achievements,
      ),
    );

    try {
      Logger.info('🔄 Updating profile with data: ${event.profileData}');

      // Create updated profile entity with proper field mapping
      final updatedProfile = currentState.profile.copyWith(
        // Map 'name' field to display name
        name: event.profileData['name'] ?? 
              event.profileData['displayName'] ?? 
              currentState.profile.name,
        username: event.profileData['username'] ?? currentState.profile.username,
        email: event.profileData['email'] ?? currentState.profile.email,
        avatar: event.profileData['avatar'] ?? currentState.profile.avatar,
        isPrivate: event.profileData['isPrivate'] ?? currentState.profile.isPrivate,
        favoriteEmotion: event.profileData['favoriteEmotion'] ?? 
                        currentState.profile.favoriteEmotion,
        // Add any other fields that might be updated
        bio: event.profileData['bio'] ?? currentState.profile.bio,
      );

      Logger.info('📝 Updated profile entity: ${updatedProfile.toString()}');

      final updateParams = UpdateUserProfileParams(profile: updatedProfile);
      final result = await _updateUserProfile(updateParams);

      result.fold(
        (failure) {
          Logger.error('❌ Profile update failed: ${failure.message}');
          emit(
            ProfileError(
              message: 'Failed to update profile. Please try again.',
              profile: currentState.profile,
              preferences: currentState.preferences,
              achievements: currentState.achievements,
            ),
          );
        },
        (updatedProfileFromServer) {
          Logger.info('✅ Profile updated successfully: ${updatedProfileFromServer.name}');
          emit(
            ProfileLoaded(
              profile: updatedProfileFromServer,
              preferences: currentState.preferences,
              achievements: currentState.achievements,
            ),
          );
        },
      );
    } catch (error) {
      Logger.error('💥 Profile update error: $error');
      emit(
        ProfileError(
          message: 'Failed to update profile. Please try again.',
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );
    }
  } else {
    Logger.error(
      '❌ Cannot update profile: Invalid state ${state.runtimeType}',
    );
    emit(
      const ProfileError(
        message: 'Please reload your profile and try again.',
      ),
    );
  }
}

  Future<void> _onUpdatePreferences(
    UpdatePreferences event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(
        ProfilePreferencesUpdating(
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );

      try {
        // Get current user ID
        final currentUserResult = await _getCurrentUser(NoParams());

        await currentUserResult.fold(
          (failure) async {
            Logger.error(
              '❌ Failed to get current user for preferences update: ${failure.message}',
            );
            emit(
              ProfileError(
                message: 'Please log in to update preferences.',
                profile: currentState.profile,
                preferences: currentState.preferences,
                achievements: currentState.achievements,
              ),
            );
          },
          (currentUser) async {
            try {
              // Convert preferences map to UserPreferencesEntity
              final preferencesEntity = UserPreferencesEntity(
                notificationsEnabled:
                    event.preferences['notificationsEnabled'] ?? true,
                sharingEnabled: event.preferences['sharingEnabled'] ?? false,
                language: event.preferences['language'] ?? 'English',
                theme: event.preferences['theme'] ?? 'Cosmic Purple',
                darkModeEnabled: event.preferences['darkModeEnabled'] ?? true,
                privacySettings: event.preferences['privacySettings'] ?? {},
                customSettings: event.preferences['customSettings'] ?? {},
              );

              final updatePreferencesParams = UpdateUserPreferencesParams(
                userId: currentUser.id,
                preferences: preferencesEntity,
              );

              final result = await _updateUserPreferences(
                updatePreferencesParams,
              );

              result.fold(
                (failure) {
                  Logger.error(
                    '❌ Preferences update failed: ${failure.message}',
                  );
                  emit(
                    ProfileError(
                      message:
                          'Failed to update preferences. Please try again.',
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: currentState.achievements,
                    ),
                  );
                },
                (updatedPreferences) {
                  Logger.info('✅ Preferences updated successfully');
                  emit(
                    ProfileLoaded(
                      profile: currentState.profile,
                      preferences: updatedPreferences,
                      achievements: currentState.achievements,
                    ),
                  );
                },
              );
            } catch (error) {
              Logger.error('💥 Preferences update error: $error');
              emit(
                ProfileError(
                  message: 'Failed to update preferences. Please try again.',
                  profile: currentState.profile,
                  preferences: currentState.preferences,
                  achievements: currentState.achievements,
                ),
              );
            }
          },
        );
      } catch (error) {
        Logger.error('💥 UpdatePreferences handler error: $error');
        emit(
          ProfileError(
            message: 'Failed to update preferences. Please try again.',
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
        );
      }
    } else {
      Logger.error(
        '❌ Cannot update preferences: Invalid state ${state.runtimeType}',
      );
      emit(
        const ProfileError(
          message: 'Please reload your profile and try again.',
        ),
      );
    }
  }

  // CRITICAL: This is the missing UpdateSettings handler
  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Logger.info('📱 Updating settings: ${event.settings}');

      final currentState = state;
      if (currentState is! ProfileLoaded) {
        Logger.warning('⚠️ Cannot update settings: Profile not loaded');
        emit(
          const ProfileError(
            message: 'Profile must be loaded before updating settings',
          ),
        );
        return;
      }

      // Show updating state
      emit(
        ProfilePreferencesUpdating(
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );

      // Get current user
      final currentUserResult = await _getCurrentUser(NoParams());

      await currentUserResult.fold(
        (failure) async {
          Logger.error(
            '❌ Failed to get current user for settings: ${failure.message}',
          );
          emit(
            ProfileError(
              message: 'Authentication error. Please log in again.',
              profile: currentState.profile,
              preferences: currentState.preferences,
              achievements: currentState.achievements,
            ),
          );
        },
        (currentUser) async {
          try {
            // Create new preferences from settings with safe defaults
            final currentPrefs = currentState.preferences;

            final newPreferences = UserPreferencesEntity(
              notificationsEnabled:
                  _getSafeBool(event.settings['notificationsEnabled']) ??
                  currentPrefs?.notificationsEnabled ??
                  true,
              sharingEnabled:
                  _getSafeBool(event.settings['dataSharingEnabled']) ??
                  _getSafeBool(event.settings['sharingEnabled']) ??
                  currentPrefs?.sharingEnabled ??
                  false,
              language:
                  _getSafeString(event.settings['language']) ??
                  currentPrefs?.language ??
                  'English',
              theme:
                  _getSafeString(event.settings['theme']) ??
                  currentPrefs?.theme ??
                  'Cosmic Purple',
              darkModeEnabled:
                  _getSafeBool(event.settings['darkModeEnabled']) ??
                  currentPrefs?.darkModeEnabled ??
                  true,
              privacySettings:
                  _getSafeMap(event.settings['privacySettings']) ??
                  currentPrefs?.privacySettings ??
                  {},
              customSettings:
                  _getSafeMap(event.settings['customSettings']) ??
                  currentPrefs?.customSettings ??
                  {},
            );

            // Update using the use case
            final updateParams = UpdateUserPreferencesParams(
              userId: currentUser.id,
              preferences: newPreferences,
            );

            final result = await _updateUserPreferences(updateParams);

            result.fold(
              (failure) {
                Logger.error('❌ Settings update failed: ${failure.message}');
                emit(
                  ProfileError(
                    message: 'Failed to update settings. Please try again.',
                    profile: currentState.profile,
                    preferences: currentState.preferences,
                    achievements: currentState.achievements,
                  ),
                );
              },
              (updatedPreferences) {
                Logger.info('✅ Settings updated successfully');
                emit(
                  ProfileLoaded(
                    profile: currentState.profile,
                    preferences: updatedPreferences,
                    achievements: currentState.achievements,
                  ),
                );
              },
            );
          } catch (e) {
            Logger.error('❌ Exception during settings update: $e');
            emit(
              ProfileError(
                message: 'Settings update failed. Please try again.',
                profile: currentState.profile,
                preferences: currentState.preferences,
                achievements: currentState.achievements,
              ),
            );
          }
        },
      );
    } catch (e) {
      Logger.error('❌ UpdateSettings handler error: $e');

      // Try to preserve current state
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(
          ProfileError(
            message: 'Settings update failed. Please try again.',
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
        );
      } else {
        emit(
          const ProfileError(
            message: 'Settings update failed. Please reload your profile.',
          ),
        );
      }
    }
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(
        ProfileAchievementsLoading(
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );

      try {
        final currentUserResult = await _getCurrentUser(NoParams());

        await currentUserResult.fold(
          (failure) async {
            Logger.error(
              '❌ Failed to get current user for achievements: ${failure.message}',
            );
            emit(
              ProfileError(
                message: 'Please log in to view achievements.',
                profile: currentState.profile,
                preferences: currentState.preferences,
                achievements: currentState.achievements,
              ),
            );
          },
          (currentUser) async {
            try {
              final achievementsParams = GetAchievementsParams(
                userId: currentUser.id,
              );
              final result = await _getAchievements(achievementsParams);

              result.fold(
                (failure) {
                  Logger.error(
                    '❌ Achievements loading failed: ${failure.message}',
                  );
                  emit(
                    ProfileError(
                      message: 'Failed to load achievements. Please try again.',
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: currentState.achievements,
                    ),
                  );
                },
                (achievements) {
                  Logger.info(
                    '✅ ${achievements.length} achievements loaded successfully',
                  );
                  emit(
                    ProfileLoaded(
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: achievements,
                    ),
                  );
                },
              );
            } catch (error) {
              Logger.error('💥 Achievements loading error: $error');
              emit(
                ProfileError(
                  message: 'Failed to load achievements. Please try again.',
                  profile: currentState.profile,
                  preferences: currentState.preferences,
                  achievements: currentState.achievements,
                ),
              );
            }
          },
        );
      } catch (error) {
        Logger.error('💥 LoadAchievements handler error: $error');
        emit(
          ProfileError(
            message: 'Failed to load achievements. Please try again.',
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
        );
      }
    } else {
      Logger.error(
        '❌ Cannot load achievements: Invalid state ${state.runtimeType}',
      );
      emit(
        const ProfileError(
          message: 'Please reload your profile and try again.',
        ),
      );
    }
  }

  Future<void> _onExportData(
    ExportData event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(
        ProfileDataExporting(
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );

      try {
        final currentUserResult = await _getCurrentUser(NoParams());

        await currentUserResult.fold(
          (failure) async {
            Logger.error(
              '❌ Failed to get current user for data export: ${failure.message}',
            );
            emit(
              ProfileError(
                message: 'Please log in to export data.',
                profile: currentState.profile,
                preferences: currentState.preferences,
                achievements: currentState.achievements,
              ),
            );
          },
          (currentUser) async {
            try {
              final exportParams = ExportUserDataParams(userId: currentUser.id);
              final result = await _exportUserData(exportParams);

              result.fold(
                (failure) {
                  Logger.error('❌ Data export failed: ${failure.message}');
                  emit(
                    ProfileError(
                      message: 'Failed to export data. Please try again.',
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: currentState.achievements,
                    ),
                  );
                },
                (exportMessage) {
                  Logger.info('✅ Data exported successfully');
                  emit(
                    ProfileDataExported(
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: currentState.achievements,
                      exportedData: {'message': exportMessage},
                    ),
                  );
                },
              );
            } catch (error) {
              Logger.error('💥 Data export error: $error');
              emit(
                ProfileError(
                  message: 'Failed to export data. Please try again.',
                  profile: currentState.profile,
                  preferences: currentState.preferences,
                  achievements: currentState.achievements,
                ),
              );
            }
          },
        );
      } catch (error) {
        Logger.error('💥 ExportData handler error: $error');
        emit(
          ProfileError(
            message: 'Failed to export data. Please try again.',
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
        );
      }
    } else {
      Logger.error('❌ Cannot export data: Invalid state ${state.runtimeType}');
      emit(
        const ProfileError(
          message: 'Please reload your profile and try again.',
        ),
      );
    }
  }

  Future<void> _onClearProfileError(
    ClearProfileError event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileError) {
      final errorState = state as ProfileError;
      if (errorState.profile != null) {
        // Return to loaded state if we have profile data
        emit(
          ProfileLoaded(
            profile: errorState.profile!,
            preferences: errorState.preferences,
            achievements: errorState.achievements ?? [],
          ),
        );
      } else {
        // Return to initial state
        emit(const ProfileInitial());
      }
    }
  }

  // Helper methods for type-safe data extraction
  bool? _getSafeBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  String? _getSafeString(dynamic value) {
    if (value is String) return value;
    return null;
  }

  Map<String, dynamic>? _getSafeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
