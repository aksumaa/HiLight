/// Original practice lines written for this app. These are not taken from
/// official or commercial IELTS books. Official pages are linked, not copied.
enum IeltsShelf { vocab, listening, reading, writing }

enum IeltsTopic { education, environment, technology, health, work, society }

enum IeltsTask { task1, task2 }

class IeltsEntry {
  const IeltsEntry({
    required this.shelf,
    required this.topic,
    required this.text,
    this.note,
    this.task,
    this.word,
    this.translation,
  });

  final IeltsShelf shelf;
  final IeltsTopic topic;
  final String text;
  final String? note;
  final IeltsTask? task;
  final String? word;
  final String? translation;

  String get tag => 'ielts/${shelf.name}/${topic.name}';
}

const ieltsOfficialLinks = [
  'https://ielts.org/',
  'https://takeielts.britishcouncil.org/',
  'https://www.cambridgeenglish.org/exams-and-tests/ielts/',
];

const ieltsStarter = <IeltsEntry>[
  IeltsEntry(
    shelf: IeltsShelf.vocab,
    topic: IeltsTopic.education,
    text: 'curriculum',
    word: 'curriculum',
    translation: 'a planned course of study',
    note: 'A school published its curriculum so families could see the year ahead.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.vocab,
    topic: IeltsTopic.environment,
    text: 'habitat',
    word: 'habitat',
    translation: 'the place a living thing needs',
    note: 'The park kept a small habitat for the birds that nest there.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.vocab,
    topic: IeltsTopic.technology,
    text: 'automation',
    word: 'automation',
    translation: 'work done by a machine',
    note: 'Automation folded the letters, and people still checked the names.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.vocab,
    topic: IeltsTopic.health,
    text: 'prevention',
    word: 'prevention',
    translation: 'stopping a problem before it starts',
    note: 'Prevention was the clinic\'s plain advice: sleep, water, and a walk.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.listening,
    topic: IeltsTopic.education,
    text: 'set aside time',
    note: 'Optional audio note: record yourself saying this phrase.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.listening,
    topic: IeltsTopic.environment,
    text: 'cut back on waste',
    note: 'Optional audio note: record yourself saying this phrase.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.reading,
    topic: IeltsTopic.technology,
    text: 'The town library lent tablets, then asked readers what they had finished. Most people used them to look up a repair, not to watch a film.',
    note: 'Question: What did most people use the tablets for?',
  ),
  IeltsEntry(
    shelf: IeltsShelf.reading,
    topic: IeltsTopic.health,
    text: 'The clinic opened an hour earlier in winter. People came for a check before work, and the waiting room stayed quiet.',
    note: 'Question: When did the clinic change its hours?',
  ),
  IeltsEntry(
    shelf: IeltsShelf.writing,
    topic: IeltsTopic.education,
    task: IeltsTask.task2,
    text: 'Schools give people a shared place to practise a skill.',
    note: 'School is good for people.',
  ),
  IeltsEntry(
    shelf: IeltsShelf.writing,
    topic: IeltsTopic.work,
    task: IeltsTask.task1,
    text: 'The chart would show how many hours the team spent with customers.',
    note: 'The chart is about work time.',
  ),
];
