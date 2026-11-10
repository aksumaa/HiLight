import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../domain/capture_event.dart';
import '../domain/recognition.dart';
import 'capture_frame_overlay.dart';
import 'language_chips.dart';
import 'permission_denied_view.dart';

enum _ScanPhase { starting, ready, denied, unavailable }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  _ScanPhase _phase = _ScanPhase.starting;
  var _flashOn = false;
  var _taking = false;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _phase = _ScanPhase.unavailable);
        return;
      }
      final camera = cameras.firstWhere(
        (candidate) => candidate.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _phase = _ScanPhase.ready;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      final denied = permissionFromCameraCode(error.code) != null;
      setState(() => _phase = denied ? _ScanPhase.denied : _ScanPhase.unavailable);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    final next = _flashOn ? FlashMode.off : FlashMode.torch;
    try {
      await controller.setFlashMode(next);
      if (mounted) setState(() => _flashOn = !_flashOn);
    } on CameraException {
      if (mounted) setState(() => _flashOn = false);
    }
  }

  Future<void> _take() async {
    final controller = _controller;
    if (controller == null || _taking || !controller.value.isInitialized) return;
    setState(() => _taking = true);
    try {
      final shot = await controller.takePicture();
      final language = ref.read(captureLanguageProvider);
      final event = await ref
          .read(phoneCameraSourceProvider)
          .capture(CaptureInput(filePath: shot.path, languageCode: language));
      final processed = await ref.read(capturePipelineProvider).process(event);
      if (!mounted) return;
      await context.push('/capture/edit', extra: processed);
      await controller.resumePreview();
    } on CameraException catch (error) {
      if (!mounted) return;
      if (permissionFromCameraCode(error.code) != null) {
        setState(() => _phase = _ScanPhase.denied);
      }
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return switch (_phase) {
      _ScanPhase.denied => PermissionDeniedView(
        title: l10n.scanPermissionTitle,
        body: l10n.scanPermissionBody,
      ),
      _ScanPhase.unavailable => Scaffold(
        appBar: AppBar(title: Text(l10n.scanTitle)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.scanNoCamera),
        ),
      ),
      _ScanPhase.starting || _ScanPhase.ready => Scaffold(
        backgroundColor: colors.background,
        body: _preview(context, l10n, colors),
      ),
    };
  }

  Widget _preview(
    BuildContext context,
    AppLocalizations l10n,
    HilightColors colors,
  ) {
    final controller = _controller;
    final language = ref.watch(captureLanguageProvider);
    final config = ref.watch(recognitionConfigProvider);
    final onDevice = OcrRouter.onDeviceLanguageCodes.contains(language);
    final engine = onDevice
        ? l10n.scanEngineOnDevice
        : config.useFakeOcr
        ? l10n.scanEngineServerStub
        : l10n.scanEngineServer;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          CameraPreview(controller)
        else
          ColoredBox(color: colors.background),
        const CaptureFrameOverlay(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.close,
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    _RoundIconButton(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      tooltip: _flashOn ? l10n.scanFlashOn : l10n.scanFlashOff,
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(HilightColors.radius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      engine,
                      style: TextStyle(
                        fontFamily: HilightTheme.uiFont,
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const LanguageChips(),
                const SizedBox(height: 16),
                _Shutter(
                  label: l10n.scanShutter,
                  busy: _taking,
                  onPressed: _phase == _ScanPhase.ready ? _take : null,
                ),
                if (_taking) ...[
                  const SizedBox(height: 12),
                  Text(l10n.scanProcessing, style: TextStyle(color: colors.card)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return IconButton.filled(
      tooltip: tooltip,
      style: IconButton.styleFrom(backgroundColor: colors.card, foregroundColor: colors.text),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: busy ? null : onPressed,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.card,
            border: Border.all(color: colors.primary, width: 4),
          ),
          child: busy
              ? Padding(
                  padding: const EdgeInsets.all(22),
                  child: CircularProgressIndicator(color: colors.primary, strokeWidth: 3),
                )
              : null,
        ),
      ),
    );
  }
}
