import '../helper/enums/enums.dart';

abstract class AppConstants {
  static String dataName = '';
  static bool isFreeType = false;

  static const EnvType env = EnvType.debug; //"debug" or "release"
  static const vatGCC = 0.05;
  static const constHeightTextField = 50.0;
  static const constHeightDropDown = 30.0;

  static const vat0_01 = 0.01;
  static const rowCustomBondAmount = 'rowCustomBondAmount';
  static const rowBondId = 'id';
  static const rowBondCreditAmount = 'credit';
  static const rowBondDebitAmount = 'debit';
  static const rowBondAccount = 'secondary';
  static const rowBondDescription = 'description';
  static const noVatKey = 'noVat-';
  static const minMobileTarget = 1000;
  static const minOtherTarget = 1000;

  ////////////--------------------------------------------------
  static String changesCollection = "$dataName-Changes";
  static const recordCollection = 'Record';
  static String bondsCollection = 'Bonds';
  static String accountsCollection = 'Accounts';
  static String tasksCollection = 'Tasks';
  static String invoicesCollection = 'Invoices';
  static String warrantyCollection = 'Warranty';
  static String productsCollection = "Products";
  static String logsCollection = "Logs";
  static String patternCollection = "Patterns";
  static String storeCollection = "Stores";
  static String chequesCollection = "Cheques";
  static String costCenterCollection = "CostCenter";
  static String sellersCollection = "Sellers";
  static String usersCollection = "users";
  static String roleCollection = "Role";
  static String settingCollection = "Setting";
  static String readFlagsCollection = "ReadFlags";
  static String inventoryCollection = "Inventory";
  static String globalCollection = dataName;
  static String ba3Invoice = "ba3Invoice";
  static String dataCollection = "data";

  ////////////--------------------------------------------------
  static const rowAccountId = 'rowAccountId';
  static const rowAccountTotal = 'rowAccountTotal';
  static const rowAccountTotal2 = 'rowAccountTotal2';
  static const rowAccountType = 'rowAccountType';
  static const rowAccountName = 'rowAccountName';
  static const rowAccountDate = 'rowAccountDate';
  static const rowAccountBalance = 'rowAccountBalance';

  ////////////--------------------------------------------------
  static const rowInvId = "invId";
  static const rowInvProduct = "invProduct";
  static const rowInvGift = "rowInvGift";
  static const rowInvQuantity = "invQuantity";
  static const rowInvSubTotal = "invSubTotal";
  static const rowInvVat = "rowInvVat";
  static const rowInvTotal = "invTotal";
  static const rowInvTotalVat = "rowInvTotalVat";
  static const rowInvDiscountId = "rowInvDiscountId";
  static const rowInvDiscountAccount = "rowInvDiscountAccount";
  static const rowInvDisAddedTotal = "rowInvDisAddedTotal";
  static const rowInvDisAddedPercentage = "rowInvDisAddedPercentage";
  static const rowInvDisDiscountTotal = "rowInvDisDiscountTotal";
  static const rowInvDisDiscountPercentage = "rowInvDisDiscountPercentage";

  ////////////--------------------------------------------------
  static const rowViewAccountId = "rowViewAccountId";
  static const rowViewAccountName = "rowViewAccountName";
  static const rowViewAccountCode = "rowViewAccountCode";
  static const rowViewAccountBalance = "rowViewAccountBalance";
  static const rowViewAccountLength = "rowViewAccountLength";

  ////////////--------------------------------------------------
  static const rowProductRecProduct = 'rowProductRecProduct';
  static const rowProductType = "rowProductType";
  static const rowProductQuantity = "rowProductQuantity";
  static const rowProductDate = "rowProductDate";
  static const rowProductTotal = "rowProductTotal";
  static const rowProductInvId = "rowProductInvId";
  static const productTypeService = "productTypeService";
  static const productTypeStore = "productTypeStore";

