import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/glass_card.dart';
import '../../animations/section_reveal.dart';
import '../../core/services/contact_service.dart';

/// Contact page with a dynamic form.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ContactService().sendMessage(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          message: _messageController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _submitted = true;
            _isLoading = false;
          });
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _submitted = false);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: AppTextStyles.mono(size: 12, color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.error.withOpacity(0.95),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 5),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 40 : 80),
                  _buildForm(context, isMobile),
                  SizedBox(height: isMobile ? 40 : 80),
                  const AppFooter(),
                  if (isMobile) const SizedBox(height: AppBottomNavBar.totalHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 5)
          : body,
    );
  }

  Widget _buildForm(BuildContext context, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppStrings.contactTitle, style: isMobile ? AppTextStyles.sectionTitleMobile : AppTextStyles.sectionTitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(AppStrings.contactSubtitle, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField('Name', _nameController, 'Your full name'),
                      const SizedBox(height: 20),
                      _buildField('Email', _emailController, 'you@example.com', isEmail: true),
                      const SizedBox(height: 20),
                      _buildField('Message', _messageController, 'Tell me about your project...', maxLines: 5),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _submitted
                            ? Container(
                                key: const ValueKey('success'),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Message sent successfully!', style: AppTextStyles.mono(size: 13, color: AppColors.success)),
                                  ],
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('button'),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Send Message', style: AppTextStyles.button),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isEmail = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.mono(size: 12, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (isEmail && !v.contains('@')) return 'Invalid email';
            return null;
          },
        ),
      ],
    );
  }
}
