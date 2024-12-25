class CardModel {
  String? userId, cardId;
  bool? isDisabled;
  CardModel({
    this.userId,
    this.cardId,
    this.isDisabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'cardId': cardId,
      'isDisabled': isDisabled,
    };
  }

  CardModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    cardId = json['cardId'];
    isDisabled = json['isDisabled'];
  }
}

