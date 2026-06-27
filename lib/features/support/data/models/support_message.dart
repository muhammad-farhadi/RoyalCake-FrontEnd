class SupportMessage {
  final int id;
  final int senderId;
  final String? senderName;
  final String content;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'],
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}