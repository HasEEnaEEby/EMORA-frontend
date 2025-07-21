import 'package:emora_mobile_app/features/home/data/data_source/remote/community_remote_data_source.dart';
import 'package:emora_mobile_app/features/home/data/repository/community_repository_impl.dart';
import 'package:emora_mobile_app/features/home/domain/repository/community_repository.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/community_use_cases.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';

class CommunityModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('🌍 Initializing Community Module...');

    try {
      // BLoC
      sl.registerFactory<CommunityBloc>(
        () => CommunityBloc(
          getGlobalFeed: sl<GetGlobalFeed>(),
          getFriendsFeed: sl<GetFriendsFeed>(),
          getTrendingPosts: sl<GetTrendingPosts>(),
          reactToPost: sl<ReactToPost>(),
          removeReaction: sl<RemoveReaction>(),
          addComment: sl<AddComment>(),
          getComments: sl<GetComments>(),
          getGlobalStats: sl<GetGlobalStats>(),
        ),
      );

      // Use Cases
      sl.registerLazySingleton<GetGlobalFeed>(
        () => GetGlobalFeed(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<GetFriendsFeed>(
        () => GetFriendsFeed(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<GetTrendingPosts>(
        () => GetTrendingPosts(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<ReactToPost>(
        () => ReactToPost(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<RemoveReaction>(
        () => RemoveReaction(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<AddComment>(
        () => AddComment(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<GetComments>(
        () => GetComments(sl<CommunityRepository>()),
      );

      sl.registerLazySingleton<GetGlobalStats>(
        () => GetGlobalStats(sl<CommunityRepository>()),
      );

      // Repository
      sl.registerLazySingleton<CommunityRepository>(
        () => CommunityRepositoryImpl(
          remoteDataSource: sl<CommunityRemoteDataSource>(),
          networkInfo: sl<NetworkInfo>(),
        ),
      );

      // Data Sources (Remote Only) - FIXED: Added both required dependencies
      sl.registerLazySingleton<CommunityRemoteDataSource>(
        () => CommunityRemoteDataSourceImpl(
          apiService: sl<ApiService>(), // . FIXED: Added missing apiService
          dioClient: sl<DioClient>(),
        ),
      );

      Logger.info('. Community Module initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('. Community Module initialization failed', e, stackTrace);
      rethrow;
    }
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('. Verifying Community Module registrations...');

    const expectedServices = [
      'CommunityBloc',
      'GetGlobalFeed',
      'GetFriendsFeed',
      'GetTrendingPosts',
      'ReactToPost',
      'RemoveReaction',
      'AddComment',
      'GetComments',
      'GetGlobalStats',
      'CommunityRepository',
      'CommunityRemoteDataSource',
    ];

    int registeredCount = 0;
    final List<String> failedServices = [];

    for (final serviceName in expectedServices) {
      try {
        bool isRegistered = false;

        switch (serviceName) {
          case 'CommunityBloc':
            isRegistered = sl.isRegistered<CommunityBloc>();
            break;
          case 'GetGlobalFeed':
            isRegistered = sl.isRegistered<GetGlobalFeed>();
            break;
          case 'GetFriendsFeed':
            isRegistered = sl.isRegistered<GetFriendsFeed>();
            break;
          case 'GetTrendingPosts':
            isRegistered = sl.isRegistered<GetTrendingPosts>();
            break;
          case 'ReactToPost':
            isRegistered = sl.isRegistered<ReactToPost>();
            break;
          case 'RemoveReaction':
            isRegistered = sl.isRegistered<RemoveReaction>();
            break;
          case 'AddComment':
            isRegistered = sl.isRegistered<AddComment>();
            break;
          case 'GetComments':
            isRegistered = sl.isRegistered<GetComments>();
            break;
          case 'GetGlobalStats':
            isRegistered = sl.isRegistered<GetGlobalStats>();
            break;
          case 'CommunityRepository':
            isRegistered = sl.isRegistered<CommunityRepository>();
            break;
          case 'CommunityRemoteDataSource':
            isRegistered = sl.isRegistered<CommunityRemoteDataSource>();
            break;
        }

        if (isRegistered) {
          registeredCount++;
        } else {
          failedServices.add(serviceName);
        }
      } catch (e) {
        failedServices.add(serviceName);
        Logger.error('. Failed to verify $serviceName', e);
      }
    }

    final success = failedServices.isEmpty;
    if (!success) {
      Logger.error(
        '. Community Module verification failed for: ${failedServices.join(', ')}',
      );
    } else {
      Logger.info('. Community Module verification completed successfully');
    }

    return {
      'module': 'Community',
      'registered': registeredCount,
      'total': expectedServices.length,
      'success': success,
      'failed_services': failedServices,
    };
  }

  static Map<String, dynamic> getHealthStatus(GetIt sl) {
    return {
      'module': 'Community',
      'timestamp': DateTime.now().toIso8601String(),
      'services_health': {
        'bloc': sl.isRegistered<CommunityBloc>(),
        'repository': sl.isRegistered<CommunityRepository>(),
        'remote_data_source': sl.isRegistered<CommunityRemoteDataSource>(),
        'use_cases': {
          'get_global_feed': sl.isRegistered<GetGlobalFeed>(),
          'get_friends_feed': sl.isRegistered<GetFriendsFeed>(),
          'get_trending_posts': sl.isRegistered<GetTrendingPosts>(),
          'react_to_post': sl.isRegistered<ReactToPost>(),
          'remove_reaction': sl.isRegistered<RemoveReaction>(),
          'add_comment': sl.isRegistered<AddComment>(),
          'get_comments': sl.isRegistered<GetComments>(),
          'get_global_stats': sl.isRegistered<GetGlobalStats>(),
        },
      },
    };
  }

  static Map<String, dynamic> getModuleInfo() {
    return {
      'name': 'Community Module',
      'version': '1.0.0',
      'description':
          'Handles community features including posts, reactions, and comments',
      'features': [
        'Global community feed',
        'Friends feed',
        'Trending posts',
        'Post reactions',
        'Comments system',
        'Global mood statistics',
      ],
      'dependencies': [
        'Core Module (NetworkInfo, DioClient, ApiService)',
        'Auth Module (for user context)',
      ],
    };
  }
}
