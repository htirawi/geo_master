import 'package:flutter/material.dart';

/// Represents the meaning and symbolism of a flag's colors
class FlagMeaning {
  const FlagMeaning({
    required this.countryCode,
    required this.colors,
    this.additionalInfo,
    this.additionalInfoAr,
  });

  final String countryCode;
  final List<FlagColor> colors;
  final String? additionalInfo;
  final String? additionalInfoAr;
}

/// Represents a single color in a flag with its meaning
class FlagColor {
  const FlagColor({
    required this.color,
    required this.hexCode,
    required this.meaningEn,
    required this.meaningAr,
    this.name,
    this.nameAr,
  });

  final Color color;
  final String hexCode;
  final String meaningEn;
  final String meaningAr;
  final String? name;
  final String? nameAr;

  String getMeaning({required bool isArabic}) => isArabic ? meaningAr : meaningEn;
  String getName({required bool isArabic}) {
    if (isArabic && nameAr != null) return nameAr!;
    if (name != null) return name!;
    return hexCode;
  }
}

/// Comprehensive repository of flag color meanings for ALL countries
/// Data sourced from official vexillological references
class FlagMeaningsRepository {
  static final Map<String, FlagMeaning> _meanings = {
    // ═══════════════════════════════════════════════════════════════════════
    // MIDDLE EAST & ARAB COUNTRIES
    // ═══════════════════════════════════════════════════════════════════════

    // Jordan
    'JO': const FlagMeaning(
      countryCode: 'JO',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The Abbasid Caliphate',
          meaningAr: 'الخلافة العباسية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Umayyad Caliphate',
          meaningAr: 'الخلافة الأموية',
        ),
        FlagColor(
          color: Color(0xFF007A3D),
          hexCode: '#007A3D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Fatimid Caliphate',
          meaningAr: 'الخلافة الفاطمية',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Hashemite dynasty and the Great Arab Revolt',
          meaningAr: 'السلالة الهاشمية والثورة العربية الكبرى',
        ),
      ],
      additionalInfo: 'The seven-pointed star represents the seven verses of Al-Fatiha, the seven hills of Amman, and faith in One God.',
      additionalInfoAr: 'تمثل النجمة السباعية آيات سورة الفاتحة السبع وتلال عمّان السبع والإيمان بالله الواحد.',
    ),

    // Saudi Arabia
    'SA': const FlagMeaning(
      countryCode: 'SA',
      colors: [
        FlagColor(
          color: Color(0xFF006C35),
          hexCode: '#006C35',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam - the traditional color associated with the Prophet Muhammad',
          meaningAr: 'الإسلام - اللون التقليدي المرتبط بالنبي محمد ﷺ',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Shahada (Islamic declaration of faith) and the sword',
          meaningAr: 'الشهادة والسيف',
        ),
      ],
      additionalInfo: 'The sword symbolizes the military strength and the strictness in applying justice. The flag is never flown at half-mast as it contains the Shahada.',
      additionalInfoAr: 'يرمز السيف إلى القوة العسكرية والصرامة في تطبيق العدالة. لا يُنكّس العلم أبداً لاحتوائه على الشهادة.',
    ),

    // United Arab Emirates
    'AE': const FlagMeaning(
      countryCode: 'AE',
      colors: [
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Unity and the sacrifices of martyrs who defended the nation',
          meaningAr: 'الوحدة وتضحيات الشهداء الذين دافعوا عن الوطن',
        ),
        FlagColor(
          color: Color(0xFF00732F),
          hexCode: '#00732F',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Prosperity, fertility, and the green lands',
          meaningAr: 'الازدهار والخصوبة والأراضي الخضراء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, honesty, and neutrality',
          meaningAr: 'السلام والصدق والحياد',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'Strength of mind and defeat of enemies',
          meaningAr: 'قوة العقل وهزيمة الأعداء',
        ),
      ],
      additionalInfo: 'The Pan-Arab colors were adopted upon independence in 1971, representing Arab unity.',
      additionalInfoAr: 'اعتُمدت الألوان العربية عند الاستقلال عام 1971 للتعبير عن الوحدة العربية.',
    ),

    // Egypt
    'EG': const FlagMeaning(
      countryCode: 'EG',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The struggle against British occupation and the sacrifices of martyrs',
          meaningAr: 'النضال ضد الاحتلال البريطاني وتضحيات الشهداء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The 1952 Revolution that ended the monarchy without bloodshed',
          meaningAr: 'ثورة 1952 التي أنهت الملكية دون إراقة دماء',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The end of oppression by the monarchy and British colonialism',
          meaningAr: 'نهاية الاضطهاد من الملكية والاستعمار البريطاني',
        ),
        FlagColor(
          color: Color(0xFFC09300),
          hexCode: '#C09300',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The Eagle of Saladin - symbol of Arab nationalism and power',
          meaningAr: 'نسر صلاح الدين - رمز القومية العربية والقوة',
        ),
      ],
      additionalInfo: 'The Eagle of Saladin holds a scroll with "Arab Republic of Egypt" in Arabic.',
      additionalInfoAr: 'يحمل نسر صلاح الدين لافتة مكتوب عليها "جمهورية مصر العربية".',
    ),

    // Palestine
    'PS': const FlagMeaning(
      countryCode: 'PS',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The Abbasid Caliphate - representing the dark past of oppression',
          meaningAr: 'الخلافة العباسية - تمثل الماضي المظلم من الاضطهاد',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Umayyad Caliphate - representing peace and purity',
          meaningAr: 'الخلافة الأموية - تمثل السلام والنقاء',
        ),
        FlagColor(
          color: Color(0xFF007A3D),
          hexCode: '#007A3D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Fatimid Caliphate - representing the land and prosperity',
          meaningAr: 'الخلافة الفاطمية - تمثل الأرض والازدهار',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Hashemites and the blood of martyrs in the struggle for freedom',
          meaningAr: 'الهاشميون ودماء الشهداء في النضال من أجل الحرية',
        ),
      ],
      additionalInfo: 'First used in 1917 as a Pan-Arab flag, officially adopted in 1964 by the PLO.',
      additionalInfoAr: 'استُخدم لأول مرة عام 1917 كعلم عربي، واعتمدته منظمة التحرير رسمياً عام 1964.',
    ),

    // Iraq
    'IQ': const FlagMeaning(
      countryCode: 'IQ',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage and the struggle for independence',
          meaningAr: 'الشجاعة والنضال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Generosity and peace',
          meaningAr: 'الكرم والسلام',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'Triumph and determination',
          meaningAr: 'الانتصار والتصميم',
        ),
        FlagColor(
          color: Color(0xFF007A3D),
          hexCode: '#007A3D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam and the Arab heritage (in the Takbir)',
          meaningAr: 'الإسلام والتراث العربي (في التكبيرة)',
        ),
      ],
      additionalInfo: 'The Takbir "Allahu Akbar" (God is Greatest) is written in green Kufic script.',
      additionalInfoAr: 'كُتبت التكبيرة "الله أكبر" بالخط الكوفي الأخضر.',
    ),

    // Syria
    'SY': const FlagMeaning(
      countryCode: 'SY',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Hashemite dynasty and the blood of martyrs',
          meaningAr: 'السلالة الهاشمية ودماء الشهداء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Umayyad Caliphate and a bright peaceful future',
          meaningAr: 'الخلافة الأموية والمستقبل السلمي المشرق',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The Abbasid Caliphate and the dark colonial past',
          meaningAr: 'الخلافة العباسية والماضي الاستعماري المظلم',
        ),
        FlagColor(
          color: Color(0xFF007A3D),
          hexCode: '#007A3D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Fatimid Caliphate and the Rashidun Caliphate',
          meaningAr: 'الخلافة الفاطمية والخلافة الراشدة',
        ),
      ],
      additionalInfo: 'The two green stars originally represented Syria and Egypt during the United Arab Republic (1958-1961).',
      additionalInfoAr: 'مثّلت النجمتان الخضراوان سوريا ومصر خلال الجمهورية العربية المتحدة (1958-1961).',
    ),

    // Lebanon
    'LB': const FlagMeaning(
      countryCode: 'LB',
      colors: [
        FlagColor(
          color: Color(0xFFED1C24),
          hexCode: '#ED1C24',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed by Lebanese for liberation and independence',
          meaningAr: 'الدماء التي أراقها اللبنانيون من أجل التحرير والاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, purity, and the snow-capped mountains',
          meaningAr: 'السلام والنقاء والجبال المكسوة بالثلوج',
        ),
        FlagColor(
          color: Color(0xFF00A651),
          hexCode: '#00A651',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Cedar of Lebanon - immortality, steadiness, and resilience',
          meaningAr: 'أرز لبنان - الخلود والثبات والصمود',
        ),
      ],
      additionalInfo: 'The Cedar of Lebanon is mentioned 75 times in the Bible as a symbol of holiness and eternity.',
      additionalInfoAr: 'ذُكر أرز لبنان 75 مرة في الكتاب المقدس كرمز للقداسة والأبدية.',
    ),

    // Kuwait
    'KW': const FlagMeaning(
      countryCode: 'KW',
      colors: [
        FlagColor(
          color: Color(0xFF007A3D),
          hexCode: '#007A3D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The fertile land and meadows of Kuwait',
          meaningAr: 'الأرض الخصبة ومروج الكويت',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and noble deeds',
          meaningAr: 'النقاء والأعمال النبيلة',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of enemies and warriors',
          meaningAr: 'دماء الأعداء والمحاربين',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The defeat of enemies in battle',
          meaningAr: 'هزيمة الأعداء في المعركة',
        ),
      ],
      additionalInfo: 'The colors are inspired by a verse from the 13th-century Arab poet Safie Al-Deen Al-Hilly.',
      additionalInfoAr: 'الألوان مستوحاة من بيت شعر للشاعر صفي الدين الحلي من القرن الثالث عشر.',
    ),

    // Qatar
    'QA': const FlagMeaning(
      countryCode: 'QA',
      colors: [
        FlagColor(
          color: Color(0xFF8D1B3D),
          hexCode: '#8D1B3D',
          name: 'Maroon',
          nameAr: 'عنابي',
          meaningEn: 'The bloodshed during Qatari wars in the 19th century',
          meaningAr: 'الدماء المراقة خلال حروب قطر في القرن التاسع عشر',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and international recognized symbol of truce',
          meaningAr: 'السلام والرمز الدولي المعترف به للهدنة',
        ),
      ],
      additionalInfo: 'The nine-point serrated edge represents Qatar as the 9th member of the "reconciled Emirates" after the Qatari-British treaty of 1916.',
      additionalInfoAr: 'تمثل الحافة المسننة ذات التسع نقاط قطر كالعضو التاسع في "الإمارات المتصالحة" بعد معاهدة قطر البريطانية عام 1916.',
    ),

    // Bahrain
    'BH': const FlagMeaning(
      countryCode: 'BH',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Kharijite sect (historically prevalent in the region)',
          meaningAr: 'الخوارج (المنتشرين تاريخياً في المنطقة)',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the truce with neighboring countries',
          meaningAr: 'السلام والهدنة مع الدول المجاورة',
        ),
      ],
      additionalInfo: 'The five white triangles represent the five pillars of Islam. The flag was modified in 2002 when Bahrain became a kingdom.',
      additionalInfoAr: 'تمثل المثلثات البيضاء الخمسة أركان الإسلام الخمسة. عُدّل العلم عام 2002 عندما أصبحت البحرين مملكة.',
    ),

    // Oman
    'OM': const FlagMeaning(
      countryCode: 'OM',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The battles against foreign invaders throughout history',
          meaningAr: 'المعارك ضد الغزاة الأجانب عبر التاريخ',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, prosperity, and the Imam (religious leader)',
          meaningAr: 'السلام والازدهار والإمام (القائد الديني)',
        ),
        FlagColor(
          color: Color(0xFF008000),
          hexCode: '#008000',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Fertility, the Green Mountains (Jebel Akhdar), and Islam',
          meaningAr: 'الخصوبة والجبل الأخضر والإسلام',
        ),
      ],
      additionalInfo: 'The national emblem features two crossed swords, a khanjar (traditional dagger), and a horse harness belt.',
      additionalInfoAr: 'يتضمن الشعار الوطني سيفين متقاطعين وخنجراً وحزام سرج الفرس.',
    ),

    // Yemen
    'YE': const FlagMeaning(
      countryCode: 'YE',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of martyrs and the revolution',
          meaningAr: 'دماء الشهداء والثورة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Hope for a bright future',
          meaningAr: 'الأمل في مستقبل مشرق',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The dark past of colonialism and division',
          meaningAr: 'الماضي المظلم من الاستعمار والانقسام',
        ),
      ],
      additionalInfo: 'Adopted on May 22, 1990, upon the unification of North Yemen and South Yemen.',
      additionalInfoAr: 'اعتُمد في 22 مايو 1990 عند توحيد اليمن الشمالي واليمن الجنوبي.',
    ),

    // Turkey
    'TR': const FlagMeaning(
      countryCode: 'TR',
      colors: [
        FlagColor(
          color: Color(0xFFE30A17),
          hexCode: '#E30A17',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of Turkish soldiers who died defending the nation',
          meaningAr: 'دماء الجنود الأتراك الذين استشهدوا دفاعاً عن الوطن',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the crescent moon and star',
          meaningAr: 'السلام والهلال والنجمة',
        ),
      ],
      additionalInfo: 'According to legend, the flag design came from a vision of a crescent moon and star reflected in a pool of blood after the Battle of Kosovo in 1389.',
      additionalInfoAr: 'وفقاً للأسطورة، جاء تصميم العلم من رؤية هلال ونجمة منعكسين في بركة دم بعد معركة كوسوفو عام 1389.',
    ),

    // Iran
    'IR': const FlagMeaning(
      countryCode: 'IR',
      colors: [
        FlagColor(
          color: Color(0xFF239F40),
          hexCode: '#239F40',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, growth, happiness, and vitality',
          meaningAr: 'الإسلام والنمو والسعادة والحيوية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty',
          meaningAr: 'السلام والصدق',
        ),
        FlagColor(
          color: Color(0xFFDA0000),
          hexCode: '#DA0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Martyrdom, bravery, and courage',
          meaningAr: 'الشهادة والشجاعة والإقدام',
        ),
      ],
      additionalInfo: 'The emblem is a stylized "Allah" in the shape of a tulip. "Allahu Akbar" is written 22 times on the flag (11 on each stripe), commemorating the date of the 1979 revolution (22 Bahman).',
      additionalInfoAr: 'الشعار كلمة "الله" منمقة على شكل زهرة التوليب. كُتبت "الله أكبر" 22 مرة على العلم تخليداً لتاريخ ثورة 1979 (22 بهمن).',
    ),

    // Israel
    'IL': const FlagMeaning(
      countryCode: 'IL',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and innocence',
          meaningAr: 'النقاء والبراءة',
        ),
        FlagColor(
          color: Color(0xFF0038B8),
          hexCode: '#0038B8',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The sky and the traditional color of the Jewish tallit (prayer shawl)',
          meaningAr: 'السماء واللون التقليدي لشال الصلاة اليهودي (التاليت)',
        ),
      ],
      additionalInfo: 'The Star of David (Magen David) is an ancient Jewish symbol. The design is based on the traditional tallit (prayer shawl).',
      additionalInfoAr: 'نجمة داود (ماجن دافيد) رمز يهودي قديم. التصميم مستوحى من شال الصلاة التقليدي.',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NORTH AFRICA
    // ═══════════════════════════════════════════════════════════════════════

    // Morocco
    'MA': const FlagMeaning(
      countryCode: 'MA',
      colors: [
        FlagColor(
          color: Color(0xFFC1272D),
          hexCode: '#C1272D',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Hardiness, bravery, and the Alaouite dynasty',
          meaningAr: 'الصلابة والشجاعة والسلالة العلوية',
        ),
        FlagColor(
          color: Color(0xFF006233),
          hexCode: '#006233',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, hope, and the wisdom of the Prophet\'s descendants',
          meaningAr: 'الإسلام والأمل وحكمة نسل النبي',
        ),
      ],
      additionalInfo: 'The five-pointed star (Seal of Solomon) represents the five pillars of Islam and the connection between God and the nation.',
      additionalInfoAr: 'تمثل النجمة الخماسية (خاتم سليمان) أركان الإسلام الخمسة والصلة بين الله والأمة.',
    ),

    // Algeria
    'DZ': const FlagMeaning(
      countryCode: 'DZ',
      colors: [
        FlagColor(
          color: Color(0xFF006233),
          hexCode: '#006233',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam and the beauty of nature',
          meaningAr: 'الإسلام وجمال الطبيعة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and peace',
          meaningAr: 'النقاء والسلام',
        ),
        FlagColor(
          color: Color(0xFFD21034),
          hexCode: '#D21034',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of those who died fighting for independence',
          meaningAr: 'دماء الذين استشهدوا في النضال من أجل الاستقلال',
        ),
      ],
      additionalInfo: 'The crescent and star are traditional symbols of Islam. The current design was adopted after independence from France in 1962.',
      additionalInfoAr: 'الهلال والنجمة رمزان تقليديان للإسلام. اعتُمد التصميم الحالي بعد الاستقلال عن فرنسا عام 1962.',
    ),

    // Tunisia
    'TN': const FlagMeaning(
      countryCode: 'TN',
      colors: [
        FlagColor(
          color: Color(0xFFE70013),
          hexCode: '#E70013',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of martyrs and resistance against oppression',
          meaningAr: 'دماء الشهداء ومقاومة الظلم',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and purity',
          meaningAr: 'السلام والنقاء',
        ),
      ],
      additionalInfo: 'The crescent and star are symbols of Islam and the Ottoman heritage. The flag design dates back to 1831.',
      additionalInfoAr: 'الهلال والنجمة رمزان للإسلام والتراث العثماني. يعود تصميم العلم إلى عام 1831.',
    ),

    // Libya
    'LY': const FlagMeaning(
      countryCode: 'LY',
      colors: [
        FlagColor(
          color: Color(0xFFE70013),
          hexCode: '#E70013',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of those who fought for freedom',
          meaningAr: 'دماء الذين ناضلوا من أجل الحرية',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The dark days under Italian occupation',
          meaningAr: 'الأيام المظلمة تحت الاحتلال الإيطالي',
        ),
        FlagColor(
          color: Color(0xFF239E46),
          hexCode: '#239E46',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, prosperity, and agriculture',
          meaningAr: 'الإسلام والازدهار والزراعة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the crescent of Islam',
          meaningAr: 'السلام وهلال الإسلام',
        ),
      ],
      additionalInfo: 'The flag of the Kingdom of Libya (1951-1969) was restored after the 2011 revolution that overthrew Gaddafi.',
      additionalInfoAr: 'أُعيد علم المملكة الليبية (1951-1969) بعد ثورة 2011 التي أطاحت بالقذافي.',
    ),

    // Sudan
    'SD': const FlagMeaning(
      countryCode: 'SD',
      colors: [
        FlagColor(
          color: Color(0xFFD21034),
          hexCode: '#D21034',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The struggle for independence and the martyrs',
          meaningAr: 'النضال من أجل الاستقلال والشهداء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, optimism, and light',
          meaningAr: 'السلام والتفاؤل والنور',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'Sudan (the name means "land of the blacks")',
          meaningAr: 'السودان (الاسم يعني "أرض السود")',
        ),
        FlagColor(
          color: Color(0xFF007229),
          hexCode: '#007229',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, agriculture, and prosperity',
          meaningAr: 'الإسلام والزراعة والازدهار',
        ),
      ],
      additionalInfo: 'The Pan-Arab colors were adopted in 1970 following the revolution.',
      additionalInfoAr: 'اعتُمدت الألوان العربية عام 1970 بعد الثورة.',
    ),

    // Mauritania
    'MR': const FlagMeaning(
      countryCode: 'MR',
      colors: [
        FlagColor(
          color: Color(0xFF006233),
          hexCode: '#006233',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam and hope for a bright future',
          meaningAr: 'الإسلام والأمل في مستقبل مشرق',
        ),
        FlagColor(
          color: Color(0xFFFFC400),
          hexCode: '#FFC400',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The sands of the Sahara Desert',
          meaningAr: 'رمال الصحراء الكبرى',
        ),
        FlagColor(
          color: Color(0xFFD01C1F),
          hexCode: '#D01C1F',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of defenders of the nation (added in 2017)',
          meaningAr: 'دماء المدافعين عن الوطن (أُضيف عام 2017)',
        ),
      ],
      additionalInfo: 'The crescent and star are symbols of Islam. Red stripes were added in 2017 to honor those who defended the nation.',
      additionalInfoAr: 'الهلال والنجمة رمزان للإسلام. أُضيفت الخطوط الحمراء عام 2017 تكريماً للمدافعين عن الوطن.',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SUB-SAHARAN AFRICA
    // ═══════════════════════════════════════════════════════════════════════

    // South Africa
    'ZA': const FlagMeaning(
      countryCode: 'ZA',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The Black majority population of South Africa',
          meaningAr: 'غالبية السكان السود في جنوب أفريقيا',
        ),
        FlagColor(
          color: Color(0xFF007A4D),
          hexCode: '#007A4D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The fertility of the land and the natural environment',
          meaningAr: 'خصوبة الأرض والبيئة الطبيعية',
        ),
        FlagColor(
          color: Color(0xFFFFB612),
          hexCode: '#FFB612',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The mineral wealth and natural resources',
          meaningAr: 'الثروة المعدنية والموارد الطبيعية',
        ),
        FlagColor(
          color: Color(0xFFDE3831),
          hexCode: '#DE3831',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The bloodshed during the struggle for freedom',
          meaningAr: 'الدماء المراقة خلال النضال من أجل الحرية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The White minority and peace',
          meaningAr: 'الأقلية البيضاء والسلام',
        ),
        FlagColor(
          color: Color(0xFF002395),
          hexCode: '#002395',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The sky and the surrounding oceans',
          meaningAr: 'السماء والمحيطات المحيطة',
        ),
      ],
      additionalInfo: 'The "Y" shape represents the convergence of diverse elements within South African society, moving forward in unity.',
      additionalInfoAr: 'يمثل شكل حرف "Y" تقارب العناصر المتنوعة في المجتمع الجنوب أفريقي والمضي قدماً في وحدة.',
    ),

    // Nigeria
    'NG': const FlagMeaning(
      countryCode: 'NG',
      colors: [
        FlagColor(
          color: Color(0xFF008751),
          hexCode: '#008751',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The forests and abundant natural wealth of Nigeria',
          meaningAr: 'الغابات والثروة الطبيعية الوفيرة في نيجيريا',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and unity among diverse ethnic groups',
          meaningAr: 'السلام والوحدة بين المجموعات العرقية المتنوعة',
        ),
      ],
      additionalInfo: 'The flag was designed by Michael Taiwo Akinkunmi, a student who won a competition in 1959.',
      additionalInfoAr: 'صمم العلم مايكل تايو أكينكونمي، وهو طالب فاز بمسابقة عام 1959.',
    ),

    // Kenya
    'KE': const FlagMeaning(
      countryCode: 'KE',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The people of Kenya',
          meaningAr: 'شعب كينيا',
        ),
        FlagColor(
          color: Color(0xFFBB0000),
          hexCode: '#BB0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed during the struggle for independence',
          meaningAr: 'الدماء المراقة خلال النضال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFF006600),
          hexCode: '#006600',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The natural landscape and agricultural wealth',
          meaningAr: 'المناظر الطبيعية والثروة الزراعية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty',
          meaningAr: 'السلام والصدق',
        ),
      ],
      additionalInfo: 'The Maasai shield and spears represent the defense of freedom.',
      additionalInfoAr: 'يمثل درع ورماح الماساي الدفاع عن الحرية.',
    ),

    // Ethiopia
    'ET': const FlagMeaning(
      countryCode: 'ET',
      colors: [
        FlagColor(
          color: Color(0xFF009739),
          hexCode: '#009739',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The land, fertility, and hope',
          meaningAr: 'الأرض والخصوبة والأمل',
        ),
        FlagColor(
          color: Color(0xFFFCDD09),
          hexCode: '#FCDD09',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'Peace, natural wealth, and love',
          meaningAr: 'السلام والثروة الطبيعية والحب',
        ),
        FlagColor(
          color: Color(0xFFDA121A),
          hexCode: '#DA121A',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Strength, sacrifice, and heroism',
          meaningAr: 'القوة والتضحية والبطولة',
        ),
        FlagColor(
          color: Color(0xFF0F47AF),
          hexCode: '#0F47AF',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Peace and democracy (in the emblem)',
          meaningAr: 'السلام والديمقراطية (في الشعار)',
        ),
      ],
      additionalInfo: 'Ethiopia\'s flag inspired the Pan-African colors used by many African nations. The star represents unity and diversity.',
      additionalInfoAr: 'ألهم علم إثيوبيا الألوان الأفريقية التي تستخدمها العديد من الدول الأفريقية. تمثل النجمة الوحدة والتنوع.',
    ),

    // Ghana
    'GH': const FlagMeaning(
      countryCode: 'GH',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of those who died in the independence struggle',
          meaningAr: 'دماء الذين استشهدوا في النضال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The mineral wealth of Ghana (former Gold Coast)',
          meaningAr: 'الثروة المعدنية لغانا (ساحل الذهب سابقاً)',
        ),
        FlagColor(
          color: Color(0xFF006B3F),
          hexCode: '#006B3F',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The forests and natural wealth',
          meaningAr: 'الغابات والثروة الطبيعية',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The African people (the Black Star)',
          meaningAr: 'الشعب الأفريقي (النجمة السوداء)',
        ),
      ],
      additionalInfo: 'Ghana was the first sub-Saharan African country to gain independence from colonial rule in 1957.',
      additionalInfoAr: 'كانت غانا أول دولة أفريقية جنوب الصحراء تنال استقلالها من الحكم الاستعماري عام 1957.',
    ),

    // Senegal
    'SN': const FlagMeaning(
      countryCode: 'SN',
      colors: [
        FlagColor(
          color: Color(0xFF00853F),
          hexCode: '#00853F',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, hope, and the fertility of the land',
          meaningAr: 'الإسلام والأمل وخصوبة الأرض',
        ),
        FlagColor(
          color: Color(0xFFFDEF42),
          hexCode: '#FDEF42',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The wealth of the nation and the arts',
          meaningAr: 'ثروة الأمة والفنون',
        ),
        FlagColor(
          color: Color(0xFFE31B23),
          hexCode: '#E31B23',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The struggle for independence and sacrifice',
          meaningAr: 'النضال من أجل الاستقلال والتضحية',
        ),
      ],
      additionalInfo: 'The green star represents the opening of the five senses to Africa, and to the world.',
      additionalInfoAr: 'تمثل النجمة الخضراء انفتاح الحواس الخمس على أفريقيا والعالم.',
    ),

    // Tanzania
    'TZ': const FlagMeaning(
      countryCode: 'TZ',
      colors: [
        FlagColor(
          color: Color(0xFF1EB53A),
          hexCode: '#1EB53A',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The natural vegetation and fertile lands',
          meaningAr: 'الغطاء النباتي الطبيعي والأراضي الخصبة',
        ),
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The mineral wealth',
          meaningAr: 'الثروة المعدنية',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The Swahili people',
          meaningAr: 'شعب السواحلي',
        ),
        FlagColor(
          color: Color(0xFF00A3DD),
          hexCode: '#00A3DD',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Indian Ocean and the many lakes',
          meaningAr: 'المحيط الهندي والبحيرات الكثيرة',
        ),
      ],
      additionalInfo: 'The flag combines elements from Tanganyika and Zanzibar flags after their union in 1964.',
      additionalInfoAr: 'يجمع العلم عناصر من علمي تنجانيقا وزنجبار بعد اتحادهما عام 1964.',
    ),

    // Uganda
    'UG': const FlagMeaning(
      countryCode: 'UG',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The African people',
          meaningAr: 'الشعب الأفريقي',
        ),
        FlagColor(
          color: Color(0xFFFCDC04),
          hexCode: '#FCDC04',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The sunshine and vitality',
          meaningAr: 'أشعة الشمس والحيوية',
        ),
        FlagColor(
          color: Color(0xFFD90000),
          hexCode: '#D90000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'African brotherhood and the blood of martyrs',
          meaningAr: 'الأخوة الأفريقية ودماء الشهداء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace (in the emblem background)',
          meaningAr: 'السلام (في خلفية الشعار)',
        ),
      ],
      additionalInfo: 'The Grey Crowned Crane is the national bird, known for its gentle nature.',
      additionalInfoAr: 'الكركي المتوج الرمادي هو الطائر الوطني المعروف بطبيعته اللطيفة.',
    ),

    // Rwanda
    'RW': const FlagMeaning(
      countryCode: 'RW',
      colors: [
        FlagColor(
          color: Color(0xFF00A1DE),
          hexCode: '#00A1DE',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Happiness and peace',
          meaningAr: 'السعادة والسلام',
        ),
        FlagColor(
          color: Color(0xFFFAD201),
          hexCode: '#FAD201',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'Economic development and prosperity',
          meaningAr: 'التنمية الاقتصادية والازدهار',
        ),
        FlagColor(
          color: Color(0xFF20603D),
          hexCode: '#20603D',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope and prosperity',
          meaningAr: 'الأمل والازدهار',
        ),
      ],
      additionalInfo: 'The sun represents enlightenment. The flag was changed in 2001 to promote national unity after the genocide.',
      additionalInfoAr: 'تمثل الشمس التنوير. غُيّر العلم عام 2001 لتعزيز الوحدة الوطنية بعد الإبادة الجماعية.',
    ),

    // Cameroon
    'CM': const FlagMeaning(
      countryCode: 'CM',
      colors: [
        FlagColor(
          color: Color(0xFF007A5E),
          hexCode: '#007A5E',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The forests of the south',
          meaningAr: 'غابات الجنوب',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Unity and the struggle for independence',
          meaningAr: 'الوحدة والنضال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The sun and the savannas of the north',
          meaningAr: 'الشمس وسافانا الشمال',
        ),
      ],
      additionalInfo: 'The yellow star is known as the "star of unity" and was added in 1975.',
      additionalInfoAr: 'تُعرف النجمة الصفراء بـ"نجمة الوحدة" وأُضيفت عام 1975.',
    ),

    // Ivory Coast (Côte d'Ivoire)
    'CI': const FlagMeaning(
      countryCode: 'CI',
      colors: [
        FlagColor(
          color: Color(0xFFF77F00),
          hexCode: '#F77F00',
          name: 'Orange',
          nameAr: 'برتقالي',
          meaningEn: 'The land and the savanna in the north',
          meaningAr: 'الأرض والسافانا في الشمال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and unity',
          meaningAr: 'السلام والوحدة',
        ),
        FlagColor(
          color: Color(0xFF009E60),
          hexCode: '#009E60',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope and the forests in the south',
          meaningAr: 'الأمل والغابات في الجنوب',
        ),
      ],
      additionalInfo: 'The flag is similar to Ireland\'s but reversed. It was adopted in 1959.',
      additionalInfoAr: 'العلم مشابه لعلم أيرلندا لكنه معكوس. اعتُمد عام 1959.',
    ),

    // Democratic Republic of the Congo
    'CD': const FlagMeaning(
      countryCode: 'CD',
      colors: [
        FlagColor(
          color: Color(0xFF007FFF),
          hexCode: '#007FFF',
          name: 'Sky Blue',
          nameAr: 'أزرق سماوي',
          meaningEn: 'Peace',
          meaningAr: 'السلام',
        ),
        FlagColor(
          color: Color(0xFFCE1021),
          hexCode: '#CE1021',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of the country\'s martyrs',
          meaningAr: 'دماء شهداء البلاد',
        ),
        FlagColor(
          color: Color(0xFFF7D618),
          hexCode: '#F7D618',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The wealth of the country',
          meaningAr: 'ثروة البلاد',
        ),
      ],
      additionalInfo: 'The star represents the radiant future. The current design was adopted in 2006.',
      additionalInfoAr: 'تمثل النجمة المستقبل المشرق. اعتُمد التصميم الحالي عام 2006.',
    ),

    // Angola
    'AO': const FlagMeaning(
      countryCode: 'AO',
      colors: [
        FlagColor(
          color: Color(0xFFCC092F),
          hexCode: '#CC092F',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed during colonialism and the liberation struggle',
          meaningAr: 'الدماء المراقة خلال الاستعمار ونضال التحرير',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'Africa and the African people',
          meaningAr: 'أفريقيا والشعب الأفريقي',
        ),
        FlagColor(
          color: Color(0xFFFFEC00),
          hexCode: '#FFEC00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The mineral wealth of Angola',
          meaningAr: 'الثروة المعدنية لأنغولا',
        ),
      ],
      additionalInfo: 'The machete and gear represent agricultural and industrial workers. The star symbolizes socialism.',
      additionalInfoAr: 'تمثل المنجل والترس العمال الزراعيين والصناعيين. ترمز النجمة إلى الاشتراكية.',
    ),

    // Zimbabwe
    'ZW': const FlagMeaning(
      countryCode: 'ZW',
      colors: [
        FlagColor(
          color: Color(0xFF006400),
          hexCode: '#006400',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Agriculture and rural areas',
          meaningAr: 'الزراعة والمناطق الريفية',
        ),
        FlagColor(
          color: Color(0xFFFFD200),
          hexCode: '#FFD200',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'Mineral wealth',
          meaningAr: 'الثروة المعدنية',
        ),
        FlagColor(
          color: Color(0xFFD40000),
          hexCode: '#D40000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed during the liberation war',
          meaningAr: 'الدماء المراقة خلال حرب التحرير',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The heritage of the Black majority',
          meaningAr: 'تراث الأغلبية السوداء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and progress',
          meaningAr: 'السلام والتقدم',
        ),
      ],
      additionalInfo: 'The Zimbabwe Bird is from the ruins of Great Zimbabwe. The red star represents socialism.',
      additionalInfoAr: 'طائر زيمبابوي من أطلال زيمبابوي العظمى. ترمز النجمة الحمراء إلى الاشتراكية.',
    ),

    // Mozambique
    'MZ': const FlagMeaning(
      countryCode: 'MZ',
      colors: [
        FlagColor(
          color: Color(0xFF009A44),
          hexCode: '#009A44',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The riches of the land',
          meaningAr: 'ثروات الأرض',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The African continent',
          meaningAr: 'القارة الأفريقية',
        ),
        FlagColor(
          color: Color(0xFFFCE100),
          hexCode: '#FCE100',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The mineral resources',
          meaningAr: 'الموارد المعدنية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace',
          meaningAr: 'السلام',
        ),
        FlagColor(
          color: Color(0xFFD21034),
          hexCode: '#D21034',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The struggle for independence',
          meaningAr: 'النضال من أجل الاستقلال',
        ),
      ],
      additionalInfo: 'The emblem features an AK-47 with a bayonet, a hoe, and a book, representing defense, agriculture, and education.',
      additionalInfoAr: 'يتضمن الشعار بندقية AK-47 بحربة ومعزقة وكتاب، تمثل الدفاع والزراعة والتعليم.',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // EUROPE
    // ═══════════════════════════════════════════════════════════════════════

    // United Kingdom
    'GB': const FlagMeaning(
      countryCode: 'GB',
      colors: [
        FlagColor(
          color: Color(0xFFCF142B),
          hexCode: '#CF142B',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Cross of St. George (England) and St. Patrick (Ireland)',
          meaningAr: 'صليب القديس جورج (إنجلترا) والقديس باتريك (أيرلندا)',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Cross of St. Andrew (Scotland) and peace',
          meaningAr: 'صليب القديس أندرو (اسكتلندا) والسلام',
        ),
        FlagColor(
          color: Color(0xFF00247D),
          hexCode: '#00247D',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The background of the Scottish flag (St. Andrew\'s Cross)',
          meaningAr: 'خلفية العلم الاسكتلندي (صليب القديس أندرو)',
        ),
      ],
      additionalInfo: 'The Union Jack combines the flags of England, Scotland, and Ireland. Wales is not represented.',
      additionalInfoAr: 'يجمع علم الاتحاد أعلام إنجلترا واسكتلندا وأيرلندا. ويلز غير ممثلة.',
    ),

    // France
    'FR': const FlagMeaning(
      countryCode: 'FR',
      colors: [
        FlagColor(
          color: Color(0xFF002654),
          hexCode: '#002654',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Liberty - representing the bourgeoisie of Paris',
          meaningAr: 'الحرية - تمثل برجوازية باريس',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Equality - representing the clergy and the monarchy',
          meaningAr: 'المساواة - تمثل رجال الدين والملكية',
        ),
        FlagColor(
          color: Color(0xFFED2939),
          hexCode: '#ED2939',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Fraternity - representing the nobility',
          meaningAr: 'الإخاء - يمثل النبلاء',
        ),
      ],
      additionalInfo: 'The Tricolor represents the ideals of the French Revolution: Liberté, Égalité, Fraternité (Liberty, Equality, Fraternity).',
      additionalInfoAr: 'يمثل العلم الثلاثي مُثُل الثورة الفرنسية: الحرية والمساواة والإخاء.',
    ),

    // Germany
    'DE': const FlagMeaning(
      countryCode: 'DE',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'Determination and the dark past that was overcome',
          meaningAr: 'العزيمة والماضي المظلم الذي تم تجاوزه',
        ),
        FlagColor(
          color: Color(0xFFDD0000),
          hexCode: '#DD0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Bravery, strength, and the blood shed for the fatherland',
          meaningAr: 'الشجاعة والقوة والدماء المراقة من أجل الوطن',
        ),
        FlagColor(
          color: Color(0xFFFFCC00),
          hexCode: '#FFCC00',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'Generosity and the golden future',
          meaningAr: 'الكرم والمستقبل الذهبي',
        ),
      ],
      additionalInfo: 'The colors originated from the uniforms of the Lützow Free Corps during the Napoleonic Wars.',
      additionalInfoAr: 'نشأت الألوان من زي فيلق لوتزوف الحر خلال الحروب النابليونية.',
    ),

    // Italy
    'IT': const FlagMeaning(
      countryCode: 'IT',
      colors: [
        FlagColor(
          color: Color(0xFF009246),
          hexCode: '#009246',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope, the Italian countryside, and the plains of Lombardy',
          meaningAr: 'الأمل والريف الإيطالي وسهول لومبارديا',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Faith, the snow on the Alps, and peace',
          meaningAr: 'الإيمان وثلوج جبال الألب والسلام',
        ),
        FlagColor(
          color: Color(0xFFCE2B37),
          hexCode: '#CE2B37',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Charity, the blood of patriots, and love',
          meaningAr: 'الإحسان ودماء الوطنيين والحب',
        ),
      ],
      additionalInfo: 'Inspired by the French Tricolor. The flag was adopted during Italian unification (Risorgimento).',
      additionalInfoAr: 'مستوحى من العلم الفرنسي الثلاثي. اعتُمد خلال التوحيد الإيطالي (ريسورجيمينتو).',
    ),

    // Spain
    'ES': const FlagMeaning(
      countryCode: 'ES',
      colors: [
        FlagColor(
          color: Color(0xFFAA151B),
          hexCode: '#AA151B',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed for Spain',
          meaningAr: 'الدماء المراقة من أجل إسبانيا',
        ),
        FlagColor(
          color: Color(0xFFF1BF00),
          hexCode: '#F1BF00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'Generosity and the Spanish sun',
          meaningAr: 'الكرم والشمس الإسبانية',
        ),
      ],
      additionalInfo: 'The coat of arms contains the historical kingdoms of Spain: Castile, León, Aragon, Navarre, and Granada.',
      additionalInfoAr: 'يحتوي شعار النبالة على الممالك التاريخية لإسبانيا: قشتالة وليون وأراغون ونافارا وغرناطة.',
    ),

    // Portugal
    'PT': const FlagMeaning(
      countryCode: 'PT',
      colors: [
        FlagColor(
          color: Color(0xFF006600),
          hexCode: '#006600',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope for the future and the republican revolution',
          meaningAr: 'الأمل في المستقبل والثورة الجمهورية',
        ),
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of those who died defending the nation',
          meaningAr: 'دماء الذين استشهدوا دفاعاً عن الوطن',
        ),
        FlagColor(
          color: Color(0xFFFFFF00),
          hexCode: '#FFFF00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The armillary sphere - maritime discoveries',
          meaningAr: 'الكرة الأرميلية - الاكتشافات البحرية',
        ),
      ],
      additionalInfo: 'The armillary sphere represents Portugal\'s Age of Discovery. The shield contains five blue escutcheons.',
      additionalInfoAr: 'تمثل الكرة الأرميلية عصر الاكتشافات البرتغالية. يحتوي الدرع على خمسة شعارات زرقاء.',
    ),

    // Netherlands
    'NL': const FlagMeaning(
      countryCode: 'NL',
      colors: [
        FlagColor(
          color: Color(0xFFAE1C28),
          hexCode: '#AE1C28',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Bravery and the blood shed for independence',
          meaningAr: 'الشجاعة والدماء المراقة من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty',
          meaningAr: 'السلام والصدق',
        ),
        FlagColor(
          color: Color(0xFF21468B),
          hexCode: '#21468B',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Loyalty, vigilance, and justice',
          meaningAr: 'الولاء واليقظة والعدالة',
        ),
      ],
      additionalInfo: 'Originally orange (for William of Orange), the top stripe was changed to red as it was more visible at sea.',
      additionalInfoAr: 'كان الشريط العلوي برتقالياً في الأصل (لويليام أورانج) وتم تغييره إلى الأحمر لأنه أكثر وضوحاً في البحر.',
    ),

    // Belgium
    'BE': const FlagMeaning(
      countryCode: 'BE',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The shield of the Duchy of Brabant',
          meaningAr: 'درع دوقية برابانت',
        ),
        FlagColor(
          color: Color(0xFFFDDA24),
          hexCode: '#FDDA24',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The lion of the Duchy of Brabant',
          meaningAr: 'أسد دوقية برابانت',
        ),
        FlagColor(
          color: Color(0xFFEF3340),
          hexCode: '#EF3340',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The tongue and claws of the lion',
          meaningAr: 'لسان ومخالب الأسد',
        ),
      ],
      additionalInfo: 'The colors come from the coat of arms of the Duchy of Brabant. Belgium gained independence in 1830.',
      additionalInfoAr: 'الألوان من شعار نبالة دوقية برابانت. نالت بلجيكا استقلالها عام 1830.',
    ),

    // Switzerland
    'CH': const FlagMeaning(
      countryCode: 'CH',
      colors: [
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed in defense of the faith and freedom',
          meaningAr: 'الدماء المراقة دفاعاً عن الإيمان والحرية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, honesty, and neutrality',
          meaningAr: 'السلام والصدق والحياد',
        ),
      ],
      additionalInfo: 'One of only two square sovereign-state flags (the other is Vatican City). Inspired the Red Cross symbol.',
      additionalInfoAr: 'أحد علمين فقط مربعين لدول ذات سيادة (الآخر هو مدينة الفاتيكان). ألهم رمز الصليب الأحمر.',
    ),

    // Austria
    'AT': const FlagMeaning(
      countryCode: 'AT',
      colors: [
        FlagColor(
          color: Color(0xFFED2939),
          hexCode: '#ED2939',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The bloodstained tunic of Duke Leopold V during the Crusades',
          meaningAr: 'السترة الملطخة بالدماء للدوق ليوبولد الخامس خلال الحروب الصليبية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The white tunic under the armor, revealed after removing the belt',
          meaningAr: 'السترة البيضاء تحت الدرع التي ظهرت بعد إزالة الحزام',
        ),
      ],
      additionalInfo: 'Legend says Duke Leopold V\'s tunic was so bloodstained in the Siege of Acre (1191) that only the part under his belt remained white.',
      additionalInfoAr: 'تقول الأسطورة إن سترة الدوق ليوبولد الخامس كانت ملطخة بالدماء في حصار عكا (1191) حتى بقي الجزء تحت حزامه أبيض فقط.',
    ),

    // Poland
    'PL': const FlagMeaning(
      countryCode: 'PL',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The white eagle - the symbol of Poland',
          meaningAr: 'النسر الأبيض - رمز بولندا',
        ),
        FlagColor(
          color: Color(0xFFDC143C),
          hexCode: '#DC143C',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The red background of the coat of arms',
          meaningAr: 'الخلفية الحمراء لشعار النبالة',
        ),
      ],
      additionalInfo: 'The colors come from the coat of arms - a white eagle on a red shield - used since the 13th century.',
      additionalInfoAr: 'الألوان من شعار النبالة - نسر أبيض على درع أحمر - المستخدم منذ القرن الثالث عشر.',
    ),

    // Russia
    'RU': const FlagMeaning(
      countryCode: 'RU',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Nobility, frankness, and freedom',
          meaningAr: 'النبل والصراحة والحرية',
        ),
        FlagColor(
          color: Color(0xFF0039A6),
          hexCode: '#0039A6',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Faithfulness, honesty, and the Virgin Mary',
          meaningAr: 'الإخلاص والصدق والعذراء مريم',
        ),
        FlagColor(
          color: Color(0xFFD52B1E),
          hexCode: '#D52B1E',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage, generosity, and love',
          meaningAr: 'الشجاعة والكرم والحب',
        ),
      ],
      additionalInfo: 'The Pan-Slavic colors were inspired by the flag of the Netherlands. Introduced by Peter the Great.',
      additionalInfoAr: 'ألوان الوحدة السلافية مستوحاة من علم هولندا. قدمها بطرس الأكبر.',
    ),

    // Ukraine
    'UA': const FlagMeaning(
      countryCode: 'UA',
      colors: [
        FlagColor(
          color: Color(0xFF005BBB),
          hexCode: '#005BBB',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The blue sky over Ukraine',
          meaningAr: 'السماء الزرقاء فوق أوكرانيا',
        ),
        FlagColor(
          color: Color(0xFFFFD500),
          hexCode: '#FFD500',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The golden wheat fields of Ukraine',
          meaningAr: 'حقول القمح الذهبية في أوكرانيا',
        ),
      ],
      additionalInfo: 'The colors represent the agricultural wealth of Ukraine - blue sky over golden wheat fields.',
      additionalInfoAr: 'تمثل الألوان الثروة الزراعية لأوكرانيا - سماء زرقاء فوق حقول القمح الذهبية.',
    ),

    // Greece
    'GR': const FlagMeaning(
      countryCode: 'GR',
      colors: [
        FlagColor(
          color: Color(0xFF0D5EAF),
          hexCode: '#0D5EAF',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The sea and sky that surround Greece',
          meaningAr: 'البحر والسماء المحيطين باليونان',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The purity of the independence struggle',
          meaningAr: 'نقاء نضال الاستقلال',
        ),
      ],
      additionalInfo: 'The nine stripes represent the syllables of "Eleftheria i Thanatos" (Freedom or Death). The cross represents Orthodox Christianity.',
      additionalInfoAr: 'تمثل الخطوط التسعة مقاطع "الحرية أو الموت". يمثل الصليب المسيحية الأرثوذكسية.',
    ),

    // Sweden
    'SE': const FlagMeaning(
      countryCode: 'SE',
      colors: [
        FlagColor(
          color: Color(0xFF006AA7),
          hexCode: '#006AA7',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Loyalty, justice, truth, and vigilance',
          meaningAr: 'الولاء والعدالة والحقيقة واليقظة',
        ),
        FlagColor(
          color: Color(0xFFFECC00),
          hexCode: '#FECC00',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'Generosity and the Nordic cross representing Christianity',
          meaningAr: 'الكرم والصليب الاسكندنافي الذي يمثل المسيحية',
        ),
      ],
      additionalInfo: 'The colors come from the coat of arms. Legend says King Eric IX saw a golden cross in the blue sky before battle.',
      additionalInfoAr: 'الألوان من شعار النبالة. تقول الأسطورة إن الملك إريك التاسع رأى صليباً ذهبياً في السماء الزرقاء قبل المعركة.',
    ),

    // Norway
    'NO': const FlagMeaning(
      countryCode: 'NO',
      colors: [
        FlagColor(
          color: Color(0xFFEF2B2D),
          hexCode: '#EF2B2D',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of those who fought for independence',
          meaningAr: 'دماء الذين ناضلوا من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the snow-capped mountains',
          meaningAr: 'السلام والجبال المكسوة بالثلوج',
        ),
        FlagColor(
          color: Color(0xFF002868),
          hexCode: '#002868',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The sea and the fjords',
          meaningAr: 'البحر والمضائق البحرية',
        ),
      ],
      additionalInfo: 'The cross is the Nordic cross, representing Christianity. The colors reflect liberty (inspired by France and the USA).',
      additionalInfoAr: 'الصليب هو الصليب الاسكندنافي الذي يمثل المسيحية. تعكس الألوان الحرية (مستوحاة من فرنسا والولايات المتحدة).',
    ),

    // Denmark
    'DK': const FlagMeaning(
      countryCode: 'DK',
      colors: [
        FlagColor(
          color: Color(0xFFC60C30),
          hexCode: '#C60C30',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Bravery and strength',
          meaningAr: 'الشجاعة والقوة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty - the Nordic cross',
          meaningAr: 'السلام والصدق - الصليب الاسكندنافي',
        ),
      ],
      additionalInfo: 'The Dannebrog is the oldest state flag still in use. Legend says it fell from the sky during the Battle of Lyndanisse in 1219.',
      additionalInfoAr: 'دانيبروغ هو أقدم علم دولة لا يزال قيد الاستخدام. تقول الأسطورة إنه سقط من السماء خلال معركة ليندانيسه عام 1219.',
    ),

    // Finland
    'FI': const FlagMeaning(
      countryCode: 'FI',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The snow that covers Finland in winter',
          meaningAr: 'الثلوج التي تغطي فنلندا في الشتاء',
        ),
        FlagColor(
          color: Color(0xFF002F6C),
          hexCode: '#002F6C',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The thousands of lakes in Finland',
          meaningAr: 'آلاف البحيرات في فنلندا',
        ),
      ],
      additionalInfo: 'Finland is called the "Land of a Thousand Lakes." The Nordic cross represents Christianity and Scandinavian heritage.',
      additionalInfoAr: 'تُسمى فنلندا "أرض الألف بحيرة". يمثل الصليب الاسكندنافي المسيحية والتراث الاسكندنافي.',
    ),

    // Ireland
    'IE': const FlagMeaning(
      countryCode: 'IE',
      colors: [
        FlagColor(
          color: Color(0xFF169B62),
          hexCode: '#169B62',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Irish Catholic tradition and the Gaelic heritage',
          meaningAr: 'التقليد الكاثوليكي الأيرلندي والتراث الغيلي',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and unity between Catholics and Protestants',
          meaningAr: 'السلام والوحدة بين الكاثوليك والبروتستانت',
        ),
        FlagColor(
          color: Color(0xFFFF883E),
          hexCode: '#FF883E',
          name: 'Orange',
          nameAr: 'برتقالي',
          meaningEn: 'The Irish Protestant tradition (followers of William of Orange)',
          meaningAr: 'التقليد البروتستانتي الأيرلندي (أتباع ويليام أورانج)',
        ),
      ],
      additionalInfo: 'The tricolor was inspired by the French flag. It symbolizes hope for peace between the two traditions.',
      additionalInfoAr: 'العلم الثلاثي مستوحى من العلم الفرنسي. يرمز إلى الأمل في السلام بين التقليدين.',
    ),

    // Czech Republic
    'CZ': const FlagMeaning(
      countryCode: 'CZ',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty',
          meaningAr: 'السلام والصدق',
        ),
        FlagColor(
          color: Color(0xFFD7141A),
          hexCode: '#D7141A',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage and valor',
          meaningAr: 'الشجاعة والبسالة',
        ),
        FlagColor(
          color: Color(0xFF11457E),
          hexCode: '#11457E',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Vigilance, truth, loyalty, and Slovakia (historically)',
          meaningAr: 'اليقظة والحقيقة والولاء وسلوفاكيا (تاريخياً)',
        ),
      ],
      additionalInfo: 'The blue triangle was added in 1920 to distinguish it from the Polish flag. It was originally the flag of Czechoslovakia.',
      additionalInfoAr: 'أُضيف المثلث الأزرق عام 1920 لتمييزه عن العلم البولندي. كان في الأصل علم تشيكوسلوفاكيا.',
    ),

    // Hungary
    'HU': const FlagMeaning(
      countryCode: 'HU',
      colors: [
        FlagColor(
          color: Color(0xFFCE2939),
          hexCode: '#CE2939',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Strength and the blood shed for the fatherland',
          meaningAr: 'القوة والدماء المراقة من أجل الوطن',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Faithfulness and freedom',
          meaningAr: 'الإخلاص والحرية',
        ),
        FlagColor(
          color: Color(0xFF477050),
          hexCode: '#477050',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope and the fertile lands of Hungary',
          meaningAr: 'الأمل والأراضي الخصبة في المجر',
        ),
      ],
      additionalInfo: 'The colors date back to the 9th century Hungarian tribal confederation.',
      additionalInfoAr: 'تعود الألوان إلى الاتحاد القبلي المجري في القرن التاسع.',
    ),

    // Romania
    'RO': const FlagMeaning(
      countryCode: 'RO',
      colors: [
        FlagColor(
          color: Color(0xFF002B7F),
          hexCode: '#002B7F',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Liberty and the sky',
          meaningAr: 'الحرية والسماء',
        ),
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'Justice and the grain fields',
          meaningAr: 'العدالة وحقول الحبوب',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Fraternity and the blood of patriots',
          meaningAr: 'الأخوة ودماء الوطنيين',
        ),
      ],
      additionalInfo: 'The tricolor represents Wallachia (blue), Moldavia (red), and their union in Romania.',
      additionalInfoAr: 'يمثل العلم الثلاثي والاشيا (أزرق) ومولدافيا (أحمر) واتحادهما في رومانيا.',
    ),

    // Bulgaria
    'BG': const FlagMeaning(
      countryCode: 'BG',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, love, and freedom',
          meaningAr: 'السلام والحب والحرية',
        ),
        FlagColor(
          color: Color(0xFF00966E),
          hexCode: '#00966E',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Agricultural abundance and the forests',
          meaningAr: 'الوفرة الزراعية والغابات',
        ),
        FlagColor(
          color: Color(0xFFD62612),
          hexCode: '#D62612',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The struggle for independence and courage',
          meaningAr: 'النضال من أجل الاستقلال والشجاعة',
        ),
      ],
      additionalInfo: 'Originally based on the Russian flag, green replaced blue in 1878 to represent the Bulgarian lands.',
      additionalInfoAr: 'استُبدل الأخضر بالأزرق عام 1878 ليمثل الأراضي البلغارية.',
    ),

    // Serbia
    'RS': const FlagMeaning(
      countryCode: 'RS',
      colors: [
        FlagColor(
          color: Color(0xFFC6363C),
          hexCode: '#C6363C',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed for freedom',
          meaningAr: 'الدماء المراقة من أجل الحرية',
        ),
        FlagColor(
          color: Color(0xFF0C4076),
          hexCode: '#0C4076',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The clear sky and loyalty',
          meaningAr: 'السماء الصافية والولاء',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Mother\'s milk and pure intentions',
          meaningAr: 'حليب الأم والنوايا النقية',
        ),
      ],
      additionalInfo: 'The Pan-Slavic colors are inverted from Russia\'s flag. The coat of arms features the Serbian cross.',
      additionalInfoAr: 'ألوان الوحدة السلافية معكوسة عن علم روسيا. يتضمن شعار النبالة الصليب الصربي.',
    ),

    // Croatia
    'HR': const FlagMeaning(
      countryCode: 'HR',
      colors: [
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of Croatian martyrs',
          meaningAr: 'دماء الشهداء الكرواتيين',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and honesty',
          meaningAr: 'السلام والصدق',
        ),
        FlagColor(
          color: Color(0xFF171796),
          hexCode: '#171796',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Loyalty and the Adriatic Sea',
          meaningAr: 'الولاء والبحر الأدرياتيكي',
        ),
      ],
      additionalInfo: 'The checkerboard (šahovnica) has been a Croatian symbol since the 10th century.',
      additionalInfoAr: 'كانت رقعة الشطرنج (شاهوفنيتسا) رمزاً كرواتياً منذ القرن العاشر.',
    ),

    // Slovenia
    'SI': const FlagMeaning(
      countryCode: 'SI',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace',
          meaningAr: 'السلام',
        ),
        FlagColor(
          color: Color(0xFF0000FF),
          hexCode: '#0000FF',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Adriatic Sea and Slovenian rivers',
          meaningAr: 'البحر الأدرياتيكي والأنهار السلوفينية',
        ),
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage and the blood shed for the homeland',
          meaningAr: 'الشجاعة والدماء المراقة من أجل الوطن',
        ),
      ],
      additionalInfo: 'The coat of arms shows Mount Triglav (the highest peak) and the three stars of the Counts of Celje.',
      additionalInfoAr: 'يُظهر شعار النبالة جبل تريغلاف (أعلى قمة) والنجوم الثلاث لكونتات تسيلي.',
    ),

    // Slovakia
    'SK': const FlagMeaning(
      countryCode: 'SK',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the Tatra Mountains\' snow',
          meaningAr: 'السلام وثلوج جبال تاترا',
        ),
        FlagColor(
          color: Color(0xFF0B4EA2),
          hexCode: '#0B4EA2',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Slavic brotherhood',
          meaningAr: 'الأخوة السلافية',
        ),
        FlagColor(
          color: Color(0xFFEE1C25),
          hexCode: '#EE1C25',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Blood and courage',
          meaningAr: 'الدماء والشجاعة',
        ),
      ],
      additionalInfo: 'The coat of arms shows the double cross on three mountains representing the Tatra, Fatra, and Matra ranges.',
      additionalInfoAr: 'يُظهر شعار النبالة الصليب المزدوج على ثلاثة جبال تمثل سلاسل تاترا وفاترا وماترا.',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ASIA
    // ═══════════════════════════════════════════════════════════════════════

    // Japan
    'JP': const FlagMeaning(
      countryCode: 'JP',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Honesty and purity of the Japanese people',
          meaningAr: 'صدق ونقاء الشعب الياباني',
        ),
        FlagColor(
          color: Color(0xFFBC002D),
          hexCode: '#BC002D',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The rising sun and sincerity',
          meaningAr: 'الشمس المشرقة والإخلاص',
        ),
      ],
      additionalInfo: 'Known as "Nisshōki" (日章旗, sun-mark flag) or "Hinomaru" (日の丸, circle of the sun). Japan is called "Land of the Rising Sun."',
      additionalInfoAr: 'يُعرف بـ"نيشوكي" (علم علامة الشمس) أو "هينومارو" (دائرة الشمس). تُسمى اليابان "أرض الشمس المشرقة".',
    ),

    // China
    'CN': const FlagMeaning(
      countryCode: 'CN',
      colors: [
        FlagColor(
          color: Color(0xFFDE2910),
          hexCode: '#DE2910',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The communist revolution and the blood of martyrs',
          meaningAr: 'الثورة الشيوعية ودماء الشهداء',
        ),
        FlagColor(
          color: Color(0xFFFFDE00),
          hexCode: '#FFDE00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The golden future and the Yellow race of China',
          meaningAr: 'المستقبل الذهبي والعرق الأصفر للصين',
        ),
      ],
      additionalInfo: 'The large star represents the Communist Party. The four smaller stars represent the four social classes: working class, peasantry, urban petty bourgeoisie, and national bourgeoisie.',
      additionalInfoAr: 'تمثل النجمة الكبيرة الحزب الشيوعي. والنجوم الأربع الصغيرة تمثل الطبقات الاجتماعية الأربع.',
    ),

    // India
    'IN': const FlagMeaning(
      countryCode: 'IN',
      colors: [
        FlagColor(
          color: Color(0xFFFF9933),
          hexCode: '#FF9933',
          name: 'Saffron',
          nameAr: 'زعفراني',
          meaningEn: 'Courage, sacrifice, and the spirit of renunciation',
          meaningAr: 'الشجاعة والتضحية وروح الزهد',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, truth, and purity',
          meaningAr: 'السلام والحقيقة والنقاء',
        ),
        FlagColor(
          color: Color(0xFF138808),
          hexCode: '#138808',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Faith, fertility, and growth',
          meaningAr: 'الإيمان والخصوبة والنمو',
        ),
        FlagColor(
          color: Color(0xFF000080),
          hexCode: '#000080',
          name: 'Navy Blue',
          nameAr: 'أزرق داكن',
          meaningEn: 'The Ashoka Chakra - law, dharma, and the wheel of time',
          meaningAr: 'شاكرا أشوكا - القانون والدارما وعجلة الزمن',
        ),
      ],
      additionalInfo: 'The Ashoka Chakra has 24 spokes representing the 24 hours of the day. It is taken from the Lion Capital of Ashoka.',
      additionalInfoAr: 'تحتوي شاكرا أشوكا على 24 شعاعًا تمثل 24 ساعة في اليوم. مأخوذة من عاصمة الأسد لأشوكا.',
    ),

    // South Korea
    'KR': const FlagMeaning(
      countryCode: 'KR',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, purity, and the Korean people',
          meaningAr: 'السلام والنقاء والشعب الكوري',
        ),
        FlagColor(
          color: Color(0xFFCD2E3A),
          hexCode: '#CD2E3A',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Positive cosmic forces (yang) - the sun, fire, light',
          meaningAr: 'القوى الكونية الإيجابية (يانغ) - الشمس والنار والنور',
        ),
        FlagColor(
          color: Color(0xFF0047A0),
          hexCode: '#0047A0',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Negative cosmic forces (yin) - the moon, water, darkness',
          meaningAr: 'القوى الكونية السلبية (ين) - القمر والماء والظلام',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The four trigrams - heaven, earth, water, fire',
          meaningAr: 'المثلثات الأربعة - السماء والأرض والماء والنار',
        ),
      ],
      additionalInfo: 'The Taeguk (태극) symbol represents the balance of yin and yang. The four trigrams are from the I Ching.',
      additionalInfoAr: 'يمثل رمز التايغوك (태극) توازن الين واليانغ. المثلثات الأربعة من كتاب التغييرات.',
    ),

    // North Korea
    'KP': const FlagMeaning(
      countryCode: 'KP',
      colors: [
        FlagColor(
          color: Color(0xFF024FA2),
          hexCode: '#024FA2',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Sovereignty, peace, and friendship',
          meaningAr: 'السيادة والسلام والصداقة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and the Korean heritage',
          meaningAr: 'النقاء والتراث الكوري',
        ),
        FlagColor(
          color: Color(0xFFED1C27),
          hexCode: '#ED1C27',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Revolutionary patriotism and the blood of martyrs',
          meaningAr: 'الوطنية الثورية ودماء الشهداء',
        ),
      ],
      additionalInfo: 'The red star represents socialism. Adopted in 1948 when the Democratic People\'s Republic was established.',
      additionalInfoAr: 'تمثل النجمة الحمراء الاشتراكية. اعتُمد عام 1948 عند تأسيس جمهورية كوريا الديمقراطية الشعبية.',
    ),

    // Vietnam
    'VN': const FlagMeaning(
      countryCode: 'VN',
      colors: [
        FlagColor(
          color: Color(0xFFDA251D),
          hexCode: '#DA251D',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The bloodshed during the struggle for independence',
          meaningAr: 'الدماء المراقة خلال النضال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFF00),
          hexCode: '#FFFF00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The five-pointed star representing the unity of five classes',
          meaningAr: 'النجمة الخماسية التي تمثل وحدة الطبقات الخمس',
        ),
      ],
      additionalInfo: 'The five points represent intellectuals, farmers, workers, businesspeople, and soldiers working together.',
      additionalInfoAr: 'تمثل النقاط الخمس المثقفين والمزارعين والعمال ورجال الأعمال والجنود يعملون معاً.',
    ),

    // Thailand
    'TH': const FlagMeaning(
      countryCode: 'TH',
      colors: [
        FlagColor(
          color: Color(0xFFEE2422),
          hexCode: '#EE2422',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The nation and the blood of those who fought for independence',
          meaningAr: 'الأمة ودماء الذين ناضلوا من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Religion - primarily Buddhism',
          meaningAr: 'الدين - البوذية بشكل رئيسي',
        ),
        FlagColor(
          color: Color(0xFF241D4F),
          hexCode: '#241D4F',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The monarchy and the King',
          meaningAr: 'الملكية والملك',
        ),
      ],
      additionalInfo: 'The three colors represent the unofficial motto: Nation, Religion, King. Blue was added in 1917 to show solidarity with the Allies in WWI.',
      additionalInfoAr: 'تمثل الألوان الثلاثة الشعار غير الرسمي: الأمة والدين والملك. أُضيف الأزرق عام 1917 للتضامن مع الحلفاء.',
    ),

    // Indonesia
    'ID': const FlagMeaning(
      countryCode: 'ID',
      colors: [
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage and the physical life of the body',
          meaningAr: 'الشجاعة والحياة المادية للجسد',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and the spiritual life of the soul',
          meaningAr: 'النقاء والحياة الروحية للروح',
        ),
      ],
      additionalInfo: 'Known as "Sang Saka Merah Putih" (Sacred Red and White). The design dates back to the 13th-century Majapahit Empire.',
      additionalInfoAr: 'يُعرف بـ"سانغ ساكا ميراه بوتيه" (الأحمر والأبيض المقدس). يعود التصميم إلى إمبراطورية ماجاباهيت في القرن الثالث عشر.',
    ),

    // Malaysia
    'MY': const FlagMeaning(
      countryCode: 'MY',
      colors: [
        FlagColor(
          color: Color(0xFFCC0001),
          hexCode: '#CC0001',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage and the brave people',
          meaningAr: 'الشجاعة والشعب الشجاع',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and clean governance',
          meaningAr: 'النقاء والحكم النظيف',
        ),
        FlagColor(
          color: Color(0xFF010066),
          hexCode: '#010066',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Unity of the Malaysian people',
          meaningAr: 'وحدة الشعب الماليزي',
        ),
        FlagColor(
          color: Color(0xFFFFCC00),
          hexCode: '#FFCC00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The royal color representing the sultans',
          meaningAr: 'اللون الملكي الذي يمثل السلاطين',
        ),
      ],
      additionalInfo: 'The 14 stripes and 14-point star represent the 13 states and federal government. The crescent represents Islam.',
      additionalInfoAr: 'تمثل الخطوط الـ14 والنجمة ذات الـ14 نقطة الولايات الـ13 والحكومة الاتحادية. يمثل الهلال الإسلام.',
    ),

    // Philippines
    'PH': const FlagMeaning(
      countryCode: 'PH',
      colors: [
        FlagColor(
          color: Color(0xFF0038A8),
          hexCode: '#0038A8',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Peace, truth, and justice',
          meaningAr: 'السلام والحقيقة والعدالة',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Patriotism and valor',
          meaningAr: 'الوطنية والشجاعة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Equality and brotherhood',
          meaningAr: 'المساواة والأخوة',
        ),
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The sun and the three stars',
          meaningAr: 'الشمس والنجوم الثلاث',
        ),
      ],
      additionalInfo: 'The sun\'s 8 rays represent the first 8 provinces that revolted. The 3 stars represent Luzon, Visayas, and Mindanao. In wartime, the flag is flown with red on top.',
      additionalInfoAr: 'تمثل أشعة الشمس الثماني أول 8 مقاطعات ثارت. تمثل النجوم الـ3 لوزون وفيساياس ومينداناو.',
    ),

    // Pakistan
    'PK': const FlagMeaning(
      countryCode: 'PK',
      colors: [
        FlagColor(
          color: Color(0xFF01411C),
          hexCode: '#01411C',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam and the Muslim majority',
          meaningAr: 'الإسلام والأغلبية المسلمة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Religious minorities and peace',
          meaningAr: 'الأقليات الدينية والسلام',
        ),
      ],
      additionalInfo: 'The crescent represents progress, the star represents light and knowledge. Designed by Syed Amir-uddin Kedwaii.',
      additionalInfoAr: 'يمثل الهلال التقدم والنجمة تمثل النور والمعرفة. صممه سيد أمير الدين كدوائي.',
    ),

    // Bangladesh
    'BD': const FlagMeaning(
      countryCode: 'BD',
      colors: [
        FlagColor(
          color: Color(0xFF006A4E),
          hexCode: '#006A4E',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The lush green land of Bangladesh',
          meaningAr: 'الأرض الخضراء الخصبة لبنغلاديش',
        ),
        FlagColor(
          color: Color(0xFFF42A41),
          hexCode: '#F42A41',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The rising sun and the blood of martyrs of 1971',
          meaningAr: 'الشمس المشرقة ودماء شهداء 1971',
        ),
      ],
      additionalInfo: 'The red disc is slightly off-center so it appears centered when the flag flies. Adopted after independence in 1971.',
      additionalInfoAr: 'القرص الأحمر بعيد قليلاً عن المركز ليظهر في الوسط عند رفرفة العلم. اعتُمد بعد الاستقلال عام 1971.',
    ),

    // Singapore
    'SG': const FlagMeaning(
      countryCode: 'SG',
      colors: [
        FlagColor(
          color: Color(0xFFED2939),
          hexCode: '#ED2939',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Universal brotherhood and equality',
          meaningAr: 'الأخوة العالمية والمساواة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Pervading and everlasting purity and virtue',
          meaningAr: 'النقاء والفضيلة السائدة والأبدية',
        ),
      ],
      additionalInfo: 'The crescent moon represents a young nation on the rise. The five stars represent democracy, peace, progress, justice, and equality.',
      additionalInfoAr: 'يمثل الهلال أمة فتية في صعود. تمثل النجوم الخمس الديمقراطية والسلام والتقدم والعدالة والمساواة.',
    ),

    // Afghanistan
    'AF': const FlagMeaning(
      countryCode: 'AF',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The dark past and foreign occupation',
          meaningAr: 'الماضي المظلم والاحتلال الأجنبي',
        ),
        FlagColor(
          color: Color(0xFFD32011),
          hexCode: '#D32011',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed for independence',
          meaningAr: 'الدماء المراقة من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFF007A36),
          hexCode: '#007A36',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Islam, hope, and prosperity',
          meaningAr: 'الإسلام والأمل والازدهار',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The national emblem and peace',
          meaningAr: 'الشعار الوطني والسلام',
        ),
      ],
      additionalInfo: 'The emblem contains a mosque with a mihrab and minbar, the Shahada, and wheat sheaves. Note: The flag design has changed frequently with political changes.',
      additionalInfoAr: 'يحتوي الشعار على مسجد بمحراب ومنبر والشهادة وحزم القمح. ملاحظة: تغير تصميم العلم كثيراً مع التغييرات السياسية.',
    ),

    // Nepal
    'NP': const FlagMeaning(
      countryCode: 'NP',
      colors: [
        FlagColor(
          color: Color(0xFFDC143C),
          hexCode: '#DC143C',
          name: 'Crimson',
          nameAr: 'قرمزي',
          meaningEn: 'The brave spirit of the Nepalese people',
          meaningAr: 'الروح الشجاعة للشعب النيبالي',
        ),
        FlagColor(
          color: Color(0xFF003893),
          hexCode: '#003893',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Peace and harmony',
          meaningAr: 'السلام والانسجام',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The moon and sun symbols',
          meaningAr: 'رموز القمر والشمس',
        ),
      ],
      additionalInfo: 'The only non-rectangular national flag. The two triangles represent the Himalayan mountains and the two major religions: Hinduism and Buddhism.',
      additionalInfoAr: 'العلم الوطني الوحيد غير المستطيل. يمثل المثلثان جبال الهيمالايا والدينين الرئيسيين: الهندوسية والبوذية.',
    ),

    // Sri Lanka
    'LK': const FlagMeaning(
      countryCode: 'LK',
      colors: [
        FlagColor(
          color: Color(0xFF8D153A),
          hexCode: '#8D153A',
          name: 'Maroon',
          nameAr: 'عنابي',
          meaningEn: 'The Sinhalese ethnic group',
          meaningAr: 'المجموعة العرقية السنهالية',
        ),
        FlagColor(
          color: Color(0xFFFF7722),
          hexCode: '#FF7722',
          name: 'Saffron',
          nameAr: 'زعفراني',
          meaningEn: 'The Tamil ethnic group',
          meaningAr: 'المجموعة العرقية التاميلية',
        ),
        FlagColor(
          color: Color(0xFF005641),
          hexCode: '#005641',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The Moors (Sri Lankan Muslims)',
          meaningAr: 'المور (المسلمون السريلانكيون)',
        ),
        FlagColor(
          color: Color(0xFFFFBE29),
          hexCode: '#FFBE29',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'Buddhism and the lion',
          meaningAr: 'البوذية والأسد',
        ),
      ],
      additionalInfo: 'The lion represents the Sinhalese nation. The sword represents sovereignty, and the four leaves represent loving kindness, compassion, equanimity, and happiness.',
      additionalInfoAr: 'يمثل الأسد الأمة السنهالية. يمثل السيف السيادة، والأوراق الأربع تمثل اللطف والرحمة والاتزان والسعادة.',
    ),

    // Mongolia
    'MN': const FlagMeaning(
      countryCode: 'MN',
      colors: [
        FlagColor(
          color: Color(0xFFC4272F),
          hexCode: '#C4272F',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Progress and prosperity',
          meaningAr: 'التقدم والازدهار',
        ),
        FlagColor(
          color: Color(0xFF015197),
          hexCode: '#015197',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The eternal blue sky of Mongolia',
          meaningAr: 'السماء الزرقاء الأبدية لمنغوليا',
        ),
        FlagColor(
          color: Color(0xFFFFD900),
          hexCode: '#FFD900',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The Soyombo symbol',
          meaningAr: 'رمز سويومبو',
        ),
      ],
      additionalInfo: 'The Soyombo symbol contains fire (prosperity), sun and moon (eternity), triangles (arrows defeating enemies), and yin-yang (balance).',
      additionalInfoAr: 'يحتوي رمز سويومبو على النار (الازدهار) والشمس والقمر (الأبدية) والمثلثات (السهام التي تهزم الأعداء) والين يانغ (التوازن).',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // AMERICAS
    // ═══════════════════════════════════════════════════════════════════════

    // United States
    'US': const FlagMeaning(
      countryCode: 'US',
      colors: [
        FlagColor(
          color: Color(0xFFB31942),
          hexCode: '#B31942',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Valor and bravery',
          meaningAr: 'الشجاعة والبسالة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and innocence',
          meaningAr: 'النقاء والبراءة',
        ),
        FlagColor(
          color: Color(0xFF0A3161),
          hexCode: '#0A3161',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Vigilance, perseverance, and justice',
          meaningAr: 'اليقظة والمثابرة والعدالة',
        ),
      ],
      additionalInfo: 'The 50 stars represent the 50 states, and the 13 stripes represent the original 13 colonies that declared independence.',
      additionalInfoAr: 'تمثل النجوم الـ50 الولايات الخمسين، والخطوط الـ13 تمثل المستعمرات الـ13 الأصلية التي أعلنت الاستقلال.',
    ),

    // Canada
    'CA': const FlagMeaning(
      countryCode: 'CA',
      colors: [
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'England\'s St. George Cross and sacrifice',
          meaningAr: 'صليب القديس جورج الإنجليزي والتضحية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'France\'s royal emblem and peace',
          meaningAr: 'شعار فرنسا الملكي والسلام',
        ),
      ],
      additionalInfo: 'The 11-point maple leaf is an iconic Canadian symbol. The flag was adopted in 1965, replacing the Red Ensign.',
      additionalInfoAr: 'ورقة القيقب ذات الـ11 نقطة رمز كندي مميز. اعتُمد العلم عام 1965 ليحل محل الراية الحمراء.',
    ),

    // Mexico
    'MX': const FlagMeaning(
      countryCode: 'MX',
      colors: [
        FlagColor(
          color: Color(0xFF006847),
          hexCode: '#006847',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope, joy, and independence',
          meaningAr: 'الأمل والفرح والاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Unity, purity, and religion',
          meaningAr: 'الوحدة والنقاء والدين',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of national heroes',
          meaningAr: 'دماء الأبطال الوطنيين',
        ),
      ],
      additionalInfo: 'The eagle devouring a serpent on a cactus is from Aztec legend about the founding of Tenochtitlan (now Mexico City).',
      additionalInfoAr: 'النسر الذي يلتهم الثعبان فوق صبار من أسطورة الأزتك حول تأسيس تينوتشتيتلان (مكسيكو سيتي الآن).',
    ),

    // Brazil
    'BR': const FlagMeaning(
      countryCode: 'BR',
      colors: [
        FlagColor(
          color: Color(0xFF009C3B),
          hexCode: '#009C3B',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'The House of Braganza (Emperor Pedro I) and the Amazon forests',
          meaningAr: 'بيت براغانزا (الإمبراطور بيدرو الأول) وغابات الأمازون',
        ),
        FlagColor(
          color: Color(0xFFFEDF00),
          hexCode: '#FEDF00',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The House of Habsburg (Empress Leopoldina) and mineral wealth',
          meaningAr: 'بيت هابسبورغ (الإمبراطورة ليوبولدينا) والثروة المعدنية',
        ),
        FlagColor(
          color: Color(0xFF002776),
          hexCode: '#002776',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The night sky over Rio de Janeiro on November 15, 1889',
          meaningAr: 'سماء الليل فوق ريو دي جانيرو في 15 نوفمبر 1889',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the stars representing states',
          meaningAr: 'السلام والنجوم التي تمثل الولايات',
        ),
      ],
      additionalInfo: 'The 27 stars represent the 26 states and Federal District. The motto "Ordem e Progresso" means "Order and Progress."',
      additionalInfoAr: 'تمثل النجوم الـ27 الولايات الـ26 والمقاطعة الاتحادية. شعار "Ordem e Progresso" يعني "النظام والتقدم".',
    ),

    // Argentina
    'AR': const FlagMeaning(
      countryCode: 'AR',
      colors: [
        FlagColor(
          color: Color(0xFF74ACDF),
          hexCode: '#74ACDF',
          name: 'Sky Blue',
          nameAr: 'أزرق سماوي',
          meaningEn: 'The clear skies and the Río de la Plata',
          meaningAr: 'السماء الصافية ونهر لابلاتا',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, purity, and the silver of the land',
          meaningAr: 'السلام والنقاء وفضة الأرض',
        ),
        FlagColor(
          color: Color(0xFFF6B40E),
          hexCode: '#F6B40E',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The Sun of May representing the May Revolution',
          meaningAr: 'شمس مايو التي تمثل ثورة مايو',
        ),
      ],
      additionalInfo: 'The Sun of May commemorates the appearance of the sun through clouds on May 25, 1810, during the independence revolution.',
      additionalInfoAr: 'تحيي شمس مايو ذكرى ظهور الشمس من بين الغيوم في 25 مايو 1810 خلال ثورة الاستقلال.',
    ),

    // Colombia
    'CO': const FlagMeaning(
      countryCode: 'CO',
      colors: [
        FlagColor(
          color: Color(0xFFFCD116),
          hexCode: '#FCD116',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The gold and abundance of Colombia',
          meaningAr: 'الذهب ووفرة كولومبيا',
        ),
        FlagColor(
          color: Color(0xFF003893),
          hexCode: '#003893',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The two oceans (Pacific and Atlantic) and sky',
          meaningAr: 'المحيطان (الهادئ والأطلسي) والسماء',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed by heroes for independence',
          meaningAr: 'دماء الأبطال من أجل الاستقلال',
        ),
      ],
      additionalInfo: 'Created by Francisco de Miranda, who saw the yellow of wheat, blue of the sea, and red of blood in Europe.',
      additionalInfoAr: 'ابتكره فرانسيسكو دي ميراندا الذي رأى أصفر القمح وأزرق البحر وأحمر الدم في أوروبا.',
    ),

    // Chile
    'CL': const FlagMeaning(
      countryCode: 'CL',
      colors: [
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The snow of the Andes mountains',
          meaningAr: 'ثلوج جبال الأنديز',
        ),
        FlagColor(
          color: Color(0xFF0039A6),
          hexCode: '#0039A6',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The clear Chilean skies and Pacific Ocean',
          meaningAr: 'سماء تشيلي الصافية والمحيط الهادئ',
        ),
        FlagColor(
          color: Color(0xFFD52B1E),
          hexCode: '#D52B1E',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed for independence',
          meaningAr: 'الدماء المراقة من أجل الاستقلال',
        ),
      ],
      additionalInfo: 'Known as "La Estrella Solitaria" (The Lone Star). The star represents the powers of the state: executive, legislative, and judicial.',
      additionalInfoAr: 'يُعرف بـ"النجمة الوحيدة". تمثل النجمة سلطات الدولة: التنفيذية والتشريعية والقضائية.',
    ),

    // Peru
    'PE': const FlagMeaning(
      countryCode: 'PE',
      colors: [
        FlagColor(
          color: Color(0xFFD91023),
          hexCode: '#D91023',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed by heroes for independence',
          meaningAr: 'دماء الأبطال من أجل الاستقلال',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, purity, and dignity',
          meaningAr: 'السلام والنقاء والكرامة',
        ),
      ],
      additionalInfo: 'Legend says liberator José de San Martín saw flamingos flying and was inspired by their red and white colors.',
      additionalInfoAr: 'تقول الأسطورة إن المحرر خوسيه دي سان مارتين رأى طيور الفلامنجو تطير واستلهم من ألوانها الحمراء والبيضاء.',
    ),

    // Venezuela
    'VE': const FlagMeaning(
      countryCode: 'VE',
      colors: [
        FlagColor(
          color: Color(0xFFFCDD09),
          hexCode: '#FCDD09',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The wealth of the nation and the golden sun',
          meaningAr: 'ثروة الأمة والشمس الذهبية',
        ),
        FlagColor(
          color: Color(0xFF003DA5),
          hexCode: '#003DA5',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The seas separating from Spanish rule',
          meaningAr: 'البحار التي فصلت عن الحكم الإسباني',
        ),
        FlagColor(
          color: Color(0xFFD52B1E),
          hexCode: '#D52B1E',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed by heroes in the independence struggle',
          meaningAr: 'دماء الأبطال في نضال الاستقلال',
        ),
      ],
      additionalInfo: 'The eight stars represent the eight provinces that voted for independence. Originally had seven stars; the eighth was added by Hugo Chávez.',
      additionalInfoAr: 'تمثل النجوم الثماني المقاطعات الثماني التي صوتت للاستقلال. كانت سبع نجوم أصلاً؛ أضاف هوغو تشافيز الثامنة.',
    ),

    // Ecuador
    'EC': const FlagMeaning(
      countryCode: 'EC',
      colors: [
        FlagColor(
          color: Color(0xFFFFD100),
          hexCode: '#FFD100',
          name: 'Yellow',
          nameAr: 'أصفر',
          meaningEn: 'The sunshine, grain, and abundance',
          meaningAr: 'أشعة الشمس والحبوب والوفرة',
        ),
        FlagColor(
          color: Color(0xFF0072CE),
          hexCode: '#0072CE',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The ocean and clear skies',
          meaningAr: 'المحيط والسماء الصافية',
        ),
        FlagColor(
          color: Color(0xFFEF3340),
          hexCode: '#EF3340',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of independence heroes',
          meaningAr: 'دماء أبطال الاستقلال',
        ),
      ],
      additionalInfo: 'Ecuador means "equator" - the country is named after the equator line passing through it. The coat of arms shows the condor.',
      additionalInfoAr: 'الإكوادور تعني "خط الاستواء" - سُميت البلاد على اسم خط الاستواء الذي يمر عبرها. يُظهر شعار النبالة طائر الكندور.',
    ),

    // Cuba
    'CU': const FlagMeaning(
      countryCode: 'CU',
      colors: [
        FlagColor(
          color: Color(0xFF002A8F),
          hexCode: '#002A8F',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The three original departments of Cuba',
          meaningAr: 'المقاطعات الثلاث الأصلية لكوبا',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity of the patriotic cause',
          meaningAr: 'نقاء القضية الوطنية',
        ),
        FlagColor(
          color: Color(0xFFCB1515),
          hexCode: '#CB1515',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed in the struggle for independence',
          meaningAr: 'الدماء المراقة في النضال من أجل الاستقلال',
        ),
      ],
      additionalInfo: 'The triangle symbolizes freedom, equality, and fraternity. The lone star is "La Estrella Solitaria" - Cuba\'s independence.',
      additionalInfoAr: 'يرمز المثلث إلى الحرية والمساواة والإخاء. النجمة الوحيدة هي "النجمة المنفردة" - استقلال كوبا.',
    ),

    // Jamaica
    'JM': const FlagMeaning(
      countryCode: 'JM',
      colors: [
        FlagColor(
          color: Color(0xFF009B3A),
          hexCode: '#009B3A',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Hope and agricultural resources',
          meaningAr: 'الأمل والموارد الزراعية',
        ),
        FlagColor(
          color: Color(0xFFFED100),
          hexCode: '#FED100',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'Natural wealth and the sunshine',
          meaningAr: 'الثروة الطبيعية وأشعة الشمس',
        ),
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The strength and creativity of the people',
          meaningAr: 'قوة وإبداع الشعب',
        ),
      ],
      additionalInfo: 'Originally meant "hardships there are, but the land is green and the sun shineth." The saltire (X) is unique among national flags.',
      additionalInfoAr: 'المعنى الأصلي "هناك مشقات، لكن الأرض خضراء والشمس مشرقة". الصليب X فريد بين الأعلام الوطنية.',
    ),

    // Belize
    'BZ': const FlagMeaning(
      countryCode: 'BZ',
      colors: [
        FlagColor(
          color: Color(0xFF171696),
          hexCode: '#171696',
          name: 'Royal Blue',
          nameAr: 'أزرق ملكي',
          meaningEn: 'The People\'s United Party (PUP) and the sea and sky',
          meaningAr: 'حزب الشعب المتحد والبحر والسماء',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The United Democratic Party (UDP) and the blood of patriots',
          meaningAr: 'الحزب الديمقراطي المتحد ودماء الوطنيين',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and purity',
          meaningAr: 'السلام والنقاء',
        ),
        FlagColor(
          color: Color(0xFF009E49),
          hexCode: '#009E49',
          name: 'Green',
          nameAr: 'أخضر',
          meaningEn: 'Forests and natural resources (in the coat of arms)',
          meaningAr: 'الغابات والموارد الطبيعية (في شعار النبالة)',
        ),
      ],
      additionalInfo: 'The coat of arms shows two woodcutters (Mestizo and Creole) representing ethnic unity, a mahogany tree, and the motto "Sub Umbra Floreo" (Under the Shade I Flourish).',
      additionalInfoAr: 'يُظهر شعار النبالة حطابين (مستيزو وكريول) يمثلان الوحدة العرقية، وشجرة الماهوجني، والشعار "تحت الظل أزدهر".',
    ),

    // Guatemala
    'GT': const FlagMeaning(
      countryCode: 'GT',
      colors: [
        FlagColor(
          color: Color(0xFF4997D0),
          hexCode: '#4997D0',
          name: 'Sky Blue',
          nameAr: 'أزرق سماوي',
          meaningEn: 'The Pacific Ocean and Caribbean Sea, justice and perseverance',
          meaningAr: 'المحيط الهادئ والبحر الكاريبي، العدالة والمثابرة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, purity, and the land between the two oceans',
          meaningAr: 'السلام والنقاء والأرض بين المحيطين',
        ),
      ],
      additionalInfo: 'The coat of arms features the quetzal bird (national symbol of freedom), crossed rifles, and a scroll with independence date (15 September 1821).',
      additionalInfoAr: 'يضم شعار النبالة طائر الكيتزال (رمز الحرية الوطني)، وبنادق متقاطعة، ولفيفة بتاريخ الاستقلال (15 سبتمبر 1821).',
    ),

    // Honduras
    'HN': const FlagMeaning(
      countryCode: 'HN',
      colors: [
        FlagColor(
          color: Color(0xFF0073CF),
          hexCode: '#0073CF',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Caribbean Sea and Pacific Ocean, the sky, and brotherhood',
          meaningAr: 'البحر الكاريبي والمحيط الهادئ، والسماء، والأخوة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and prosperity, the land between the seas',
          meaningAr: 'السلام والازدهار، الأرض بين البحرين',
        ),
      ],
      additionalInfo: 'The five stars represent the five original Central American provinces: El Salvador, Costa Rica, Nicaragua, Honduras, and Guatemala.',
      additionalInfoAr: 'تمثل النجوم الخمس المقاطعات الخمس الأصلية لأمريكا الوسطى: السلفادور وكوستاريكا ونيكاراغوا وهندوراس وغواتيمالا.',
    ),

    // El Salvador
    'SV': const FlagMeaning(
      countryCode: 'SV',
      colors: [
        FlagColor(
          color: Color(0xFF0F47AF),
          hexCode: '#0F47AF',
          name: 'Cobalt Blue',
          nameAr: 'أزرق كوبالت',
          meaningEn: 'The sky and the two oceans surrounding Central America',
          meaningAr: 'السماء والمحيطان المحيطان بأمريكا الوسطى',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, solidarity, and harmony',
          meaningAr: 'السلام والتضامن والوئام',
        ),
      ],
      additionalInfo: 'The coat of arms includes five volcanoes (the five nations of Central America), the Cap of Liberty, and the date of independence from Spain.',
      additionalInfoAr: 'يتضمن شعار النبالة خمسة براكين (دول أمريكا الوسطى الخمس)، وقبعة الحرية، وتاريخ الاستقلال عن إسبانيا.',
    ),

    // Nicaragua
    'NI': const FlagMeaning(
      countryCode: 'NI',
      colors: [
        FlagColor(
          color: Color(0xFF0067C6),
          hexCode: '#0067C6',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Pacific Ocean and Caribbean Sea',
          meaningAr: 'المحيط الهادئ والبحر الكاريبي',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and the land between the two bodies of water',
          meaningAr: 'السلام والأرض بين المسطحين المائيين',
        ),
      ],
      additionalInfo: 'The coat of arms shows five volcanoes between two oceans, a rainbow of peace, and a Phrygian cap representing liberty.',
      additionalInfoAr: 'يُظهر شعار النبالة خمسة براكين بين محيطين، وقوس قزح السلام، وقبعة فريجية ترمز للحرية.',
    ),

    // Costa Rica
    'CR': const FlagMeaning(
      countryCode: 'CR',
      colors: [
        FlagColor(
          color: Color(0xFF002B7F),
          hexCode: '#002B7F',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The sky, opportunities, idealism, and perseverance',
          meaningAr: 'السماء والفرص والمثالية والمثابرة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace, wisdom, and happiness',
          meaningAr: 'السلام والحكمة والسعادة',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood shed for freedom and generosity',
          meaningAr: 'الدماء المراقة من أجل الحرية والكرم',
        ),
      ],
      additionalInfo: 'The coat of arms shows three volcanoes, two oceans, a rising sun, and seven stars representing the seven provinces.',
      additionalInfoAr: 'يُظهر شعار النبالة ثلاثة براكين ومحيطين وشمساً مشرقة وسبع نجوم تمثل المقاطعات السبع.',
    ),

    // Panama
    'PA': const FlagMeaning(
      countryCode: 'PA',
      colors: [
        FlagColor(
          color: Color(0xFFDA121A),
          hexCode: '#DA121A',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Liberal Party',
          meaningAr: 'الحزب الليبرالي',
        ),
        FlagColor(
          color: Color(0xFF0073CF),
          hexCode: '#0073CF',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Conservative Party and the surrounding oceans',
          meaningAr: 'الحزب المحافظ والمحيطات المحيطة',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace and purity between the two parties',
          meaningAr: 'السلام والنقاء بين الحزبين',
        ),
      ],
      additionalInfo: 'The blue star represents civic qualities and honesty. The red star represents the authority and law. The flag was designed by the son of Panama\'s first president.',
      additionalInfoAr: 'ترمز النجمة الزرقاء للصفات المدنية والصدق. وترمز النجمة الحمراء للسلطة والقانون. صمم العلم ابن أول رئيس لبنما.',
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // OCEANIA
    // ═══════════════════════════════════════════════════════════════════════

    // Australia
    'AU': const FlagMeaning(
      countryCode: 'AU',
      colors: [
        FlagColor(
          color: Color(0xFF00008B),
          hexCode: '#00008B',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The ocean and sky surrounding Australia',
          meaningAr: 'المحيط والسماء المحيطين بأستراليا',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The Southern Cross constellation and peace',
          meaningAr: 'كوكبة الصليب الجنوبي والسلام',
        ),
        FlagColor(
          color: Color(0xFFFF0000),
          hexCode: '#FF0000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Union Jack (British heritage)',
          meaningAr: 'علم الاتحاد (التراث البريطاني)',
        ),
      ],
      additionalInfo: 'The Commonwealth Star (7 points) represents the 6 states and territories. The Southern Cross is visible from all of Australia.',
      additionalInfoAr: 'نجمة الكومنولث (7 نقاط) تمثل الولايات والأقاليم الست. الصليب الجنوبي مرئي من كل أستراليا.',
    ),

    // New Zealand
    'NZ': const FlagMeaning(
      countryCode: 'NZ',
      colors: [
        FlagColor(
          color: Color(0xFF00247D),
          hexCode: '#00247D',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'The Pacific Ocean and the clear New Zealand sky',
          meaningAr: 'المحيط الهادئ وسماء نيوزيلندا الصافية',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'The long white cloud (Aotearoa)',
          meaningAr: 'السحابة البيضاء الطويلة (أوتياروا)',
        ),
        FlagColor(
          color: Color(0xFFCC142B),
          hexCode: '#CC142B',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The Southern Cross stars and British heritage',
          meaningAr: 'نجوم الصليب الجنوبي والتراث البريطاني',
        ),
      ],
      additionalInfo: 'New Zealand\'s Māori name "Aotearoa" means "Land of the Long White Cloud." The four stars represent the Southern Cross.',
      additionalInfoAr: 'اسم الماوري لنيوزيلندا "أوتياروا" يعني "أرض السحابة البيضاء الطويلة". النجوم الأربع تمثل الصليب الجنوبي.',
    ),

    // Fiji
    'FJ': const FlagMeaning(
      countryCode: 'FJ',
      colors: [
        FlagColor(
          color: Color(0xFF68BFE5),
          hexCode: '#68BFE5',
          name: 'Light Blue',
          nameAr: 'أزرق فاتح',
          meaningEn: 'The Pacific Ocean surrounding Fiji',
          meaningAr: 'المحيط الهادئ المحيط بفيجي',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Peace',
          meaningAr: 'السلام',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'British heritage and the Union Jack',
          meaningAr: 'التراث البريطاني وعلم الاتحاد',
        ),
      ],
      additionalInfo: 'The coat of arms shows a lion holding a cocoa pod, sugarcane, coconut palm, banana, and a dove of peace.',
      additionalInfoAr: 'يُظهر شعار النبالة أسداً يحمل حبة كاكاو وقصب السكر ونخيل جوز الهند وموزاً وحمامة السلام.',
    ),

    // Papua New Guinea
    'PG': const FlagMeaning(
      countryCode: 'PG',
      colors: [
        FlagColor(
          color: Color(0xFF000000),
          hexCode: '#000000',
          name: 'Black',
          nameAr: 'أسود',
          meaningEn: 'The people of Papua New Guinea',
          meaningAr: 'شعب بابوا غينيا الجديدة',
        ),
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Traditional colors of many local tribes',
          meaningAr: 'الألوان التقليدية للعديد من القبائل المحلية',
        ),
        FlagColor(
          color: Color(0xFFFFD100),
          hexCode: '#FFD100',
          name: 'Gold',
          nameAr: 'ذهبي',
          meaningEn: 'The Southern Cross and the bird of paradise',
          meaningAr: 'الصليب الجنوبي وطائر الجنة',
        ),
      ],
      additionalInfo: 'The raggiana bird-of-paradise is the national bird. The Southern Cross represents the geographic location in the southern hemisphere.',
      additionalInfoAr: 'طائر الجنة راجيانا هو الطائر الوطني. يمثل الصليب الجنوبي الموقع الجغرافي في نصف الكرة الجنوبي.',
    ),

    // Samoa
    'WS': const FlagMeaning(
      countryCode: 'WS',
      colors: [
        FlagColor(
          color: Color(0xFFCE1126),
          hexCode: '#CE1126',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'Courage',
          meaningAr: 'الشجاعة',
        ),
        FlagColor(
          color: Color(0xFF002B7F),
          hexCode: '#002B7F',
          name: 'Blue',
          nameAr: 'أزرق',
          meaningEn: 'Freedom and the Pacific Ocean',
          meaningAr: 'الحرية والمحيط الهادئ',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and the Southern Cross stars',
          meaningAr: 'النقاء ونجوم الصليب الجنوبي',
        ),
      ],
      additionalInfo: 'The five stars represent the Southern Cross constellation. Samoa was the first Pacific island nation to gain independence in the 20th century.',
      additionalInfoAr: 'تمثل النجوم الخمس كوكبة الصليب الجنوبي. كانت ساموا أول دولة جزيرة في المحيط الهادئ تنال الاستقلال في القرن العشرين.',
    ),

    // Tonga
    'TO': const FlagMeaning(
      countryCode: 'TO',
      colors: [
        FlagColor(
          color: Color(0xFFC10000),
          hexCode: '#C10000',
          name: 'Red',
          nameAr: 'أحمر',
          meaningEn: 'The blood of Christ',
          meaningAr: 'دم المسيح',
        ),
        FlagColor(
          color: Color(0xFFFFFFFF),
          hexCode: '#FFFFFF',
          name: 'White',
          nameAr: 'أبيض',
          meaningEn: 'Purity and Christianity',
          meaningAr: 'النقاء والمسيحية',
        ),
      ],
      additionalInfo: 'Tonga is one of the most Christian nations in the world. The flag has remained unchanged since 1875.',
      additionalInfoAr: 'تونغا من أكثر الدول المسيحية في العالم. ظل العلم دون تغيير منذ 1875.',
    ),
  };

  /// Get flag meaning for a country by code
  static FlagMeaning? getMeaning(String countryCode) {
    return _meanings[countryCode.toUpperCase()];
  }

  /// Check if flag meaning exists for a country
  static bool hasMeaning(String countryCode) {
    return _meanings.containsKey(countryCode.toUpperCase());
  }

  /// Get total number of countries with flag meanings
  static int get totalCountries => _meanings.length;

  /// Get all country codes with flag meanings
  static List<String> get allCountryCodes => _meanings.keys.toList();
}
