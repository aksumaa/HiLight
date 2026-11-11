enum WordMastery { newWord, learning, known }

class VocabWord {
  const VocabWord({
    required this.id,
    required this.word,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    required this.updatedAt,
    this.translation = '',
    this.definition = '',
    this.example = '',
    this.partOfSpeech = '',
    this.sourceSentence = '',
    this.sourceItemId,
    this.tags = '',
    this.mastery = WordMastery.newWord,
    this.deletedAt,
    this.dirty = false,
  });

  final String id;
  final String word;
  final String sourceLanguage;
  final String targetLanguage;
  final String translation;
  final String definition;
  final String example;
  final String partOfSpeech;
  final String sourceSentence;
  final String? sourceItemId;
  final String tags;
  final WordMastery mastery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool dirty;

  VocabWord copyWith({
    WordMastery? mastery,
    String? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? dirty,
    bool clearDeleted = false,
  }) {
    return VocabWord(
      id: id,
      word: word,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translation: translation,
      definition: definition,
      example: example,
      partOfSpeech: partOfSpeech,
      sourceSentence: sourceSentence,
      sourceItemId: sourceItemId,
      tags: tags ?? this.tags,
      mastery: mastery ?? this.mastery,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeleted ? null : deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
    );
  }
}

class LookupResult {
  const LookupResult({
    required this.word,
    required this.translation,
    required this.definition,
    required this.example,
    required this.partOfSpeech,
  });

  final String word;
  final String translation;
  final String definition;
  final String example;
  final String partOfSpeech;
}
