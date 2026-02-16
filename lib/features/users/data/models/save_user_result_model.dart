import 'package:cowork/features/users/domain/entities/save_user_result.dart';

class SaveUserResultModel {
  final bool success;
  final bool alreadyExists;
  final String? errorMessage;
  final String? createdUid;

  const SaveUserResultModel({
    required this.success,
    required this.alreadyExists,
    required this.errorMessage,
    required this.createdUid,
  });

  const SaveUserResultModel.success({String? createdUid})
      : success = true,
        alreadyExists = false,
        errorMessage = null,
        createdUid = createdUid;

  const SaveUserResultModel.error(String message)
      : success = false,
        alreadyExists = false,
        errorMessage = message,
        createdUid = null;

  const SaveUserResultModel.alreadyExists()
      : success = false,
        alreadyExists = true,
        errorMessage = null,
        createdUid = null;

  SaveUserResult toEntity() {
    return SaveUserResult(
      success: success,
      alreadyExists: alreadyExists,
      errorMessage: errorMessage,
      createdUid: createdUid,
    );
  }
}
