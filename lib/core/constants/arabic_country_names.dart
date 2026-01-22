import 'dart:convert';

import 'package:flutter/services.dart';

import '../services/logger_service.dart';

/// Arabic translations for country names (ISO 3166-1 alpha-2 codes)
///
/// This class provides Arabic translations with a layered approach:
/// 1. JSON asset data (loaded at app startup) - primary source
/// 2. Static fallback data (compiled into app) - always available
///
/// Call [loadFromAsset] during app initialization for best experience.
abstract class ArabicCountryNames {
  // Asset path
  static const String _assetPath = 'assets/data/arabic_translations.json';

  // Loaded JSON data (takes precedence when available)
  static Map<String, dynamic>? _loadedCountries;
  static Map<String, String>? _loadedRegions;
  static Map<String, String>? _loadedSubregions;
  static Map<String, String>? _loadedContinents;
  static bool _isLoaded = false;

  /// Load translations from bundled JSON asset
  /// Call this during app initialization for best experience
  static Future<void> loadFromAsset() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      _loadedCountries = data['countries'] as Map<String, dynamic>?;
      _loadedRegions = _castToStringMap(data['regions']);
      _loadedSubregions = _castToStringMap(data['subregions']);
      _loadedContinents = _castToStringMap(data['continents']);

      _isLoaded = true;
      logger.info(
        'Loaded ${_loadedCountries?.length ?? 0} Arabic country translations from asset',
        tag: 'ArabicCountryNames',
      );
    } catch (e) {
      logger.warning(
        'Failed to load Arabic translations from asset, using fallback',
        tag: 'ArabicCountryNames',
        error: e,
      );
    }
  }

  /// Helper to safely cast dynamic map to String map
  static Map<String, String>? _castToStringMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return null;
  }

  /// Get Arabic name for a country by its code
  static String? getName(String code) {
    final upperCode = code.toUpperCase();

    // First check loaded JSON data
    if (_loadedCountries != null && _loadedCountries!.containsKey(upperCode)) {
      final countryData = _loadedCountries![upperCode] as Map<String, dynamic>?;
      if (countryData != null && countryData['name'] != null) {
        return countryData['name'] as String;
      }
    }

    // Fall back to static data
    return names[upperCode];
  }

  /// Get Arabic capital name for a country by its code
  static String? getCapital(String code) {
    final upperCode = code.toUpperCase();

    // First check loaded JSON data
    if (_loadedCountries != null && _loadedCountries!.containsKey(upperCode)) {
      final countryData = _loadedCountries![upperCode] as Map<String, dynamic>?;
      if (countryData != null && countryData['capital'] != null) {
        return countryData['capital'] as String;
      }
    }

    // Fall back to static data
    return capitals[upperCode];
  }

  /// Get Arabic region name
  static String getRegion(String region) {
    // First check loaded JSON data
    if (_loadedRegions != null && _loadedRegions!.containsKey(region)) {
      return _loadedRegions![region]!;
    }

    // Fall back to static data
    return regions[region] ?? region;
  }

  /// Get Arabic subregion name
  static String getSubregion(String subregion) {
    // First check loaded JSON data
    if (_loadedSubregions != null && _loadedSubregions!.containsKey(subregion)) {
      return _loadedSubregions![subregion]!;
    }

    // Fall back to static data
    return subregions[subregion] ?? subregion;
  }

  /// Get Arabic continent name
  static String getContinent(String continent) {
    // First check loaded JSON data
    if (_loadedContinents != null && _loadedContinents!.containsKey(continent)) {
      return _loadedContinents![continent]!;
    }

    // Fall back to continents map (use regions as fallback since they overlap)
    return regions[continent] ?? continent;
  }

  /// Check if translations have been loaded from asset
  static bool get isLoaded => _isLoaded;

  /// Static fallback data - always available
  static const Map<String, String> names = {
    // Africa
    'DZ': 'الجزائر',
    'AO': 'أنغولا',
    'BJ': 'بنين',
    'BW': 'بوتسوانا',
    'BF': 'بوركينا فاسو',
    'BI': 'بوروندي',
    'CV': 'الرأس الأخضر',
    'CM': 'الكاميرون',
    'CF': 'جمهورية أفريقيا الوسطى',
    'TD': 'تشاد',
    'KM': 'جزر القمر',
    'CG': 'الكونغو',
    'CD': 'جمهورية الكونغو الديمقراطية',
    'DJ': 'جيبوتي',
    'EG': 'مصر',
    'GQ': 'غينيا الاستوائية',
    'ER': 'إريتريا',
    'SZ': 'إسواتيني',
    'ET': 'إثيوبيا',
    'GA': 'الغابون',
    'GM': 'غامبيا',
    'GH': 'غانا',
    'GN': 'غينيا',
    'GW': 'غينيا بيساو',
    'CI': 'ساحل العاج',
    'KE': 'كينيا',
    'LS': 'ليسوتو',
    'LR': 'ليبيريا',
    'LY': 'ليبيا',
    'MG': 'مدغشقر',
    'MW': 'ملاوي',
    'ML': 'مالي',
    'MR': 'موريتانيا',
    'MU': 'موريشيوس',
    'MA': 'المغرب',
    'MZ': 'موزمبيق',
    'NA': 'ناميبيا',
    'NE': 'النيجر',
    'NG': 'نيجيريا',
    'RW': 'رواندا',
    'ST': 'ساو تومي وبرينسيب',
    'SN': 'السنغال',
    'SC': 'سيشل',
    'SL': 'سيراليون',
    'SO': 'الصومال',
    'ZA': 'جنوب أفريقيا',
    'SS': 'جنوب السودان',
    'SD': 'السودان',
    'TZ': 'تنزانيا',
    'TG': 'توغو',
    'TN': 'تونس',
    'UG': 'أوغندا',
    'ZM': 'زامبيا',
    'ZW': 'زيمبابوي',

    // Asia
    'AF': 'أفغانستان',
    'AM': 'أرمينيا',
    'AZ': 'أذربيجان',
    'BH': 'البحرين',
    'BD': 'بنغلاديش',
    'BT': 'بوتان',
    'BN': 'بروناي',
    'KH': 'كمبوديا',
    'CN': 'الصين',
    'CY': 'قبرص',
    'GE': 'جورجيا',
    'IN': 'الهند',
    'ID': 'إندونيسيا',
    'IR': 'إيران',
    'IQ': 'العراق',
    'IL': 'إسرائيل',
    'JP': 'اليابان',
    'JO': 'المملكة الأردنية الهاشمية',
    'KZ': 'كازاخستان',
    'KW': 'الكويت',
    'KG': 'قيرغيزستان',
    'LA': 'لاوس',
    'LB': 'لبنان',
    'MY': 'ماليزيا',
    'MV': 'المالديف',
    'MN': 'منغوليا',
    'MM': 'ميانمار',
    'NP': 'نيبال',
    'KP': 'كوريا الشمالية',
    'OM': 'عمان',
    'PK': 'باكستان',
    'PS': 'فلسطين',
    'PH': 'الفلبين',
    'QA': 'قطر',
    'SA': 'المملكة العربية السعودية',
    'SG': 'سنغافورة',
    'KR': 'كوريا الجنوبية',
    'LK': 'سريلانكا',
    'SY': 'سوريا',
    'TW': 'تايوان',
    'TJ': 'طاجيكستان',
    'TH': 'تايلاند',
    'TL': 'تيمور الشرقية',
    'TR': 'تركيا',
    'TM': 'تركمانستان',
    'AE': 'الإمارات العربية المتحدة',
    'UZ': 'أوزبكستان',
    'VN': 'فيتنام',
    'YE': 'اليمن',

    // Europe
    'AL': 'ألبانيا',
    'AD': 'أندورا',
    'AT': 'النمسا',
    'BY': 'بيلاروسيا',
    'BE': 'بلجيكا',
    'BA': 'البوسنة والهرسك',
    'BG': 'بلغاريا',
    'HR': 'كرواتيا',
    'CZ': 'التشيك',
    'DK': 'الدنمارك',
    'EE': 'إستونيا',
    'FI': 'فنلندا',
    'FR': 'فرنسا',
    'DE': 'ألمانيا',
    'GR': 'اليونان',
    'HU': 'المجر',
    'IS': 'آيسلندا',
    'IE': 'أيرلندا',
    'IT': 'إيطاليا',
    'XK': 'كوسوفو',
    'LV': 'لاتفيا',
    'LI': 'ليختنشتاين',
    'LT': 'ليتوانيا',
    'LU': 'لوكسمبورغ',
    'MT': 'مالطا',
    'MD': 'مولدوفا',
    'MC': 'موناكو',
    'ME': 'الجبل الأسود',
    'NL': 'هولندا',
    'MK': 'مقدونيا الشمالية',
    'NO': 'النرويج',
    'PL': 'بولندا',
    'PT': 'البرتغال',
    'RO': 'رومانيا',
    'RU': 'روسيا',
    'SM': 'سان مارينو',
    'RS': 'صربيا',
    'SK': 'سلوفاكيا',
    'SI': 'سلوفينيا',
    'ES': 'إسبانيا',
    'SE': 'السويد',
    'CH': 'سويسرا',
    'UA': 'أوكرانيا',
    'GB': 'المملكة المتحدة',
    'VA': 'الفاتيكان',

    // North America
    'AG': 'أنتيغوا وباربودا',
    'BS': 'الباهاما',
    'BB': 'باربادوس',
    'BZ': 'بليز',
    'CA': 'كندا',
    'CR': 'كوستاريكا',
    'CU': 'كوبا',
    'DM': 'دومينيكا',
    'DO': 'جمهورية الدومينيكان',
    'SV': 'السلفادور',
    'GD': 'غرينادا',
    'GT': 'غواتيمالا',
    'HT': 'هايتي',
    'HN': 'هندوراس',
    'JM': 'جامايكا',
    'MX': 'المكسيك',
    'NI': 'نيكاراغوا',
    'PA': 'بنما',
    'KN': 'سانت كيتس ونيفيس',
    'LC': 'سانت لوسيا',
    'VC': 'سانت فنسنت والغرينادين',
    'TT': 'ترينيداد وتوباغو',
    'US': 'الولايات المتحدة',

    // South America
    'AR': 'الأرجنتين',
    'BO': 'بوليفيا',
    'BR': 'البرازيل',
    'CL': 'تشيلي',
    'CO': 'كولومبيا',
    'EC': 'الإكوادور',
    'GY': 'غيانا',
    'PY': 'باراغواي',
    'PE': 'بيرو',
    'SR': 'سورينام',
    'UY': 'أوروغواي',
    'VE': 'فنزويلا',

    // Oceania
    'AU': 'أستراليا',
    'FJ': 'فيجي',
    'KI': 'كيريباتي',
    'MH': 'جزر مارشال',
    'FM': 'ميكرونيزيا',
    'NR': 'ناورو',
    'NZ': 'نيوزيلندا',
    'PW': 'بالاو',
    'PG': 'بابوا غينيا الجديدة',
    'WS': 'ساموا',
    'SB': 'جزر سليمان',
    'TO': 'تونغا',
    'TV': 'توفالو',
    'VU': 'فانواتو',
    'NC': 'كاليدونيا الجديدة',
    'CK': 'جزر كوك',
    'GU': 'غوام',
    'AS': 'ساموا الأمريكية',
    'MP': 'جزر ماريانا الشمالية',
    'NU': 'نييوي',
    'TK': 'توكيلاو',
    'WF': 'واليس وفوتونا',
    'PF': 'بولينيزيا الفرنسية',
    'PN': 'جزر بيتكيرن',
    'NF': 'جزيرة نورفولك',

    // Antarctic & Territories
    'AQ': 'القارة القطبية الجنوبية',
    'GS': 'جورجيا الجنوبية وجزر ساندويتش الجنوبية',
    'BV': 'جزيرة بوفيه',
    'HM': 'جزيرة هيرد وجزر ماكدونالد',
    'TF': 'الأراضي الفرنسية الجنوبية',

    // Caribbean & Atlantic Territories
    'AI': 'أنغويلا',
    'AW': 'أروبا',
    'BM': 'برمودا',
    'BQ': 'الجزر الكاريبية الهولندية',
    'VG': 'جزر العذراء البريطانية',
    'VI': 'جزر العذراء الأمريكية',
    'KY': 'جزر كايمان',
    'CW': 'كوراساو',
    'FK': 'جزر فوكلاند',
    'GF': 'غويانا الفرنسية',
    'GL': 'غرينلاند',
    'GP': 'غوادلوب',
    'MQ': 'مارتينيك',
    'MS': 'مونتسرات',
    'PR': 'بورتوريكو',
    'BL': 'سان بارتيليمي',
    'MF': 'سانت مارتن',
    'PM': 'سان بيير وميكلون',
    'SX': 'سينت مارتن',
    'TC': 'جزر تركس وكايكوس',

    // Indian Ocean Territories
    'CC': 'جزر كوكوس',
    'CX': 'جزيرة الكريسماس',
    'IO': 'إقليم المحيط الهندي البريطاني',
    'YT': 'مايوت',
    'RE': 'ريونيون',

    // European Territories
    'AX': 'جزر آلاند',
    'FO': 'جزر فارو',
    'GI': 'جبل طارق',
    'GG': 'غيرنزي',
    'IM': 'جزيرة مان',
    'JE': 'جيرزي',
    'SJ': 'سفالبارد ويان ماين',

    // Asian Territories
    'HK': 'هونغ كونغ',
    'MO': 'ماكاو',

    // Special entries
    'EH': 'الصحراء الغربية',
    'UM': 'جزر الولايات المتحدة الصغيرة النائية',
  };

  /// Arabic translations for capital cities
  static const Map<String, String> capitals = {
    // Africa
    'DZ': 'الجزائر',
    'AO': 'لواندا',
    'BJ': 'بورتو نوفو',
    'BW': 'غابورون',
    'BF': 'واغادوغو',
    'BI': 'بوجومبورا',
    'CV': 'برايا',
    'CM': 'ياوندي',
    'CF': 'بانغي',
    'TD': 'نجامينا',
    'KM': 'موروني',
    'CG': 'برازافيل',
    'CD': 'كينشاسا',
    'DJ': 'جيبوتي',
    'EG': 'القاهرة',
    'GQ': 'مالابو',
    'ER': 'أسمرة',
    'SZ': 'مبابان',
    'ET': 'أديس أبابا',
    'GA': 'ليبرفيل',
    'GM': 'بانجول',
    'GH': 'أكرا',
    'GN': 'كوناكري',
    'GW': 'بيساو',
    'CI': 'ياموسوكرو',
    'KE': 'نيروبي',
    'LS': 'ماسيرو',
    'LR': 'مونروفيا',
    'LY': 'طرابلس',
    'MG': 'أنتاناناريفو',
    'MW': 'ليلونغوي',
    'ML': 'باماكو',
    'MR': 'نواكشوط',
    'MU': 'بورت لويس',
    'MA': 'الرباط',
    'MZ': 'مابوتو',
    'NA': 'ويندهوك',
    'NE': 'نيامي',
    'NG': 'أبوجا',
    'RW': 'كيغالي',
    'ST': 'ساو تومي',
    'SN': 'داكار',
    'SC': 'فيكتوريا',
    'SL': 'فريتاون',
    'SO': 'مقديشو',
    'ZA': 'بريتوريا',
    'SS': 'جوبا',
    'SD': 'الخرطوم',
    'TZ': 'دودوما',
    'TG': 'لومي',
    'TN': 'تونس',
    'UG': 'كمبالا',
    'ZM': 'لوساكا',
    'ZW': 'هراري',

    // Asia
    'AF': 'كابل',
    'AM': 'يريفان',
    'AZ': 'باكو',
    'BH': 'المنامة',
    'BD': 'دكا',
    'BT': 'تيمفو',
    'BN': 'بندر سري بكاوان',
    'KH': 'بنوم بنه',
    'CN': 'بكين',
    'CY': 'نيقوسيا',
    'GE': 'تبليسي',
    'IN': 'نيودلهي',
    'ID': 'جاكرتا',
    'IR': 'طهران',
    'IQ': 'بغداد',
    'IL': 'القدس',
    'JP': 'طوكيو',
    'JO': 'عمّان',
    'KZ': 'نور سلطان',
    'KW': 'الكويت',
    'KG': 'بيشكك',
    'LA': 'فيينتيان',
    'LB': 'بيروت',
    'MY': 'كوالالمبور',
    'MV': 'ماليه',
    'MN': 'أولان باتور',
    'MM': 'نايبيداو',
    'NP': 'كاتماندو',
    'KP': 'بيونغ يانغ',
    'OM': 'مسقط',
    'PK': 'إسلام أباد',
    'PS': 'رام الله',
    'PH': 'مانيلا',
    'QA': 'الدوحة',
    'SA': 'الرياض',
    'SG': 'سنغافورة',
    'KR': 'سيول',
    'LK': 'سري جاياواردنابورا كوتي',
    'SY': 'دمشق',
    'TW': 'تايبيه',
    'TJ': 'دوشانبي',
    'TH': 'بانكوك',
    'TL': 'ديلي',
    'TR': 'أنقرة',
    'TM': 'عشق أباد',
    'AE': 'أبو ظبي',
    'UZ': 'طشقند',
    'VN': 'هانوي',
    'YE': 'صنعاء',

    // Europe
    'AL': 'تيرانا',
    'AD': 'أندورا لا فيلا',
    'AT': 'فيينا',
    'BY': 'مينسك',
    'BE': 'بروكسل',
    'BA': 'سراييفو',
    'BG': 'صوفيا',
    'HR': 'زغرب',
    'CZ': 'براغ',
    'DK': 'كوبنهاغن',
    'EE': 'تالين',
    'FI': 'هلسنكي',
    'FR': 'باريس',
    'DE': 'برلين',
    'GR': 'أثينا',
    'HU': 'بودابست',
    'IS': 'ريكيافيك',
    'IE': 'دبلن',
    'IT': 'روما',
    'XK': 'بريشتينا',
    'LV': 'ريغا',
    'LI': 'فادوز',
    'LT': 'فيلنيوس',
    'LU': 'لوكسمبورغ',
    'MT': 'فاليتا',
    'MD': 'كيشيناو',
    'MC': 'موناكو',
    'ME': 'بودغوريتسا',
    'NL': 'أمستردام',
    'MK': 'سكوبيه',
    'NO': 'أوسلو',
    'PL': 'وارسو',
    'PT': 'لشبونة',
    'RO': 'بوخارست',
    'RU': 'موسكو',
    'SM': 'سان مارينو',
    'RS': 'بلغراد',
    'SK': 'براتيسلافا',
    'SI': 'ليوبليانا',
    'ES': 'مدريد',
    'SE': 'ستوكهولم',
    'CH': 'برن',
    'UA': 'كييف',
    'GB': 'لندن',
    'VA': 'الفاتيكان',

    // North America
    'AG': 'سانت جونز',
    'BS': 'ناساو',
    'BB': 'بريدجتاون',
    'BZ': 'بلموبان',
    'CA': 'أوتاوا',
    'CR': 'سان خوسيه',
    'CU': 'هافانا',
    'DM': 'روسو',
    'DO': 'سانتو دومينغو',
    'SV': 'سان سلفادور',
    'GD': 'سانت جورج',
    'GT': 'غواتيمالا',
    'HT': 'بورت أو برنس',
    'HN': 'تيغوسيغالبا',
    'JM': 'كينغستون',
    'MX': 'مكسيكو سيتي',
    'NI': 'ماناغوا',
    'PA': 'بنما',
    'KN': 'باستير',
    'LC': 'كاستريس',
    'VC': 'كينغستاون',
    'TT': 'بورت أوف سبين',
    'US': 'واشنطن',

    // South America
    'AR': 'بوينس آيرس',
    'BO': 'سوكري',
    'BR': 'برازيليا',
    'CL': 'سانتياغو',
    'CO': 'بوغوتا',
    'EC': 'كيتو',
    'GY': 'جورج تاون',
    'PY': 'أسونسيون',
    'PE': 'ليما',
    'SR': 'باراماريبو',
    'UY': 'مونتيفيديو',
    'VE': 'كاراكاس',

    // Oceania
    'AU': 'كانبرا',
    'FJ': 'سوفا',
    'KI': 'تاراوا',
    'MH': 'ماجورو',
    'FM': 'باليكير',
    'NR': 'يارين',
    'NZ': 'ويلينغتون',
    'PW': 'نغيرولمود',
    'PG': 'بورت مورسبي',
    'WS': 'أبيا',
    'SB': 'هونيارا',
    'TO': 'نوكو ألوفا',
    'TV': 'فونافوتي',
    'VU': 'بورت فيلا',
  };

  /// Arabic translations for regions
  static const Map<String, String> regions = {
    'Africa': 'أفريقيا',
    'Americas': 'الأمريكتين',
    'Antarctic': 'القارة القطبية الجنوبية',
    'Asia': 'آسيا',
    'Europe': 'أوروبا',
    'Oceania': 'أوقيانوسيا',
  };

  /// Arabic translations for subregions
  static const Map<String, String> subregions = {
    // Africa
    'Northern Africa': 'شمال أفريقيا',
    'Eastern Africa': 'شرق أفريقيا',
    'Middle Africa': 'وسط أفريقيا',
    'Southern Africa': 'جنوب أفريقيا',
    'Western Africa': 'غرب أفريقيا',

    // Americas
    'Caribbean': 'الكاريبي',
    'Central America': 'أمريكا الوسطى',
    'North America': 'أمريكا الشمالية',
    'South America': 'أمريكا الجنوبية',

    // Asia
    'Central Asia': 'آسيا الوسطى',
    'Eastern Asia': 'شرق آسيا',
    'South-Eastern Asia': 'جنوب شرق آسيا',
    'Southern Asia': 'جنوب آسيا',
    'Western Asia': 'غرب آسيا',

    // Europe
    'Eastern Europe': 'أوروبا الشرقية',
    'Northern Europe': 'أوروبا الشمالية',
    'Southern Europe': 'أوروبا الجنوبية',
    'Western Europe': 'أوروبا الغربية',

    // Oceania
    'Australia and New Zealand': 'أستراليا ونيوزيلندا',
    'Melanesia': 'ميلانيزيا',
    'Micronesia': 'ميكرونيزيا',
    'Polynesia': 'بولينيزيا',
  };
}
