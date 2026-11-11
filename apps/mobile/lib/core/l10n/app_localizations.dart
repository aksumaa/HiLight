import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HiLight'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeTitle;

  /// No description provided for @homeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan a page'**
  String get homeScan;

  /// No description provided for @homeRecord.
  ///
  /// In en, this message translates to:
  /// **'Record voice'**
  String get homeRecord;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. Photograph a page or record a voice note.'**
  String get homeEmpty;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'The library could not be opened.'**
  String get homeLoadError;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTitle;

  /// No description provided for @scanShutter.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanShutter;

  /// No description provided for @scanFlashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get scanFlashOn;

  /// No description provided for @scanFlashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get scanFlashOff;

  /// No description provided for @scanEngineOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On this iPhone · Latin script'**
  String get scanEngineOnDevice;

  /// No description provided for @scanEngineServer.
  ///
  /// In en, this message translates to:
  /// **'HiLight server'**
  String get scanEngineServer;

  /// No description provided for @scanEngineServerStub.
  ///
  /// In en, this message translates to:
  /// **'Server preview · not a real reading yet'**
  String get scanEngineServerStub;

  /// No description provided for @scanProcessing.
  ///
  /// In en, this message translates to:
  /// **'Reading the page…'**
  String get scanProcessing;

  /// No description provided for @scanNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera is available. The Simulator has none — open HiLight on your iPhone.'**
  String get scanNoCamera;

  /// No description provided for @scanPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get scanPermissionTitle;

  /// No description provided for @scanPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'HiLight needs the camera to photograph a book page.'**
  String get scanPermissionBody;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get recordTitle;

  /// No description provided for @recordPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get recordPause;

  /// No description provided for @recordResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get recordResume;

  /// No description provided for @recordStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get recordStop;

  /// No description provided for @recordPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off'**
  String get recordPermissionTitle;

  /// No description provided for @recordPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'HiLight needs the microphone to record a voice note.'**
  String get recordPermissionBody;

  /// No description provided for @recordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped at {minutes} minutes.'**
  String recordTooLong(int minutes);

  /// No description provided for @recordProcessing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get recordProcessing;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the text'**
  String get editTitle;

  /// No description provided for @editTextHint.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get editTextHint;

  /// No description provided for @editHelper.
  ///
  /// In en, this message translates to:
  /// **'Recognition can make mistakes. Read the text before you save it.'**
  String get editHelper;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Tag or book'**
  String get editTag;

  /// No description provided for @editPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get editPage;

  /// No description provided for @editLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get editLanguage;

  /// No description provided for @editSave.
  ///
  /// In en, this message translates to:
  /// **'Save to Library'**
  String get editSave;

  /// No description provided for @editDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editDiscard;

  /// No description provided for @editPending.
  ///
  /// In en, this message translates to:
  /// **'You are offline. The file is saved and marked pending recognition.'**
  String get editPending;

  /// No description provided for @editEmpty.
  ///
  /// In en, this message translates to:
  /// **'No text was found. You can type it yourself.'**
  String get editEmpty;

  /// No description provided for @editStub.
  ///
  /// In en, this message translates to:
  /// **'This text is a preview. The recognition server is not connected yet.'**
  String get editStub;

  /// No description provided for @editFailed.
  ///
  /// In en, this message translates to:
  /// **'Recognition failed. The file is still here — type the text if you want to keep it.'**
  String get editFailed;

  /// No description provided for @editTooLong.
  ///
  /// In en, this message translates to:
  /// **'This recording is longer than {minutes} minutes, so it was not sent for transcription.'**
  String editTooLong(int minutes);

  /// No description provided for @editRecognizeAgain.
  ///
  /// In en, this message translates to:
  /// **'Recognize again'**
  String get editRecognizeAgain;

  /// No description provided for @editMissing.
  ///
  /// In en, this message translates to:
  /// **'There is no capture to edit.'**
  String get editMissing;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageUzbek.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get languageUzbek;

  /// No description provided for @sourceScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get sourceScan;

  /// No description provided for @sourceVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get sourceVoice;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Typed'**
  String get sourceManual;

  /// No description provided for @sourceDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get sourceDevice;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending recognition'**
  String get statusPending;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this capture?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'The photo or recording and the text will be deleted.'**
  String get discardBody;

  /// No description provided for @discardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAction;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerAction;

  /// No description provided for @switchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Create one'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToLogin;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue on this iPhone'**
  String get continueOffline;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check the email, password, and that the API is reachable.'**
  String get loginFailed;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncNow;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'Library synced.'**
  String get syncDone;

  /// No description provided for @syncNeedsAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync this library.'**
  String get syncNeedsAccount;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync did not finish. Your notes stay on this iPhone.'**
  String get syncFailed;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @todayReview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s review'**
  String get todayReview;

  /// No description provided for @todayReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Older notes will show up here.'**
  String get todayReviewEmpty;

  /// No description provided for @askAi.
  ///
  /// In en, this message translates to:
  /// **'Ask HiLight AI'**
  String get askAi;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get navCapture;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @captureSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureSheetTitle;

  /// No description provided for @captureWrite.
  ///
  /// In en, this message translates to:
  /// **'Write note'**
  String get captureWrite;

  /// No description provided for @writeTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get writeTitle;

  /// No description provided for @writeHint.
  ///
  /// In en, this message translates to:
  /// **'Type a sentence'**
  String get writeHint;

  /// No description provided for @writeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get writeContinue;

  /// No description provided for @writeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write something before continuing.'**
  String get writeEmpty;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @librarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get librarySearch;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty. Capture a sentence to begin.'**
  String get libraryEmpty;

  /// No description provided for @libraryNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this search.'**
  String get libraryNoMatches;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get filterQuotes;

  /// No description provided for @filterVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get filterVoice;

  /// No description provided for @filterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get filterNotes;

  /// No description provided for @filterAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get filterAi;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsBody.
  ///
  /// In en, this message translates to:
  /// **'Insights will gather patterns from your notes later. Your library already works without them.'**
  String get insightsBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @deviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceTitle;

  /// No description provided for @itemDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get itemDetailTitle;

  /// No description provided for @itemMissing.
  ///
  /// In en, this message translates to:
  /// **'This note is no longer in the library.'**
  String get itemMissing;

  /// No description provided for @itemCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get itemCopy;

  /// No description provided for @itemCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get itemCopied;

  /// No description provided for @itemEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get itemEdit;

  /// No description provided for @itemSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get itemSave;

  /// No description provided for @itemDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get itemDelete;

  /// No description provided for @itemDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get itemDeleteTitle;

  /// No description provided for @itemDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will leave your library on this iPhone.'**
  String get itemDeleteBody;

  /// No description provided for @itemDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get itemDeleteAction;

  /// No description provided for @discussAi.
  ///
  /// In en, this message translates to:
  /// **'Discuss with HiLight AI'**
  String get discussAi;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'HiLight AI'**
  String get aiTitle;

  /// No description provided for @aiHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your notes'**
  String get aiHint;

  /// No description provided for @aiSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// No description provided for @aiFromNotes.
  ///
  /// In en, this message translates to:
  /// **'From your notes'**
  String get aiFromNotes;

  /// No description provided for @aiGeneral.
  ///
  /// In en, this message translates to:
  /// **'General knowledge'**
  String get aiGeneral;

  /// No description provided for @aiFromNotesBody.
  ///
  /// In en, this message translates to:
  /// **'This answer stays with the notes below. The model is not connected yet.'**
  String get aiFromNotesBody;

  /// No description provided for @aiGeneralBody.
  ///
  /// In en, this message translates to:
  /// **'This is general knowledge. It is not drawn from your notes. The model is not connected yet.'**
  String get aiGeneralBody;

  /// No description provided for @aiEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about something you saved.'**
  String get aiEmpty;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguage;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appearanceLayout.
  ///
  /// In en, this message translates to:
  /// **'Library layout'**
  String get appearanceLayout;

  /// No description provided for @layoutList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get layoutList;

  /// No description provided for @layoutCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get layoutCards;

  /// No description provided for @layoutCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get layoutCompact;

  /// No description provided for @appearanceAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get appearanceAccent;

  /// No description provided for @appearanceFont.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get appearanceFont;

  /// No description provided for @appearancePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get appearancePreview;

  /// No description provided for @previewSample.
  ///
  /// In en, this message translates to:
  /// **'A sentence worth keeping.'**
  String get previewSample;

  /// No description provided for @deviceBody.
  ///
  /// In en, this message translates to:
  /// **'The pen is not connected. This screen uses a stand-in and never talks to Bluetooth.'**
  String get deviceBody;

  /// No description provided for @deviceSample.
  ///
  /// In en, this message translates to:
  /// **'A sentence sent from the pen stand-in.'**
  String get deviceSample;

  /// No description provided for @deviceSend.
  ///
  /// In en, this message translates to:
  /// **'Simulate a pen note'**
  String get deviceSend;

  /// No description provided for @deviceSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your library.'**
  String get deviceSaved;

  /// No description provided for @deviceFailed.
  ///
  /// In en, this message translates to:
  /// **'The stand-in note could not be saved.'**
  String get deviceFailed;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Continue to sign in'**
  String get onboardingStart;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Capture a sentence'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Photograph a page, record your voice, or type a note.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'One library'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Quotes, voice, and notes land in a single feed. Books are optional.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Ask later'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'HiLight AI will answer from your notes, and label when it does not.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What should Home show?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalBody.
  ///
  /// In en, this message translates to:
  /// **'You can keep both. This only changes the first screen.'**
  String get onboardingGoalBody;

  /// No description provided for @goalReader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get goalReader;

  /// No description provided for @goalLearner.
  ///
  /// In en, this message translates to:
  /// **'IELTS learner'**
  String get goalLearner;

  /// No description provided for @goalBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get goalBoth;

  /// No description provided for @homeHighlights.
  ///
  /// In en, this message translates to:
  /// **'Today\'s highlights'**
  String get homeHighlights;

  /// No description provided for @homeReviewDue.
  ///
  /// In en, this message translates to:
  /// **'Review due'**
  String get homeReviewDue;

  /// No description provided for @homeWordOfDay.
  ///
  /// In en, this message translates to:
  /// **'Word of the day'**
  String get homeWordOfDay;

  /// No description provided for @homeWordOfDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save a word and one will appear here.'**
  String get homeWordOfDayEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
