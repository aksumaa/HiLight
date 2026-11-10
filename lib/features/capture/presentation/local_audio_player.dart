import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';

class LocalAudioPlayer extends StatefulWidget {
  const LocalAudioPlayer({required this.path, super.key});

  final String path;

  @override
  State<LocalAudioPlayer> createState() => _LocalAudioPlayerState();
}

class _LocalAudioPlayerState extends State<LocalAudioPlayer> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _states;
  PlayerState _state = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _states = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  @override
  void dispose() {
    _states?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
      return;
    }
    await _player.play(DeviceFileSource(widget.path));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    final playing = _state == PlayerState.playing;
    return DecoratedBox(
      decoration: colors.surface(),
      child: ListTile(
        leading: Icon(Icons.graphic_eq, color: colors.text),
        title: Text(
          widget.path.split('/').last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: HilightTheme.uiFont),
        ),
        trailing: IconButton(
          onPressed: _toggle,
          icon: Icon(playing ? Icons.pause_circle_outline : Icons.play_circle_outline, color: colors.text),
        ),
      ),
    );
  }
}
