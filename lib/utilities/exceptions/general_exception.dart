class GeneralException implements Exception {
  final String message;

  GeneralException(this.message);

  @override
  String toString() {
    return message;
  }
}
