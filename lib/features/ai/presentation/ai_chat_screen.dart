import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';
import '../domain/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final items = ref.watch(libraryItemsProvider).value ?? const <LibraryItem>[];
  return FakeAiRepository(items);
});

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({this.focus, super.key});

  final LibraryItem? focus;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _messages = <_ChatMessage>[];

  @override
  void initState() {
    super.initState();
    final focus = widget.focus;
    if (focus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final reply = ref.read(aiRepositoryProvider).answer(focus.text, focus: focus);
        setState(() => _messages.add(_ChatMessage.assistant(reply)));
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiTitle)),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.aiEmpty, style: TextStyle(color: colors.secondary, height: 1.4)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    children: [
                      for (final message in _messages) _MessageView(message: message),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(hintText: l10n.aiHint),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: l10n.aiSend,
                  onPressed: _send,
                  icon: Icon(Icons.send, color: colors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final reply = ref.read(aiRepositoryProvider).answer(text);
    setState(() {
      _messages.add(_ChatMessage.user(text));
      _messages.add(_ChatMessage.assistant(reply));
      _input.clear();
    });
  }
}

class _ChatMessage {
  _ChatMessage.user(this.text) : reply = null;
  _ChatMessage.assistant(this.reply) : text = null;

  final String? text;
  final AiReply? reply;
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final reply = message.reply;
    if (reply == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(HilightColors.radius),
          ),
          child: Text(
            message.text ?? '',
            style: TextStyle(color: colors.card, fontFamily: HilightTheme.uiFont),
          ),
        ),
      );
    }
    final fromNotes = reply.kind == AiAnswerKind.fromNotes;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(HilightColors.radius),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fromNotes ? l10n.aiFromNotes : l10n.aiGeneral,
            style: TextStyle(
              color: fromNotes ? colors.quote : colors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fromNotes ? l10n.aiFromNotesBody : l10n.aiGeneralBody,
            style: const TextStyle(fontFamily: HilightTheme.uiFont, height: 1.4),
          ),
          if (reply.sources.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in reply.sources)
                  ActionChip(
                    label: Text(_snippet(item.text), overflow: TextOverflow.ellipsis),
                    onPressed: () => context.push('/item/${item.id}'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _snippet(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 42) return trimmed;
    return '${trimmed.substring(0, 42)}…';
  }
}
