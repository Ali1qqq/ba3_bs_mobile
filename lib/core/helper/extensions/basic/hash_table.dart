/*
///
/// HashTable Implementation
///
/// 1. Infrastructure (Array)
/// 2. Operations:
///    - set
///    - get
///    - remove
///    - resize
///    - size
///
class HashTable<K, V> {
  late int initialSize;
  late int entriesCount;
  late List<KeyValuePair?> entries;

  HashTable() {
    this.initialSize = 3;
    this.entriesCount = 0;
    this.entries = List.filled(initialSize, null);
  }

  void resizeOrNot() {
    if (entriesCount < entries.length) {
      return;
    }

    int newSize = entries.length * 2;

    print('resize from ${entries.length} to $newSize');

    List<KeyValuePair?> entriesCopy = List.filled(entries.length, null);

    for (int i = 0; i < entries.length; i++) {
      entriesCopy[i] = entries[i];
    }

    entries = List.filled(newSize, null);
    entriesCount = 0;

    for (int i = 0; i < entriesCopy.length; i++) {
      if (entriesCopy[i] == null) continue;
      addToEntries(entriesCopy[i]?.key, entriesCopy[i]?.value);
    }
  }

  void addToEntries(K key, V value) {
    int hash = _hash(key);

    if (entries[hash] != null && entries[hash]!.key != key) {
      hash = _collisionHandling(key, hash, forSet: true);
    }

    if (hash == -1) {
      throw Exception('No space in hash table');
    }

    if (entries[hash] == null) {
      KeyValuePair newKeyValuePair = KeyValuePair(key, value);
      entries[hash] = newKeyValuePair;
      entriesCount++;
    } else if (entries[hash]!.key == key) {
      if (entries[hash]!.value == null) {
        entriesCount++;
      }
      entries[hash]!.value = value;
    } else {
      throw Exception('No space in hash table');
    }
  }

  /// FNV-1a hash function (32-bit)
  /// Converts a key into a valid array index.
  ///
  /// - **Input:** K key
  /// - **Output:** Hashed index within the array range
  int _hash(K key) {
    const int fnvOffsetBasis = 0x811c9dc5;
    const int fnvPrime = 0x01000193;

    int hash = fnvOffsetBasis;
    List<int> data = key.toString().codeUnits;

    for (int i = 0; i < data.length; i++) {
      hash ^= data[i];
      hash *= fnvPrime;
      hash &= 0xffffffff; // Keep within 32-bit range
    }

    print('[hash] ${key.toString()} $hash ${hash.toRadixString(16)} -> ${hash % entries.length}');

    return hash % entries.length; // Ensure index fits within table size
  }

  /// Handles collisions using **linear probing**.
  ///
  /// - **Input:** K key, int hash, _HashTableOperations operation
  /// - **Output:** New index for insertion/search, or -1 if not found.
  int _collisionHandling(K key, int hash, {required bool forSet}) {
    for (int i = 1; i < entries.length; i++) {
      int probeIndex = (hash + i) % entries.length;

      print('[coll] ${key.toString()} $hash -> probeIndex $probeIndex');

      if (forSet) {
        if (entries[probeIndex] == null || entries[probeIndex]?.key == key) {
          return probeIndex;
        }
      } else if (!forSet) {
        if (entries[probeIndex]?.key == key) {
          return probeIndex;
        }
      }
    }

    return -1; // No available slot or key not found
  }

  void set(K key, V value) {
    resizeOrNot();
    addToEntries(key, value);
  }

  V? get(K key) {
    int index = _hash(key);

    // Handle collision if key does not match
    if (entries[index] != null && entries[index]?.key != key) {
      index = _collisionHandling(key, index, forSet: false);
    }

    return (index != -1 && entries[index] != null && entries[index]!.key == key) ? entries[index]!.value : null;
  }

  void remove(K key) {
    int index = _hash(key);

    if (entries[index] != null && entries[index]!.key != key) {
      index = _collisionHandling(key, index, forSet: false);
    }

    // If key not found, return
    if (index == -1 || entries[index] == null || entries[index]!.key != key) return;

    // Mark as deleted instead of setting null (soft delete)
    entries[index]!.value = null;
    entriesCount--;
  }

  int get size => entriesCount;

  void printTable() {
    print('[size] $entriesCount');
    for (int i = 0; i < entries.length; i++) {
      print('[$i] ${entries[i]?.key}:${entries[i]?.value}');
    }
  }
}

class KeyValuePair<K, V> {
  KeyValuePair(this.key, this.value);

  final K key;
  V value;
}

void main() {
  HashTable<String, String> hashTable = HashTable<String, String>();

  hashTable.printTable();

  hashTable.set('Sinar', 'Sinar@gmail.com');
  hashTable.set('Elvis', 'Elvis@gmail.com');
  hashTable.set('Tane', 'Tane@gmail.com');

  hashTable.printTable();

  hashTable.set('Gerti', 'Gerti@gmail.com');
  hashTable.set('Artist', 'Artist@gmail.com');

  hashTable.printTable();

  print('[get] ${hashTable.get('Sinar')}');
  print('[get] ${hashTable.get('Tane')}');

  print('[remove] Sinar');

  hashTable.remove('Sinar');

  hashTable.printTable();

  print('[get] ${hashTable.get('Sinar')}');
  print('[get] ${hashTable.get('Elvis')}');
  print('[get] ${hashTable.get('Tane')}');
  print('[get] ${hashTable.get('Gerti')}');
  print('[get] ${hashTable.get('Artist')}');

  print('[remove] Elvis');

  hashTable.remove('Elvis');

  hashTable.printTable();

  print('[get] Sinar ${hashTable.get('Sinar')}');
  print('[get] Elvis ${hashTable.get('Elvis')}');
  print('[get] Tane ${hashTable.get('Tane')}');
  print('[get] Gerti ${hashTable.get('Gerti')}');
  print('[get] Artist ${hashTable.get('Artist')}');

  hashTable.set('Sinar', 'Sinar2@gmail.com');

  hashTable.printTable();
}
*/
