import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        return Scaffold(
          resizeToAvoidBottomInset: true,
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
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                  
                  // Header with stylized logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tindahan Ko',
                          style: GoogleFonts.getFont(
                            'Imperial Script',
                            fontSize: 48,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Para sa mga Reyna ng Tindahan',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Text(
                    'Setup Your Store',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your store information to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _storeNameController,
                            label: 'Store Name',
                            hint: 'e.g., Aling Maria\'s Sari-Sari Store',
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _ownerNameController,
                            label: 'Store Owner',
                            hint: 'e.g., Maria Santos',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _addressController,
                            label: 'Store Address',
                            hint: 'e.g., 123 Barangay Street, City',
                            icon: Icons.location_on,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  
                  // Continue Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveStoreInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: theme.colorScheme.primary)
                          : Text(
                              'Start Selling! 🚀',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveStoreInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('store_name', _storeNameController.text.trim());
      await prefs.setString('owner_name', _ownerNameController.text.trim());
      await prefs.setString('store_address', _addressController.text.trim());
      await prefs.setBool('is_setup_complete', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving store information')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}