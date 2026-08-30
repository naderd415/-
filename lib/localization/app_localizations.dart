import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Offline Stock Closing',
      'dashboard': 'Dashboard',
      'reports': 'Reports',
      'forecasting': 'Smart Analytics & Forecasting',
      'forecasting_subtitle': 'Demand prediction & recommended reorder quantities',
      'yesterday_stock': "Yesterday's Stock",
      'operating_units': 'Operating Units',
      'current_stock': 'Current Stock',
      'actual_consumption': 'Actual Consumption',
      'variance': 'Variance / Discrepancy',
      'shortage': 'Shortage (Missing)',
      'surplus': 'Surplus (Extra)',
      'accurate': 'Accurate',
      'save_record': 'Save Multi-Item Closing',
      'voice_input': 'Voice Command',
      'camera_scan': 'Paper OCR Scan',
      'object_counting': 'Multi-Class Cup Recognition (AI)',
      'close': 'Close',
      'date': 'Date',
      'history': 'Closing History',
      'export_csv': 'Export Reports (CSV)',
      'backup_db': 'Backup DB (JSON)',
      'restore_db': 'Restore DB',
      'record_saved': 'All cup closing entries saved successfully offline.',
      'invalid_inputs': 'Please check numbers for all cup sizes.',
      'voice_active': 'Listening offline... Speak count metrics.',
      'voice_inactive': 'Tap to speak counts',
      'no_records': 'No records found in local database.',
      'scan_instructions': 'Point camera at numbers on count sheet.',
      'detected_value': 'Detected Values',
      'assign_to': 'Assign to',
      'cup_presets': 'Cup Sizes & Presets',
      'add_custom_size': 'Add Custom Cup Size',
      'ounces': 'Ounces (oz)',
      'milliliters': 'Milliliters (ml)',
      'name_ar': 'Arabic Name',
      'name_en': 'English Name',
      'threshold': 'Low Stock Threshold',
      'low_stock_warning': 'LOW STOCK ALERT!',
      'predicted_demand': 'Predicted Demand Tomorrow',
      'recommended_reorder': 'Recommended Reorder Quantity',
      'reorder_status': 'Stock Reorder Status',
      'status_safe': 'Safe Stock Level',
      'status_order_soon': 'Order Soon',
      'status_critical': 'CRITICAL REORDER NEEDED',
      'backup_success': 'Local database backup saved to documents.',
      'restore_success': 'Database successfully restored from backup.',
      'notes': 'Notes / Context',
    },
    'ar': {
      'app_title': 'تقفيل المخزون اليومي',
      'dashboard': 'لوحة التقفيل اليومي',
      'reports': 'التقارير اليومية',
      'forecasting': 'التوقعات والتحليلات الذكية',
      'forecasting_subtitle': 'التنبؤ بطلب الغد وحساب كميات التوريد المطلوبة',
      'yesterday_stock': 'مخزون أمس',
      'operating_units': 'التشغيل (المبيعات المفترضة)',
      'current_stock': 'الاستوك الحالي',
      'actual_consumption': 'الاستهلاك الفعلي',
      'variance': 'الفارق (العجز / الزيادة)',
      'shortage': 'عجز (مفقود)',
      'surplus': 'زيادة (فائض)',
      'accurate': 'متطابق (دقيق)',
      'save_record': 'حفظ التقفيل لجميع المقاسات',
      'voice_input': 'الإدخال الصوتي المحلي',
      'camera_scan': 'قراءة أوراق التقفيل (OCR)',
      'object_counting': 'التعرف الذكي على مقاسات الكوبايات',
      'close': 'إغلاق',
      'date': 'التاريخ',
      'history': 'سجل التقفيلات السابقة',
      'export_csv': 'تصدير التقارير (CSV)',
      'backup_db': 'نسخ احتياطي محلي',
      'restore_db': 'استرجاع النسخة الاحتياطية',
      'record_saved': 'تم حفظ تقفيل كافة المقاسات بنجاح محلياً.',
      'invalid_inputs': 'يرجى مراجعة قيم المدخلات لجميع المقاسات.',
      'voice_active': 'جاري الاستماع دون اتصال... تحدث بالقيم.',
      'voice_inactive': 'اضغط للتحدث بالقيم صوتياً',
      'no_records': 'لا توجد تقارير مخزنة في قاعدة البيانات المحلية.',
      'scan_instructions': 'وجه الكاميرا نحو الأرقام المكتوبة في ورقة العد.',
      'detected_value': 'الأرقام المكتشفة',
      'assign_to': 'تعيين إلى',
      'cup_presets': 'أحجام ومقاسات الكوبايات',
      'add_custom_size': 'إضافة مقاس كوب مخصص',
      'ounces': 'أونصة (oz)',
      'milliliters': 'مليلتر (ml)',
      'name_ar': 'الاسم بالعربية',
      'name_en': 'الاسم بالإنجليزية',
      'threshold': 'حد التنبيه للنقصان',
      'low_stock_warning': 'تنبيه: مخزون منخفض جداً!',
      'predicted_demand': 'الطلب المتوقع لغد',
      'recommended_reorder': 'كمية التوريد المطلوبة',
      'reorder_status': 'حالة إعادة الطلب',
      'status_safe': 'مخزون آمن',
      'status_order_soon': 'اطلب قريباً',
      'status_critical': 'إعادة طلب حرجة جداً',
      'backup_success': 'تم حفظ النسخة الاحتياطية لقاعدة البيانات محلياً.',
      'restore_success': 'تم استرجاع قاعدة البيانات محلياً بنجاح.',
      'notes': 'ملاحظات / سياق الإدخال',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  bool get isRtl => locale.languageCode == 'ar';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String translate(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  bool get isRtl => AppLocalizations.of(this)?.isRtl ?? false;
}