  ////////////--------------------------------------------------
  static const patId = "patId";
  static const patCode = "patCode";
  static const patPrimary = "patPrimary";
  static const patName = "patName";
  static const patType = "patType";

  ////////////--------------------------------------------------
  static const invoiceTypeSales = "invoiceTypeSales";
  static const invoiceTypeBuyReturn = "invoiceTypeBuyReturn";
  static const invoiceTypeSalesReturn = "invoiceTypeSalesReturn";
  static const invoiceTypeSalesWithPartner = "invoiceTypeSalesWithPartner";
  static const invoiceTypeBuy = 'invoiceTypeBuy';
  static const invoiceTypeAdd = "invoiceTypeAdd";
  static const invoiceTypeRemove = "invoiceTypeRemove";
  static const invoiceTypeChange = "invoiceTypeChange";
  static const tabbySales = "م Tabby";
  static const stripSales = "م Strip";
  static const cardSales = "م Card";






  ////////////--------------------------------------------------
  static const rowImportName = "rowImportName";
  static const rowImportPrice = "rowImportPrice";
  static const rowImportBarcode = "rowImportBarcode";
  static const rowImportCode = "rowImportCode";
  static const rowImportGroupCode = "rowImportGroupCode";
  static const rowImportHasVat = "rowImportHasVat";

  ////////////--------------------------------------------------
  static const roleUserRead = "roleUserRead";
  static const roleUserWrite = "roleUserWrite";
  static const roleUserUpdate = "roleUserUpdate";
  static const roleUserDelete = "roleUserDelete";
  static const roleUserAdmin = "roleUserAdmin";
  static const roleViewBond = "roleViewBond";
  static const roleViewAccount = "roleViewAccount";
  static const roleViewInvoice = "roleViewInvoice";
  static const roleViewMaterial = "roleViewMaterial";
  static const roleViewStore = "roleViewStore";
  static const roleViewPattern = "roleViewPattern";
  static const roleViewCheques = "roleViewCheques";
  static const roleViewSeller = "roleViewSeller";
  static const roleViewReport = "roleViewReport";
  static const roleViewImport = "roleViewImport";
  static const roleViewTask = "roleViewTask";
  static const roleViewTarget = "roleViewTarget";
  static const roleViewInventory = "roleViewInventory";
  static const roleViewUserManagement = "roleViewUserManagement";
  static const roleViewDue = "roleViewDue";
  static const roleViewStatistics = "roleViewStatistics";
  static const roleViewTimer = "roleViewTimer";
  static const roleViewDataBase = "roleViewDataBase";
  static const roleViewCard = "roleViewCard";
  static const roleViewHome = "roleViewHome";

  ////////////--------------------------------------------------
  static const invoiceChoosePriceMethodeCustomerPrice = "invoiceChoosePriceMethodeCustomerPrice";
  static const invoiceChoosePriceMethodeDefault = "invoiceChoosePriceMethodeCustomerPrice";
  static const invoiceChoosePriceMethodeLastPrice = "invoiceChoosePriceMethodeLastPrice";
  static const invoiceChoosePriceMethodeAveragePrice = "invoiceChoosePriceMethodeAveragePrice";
  static const invoiceChoosePriceMethodeHigher = "invoiceChoosePriceMethodeHigher";
  static const invoiceChoosePriceMethodeLower = "invoiceChoosePriceMethodeLower";
  static const invoiceChoosePriceMethodeMinPrice = "invoiceChoosePriceMethodeMinPrice";
  static const invoiceChoosePriceMethodeAverageBuyPrice = "invoiceChoosePriceMethodeAverageBuyPrice";
  static const invoiceChoosePriceMethodeWholePrice = "invoiceChoosePriceMethodeWholePrice";
  static const invoiceChoosePriceMethodeRetailPrice = "invoiceChoosePriceMethodeRetailPrice";
  static const invoiceChoosePriceMethodeCostPrice = "invoiceChoosePriceMethodeCostPrice";
  static const invoiceChoosePriceMethodeCustom = "invoiceChoosePriceMethodeCustom";

