import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../data/models/support_message.dart';

class ChatState {
  final bool isLoading;
  final bool isUploading;
  final List<SupportMessage> messages;
  final String? error;
  final int unreadCount; // شمارنده پیام‌های نخوانده

  ChatState({
    this.isLoading = false,
    this.isUploading = false,
    this.messages = const [],
    this.error,
    this.unreadCount = 0,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isUploading,
    List<SupportMessage>? messages,
    String? error,
    int? unreadCount,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      messages: messages ?? this.messages,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;
  WebSocketChannel? _channel;

  ChatNotifier(this.ref) : super(ChatState()) {
    // به محض اینکه وضعیت لاگین تغییر کرد، سوکت را مدیریت می‌کنیم
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && _channel == null) {
        _initChat();
      } else if (!next.isAuthenticated && _channel != null) {
        _disconnect();
      }
    });

    // اگر از قبل لاگین بود (در زمان بالا آمدن اپ)، متصل شو
    if (ref.read(authProvider).isAuthenticated) {
      _initChat();
    }
  }

  Future<void> _initChat() async {
    await fetchHistory();
    await _connectWebSocket();
  }

  // ۱. دریافت تاریخچه
  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/support/history');

      final List<dynamic> data = response.data;
      final messages = data.map((e) => SupportMessage.fromJson(e)).toList();

      state = state.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطا در دریافت تاریخچه');
    }
  }

  // ۲. اتصال به WebSocket
  Future<void> _connectWebSocket() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return;

    // ۱. تبدیل امنِ آدرس http به ws و https به wss
    String wsUrl = AppConstants.baseUrl;
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }

    // ۲. انکد کردن توکن برای جلوگیری از خطای فرمت آدرس در مرورگر
    final safeToken = Uri.encodeComponent(token);

    // ۳. ساخت آدرس نهایی
    final uri = Uri.parse('$wsUrl/api/v1/support/ws?token=$safeToken');

    try {
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
            (message) {
          final decodedData = jsonDecode(message);
          final newMessage = SupportMessage.fromJson(decodedData);
          final myUserId = ref.read(authProvider).userInfo?['id'];

          int newUnread = state.unreadCount;
          final currentTab = ref.read(bottomNavIndexProvider);

          // اگر پیام از طرف ادمین بود و کاربر داخل تب چت نبود، بج را اضافه کن
          if (newMessage.senderId != myUserId && currentTab != 3) {
            newUnread++;
          }

          state = state.copyWith(
            messages: [...state.messages, newMessage],
            unreadCount: newUnread,
          );
        },
        onError: (error) {
          print('WebSocket Listen Error: $error');
          // در صورت قطعی، می‌توانیم استیت را مدیریت کنیم
        },
        onDone: () {
          print('WebSocket Closed by Server');
        },
      );
    } catch (e) {
      print('WebSocket Connection Error: $e');
    }
  }
  // ۳. ارسال پیام متنی
  void sendMessage(String content) {
    if (_channel != null && content.isNotEmpty) {
      final data = {
        "content": content,
        "attachment_url": null,
        "attachment_type": null,
      };
      _channel!.sink.add(jsonEncode(data));
    }
  }

  // ۴. آپلود فایل و ارسال پیام
  Future<void> sendMediaMessage({String? filePath, List<int>? fileBytes, required String fileName}) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      MultipartFile multipartFile;

      // اگر فایل به صورت بایت ارسال شده بود (مخصوص وب)
      if (fileBytes != null) {
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      }
      // اگر از طریق مسیر ارسال شده بود (مخصوص اندروید و iOS)
      else if (filePath != null) {
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        state = state.copyWith(isUploading: false, error: 'فایلی برای آپلود یافت نشد');
        return;
      }

      // ساخت فرم‌دیتا برای آپلود
      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      // ارسال به REST API
      final response = await dio.post('/support/upload_media', data: formData);

      final attachmentUrl = response.data['attachment_url'];
      final attachmentType = response.data['attachment_type'];

      // پس از آپلود موفق، دیتا را از طریق سوکت می‌فرستیم
      if (_channel != null) {
        final data = {
          "content": "فایل ضمیمه",
          "attachment_url": attachmentUrl,
          "attachment_type": attachmentType,
        };
        _channel!.sink.add(jsonEncode(data));
      }

      state = state.copyWith(isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false, error: 'خطا در آپلود فایل');
    }
  }

  // صفر کردن پیام‌های نخوانده (وقتی وارد صفحه چت می‌شویم)
  void markAsRead() {
    if (state.unreadCount > 0) {
      state = state.copyWith(unreadCount: 0);
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
    state = ChatState();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}

// نکته مهم: autoDispose حذف شده تا همیشه زنده بماند
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
