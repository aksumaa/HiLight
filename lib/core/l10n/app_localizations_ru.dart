// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HiLight';

  @override
  String get homeTitle => 'Библиотека';

  @override
  String get homeScan => 'Сканировать страницу';

  @override
  String get homeRecord => 'Записать голос';

  @override
  String get homeEmpty =>
      'Пока ничего нет. Сфотографируйте страницу или запишите голос.';

  @override
  String get homeRecent => 'Недавние';

  @override
  String get homeLoadError => 'Не удалось открыть библиотеку.';

  @override
  String get scanTitle => 'Скан';

  @override
  String get scanShutter => 'Снять';

  @override
  String get scanFlashOn => 'Вспышка включена';

  @override
  String get scanFlashOff => 'Вспышка выключена';

  @override
  String get scanEngineOnDevice => 'На этом iPhone · латиница';

  @override
  String get scanEngineServer => 'Сервер HiLight';

  @override
  String get scanEngineServerStub =>
      'Черновик сервера · это ещё не настоящее распознавание';

  @override
  String get scanProcessing => 'Читаем страницу…';

  @override
  String get scanNoCamera =>
      'Камера недоступна. В симуляторе её нет — откройте HiLight на iPhone.';

  @override
  String get scanPermissionTitle => 'Нет доступа к камере';

  @override
  String get scanPermissionBody =>
      'HiLight нужна камера, чтобы сфотографировать страницу книги.';

  @override
  String get recordTitle => 'Голосовая заметка';

  @override
  String get recordPause => 'Пауза';

  @override
  String get recordResume => 'Дальше';

  @override
  String get recordStop => 'Стоп';

  @override
  String get recordPermissionTitle => 'Нет доступа к микрофону';

  @override
  String get recordPermissionBody =>
      'HiLight нужен микрофон, чтобы записать голосовую заметку.';

  @override
  String recordTooLong(int minutes) {
    return 'Запись остановлена на $minutes минутах.';
  }

  @override
  String get recordProcessing => 'Распознаём речь…';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get editTitle => 'Проверьте текст';

  @override
  String get editTextHint => 'Текст';

  @override
  String get editHelper =>
      'Распознавание может ошибаться. Прочитайте текст перед сохранением.';

  @override
  String get editTag => 'Тег или книга';

  @override
  String get editPage => 'Страница';

  @override
  String get editLanguage => 'Язык';

  @override
  String get editSave => 'Сохранить в библиотеку';

  @override
  String get editDiscard => 'Удалить';

  @override
  String get editPending =>
      'Нет сети. Файл сохранён и помечен как «ожидает распознавания».';

  @override
  String get editEmpty => 'Текст не найден. Можно ввести его вручную.';

  @override
  String get editStub => 'Это черновик. Сервер распознавания ещё не подключён.';

  @override
  String get editFailed =>
      'Не удалось распознать. Файл на месте — введите текст, если хотите его сохранить.';

  @override
  String editTooLong(int minutes) {
    return 'Запись длиннее $minutes минут, поэтому она не отправлялась на распознавание.';
  }

  @override
  String get editRecognizeAgain => 'Распознать снова';

  @override
  String get editMissing => 'Нет записи для правки.';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageUzbek => 'Узбекский';

  @override
  String get sourceScan => 'Скан';

  @override
  String get sourceVoice => 'Голос';

  @override
  String get sourceManual => 'Вручную';

  @override
  String get sourceDevice => 'Устройство';

  @override
  String get statusPending => 'Ожидает распознавания';

  @override
  String get discardTitle => 'Удалить эту запись?';

  @override
  String get discardBody => 'Фото или аудио и текст будут удалены.';

  @override
  String get discardAction => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get loginTitle => 'Вход';

  @override
  String get registerTitle => 'Новый аккаунт';

  @override
  String get emailLabel => 'Почта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get loginAction => 'Войти';

  @override
  String get registerAction => 'Создать аккаунт';

  @override
  String get switchToRegister => 'Нет аккаунта? Создать';

  @override
  String get switchToLogin => 'Уже есть аккаунт? Войти';

  @override
  String get continueOffline => 'Продолжить на этом iPhone';

  @override
  String get loginFailed =>
      'Не удалось войти. Проверьте почту, пароль и что API доступен.';

  @override
  String get syncNow => 'Синхронизация';

  @override
  String get syncDone => 'Библиотека синхронизирована.';

  @override
  String get syncNeedsAccount => 'Войдите, чтобы синхронизировать библиотеку.';

  @override
  String get syncFailed =>
      'Синхронизация не завершилась. Заметки остаются на этом iPhone.';

  @override
  String get logOut => 'Выйти';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String get todayReview => 'Повтор сегодня';

  @override
  String get todayReviewEmpty => 'Здесь появятся более старые заметки.';

  @override
  String get askAi => 'Спросить HiLight AI';

  @override
  String get navHome => 'Главная';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navCapture => 'Добавить';

  @override
  String get navInsights => 'Итоги';

  @override
  String get navProfile => 'Профиль';

  @override
  String get captureSheetTitle => 'Добавить';

  @override
  String get captureWrite => 'Написать заметку';

  @override
  String get writeTitle => 'Новая заметка';

  @override
  String get writeHint => 'Введите предложение';

  @override
  String get writeContinue => 'Дальше';

  @override
  String get writeEmpty => 'Сначала напишите текст.';

  @override
  String get libraryTitle => 'Библиотека';

  @override
  String get librarySearch => 'Поиск заметок';

  @override
  String get libraryEmpty => 'Библиотека пуста. Сохраните первое предложение.';

  @override
  String get libraryNoMatches => 'Ничего не найдено.';

  @override
  String get filterAll => 'Все';

  @override
  String get filterQuotes => 'Цитаты';

  @override
  String get filterVoice => 'Голос';

  @override
  String get filterNotes => 'Заметки';

  @override
  String get filterAi => 'ИИ';

  @override
  String get insightsTitle => 'Итоги';

  @override
  String get insightsBody =>
      'Итоги позже соберут закономерности из ваших заметок. Библиотека уже работает без них.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get appearanceTitle => 'Оформление';

  @override
  String get deviceTitle => 'Устройство';

  @override
  String get itemDetailTitle => 'Заметка';

  @override
  String get itemMissing => 'Этой заметки больше нет в библиотеке.';

  @override
  String get itemCopy => 'Копировать';

  @override
  String get itemCopied => 'Скопировано.';

  @override
  String get itemEdit => 'Изменить';

  @override
  String get itemSave => 'Сохранить';

  @override
  String get itemDelete => 'Удалить';

  @override
  String get itemDeleteTitle => 'Удалить заметку?';

  @override
  String get itemDeleteBody => 'Она исчезнет из библиотеки на этом iPhone.';

  @override
  String get itemDeleteAction => 'Удалить';

  @override
  String get discussAi => 'Обсудить с HiLight AI';

  @override
  String get aiTitle => 'HiLight AI';

  @override
  String get aiHint => 'Спросите о своих заметках';

  @override
  String get aiSend => 'Отправить';

  @override
  String get aiFromNotes => 'Из ваших заметок';

  @override
  String get aiGeneral => 'Общие знания';

  @override
  String get aiFromNotesBody =>
      'Ответ опирается на заметки ниже. Модель ещё не подключена.';

  @override
  String get aiGeneralBody =>
      'Это общие знания, не из ваших заметок. Модель ещё не подключена.';

  @override
  String get aiEmpty => 'Спросите о том, что вы сохранили.';

  @override
  String get appearanceLanguage => 'Язык';

  @override
  String get appearanceTheme => 'Тема';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get appearanceLayout => 'Вид библиотеки';

  @override
  String get layoutList => 'Список';

  @override
  String get layoutCards => 'Карточки';

  @override
  String get layoutCompact => 'Компактно';

  @override
  String get appearanceAccent => 'Акцент';

  @override
  String get appearanceFont => 'Размер шрифта';

  @override
  String get appearancePreview => 'Предпросмотр';

  @override
  String get previewSample => 'Предложение, которое стоит сохранить.';

  @override
  String get deviceBody =>
      'Ручка не подключена. Этот экран — заглушка и не использует Bluetooth.';

  @override
  String get deviceSample => 'Предложение от заглушки ручки.';

  @override
  String get deviceSend => 'Имитировать заметку с ручки';

  @override
  String get deviceSaved => 'Сохранено в библиотеку.';

  @override
  String get deviceFailed => 'Заглушку не удалось сохранить.';

  @override
  String get onboardingLanguage => 'Выберите язык';

  @override
  String get onboardingNext => 'Дальше';

  @override
  String get onboardingStart => 'Перейти ко входу';

  @override
  String get onboardingSlide1Title => 'Сохраните предложение';

  @override
  String get onboardingSlide1Body =>
      'Сфотографируйте страницу, запишите голос или наберите заметку.';

  @override
  String get onboardingSlide2Title => 'Одна библиотека';

  @override
  String get onboardingSlide2Body =>
      'Цитаты, голос и заметки попадают в одну ленту. Книги необязательны.';

  @override
  String get onboardingSlide3Title => 'Спросите позже';

  @override
  String get onboardingSlide3Body =>
      'HiLight AI ответит по вашим заметкам и подпишет, если ответ не из них.';
}
