import '../../../accounts/data/models/account_model.dart';

class DiscountAdditionAccountModel extends AccountModel {
  double amount; // Add amount for discount/addition
  double percentage; // Add percentage for discount/addition

  DiscountAdditionAccountModel({
    required String accName,
    required String id,
    required this.amount,
    required this.percentage,
  }) : super(accName: accName, id: id);

  factory DiscountAdditionAccountModel.fromJson(Map<String, dynamic> json) {
    return DiscountAdditionAccountModel(
      accName: json['accName'],
      id: json['id'],
      amount: json['amount'],
      percentage: json['percentage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accName': accName,
      'id': id,
      'amount': amount,
      'percentage': percentage,
    };
  }
}
