import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/country.dart';
import '../../../../presentation/providers/world_map_provider.dart';

/// Floating action button with globe spin animation for random country selection
class RandomCountryFab extends ConsumerStatefulWidget {
  const RandomCountryFab({
    super.key,
    required this.onCountrySelected,
    this.isLoading = false,
  });

  final void Function(Country country) onCountrySelected;
  final bool isLoading;

  @override
  ConsumerState<RandomCountryFab> createState() => _RandomCountryFabState();
}

class _RandomCountryFabState extends ConsumerState<RandomCountryFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 4 * math.pi, // Two full rotations
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener(_onAnimationStatus);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _isSpinning = false);
      _selectRandomCountry();
    }
  }

  Future<void> _onTap() async {
    if (_isSpinning || widget.isLoading) return;

    setState(() => _isSpinning = true);
    _controller.forward(from: 0);
  }

  void _selectRandomCountry() {
    final asyncRandomCountry = ref.read(randomCountryProvider);
    final randomCountry = asyncRandomCountry.valueOrNull;
    if (randomCountry != null) {
      widget.onCountrySelected(randomCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _onTap,
              heroTag: 'random_country_fab',
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              icon: _isSpinning
                  ? _SpinningGlobe()
                  : const Icon(Icons.public),
              label: Text(
                isArabic ? 'عشوائي' : 'Random',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated spinning globe icon
class _SpinningGlobe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.public);
  }
}

/// Compact FAB version (icon only)
class RandomCountryFabCompact extends ConsumerStatefulWidget {
  const RandomCountryFabCompact({
    super.key,
    required this.onCountrySelected,
  });

  final void Function(Country country) onCountrySelected;

  @override
  ConsumerState<RandomCountryFabCompact> createState() =>
      _RandomCountryFabCompactState();
}

class _RandomCountryFabCompactState
    extends ConsumerState<RandomCountryFabCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        _selectRandomCountry();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);
    _controller.forward(from: 0);
  }

  void _selectRandomCountry() {
    final asyncRandomCountry = ref.read(randomCountryProvider);
    final randomCountry = asyncRandomCountry.valueOrNull;
    if (randomCountry != null) {
      widget.onCountrySelected(randomCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rotation = _controller.value * 4 * math.pi;
        final scale = 1.0 + 0.2 * math.sin(_controller.value * math.pi);

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: FloatingActionButton(
              onPressed: _onTap,
              heroTag: 'random_country_fab_compact',
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.public),
            ),
          ),
        );
      },
    );
  }
}

/// Random country tooltip showing the selected country
class RandomCountryTooltip extends StatelessWidget {
  const RandomCountryTooltip({
    super.key,
    required this.country,
    required this.onExplore,
    required this.onDismiss,
  });

  final Country country;
  final VoidCallback onExplore;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final countryName = country.getDisplayName(isArabic: isArabic);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.casino,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'اكتشف!' : 'Discover!',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              countryName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (country.capital != null) ...[
              const SizedBox(height: 4),
              Text(
                country.capital!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onExplore,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(isArabic ? 'استكشف' : 'Explore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dice roll animation for random selection
class DiceRollAnimation extends StatefulWidget {
  const DiceRollAnimation({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  State<DiceRollAnimation> createState() => _DiceRollAnimationState();
}

class _DiceRollAnimationState extends State<DiceRollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _controller.value,
          child: Transform.rotate(
            angle: _controller.value * 6 * math.pi,
            child: Transform.scale(
              scale: 1 + _controller.value,
              child: const Icon(
                Icons.casino,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
