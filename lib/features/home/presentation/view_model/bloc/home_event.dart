// home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}

class MarkFirstTimeLoginCompleteEvent extends HomeEvent {
  const MarkFirstTimeLoginCompleteEvent();
}

class NavigateToMainFlowEvent extends HomeEvent {
  const NavigateToMainFlowEvent();
}

class RefreshUserStatsEvent extends HomeEvent {
  const RefreshUserStatsEvent();
}

class UpdateLastActivityEvent extends HomeEvent {
  const UpdateLastActivityEvent();
}

class ClearHomeDataEvent extends HomeEvent {
  const ClearHomeDataEvent();
}

class LogoutEvent extends HomeEvent {
  const LogoutEvent();
}

class LoadUserStatsEvent extends HomeEvent {
  const LoadUserStatsEvent();
}
