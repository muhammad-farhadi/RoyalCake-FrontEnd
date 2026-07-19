import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'otp_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // 🔴 پاک کردن ارورها به محض باز شدن این صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ لطفاً تمام کادرهای فرم را پر کنید.',
            style: TextStyle(fontFamily: 'Samim'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ شماره موبایل وارد شده معتبر نیست. باید ۱۱ رقم باشد.',
            style: TextStyle(fontFamily: 'Samim'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .register(name, phone, password);
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(phoneNumber: phone, password: password),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfffcf8f8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // 🔴 پاک کردن ارور قبل از بازگشت
            ref.read(authProvider.notifier).clearError();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff0c4d3b)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'ایجاد حساب کاربری',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: const Color(0xff0c4d3b),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'جهت پیوستن به خانواده رویال کیک، فرم زیر را تکمیل کنید',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff2c3e50),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===================================================================
              // 🚨 بنر خطای کوبنده و قرمز ثبت نام
              // ===================================================================
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
                        Icons.warning_amber_rounded,
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

              // فیلد نام و نام خانوادگی
              _buildTextField(
                controller: _nameController,
                hint: 'نام و نام خانوادگی',
                icon: Icons.person_outline,
                helperText: '💡 نام کامل خود را به صورت فارسی درج کنید.',
              ),
              const SizedBox(height: 16),

              // فیلد شماره موبایل
              _buildTextField(
                controller: _phoneController,
                hint: 'شماره موبایل فعال گوشی',
                icon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                helperText:
                    '⚠️ شماره همراه باید ۱۱ رقم کامل جهت دریافت پیامک تأیید.',
              ),
              const SizedBox(height: 16),

              // فیلد کلمه عبور
              _buildTextField(
                controller: _passwordController,
                hint: 'تعیین رمز عبور دلخواه',
                icon: Icons.lock_outline,
                isPassword: true,
                helperText:
                    '⚠️ یک رمز عبور حداقل ۶ رقمی انتخاب کرده و آن را فراموش نکنید.',
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
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
                          'ثبت‌نام',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'قبلاً ثبت‌نام کرده‌اید؟',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // 🔴 پاک کردن ارور قبل از بازگشت
                      ref.read(authProvider.notifier).clearError();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'وارد شوید',
                      style: TextStyle(
                        color: Color(0xfffc94a1),
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
    required String helperText, // 🔴 اضافه شدن هلپر تکست
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
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
