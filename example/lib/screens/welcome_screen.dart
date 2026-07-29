import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16),
              Text(
                'Choose a demo',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All processing uses derived face-action signals only.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  children: <Widget>[
                    _DemoCard(
                      animation: _stagger,
                      index: 0,
                      icon: Icons.monitor_heart_outlined,
                      title: 'Real-time detection',
                      subtitle: 'Camera + live config tuning panel',
                      color: Colors.cyan,
                      onTap: () => Navigator.pushNamed(context, '/realtime'),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 1,
                      icon: Icons.videocam_outlined,
                      title: 'Live camera demo',
                      subtitle: 'Real-time face signals with camera preview',
                      color: theme.colorScheme.primary,
                      onTap: () => Navigator.pushNamed(context, '/permission'),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 2,
                      icon: Icons.verified_user_outlined,
                      title: 'Live challenge',
                      subtitle: 'Guided steps: blink, turn, hold still',
                      color: Colors.teal,
                      onTap: () =>
                          Navigator.pushNamed(context, '/live-challenge'),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 3,
                      icon: Icons.gps_fixed_rounded,
                      title: 'Follow the dot',
                      subtitle: 'Move face to track on-screen targets',
                      color: Colors.amber.shade700,
                      onTap: () => Navigator.pushNamed(context, '/follow-dot'),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 4,
                      icon: Icons.shuffle_rounded,
                      title: 'Randomized challenge',
                      subtitle: 'Shuffled sequence with nonce',
                      color: Colors.deepOrange,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/live-challenge-random',
                      ),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 5,
                      icon: Icons.science_outlined,
                      title: 'Simulated flow',
                      subtitle: 'Camera-free state machine — tap to advance',
                      color: Colors.indigo,
                      onTap: () => Navigator.pushNamed(context, '/challenge'),
                    ),
                    _DemoCard(
                      animation: _stagger,
                      index: 6,
                      icon: Icons.casino_outlined,
                      title: 'Simulated randomized',
                      subtitle: 'Camera-free randomized — tap to advance',
                      color: Colors.purple,
                      onTap: () =>
                          Navigator.pushNamed(context, '/challenge-random'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.animation,
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final AnimationController animation;
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.12).clamp(0.0, 0.6);
    final itemAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        delay,
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: itemAnimation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(itemAnimation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
