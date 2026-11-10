import '../../../data/models/library_item.dart';

enum AiAnswerKind { fromNotes, general }

class AiReply {
  const AiReply({required this.kind, required this.sources});

  final AiAnswerKind kind;
  final List<LibraryItem> sources;
}

abstract class AiRepository {
  AiReply answer(String prompt, {LibraryItem? focus});
}

/// Canned answers until a model is connected. A matching note is labeled
/// "from your notes"; everything else is general knowledge.
class FakeAiRepository implements AiRepository {
  const FakeAiRepository(this.items);

  final List<LibraryItem> items;

  @override
  AiReply answer(String prompt, {LibraryItem? focus}) {
    if (focus != null && focus.text.trim().isNotEmpty) {
      return AiReply(kind: AiAnswerKind.fromNotes, sources: [focus]);
    }
    final needle = prompt.trim().toLowerCase();
    if (needle.isEmpty) {
      return const AiReply(kind: AiAnswerKind.general, sources: []);
    }
    final hits = [
      for (final item in items)
        if (item.text.toLowerCase().contains(needle) ||
            (item.tag ?? '').toLowerCase().contains(needle))
          item,
    ];
    if (hits.isEmpty) {
      return const AiReply(kind: AiAnswerKind.general, sources: []);
    }
    return AiReply(kind: AiAnswerKind.fromNotes, sources: hits.take(3).toList());
  }
}
