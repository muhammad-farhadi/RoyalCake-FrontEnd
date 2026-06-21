import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_page.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String password;

  const OtpPage({super.key, required this.phoneNumber, required this.password});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();

  // متغیرهای مربوط به تایمر معکوس
  Timer? _timer;
  int _secondsRemaining = 120; // مدت زمان فعال بودن تایمر (۲ دقیقه)
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer(); // شروع تایمر به محض ورود به صفحه
  }

  @override
  void dispose() {
    _timer?.cancel(); // لغو تایمر برای جلوگیری از نشت حافظه (Memory Leak)
    _otpController.dispose();
    super.dispose();
  }

  // متد شروع و مدیریت تایمر
  void _startTimer() {
    setState(() {
      _secondsRemaining = 120;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      }
    });
  }

  // تبدیل ثانیه به فرمت استاندارد زمان (01:59)
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // متد ارسال مجدد کد تایید
  void _resendCode() async {
    if (!_canResend) return;

    final success = await ref
        .read(authProvider.notifier)
        .resendOtp(widget.phoneNumber);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تایید جدید با موفقیت ارسال شد.')),
      );
      _startTimer(); // شروع مجدد تایمر پس از ارسال موفق
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  void _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length < 6) return;

    final success = await ref
        .read(authProvider.notifier)
        .verifyOtpAndLogin(widget.phoneNumber, code, widget.password);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تایید شماره موبایل', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'کد ارسال شده به شماره ${widget.phoneNumber} را وارد کنید.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // فیلد ورود کد OTP
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 6) _verifyCode();
                },
              ),
              const SizedBox(height: 32),

              // بخش تایمر و ارسال مجدد کد
              Center(
                child: _canResend
                    ? TextButton.icon(
                        onPressed: authState.isLoading ? null : _resendCode,
                        icon: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'ارسال مجدد کد تایید',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ارسال مجدد کد تا ${_formatTime(_secondsRemaining)} دیگر',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // دکمه تایید نهایی
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
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
                          'تایید و ورود',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
