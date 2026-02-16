class SaveUserResult {
  final bool success;
  final bool alreadyExists;
  final String? errorMessage;
  final String? createdUid;

  const SaveUserResult({
    required this.success,
    required this.alreadyExists,
    required this.errorMessage,
    required this.createdUid,
  });

  const SaveUserResult.success({String? createdUid})
      : success = true,
        alreadyExists = false,
        errorMessage = null,
        createdUid = createdUid;

  const SaveUserResult.error(String message)
      : success = false,
        alreadyExists = false,
        errorMessage = message,
        createdUid = null;

  const SaveUserResult.alreadyExists()
      : success = false,
        alreadyExists = true,
        errorMessage = null,
        createdUid = null;
}
