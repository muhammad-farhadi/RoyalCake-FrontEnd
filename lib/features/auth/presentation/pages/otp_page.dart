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
  Timer? _timer;
  int _secondsRemaining = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
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

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _resendCode() async {
    if (!_canResend) return;
    final success = await ref
        .read(authProvider.notifier)
        .resendOtp(widget.phoneNumber);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تایید مجدداً ارسال شد.')),
      );
      _startTimer();
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
      backgroundColor: const Color(0xfffcf8f8), // رنگ پس‌زمینه لایت اپ
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: const Color(0xff0c4d3b), // هماهنگی رنگ دکمه بازگشت
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // وسط‌چین شدن عمودی تمامی المان‌ها
            children: [
              const SizedBox(height: 16),
              Center(child: Image.asset('assets/images/logo.png', height: 120)),
              const SizedBox(height: 40),

              Center(
                child: Text(
                  'کد تایید را وارد کنید',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: const Color(0xff0c4d3b), // رنگ سبز تیره تم
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'کد پیامک شده به شماره ${widget.phoneNumber} را وارد نمایید',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff2c3e50), // رنگ متن تیره تم
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // فیلد اختصاصی وارد کردن کد OTP
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0c4d3b),
                ),
                maxLength: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xff0c4d3b), // بوردر سبز در فوکوس
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
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xfffc94a1), // رنگ صورتی تم (Accent)
                          size: 20,
                        ),
                        label: const Text(
                          'ارسال مجدد کد تایید',
                          style: TextStyle(
                            color: Color(0xfffc94a1), // رنگ صورتی تم (Accent)
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
                            'مانده تا ارسال مجدد: ${_formatTime(_secondsRemaining)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // دکمه اصلی تایید و ورود
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0c4d3b), // رنگ سبز اصلی
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
                          'تایید و ورود',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
