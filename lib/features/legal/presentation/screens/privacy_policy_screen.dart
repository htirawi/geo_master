import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Privacy Policy screen with professional GDPR-compliant content
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicy,
          style: isArabic
              ? GoogleFonts.cairo(fontWeight: FontWeight.w600)
              : GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(isArabic),
            const SizedBox(height: 24),
            _buildIntro(isArabic, theme),
            _buildSection(
              title: isArabic ? '1. المعلومات التي نجمعها' : '1. Information We Collect',
              content: isArabic
                  ? 'نجمع المعلومات التالية:\n\n• معلومات الحساب: الاسم، البريد الإلكتروني عند التسجيل\n• بيانات الاستخدام: تقدمك في التعلم، نتائج الاختبارات، الإنجازات\n• معلومات الجهاز: نوع الجهاز، نظام التشغيل، معرف الجهاز\n• بيانات التحليلات: كيفية استخدامك للتطبيق لتحسين تجربتك'
                  : 'We collect the following information:\n\n• Account Information: Name, email when you register\n• Usage Data: Your learning progress, quiz results, achievements\n• Device Information: Device type, operating system, device identifier\n• Analytics Data: How you use the App to improve your experience',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '2. كيف نستخدم معلوماتك' : '2. How We Use Your Information',
              content: isArabic
                  ? 'نستخدم معلوماتك لـ:\n\n• توفير وتحسين خدماتنا\n• تخصيص تجربة التعلم الخاصة بك\n• إرسال إشعارات مهمة حول حسابك\n• تحليل أنماط الاستخدام لتحسين التطبيق\n• منع الاحتيال وضمان الأمان'
                  : 'We use your information to:\n\n• Provide and improve our services\n• Personalize your learning experience\n• Send important notifications about your account\n• Analyze usage patterns to enhance the App\n• Prevent fraud and ensure security',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '3. مشاركة البيانات' : '3. Data Sharing',
              content: isArabic
                  ? 'لا نبيع معلوماتك الشخصية. قد نشارك البيانات مع:\n\n• مزودي الخدمات: مثل Firebase لتخزين البيانات والمصادقة\n• شركاء التحليلات: لفهم استخدام التطبيق (بيانات مجهولة الهوية)\n• السلطات القانونية: عند الطلب بموجب القانون'
                  : 'We do not sell your personal information. We may share data with:\n\n• Service Providers: Such as Firebase for data storage and authentication\n• Analytics Partners: To understand App usage (anonymized data)\n• Legal Authorities: When required by law',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '4. أمان البيانات' : '4. Data Security',
              content: isArabic
                  ? 'نحن ملتزمون بحماية بياناتك:\n\n• نستخدم التشفير لحماية البيانات أثناء النقل والتخزين\n• نطبق ضوابط وصول صارمة\n• نجري مراجعات أمنية منتظمة\n• نخزن البيانات على خوادم آمنة'
                  : 'We are committed to protecting your data:\n\n• We use encryption to protect data in transit and at rest\n• We implement strict access controls\n• We conduct regular security reviews\n• We store data on secure servers',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '5. حقوقك (GDPR)' : '5. Your Rights (GDPR)',
              content: isArabic
                  ? 'لديك الحقوق التالية:\n\n• الوصول: طلب نسخة من بياناتك الشخصية\n• التصحيح: تصحيح أي معلومات غير دقيقة\n• الحذف: طلب حذف بياناتك ("الحق في النسيان")\n• النقل: الحصول على بياناتك بتنسيق قابل للنقل\n• الاعتراض: الاعتراض على معالجة معينة للبيانات\n• سحب الموافقة: في أي وقت'
                  : 'You have the following rights:\n\n• Access: Request a copy of your personal data\n• Rectification: Correct any inaccurate information\n• Erasure: Request deletion of your data ("Right to be Forgotten")\n• Portability: Receive your data in a portable format\n• Object: Object to certain data processing\n• Withdraw Consent: At any time',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '6. الاحتفاظ بالبيانات' : '6. Data Retention',
              content: isArabic
                  ? 'نحتفظ ببياناتك طالما لديك حساب نشط. عند حذف حسابك:\n\n• يتم حذف البيانات الشخصية خلال 30 يوماً\n• قد نحتفظ ببيانات مجهولة الهوية للتحليلات\n• قد نحتفظ ببعض البيانات للامتثال القانوني'
                  : 'We retain your data as long as you have an active account. When you delete your account:\n\n• Personal data is deleted within 30 days\n• We may retain anonymized data for analytics\n• We may retain some data for legal compliance',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '7. خصوصية الأطفال' : '7. Children\'s Privacy',
              content: isArabic
                  ? 'تطبيقنا مناسب لجميع الأعمار. للمستخدمين تحت 16 عاماً:\n\n• نحصل على موافقة الوالدين عند الضرورة\n• نجمع الحد الأدنى من البيانات المطلوبة\n• لا نعرض إعلانات مستهدفة للأطفال'
                  : 'Our App is suitable for all ages. For users under 16:\n\n• We obtain parental consent when necessary\n• We collect minimal required data\n• We do not show targeted ads to children',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '8. ملفات تعريف الارتباط والتتبع' : '8. Cookies and Tracking',
              content: isArabic
                  ? 'نستخدم تقنيات التتبع لـ:\n\n• تذكر تفضيلاتك\n• تحليل استخدام التطبيق\n• تحسين أداء التطبيق\n\nيمكنك التحكم في هذه الإعدادات من إعدادات جهازك.'
                  : 'We use tracking technologies to:\n\n• Remember your preferences\n• Analyze App usage\n• Improve App performance\n\nYou can control these settings from your device settings.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '9. التحويلات الدولية' : '9. International Transfers',
              content: isArabic
                  ? 'قد يتم نقل بياناتك ومعالجتها في دول خارج بلد إقامتك. نضمن حماية بياناتك وفقاً لمعايير حماية البيانات الدولية.'
                  : 'Your data may be transferred to and processed in countries outside your country of residence. We ensure your data is protected according to international data protection standards.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '10. التغييرات على هذه السياسة' : '10. Changes to This Policy',
              content: isArabic
                  ? 'قد نقوم بتحديث سياسة الخصوصية هذه. سنخطرك بأي تغييرات جوهرية عبر:\n\n• إشعار داخل التطبيق\n• البريد الإلكتروني (إذا كان لديك حساب)\n\nيُعتبر استمرارك في استخدام التطبيق موافقة على التغييرات.'
                  : 'We may update this Privacy Policy. We will notify you of any material changes via:\n\n• In-app notification\n• Email (if you have an account)\n\nYour continued use of the App constitutes acceptance of the changes.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '11. اتصل بنا' : '11. Contact Us',
              content: isArabic
                  ? 'لأي استفسارات تتعلق بالخصوصية:\n\nالبريد الإلكتروني: privacy@geomaster.app\n\nمسؤول حماية البيانات:\ndpo@geomaster.app'
                  : 'For any privacy-related inquiries:\n\nEmail: privacy@geomaster.app\n\nData Protection Officer:\ndpo@geomaster.app',
              isArabic: isArabic,
              theme: theme,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.update, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'آخر تحديث: يناير 2026' : 'Last updated: January 2026',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : GoogleFonts.poppins().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(bool isArabic, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.tertiary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic
                    ? 'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك.'
                    : 'We respect your privacy and are committed to protecting your personal data. This policy explains how we collect, use, and protect your information.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondaryLight,
                      )
                    : GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondaryLight,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isArabic,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  )
                : GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: isArabic
                ? GoogleFonts.cairo(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textSecondaryLight,
                  )
                : GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textSecondaryLight,
                  ),
          ),
        ],
      ),
    );
  }
}
