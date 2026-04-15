import 'package:flutter/material.dart';

class SamsUiTokens {
  static const Color primary = Color(0xFF063454);
  static const Color brandBlue = Color(0xFF0A4D78);
  static const Color secondary = Color(0xFF1E88E5);
  static const Color accent = Color(0xFF0AA7A7);

  static const Color success = Color(0xFF0E8F54);
  static const Color warning = Color(0xFFB7791F);
  static const Color danger = Color(0xFFC0352B);

  static const Color background = Color(0xFFF5F8FC);
  static const Color scaffoldBackground = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFD9E1EA);

  static const double pageHPadding = 16;
  static const double sectionGap = 20;
  static const double cardGap = 14;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;

  static const double buttonHeight = 50;
  static const double navBarHeight = 68;
  static const double navBarCompactHeight = 64;
  static const double navTopRadius = 22;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double contentMaxWidth = 1180;

  static const Duration fastAnimation = Duration(milliseconds: 180);
  static const Duration pageAnimation = Duration(milliseconds: 280);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14091C2B), blurRadius: 14, offset: Offset(0, 5)),
  ];

  static bool isCompactWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static bool isDesktopWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  static bool isTabletWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static double horizontalPagePadding(
    BuildContext context, {
    double regular = pageHPadding,
    double compact = 12,
  }) {
    return isCompactWidth(context) ? compact : regular;
  }

  static EdgeInsets pageInsets(
    BuildContext context, {
    double top = 16,
    double bottom = 24,
    double regularHorizontal = pageHPadding,
    double compactHorizontal = 12,
  }) {
    final horizontal = horizontalPagePadding(
      context,
      regular: regularHorizontal,
      compact: compactHorizontal,
    );

    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}

extension SamsLocalizationContext on BuildContext {
  bool get isArabicLocale => Localizations.localeOf(this).languageCode == 'ar';

  String tr(String input) {
    return SamsLocalizer.translate(input, isArabic: isArabicLocale);
  }
}

class SamsLocaleText extends StatelessWidget {
  const SamsLocaleText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr(data),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel == null
          ? null
          : context.tr(semanticsLabel!),
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

class SamsLocalizer {
  SamsLocalizer._();

  static final RegExp _latinWordRegex = RegExp(r'[A-Za-z]');
  static final RegExp _tokenRegex = RegExp(r"[A-Za-z0-9@._'-]+");
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+$',
  );

