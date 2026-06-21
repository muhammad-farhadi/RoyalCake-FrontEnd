import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/forgot_password_sheet.dart';
import 'otp_page.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً تمامی فیلدها را پر کنید.')),
      );
      return;
    }

    // دریافت وضعیت لاگین به جای فقط یک بولین (true/false)
    final status = await ref.read(authProvider.notifier).login(phone, password);

    if (!mounted) return;

    if (status == LoginStatus.success) {
      // لاگین موفق -> هدایت به صفحه اصلی
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (status == LoginStatus.unverified) {
      // حساب تایید نشده -> ارسال مجدد کد و رفتن به صفحه OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حساب کاربری شما تایید نشده است. در حال ارسال مجدد کد...',
          ),
        ),
      );

      final isResent = await ref.read(authProvider.notifier).resendOtp(phone);
      if (isResent && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpPage(phoneNumber: phone, password: password),
          ),
        );
      } else if (mounted) {
        final error = ref.read(authProvider).error;
        if (error != null)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
      }
    } else {
      // خطای معمولی (رمز اشتباه و ...)
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(child: Image.asset('assets/images/logo.png', height: 120)),
              const SizedBox(height: 40),
              Text('خوش آمدید!', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'برای ورود، شماره موبایل و رمز عبور خود را وارد کنید.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // فیلد شماره موبایل
              _buildTextField(
                controller: _phoneController,
                hint: 'شماره موبایل (مثال: 09123456789)',
                icon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
              ),
              const SizedBox(height: 16),

              // فیلد رمز عبور
              _buildTextField(
                controller: _passwordController,
                hint: 'رمز عبور',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              // فراموشی رمز عبور (فعلاً غیرفعال)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      // برای بالا آمدن پاپ‌آپ با کیبورد الزامی است
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      builder: (context) => const ForgotPasswordSheet(),
                    );
                  },
                  child: Text(
                    'رمز عبور خود را فراموش کرده‌اید؟',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // دکمه ورود
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ورود به حساب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
              // دکمه انتقال به ثبت‌نام
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حساب کاربری ندارید؟',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    ),
                    child: Text(
                      'ثبت‌نام کنید',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
        fillColor: Colors.white,
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
}
