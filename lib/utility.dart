import 'dart:convert';

/// Encode a String to base64
String encode(String text) {
  return base64.encode(utf8.encode(text));
}

/// Decode a base64 to String
String decode(String encodedText) {
  return utf8.decode(base64.decode(encodedText));
}