  static const Map<String, String> _exactPhrases = {
    'SAMS Home': 'الرئيسية - سامز',
    'SAMS Student Portal': 'بوابة طلاب سامز',
    'SAMS Student Portal • v1.0.0': 'بوابة طلاب سامز • الإصدار 1.0.0',
    'SAMS Student App • Version 1.0': 'تطبيق طلاب سامز • الإصدار 1.0',
    'Welcome back': 'أهلا بيك من تاني',
    'Choose a quick QR sign-in or continue manually.':
        'ادخل بسرعة بكود QR أو كمّل تسجيل يدوي.',
    'Sign-in with QR code': 'سجّل الدخول بكود QR',
    'or': 'أو',
    'Hide manual login': 'اخفي التسجيل اليدوي',
    'Login manually': 'سجّل يدوي',
    'Roll no.': 'رقم الجلوس',
    'Password': 'كلمة المرور',
    'New Password': 'كلمة المرور الجديدة',
    'Current Password': 'كلمة المرور الحالية',
    'Confirm New Password': 'تأكيد كلمة المرور الجديدة',
    'Confirm Password': 'تأكيد كلمة المرور',
    'Continue': 'كمّل',
    'New here? Create an account': 'أول مرة هنا؟ اعمل حساب جديد',
    'Welcome.': 'أهلا بيك.',
    'Create your SAMS account to continue.': 'اعمل حساب سامز عشان تكمل.',
    'Name': 'الاسم',
    'Email': 'البريد الإلكتروني',
    'I agree to the Terms and Conditions': 'أنا موافق على الشروط والأحكام',
    'Sign up': 'إنشاء حساب',
    'Already have an account? Login': 'عندك حساب بالفعل؟ سجّل دخول',
    'Sadat Academy for\nManagement Sciences':
        'أكاديمية السادات\nللعلوم الإدارية',
    'Home': 'الرئيسية',
    'Messages': 'الرسائل',
    'Scan': 'المسح',
    'Help Desk': 'الدعم',
    'Menu': 'القائمة',
    'Profile': 'حسابي',
    'Settings': 'الإعدادات',
    'Session': 'الفصل الدراسي',
    'Change Password': 'تغيير كلمة المرور',
    'Privacy policy': 'سياسة الخصوصية',
    'Privacy Policy': 'سياسة الخصوصية',
    'Terms & Conditions': 'الشروط والأحكام',
    'About App': 'عن التطبيق',
    'App version': 'إصدار التطبيق',
    'Appearance': 'المظهر',
    'Language': 'اللغة',
    'Notifications': 'الإشعارات',
    'Privacy & Security': 'الخصوصية والأمان',
    'Dark Mode': 'الوضع الليلي',
    'App Language': 'لغة التطبيق',
    'English': 'الإنجليزية',
    'Arabic': 'العربية',
    'Push alerts': 'تنبيهات فورية',
    'Email updates': 'تحديثات البريد',
    'Assignment reminders': 'تذكير الواجبات',
    'Quiet hours': 'ساعات الهدوء',
    'Smart Settings': 'إعدادات ذكية',
    'Look and feel of your SAMS app experience.':
        'اختار الشكل المناسب لتجربتك في تطبيق سامز.',
    'Choose your preferred app language.': 'اختار اللغة اللي تفضلها للتطبيق.',
    'Choose the display language for the app interface.':
        'اختار لغة عرض التطبيق.',
    'Control alerts and update reminders.':
        'تحكم في التنبيهات وتذكيرات التحديثات.',
    'Receive instant notices for attendance and announcements.':
        'استقبل تنبيهات فورية للحضور والإعلانات.',
    'Receive periodic summaries and account updates by email.':
        'استقبل ملخصات دورية وتحديثات الحساب على البريد.',
    'Get reminders before deadlines and upcoming class tasks.':
        'خد تذكير قبل المواعيد النهائية والمهام الجاية.',
    'Pause non-critical notifications during study/sleep time.':
        'وقف التنبيهات غير المهمة وقت المذاكرة أو النوم.',
    'Manage visibility, sharing, and data preferences.':
        'تحكم في الظهور والمشاركة وإعدادات البيانات.',
    'Show profile photo to classmates': 'إظهار صورة البروفايل للزملاء',
    'Controls visibility of your avatar in student directory.':
        'بتتحكم في ظهور صورتك داخل دليل الطلبة.',
    'Show contact information': 'إظهار بيانات التواصل',
    'Allow classmates to see your registered contact details.':
        'اسمح لزمايلك يشوفوا بيانات التواصل المسجلة.',
    'Share data with campus services': 'مشاركة البيانات مع خدمات الجامعة',
    'Used to personalize student features and recommendations.':
        'بيُستخدم لتخصيص المزايا والتوصيات ليك.',
    'Allow anonymous analytics': 'السماح بتحليلات مجهولة',
    'Help improve the SAMS app experience and performance.':
        'ده بيساعدنا نحسّن تجربة التطبيق والأداء.',
    'Version info, legal pages, and app details.':
        'معلومات الإصدار والصفحات القانونية وتفاصيل التطبيق.',
    'Review student platform terms and usage policy.':
        'راجع شروط استخدام المنصة وسياساتها.',
    'See how your data is handled and protected.':
        'اعرف بياناتك بتتجمع وتتأمن إزاي.',
    'Language switched to': 'تم تغيير اللغة إلى',
    'Dark Mode enabled.': 'تم تفعيل الوضع الليلي.',
    'Light Mode enabled.': 'تم تفعيل الوضع الفاتح.',
    'Loading profile': 'جاري تحميل الملف الشخصي',
    'Fetching your account details and settings...':
        'بنجيب بيانات حسابك وإعداداتك...',
    "Couldn't load profile": 'ماقدرناش نحمّل ملفك الشخصي',
    'Failed to load profile. Please try again.':
        'حصلت مشكلة في تحميل الملف الشخصي. جرّب تاني.',
    'Confirm switch': 'تأكيد التحويل',
    'Cancel': 'إلغاء',
    'Switch': 'تحويل',
    'Appearance, language, notifications and security':
        'المظهر واللغة والإشعارات والأمان',
    'Track route, stops and live bus status':
        'تابع خط السير والمحطات وحالة الأتوبيس لحظة بلحظة',
    'Access gate pass, allotment and receipts':
        'وصول سريع لإذن الخروج والتسكين والإيصالات',
    'Last changed 2 months ago': 'آخر تغيير من شهرين',
    'Loading your dashboard': 'جاري تحميل الصفحة الرئيسية',
    'Fetching attendance, bus status and announcements...':
        'بنجهز الحضور وحالة الأتوبيس والإعلانات...',
    "Couldn't load home dashboard": 'ماقدرناش نحمّل الصفحة الرئيسية',
    'Failed to load home dashboard. Please try again.':
        'حصلت مشكلة في تحميل الصفحة الرئيسية. جرّب تاني.',
    'Daily Essentials': 'أهم حاجاتك اليوم',
    'Announcements': 'الإعلانات',
    'Schedule': 'الجدول',
    'Mark Today\'s Attendance': 'سجّل حضور النهاردة',
    'No announcements yet': 'مفيش إعلانات لسه',
    'You are all caught up. New updates from SAMS will appear here.':
        'أنت متابع كل الجديد. أي تحديث جديد من سامز هيظهر هنا.',
    'Refresh Updates': 'تحديث',
    'Attendance': 'الحضور',
    'Class-wise Attendance': 'الحضور حسب كل مادة',
    'Overall Attendance': 'إجمالي الحضور',
    'Attendance Color Guide': 'دليل ألوان الحضور',
    'Safe Zone (≥ 80%)': 'منطقة الأمان (80% أو أكتر)',
    'Watch Zone (60–79%)': 'منطقة المراقبة (من 60% لـ 79%)',
    'Critical Zone (< 60%)': 'منطقة الخطر (أقل من 60%)',
    'Mark Attendance': 'تسجيل الحضور',
    'Loading your attendance...': 'جاري تحميل بيانات الحضور...',
    'Preparing overall and class-wise attendance for you...':
        'بنجهزلك إجمالي الحضور وتفاصيل كل مادة...',
    "Couldn't load attendance": 'ماقدرناش نحمّل بيانات الحضور',
    'Failed to load attendance. Please try again.':
        'حصلت مشكلة في تحميل الحضور. جرّب تاني.',
    'Bus Tracking': 'تتبع الأتوبيس',
    'Live Route': 'خط السير المباشر',
    "Couldn't load bus tracking": 'ماقدرناش نحمّل تتبع الأتوبيس',
    'Failed to load bus tracking. Please try again.':
        'حصلت مشكلة في تحميل تتبع الأتوبيس. جرّب تاني.',
    'Loading your bus tracking...': 'جاري تحميل تتبع الأتوبيس...',
    'Syncing live bus location, route stops, and ETA...':
        'بنحدّث موقع الأتوبيس والمحطات ووقت الوصول...',
    'No bus updates currently. Pull to refresh.':
        'مفيش تحديثات للأتوبيس دلوقتي. اسحب للتحديث.',
    'Today\'s route complete. Next trip schedule will appear soon.':
        'رحلة النهاردة خلصت. مواعيد الرحلة الجاية هتظهر قريب.',
    'Retry': 'حاول تاني',
    'Check Again': 'إعادة المحاولة',
    "Couldn't load help desk": 'ماقدرناش نحمّل صفحة الدعم',
    'Failed to load help desk requests. Please try again.':
        'حصلت مشكلة في تحميل طلبات الدعم. جرّب تاني.',
    'No complaints right now': 'مفيش شكاوى حاليًا',
    'Great! You have no active concerns at the moment.':
        'ممتاز! مفيش أي شكاوى مفتوحة دلوقتي.',
    'Raise a complaint': 'قدّم شكوى',
    'Loading your concerns...': 'جاري تحميل شكاواك...',
    'Fetching your latest complaints and help desk updates...':
        'بنجيب آخر الشكاوى وتحديثات الدعم...',
    'Submitting your concern...': 'جاري إرسال شكوتك...',
    'Raise your Concern': 'قدّم شكوتك',
    'Concerned Department': 'الجهة المعنية',
    'Estimated response: within 24 hours': 'الرد المتوقع: خلال 24 ساعة',
    'Your Concern': 'موضوع الشكوى',
    'Describe your issue here...': 'اكتب تفاصيل مشكلتك هنا...',
    'Please select department and enter your concern.':
        'من فضلك اختار الجهة واكتب شكوتك.',
    'Concern submitted successfully': 'تم إرسال الشكوى بنجاح',
    "Couldn't load messages": 'ماقدرناش نحمّل الرسائل',
    'Failed to load messages. Please try again.':
        'حصلت مشكلة في تحميل الرسائل. جرّب تاني.',
    'Loading your messages...': 'جاري تحميل الرسائل...',
    'Preparing your inbox and latest conversation previews...':
        'بنجهز صندوق الرسائل وآخر المحادثات...',
    'No messages yet': 'مفيش رسائل لسه',
    'Your updates and messages from SAMS will appear here.':
        'كل الرسائل والتحديثات من سامز هتظهر هنا.',
    'Search messages': 'ابحث في الرسائل',
    'Search friends or messages': 'ابحث عن أصحابك أو في الرسائل',
    'Friends & Faculty': 'أصحابك وهيئة التدريس',
    'Search your friends, open chats, and stay connected in real time.':
        'دوّر على أصحابك، افتح الشات، وخليك متابع لحظة بلحظة.',
    'Start chatting': 'ابدأ محادثة',
    'No friends found': 'مفيش نتائج',
    'Try another name or keyword.': 'جرّب اسم أو كلمة تانية.',
    'Type a message...': 'اكتب رسالة...',
    'Online': 'متصل الآن',
    'Last seen': 'آخر ظهور',
    'Now': 'الآن',
    'Yesterday': 'أمس',
    '5m ago': 'من 5 دقايق',
    '12m ago': 'من 12 دقيقة',
    '1h ago': 'من ساعة',
    '3h ago': 'من 3 ساعات',
    'Scan QR Code': 'امسح كود QR',
    'Scan successful': 'تم المسح بنجاح',
    'Your request has been verified by SAMS services.':
        'تم التحقق من طلبك بنجاح من خدمات سامز.',
    'Scan again': 'امسح مرة تانية',
    'Done': 'تم',
    'Preparing scanner': 'جاري تجهيز الماسح',
    'Getting your camera and gallery options ready...':
        'بنجهز خيارات الكاميرا والمعرض...',
    "Couldn't open scanner": 'ماقدرناش نفتح الماسح',
    'Failed to open scanner. Please try again.':
        'حصلت مشكلة في فتح الماسح. جرّب تاني.',
    'Choose from gallery': 'اختار من المعرض',
    'Use camera': 'استخدم الكاميرا',
    'Scanning in progress...': 'جاري المسح...',
    'Scanning...': 'بيتم المسح...',
    'Please hold still while we verify your code.':
        'من فضلك اثبت لحظة لحد ما نتحقق من الكود.',
    'SAMS Hostel': 'سكن سامز',
    "Couldn't load hostel services": 'ماقدرناش نحمّل خدمات السكن',
    'Failed to load hostel services. Please try again.':
        'حصلت مشكلة في تحميل خدمات السكن. جرّب تاني.',
    'Loading hostel services': 'جاري تحميل خدمات السكن',
    'Preparing your gate pass, receipts and allotment options...':
        'بنجهز إذن الخروج والإيصالات وخيارات التسكين...',
    'Hostel services & requests': 'خدمات وطلبات السكن',
    'Leave Permission': 'إذن الخروج',
    'Fee Receipt': 'إيصال الرسوم',
    'Mess Feedback': 'تقييم المطعم',
    'Maintenance Request': 'طلب صيانة',
    'Request weekend leave and in/out movement approvals':
        'طلب خروج نهاية الأسبوع وموافقات الدخول والخروج',
    'View and download tuition and hostel payment receipts':
        'عرض وتنزيل إيصالات مصروفات الدراسة والسكن',
    'Submit daily meal quality, variety, and hygiene feedback':
        'إرسال تقييم يومي لجودة الأكل والتنوع والنظافة',
    'Report AC, plumbing, electrical, or furniture issues':
        'الإبلاغ عن مشاكل التكييف أو السباكة أو الكهرباء أو الأثاث',
    'Current Hostel Status': 'حالة السكن الحالية',
    'Room B-214 • Floor 2\nLast pass approved on 10 Apr 2026':
        'الغرفة B-214 • الدور الثاني\nآخر إذن خروج اتوافق عليه يوم 10 أبريل 2026',
    'Pass type': 'نوع الإذن',
    'Weekend': 'ويك إند',
    'Emergency': 'طارئ',
    'Academic': 'دراسي',
    'Leave date': 'تاريخ الخروج',
    'Return date': 'تاريخ الرجوع',
    'Select leave date': 'اختار تاريخ الخروج',
    'Select return date': 'اختار تاريخ الرجوع',
    'Guardian contact': 'رقم ولي الأمر',
    'Reason': 'السبب',
    'Briefly explain your leave request...': 'اكتب سبب طلب الإذن باختصار...',
    'Approval flow': 'مسار الموافقة',
    'Request created': 'تم إنشاء الطلب',
    'Hostel Warden review': 'مراجعة مشرف السكن',
    'Gate office validation': 'اعتماد مكتب البوابة',
    'Final check before departure': 'مراجعة أخيرة قبل الخروج',
    'Please fill reason and guardian contact before submitting.':
        'من فضلك اكتب السبب ورقم ولي الأمر قبل الإرسال.',
    'Leave permission request submitted to Hostel Warden.':
        'تم إرسال طلب الإذن لمشرف السكن.',
    'Submit leave request': 'إرسال طلب الإذن',
    'Payment summary': 'ملخص الدفع',
    'Academic Year 2025/2026\nTotal paid: EGP 8,500 • Outstanding: EGP 4,250':
        'السنة الدراسية 2025/2026\nإجمالي المدفوع: 8,500 جنيه • المتبقي: 4,250 جنيه',
    'Available receipts': 'الإيصالات المتاحة',
    'Hostel Fee - April 2026': 'رسوم السكن - أبريل 2026',
    'Hostel Fee - March 2026': 'رسوم السكن - مارس 2026',
    'Hostel Fee - February 2026': 'رسوم السكن - فبراير 2026',
    'Paid': 'مدفوع',
    'Due': 'مستحق',
    'Awaiting payment': 'في انتظار السداد',
    'Pending due 20 Apr 2026': 'مستحق السداد يوم 20 أبريل 2026',
    'Bank transfer': 'تحويل بنكي',
    'Share': 'مشاركة',
    'Download': 'تنزيل',
    'Unavailable': 'غير متاح',
    'Receipt unavailable until payment is completed.':
        'الإيصال مش هيبقى متاح إلا بعد السداد.',
    'Official stamped receipts are generated within 1-2 minutes and sent to your registered email.':
        'الإيصالات المختومة بتطلع خلال دقيقة إلى دقيقتين وبتتبعت على بريدك المسجل.',
    'Request selected receipt PDF': 'طلب ملف PDF للإيصال المختار',
    'Today\'s food experience': 'تجربة أكل النهاردة',
    'Meal type': 'نوع الوجبة',
    'Breakfast': 'فطار',
    'Lunch': 'غدا',
    'Dinner': 'عشا',
    'Taste': 'الطعم',
    'Hygiene': 'النظافة',
    'Variety': 'التنوع',
    'Comments': 'ملاحظات',
    'Share what can be improved...': 'اكتب إيه اللي محتاج يتحسن...',
    'Recent submissions': 'آخر التقييمات',
    'Please add a short comment before submitting feedback.':
        'من فضلك اكتب تعليق قصير قبل الإرسال.',
    'Mess feedback submitted. Thanks for helping improve service.':
        'تم إرسال التقييم. شكرًا لمساعدتك في تحسين الخدمة.',
    'Submit mess feedback': 'إرسال تقييم المطعم',
    'Average response time: 2.5 hours • Emergency cases are prioritized.':
        'متوسط وقت الاستجابة: ساعتين ونصف • الحالات الطارئة ليها أولوية.',
    'Request form': 'نموذج الطلب',
    'Category': 'الفئة',
    'Electrical': 'كهرباء',
    'Plumbing': 'سباكة',
    'Furniture': 'أثاث',
    'Internet / Network': 'إنترنت / شبكة',
    'Location': 'المكان',
    'Priority': 'الأولوية',
    'Low': 'منخفضة',
    'Medium': 'متوسطة',
    'High': 'عالية',
    'Preferred visit slot': 'ميعاد الزيارة المفضل',
    'Today (6:00 PM - 8:00 PM)': 'اليوم (6:00 م - 8:00 م)',
    'Tomorrow (8:00 AM - 10:00 AM)': 'بكرة (8:00 ص - 10:00 ص)',
    'Tomorrow (4:00 PM - 6:00 PM)': 'بكرة (4:00 م - 6:00 م)',
    'Issue description': 'وصف المشكلة',
    'Describe the issue and when it started...':
        'اكتب تفاصيل المشكلة وإمتى بدأت...',
    'Open requests': 'الطلبات المفتوحة',
    'Bathroom leakage - Room B118': 'تسريب في الحمام - غرفة B118',
    'Wardrobe door alignment - Room B214': 'باب الدولاب محتاج ضبط - غرفة B214',
    'In Progress': 'جاري التنفيذ',
    'Scheduled': 'مجدول',
    'ETA: Today 7:30 PM': 'الوصول المتوقع: اليوم 7:30 م',
    'ETA: Tomorrow 9:00 AM': 'الوصول المتوقع: بكرة 9:00 ص',
    'Please complete location and issue description.':
        'من فضلك اكتب المكان ووصف المشكلة.',
    'Maintenance request submitted. Team will reach out shortly.':
        'تم إرسال طلب الصيانة. الفريق هيتواصل معاك قريب.',
    'Submit maintenance request': 'إرسال طلب الصيانة',
    'What SAMS Student Portal does': 'بوابة سامز بتوفرلك إيه؟',
    'Keeps your attendance, schedule, messages, and campus updates in one place.':
        'بتجمعلك الحضور والجدول والرسائل وتحديثات الجامعة في مكان واحد.',
    'Provides quick access to hostel, transport, and support workflows.':
        'بتسهّل الوصول لخدمات السكن والنقل والدعم بسرعة.',
    'Designed to reduce paperwork and help students complete tasks faster.':
        'متصممة تقلل الورقيات وتساعد الطلبة يخلصوا مهامهم أسرع.',
    'Support and contact': 'الدعم والتواصل',
    'Support Email': 'بريد الدعم',
    'Support Hours': 'مواعيد الدعم',
    'Mon - Sat, 8:00 AM - 6:00 PM': 'من الاثنين للسبت، من 8:00 ص لـ 6:00 م',
    'Open a concern from the app': 'قدّم شكوتك من داخل التطبيق',
    'Legal': 'الصفحات القانونية',
    'Read usage terms and student responsibilities.':
        'اقرأ شروط الاستخدام ومسؤوليات الطالب.',
    'Understand how your data is collected and protected.':
        'اعرف بياناتك بتتجمع وتتأمن إزاي.',
    'Last updated: April 15, 2026. Please review this page periodically for changes.':
        'آخر تحديث: 15 أبريل 2026. راجع الصفحة دي كل فترة لأي تعديلات.',
    'We are committed to protecting your student data and being clear about how it is used.':
        'احنا ملتزمين بحماية بياناتك وشرح استخدامها بشكل واضح.',
    '1. Acceptance of terms': '1. الموافقة على الشروط',
    '2. Student account responsibility': '2. مسؤولية حساب الطالب',
    '3. Acceptable use': '3. الاستخدام المسموح',
    '4. Information accuracy': '4. دقة البيانات',
    '5. Service availability': '5. إتاحة الخدمة',
    '6. Updates to terms': '6. تحديث الشروط',
    '7. Contact': '7. التواصل',
    '1. Data we collect': '1. البيانات اللي بنجمعها',
    '2. How we use data': '2. بنستخدم البيانات إزاي',
    '3. Data sharing': '3. مشاركة البيانات',
    '4. Security measures': '4. إجراءات الأمان',
    '5. Data retention': '5. مدة الاحتفاظ بالبيانات',
    '6. Your choices': '6. اختياراتك',
    '7. Contact us': '7. تواصل معانا',
    'By using SAMS Student Portal, you agree to follow these terms and all applicable campus policies.':
        'باستخدامك لبوابة سامز، إنت موافق على الشروط وسياسات الجامعة المعمول بيها.',
    'You are responsible for maintaining the confidentiality of your login credentials and for all activity under your account.':
        'إنت مسؤول عن سرية بيانات الدخول وكل نشاط بيتم من حسابك.',
    'Do not misuse the service, attempt unauthorized access, upload harmful content, or interfere with other students using the platform.':
        'ممنوع إساءة استخدام الخدمة أو محاولة دخول غير مصرح أو رفع محتوى ضار أو تعطيل استخدام باقي الطلبة.',
    'You should provide accurate and current details in forms, profiles, requests, and support tickets to ensure correct processing.':
        'لازم بياناتك تكون صحيحة ومحدثة في النماذج والطلبات والتذاكر عشان المعالجة تتم بشكل صحيح.',
    'The app may be temporarily unavailable during maintenance, upgrades, or network issues. We aim to minimize downtime.':
        'ممكن التطبيق يقف مؤقتًا أثناء الصيانة أو التحديثات أو مشاكل الشبكة، وإحنا بنقلل وقت التوقف قدر الإمكان.',
    'Terms may be revised from time to time. Continued use of the app after changes means you accept the updated terms.':
        'الشروط ممكن تتحدث من وقت للتاني، واستمرارك في استخدام التطبيق بعد التعديل معناه موافقتك على النسخة الجديدة.',
    'For questions regarding these terms, raise a concern through Help Desk or contact support@sams.edu.':
        'لو عندك أي استفسار بخصوص الشروط، قدّم شكوى من الدعم أو تواصل على support@sams.edu.',
    'Data may be shared with authorized campus departments only when needed to fulfill academic, hostel, transport, or support operations.':
        'البيانات ممكن تتشارك مع الجهات المخولة داخل الجامعة فقط عند الحاجة لتقديم الخدمات الدراسية أو السكن أو النقل أو الدعم.',
    'Information is retained for the period necessary to provide services, comply with institutional policies, and meet legal obligations.':
        'بنحتفظ بالبيانات للمدة اللازمة لتقديم الخدمة والالتزام بسياسات المؤسسة والمتطلبات القانونية.',
    'For privacy-related concerns, please raise a Help Desk ticket or write to privacy@sams.edu.':
        'لو عندك ملاحظة تخص الخصوصية، قدّم تذكرة دعم أو راسل privacy@sams.edu.',
    'No items planned for this date.': 'مفيش عناصر مجدولة في التاريخ ده.',
    'Exams, lectures, events & birthdays overview':
        'نظرة عامة على الامتحانات والمحاضرات والفعاليات وأعياد الميلاد',
    'CALENDAR': 'التقويم',
    'Accounting Principles': 'مبادئ المحاسبة',
    'Business Administration': 'إدارة الأعمال',
    'Marketing Management': 'إدارة التسويق',
    'Financial Management': 'الإدارة المالية',
    'Human Resources Management': 'إدارة الموارد البشرية',
    'Management Information Systems': 'نظم المعلومات الإدارية',
    'Economics for Managers': 'الاقتصاد للمديرين',
    'Business Statistics': 'إحصاء الأعمال',
    'Accounting Principles • Dr. Ahmed Hassan': 'مبادئ المحاسبة • د. أحمد حسن',
    'Business Administration • Dr. Fatima Ali': 'إدارة الأعمال • د. فاطمة علي',
    'Marketing Management • Prof. Mohamed Salah':
        'إدارة التسويق • أ. محمد صلاح',
    'Financial Management • Dr. Sara Ibrahim':
        'الإدارة المالية • د. سارة إبراهيم',
    'Human Resources Management • Dr. Youssef Mahmoud':
        'إدارة الموارد البشرية • د. يوسف محمود',
    'Management Information Systems • Dr. Nourhan Adel':
        'نظم المعلومات الإدارية • د. نورهان عادل',
    'Economics for Managers • Prof. Karim Abdelrahman':
        'الاقتصاد للمديرين • أ. كريم عبدالرحمن',
    'Business Statistics • Dr. Mariam Mostafa': 'إحصاء الأعمال • د. مريم مصطفى',
    'SAMS Midterm Schedule (Semester 5) Published':
        'تم نشر جدول الميدترم لطلاب الترم الخامس',
    'Please review your timetable on the SAMS portal. Any clash requests should be sent to Prof. Mohamed Salah before Wednesday 2:00 PM.':
        'من فضلك راجع جدولك على بوابة سامز. أي تعارض في المواعيد ابعته لأ. محمد صلاح قبل الأربعاء 2:00 م.',
    'Tuition Installment Window – Spring 2026':
        'فتح باب تقسيط المصروفات - ربيع 2026',
    'Student Affairs (Maadi Building A) will accept installment requests from 9:30 AM to 2:30 PM. Contact Dr. Fatima Ali for verification support.':
        'شؤون الطلاب (مبنى A - المعادي) هتستقبل طلبات التقسيط من 9:30 ص لـ 2:30 م. تواصَل مع د. فاطمة علي للدعم.',
    'Career Week: Banking & FMCG Talks':
        'أسبوع التوظيف: جلسات البنوك والسلع الاستهلاكية',
    'Guest sessions start Sunday at the Main Auditorium. Opening talk moderated by Dr. Ahmed Hassan and Dr. Sara Ibrahim.':
        'الجلسات الضيف هتبدأ يوم الأحد في القاعة الرئيسية، والجلسة الافتتاحية بإدارة د. أحمد حسن ود. سارة إبراهيم.',
    'Library Extended Hours Before Midterms':
        'تمديد مواعيد المكتبة قبل الميدترم',
    'SAMS Central Library will be open until 9:00 PM (Sun–Thu). Floor supervisors include Dr. Nourhan Adel and Prof. Karim Abdelrahman.':
        'المكتبة المركزية في سامز هتفضل مفتوحة لحد 9:00 م (من الأحد للخميس)، وتحت إشراف د. نورهان عادل وأ. كريم عبدالرحمن.',
    'Important': 'مهم',
    'Financial Aid': 'دعم مالي',
    'Academics': 'أكاديمي',
    'Campus': 'الحرم الجامعي',
    'Reminder: Accounting quiz starts 10:00 AM sharp in Hall M203. Bring your SAMS ID card.':
        'تذكير: كويز المحاسبة هيبدأ 10:00 ص بالظبط في قاعة M203. خليك معاك بطاقة سامز.',
    'Financial Management case study rubric is now available on Moodle.':
        'Rubric الخاص بحالة الإدارة المالية متاح الآن على مودل.',
    'Attendance for Monday lecture will be taken in the first 15 minutes only.':
        'حضور محاضرة الاثنين هيتسجل في أول 15 دقيقة بس.',
    'Your internship letter is ready for collection from Building B counter 4.':
        'خطاب التدريب بتاعك جاهز للاستلام من مبنى B شباك 4.',
    'MIS lab section has moved to Computer Lab 2 this Tuesday.':
        'سيكشن معمل MIS اتنقل لمعمل كمبيوتر 2 يوم الثلاثاء.',
    'Economics discussion section will focus on Egypt inflation trends for 2025.':
        'سكشن المناقشة في الاقتصاد هيركز على اتجاهات التضخم في مصر لعام 2025.',
    'Transport Department': 'إدارة النقل',
    'IT Support': 'الدعم التقني',
    'Library Services': 'خدمات المكتبة',
    'I moved from Maadi to Nasr City. Please change my shuttle route from Line 03 to Line 06 starting next week.':
        'أنا نقلت من المعادي لمدينة نصر. من فضلك غيّر خط الأتوبيس من خط 03 لخط 06 بداية من الأسبوع الجاي.',
    'SAMS portal login keeps timing out on campus Wi-Fi between 8:00 PM and 10:00 PM in Building C.':
        'تسجيل دخول بوابة سامز بيفصل على واي فاي الحرم بين 8:00 م و10:00 م في مبنى C.',
    'My student card is active for borrowing books but not for accessing EBSCO databases from the digital library lab.':
        'بطاقتي شغالة في استعارة الكتب بس مش شغالة في دخول قواعد بيانات EBSCO من معمل المكتبة الرقمية.',
    'In Campus': 'داخل الحرم',
    'Maadi Campus (SAMS)': 'حرم المعادي (سامز)',
    'Maadi Corniche': 'كورنيش المعادي',
    'Tahrir Square': 'ميدان التحرير',
    'Giza Square': 'ميدان الجيزة',
    'Cairo University': 'جامعة القاهرة',
    'Ramses Station': 'محطة رمسيس',
    'Helwan': 'حلوان',
    'Maadi Corniche → Tahrir Square → Giza Square → Cairo University → Ramses Station → Helwan':
        'كورنيش المعادي ← ميدان التحرير ← ميدان الجيزة ← جامعة القاهرة ← محطة رمسيس ← حلوان',
    'Origin': 'بداية الخط',
    'Passed': 'عدّت',
    'Current': 'حاليًا',
    'Upcoming': 'جاية',
    'Updated 2 mins ago': 'آخر تحديث من دقيقتين',
    'Morning Shuttle • 6 major stops • 33km • 1 hour 40 mins':
        'رحلة الصبح • 6 محطات رئيسية • 33 كم • ساعة و40 دقيقة',
    'Status: Arriving at Gate 2 (Maadi Campus)':
        'الحالة: الأتوبيس داخل على بوابة 2 (حرم المعادي)',
    'SAMS Shuttle 03 • Maadi → Ramses': 'أتوبيس سامز 03 • المعادي ← رمسيس',
    '8/11 lectures attended this week': 'حضرت 8 من 11 محاضرة الأسبوع ده',
    'Accounting Principles Lecture': 'محاضرة مبادئ المحاسبة',
    'Financial Management Tutorial': 'تمارين الإدارة المالية',
    'MIS Lab Session': 'سيشن معمل MIS',
    'Student Activities Committee Meetup': 'لقاء لجنة الأنشطة الطلابية',
    'Quiz - Operations Management': 'كويز - إدارة العمليات',
    'Final Exam - Business Administration': 'امتحان نهائي - إدارة الأعمال',
    'Gana Abdelrahman Birthday': 'عيد ميلاد جنا عبدالرحمن',
    'Spring Semester Orientation': 'تعريف بترم الربيع',
    'Career Week: Banking Track': 'أسبوع التوظيف: مسار البنوك',
    'Midterm Exam - Marketing Management': 'امتحان ميدترم - إدارة التسويق',
    'Community Service Day (Maadi)': 'يوم خدمة مجتمعية (المعادي)',
    'Fall Semester Kickoff': 'بداية ترم الخريف',
    'October Victory Commemoration Talk': 'ندوة ذكرى نصر أكتوبر',
    'Midterm Exam - Economics for Managers':
        'امتحان ميدترم - الاقتصاد للمديرين',
    'Class Advisor Birthday - Prof. Mohamed Salah':
        'عيد ميلاد المرشد الأكاديمي - أ. محمد صلاح',
    'Lecture Hall B2': 'قاعة محاضرات B2',
    'Room C-114': 'قاعة C-114',
    'Computer Lab 2': 'معمل كمبيوتر 2',
    'Student Union Hall': 'قاعة اتحاد الطلبة',
    'Main Exam Hall A': 'قاعة الامتحان الرئيسية A',
    'Hall M-203': 'قاعة M-203',
    'Campus Café Terrace': 'تراس كافيه الحرم',
    'SAMS Main Auditorium': 'القاعة الكبرى - سامز',
    'Conference Hall, Building A': 'قاعة المؤتمرات - مبنى A',
    'Maadi Community Center': 'مركز مجتمع المعادي',
    'Open Air Theater': 'المسرح المكشوف',
    'History Hall, Building D': 'قاعة التاريخ - مبنى D',
    'Exam Hall B': 'قاعة امتحان B',
    'Faculty Lounge': 'استراحة هيئة التدريس',
    'Open for all Semester 5 students': 'متاح لكل طلبة الترم الخامس',
    'Bring SAMS ID and approved calculator':
        'خليك معاك بطاقة سامز وآلة حاسبة معتمدة',
    'Classmates gathering': 'تجمع بسيط للدفعة',
    'Dean office + Student Affairs': 'مكتب العميد + شؤون الطلاب',
    'Hosted with Banque Misr alumni': 'بالتعاون مع خريجي بنك مصر',
    'Semester 5 core requirement': 'متطلب أساسي لطلاب الترم الخامس',
    'Volunteer hours count toward activities record':
        'ساعات التطوع بتتحسب ضمن سجل الأنشطة',
    'Special lecture by Dr. Khaled Samir': 'محاضرة خاصة مع د. خالد سمير',
    'Paper-based exam': 'امتحان ورقي',
    '2025 - 2026 • Bachelor of Management Sciences – Semester 5':
        '2025 - 2026 • بكالوريوس علوم إدارية - الترم الخامس',
    'Bachelor of Management Sciences – Semester 5 • Current term':
        'بكالوريوس علوم إدارية - الترم الخامس • الترم الحالي',
    'Bachelor of Management Sciences – Semester 1':
        'بكالوريوس علوم إدارية - الترم الأول',
    'Bachelor of Management Sciences – Semester 2':
        'بكالوريوس علوم إدارية - الترم الثاني',
    'Bachelor of Management Sciences – Semester 3':
        'بكالوريوس علوم إدارية - الترم الثالث',
    'Bachelor of Management Sciences – Semester 4':
        'بكالوريوس علوم إدارية - الترم الرابع',
    'Bachelor of Management Sciences – Semester 5':
        'بكالوريوس علوم إدارية - الترم الخامس',
    'Academic Overview': 'نظرة عامة أكاديمية',
    'Track your active semester and previous academic progress.':
        'تابع الترم الحالي وتقدمك الأكاديمي في الترمات اللي فاتت.',
    'Current Session': 'الفصل الحالي',
    'Active': 'نشط',
    'Academic Year 2025-26 • 27 Sep 2025 – 29 Jan 2026':
        'السنة الدراسية 2025-26 • من 27 سبتمبر 2025 إلى 29 يناير 2026',
    'Programme: Bachelor of Management Sciences – Semester 5':
        'البرنامج: بكالوريوس علوم إدارية - الترم الخامس',
    'Department: Business Administration • Campus: SAMS Cairo (Maadi)':
        'القسم: إدارة أعمال • الحرم: سامز القاهرة (المعادي)',
    'Semester Subjects': 'مواد الترم',
    'Past Semesters': 'الترمات السابقة',
    'Completed': 'مكتمل',
    'Mon - Sat': 'من الاثنين للسبت',
  };

