import 'package:hive/hive.dart';

part 'dash_account_model.g.dart'; // اسم الملف الذي سيتم توليده

@HiveType(typeId: 2)
class DashAccountModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? balance;

  DashAccountModel({this.id, this.name, this.balance});

  // fromJson
  factory DashAccountModel.fromJson(Map<String, dynamic> json) {
    return DashAccountModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      balance: json['balance'] as String?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  @override
  String toString() {
    return 'DashAccountModel(id: $id, name: $name, balance: $balance)';
  }
}