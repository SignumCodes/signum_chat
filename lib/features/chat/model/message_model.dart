enum MessageType { text, image, audio, video, file }

class Message {
  final String id;
  final String text;
  final String senderId;
  final int timestamp;
  final String status; // sent, delivered, seen
  final MessageType type;
  final String? fileId;     // For WebRTC file transfers
  final String? fileName;   // For WebRTC file transfers
  final String? fileType;   // For WebRTC file transfers

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.status,
    this.type = MessageType.text,
    this.fileId,
    this.fileName,
    this.fileType,
  });

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    int? timestamp,
    String? status,
    MessageType? type,
    String? mediaUrl,
    String? fileId,
    String? fileName,
    String? fileType,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
    );
  }
}