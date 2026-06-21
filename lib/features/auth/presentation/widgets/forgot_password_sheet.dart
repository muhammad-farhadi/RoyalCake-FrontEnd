import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_page.dart';

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  int _currentStep = 1; // 1: دریافت شماره, 2: دریافت کد و پسورد جدید
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // مرحله اول: ارسال درخواست پیامک
  void _submitPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 11) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('شماره موبایل نامعتبر است')));
      return;
    }

    final success = await ref.read(authProvider.notifier).forgotPassword(phone);
    if (success && mounted) {
      setState(() {
        _currentStep = 2; // رفتن به مرحله بعد
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('کد تایید ارسال شد.')));
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      if (error != null)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // مرحله دوم: ثبت رمز جدید و لاگین
  void _resetAndLogin() async {
    final phone = _phoneController.text.trim();
    final code = _otpController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً همه فیلدها را پر کنید')),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .resetPasswordAndLogin(phone, code, newPassword);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // بستن پاپ‌آپ
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      final error = ref.read(authProvider).error;
      if (error != null)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Padding(
      // تنظیم پدینگ برای بالا آمدن صفحه هنگام باز شدن کیبورد
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نوار کوچک بالای پاپ‌آپ
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _currentStep == 1 ? 'فراموشی رمز عبور' : 'تعیین رمز عبور جدید',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? 'شماره موبایل خود را وارد کنید تا کد تایید برای شما ارسال شود.'
                    : 'کد ۵ رقمی ارسالی و رمز عبور جدید خود را وارد کنید.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              if (_currentStep == 1) ...[
                // فرم مرحله اول
                _buildTextField(
                  controller: _phoneController,
                  hint: 'شماره موبایل',
                  icon: Icons.phone_iphone,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  theme: theme,
                  isLoading: authState.isLoading,
                  text: 'ارسال کد تایید',
                  onPressed: _submitPhone,
                ),
              ] else ...[
                // فرم مرحله دوم
                _buildTextField(
                  controller: _otpController,
                  hint: 'کد تایید پیامک شده',
                  icon: Icons.domain_verification,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'رمز عبور جدید',
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  theme: theme,
                  isLoading: authState.isLoading,
                  text: 'تغییر رمز و ورود خودکار',
                  onPressed: _resetAndLogin,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        counterText: "",
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required bool isLoading,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
