// lib/core/use_case/use_case.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base class for all use cases in the application
/// T is the return type, Params is the parameters type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use this class when the use case doesn't require any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

/// Base class for use cases that don't return anything
abstract class VoidUseCase<Params> {
  Future<Either<Failure, void>> call(Params params);
}

/// Base class for synchronous use cases
abstract class SyncUseCase<T, Params> {
  Either<Failure, T> call(Params params);
}

/// Base class for stream use cases
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}
