//
// class BondType {
//   final String? type;
//   final String? name;
//   final String? latinName;
//   final int? from;
//   final int? to;
//   final int? taxType;
//
//   BondType({
//     required this.type,
//     required this.name,
//     required this.latinName,
//     required this.from,
//     required this.to,
//     required this.taxType,
//   });
//
//   factory BondType.fromJson(Map<String, dynamic> json) {
//     return BondType(
//       type: json['Type'],
//       name: json['Name'],
//       latinName: json['LatinName'],
//       from: json['From'],
//       to: json['To'],
//       taxType: json['TaxType'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'Type': type,
//       'Name': name,
//       'LatinName': latinName,
//       'From': from,
//       'To': to,
//       'TaxType': taxType,
//     };
//   }
// }
