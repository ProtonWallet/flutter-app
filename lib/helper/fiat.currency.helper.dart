import 'package:wallet/rust/proton_api/user_settings.dart';

class FiatCurrencyInfo {
  String name;
  String symbol;
  String sign;
  int cents;

  FiatCurrencyInfo(
      {required this.name, required this.symbol, required this.sign, required this.cents});
}

class FiatCurrencyHelper {
  static String getSymbol(FiatCurrency apiFiatCurrency) {
    String symbol = apiFiatCurrency.name.toUpperCase();
    return symbol;
  }

  static String getFullName(FiatCurrency apiFiatCurrency) {
    String name = "";
    String sign = "";
    String symbol = "";
    if (fiatCurrency2Info.containsKey(apiFiatCurrency)) {
      name = fiatCurrency2Info[apiFiatCurrency]!.name;
      sign = fiatCurrency2Info[apiFiatCurrency]!.sign;
      symbol = fiatCurrency2Info[apiFiatCurrency]!.symbol.toUpperCase();
    }
    return "$name, $symbol($sign)";
  }

  static String getDisplayName(FiatCurrency apiFiatCurrency) {
    String sign = "";
    String symbol = "";
    if (fiatCurrency2Info.containsKey(apiFiatCurrency)) {
      sign = fiatCurrency2Info[apiFiatCurrency]!.sign;
      symbol = fiatCurrency2Info[apiFiatCurrency]!.symbol.toUpperCase();
    }
    return "$symbol($sign)";
  }
}

const List<FiatCurrency> fiatCurrencies = [
  FiatCurrency.usd,
  FiatCurrency.eur,
  FiatCurrency.chf,
  FiatCurrency.aed,
  FiatCurrency.all,
  FiatCurrency.amd,
  FiatCurrency.ars,
  FiatCurrency.aud,
  FiatCurrency.azn,
  FiatCurrency.bam,
  FiatCurrency.bdt,
  FiatCurrency.bgn,
  FiatCurrency.bhd,
  FiatCurrency.bmd,
  FiatCurrency.bob,
  FiatCurrency.brl,
  FiatCurrency.byn,
  FiatCurrency.cad,
  FiatCurrency.clp,
  FiatCurrency.cny,
  FiatCurrency.cop,
  FiatCurrency.crc,
  FiatCurrency.cup,
  FiatCurrency.czk,
  FiatCurrency.dkk,
  FiatCurrency.dop,
  FiatCurrency.dzd,
  FiatCurrency.egp,
  FiatCurrency.gbp,
  FiatCurrency.gel,
  FiatCurrency.ghs,
  FiatCurrency.gtq,
  FiatCurrency.hkd,
  FiatCurrency.hnl,
  FiatCurrency.hrk,
  FiatCurrency.huf,
  FiatCurrency.idr,
  FiatCurrency.ils,
  FiatCurrency.inr,
  FiatCurrency.iqd,
  FiatCurrency.irr,
  FiatCurrency.isk,
  FiatCurrency.jmd,
  FiatCurrency.jod,
  FiatCurrency.jpy,
  FiatCurrency.kes,
  FiatCurrency.kgs,
  FiatCurrency.khr,
  FiatCurrency.krw,
  FiatCurrency.kwd,
  FiatCurrency.kzt,
  FiatCurrency.lbp,
  FiatCurrency.lkr,
  FiatCurrency.mad,
  FiatCurrency.mdl,
  FiatCurrency.mkd,
  FiatCurrency.mmk,
  FiatCurrency.mnt,
  FiatCurrency.mur,
  FiatCurrency.mxn,
  FiatCurrency.myr,
  FiatCurrency.nad,
  FiatCurrency.ngn,
  FiatCurrency.nio,
  FiatCurrency.nok,
  FiatCurrency.npr,
  FiatCurrency.nzd,
  FiatCurrency.omr,
  FiatCurrency.pab,
  FiatCurrency.pen,
  FiatCurrency.php,
  FiatCurrency.pkr,
  FiatCurrency.pln,
  FiatCurrency.qar,
  FiatCurrency.ron,
  FiatCurrency.rsd,
  FiatCurrency.rub,
  FiatCurrency.sar,
  FiatCurrency.sek,
  FiatCurrency.sgd,
  FiatCurrency.ssp,
  FiatCurrency.thb,
  FiatCurrency.tnd,
  FiatCurrency.ttd,
  FiatCurrency.twd,
  FiatCurrency.uah,
  FiatCurrency.ugx,
  FiatCurrency.uyu,
  FiatCurrency.uzs,
  FiatCurrency.ves,
  FiatCurrency.vnd,
  FiatCurrency.zar,
];

