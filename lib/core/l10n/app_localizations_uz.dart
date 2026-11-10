// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'HiLight';

  @override
  String get homeTitle => 'Kutubxona';

  @override
  String get homeScan => 'Sahifani skanerlash';

  @override
  String get homeRecord => 'Ovoz yozish';

  @override
  String get homeEmpty =>
      'Hali hech narsa yoʻq. Sahifani suratga oling yoki ovoz yozing.';

  @override
  String get homeRecent => 'Soʻnggi';

  @override
  String get homeLoadError => 'Kutubxonani ochib boʻlmadi.';

  @override
  String get scanTitle => 'Skan';

  @override
  String get scanShutter => 'Suratga olish';

  @override
  String get scanFlashOn => 'Chaqnoq yoniq';

  @override
  String get scanFlashOff => 'Chaqnoq oʻchiq';

  @override
  String get scanEngineOnDevice => 'Shu iPhone’da · lotin yozuvi';

  @override
  String get scanEngineServer => 'HiLight serveri';

  @override
  String get scanEngineServerStub =>
      'Server namunasi · bu hali haqiqiy tanish emas';

  @override
  String get scanProcessing => 'Sahifa oʻqilmoqda…';

  @override
  String get scanNoCamera =>
      'Kamera yoʻq. Simulyatorda u boʻlmaydi — HiLight’ni iPhone’da oching.';

  @override
  String get scanPermissionTitle => 'Kameraga ruxsat yoʻq';

  @override
  String get scanPermissionBody =>
      'Kitob sahifasini suratga olish uchun HiLight’ga kamera kerak.';

  @override
  String get recordTitle => 'Ovozli eslatma';

  @override
  String get recordPause => 'Pauza';

  @override
  String get recordResume => 'Davom etish';

  @override
  String get recordStop => 'Toʻxtatish';

  @override
  String get recordPermissionTitle => 'Mikrofonga ruxsat yoʻq';

  @override
  String get recordPermissionBody =>
      'Ovozli eslatma yozish uchun HiLight’ga mikrofon kerak.';

  @override
  String recordTooLong(int minutes) {
    return 'Yozuv $minutes daqiqada toʻxtatildi.';
  }

  @override
  String get recordProcessing => 'Nutq tanilmoqda…';

  @override
  String get openSettings => 'Sozlamalarni ochish';

  @override
  String get editTitle => 'Matnni tekshiring';

  @override
  String get editTextHint => 'Matn';

  @override
  String get editHelper =>
      'Tanish xato qilishi mumkin. Saqlashdan oldin matnni oʻqing.';

  @override
  String get editTag => 'Teg yoki kitob';

  @override
  String get editPage => 'Sahifa';

  @override
  String get editLanguage => 'Til';

  @override
  String get editSave => 'Kutubxonaga saqlash';

  @override
  String get editDiscard => 'Bekor qilish';

  @override
  String get editPending =>
      'Tarmoq yoʻq. Fayl saqlandi va «tanish kutilmoqda» deb belgilandi.';

  @override
  String get editEmpty => 'Matn topilmadi. Oʻzingiz yozishingiz mumkin.';

  @override
  String get editStub => 'Bu namuna matn. Tanish serveri hali ulanmagan.';

  @override
  String get editFailed =>
      'Tanish amalga oshmadi. Fayl joyida — saqlamoqchi boʻlsangiz, matnni yozing.';

  @override
  String editTooLong(int minutes) {
    return 'Yozuv $minutes daqiqadan uzun, shuning uchun tanishga yuborilmadi.';
  }

  @override
  String get editRecognizeAgain => 'Qayta tanish';

  @override
  String get editMissing => 'Tahrirlash uchun yozuv yoʻq.';

  @override
  String get languageEnglish => 'Inglizcha';

  @override
  String get languageRussian => 'Ruscha';

  @override
  String get languageUzbek => 'Oʻzbekcha';

  @override
  String get sourceScan => 'Skan';

  @override
  String get sourceVoice => 'Ovoz';

  @override
  String get sourceManual => 'Qoʻlda';

  @override
  String get sourceDevice => 'Qurilma';

  @override
  String get statusPending => 'Tanish kutilmoqda';

  @override
  String get discardTitle => 'Bu yozuv oʻchirilsinmi?';

  @override
  String get discardBody => 'Surat yoki audio va matn oʻchadi.';

  @override
  String get discardAction => 'Oʻchirish';

  @override
  String get cancel => 'Bekor';

  @override
  String get accountTitle => 'Hisob';

  @override
  String get loginTitle => 'Kirish';

  @override
  String get registerTitle => 'Yangi hisob';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get loginAction => 'Kirish';

  @override
  String get registerAction => 'Hisob yaratish';

  @override
  String get switchToRegister => 'Hisob yoʻqmi? Yarating';

  @override
  String get switchToLogin => 'Hisob bormi? Kiring';

  @override
  String get continueOffline => 'Shu iPhone’da davom etish';

  @override
  String get loginFailed =>
      'Kirib boʻlmadi. Email, parol va API manzilini tekshiring.';

  @override
  String get syncNow => 'Sinxronlash';

  @override
  String get syncDone => 'Kutubxona sinxronlandi.';

  @override
  String get syncNeedsAccount => 'Kutubxonani sinxronlash uchun kiring.';

  @override
  String get syncFailed => 'Sinxron tugamadi. Yozuvlar shu iPhone’da qoladi.';

  @override
  String get logOut => 'Chiqish';
}
