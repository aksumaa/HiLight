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

  /// No description provided for @booksTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksTitle;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedTitle;

  /// No description provided for @booksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No books yet. Search a title, scan an ISBN, or type one in.'**
  String get booksEmpty;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get addBook;

  /// No description provided for @searchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get searchBooks;

  /// No description provided for @bookTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookTitleField;

  /// No description provided for @bookAuthorField.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get bookAuthorField;

  /// No description provided for @bookPagesField.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get bookPagesField;

  /// No description provided for @saveBook.
  ///
  /// In en, this message translates to:
  /// **'Save book'**
  String get saveBook;

  /// No description provided for @scanIsbn.
  ///
  /// In en, this message translates to:
  /// **'Scan ISBN'**
  String get scanIsbn;

  /// No description provided for @bookHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get bookHighlights;

  /// No description provided for @bookNoHighlights.
  ///
  /// In en, this message translates to:
  /// **'Nothing from this book yet.'**
  String get bookNoHighlights;

  /// No description provided for @highlightNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get highlightNote;

  /// No description provided for @highlightChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get highlightChapter;

  /// No description provided for @highlightFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get highlightFavorite;

  /// No description provided for @assignBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get assignBook;

  /// No description provided for @noBook.
  ///
  /// In en, this message translates to:
  /// **'No book'**
  String get noBook;

  /// No description provided for @lookupSave.
  ///
  /// In en, this message translates to:
  /// **'Save to Vocab'**
  String get lookupSave;

  /// No description provided for @lookupOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. The word was not saved.'**
  String get lookupOffline;

  /// No description provided for @lookupSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak the word'**
  String get lookupSpeak;

  /// No description provided for @vocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabTitle;

  /// No description provided for @vocabEmpty.
  ///
  /// In en, this message translates to:
  /// **'No words yet. Open a highlight and save a word.'**
  String get vocabEmpty;

  /// No description provided for @vocabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search words or tags'**
  String get vocabSearch;

  /// No description provided for @vocabUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get vocabUndo;

  /// No description provided for @vocabDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word removed.'**
  String get vocabDeleted;

  /// No description provided for @masteryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get masteryNew;

  /// No description provided for @masteryLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get masteryLearning;

  /// No description provided for @masteryKnown.
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get masteryKnown;

  /// No description provided for @suggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Uncommon words'**
  String get suggestTitle;

  /// No description provided for @suggestSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get suggestSave;

  /// No description provided for @reviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is due. Come back tomorrow.'**
  String get reviewEmpty;

  /// No description provided for @reviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get reviewAgain;

  /// No description provided for @reviewHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get reviewHard;

  /// No description provided for @reviewGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reviewGood;

  /// No description provided for @reviewEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get reviewEasy;

  /// No description provided for @reviewShow.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get reviewShow;

  /// No description provided for @reviewSummary.
  ///
  /// In en, this message translates to:
  /// **'Session done'**
  String get reviewSummary;

  /// No description provided for @reviewStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get reviewStreak;

  /// No description provided for @shareQuote.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareQuote;

  /// No description provided for @insightsWords.
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get insightsWords;

  /// No description provided for @insightsPerBook.
  ///
  /// In en, this message translates to:
  /// **'Highlights by book'**
  String get insightsPerBook;

  /// No description provided for @insightsWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get insightsWeek;

  /// No description provided for @insightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save a highlight or review a card to see this fill in.'**
  String get insightsEmpty;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily review'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'HiLight will remind you at the time you choose. You can say no.'**
  String get reminderBody;

  /// No description provided for @reminderAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders'**
  String get reminderAllow;

  /// No description provided for @ieltsTitle.
  ///
  /// In en, this message translates to:
  /// **'IELTS practice'**
  String get ieltsTitle;

  /// No description provided for @ieltsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this shelf yet.'**
  String get ieltsEmpty;

  /// No description provided for @ieltsVocab.
  ///
  /// In en, this message translates to:
  /// **'Vocab'**
  String get ieltsVocab;

  /// No description provided for @ieltsListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get ieltsListening;

  /// No description provided for @ieltsReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get ieltsReading;

  /// No description provided for @ieltsWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get ieltsWriting;

  /// No description provided for @ieltsOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official resources'**
  String get ieltsOfficial;

  /// No description provided for @ieltsOfficialBody.
  ///
  /// In en, this message translates to:
  /// **'These links leave HiLight. The practice lines here were written for the app.'**
  String get ieltsOfficialBody;

  /// No description provided for @ieltsTask1.
  ///
  /// In en, this message translates to:
  /// **'Task 1'**
  String get ieltsTask1;

  /// No description provided for @ieltsTask2.
  ///
  /// In en, this message translates to:
  /// **'Task 2'**
  String get ieltsTask2;

  /// No description provided for @ieltsBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get ieltsBefore;

  /// No description provided for @ieltsUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade my sentence'**
  String get ieltsUpgrade;

  /// No description provided for @ieltsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Practice feedback, not an official IELTS score.'**
  String get ieltsDisclaimer;

  /// No description provided for @topicEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get topicEducation;

  /// No description provided for @topicEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get topicEnvironment;

  /// No description provided for @topicTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get topicTechnology;

  /// No description provided for @topicHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get topicHealth;

  /// No description provided for @topicWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get topicWork;

  /// No description provided for @topicSociety.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get topicSociety;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @quizBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill the gap'**
  String get quizBlank;

  /// No description provided for @quizChoice.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get quizChoice;

  /// No description provided for @quizDictation.
  ///
  /// In en, this message translates to:
  /// **'Dictation'**
  String get quizDictation;

  /// No description provided for @quizCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get quizCheck;

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Kept. This card moves forward.'**
  String get quizCorrect;

  /// No description provided for @quizAgain.
  ///
  /// In en, this message translates to:
  /// **'Missed. This card comes back sooner.'**
  String get quizAgain;

  /// No description provided for @quizEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save a sentence or a word first.'**
  String get quizEmpty;

  /// No description provided for @quizSpeak.
  ///
  /// In en, this message translates to:
  /// **'Play the sentence'**
  String get quizSpeak;

  /// No description provided for @aiExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get aiExplain;

  /// No description provided for @aiSimplify.
  ///
  /// In en, this message translates to:
  /// **'Simplify'**
  String get aiSimplify;

  /// No description provided for @aiTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get aiTranslate;

  /// No description provided for @aiGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get aiGrammar;

  /// No description provided for @aiQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz me'**
  String get aiQuiz;

  /// No description provided for @aiLimit.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tutor limit is used. It resets tomorrow.'**
  String get aiLimit;

  /// No description provided for @aiOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline practice. This was not sent to the tutor.'**
  String get aiOffline;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get importPick;

  /// No description provided for @importSave.
  ///
  /// In en, this message translates to:
  /// **'Save highlights'**
  String get importSave;

  /// No description provided for @importEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to save.'**
  String get importEmpty;

  /// No description provided for @importDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates skipped'**
  String get importDuplicates;

  /// No description provided for @searchMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get searchMeaning;

  /// No description provided for @searchWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get searchWords;

  /// No description provided for @relatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get relatedTitle;

  /// No description provided for @relatedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No related note yet.'**
  String get relatedEmpty;

  /// No description provided for @shareSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved from another app.'**
  String get shareSaved;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save a highlight or a word first.'**
  String get exportEmpty;

  /// No description provided for @exportObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian folder'**
  String get exportObsidian;

  /// No description provided for @exportObsidianBody.
  ///
  /// In en, this message translates to:
  /// **'One Markdown note per book, ready to drop into a vault.'**
  String get exportObsidianBody;

  /// No description provided for @exportNotion.
  ///
  /// In en, this message translates to:
  /// **'Notion Markdown'**
  String get exportNotion;

  /// No description provided for @exportNotionBody.
  ///
  /// In en, this message translates to:
  /// **'One document with a heading for each book.'**
  String get exportNotionBody;

  /// No description provided for @exportAnki.
  ///
  /// In en, this message translates to:
  /// **'Anki CSV'**
  String get exportAnki;

  /// No description provided for @exportAnkiBody.
  ///
  /// In en, this message translates to:
  /// **'Front, back, and tags from your vocabulary.'**
  String get exportAnkiBody;
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