/// These info comes from /api/wallet/v1/fiat-currencies
/// Since change is unlikely, there's no need to load dynamically via API.
final Map<FiatCurrency, FiatCurrencyInfo> fiatCurrency2Info = {
  FiatCurrency.all: FiatCurrencyInfo(name: 'Albanian Lek', symbol: 'all', sign: 'L', cents: 100),
  FiatCurrency.dzd: FiatCurrencyInfo(name: 'Algerian Dinar', symbol: 'dzd', sign: 'د.ج', cents: 100),
  FiatCurrency.ars: FiatCurrencyInfo(name: 'Argentine Peso', symbol: 'ars', sign: '\$', cents: 100),
  FiatCurrency.amd: FiatCurrencyInfo(name: 'Armenian Dram', symbol: 'amd', sign: '֏', cents: 100),
  FiatCurrency.aud: FiatCurrencyInfo(name: 'Australian Dollar', symbol: 'aud', sign: '\$', cents: 100),
  FiatCurrency.azn: FiatCurrencyInfo(name: 'Azerbaijani Manat', symbol: 'azn', sign: '₼', cents: 100),
  FiatCurrency.bhd: FiatCurrencyInfo(name: 'Bahraini Dinar', symbol: 'bhd', sign: '.د.ب', cents: 1000),
  FiatCurrency.bdt: FiatCurrencyInfo(name: 'Bangladeshi Taka', symbol: 'bdt', sign: '৳', cents: 100),
  FiatCurrency.byn: FiatCurrencyInfo(name: 'Belarusian Ruble', symbol: 'byn', sign: 'Br', cents: 100),
  FiatCurrency.bmd: FiatCurrencyInfo(name: 'Bermudan Dollar', symbol: 'bmd', sign: '\$', cents: 100),
  FiatCurrency.bob: FiatCurrencyInfo(name: 'Bolivian Boliviano', symbol: 'bob', sign: 'Bs.', cents: 100),
  FiatCurrency.bam: FiatCurrencyInfo(name: 'Bosnia-Herzegovina Convertible Mark', symbol: 'bam', sign: 'KM', cents: 100),
  FiatCurrency.brl: FiatCurrencyInfo(name: 'Brazilian Real', symbol: 'brl', sign: 'R\$', cents: 100),
  FiatCurrency.bgn: FiatCurrencyInfo(name: 'Bulgarian Lev', symbol: 'bgn', sign: 'лв', cents: 100),
  FiatCurrency.khr: FiatCurrencyInfo(name: 'Cambodian Riel', symbol: 'khr', sign: '៛', cents: 100),
  FiatCurrency.cad: FiatCurrencyInfo(name: 'Canadian Dollar', symbol: 'cad', sign: '\$', cents: 100),
  FiatCurrency.clp: FiatCurrencyInfo(name: 'Chilean Peso', symbol: 'clp', sign: '\$', cents: 1),
  FiatCurrency.cny: FiatCurrencyInfo(name: 'Chinese Yuan', symbol: 'cny', sign: '¥', cents: 100),
  FiatCurrency.cop: FiatCurrencyInfo(name: 'Colombian Peso', symbol: 'cop', sign: '\$', cents: 100),
  FiatCurrency.crc: FiatCurrencyInfo(name: 'Costa Rican Colón', symbol: 'crc', sign: '₡', cents: 100),
  FiatCurrency.hrk: FiatCurrencyInfo(name: 'Croatian Kuna', symbol: 'hrk', sign: 'kn', cents: 100),
  FiatCurrency.cup: FiatCurrencyInfo(name: 'Cuban Peso', symbol: 'cup', sign: '\$', cents: 100),
  FiatCurrency.czk: FiatCurrencyInfo(name: 'Czech Koruna', symbol: 'czk', sign: 'Kč', cents: 100),
  FiatCurrency.dkk: FiatCurrencyInfo(name: 'Danish Krone', symbol: 'dkk', sign: 'kr', cents: 100),
  FiatCurrency.dop: FiatCurrencyInfo(name: 'Dominican Peso', symbol: 'dop', sign: '\$', cents: 100),
  FiatCurrency.egp: FiatCurrencyInfo(name: 'Egyptian Pound', symbol: 'egp', sign: '£', cents: 100),
  FiatCurrency.eur: FiatCurrencyInfo(name: 'Euro', symbol: 'eur', sign: '€', cents: 100),
  FiatCurrency.gel: FiatCurrencyInfo(name: 'Georgian Lari', symbol: 'gel', sign: '₾', cents: 100),
  FiatCurrency.ghs: FiatCurrencyInfo(name: 'Ghanaian Cedi', symbol: 'ghs', sign: '₵', cents: 100),
  FiatCurrency.gtq: FiatCurrencyInfo(name: 'Guatemalan Quetzal', symbol: 'gtq', sign: 'Q', cents: 100),
  FiatCurrency.hnl: FiatCurrencyInfo(name: 'Honduran Lempira', symbol: 'hnl', sign: 'L', cents: 100),
  FiatCurrency.hkd: FiatCurrencyInfo(name: 'Hong Kong Dollar', symbol: 'hkd', sign: '\$', cents: 100),
  FiatCurrency.huf: FiatCurrencyInfo(name: 'Hungarian Forint', symbol: 'huf', sign: 'Ft', cents: 1),
  FiatCurrency.isk: FiatCurrencyInfo(name: 'Icelandic Króna', symbol: 'isk', sign: 'kr', cents: 1),
  FiatCurrency.inr: FiatCurrencyInfo(name: 'Indian Rupee', symbol: 'inr', sign: '₹', cents: 100),
  FiatCurrency.idr: FiatCurrencyInfo(name: 'Indonesian Rupiah', symbol: 'idr', sign: 'Rp', cents: 100),
  FiatCurrency.irr: FiatCurrencyInfo(name: 'Iranian Rial', symbol: 'irr', sign: '﷼', cents: 100),
  FiatCurrency.iqd: FiatCurrencyInfo(name: 'Iraqi Dinar', symbol: 'iqd', sign: 'ع.د', cents: 1000),
  FiatCurrency.ils: FiatCurrencyInfo(name: 'Israeli New Shekel', symbol: 'ils', sign: '₪', cents: 100),
  FiatCurrency.jmd: FiatCurrencyInfo(name: 'Jamaican Dollar', symbol: 'jmd', sign: '\$', cents: 100),
  FiatCurrency.jpy: FiatCurrencyInfo(name: 'Japanese Yen', symbol: 'jpy', sign: '¥', cents: 1),
  FiatCurrency.jod: FiatCurrencyInfo(name: 'Jordanian Dinar', symbol: 'jod', sign: 'د.ا', cents: 1000),
  FiatCurrency.kzt: FiatCurrencyInfo(name: 'Kazakhstani Tenge', symbol: 'kzt', sign: '₸', cents: 100),
  FiatCurrency.kes: FiatCurrencyInfo(name: 'Kenyan Shilling', symbol: 'kes', sign: 'Sh', cents: 100),
  FiatCurrency.kwd: FiatCurrencyInfo(name: 'Kuwaiti Dinar', symbol: 'kwd', sign: 'د.ك', cents: 1000),
  FiatCurrency.kgs: FiatCurrencyInfo(name: 'Kyrgystani Som', symbol: 'kgs', sign: 'с', cents: 100),
  FiatCurrency.lbp: FiatCurrencyInfo(name: 'Lebanese Pound', symbol: 'lbp', sign: 'ل.ل', cents: 100),
  FiatCurrency.mkd: FiatCurrencyInfo(name: 'Macedonian Denar', symbol: 'mkd', sign: 'ден', cents: 100),
  FiatCurrency.myr: FiatCurrencyInfo(name: 'Malaysian Ringgit', symbol: 'myr', sign: 'RM', cents: 100),
  FiatCurrency.mur: FiatCurrencyInfo(name: 'Mauritian Rupee', symbol: 'mur', sign: '₨', cents: 100),
  FiatCurrency.mxn: FiatCurrencyInfo(name: 'Mexican Peso', symbol: 'mxn', sign: '\$', cents: 100),
  FiatCurrency.mdl: FiatCurrencyInfo(name: 'Moldovan Leu', symbol: 'mdl', sign: 'L', cents: 100),
  FiatCurrency.mnt: FiatCurrencyInfo(name: 'Mongolian Tugrik', symbol: 'mnt', sign: '₮', cents: 100),
  FiatCurrency.mad: FiatCurrencyInfo(name: 'Moroccan Dirham', symbol: 'mad', sign: 'د.م.', cents: 100),
  FiatCurrency.mmk: FiatCurrencyInfo(name: 'Myanma Kyat', symbol: 'mmk', sign: 'Ks', cents: 100),
  FiatCurrency.nad: FiatCurrencyInfo(name: 'Namibian Dollar', symbol: 'nad', sign: '\$', cents: 100),
  FiatCurrency.npr: FiatCurrencyInfo(name: 'Nepalese Rupee', symbol: 'npr', sign: '₨', cents: 100),
  FiatCurrency.twd: FiatCurrencyInfo(name: 'New Taiwan Dollar', symbol: 'twd', sign: 'NT\$', cents: 1),
  FiatCurrency.nzd: FiatCurrencyInfo(name: 'New Zealand Dollar', symbol: 'nzd', sign: '\$', cents: 100),
  FiatCurrency.nio: FiatCurrencyInfo(name: 'Nicaraguan Córdoba', symbol: 'nio', sign: 'C\$', cents: 100),
  FiatCurrency.ngn: FiatCurrencyInfo(name: 'Nigerian Naira', symbol: 'ngn', sign: '₦', cents: 100),
  FiatCurrency.nok: FiatCurrencyInfo(name: 'Norwegian Krone', symbol: 'nok', sign: 'kr', cents: 100),
  FiatCurrency.omr: FiatCurrencyInfo(name: 'Omani Rial', symbol: 'omr', sign: 'ر.ع.', cents: 1000),
  FiatCurrency.pkr: FiatCurrencyInfo(name: 'Pakistani Rupee', symbol: 'pkr', sign: '₨', cents: 100),
  FiatCurrency.pab: FiatCurrencyInfo(name: 'Panamanian Balboa', symbol: 'pab', sign: 'B/.', cents: 100),
  FiatCurrency.pen: FiatCurrencyInfo(name: 'Peruvian Sol', symbol: 'pen', sign: 'S/.', cents: 100),
  FiatCurrency.php: FiatCurrencyInfo(name: 'Philippine Peso', symbol: 'php', sign: '₱', cents: 100),
  FiatCurrency.pln: FiatCurrencyInfo(name: 'Polish Złoty', symbol: 'pln', sign: 'zł', cents: 100),
  FiatCurrency.gbp: FiatCurrencyInfo(name: 'Pound Sterling', symbol: 'gbp', sign: '£', cents: 100),
  FiatCurrency.qar: FiatCurrencyInfo(name: 'Qatari Rial', symbol: 'qar', sign: 'ر.ق', cents: 100),
  FiatCurrency.ron: FiatCurrencyInfo(name: 'Romanian Leu', symbol: 'ron', sign: 'lei', cents: 100),
  FiatCurrency.rub: FiatCurrencyInfo(name: 'Russian Ruble', symbol: 'rub', sign: '₽', cents: 100),
  FiatCurrency.sar: FiatCurrencyInfo(name: 'Saudi Riyal', symbol: 'sar', sign: 'ر.س', cents: 100),
  FiatCurrency.rsd: FiatCurrencyInfo(name: 'Serbian Dinar', symbol: 'rsd', sign: 'дин.', cents: 100),
  FiatCurrency.sgd: FiatCurrencyInfo(name: 'Singapore Dollar', symbol: 'sgd', sign: 'S\$', cents: 100),
  FiatCurrency.zar: FiatCurrencyInfo(name: 'South African Rand', symbol: 'zar', sign: 'R', cents: 100),
  FiatCurrency.krw: FiatCurrencyInfo(name: 'South Korean Won', symbol: 'krw', sign: '₩', cents: 1),
  FiatCurrency.ssp: FiatCurrencyInfo(name: 'South Sudanese Pound', symbol: 'ssp', sign: '£', cents: 100),
  FiatCurrency.ves: FiatCurrencyInfo(name: 'Sovereign Bolivar', symbol: 'ves', sign: 'VES', cents: 100),
  FiatCurrency.lkr: FiatCurrencyInfo(name: 'Sri Lankan Rupee', symbol: 'lkr', sign: 'Rs', cents: 100),
  FiatCurrency.sek: FiatCurrencyInfo(name: 'Swedish Krona', symbol: 'sek', sign: 'kr', cents: 100),
  FiatCurrency.chf: FiatCurrencyInfo(name: 'Swiss Franc', symbol: 'chf', sign: 'Fr', cents: 100),
  FiatCurrency.thb: FiatCurrencyInfo(name: 'Thai Baht', symbol: 'thb', sign: '฿', cents: 100),
  FiatCurrency.ttd: FiatCurrencyInfo(name: 'Trinidad and Tobago Dollar', symbol: 'ttd', sign: 'TTD', cents: 100),
  FiatCurrency.tnd: FiatCurrencyInfo(name: 'Tunisian Dinar', symbol: 'tnd', sign: 'د.ت', cents: 1000),
  FiatCurrency.ugx: FiatCurrencyInfo(name: 'Ugandan Shilling', symbol: 'ugx', sign: 'UGX', cents: 1),
  FiatCurrency.uah: FiatCurrencyInfo(name: 'Ukrainian Hryvnia', symbol: 'uah', sign: '₴', cents: 100),
  FiatCurrency.aed: FiatCurrencyInfo(name: 'United Arab Emirates Dirham', symbol: 'aed', sign: 'د.إ', cents: 100),
  FiatCurrency.usd: FiatCurrencyInfo(name: 'United States Dollar', symbol: 'usd', sign: '\$', cents: 100),
  FiatCurrency.uyu: FiatCurrencyInfo(name: 'Uruguayan Peso', symbol: 'uyu', sign: 'UYU', cents: 100),
  FiatCurrency.uzs: FiatCurrencyInfo(name: 'Uzbekistan Som', symbol: 'uzs', sign: 'UZS', cents: 100),
  FiatCurrency.vnd: FiatCurrencyInfo(name: 'Vietnamese Dong', symbol: 'vnd', sign: '₫', cents: 1),
};