  static const Map<String, String> _phraseContains = {
    "Couldn't load": 'ماقدرناش نحمّل',
    'Failed to load': 'فشل تحميل',
    'Please try again.': 'من فضلك جرّب تاني.',
    'Please ': 'من فضلك ',
    'Loading ': 'جاري تحميل ',
    'Current Status:': 'الحالة الحالية:',
    'Status:': 'الحالة:',
    'Last updated': 'آخر تحديث',
    'Last changed': 'آخر تغيير',
    'Open requests': 'الطلبات المفتوحة',
    'Request form': 'نموذج الطلب',
    'Feedback form': 'نموذج التقييم',
    'Current average rating': 'متوسط التقييم الحالي',
    'Recent submissions': 'آخر التقييمات',
    'Academic Year': 'السنة الدراسية',
    'Payment summary': 'ملخص الدفع',
    'Available receipts': 'الإيصالات المتاحة',
    'Issue description': 'وصف المشكلة',
    'Preferred visit slot': 'ميعاد الزيارة المفضل',
    'Language switched to': 'تم تغيير اللغة إلى',
    'Dark Mode enabled.': 'تم تفعيل الوضع الليلي.',
    'Light Mode enabled.': 'تم تفعيل الوضع الفاتح.',
    'Mon - Sat': 'من الاثنين للسبت',
    ' AM': ' ص',
    ' PM': ' م',
    ' mins': ' دقيقة',
    ' km': ' كم',
    'km': ' كم',
    ' hour': ' ساعة',
    ' hours': ' ساعات',
  };

