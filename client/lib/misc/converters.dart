Uri uriFromString(String uri) => Uri.parse(uri);

Uri? uriFromStringNull(String? uri) => uri != null ? uriFromString(uri) : null;
