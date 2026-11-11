import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../../data/models/library_item.dart';
import '../../profile/application/settings_controller.dart';
import '../application/tutor_provider.dart';
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
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final mode in const ['explain', 'simplify', 'translate', 'grammar', 'quiz'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(_modeLabel(l10n, mode)),
                      onPressed: () => _act(mode),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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

  String _modeLabel(AppLocalizations l10n, String mode) {
    return switch (mode) {
      'simplify' => l10n.aiSimplify,
      'translate' => l10n.aiTranslate,
      'grammar' => l10n.aiGrammar,
      'quiz' => l10n.aiQuiz,
      _ => l10n.aiExplain,
    };
  }

  Future<void> _act(String mode) async {
    final l10n = AppLocalizations.of(context);
    final text = _input.text.trim().isNotEmpty ? _input.text.trim() : widget.focus?.text ?? '';
    if (text.isEmpty) return;
    final reply = await ref.read(tutorProvider).chat(
      text: text,
      mode: mode,
      targetLanguage: ref.read(settingsProvider).localeCode,
    );
    if (!mounted) return;
    final body = reply.limitReached ? l10n.aiLimit : '${reply.offline ? '${l10n.aiOffline}\n' : ''}${reply.text}';
    setState(() {
      _messages.add(_ChatMessage.user(_modeLabel(l10n, mode)));
      _messages.add(_ChatMessage.note(body));
    });
    if (mode == 'quiz' && !reply.limitReached) context.push('/quiz');
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
  _ChatMessage.user(this.text) : reply = null, fromUser = true;
  _ChatMessage.assistant(this.reply) : text = null, fromUser = false;
  _ChatMessage.note(this.text) : reply = null, fromUser = false;

  final String? text;
  final AiReply? reply;
  final bool fromUser;
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
        alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: colors.surface(radius: 18),
          child: Text(
            message.text ?? '',
            style: TextStyle(color: colors.text, fontFamily: HilightTheme.uiFont, fontSize: 15, height: 1.4),
          ),
        ),
      );
    }
    final fromNotes = reply.kind == AiAnswerKind.fromNotes;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: colors.surface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fromNotes ? l10n.aiFromNotes : l10n.aiGeneral,
            style: TextStyle(
              color: fromNotes ? colors.quote : colors.secondary,
              fontWeight: FontWeight.w500,
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
                    backgroundColor: colors.card,
                    side: BorderSide(color: colors.hairline),
                    labelStyle: TextStyle(
                      fontFamily: HilightTheme.uiFont,
                      fontSize: 13,
                      color: colors.text,
                    ),
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
