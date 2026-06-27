import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:file_picker/file_picker.dart'; // اضافه شدن فایل‌پیکر
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupportChatPage extends ConsumerStatefulWidget {
  const SupportChatPage({super.key});

  @override
  ConsumerState<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends ConsumerState<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // اسکرول نرم به آخرین پیام
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).markAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    // تغییر مهم برای نسخه 11 به بعد: کلمه platform حذف شد
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: kIsWeb, // برای کروم (وب) حتماً دیتا را به صورت بایت می‌گیریم
    );

    if (result != null) {
      final file = result.files.single;

      // اجرای حالت وب (کروم)
      if (kIsWeb) {
        if (file.bytes != null) {
          ref
              .read(chatProvider.notifier)
              .sendMediaMessage(fileBytes: file.bytes, fileName: file.name);
        }
      }
      // اجرای حالت موبایل (اندروید / iOS)
      else {
        if (file.path != null) {
          ref
              .read(chatProvider.notifier)
              .sendMediaMessage(filePath: file.path, fileName: file.name);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final myUserId = ref.watch(authProvider).userInfo?['id'];

    // اطمینان از اسکرول به پایین هنگام دریافت پیام جدید یا لود شدن تاریخچه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatState.unreadCount > 0) {
        ref.read(chatProvider.notifier).markAsRead();
      }
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : chatState.messages.isEmpty
                ? const Center(
                    child: Text(
                      'پیامی وجود ندارد. می‌توانید مشکل خود را مطرح کنید.',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        color: Colors.black45,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      final isMe = msg.senderId == myUserId;
                      return _buildChatBubble(msg, isMe);
                    },
                  ),
          ),

          // نوار لودینگ در زمان آپلود فایل
          if (chatState.isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'در حال ارسال فایل...',
                    style: TextStyle(
                      fontFamily: 'Samim',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // باکس ارسال پیام
          _buildMessageInput(chatState.isUploading),
        ],
      ),
    );
  }

  // طراجی حباب چت با پشتیبانی از انواع فایل‌ها
  Widget _buildChatBubble(dynamic msg, bool isMe) {
    final timeStr = intl.DateFormat('HH:mm').format(msg.createdAt.toLocal());
    final hasAttachment =
        msg.attachmentUrl != null && msg.attachmentUrl.toString().isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'پشتیبانی',
                  style: TextStyle(
                    fontFamily: 'Samim',
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // ==========================================
            // بخش رندر کردن فایل‌های پیوست شده بر اساس نوع
            // ==========================================
            if (hasAttachment) ...[
              _buildAttachmentWidget(
                msg.attachmentType,
                msg.attachmentUrl,
                isMe,
              ),
              const SizedBox(height: 6),
            ],

            // متن پیام (اگر فایل نباشد یا همراه فایل متنی هم باشد)
            if (msg.content.isNotEmpty && msg.content != 'فایل ضمیمه')
              Text(
                msg.content,
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 14,
                  color: isMe ? Colors.white : AppColors.darkText,
                  height: 1.4,
                ),
              ),

            // زمان ارسال پیام
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'Samim',
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت کمکی برای نمایش نوع فایل پیوست
  Widget _buildAttachmentWidget(String? type, String url, bool isMe) {
    final fullUrl = AppConstants.getFullImageUrl(url);
    final color = isMe ? Colors.white : AppColors.primary;
    final bgColor = isMe
        ? Colors.white.withOpacity(0.2)
        : AppColors.primary.withOpacity(0.1);

    if (type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(fullUrl, fit: BoxFit.cover),
      );
    } else if (type == 'video') {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.play_circle_fill_rounded, color: color, size: 40),
      );
    } else if (type == 'voice') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              'پیام صوتی',
              style: TextStyle(color: color, fontFamily: 'Samim', fontSize: 12),
            ),
          ],
        ),
      );
    } else {
      // حالت سند (Document)
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              'فایل ضمیمه',
              style: TextStyle(color: color, fontFamily: 'Samim', fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageInput(bool isUploading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
              onPressed: isUploading
                  ? null
                  : _pickAndUploadFile, // استفاده از متد جدید فایل‌پیکر
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'پیام خود را بنویسید...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Samim',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    ref.read(chatProvider.notifier).sendMessage(text);
                    _messageController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
