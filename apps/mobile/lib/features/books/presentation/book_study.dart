import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../ai/application/tutor_provider.dart';
import '../../ai/domain/tutor_service.dart';
import '../domain/shelf_book.dart';

class BookStudy extends ConsumerWidget {
  const BookStudy({required this.book, required this.highlights, super.key});

  final ShelfBook book;
  final List<LibraryItem> highlights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notes = [for (final item in highlights) if (item.text.trim().isNotEmpty) item.text.trim()];
    return Wrap(
      spacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => _show(context, ref, summary: true, notes: notes),
          child: Text(l10n.bookSummary),
        ),
        OutlinedButton(
          onPressed: () => _show(context, ref, summary: false, notes: notes),
          child: Text(l10n.bookChat),
        ),
      ],
    );
  }

  Future<void> _show(
    BuildContext context,
    WidgetRef ref, {
    required bool summary,
    required List<String> notes,
  }) async {
    final l10n = AppLocalizations.of(context);
    final tutor = ref.read(tutorProvider);
    final question = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
          child: _StudySheet(
            title: summary ? l10n.bookSummary : l10n.bookChat,
            summary: summary,
            notes: notes,
            book: book,
            tutor: tutor,
            question: question,
          ),
        );
      },
    );
    question.dispose();
  }
}

class _StudySheet extends StatefulWidget {
  const _StudySheet({
    required this.title,
    required this.summary,
    required this.notes,
    required this.book,
    required this.tutor,
    required this.question,
  });

  final String title;
  final bool summary;
  final List<String> notes;
  final ShelfBook book;
  final TutorService tutor;
  final TextEditingController question;

  @override
  State<_StudySheet> createState() => _StudySheetState();
}

class _StudySheetState extends State<_StudySheet> {
  TutorReply? _reply;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.summary) _run();
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    final reply = widget.summary
        ? await widget.tutor.summarize(title: widget.book.title, bookId: widget.book.id, notes: widget.notes)
        : await widget.tutor.bookChat(
            title: widget.book.title,
            bookId: widget.book.id,
            question: widget.question.text.trim(),
            notes: widget.notes,
          );
    if (mounted) {
      setState(() {
        _reply = reply;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final reply = _reply;
    final label = reply == null
        ? null
        : reply.limitReached
        ? l10n.aiLimit
        : reply.kind == 'from_notes'
        ? l10n.aiFromNotes
        : l10n.aiGeneral;
    return ListView(
      shrinkWrap: true,
      children: [
        Text(widget.title, style: TextStyle(color: colors.text, fontWeight: FontWeight.w500)),
        if (!widget.summary) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.question,
            decoration: InputDecoration(hintText: l10n.bookChatHint),
            onSubmitted: (_) => _run(),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _busy ? null : _run, child: Text(l10n.aiSend)),
        ],
        const SizedBox(height: 12),
        if (_busy) const LinearProgressIndicator(minHeight: 2),
        if (widget.notes.isEmpty) Text(l10n.bookChatEmpty, style: TextStyle(color: colors.secondary)),
        if (label != null) Text(label, style: TextStyle(color: colors.secondary, fontSize: 13)),
        if (reply != null && reply.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(reply.text, style: TextStyle(color: colors.text, height: 1.4)),
          ),
        if (reply != null && reply.offline)
          Text(l10n.aiOffline, style: TextStyle(color: colors.secondary)),
      ],
    );
  }
}
