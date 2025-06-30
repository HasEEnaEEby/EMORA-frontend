// app/bloc_observer.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    Logger.info('🎯 BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
      Logger.info('📨 Event: ${bloc.runtimeType} - $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    Logger.info('🔄 State Change: ${bloc.runtimeType}');
    Logger.info('   From: ${change.currentState}');
    Logger.info('   To: ${change.nextState}');
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    // Only call super and log for Bloc instances, not Cubit
    if (bloc is Bloc) {
      super.onTransition(bloc, transition);
      Logger.info('🔄 Transition: ${bloc.runtimeType}');
      Logger.info('   Event: ${transition.event}');
      Logger.info('   From: ${transition.currentState}');
      Logger.info('   To: ${transition.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Logger.error('💥 BLoC Error in ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    Logger.info('🗑️ BLoC Closed: ${bloc.runtimeType}');
  }
}
