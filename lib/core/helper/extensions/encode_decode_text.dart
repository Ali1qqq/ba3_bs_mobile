import 'dart:convert';

extension ProblematicCharsExtension on String {
  // خريطة استبدال الرموز المُشكلة للمشاكل: يُستبدل معظم الرموز بفراغ،
  // ويتم استبدال الشرطة (-) بـ "ـ".
  static const Map<String, String> problematicMap = {
    r'$': ' ',
    r'\': ' ', // نكتب \\ لتمثيل الشرطة المائلة العكسية
    '{': ' ',
    '}': ' ',
    '"': ' ',
    "'": ' ',
    '+': ' ',
    '-': 'ـ',
  };

  // فاصل مخفي (غير مرئي) لفصل النص الآمن عن بيانات الميتاداتا.
  static const String _metadataDelimiter = '\u2063';

  // دالة تحويل نص عادي إلى نص مخفي باستخدام أحرف زيرو-ويـد:
  // هنا نستخدم: '0' -> U+200B، و'1' -> U+200C.
  String _toInvisible(String input) {
    List<String> invisibleChars = [];
    for (var codeUnit in utf8.encode(input)) {
      String binary = codeUnit.toRadixString(2).padLeft(8, '0');
      for (var bit in binary.split('')) {
        invisibleChars.add(bit == '0' ? '\u200B' : '\u200C');
      }
    }
    return invisibleChars.join();
  }

  // دالة التحويل العكسي: من النص المخفي إلى النص العادي.
  String _fromInvisible(String input) {
    List<int> bytes = [];
    for (int i = 0; i < input.length; i += 8) {
      String byteStr = input.substring(i, i + 8);
      String binary =
          byteStr.split('').map((c) => c == '\u200B' ? '0' : '1').join();
      int byte = int.parse(binary, radix: 2);
      bytes.add(byte);
    }
    return utf8.decode(bytes);
  }

  /// دالة التشفير:
  /// تُنشئ نصاً آمناً بحيث تُستبدل الرموز الخاصة (من problematicMap) بالحرف الآمن،
  /// ويتم جمع بيانات الميتاداتا (موقع وحرف) وتشفيرها بشكل مخفي.
  String encodeProblematic() {
    StringBuffer safeText = StringBuffer();
    List<String> metadataEntries = [];

    for (int i = 0; i < length; i++) {
      String char = this[i];
      if (problematicMap.containsKey(char)) {
        // تسجيل بيانات الميتاداتا: موقع الحرف والرمز الأصلي.
        metadataEntries.add('$i:$char');
        // استبدال الرمز بحرف آمن (فراغ أو "ـ" للشرطة).
        safeText.write(problematicMap[char]);
      } else {
        safeText.write(char);
      }
    }

    // بناء سلسلة الميتاداتا باستخدام الفاصلة للفصل بين كل سجل.
    String metadataStr = metadataEntries.join(',');
    // تحويل بيانات الميتاداتا إلى تمثيل مخفي.
    String invisibleMetadata = _toInvisible(metadataStr);
    // إلحاق الفاصل المخفي وبيانات الميتاداتا في نهاية النص الآمن.
    return safeText.toString() + _metadataDelimiter + invisibleMetadata;
  }

  /// دالة فك التشفير:
  /// تستخرج بيانات الميتاداتا المخفية وتعيد بناء النص الأصلي
  /// عن طريق استبدال الحروف في المواقع المُسجلة.
  String decodeProblematic() {
    int delimiterIndex = lastIndexOf(_metadataDelimiter);
    if (delimiterIndex == -1) {
      // لا توجد بيانات ميتاداتا؛ نعيد النص كما هو.
      return this;
    }
    String safeText = substring(0, delimiterIndex);
    String invisibleMetadata =
        substring(delimiterIndex + _metadataDelimiter.length);
    String metadataStr = _fromInvisible(invisibleMetadata);

    // تقسيم بيانات الميتاداتا إلى سجلات منفصلة (بصيغة "موقع:حرف").
    List<String> entries = metadataStr.split(',');
    List<String> chars = safeText.split('');
    for (String entry in entries) {
      if (entry.isEmpty) continue;
      List<String> parts = entry.split(':');
      if (parts.length != 2) continue;
      int index = int.parse(parts[0]);
      String originalChar = parts[1];
      if (index >= 0 && index < chars.length) {
        // استبدال الحرف في الموقع المحدد بالحرف الأصلي.
        chars[index] = originalChar;
      }
    }
    return chars.join();
  }
}
