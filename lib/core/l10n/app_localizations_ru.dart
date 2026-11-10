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
}
