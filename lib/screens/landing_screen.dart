import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF6F7FB),
                  Color(0xFFE5E7EB),
                ],
              ),
            ),
            child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Column(
                  children: [
                    Text(
                      'Tindahan Ko',
                      style: GoogleFonts.getFont(
                        'Imperial Script',
                        fontSize: 64,
                        color: theme.colorScheme.primary,
                        shadows: [
                          const Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Para sa mga Reyna ng Tindahan',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Choggy Bear Mini Store',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Platform Selection
                Column(
                  children: [
                    Text(
                      'Choose Platform:',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Android Button
                    _PlatformButton(
                      icon: '🤖',
                      title: 'Android Version',
                      subtitle: 'Native Android Experience',
                      onTap: () => _navigateToApp(context, 'android'),
                    ),
                    const SizedBox(height: 12),
                    
                    // iOS Button
                    _PlatformButton(
                      icon: '🍎',
                      title: 'iOS Version',
                      subtitle: 'Native iOS Experience',
                      onTap: () => _navigateToApp(context, 'ios'),
                    ),
                    const SizedBox(height: 12),
                    
                    // Web Button
                    _PlatformButton(
                      icon: '🌐',
                      title: 'Web Version',
                      subtitle: 'Cross-platform Web App',
                      isSecondary: true,
                      onTap: () => _navigateToApp(context, 'web'),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                Text(
                  'Select your platform to experience the app!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToApp(BuildContext context, String platform) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSecondary;

  const _PlatformButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSecondary 
          ? Theme.of(context).colorScheme.surface.withOpacity(0.3)
          : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}