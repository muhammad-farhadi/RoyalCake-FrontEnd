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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final phone = toEnglishDigits(_phoneController.text.trim());
    final password = toEnglishDigits(_passwordController.text.trim());

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ لطفاً کادرهای شماره موبایل و رمز عبور را پر کنید.',
            style: TextStyle(fontFamily: 'Samim'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phone.length < 11 || !phone.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ شماره موبایل معتبر نیست! باید ۱۱ رقم کامل و با ۰ شروع شود.',
            style: TextStyle(fontFamily: 'Samim'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final status = await ref.read(authProvider.notifier).login(phone, password);
    if (!mounted) return;

    if (status == LoginStatus.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (status == LoginStatus.unverified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'کد تایید قبلاً ارسال نشده یا منقضی شده، ارسال مجدد...',
            style: TextStyle(fontFamily: 'Samim'),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfffcf8f8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset('assets/images/logo.png', height: 120),
                ),
                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'خوش آمدید!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: const Color(0xff0c4d3b),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Samim',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'لطفاً برای ورود به حساب کاربری خود اطلاعات زیر را وارد کنید',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xff2c3e50),
                      fontFamily: 'Samim',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // بنر خطای کوبنده و شکیل به زبان فارسی روان
                if (authState.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade300, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.report_problem_rounded,
                          color: Colors.red.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(
                              fontFamily: 'Samim',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // فیلد شماره موبایل
                _buildTextField(
                  controller: _phoneController,
                  hint: 'شماره موبایل (مانند: 09123456789)',
                  icon: Icons.phone_iphone,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  helperText: '⚠️ شماره همراه باید ۱۱ رقم کامل باشد.',
                ),
                const SizedBox(height: 16),

                // فیلد رمز عبور
                _buildTextField(
                  controller: _passwordController,
                  hint: 'رمز عبور',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  helperText:
                      '💡 رمزی که موقع ایجاد حساب کاربری انتخاب کرده‌اید.',
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).clearError();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        backgroundColor: Colors.white,
                        builder: (context) => const ForgotPasswordSheet(),
                      );
                    },
                    child: const Text(
                      'رمز عبور خود را فراموش کرده‌اید؟',
                      style: TextStyle(
                        color: Color(0xfffc94a1),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Samim',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0c4d3b),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 1,
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
                            'ورود',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Samim',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'هنوز ثبت‌نام نکرده‌اید؟',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'ایجاد حساب کاربری',
                        style: TextStyle(
                          color: Color(0xff0c4d3b),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Samim',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    required String helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 16, fontFamily: 'Samim'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontFamily: 'Samim',
            ),
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xff0c4d3b)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xff0c4d3b), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            helperText,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
              fontFamily: 'Samim',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
