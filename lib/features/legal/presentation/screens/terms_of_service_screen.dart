import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Terms of Service screen with professional legal content
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsOfService,
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
            _buildSection(
              title: isArabic ? '1. قبول الشروط' : '1. Acceptance of Terms',
              content: isArabic
                  ? 'باستخدام تطبيق أطلس العالم ("التطبيق")، فإنك توافق على الالتزام بشروط الخدمة هذه. إذا كنت لا توافق على أي جزء من هذه الشروط، يُرجى عدم استخدام التطبيق.'
                  : 'By using the GeoMaster application ("App"), you agree to be bound by these Terms of Service. If you do not agree to any part of these terms, please do not use the App.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '2. وصف الخدمة' : '2. Description of Service',
              content: isArabic
                  ? 'أطلس العالم هو تطبيق تعليمي للجغرافيا يوفر:\n• اختبارات تفاعلية عن الدول والعواصم والأعلام\n• معلم ذكاء اصطناعي للمساعدة في التعلم\n• نظام إنجازات ومكافآت\n• محتوى تعليمي شامل عن دول العالم'
                  : 'GeoMaster is a geography learning application that provides:\n• Interactive quizzes about countries, capitals, and flags\n• AI tutor for learning assistance\n• Achievement and reward system\n• Comprehensive educational content about world countries',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '3. حسابات المستخدمين' : '3. User Accounts',
              content: isArabic
                  ? 'يمكنك استخدام التطبيق كضيف أو إنشاء حساب. عند إنشاء حساب:\n• يجب تقديم معلومات دقيقة وكاملة\n• أنت مسؤول عن الحفاظ على سرية حسابك\n• يجب إخطارنا فوراً بأي استخدام غير مصرح به'
                  : 'You may use the App as a guest or create an account. When creating an account:\n• You must provide accurate and complete information\n• You are responsible for maintaining the confidentiality of your account\n• You must notify us immediately of any unauthorized use',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '4. الاشتراكات والدفع' : '4. Subscriptions and Payment',
              content: isArabic
                  ? 'يقدم التطبيق ميزات مجانية ومدفوعة:\n• الميزات الأساسية متاحة مجاناً\n• الاشتراكات المميزة تفتح ميزات إضافية\n• يتم تجديد الاشتراكات تلقائياً ما لم يتم إلغاؤها\n• يمكن إدارة الاشتراكات من خلال متجر التطبيقات'
                  : 'The App offers both free and premium features:\n• Basic features are available for free\n• Premium subscriptions unlock additional features\n• Subscriptions auto-renew unless cancelled\n• Subscriptions can be managed through the app store',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '5. الملكية الفكرية' : '5. Intellectual Property',
              content: isArabic
                  ? 'جميع المحتويات في التطبيق، بما في ذلك النصوص والصور والرسومات والشعارات، هي ملك لنا أو لمرخصينا ومحمية بموجب قوانين حقوق النشر والعلامات التجارية.'
                  : 'All content in the App, including text, images, graphics, and logos, is owned by us or our licensors and is protected by copyright and trademark laws.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '6. السلوك المحظور' : '6. Prohibited Conduct',
              content: isArabic
                  ? 'يُحظر عليك:\n• استخدام التطبيق لأي غرض غير قانوني\n• محاولة الوصول غير المصرح به إلى أنظمتنا\n• نقل أي فيروسات أو برامج ضارة\n• انتهاك حقوق الملكية الفكرية'
                  : 'You are prohibited from:\n• Using the App for any unlawful purpose\n• Attempting unauthorized access to our systems\n• Transmitting any viruses or malicious software\n• Violating intellectual property rights',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '7. إخلاء المسؤولية' : '7. Disclaimer',
              content: isArabic
                  ? 'يتم توفير التطبيق "كما هو" دون أي ضمانات. لا نضمن أن التطبيق سيكون خالياً من الأخطاء أو متاحاً دائماً. المحتوى التعليمي للأغراض المعلوماتية فقط.'
                  : 'The App is provided "as is" without any warranties. We do not guarantee that the App will be error-free or always available. Educational content is for informational purposes only.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '8. تحديد المسؤولية' : '8. Limitation of Liability',
              content: isArabic
                  ? 'لن نكون مسؤولين عن أي أضرار غير مباشرة أو عرضية أو خاصة أو تبعية ناتجة عن استخدامك للتطبيق.'
                  : 'We shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '9. التعديلات' : '9. Modifications',
              content: isArabic
                  ? 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية. استمرارك في استخدام التطبيق يعني قبولك للشروط المعدلة.'
                  : 'We reserve the right to modify these terms at any time. You will be notified of any material changes. Your continued use of the App constitutes acceptance of the modified terms.',
              isArabic: isArabic,
              theme: theme,
            ),
            _buildSection(
              title: isArabic ? '10. الاتصال بنا' : '10. Contact Us',
              content: isArabic
                  ? 'إذا كان لديك أي أسئلة حول شروط الخدمة هذه، يُرجى التواصل معنا عبر:\nالبريد الإلكتروني: support@geomaster.app'
                  : 'If you have any questions about these Terms of Service, please contact us at:\nEmail: support@geomaster.app',
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