  static const Map<String, String> _wordMap = {
    'home': 'الرئيسية',
    'messages': 'الرسائل',
    'scan': 'المسح',
    'menu': 'القائمة',
    'help': 'دعم',
    'desk': 'فني',
    'settings': 'الإعدادات',
    'session': 'الفصل',
    'profile': 'الحساب',
    'attendance': 'الحضور',
    'calendar': 'التقويم',
    'bus': 'الأتوبيس',
    'tracking': 'التتبع',
    'hostel': 'السكن',
    'leave': 'خروج',
    'permission': 'إذن',
    'fee': 'رسوم',
    'receipt': 'إيصال',
    'maintenance': 'صيانة',
    'request': 'طلب',
    'mess': 'المطعم',
    'feedback': 'تقييم',
    'privacy': 'خصوصية',
    'policy': 'سياسة',
    'terms': 'الشروط',
    'conditions': 'الأحكام',
    'about': 'عن',
    'app': 'التطبيق',
    'version': 'الإصدار',
    'retry': 'حاول',
    'submit': 'إرسال',
    'today': 'اليوم',
    'tomorrow': 'بكرة',
    'origin': 'بداية',
    'passed': 'عدّت',
    'current': 'حاليًا',
    'upcoming': 'جاية',
    'updated': 'تحديث',
    'ago': 'فاتت',
    'next': 'الجاية',
    'stop': 'محطة',
    'eta': 'الوصول',
    'in': 'داخل',
    'campus': 'الحرم',
    'important': 'مهم',
    'academics': 'أكاديمي',
    'financial': 'مالي',
    'aid': 'دعم',
    'monday': 'الاثنين',
    'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء',
    'thursday': 'الخميس',
    'friday': 'الجمعة',
    'saturday': 'السبت',
    'sunday': 'الأحد',
    'january': 'يناير',
    'february': 'فبراير',
    'march': 'مارس',
    'april': 'أبريل',
    'may': 'مايو',
    'june': 'يونيو',
    'july': 'يوليو',
    'august': 'أغسطس',
    'september': 'سبتمبر',
    'october': 'أكتوبر',
    'november': 'نوفمبر',
    'december': 'ديسمبر',
    'jan': 'ينا',
    'feb': 'فبراير',
    'mar': 'مارس',
    'apr': 'أبريل',
    'jun': 'يونيو',
    'jul': 'يوليو',
    'aug': 'أغسطس',
    'sep': 'سبتمبر',
    'oct': 'أكتوبر',
    'nov': 'نوفمبر',
    'dec': 'ديسمبر',
    'dr.': 'د.',
    'prof.': 'أ.',
    'maadi': 'المعادي',
    'ramses': 'رمسيس',
    'tahrir': 'التحرير',
    'giza': 'الجيزة',
    'cairo': 'القاهرة',
    'university': 'الجامعة',
    'station': 'المحطة',
    'helwan': 'حلوان',
  };

