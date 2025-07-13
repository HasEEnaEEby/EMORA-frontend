import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

import '../../../features/home/data/data_source/local/home_local_data_source.dart';
import '../../../features/home/data/data_source/remote/home_remote_data_source.dart';
import '../../../features/home/data/data_source/remote/community_remote_data_source.dart';
import '../../../features/home/data/data_source/remote/friend_remote_data_source.dart';
import '../../../features/home/data/repository/home_repository_impl.dart';
import '../../../features/home/data/repository/community_repository_impl.dart';
import '../../../features/home/data/repository/friend_repository_impl.dart';
import '../../../features/home/domain/repository/home_repository.dart';
import '../../../features/home/domain/repository/community_repository.dart';
import '../../../features/home/domain/repository/friend_repository.dart';
import '../../../features/home/domain/use_case/get_user_stats.dart';
import '../../../features/home/domain/use_case/load_home_data.dart';
import '../../../features/home/domain/use_case/navigate_to_main_flow.dart';
import '../../../features/home/domain/use_case/community_use_cases.dart';
import '../../../features/home/domain/use_case/friend_use_cases.dart';
import '../../../features/home/presentation/view_model/bloc/home_bloc.dart';
import '../../../features/home/presentation/view_model/bloc/community_bloc.dart';
import '../../../features/home/presentation/view_model/bloc/friend_bloc.dart';

class HomeModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('🏠 Initializing home module...');

    try {
      _initDataSources(sl);
      _initRepository(sl);
      _initUseCases(sl);
      _initBloc(sl);

      Logger.info('✅ Home module initialized successfully');
    } catch (e) {
      Logger.error('❌ Home module initialization failed', e);
      rethrow;
    }
  }

  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing home data sources...');

    // Local Data Source
    sl.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(),
    );

    // Remote Data Source
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
        apiService: sl<ApiService>(),
      ),
    );

    // Community Remote Data Source
    sl.registerLazySingleton<CommunityRemoteDataSource>(
      () => CommunityRemoteDataSourceImpl(
        apiService: sl<ApiService>(),
        dioClient: sl<DioClient>(),
      ),
    );

    // Friend Remote Data Source
    sl.registerLazySingleton<FriendRemoteDataSource>(
      () => FriendRemoteDataSourceImpl(
        apiService: sl<ApiService>(),
        dioClient: sl<DioClient>(),
      ),
    );
  }

  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing home repository...');

    // Repository - Register both interface and implementation
    sl.registerLazySingleton<HomeRepositoryImpl>(
      () => HomeRepositoryImpl(
        remoteDataSource: sl<HomeRemoteDataSource>(),
        localDataSource: sl<HomeLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    // Register the interface pointing to the implementation
    sl.registerLazySingleton<HomeRepository>(() => sl<HomeRepositoryImpl>());

    // Community Repository
    sl.registerLazySingleton<CommunityRepositoryImpl>(
      () => CommunityRepositoryImpl(
        remoteDataSource: sl<CommunityRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    sl.registerLazySingleton<CommunityRepository>(() => sl<CommunityRepositoryImpl>());

    // Friend Repository
    sl.registerLazySingleton<FriendRepositoryImpl>(
      () => FriendRepositoryImpl(
        remoteDataSource: sl<FriendRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    sl.registerLazySingleton<FriendRepository>(() => sl<FriendRepositoryImpl>());
  }

  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing home use cases...');

    sl.registerLazySingleton<LoadHomeData>(
      () => LoadHomeData(sl<HomeRepository>()),
    );

    sl.registerLazySingleton<GetUserStats>(
      () => GetUserStats(sl<HomeRepository>()),
    );

    sl.registerLazySingleton<NavigateToMainFlow>(() => NavigateToMainFlow());

    // Community Use Cases
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

    // Friend Use Cases
    sl.registerLazySingleton<SearchUsers>(
      () => SearchUsers(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<SendFriendRequest>(
      () => SendFriendRequest(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<CancelFriendRequest>(
      () => CancelFriendRequest(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<RespondToFriendRequest>(
      () => RespondToFriendRequest(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<GetFriends>(
      () => GetFriends(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<GetPendingRequests>(
      () => GetPendingRequests(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<RemoveFriend>(
      () => RemoveFriend(sl<FriendRepository>()),
    );

    sl.registerLazySingleton<GetFriendSuggestions>(
      () => GetFriendSuggestions(sl<FriendRepository>()),
    );
  }

  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing home bloc...');

    sl.registerLazySingleton<HomeBloc>(
      () => HomeBloc(
        loadHomeData: sl<LoadHomeData>(),
        getUserStats: sl<GetUserStats>(),
        navigateToMainFlow: sl<NavigateToMainFlow>(),
      ),
    );

    sl.registerLazySingleton<CommunityBloc>(
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

    sl.registerLazySingleton<FriendBloc>(
      () => FriendBloc(
        searchUsers: sl<SearchUsers>(),
        sendFriendRequest: sl<SendFriendRequest>(),
        cancelFriendRequest: sl<CancelFriendRequest>(),
        respondToFriendRequest: sl<RespondToFriendRequest>(),
        getFriends: sl<GetFriends>(),
        getPendingRequests: sl<GetPendingRequests>(),
        removeFriend: sl<RemoveFriend>(),
        getFriendSuggestions: sl<GetFriendSuggestions>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying home module registrations...');

    final serviceChecks = <String, bool Function()>{
      'HomeLocalDataSource': () => sl.isRegistered<HomeLocalDataSource>(),
      'HomeRemoteDataSource': () => sl.isRegistered<HomeRemoteDataSource>(),
      'CommunityRemoteDataSource': () => sl.isRegistered<CommunityRemoteDataSource>(),
      'HomeRepositoryImpl': () => sl.isRegistered<HomeRepositoryImpl>(),
      'HomeRepository': () => sl.isRegistered<HomeRepository>(),
      'CommunityRepositoryImpl': () => sl.isRegistered<CommunityRepositoryImpl>(),
      'CommunityRepository': () => sl.isRegistered<CommunityRepository>(),
      'LoadHomeData': () => sl.isRegistered<LoadHomeData>(),
      'GetUserStats': () => sl.isRegistered<GetUserStats>(),
      'NavigateToMainFlow': () => sl.isRegistered<NavigateToMainFlow>(),
      'GetGlobalFeed': () => sl.isRegistered<GetGlobalFeed>(),
      'GetFriendsFeed': () => sl.isRegistered<GetFriendsFeed>(),
      'GetTrendingPosts': () => sl.isRegistered<GetTrendingPosts>(),
      'ReactToPost': () => sl.isRegistered<ReactToPost>(),
      'RemoveReaction': () => sl.isRegistered<RemoveReaction>(),
      'AddComment': () => sl.isRegistered<AddComment>(),
      'GetComments': () => sl.isRegistered<GetComments>(),
      'GetGlobalStats': () => sl.isRegistered<GetGlobalStats>(),
      'HomeBloc': () => sl.isRegistered<HomeBloc>(),
      'CommunityBloc': () => sl.isRegistered<CommunityBloc>(),
      'FriendRemoteDataSource': () => sl.isRegistered<FriendRemoteDataSource>(),
      'FriendRepositoryImpl': () => sl.isRegistered<FriendRepositoryImpl>(),
      'FriendRepository': () => sl.isRegistered<FriendRepository>(),
      'SearchUsers': () => sl.isRegistered<SearchUsers>(),
      'SendFriendRequest': () => sl.isRegistered<SendFriendRequest>(),
      'RespondToFriendRequest': () => sl.isRegistered<RespondToFriendRequest>(),
      'GetFriends': () => sl.isRegistered<GetFriends>(),
      'GetPendingRequests': () => sl.isRegistered<GetPendingRequests>(),
      'RemoveFriend': () => sl.isRegistered<RemoveFriend>(),
      'GetFriendSuggestions': () => sl.isRegistered<GetFriendSuggestions>(),
      'FriendBloc': () => sl.isRegistered<FriendBloc>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Home: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Home: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Home Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Home',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
