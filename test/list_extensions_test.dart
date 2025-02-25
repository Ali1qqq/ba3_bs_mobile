import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ListExtensions',
    () {
      test('groupBy correctly groups elements by a key', () {
        final fruits = ['apple', 'apricot', 'banana'];
        final grouped = fruits.groupBy((fruit) => fruit[0]);

        expect(grouped['a'], containsAll(['apple', 'apricot']));
        expect(grouped['b'], containsAll(['banana']));
      });

      test('mergeBy correctly merges elements with the same key', () {
        final numbers = [1, 2, 3, 4, 2, 4];
        final merged = numbers.mergeBy(
          (n) => n % 2 == 0 ? 'even' : 'odd',
          (acc, cur) => acc + cur,
        );

        expect(merged, containsAll([4, 12])); // sum of odds: 4, sum of evens: 12
      });

      test('toMap correctly converts a list to a map with keys', () {
        final users = [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
        ];
        final userMap = users.toMap((user) => user['id']);

        expect(userMap[1]?['name'], 'Alice');
        expect(userMap[2]?['name'], 'Bob');
      });

      test('select correctly extracts non-null values', () {
        final items = ['apple', null, 'banana'];
        final nonNullItems = items.select((item) => item);

        expect(nonNullItems, containsAll(['apple', 'banana']));
      });

      test('distinct correctly removes duplicate elements', () {
        final numbers = [1, 2, 2, 3];
        final distinctNumbers = numbers.distinct();

        expect(distinctNumbers, containsAll([1, 2, 3]));
      });

      test('distinctBy correctly removes elements based on a key', () {
        final people = [
          {'name': 'Alice'},
          {'name': 'Bob'},
          {'name': 'Alice'}
        ];
        final uniquePeople = people.distinctBy((p) => p['name']);

        expect(uniquePeople.length, 2);
        expect(
          uniquePeople,
          containsAll(
            [
              {'name': 'Alice'},
              {'name': 'Bob'},
            ],
          ),
        );
      });

      test('partition splits the list correctly', () {
        final numbers = [1, 2, 3, 4];
        final (evens, odds) = numbers.partition((n) => n % 2 == 0);

        expect(evens, containsAll([2, 4]));
        expect(odds, containsAll([1, 3]));
      });

      test('sortBy correctly sorts in ascending order', () {
        final people = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
          {'name': 'Ali', 'age': 40},
          {'name': 'Ahmed', 'age': 10},
          {'name': 'Mo', 'age': 50},
        ];

        // Explicitly specify <int> for K
        people.sortBy<int>((person) => person['age'] as int);

        expect(people.first['name'], 'Ahmed');
        expect(
          people,
          containsAll(
            [
              {'name': 'Ahmed', 'age': 10},
              {'name': 'Bob', 'age': 25},
              {'name': 'Alice', 'age': 30},
              {'name': 'Ali', 'age': 40},
              {'name': 'Mo', 'age': 50},
            ],
          ),
        );
      });

      test('sortByDescending correctly sorts in descending order', () {
        final people = [
          {'name': 'Mo', 'age': 50},
          {'name': 'Ali', 'age': 40},
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
          {'name': 'Ahmed', 'age': 10},
        ];

        // Explicitly specify <int> for K
        people.sortByDescending<int>((person) => person['age'] as int);

        expect(people.first['name'], 'Mo');
        expect(
          people,
          containsAll(
            [
              {'name': 'Mo', 'age': 50},
              {'name': 'Ali', 'age': 40},
              {'name': 'Alice', 'age': 30},
              {'name': 'Bob', 'age': 25},
              {'name': 'Ahmed', 'age': 10},
            ],
          ),
        );
      });

      test('sumBy computes the correct sum', () {
        final numbers = [1, 2, 3];
        final sum = numbers.sumBy((n) => n);

        expect(sum, equals(6));
      });

      test('minBy finds the minimum value', () {
        final numbers = [10, 5, 8];

        // Explicitly specify <num> for K
        final minNumber = numbers.minBy<num>((n) => n);

        expect(minNumber, equals(5));
      });

      test('maxBy finds the maximum value', () {
        final numbers = [10, 5, 8];

        // Explicitly specify <num> for K
        final maxNumber = numbers.maxBy<num>((n) => n);

        expect(maxNumber, equals(10));
      });

      test('shuffle does not modify the original list', () {
        final numbers = [1, 2, 3, 4, 5];
        final shuffled = numbers.shuffled();

        expect(numbers, containsAll([1, 2, 3, 4, 5])); // Original list remains
        expect(shuffled.length, equals(5));
      });

      test('random picks an element from the list', () {
        final numbers = [1, 2, 3, 4, 5];
        final randomElement = numbers.random();

        expect(numbers, contains(randomElement));
      });

      test('diffBy detects changes correctly', () {
        final previousItems = [
          {'id': 1, 'quantity': 5},
          {'id': 2, 'quantity': 3}
        ];
        final currentItems = [
          {'id': 1, 'quantity': 8},
          {'id': 2, 'quantity': 3}
        ];

        final updatedItems = currentItems.diffBy(
          previousItems,
          (item) => item['id'],
          (current, previous) => current['quantity'] != previous['quantity'],
        );

        expect(updatedItems.length, equals(1));
        expect(updatedItems.first['id'], equals(1));
        expect(updatedItems.first['quantity'], equals(8));
      });

      test('quantityDiff correctly detects quantity changes', () {
        final previousItems = [
          {'id': 1, 'quantity': 5},
          {'id': 2, 'quantity': 3}
        ];
        final currentItems = [
          {'id': 1, 'quantity': 8},
          {'id': 2, 'quantity': 3}
        ];

        final updatedItems = currentItems.quantityDiff(
          previousItems,
          (item) => item['id'],
          (item) => item['quantity'] as int,
          (item, difference) => {'id': item['id'] as int, 'quantity': difference},
        );

        expect(updatedItems.length, equals(1));
        expect(updatedItems.first['id'], equals(1));
        expect(updatedItems.first['quantity'], equals(3)); // 8 - 5
      });

      test('intersect correctly detects quantity changes', () {
        final previousItems = [
          {'name': 'Mo', 'age': 50},
          {'name': 'Ali', 'age': 40},
        ];
        final currentItems = [
          {'name': 'Mo', 'age': 50},
          {'name': 'Ahmed', 'age': 10},
        ];

        final intersectItems = currentItems.intersectBy(
          previousItems,
          (item) => item['name'],
        );

        expect(intersectItems.length, equals(1));
        expect(intersectItems.first['age'], equals(50));
        expect(intersectItems.first['name'], 'Mo');
        expect(
          intersectItems,
          containsAll(
            [
              {'name': 'Mo', 'age': 50}
            ],
          ),
        );
      });

      test('chunkBy correctly detects quantity changes', () {
        final letters = ['a', 'b', 'c', 'd', 'e'];
        final chunks = letters.chunkBy(2);

        expect(chunks.length, equals(3));
        expect(
          chunks,
          containsAll(
            [
              ['a', 'b'],
              ['c', 'd'],
              ['e']
            ],
          ),
        );
      });

      test('associate transforms a list into a map', () {
        final fruits = ['apple', 'banana', 'cherry'];
        final fruitLengths = fruits.associate((fruit) => MapEntry(fruit, fruit.length));

        expect(fruitLengths, equals({'apple': 5, 'banana': 6, 'cherry': 6}));
      });

      test('associateBy creates a map with elements as values and keys from keySelector', () {
        final users = [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'}
        ];
        final userMap = users.associateBy((user) => user['id']);

        expect(userMap[1]?['name'], 'Alice');
        expect(userMap[2]?['name'], 'Bob');
      });

      test('associateWith creates a map where keys are elements and values are computed', () {
        final fruits = ['apple', 'banana', 'cherry'];
        final fruitColors = fruits.associateWith((fruit) => fruit == 'apple'
            ? 'red'
            : fruit == 'banana'
                ? 'yellow'
                : 'red');

        expect(fruitColors, equals({'apple': 'red', 'banana': 'yellow', 'cherry': 'red'}));
      });

      test('flatten flattens nested lists', () {
        final nestedList = [
          1,
          [2, 3],
          4
        ];
        final flattened = nestedList.flatten();

        expect(flattened, equals([1, 2, 3, 4]));
      });

      test('zip combines two lists element-wise', () {
        final numbers1 = [1, 2, 3];
        final numbers2 = [4, 5, 6];
        final sums = numbers1.zip(numbers2, (a, b) => a + b);

        expect(sums, equals([5, 7, 9]));
      });

      test('takeWhileInclusive includes the first non-matching element', () {
        final numbers = [1, 2, 3, 4, 5];
        final result = numbers.takeWhileInclusive((n) => n < 3);

        expect(result, equals([1, 2, 3])); // Includes 3, even though 3 < 3 is false
      });

      test('dropWhileInclusive includes the first non-matching element', () {
        final numbers = [1, 2, 3, 4, 5];
        final result = numbers.dropWhileInclusive((n) => n < 3);

        expect(result, equals([3, 4, 5])); // 3 is included, since it's the first that fails the predicate
      });

      test(
        'windowed creates sliding windows of given size',
        () {
          final numbers = [1, 2, 3, 4, 5];

          final windowsTrue = numbers.windowed(3, step: 2, partialWindows: true);
          expect(
              windowsTrue,
              equals([
                [1, 2, 3],
                [3, 4, 5],
                [5]
              ]));

          final windowsFalse = numbers.windowed(3, step: 2, partialWindows: false);
          expect(
              windowsFalse,
              equals([
                [1, 2, 3],
                [3, 4, 5]
              ]));
        },
      );
    },
  );
}
