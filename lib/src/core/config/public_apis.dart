/// Public API configuration required for academic submission.
final class PublicApis {
  PublicApis._();

  static const String maptilerName = 'MapTiler';

  /// Universal request format (as given in the assignment prompt).
  static const String maptilerUniversalFormat =
      'https://api.maptiler.com/{METHOD}/{QUERY}.json?{PARAMS}&key=YOUR_MAPTILER_API_KEY_HERE';

  /// Vector style JSON (as provided).
  static const String maptilerStreetsV4StyleUrl =
      'https://api.maptiler.com/maps/streets-v4/style.json?key=pcH5SSPJjdDvJ5kGeeYL';
}
