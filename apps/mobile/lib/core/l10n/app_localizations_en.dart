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

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get todayReview => 'Today\'s review';

  @override
  String get todayReviewEmpty => 'Older notes will show up here.';

  @override
  String get askAi => 'Ask HiLight AI';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navCapture => 'Capture';

  @override
  String get navInsights => 'Insights';

  @override
  String get navProfile => 'Profile';

  @override
  String get captureSheetTitle => 'Capture';

  @override
  String get captureWrite => 'Write note';

  @override
  String get writeTitle => 'Write a note';

  @override
  String get writeHint => 'Type a sentence';

  @override
  String get writeContinue => 'Continue';

  @override
  String get writeEmpty => 'Write something before continuing.';

  @override
  String get libraryTitle => 'Library';

  @override
  String get librarySearch => 'Search notes';

  @override
  String get libraryEmpty =>
      'Your library is empty. Capture a sentence to begin.';

  @override
  String get libraryNoMatches => 'Nothing matches this search.';

  @override
  String get filterAll => 'All';

  @override
  String get filterQuotes => 'Quotes';

  @override
  String get filterVoice => 'Voice';

  @override
  String get filterNotes => 'Notes';

  @override
  String get filterAi => 'AI';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsBody =>
      'Insights will gather patterns from your notes later. Your library already works without them.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get deviceTitle => 'Device';

  @override
  String get itemDetailTitle => 'Note';

  @override
  String get itemMissing => 'This note is no longer in the library.';

  @override
  String get itemCopy => 'Copy';

  @override
  String get itemCopied => 'Copied.';

  @override
  String get itemEdit => 'Edit';

  @override
  String get itemSave => 'Save';

  @override
  String get itemDelete => 'Delete';

  @override
  String get itemDeleteTitle => 'Delete this note?';

  @override
  String get itemDeleteBody => 'It will leave your library on this iPhone.';

  @override
  String get itemDeleteAction => 'Delete';

  @override
  String get discussAi => 'Discuss with HiLight AI';

  @override
  String get aiTitle => 'HiLight AI';

  @override
  String get aiHint => 'Ask about your notes';

  @override
  String get aiSend => 'Send';

  @override
  String get aiFromNotes => 'From your notes';

  @override
  String get aiGeneral => 'General knowledge';

  @override
  String get aiFromNotesBody =>
      'This answer stays with the notes below. The model is not connected yet.';

  @override
  String get aiGeneralBody =>
      'This is general knowledge. It is not drawn from your notes. The model is not connected yet.';

  @override
  String get aiEmpty => 'Ask a question about something you saved.';

  @override
  String get appearanceLanguage => 'Language';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get appearanceLayout => 'Library layout';

  @override
  String get layoutList => 'List';

  @override
  String get layoutCards => 'Cards';

  @override
  String get layoutCompact => 'Compact';

  @override
  String get appearanceAccent => 'Accent';

  @override
  String get appearanceFont => 'Font size';

  @override
  String get appearancePreview => 'Preview';

  @override
  String get previewSample => 'A sentence worth keeping.';

  @override
  String get deviceBody =>
      'The pen is not connected. This screen uses a stand-in and never talks to Bluetooth.';

  @override
  String get deviceSample => 'A sentence sent from the pen stand-in.';

  @override
  String get deviceSend => 'Simulate a pen note';

  @override
  String get deviceSaved => 'Saved to your library.';

  @override
  String get deviceFailed => 'The stand-in note could not be saved.';

  @override
  String get onboardingLanguage => 'Choose a language';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Continue to sign in';

  @override
  String get onboardingSlide1Title => 'Capture a sentence';

  @override
  String get onboardingSlide1Body =>
      'Photograph a page, record your voice, or type a note.';

  @override
  String get onboardingSlide2Title => 'One library';

  @override
  String get onboardingSlide2Body =>
      'Quotes, voice, and notes land in a single feed. Books are optional.';

  @override
  String get onboardingSlide3Title => 'Ask later';

  @override
  String get onboardingSlide3Body =>
      'HiLight AI will answer from your notes, and label when it does not.';

  @override
  String get onboardingGoalTitle => 'What should Home show?';

  @override
  String get onboardingGoalBody =>
      'You can keep both. This only changes the first screen.';

  @override
  String get goalReader => 'Reader';

  @override
  String get goalLearner => 'IELTS learner';

  @override
  String get goalBoth => 'Both';

  @override
  String get homeHighlights => 'Today\'s highlights';

  @override
  String get homeReviewDue => 'Review due';

  @override
  String get homeWordOfDay => 'Word of the day';

  @override
  String get homeWordOfDayEmpty => 'Save a word and one will appear here.';

  @override
  String get booksTitle => 'Books';

  @override
  String get feedTitle => 'Feed';

  @override
  String get booksEmpty =>
      'No books yet. Search a title, scan an ISBN, or type one in.';

  @override
  String get addBook => 'Add a book';

  @override
  String get searchBooks => 'Search by title';

  @override
  String get bookTitleField => 'Title';

  @override
  String get bookAuthorField => 'Author';

  @override
  String get bookPagesField => 'Pages';

  @override
  String get saveBook => 'Save book';

  @override
  String get scanIsbn => 'Scan ISBN';

  @override
  String get bookHighlights => 'Highlights';

  @override
  String get bookNoHighlights => 'Nothing from this book yet.';

  @override
  String get highlightNote => 'Note';

  @override
  String get highlightChapter => 'Chapter';

  @override
  String get highlightFavorite => 'Favorite';

  @override
  String get assignBook => 'Book';

  @override
  String get noBook => 'No book';

  @override
  String get lookupSave => 'Save to Vocab';

  @override
  String get lookupOffline => 'You are offline. The word was not saved.';

  @override
  String get lookupSpeak => 'Speak the word';

  @override
  String get vocabTitle => 'Vocabulary';

  @override
  String get vocabEmpty => 'No words yet. Open a highlight and save a word.';

  @override
  String get vocabSearch => 'Search words or tags';

  @override
  String get vocabUndo => 'Undo';

  @override
  String get vocabDeleted => 'Word removed.';

  @override
  String get masteryNew => 'New';

  @override
  String get masteryLearning => 'Learning';

  @override
  String get masteryKnown => 'Known';

  @override
  String get suggestTitle => 'Uncommon words';

  @override
  String get suggestSave => 'Save';

  @override
  String get reviewEmpty => 'Nothing is due. Come back tomorrow.';

  @override
  String get reviewAgain => 'Again';

  @override
  String get reviewHard => 'Hard';

  @override
  String get reviewGood => 'Good';

  @override
  String get reviewEasy => 'Easy';

  @override
  String get reviewShow => 'Show answer';

  @override
  String get reviewSummary => 'Session done';

  @override
  String get reviewStreak => 'Day streak';

  @override
  String get shareQuote => 'Share';

  @override
  String get insightsWords => 'Words learned';

  @override
  String get insightsPerBook => 'Highlights by book';

  @override
  String get insightsWeek => 'This week';

  @override
  String get insightsEmpty =>
      'Save a highlight or review a card to see this fill in.';

  @override
  String get reminderTitle => 'Daily review';

  @override
  String get reminderBody =>
      'HiLight will remind you at the time you choose. You can say no.';

  @override
  String get reminderAllow => 'Allow reminders';

  @override
  String get ieltsTitle => 'IELTS practice';

  @override
  String get ieltsEmpty => 'Nothing on this shelf yet.';

  @override
  String get ieltsVocab => 'Vocab';

  @override
  String get ieltsListening => 'Listening';

  @override
  String get ieltsReading => 'Reading';

  @override
  String get ieltsWriting => 'Writing';

  @override
  String get ieltsOfficial => 'Official resources';

  @override
  String get ieltsOfficialBody =>
      'These links leave HiLight. The practice lines here were written for the app.';

  @override
  String get ieltsTask1 => 'Task 1';

  @override
  String get ieltsTask2 => 'Task 2';

  @override
  String get ieltsBefore => 'Before';

  @override
  String get ieltsUpgrade => 'Upgrade my sentence';

  @override
  String get ieltsDisclaimer =>
      'Practice feedback, not an official IELTS score.';

  @override
  String get topicEducation => 'Education';

  @override
  String get topicEnvironment => 'Environment';

  @override
  String get topicTechnology => 'Technology';

  @override
  String get topicHealth => 'Health';

  @override
  String get topicWork => 'Work';

  @override
  String get topicSociety => 'Society';

  @override
  String get quizTitle => 'Quiz';

  @override
  String get quizBlank => 'Fill the gap';

  @override
  String get quizChoice => 'Choose';

  @override
  String get quizDictation => 'Dictation';

  @override
  String get quizCheck => 'Check';

  @override
  String get quizCorrect => 'Kept. This card moves forward.';

  @override
  String get quizAgain => 'Missed. This card comes back sooner.';

  @override
  String get quizEmpty => 'Save a sentence or a word first.';

  @override
  String get quizSpeak => 'Play the sentence';

  @override
  String get aiExplain => 'Explain';

  @override
  String get aiSimplify => 'Simplify';

  @override
  String get aiTranslate => 'Translate';

  @override
  String get aiGrammar => 'Grammar';

  @override
  String get aiQuiz => 'Quiz me';

  @override
  String get aiLimit => 'Today\'s tutor limit is used. It resets tomorrow.';

  @override
  String get aiOffline => 'Offline practice. This was not sent to the tutor.';

  @override
  String get importTitle => 'Import';

  @override
  String get importPick => 'Choose a file';

  @override
  String get importSave => 'Save highlights';

  @override
  String get importEmpty => 'Nothing new to save.';

  @override
  String get importDuplicates => 'Duplicates skipped';

  @override
  String get searchMeaning => 'Meaning';

  @override
  String get searchWords => 'Words';

  @override
  String get relatedTitle => 'Related';

  @override
  String get relatedEmpty => 'No related note yet.';
}
