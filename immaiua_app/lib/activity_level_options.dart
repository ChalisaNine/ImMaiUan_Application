const List<String> activityLevelOptions = [
  'Sedentary (office job)',
  'Light exercise (1-2 days/week)',
  'Moderate exercise (3-5 days/week)',
  'Heavy training (6-7 days/week)',
];

String? normalizeActivityLevel(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;

  final normalized = text
      .replaceAll('Ã¢â‚¬â€œ', '-')
      .replaceAll('â€“', '-')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll(RegExp(r'\s+'), ' ');

  for (final level in activityLevelOptions) {
    if (level.toLowerCase() == normalized.toLowerCase()) {
      return level;
    }
  }

  return normalized;
}