  static const Map<String, String> _transliterationMap = {
    'a': 'ا',
    'b': 'ب',
    'c': 'ك',
    'd': 'د',
    'e': 'ي',
    'f': 'ف',
    'g': 'ج',
    'h': 'ه',
    'i': 'ي',
    'j': 'ج',
    'k': 'ك',
    'l': 'ل',
    'm': 'م',
    'n': 'ن',
    'o': 'و',
    'p': 'ب',
    'q': 'ق',
    'r': 'ر',
    's': 'س',
    't': 'ت',
    'u': 'و',
    'v': 'ف',
    'w': 'و',
    'x': 'كس',
    'y': 'ي',
    'z': 'ز',
  };

  static String translate(String input, {required bool isArabic}) {
    if (!isArabic || input.isEmpty) {
      return input;
    }

    final exact = _exactPhrases[input];
    if (exact != null) {
      return exact;
    }

    final dynamic = _translateDynamic(input);
    if (dynamic != null) {
      return dynamic;
    }

    var transformed = input;

    for (final entry in _phraseContains.entries) {
      transformed = transformed.replaceAll(entry.key, entry.value);
    }

    transformed = transformed.splitMapJoin(
      _tokenRegex,
      onMatch: (match) => _translateToken(match.group(0) ?? ''),
      onNonMatch: (value) => value,
    );

    return transformed
        .replaceAll('  ', ' ')
        .replaceAll(' :', ':')
        .replaceAll(' ،', '،')
        .trim();
  }

