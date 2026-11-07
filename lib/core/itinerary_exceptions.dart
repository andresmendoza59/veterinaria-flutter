class ItineraryException implements Exception {
  final String message;

  const ItineraryException(this.message);

  @override
  String toString() => message;
}

class ItineraryRejectedException extends ItineraryException {
  const ItineraryRejectedException(super.message);
}

class ItineraryTemporaryException extends ItineraryException {
  const ItineraryTemporaryException(super.message);
}
