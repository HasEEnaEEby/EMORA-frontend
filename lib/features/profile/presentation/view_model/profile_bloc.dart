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
    
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<UpdateSettings>(_onUpdateSettings);
    on<UpdateAvatar>(_onUpdateAvatar);
    on<LoadAchievements>(_onLoadAchievements);
    on<ExportData>(_onExportData);
    on<ClearProfileError>(_onClearProfileError);
    on<ClearProfileCache>(_onClearProfileCache);

    Logger.info('✅ ProfileBloc initialized with all event handlers');
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Logger.info('🔄 Loading user profile...');
      emit(const ProfileLoading());

      final currentUserResult = await _getCurrentUser(NoParams());

      await currentUserResult.fold(
        (failure) async {
          Logger.error('❌ Failed to get current user: ${failure.message}');
          emit(ProfileError(message: 'Please log in to view your profile'));
        },
        (currentUser) async {
          try {
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
                Logger.info('📊 Profile data: name="${profile.name}", email="${profile.email}", avatar="${profile.avatar}"');

                UserPreferencesEntity? preferences;
                List<AchievementEntity> achievements = [];

                try {
                  final preferencesResult = await _getUserPreferences(
                    GetUserPreferencesParams(userId: currentUser.id),
                  );

                  preferencesResult.fold(
                    (failure) {
                      Logger.warning('⚠️ Failed to load preferences: ${failure.message}');
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

                try {
                  final achievementsResult = await _getAchievements(
                    GetAchievementsParams(userId: currentUser.id),
                  );

                  achievementsResult.fold(
                    (failure) {
                      Logger.warning('⚠️ Failed to load achievements: ${failure.message}');
                      achievements = _createDefaultAchievements(profile);
                    },
                    (achs) {
                      achievements = achs.isNotEmpty ? achs : _createDefaultAchievements(profile);
                      Logger.info('✅ ${achievements.length} achievements loaded');
                    },
                  );
                } catch (e) {
                  Logger.error('💥 Achievements loading error: $e');
                  achievements = _createDefaultAchievements(profile);
                }

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
    try {
      Logger.info('🔄 Refreshing profile...');
      
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        
        emit(
          ProfileLoading(
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
        );
      }
      
    add(const LoadProfile());
    } catch (e) {
      Logger.error('💥 RefreshProfile error: $e');
      emit(ProfileError(message: 'Failed to refresh profile'));
    }
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

        final optimisticProfile = _createOptimisticUpdate(currentState.profile, event.profileData);
        
        emit(
          ProfileLoaded(
            profile: optimisticProfile,
            preferences: currentState.preferences,
            achievements: currentState.achievements,
          ),
      );

        final updateParams = UpdateUserProfileParams(profile: optimisticProfile);
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
          
            Future.delayed(const Duration(milliseconds: 1000), () {
            if (!isClosed) {
              add(const RefreshProfile());
            }
          });
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
      Logger.error('❌ Cannot update profile: Invalid state ${state.runtimeType}');
    emit(
      const ProfileError(
        message: 'Please reload your profile and try again.',
      ),
    );
  }
}

  Future<void> _onUpdateAvatar(
    UpdateAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Logger.info('🎭 Updating avatar to ${event.avatarName}');

      if (state is! ProfileLoaded) {
        emit(ProfileError(message: 'No profile loaded to update avatar'));
        return;
      }

      final currentState = state as ProfileLoaded;
      
      final updatedProfile = currentState.profile.copyWith(
        avatar: event.avatarName,
      );

      emit(ProfileLoaded(
        profile: updatedProfile,
        preferences: currentState.preferences,
        achievements: currentState.achievements,
      ));

      final updateData = {
        'avatar': event.avatarName,
        'selectedAvatar': event.avatarName,
        'name': currentState.profile.name,
        'email': currentState.profile.email,
        'bio': currentState.profile.bio,
        'pronouns': currentState.profile.pronouns,
        'ageGroup': currentState.profile.ageGroup,
        'themeColor': currentState.profile.themeColor,
      };

      add(UpdateProfile(profileData: updateData));
      
    } catch (error) {
      Logger.error('❌ Error updating avatar: $error');
      emit(ProfileError(message: 'Failed to update avatar: ${error.toString()}'));
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
        final currentUserResult = await _getCurrentUser(NoParams());

        await currentUserResult.fold(
          (failure) async {
            Logger.error('❌ Failed to get current user for preferences update: ${failure.message}');
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
              final preferencesEntity = UserPreferencesEntity(
                notificationsEnabled: event.preferences['notificationsEnabled'] ?? true,
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

              final result = await _updateUserPreferences(updatePreferencesParams);

              result.fold(
                (failure) {
                  Logger.error('❌ Preferences update failed: ${failure.message}');
                  emit(
                    ProfileError(
                      message: 'Failed to update preferences. Please try again.',
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
    }
  }

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

      emit(
        ProfilePreferencesUpdating(
          profile: currentState.profile,
          preferences: currentState.preferences,
          achievements: currentState.achievements,
        ),
      );

      final currentUserResult = await _getCurrentUser(NoParams());

      await currentUserResult.fold(
        (failure) async {
          Logger.error('❌ Failed to get current user for settings: ${failure.message}');
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
            final currentPrefs = currentState.preferences;

            final newPreferences = UserPreferencesEntity(
              notificationsEnabled: _getSafeBool(event.settings['notificationsEnabled']) ?? 
                                  currentPrefs?.notificationsEnabled ?? true,
              sharingEnabled: _getSafeBool(event.settings['dataSharingEnabled']) ?? 
                  _getSafeBool(event.settings['sharingEnabled']) ??
                            currentPrefs?.sharingEnabled ?? false,
              language: _getSafeString(event.settings['language']) ?? 
                       currentPrefs?.language ?? 'English',
              theme: _getSafeString(event.settings['theme']) ?? 
                    currentPrefs?.theme ?? 'Cosmic Purple',
              darkModeEnabled: _getSafeBool(event.settings['darkModeEnabled']) ?? 
                             currentPrefs?.darkModeEnabled ?? true,
              privacySettings: _getSafeMap(event.settings['privacySettings']) ?? 
                             currentPrefs?.privacySettings ?? {},
              customSettings: _getSafeMap(event.settings['customSettings']) ?? 
                            currentPrefs?.customSettings ?? {},
            );

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
            Logger.error('💥 Exception during settings update: $e');
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
      Logger.error('💥 UpdateSettings handler error: $e');
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
            Logger.error('❌ Failed to get current user for achievements: ${failure.message}');
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
              final achievementsParams = GetAchievementsParams(userId: currentUser.id);
              final result = await _getAchievements(achievementsParams);

              result.fold(
                (failure) {
                  Logger.error('❌ Achievements loading failed: ${failure.message}');
                  final defaultAchievements = _createDefaultAchievements(currentState.profile);
                  emit(
                    ProfileLoaded(
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: defaultAchievements,
                    ),
                  );
                },
                (achievements) {
                  Logger.info('✅ ${achievements.length} achievements loaded successfully');
                  final mergedAchievements = _mergeWithDefaultAchievements(achievements, currentState.profile);
                  emit(
                    ProfileLoaded(
                      profile: currentState.profile,
                      preferences: currentState.preferences,
                      achievements: mergedAchievements,
                    ),
                  );
                },
              );
            } catch (error) {
              Logger.error('💥 Achievements loading error: $error');
              final defaultAchievements = _createDefaultAchievements(currentState.profile);
              emit(
                ProfileLoaded(
                  profile: currentState.profile,
                  preferences: currentState.preferences,
                  achievements: defaultAchievements,
                ),
              );
            }
          },
        );
      } catch (error) {
        Logger.error('💥 LoadAchievements handler error: $error');
        final defaultAchievements = _createDefaultAchievements(currentState.profile);
        emit(
          ProfileLoaded(
            profile: currentState.profile,
            preferences: currentState.preferences,
            achievements: defaultAchievements,
          ),
        );
      }
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
            Logger.error('❌ Failed to get current user for data export:  [33m${failure.message} [0m');
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
    }
  }

  Future<void> _onClearProfileError(
    ClearProfileError event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileError) {
      final errorState = state as ProfileError;
      if (errorState.profile != null) {
        emit(
          ProfileLoaded(
            profile: errorState.profile!,
            preferences: errorState.preferences,
            achievements: errorState.achievements ?? [],
          ),
        );
      } else {
        emit(const ProfileInitial());
      }
    }
  }

  Future<void> _onClearProfileCache(
    ClearProfileCache event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      Logger.info('🗑️ Clearing profile cache');
      
      if (state is ProfileLoaded) {
        add(const LoadProfile());
      }
    } catch (error) {
      Logger.error('❌ Error clearing cache: $error');
    }
  }


  dynamic _createOptimisticUpdate(dynamic currentProfile, Map<String, dynamic> updateData) {
    Logger.info('🔄 Creating optimistic profile update with data: $updateData');

    return currentProfile.copyWith(
      name: updateData['name'] ?? updateData['displayName'] ?? currentProfile.name,
      email: updateData['email'] ?? currentProfile.email,
      avatar: updateData['avatar'] ?? updateData['selectedAvatar'] ?? currentProfile.avatar,
      bio: updateData['bio'] ?? currentProfile.bio,
      pronouns: updateData['pronouns'] ?? currentProfile.pronouns,
      ageGroup: updateData['ageGroup'] ?? currentProfile.ageGroup,
      themeColor: updateData['themeColor'] ?? currentProfile.themeColor,
      isPrivate: updateData['isPrivate'] ?? currentProfile.isPrivate,
      favoriteEmotion: updateData['favoriteEmotion'] ?? currentProfile.favoriteEmotion,
    );
  }

  List<AchievementEntity> _createDefaultAchievements(dynamic profile) {
    final now = DateTime.now().toIso8601String();
    
    return [
      AchievementEntity(
        id: 'welcome_aboard',
        title: 'Welcome Aboard! 🎉',
        description: 'Welcome to your emotional wellness journey',
        icon: 'star',
        color: '#10B981',
        category: 'milestone',
        earned: true,
        progress: 1,
        requirement: 1,
        rarity: 'common',
        earnedDate: now,
      ),
      AchievementEntity(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Log your first emotion entry',
        icon: 'emoji_emotions',
        color: '#3B82F6',
        category: 'milestone',
        earned: profile.totalEntries > 0,
        progress: profile.totalEntries > 0 ? 1 : 0,
        requirement: 1,
        rarity: 'common',
        earnedDate: profile.totalEntries > 0 ? now : null,
      ),
      AchievementEntity(
        id: 'profile_complete',
        title: 'Profile Master',
        description: 'Complete your profile with avatar and bio',
        icon: 'account_circle',
        color: '#8B5CF6',
        category: 'milestone',
        earned: _isProfileComplete(profile),
        progress: _isProfileComplete(profile) ? 1 : 0,
        requirement: 1,
        rarity: 'common',
        earnedDate: _isProfileComplete(profile) ? now : null,
      ),
      
      AchievementEntity(
        id: 'three_day_streak',
        title: 'Three Day Streak 🔥',
        description: 'Log emotions for 3 consecutive days',
        icon: 'local_fire_department',
        color: '#EF4444',
        category: 'streak',
        earned: profile.currentStreak >= 3,
        progress: profile.currentStreak,
        requirement: 3,
        rarity: 'rare',
        earnedDate: profile.currentStreak >= 3 ? now : null,
      ),
      AchievementEntity(
        id: 'week_warrior',
        title: 'Week Warrior ⚡',
        description: 'Maintain a 7-day logging streak',
        icon: 'military_tech',
        color: '#F59E0B',
        category: 'streak',
        earned: profile.currentStreak >= 7,
        progress: profile.currentStreak,
        requirement: 7,
        rarity: 'rare',
        earnedDate: profile.currentStreak >= 7 ? now : null,
      ),
      AchievementEntity(
        id: 'month_master',
        title: 'Month Master 🏆',
        description: 'Complete 30 consecutive days',
        icon: 'emoji_events',
        color: '#EF4444',
        category: 'streak',
        earned: profile.currentStreak >= 30,
        progress: profile.currentStreak,
        requirement: 30,
        rarity: 'epic',
        earnedDate: profile.currentStreak >= 30 ? now : null,
      ),
      
      AchievementEntity(
        id: 'getting_started',
        title: 'Getting Started 📈',
        description: 'Complete 5 emotion entries',
        icon: 'trending_up',
        color: '#10B981',
        category: 'milestone',
        earned: profile.totalEntries >= 5,
        progress: profile.totalEntries,
        requirement: 5,
        rarity: 'common',
        earnedDate: profile.totalEntries >= 5 ? now : null,
      ),
      AchievementEntity(
        id: 'emotion_explorer',
        title: 'Emotion Explorer 🧭',
        description: 'Log 15 different emotions',
        icon: 'explore',
        color: '#6366F1',
        category: 'exploration',
        earned: profile.totalEntries >= 15,
        progress: profile.totalEntries,
        requirement: 15,
        rarity: 'rare',
        earnedDate: profile.totalEntries >= 15 ? now : null,
      ),
      AchievementEntity(
        id: 'dedicated_tracker',
        title: 'Dedicated Tracker 🎯',
        description: 'Complete 30 emotion entries',
        icon: 'psychology',
        color: '#8B5CF6',
        category: 'milestone',
        earned: profile.totalEntries >= 30,
        progress: profile.totalEntries,
        requirement: 30,
        rarity: 'epic',
        earnedDate: profile.totalEntries >= 30 ? now : null,
      ),
      AchievementEntity(
        id: 'mood_master',
        title: 'Mood Master 👑',
        description: 'Complete 100 emotion entries',
        icon: 'psychology',
        color: '#FFD700',
        category: 'milestone',
        earned: profile.totalEntries >= 100,
        progress: profile.totalEntries,
        requirement: 100,
        rarity: 'legendary',
        earnedDate: profile.totalEntries >= 100 ? now : null,
      ),
      
      AchievementEntity(
        id: 'social_butterfly',
        title: 'Social Butterfly 🦋',
        description: 'Connect with your first friend',
        icon: 'people',
        color: '#3B82F6',
        category: 'social',
        earned: profile.totalFriends > 0,
        progress: profile.totalFriends,
        requirement: 1,
        rarity: 'rare',
        earnedDate: profile.totalFriends > 0 ? now : null,
      ),
      AchievementEntity(
        id: 'support_hero',
        title: 'Support Hero ❤️',
        description: 'Help 5 friends with comfort reactions',
        icon: 'favorite',
        color: '#EF4444',
        category: 'social',
        earned: profile.helpedFriends >= 5,
        progress: profile.helpedFriends,
        requirement: 5,
        rarity: 'rare',
        earnedDate: profile.helpedFriends >= 5 ? now : null,
      ),
      
      AchievementEntity(
        id: 'early_adopter',
        title: 'Early Adopter 🚀',
        description: 'One of the first to join our community',
        icon: 'rocket_launch',
        color: '#F59E0B',
        category: 'special',
        earned: true,
        progress: 1,
        requirement: 1,
        rarity: 'legendary',
        earnedDate: now,
      ),
      AchievementEntity(
        id: 'consistency_king',
        title: 'Consistency King 👑',
        description: 'Maintain a 30-day streak',
        icon: 'local_fire_department',
        color: '#FF4500',
        category: 'streak',
        earned: profile.longestStreak >= 30,
        progress: profile.longestStreak,
        requirement: 30,
        rarity: 'epic',
        earnedDate: profile.longestStreak >= 30 ? now : null,
      ),
    ];
  }

  List<AchievementEntity> _mergeWithDefaultAchievements(
    List<AchievementEntity> apiAchievements, 
    dynamic profile,
  ) {
    final defaultAchievements = _createDefaultAchievements(profile);
    final apiAchievementIds = apiAchievements.map((a) => a.id).toSet();
    
    final missingDefaults = defaultAchievements
        .where((defaultAch) => !apiAchievementIds.contains(defaultAch.id))
        .toList();
    
    return [...apiAchievements, ...missingDefaults];
  }

  bool _isProfileComplete(dynamic profile) {
    return profile.name.isNotEmpty && 
           profile.email.isNotEmpty && 
           profile.avatar.isNotEmpty;
  }

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

  @override
  void onTransition(Transition<ProfileEvent, ProfileState> transition) {
    super.onTransition(transition);
    Logger.info('🔄 ProfileBloc Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.error('❌ ProfileBloc Error: $error\n$stackTrace');
  }
}