  ////////////--------------------------------------------------
  static const rowAccountAggregateName = "rowAccountAggregateName";

  ////////////---------------------------------------------------
  static const globalTypeInvoice = "globalTypeInvoice";
  static const globalTypeBond = "globalTypeBond";
  static const globalTypeCheque = "globalTypeCheque";
  static const globalTypeAccountDue = "globalAccountDue";
  static const globalTypeStartersBond = "globalTypeStartersBond";

  ////////////---------------------------------------------------
  static const invoiceRecordCollection = "invoiceRecord";
  static const bondRecordCollection = "bondRecord";
  static const chequeRecordCollection = "chequeRecord";

  ////////////----------------------------------------------------
  static const productsAllSubscription = "productsAllSubscription";

  ////////////----------------------------------------------------
  static const paidStatusFullUsed = "paidStatusFullUse";
  static const paidStatusNotUsed = "paidStatusNotUsed";
  static const paidStatusSemiUsed = "paidStatusSemiUsed";

  ////////////----------------------------------------------------
  static const userStatusOnline = "userStatusOnline";
  static const userStatusAway = "userStatusAway";

  ////////////----------------------------------------------------
  static const invPayTypeDue = "invPayTypeDue";
  static const invPayTypeCash = "invPayTypeCash";

  /////////////---------------------------------------------------
  static const taskTypeProduct = 'taskTypeProduct';
  static const taskTypeInventory = 'taskTypeInventory';

  static const typeAccountView = "typeAccountView";
  static const typeAccountDueView = "typeAccountDueView";

  static const salleTypeId = "pat1706468132863249";

  /////////////---------------------------------------------------
  static const mainVATCategory = "SR-التصنيف الأساسي";
  static const withoutVAT = "EX-معفى";

  // static String vatAccountId = getAccountIdFromText("ضريبة القيمة المضافة رأس الخيمة");
  // static String returnVatAccountId = getAccountIdFromText("استرداد ضريبة القيمة المضافة رأس الخيمة");

  /////////////---------------------------------------------------
  static const firstTimeEnter = "FirstTimeEnter";
  static const secondTimeEnter = "secondTimeEnter";
  static const firstTimeOut = "secondTimeEnter";
  static const secondTimeOut = "secondTimeEnter";
  static const breakTime = "secondTimeEnter";

  static const allRolePage = [
    AppConstants.roleViewBond,
    AppConstants.roleViewAccount,
    AppConstants.roleViewInvoice,
    AppConstants.roleViewMaterial,
    AppConstants.roleViewStore,
    AppConstants.roleViewPattern,
    AppConstants.roleViewCheques,
    AppConstants.roleViewSeller,
    AppConstants.roleViewReport,
    AppConstants.roleViewTarget,
    AppConstants.roleViewInventory,
    AppConstants.roleViewTask,
    AppConstants.roleViewImport,
    AppConstants.roleViewUserManagement,
    AppConstants.roleViewDue,
    AppConstants.roleViewStatistics,
    AppConstants.roleViewTimer,
    AppConstants.roleViewDataBase,
    AppConstants.roleViewCard,
    AppConstants.roleViewHome
  ];


  static const String success = 'success';
  static const String badRequestError = 'bad_request_error';
  static const String noContent = 'no_content';
  static const String forbiddenError = 'forbidden_error';
  static const String unauthorizedError = 'unauthorized_error';
  static const String notFoundError = 'not_found_error';
  static const String conflictError = 'conflict_error';
  static const String internalServerError = 'internal_server_error';
  static const String unknownError = 'unknown_error';
  static const String timeoutError = 'timeout_error';
  static const String defaultError = 'default_error';
  static const String cancelError = 'cancel_error';
  static const String cacheError = 'cache_error';
  static const String noInternetError = 'no_internet_error';