  static String? _translateDynamic(String input) {
    final idMatch = RegExp(r'^ID:\s*(.+)$').firstMatch(input);
    if (idMatch != null) {
      return 'رقم الطالب: ${idMatch.group(1)!}';
    }

    final hiMatch = RegExp(r'^Hi,\s*(.+)$').firstMatch(input);
    if (hiMatch != null) {
      return 'أهلا يا ${translate(hiMatch.group(1)!, isArabic: true)}';
    }

    final lecturesMatch = RegExp(
      r'^(\d+)\/(\d+) lectures attended this week$',
    ).firstMatch(input);
    if (lecturesMatch != null) {
      return 'حضرت ${lecturesMatch.group(1)!} من ${lecturesMatch.group(2)!} محاضرة الأسبوع ده';
    }

    final languageMatch = RegExp(
      r'^Language switched to\s+(.+)\.$',
    ).firstMatch(input);
    if (languageMatch != null) {
      final lang = translate(languageMatch.group(1)!, isArabic: true);
      return 'تم تغيير اللغة إلى $lang.';
    }

    final nextStopMatch = RegExp(
      r'^Next stop:\s*(.+)\s•\sETA\s(.+)$',
    ).firstMatch(input);
    if (nextStopMatch != null) {
      final stop = translate(nextStopMatch.group(1)!, isArabic: true);
      final eta = translate(nextStopMatch.group(2)!, isArabic: true);
      return 'المحطة الجاية: $stop • الوصول خلال $eta';
    }

    final currentStopMatch = RegExp(
      r'^Current stop:\s*(.+)\s•\s(.+)$',
    ).firstMatch(input);
    if (currentStopMatch != null) {
      final stop = translate(currentStopMatch.group(1)!, isArabic: true);
      final updated = translate(currentStopMatch.group(2)!, isArabic: true);
      return 'المحطة الحالية: $stop • $updated';
    }

    final openedMatch = RegExp(r'^Opened:\s*(.+)$').firstMatch(input);
    if (openedMatch != null) {
      return 'مفتوح: ${translate(openedMatch.group(1)!, isArabic: true)}';
    }

    final overallMatch = RegExp(
      r'^Overall Attendance:\s*(\d+)%$',
    ).firstMatch(input);
    if (overallMatch != null) {
      return 'إجمالي الحضور: ${overallMatch.group(1)!}%';
    }

    final avgMatch = RegExp(
      r'^Current average rating:\s*(.+)\s/\s5\.0$',
    ).firstMatch(input);
    if (avgMatch != null) {
      return 'متوسط التقييم الحالي: ${avgMatch.group(1)!} / 5.0';
    }

    final lastChangedMatch = RegExp(r'^Last changed\s+(.+)$').firstMatch(input);
    if (lastChangedMatch != null) {
      return 'آخر تغيير من ${translate(lastChangedMatch.group(1)!, isArabic: true)}';
    }

    final updatedAgoMatch = RegExp(r'^Updated\s+(.+)\s+ago$').firstMatch(input);
    if (updatedAgoMatch != null) {
      return 'آخر تحديث من ${translate(updatedAgoMatch.group(1)!, isArabic: true)}';
    }

    return null;
  }

  static String _translateToken(String token) {
    if (token.isEmpty) {
      return token;
    }

    if (_emailRegex.hasMatch(token)) {
      return token;
    }

    final lower = token.toLowerCase();
    final fromMap = _wordMap[lower];
    if (fromMap != null) {
      return fromMap;
    }

    if (!_latinWordRegex.hasMatch(token)) {
      return token;
    }

    return _transliterateToken(token);
  }

  static String _transliterateToken(String token) {
    final buffer = StringBuffer();

    for (final rune in token.runes) {
      final char = String.fromCharCode(rune);
      final lower = char.toLowerCase();
      if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write(_transliterationMap[lower] ?? char);
      }
    }

    return buffer.toString();
  }
}
