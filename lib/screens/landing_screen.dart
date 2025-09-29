import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Column(
                children: [
                  Text(
                    'Tindahan Ko',
                    style: GoogleFonts.greatVibes(
                      fontSize: 64,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Para sa mga Reyna ng Tahanan 👑',
                    style: GoogleFonts.dancingScript(
                      fontSize: 24,
                      color: AppTheme.lightPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).py32(),
              
              // Platform Selection
              Column(
                children: [
                  Text(
                    'Choose Platform:',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ).pb16(),
                  
                  // Android Button
                  _PlatformButton(
                    icon: '🤖',
                    title: 'Android Version',
                    subtitle: 'Native Android Experience',
                    onTap: () => _navigateToApp(context, 'android'),
                  ).pb12(),
                  
                  // iOS Button
                  _PlatformButton(
                    icon: '🍎',
                    title: 'iOS Version',
                    subtitle: 'Native iOS Experience',
                    onTap: () => _navigateToApp(context, 'ios'),
                  ).pb12(),
                  
                  // Web Button
                  _PlatformButton(
                    icon: '🌐',
                    title: 'Web Version',
                    subtitle: 'Cross-platform Web App',
                    isSecondary: true,
                    onTap: () => _navigateToApp(context, 'web'),
                  ),
                ],
              ).px32(),
              
              const Spacer(),
              
              Text(
                'Select your platform to experience the app!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.lightPink,
                ),
                textAlign: TextAlign.center,
              ).px32().pb32(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToApp(BuildContext context, String platform) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(platform: platform),
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
          ? Colors.white.withOpacity(0.2)
          : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
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
                16.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
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