  //bill
  static const String invRecId = 'invRecId';
  static const String invRecProduct = 'invRecProduct';

  static const String invRecProductSoldSerial = 'invRecProductSoldSerial';

  static const String invRecProductSerialNumbers = 'invRecProductSerialNumbers';
  static const String invRecTotal = 'invRecTotal';
  static const String invRecSubTotal = 'invRecSubTotal';
  static const String invRecVat = 'invRecVat';
  static const String invRecQuantity = 'invRecQuantity';
  static const String invRecIsLocal = 'invRecIsLocal';
  static const String invRecGift = 'invRecGift';
  static const String invRecGiftTotal = 'invRecGiftTotal';
  static const String invRecSubTotalWithVat = 'invRecSubTotalWithVat';
  static const String ratio = 'النسبة';
  static const String value = 'القيمة';
  static const String accountName = 'اسم الحساب';
  static const String id = 'id';
  static const String discount = 'discount';
  static const String addition = 'addition';
  static const String discountRatio = 'discountRatio';
  static const String additionRatio = 'additionRatio';
  static const String account = 'الحساب';
  static const String discountAr = 'الحسم';
  static const String discountRatioAr = 'نسبة الحسم';
  static const String additionAr = 'الاضافات';
  static const String additionRatioAr = 'نسبة الاضافات';
  static const String deleteConfirmationTitle = 'تأكيد الحذف';
  static const String deleteConfirmationMessage = 'هل انت متأكد من حذف هذا العنصر';
  static const String yes = 'نعم';
  static const String no = 'لا';

  static const String discountAccountType = 'discountAccountType';
  static const String additionAccountType = 'additionAccountType';

  ///Pay Items
  //////////////////////////////////////////////////////////////
  static const String entryAccountGuid = 'EntryAccountGuid';
  static const String entryDate = 'EntryDate';
  static const String entryDebit = 'EntryDebit';
  static const String entryCredit = 'EntryCredit';
  static const String entryNote = 'EntryNote';
  static const String entryCurrencyGuid = 'EntryCurrencyGuid';
  static const String entryCurrencyVal = 'EntryCurrencyVal';
  static const String entryCostGuid = 'EntryCostGuid';
  static const String entryClass = 'EntryClass';
  static const String entryNumber = 'EntryNumber';
  static const String entryCustomerGuid = 'EntryCustomerGuid';
  static const String entryType = 'EntryType';

  /// Bond
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  static const String payTypeGuid = 'PayTypeGuid';
  static const String payNumber = 'PayNumber';
  static const String payGuid = 'PayGuid';
  static const String payBranchGuid = 'PayBranchGuid';
  static const String payDate = 'PayDate';
  static const String entryPostDate = 'EntryPostDate';
  static const String payNote = 'PayNote';
  static const String payCurrencyGuid = 'PayCurrencyGuid';
  static const String payCurVal = 'PayCurVal';
  static const String payAccountGuid = 'PayAccountGuid';
  static const String paySecurity = 'PaySecurity';
  static const String paySkip = 'PaySkip';
  static const String prParentType = 'ErParentType';
  static const String payItems = 'PayItems';

  /// Cheques
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  static const String chequesTypeGuid = "chequesTypeGuid";
  static const String chequesNumber = "chequesNumber";
  static const String chequesNum = "chequesNum";
  static const String chequesGuid = "chequesGuid";
  static const String chequesDate = "chequesDate";
  static const String chequesDueDate = "chequesDueDate";
  static const String chequesNote = "chequesNote";
  static const String chequesVal = "chequesVal";
  static const String chequesAccount2Guid = "chequesAccount2Guid";
  static const String accPtr = "accPtr";
  static const String accPtrName = "accPtrName";
  static const String chequesAccount2Name = "chequesAccount2Name";
  static const String isPayed = "isPayed";

  static const double bottomWindowWidth = 200;
  static const double bottomWindowHeight = 40;

