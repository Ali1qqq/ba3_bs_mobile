class CustomerModel {
  final String? id;
  final String? name;
  final String? latinName;
  final String? prefix;
  final String? nation;
  final String? phone1;
  final String? phone2;
  final String? fax;
  final String? telex;
  final String? note;
  final String? accountGuid;
  final DateTime? checkDate;
  final int? security;
  final int? type;
  final double? discountRatio;
  final int? defaultPrice;
  final int? state;
  final String? email;
  final String? homePage;
  final String? suffix;
  final String? mobile;
  final String? pager;
  final String? hobbies;
  final String? gender;
  final String? certificate;
  final String? defaultAddressGuid;
  final String? cusVatGuid;

  CustomerModel({
    this.id,
    this.name,
    this.latinName,
    this.prefix,
    this.nation,
    this.phone1,
    this.phone2,
    this.fax,
    this.telex,
    this.note,
    this.accountGuid,
    this.checkDate,
    this.security,
    this.type,
    this.discountRatio,
    this.defaultPrice,
    this.state,
    this.email,
    this.homePage,
    this.suffix,
    this.mobile,
    this.pager,
    this.hobbies,
    this.gender,
    this.certificate,
    this.defaultAddressGuid,
    this.cusVatGuid,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['docId'] as String?,
      name: json['name'] as String?,
      latinName: json['latinName'] as String?,
      prefix: json['prefix'] as String?,
      nation: json['nation'] as String?,
      phone1: json['phone1'] as String?,
      phone2: json['phone2'] as String?,
      fax: json['fax'] as String?,
      telex: json['telex'] as String?,
      note: json['note'] as String?,
      accountGuid: json['accountGuid'] as String?,
      checkDate: DateTime.tryParse(json['checkDate'] as String? ?? ''),
      security: json['security'] as int?,
      type: json['type'] as int?,
      discountRatio: (json['discountRatio'] as num?)?.toDouble(),
      defaultPrice: json['defaultPrice'] as int?,
      state: json['state'] as int?,
      email: json['email'] as String?,
      homePage: json['homePage'] as String?,
      suffix: json['suffix'] as String?,
      mobile: json['mobile'] as String?,
      pager: json['pager'] as String?,
      hobbies: json['hobbies'] as String?,
      gender: json['gender'] as String?,
      certificate: json['certificate'] as String?,
      defaultAddressGuid: json['defaultAddressGuid'] as String?,
      cusVatGuid: json['cusVatGuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'name': name,
      'latinName': latinName,
      'prefix': prefix,
      'nation': nation,
      'phone1': phone1,
      'phone2': phone2,
      'fax': fax,
      'telex': telex,
      'note': note,
      'accountGuid': accountGuid,
      'checkDate': checkDate?.toIso8601String(),
      'security': security,
      'type': type,
      'discountRatio': discountRatio,
      'defaultPrice': defaultPrice,
      'state': state,
      'email': email,
      'homePage': homePage,
      'suffix': suffix,
      'mobile': mobile,
      'pager': pager,
      'hobbies': hobbies,
      'gender': gender,
      'certificate': certificate,
      'defaultAddressGuid': defaultAddressGuid,
      'cusVatGuid': cusVatGuid,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? latinName,
    String? prefix,
    String? nation,
    String? phone1,
    String? phone2,
    String? fax,
    String? telex,
    String? note,
    String? accountGuid,
    DateTime? checkDate,
    int? security,
    int? type,
    double? discountRatio,
    int? defaultPrice,
    int? state,
    String? email,
    String? homePage,
    String? suffix,
    String? mobile,
    String? pager,
    String? hobbies,
    String? gender,
    String? certificate,
    String? defaultAddressGuid,
    String? cusVatGuid,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latinName: latinName ?? this.latinName,
      prefix: prefix ?? this.prefix,
      nation: nation ?? this.nation,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      fax: fax ?? this.fax,
      telex: telex ?? this.telex,
      note: note ?? this.note,
      accountGuid: accountGuid ?? this.accountGuid,
      checkDate: checkDate ?? this.checkDate,
      security: security ?? this.security,
      type: type ?? this.type,
      discountRatio: discountRatio ?? this.discountRatio,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      state: state ?? this.state,
      email: email ?? this.email,
      homePage: homePage ?? this.homePage,
      suffix: suffix ?? this.suffix,
      mobile: mobile ?? this.mobile,
      pager: pager ?? this.pager,
      hobbies: hobbies ?? this.hobbies,
      gender: gender ?? this.gender,
      certificate: certificate ?? this.certificate,
      defaultAddressGuid: defaultAddressGuid ?? this.defaultAddressGuid,
      cusVatGuid: cusVatGuid ?? this.cusVatGuid,
    );
  }
}
