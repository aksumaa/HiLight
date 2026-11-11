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

  @override
  String get greetingMorning => 'Xayrli tong';

  @override
  String get greetingAfternoon => 'Xayrli kun';

  @override
  String get greetingEvening => 'Xayrli kech';

  @override
  String get todayReview => 'Bugungi takror';

  @override
  String get todayReviewEmpty => 'Eski yozuvlar shu yerda chiqadi.';

  @override
  String get askAi => 'HiLight AI dan soʻrang';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navLibrary => 'Kutubxona';

  @override
  String get navCapture => 'Qoʻshish';

  @override
  String get navInsights => 'Xulosalar';

  @override
  String get navProfile => 'Profil';

  @override
  String get captureSheetTitle => 'Qoʻshish';

  @override
  String get captureWrite => 'Eslatma yozish';

  @override
  String get writeTitle => 'Yangi eslatma';

  @override
  String get writeHint => 'Gapni yozing';

  @override
  String get writeContinue => 'Davom etish';

  @override
  String get writeEmpty => 'Avval matn yozing.';

  @override
  String get libraryTitle => 'Kutubxona';

  @override
  String get librarySearch => 'Eslatmalarni qidirish';

  @override
  String get libraryEmpty => 'Kutubxona boʻsh. Birinchi gapni saqlang.';

  @override
  String get libraryNoMatches => 'Hech narsa topilmadi.';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get filterQuotes => 'Iqtiboslar';

  @override
  String get filterVoice => 'Ovoz';

  @override
  String get filterNotes => 'Eslatmalar';

  @override
  String get filterAi => 'SI';

  @override
  String get insightsTitle => 'Xulosalar';

  @override
  String get insightsBody =>
      'Xulosalar keyinroq eslatmalaringizdagi naqshlarni yigʻadi. Kutubxona ularsiz ham ishlaydi.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get appearanceTitle => 'Koʻrinish';

  @override
  String get deviceTitle => 'Qurilma';

  @override
  String get itemDetailTitle => 'Eslatma';

  @override
  String get itemMissing => 'Bu eslatma kutubxonada yoʻq.';

  @override
  String get itemCopy => 'Nusxa olish';

  @override
  String get itemCopied => 'Nusxa olindi.';

  @override
  String get itemEdit => 'Tahrirlash';

  @override
  String get itemSave => 'Saqlash';

  @override
  String get itemDelete => 'Oʻchirish';

  @override
  String get itemDeleteTitle => 'Eslatma oʻchirilsinmi?';

  @override
  String get itemDeleteBody => 'U shu iPhone dagi kutubxonadan chiqadi.';

  @override
  String get itemDeleteAction => 'Oʻchirish';

  @override
  String get discussAi => 'HiLight AI bilan muhokama';

  @override
  String get aiTitle => 'HiLight AI';

  @override
  String get aiHint => 'Eslatmalaringiz haqida soʻrang';

  @override
  String get aiSend => 'Yuborish';

  @override
  String get aiFromNotes => 'Eslatmalaringizdan';

  @override
  String get aiGeneral => 'Umumiy bilim';

  @override
  String get aiFromNotesBody =>
      'Javob pastdagi eslatmalarga tayanadi. Model hali ulanmagan.';

  @override
  String get aiGeneralBody =>
      'Bu umumiy bilim, eslatmalaringizdan emas. Model hali ulanmagan.';

  @override
  String get aiEmpty => 'Saqlagan narsangiz haqida soʻrang.';

  @override
  String get appearanceLanguage => 'Til';

  @override
  String get appearanceTheme => 'Mavzu';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Yorugʻ';

  @override
  String get themeDark => 'Qorongʻi';

  @override
  String get appearanceLayout => 'Kutubxona koʻrinishi';

  @override
  String get layoutList => 'Roʻyxat';

  @override
  String get layoutCards => 'Kartalar';

  @override
  String get layoutCompact => 'Ixcham';

  @override
  String get appearanceAccent => 'Urgʻu';

  @override
  String get appearanceFont => 'Shrift oʻlchami';

  @override
  String get appearancePreview => 'Koʻrib chiqish';

  @override
  String get previewSample => 'Saqlashga arziydigan gap.';

  @override
  String get deviceBody =>
      'Ruchka ulanmagan. Bu ekran oʻrnini bosadi va Bluetooth ishlatmaydi.';

  @override
  String get deviceSample => 'Ruchka oʻrnidan kelgan gap.';

  @override
  String get deviceSend => 'Ruchka eslatmasini sinash';

  @override
  String get deviceSaved => 'Kutubxonaga saqlandi.';

  @override
  String get deviceFailed => 'Sinov eslatmasi saqlanmadi.';

  @override
  String get onboardingLanguage => 'Tilni tanlang';

  @override
  String get onboardingNext => 'Keyingi';

  @override
  String get onboardingStart => 'Kirishga oʻtish';

  @override
  String get onboardingSlide1Title => 'Gapni saqlang';

  @override
  String get onboardingSlide1Body =>
      'Sahifani suratga oling, ovoz yozing yoki eslatma yozing.';

  @override
  String get onboardingSlide2Title => 'Bitta kutubxona';

  @override
  String get onboardingSlide2Body =>
      'Iqtibos, ovoz va eslatmalar bitta tasmasga tushadi. Kitoblar ixtiyoriy.';

  @override
  String get onboardingSlide3Title => 'Keyin soʻrang';

  @override
  String get onboardingSlide3Body =>
      'HiLight AI eslatmalaringizdan javob beradi va javob ulardan boʻlmasa, belgilaydi.';

  @override
  String get onboardingGoalTitle => 'Bosh sahifa nimani koʻrsatsin?';

  @override
  String get onboardingGoalBody =>
      'Ikkalasini ham qoldirish mumkin. Bu faqat birinchi ekranni oʻzgartiradi.';

  @override
  String get goalReader => 'Kitobxon';

  @override
  String get goalLearner => 'IELTS';

  @override
  String get goalBoth => 'Ikkalasi';

  @override
  String get homeHighlights => 'Bugungi parchalar';

  @override
  String get homeReviewDue => 'Takrorlash';

  @override
  String get homeWordOfDay => 'Kun soʻzi';

  @override
  String get homeWordOfDayEmpty => 'Soʻz saqlang, u shu yerda chiqadi.';
}