  static const double deviceFullWidth = 1680.0;
  static const double deviceFullHeight = 930.0;

  static const String userIdKey = 'userIdKey';

  static const String recipientEmail = 'burjalarab000@gmail.com';

  // static const String recipientEmail = 'ahmed.zein1896@gmail.com';

  // static const String recipientEmail = 'alidabol567@gmail.com';

  static const int maxItemsPerBill = 100;

  static const List<String> locales = [
    'ar',
    'en',
    'ur',
    'fr',
    'de',
    'zh',
  ];

  static const String appLocalLangBox = 'appLocalLangBox';

  static const String defaultLangCode = 'en';

  static const String chequeToAccountId = '7d471b63-4499-4c2f-ba99-21912c8b98b5';
  static const String chequeToAccountName = 'اوراق الدفع';
  static const String bankAccountId = 'a3fe9771-c9cf-4790-b782-c1c3977bcd99';
  static const String bankToAccountName = 'المصرف';

  ///------------------------------------------
  static const String taxLocalAccountId = '3044a58b-8a76-461b-9385-cb87df3e0afd';
  static const String taxLocalAccountName = 'ضريبة القيمة المضافة رأس الخيمة';
  static const String returnTaxAccountId = '81e6d822-e3ee-4f42-92bf-f96eed4a0045';
  static const String returnTaxAccountName = 'استرداد ضريبة القيمة المضافة رأس الخيمة';




  ///------------------------------------------
  static const String taxFreeAccountId = '19dccbca-b32e-4604-b37c-980cbbd2f15a';
  static const String taxFreeAccountName = 'ضريبة القيمة المضافة فري زون';
  static const String returnFreeTaxAccountId = '2181459c-3293-42f5-b80e-7232e824786f';
  static const String returnFreeTaxAccountName = 'استرداد ضريبة القيمة المضافة فري زون';




  ///------------------------------------------
  static const String primaryCashAccountId = '5b36c82d-9105-4177-a5c3-0f90e5857e3c';
  static const String primaryCashAccountName = 'الصندوق';

  static const double targetLatitude = 25.793679566610773; // Latitude المنطقة المستهدفة
  static const double targetLongitude = 55.948330278435; // Longitude المنطقة المستهدفة
  static const double radiusInMeters = 25;
  static const double secondTargetLatitude = 25.765046214850365; // Latitude المنطقة المستهدفة
  static const double secondTargetLongitude = 55.970645196084746; // Longitude المنطقة المستهدفة
  static const double secondRadiusInMeters = 50;
  ////// pluto Filed Names
  static const String materialIdFiled = 'materialIdFiled';
  static const String materialGroupIdFiled = 'materialGroupIdFiled';
  static const String userIdFiled = 'userIdFiled';
  static const String accountIdFiled = 'accountIdFiled';
  static const String entryBonIdFiled = 'entryBonIdFiled';
  static const String billIdFiled = 'billIdFiled';
  static var bondIdFiled='bondIdFiled';


  /////
  static const bool hideInvRecProductSoldSerial = false;
  static const bool hideInvRecProductSerialNumbers = false;
  static const String serialNumbersStatement = 'serialNumbersStatement';
  static const String searchByPhone = 'searchByPhone';
  static const String searchByOrderNumber = 'searchByOrderNumber';
  static const String userTaskIdField = 'userTaskIdField';
  static const String defaultVersion = 'الأساسي';

  static const Map<String, String> months = {
    "يناير (1)": "01",
    "فبراير (2)": "02",
    "مارس (3)": "03",
    "أبريل (4)": "04",
    "مايو (5)": "05",
    "يونيو (6)": "06",
    "يوليو (7)": "07",
    "أغسطس (8)": "08",
    "سبتمبر (9)": "09",
    "أكتوبر (10)": "10",
    "نوفمبر (11)": "11",
    "ديسمبر (12)": "12",
  };


}