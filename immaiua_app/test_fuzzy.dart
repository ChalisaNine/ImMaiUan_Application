import 'package:fuzzy/fuzzy.dart';

void main() {
  var list = [
    {'name': 'Apple'},
    {'name': 'Banana'},
    {'name': 'Fried Rice'},
    {'name': 'Orange'}
  ];

  final fuse = Fuzzy(
    list,
    options: FuzzyOptions(
      keys: [
        WeightedKey(
          name: 'name',
          getter: (dynamic obj) => obj['name'] as String,
          weight: 1,
        )
      ],
    ),
  );

  final result = fuse.search('frid rice');
  for (var r in result) {
    print(r.item);
  }
}
