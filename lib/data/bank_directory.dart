class BankDirectory {
  static const Map<String, String> bankCodes = {
    'SBIINB': 'State Bank of India',
    'SBININ': 'State Bank of India',
    'HDFCBK': 'HDFC Bank',
    'ICICIB': 'ICICI Bank',
    'AXISBK': 'Axis Bank',
    'PNBSMS': 'Punjab National Bank',
    'KOTAKB': 'Kotak Mahindra Bank',
    'BARBNK': 'Bank of Baroda',
    'CANBNK': 'Canara Bank',
    'UBINRA': 'Union Bank of India',
    'IDFCFB': 'IDFC First Bank',
    'IOBCHN': 'Indian Overseas Bank',
    'IOB': 'Indian Overseas Bank',
    'INDBNK': 'Indian Bank',
    'YESBNK': 'Yes Bank',
    'INDUSB': 'IndusInd Bank',
    'FEDBNK': 'Federal Bank',
    'CSBKOL': 'CSB Bank',
    'AIRBNK': 'Airtel Payments Bank',
    'PYTMBN': 'Paytm Payments Bank',
    'DBSSBK': 'DBS Bank',
    'AUFBIN': 'AU Small Finance Bank',
    'UJJIBF': 'Ujjivan Small Finance Bank',
    'DCBLTD': 'DCB Bank',
    'RATNBO': 'RBL Bank',
    'TMBLTD': 'Tamilnad Mercantile Bank',
    'CUBIND': 'City Union Bank',
    'KARBKB': 'Karnataka Bank',
    'MAHBIN': 'Bank of Maharashtra',
    'BOIIND': 'Bank of India',
    'CENTBK': 'Central Bank of India',
    'INDIAN': 'Indian Bank',
    'UCOBAN': 'UCO Bank',
    'ABNABK': 'ABN AMRO Bank',
    'ADCBBK': 'Abu Dhabi Commercial Bank',
    'AMEXBK': 'American Express',
    'ANZBGK': 'ANZ Bank',
    'BANDHK': 'Bandhan Bank',
    'MAYBKI': 'Maybank',
    'BOABK': 'Bank of America',
    'BBKBK': 'BBK Bank',
    'BOCBK': 'Bank of China',
    'BOCHK': 'Bank of China Hong Kong',
    'BARCBK': 'Barclays Bank',
    'BNPBK': 'BNP Paribas',
    'CITIBK': 'Citibank',
    'CRSUIS': 'Credit Suisse',
    'CREBK': 'Credit Bank',
    'DEUTBK': 'Deutsche Bank',
    'DHLBK': 'DHL Bank',
    'DOHBK': 'Doha Bank',
    'EMRNBD': 'Emirates NBD',
    'ESAFBK': 'ESAF Small Finance Bank',
    'FINOPB': 'Fino Payments Bank',
    'FABBK': 'First Abu Dhabi Bank',
    'FRBNK': 'First Rand Bank',
    'HNDLBK': 'Hongkong Bank',
    'HSBCBK': 'HSBC',
    'IDBIBK': 'IDBI Bank',
    'IPPB': 'India Post Payments Bank',
    'ICBCBK': 'ICBC Bank',
    'IBKBK': 'IBK Bank',
    'JKBK': 'Jammu & Kashmir Bank',
    'JPMBK': 'JPMorgan Chase',
    'KEBHBK': 'KEB Hana Bank',
    'KOOKBK': 'Kookmin Bank',
    'KTHBK': 'Krung Thai Bank',
    'MIZUBK': 'Mizuho Bank',
    'MUFGBK': 'MUFG Bank',
    'NAINBK': 'National Bank',
    'NATWBK': 'NatWest Bank',
    'PSBBK': 'Punjab & Sind Bank',
    'QNBBK': 'Qatar National Bank',
    'RABOBK': 'Rabobank',
    'SAXOBK': 'Saxo Bank',
    'SBERBK': 'Sberbank',
    'SCOTBK': 'Scotiabank',
    'SHINBK': 'Shinhan Bank',
    'SOCGBK': 'Societe Generale',
    'SONBK': 'Soneri Bank',
    'SIBK': 'South Indian Bank',
    'SCBK': 'Standard Chartered Bank',
    'SMBCBK': 'SMBC Bank',
    'UOBBK': 'UOB Bank',
    'WESTBK': 'Westpac Bank',
    'WOORIBK': 'Woori Bank',
  };

  static List<String> get allCodes => bankCodes.keys.toList();

  static bool isBankSender(String sender) {
    final upperSender = sender.toUpperCase();
    return bankCodes.keys.any((code) => upperSender.contains(code));
  }

  static String? findBankCode(String sender) {
    final upperSender = sender.toUpperCase();
    for (final code in bankCodes.keys) {
      if (upperSender.contains(code)) {
        return code;
      }
    }
    return null;
  }

  static String getBankName(String code) {
    return bankCodes[code] ?? 'Unknown Bank';
  }
}
