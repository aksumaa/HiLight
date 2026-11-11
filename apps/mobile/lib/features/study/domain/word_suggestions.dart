/// Common English words written for this app. This is not a published
/// frequency corpus, so there is no external license. A word of five or more
/// letters that is missing from this set is treated as uncommon.
const commonEnglishWords = {
  'about', 'above', 'after', 'again', 'against', 'alone', 'along', 'already',
  'also', 'although', 'always', 'among', 'another', 'answer', 'around', 'because',
  'before', 'begin', 'being', 'below', 'between', 'black', 'book', 'both',
  'bring', 'build', 'called', 'came', 'cannot', 'change', 'children', 'city',
  'close', 'come', 'could', 'country', 'course', 'day', 'different', 'does',
  'done', 'down', 'during', 'each', 'early', 'earth', 'enough', 'even',
  'every', 'example', 'family', 'father', 'feel', 'felt', 'find', 'first',
  'follow', 'found', 'from', 'give', 'going', 'good', 'great', 'group',
  'hand', 'have', 'head', 'heard', 'help', 'here', 'high', 'home',
  'house', 'however', 'human', 'idea', 'important', 'into', 'just', 'keep',
  'kind', 'know', 'large', 'last', 'later', 'learn', 'leave', 'left',
  'life', 'light', 'like', 'line', 'little', 'live', 'long', 'look',
  'made', 'make', 'many', 'might', 'more', 'most', 'mother', 'move',
  'much', 'must', 'name', 'need', 'never', 'next', 'night', 'number',
  'often', 'once', 'only', 'open', 'order', 'other', 'over', 'page',
  'part', 'people', 'place', 'point', 'power', 'problem', 'question', 'read',
  'really', 'right', 'said', 'same', 'school', 'second', 'see', 'seem',
  'sentence', 'should', 'show', 'since', 'small', 'some', 'something', 'sound',
  'still', 'story', 'study', 'such', 'take', 'tell', 'than', 'that',
  'their', 'them', 'then', 'there', 'these', 'they', 'thing', 'think',
  'this', 'those', 'thought', 'three', 'through', 'time', 'today', 'together',
  'turn', 'under', 'until', 'used', 'very', 'want', 'water', 'way',
  'well', 'went', 'were', 'what', 'when', 'where', 'which', 'while',
  'white', 'will', 'with', 'word', 'work', 'world', 'would', 'write',
  'year', 'young', 'your',
};

List<String> uncommonWords(String text, Set<String> alreadySaved) {
  final found = <String>[];
  for (final match in RegExp("[A-Za-z][A-Za-z'-]{4,}").allMatches(text)) {
    final word = match.group(0)!.toLowerCase().replaceAll("'", '');
    if (word.length < 5) continue;
    if (commonEnglishWords.contains(word) || alreadySaved.contains(word)) continue;
    if (found.contains(word)) continue;
    found.add(word);
    if (found.length == 5) break;
  }
  return found;
}
