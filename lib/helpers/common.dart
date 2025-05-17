String nickEmail(String email) {
  final regex = RegExp(r'[^.@]+');
  var match = regex.stringMatch(email);
  if (match != null) {
    return match;
  }
  // Return an empty string or throw an error if no match is found
  return '';
}
