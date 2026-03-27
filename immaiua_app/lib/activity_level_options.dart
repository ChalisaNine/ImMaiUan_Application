const List<String> activityLevelOptions = [
  'Sedentary (office job)',
  'Light exercise (1-2 days/week)',
  'Moderate exercise (3-5 days/week)',
  'Heavy training (6-7 days/week)',
  'Extra active (physical job or intense daily training)',
];

const Map<String, String> _activityAliases = {
  'sedentary': 'Sedentary (office job)',
  'sedentary (office job)': 'Sedentary (office job)',
  'lightly active': 'Light exercise (1-2 days/week)',
  'light exercise (1-2 days/week)': 'Light exercise (1-2 days/week)',
  'light exercise (1â€“2 days/week)': 'Light exercise (1-2 days/week)',
  'light exercise (1ã¢â‚¬â€œ2 days/week)': 'Light exercise (1-2 days/week)',
  'moderately active': 'Moderate exercise (3-5 days/week)',
  'moderate exercise (3-5 days/week)': 'Moderate exercise (3-5 days/week)',
  'moderate exercise (3â€“5 days/week)': 'Moderate exercise (3-5 days/week)',
  'moderate exercise (3ã¢â‚¬â€œ5 days/week)': 'Moderate exercise (3-5 days/week)',
  'very active': 'Heavy training (6-7 days/week)',
  'heavy training (6-7 days/week)': 'Heavy training (6-7 days/week)',
  'heavy training (6â€“7 days/week)': 'Heavy training (6-7 days/week)',
  'heavy training (6ã¢â‚¬â€œ7 days/week)': 'Heavy training (6-7 days/week)',
  'extra active': 'Extra active (physical job or intense daily training)',
  'extra active (physical job or intense daily training)':
      'Extra active (physical job or intense daily training)',
};

String? normalizeActivityLevel(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;

  final normalized = text
      .replaceAll('ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ', '-')
      .replaceAll('ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“', '-')
      .replaceAll('Ã¢â‚¬â€œ', '-')
      .replaceAll('Ã¢â‚¬â€', '-')
      .replaceAll(RegExp(r'\s+'), ' ');

  for (final level in activityLevelOptions) {
    if (level.toLowerCase() == normalized.toLowerCase()) {
      return level;
    }
  }

  return _activityAliases[normalized.toLowerCase()] ?? normalized;
}
