import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/profile_repository.dart';

class ExportUserDataParams extends Equatable {
  final String userId;

  const ExportUserDataParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ExportUserData implements UseCase<String, ExportUserDataParams> {
  final ProfileRepository repository;

  ExportUserData({required this.repository});

  @override
  Future<Either<Failure, String>> call(ExportUserDataParams params) async {
    return await repository.exportUserData(params.userId);
  }
}
