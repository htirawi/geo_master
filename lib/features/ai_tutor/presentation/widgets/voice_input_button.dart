import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/speech_service.dart';

/// Animated voice input button for speech-to-text
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size = 48,
    this.isEnabled = true,
  });

  final bool isListening;
  final VoidCallback onPressed;
  final double size;
  final bool isEnabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse animation background
              if (widget.isListening)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              // Main button
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isListening
                      ? AppColors.error
                      : widget.isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  boxShadow: widget.isListening
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Voice input overlay that shows transcription in real-time
class VoiceInputOverlay extends StatelessWidget {
  const VoiceInputOverlay({
    super.key,
    required this.transcription,
    required this.status,
    required this.onCancel,
    required this.onDone,
    this.isArabic = false,
  });

  final String transcription;
  final SpeechStatus status;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg - 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingDot(isActive: status == SpeechStatus.listening),
              const SizedBox(width: AppDimensions.xs),
              Text(
                status == SpeechStatus.listening
                    ? 'Listening...'
                    : status == SpeechStatus.done
                        ? 'Done'
                        : 'Ready',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Transcription
          Container(
            constraints: const BoxConstraints(
              minHeight: 80,
              maxHeight: 200,
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: SingleChildScrollView(
              child: Text(
                transcription.isEmpty
                    ? isArabic
                        ? 'تحدث الآن...'
                        : 'Speak now...'
                    : transcription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: transcription.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                  fontStyle: transcription.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                label: Text(isArabic ? 'إلغاء' : 'Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
              FilledButton.icon(
                onPressed: transcription.isNotEmpty ? onDone : null,
                icon: const Icon(Icons.send),
                label: Text(isArabic ? 'إرسال' : 'Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot indicator for recording status
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.isActive});

  final bool isActive;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? AppColors.error.withValues(alpha: _animation.value)
                : Colors.grey,
          ),
        );
      },
    );
  }
}
