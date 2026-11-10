// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HiLight';

  @override
  String get homeTitle => 'Library';

  @override
  String get homeScan => 'Scan a page';

  @override
  String get homeRecord => 'Record voice';

  @override
  String get homeEmpty =>
      'Nothing saved yet. Photograph a page or record a voice note.';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeLoadError => 'The library could not be opened.';

  @override
  String get scanTitle => 'Scan';

  @override
  String get scanShutter => 'Take photo';

  @override
  String get scanFlashOn => 'Flash on';

  @override
  String get scanFlashOff => 'Flash off';

  @override
  String get scanEngineOnDevice => 'On this iPhone · Latin script';

  @override
  String get scanEngineServer => 'HiLight server';

  @override
  String get scanEngineServerStub => 'Server preview · not a real reading yet';

  @override
  String get scanProcessing => 'Reading the page…';

  @override
  String get scanNoCamera =>
      'No camera is available. The Simulator has none — open HiLight on your iPhone.';

  @override
  String get scanPermissionTitle => 'Camera access is off';

  @override
  String get scanPermissionBody =>
      'HiLight needs the camera to photograph a book page.';

  @override
  String get recordTitle => 'Voice note';

  @override
  String get recordPause => 'Pause';

  @override
  String get recordResume => 'Resume';

  @override
  String get recordStop => 'Stop';

  @override
  String get recordPermissionTitle => 'Microphone access is off';

  @override
  String get recordPermissionBody =>
      'HiLight needs the microphone to record a voice note.';

  @override
  String recordTooLong(int minutes) {
    return 'Recording stopped at $minutes minutes.';
  }

  @override
  String get recordProcessing => 'Transcribing…';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get editTitle => 'Check the text';

  @override
  String get editTextHint => 'Text';

  @override
  String get editHelper =>
      'Recognition can make mistakes. Read the text before you save it.';

  @override
  String get editTag => 'Tag or book';

  @override
  String get editPage => 'Page';

  @override
  String get editLanguage => 'Language';

  @override
  String get editSave => 'Save to Library';

  @override
  String get editDiscard => 'Discard';

  @override
  String get editPending =>
      'You are offline. The file is saved and marked pending recognition.';

  @override
  String get editEmpty => 'No text was found. You can type it yourself.';

  @override
  String get editStub =>
      'This text is a preview. The recognition server is not connected yet.';

  @override
  String get editFailed =>
      'Recognition failed. The file is still here — type the text if you want to keep it.';

  @override
  String editTooLong(int minutes) {
    return 'This recording is longer than $minutes minutes, so it was not sent for transcription.';
  }

  @override
  String get editRecognizeAgain => 'Recognize again';

  @override
  String get editMissing => 'There is no capture to edit.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageUzbek => 'Uzbek';

  @override
  String get sourceScan => 'Scan';

  @override
  String get sourceVoice => 'Voice';

  @override
  String get sourceManual => 'Typed';

  @override
  String get sourceDevice => 'Device';

  @override
  String get statusPending => 'Pending recognition';

  @override
  String get discardTitle => 'Discard this capture?';

  @override
  String get discardBody =>
      'The photo or recording and the text will be deleted.';

  @override
  String get discardAction => 'Discard';

  @override
  String get cancel => 'Cancel';

  @override
  String get accountTitle => 'Account';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginAction => 'Sign in';

  @override
  String get registerAction => 'Create account';

  @override
  String get switchToRegister => 'Need an account? Create one';

  @override
  String get switchToLogin => 'Already have an account? Sign in';

  @override
  String get continueOffline => 'Continue on this iPhone';

  @override
  String get loginFailed =>
      'Could not sign in. Check the email, password, and that the API is reachable.';

  @override
  String get syncNow => 'Sync';

  @override
  String get syncDone => 'Library synced.';

  @override
  String get syncNeedsAccount => 'Sign in to sync this library.';

  @override
  String get syncFailed =>
      'Sync did not finish. Your notes stay on this iPhone.';

  @override
  String get logOut => 'Log out';
}
