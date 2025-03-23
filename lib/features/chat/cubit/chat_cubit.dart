import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../core/services/web_rtc_service.dart';
import '../model/message_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref("chats");
  final DatabaseReference _typingRef = FirebaseDatabase.instance.ref("typing_status");
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final WebRTCService _webRTCService = WebRTCService();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  StreamSubscription<DatabaseEvent>? _chatSubscription;
  StreamSubscription<DatabaseEvent>? _typingSubscription;

  String? get currentUser => _currentUserId;

  String? _currentChatRoomId;
  String? _currentReceiverId;

  /// 📡 Load messages for a given chat room
  void loadMessages(String chatRoomId) {
    emit(ChatLoading());
    _currentChatRoomId = chatRoomId;

    _chatSubscription = _chatRef.child(chatRoomId).orderByChild("timestamp").onValue.listen((event) {
      if (event.snapshot.value == null) {
        emit(ChatLoaded([])); // Empty list if no messages
        return;
      }

      Map<dynamic, dynamic> messagesMap = event.snapshot.value as Map<dynamic, dynamic>;
      List<Message> messages = messagesMap.entries.map((entry) {
        final messageData = entry.value as Map<dynamic, dynamic>;

        return Message(
          id: entry.key,
          text: messageData["text"] ?? "",
          senderId: messageData["senderId"] ?? "",
          timestamp: messageData["timestamp"] ?? 0,
          status: messageData["status"] ?? "sent",
          type: _getMessageType(messageData["type"] ?? "text"),
          fileId: messageData["fileId"],
          fileName: messageData["fileName"],
          fileType: messageData["fileType"],
        );
      }).toList();

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort messages by time
      emit(ChatLoaded(messages));

      // ✅ Mark messages as "delivered" if not sent by the current user
      _markMessagesDelivered(chatRoomId, messages);
    });

    // Initialize WebRTC callbacks
    _webRTCService.onFileReceived = (fileData) {
      _handleWebRTCFileReceived(fileData, chatRoomId);
    };
  }

  // Handle received WebRTC file
  void _handleWebRTCFileReceived(Map<String, dynamic> fileData, String chatRoomId) {
    if (_currentUserId == null) return;

    final message = {
      "text": "Sent a file: ${fileData['fileName']}",
      "senderId": fileData['senderId'],
      "timestamp": ServerValue.timestamp,
      "status": "sent",
      "type": _getFileType(fileData['fileType']),
      "fileId": fileData['fileId'],
      "fileName": fileData['fileName'],
      "fileType": fileData['fileType'],
    };

    _chatRef.child(chatRoomId).push().set(message);
  }

  // Set receiver ID for WebRTC connection
  void setReceiverId(String receiverId) {
    _currentReceiverId = receiverId;
    if (_currentChatRoomId != null) {
      _webRTCService.initPeerConnection(receiverId, _currentChatRoomId!);
    }
  }

  // Convert string type to enum
  MessageType _getMessageType(String type) {
    switch (type) {
      case "image": return MessageType.image;
      case "audio": return MessageType.audio;
      case "video": return MessageType.video;
      case "file": return MessageType.file;
      default: return MessageType.text;
    }
  }

  // Get message type from file mime type
  String _getFileType(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType.startsWith('video/')) return 'video';
    return 'file';
  }

  /// ✅ Mark messages as delivered
  void _markMessagesDelivered(String chatRoomId, List<Message> messages) {
    for (var message in messages) {
      if (message.senderId != _currentUserId && message.status == "sent") {
        _chatRef.child(chatRoomId).child(message.id).update({"status": "delivered"});
      }
    }
  }

  /// ✅ Mark messages as seen when user opens chat
  void markMessagesAsSeen(String chatRoomId) {
    _chatRef.child(chatRoomId).orderByChild("status").equalTo("delivered").once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> messagesMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        for (var messageId in messagesMap.keys) {
          _chatRef.child(chatRoomId).child(messageId).update({"status": "seen"});
        }
      }
    });
  }

  /// 📝 Send a text message with "sent" status
  Future<void> sendMessage(String chatRoomId, String messageText, MessageType messageType) async {
    if (_currentUserId == null || messageText.trim().isEmpty) return;

    final message = {
      "text": messageText.trim(),
      "senderId": _currentUserId,
      "timestamp": ServerValue.timestamp,
      "status": "sent",
      "type": "text",
    };

    await _chatRef.child(chatRoomId).push().set(message);
  }

  /// 📤 Send a media message via WebRTC
  Future<void> sendMediaMessage(
      String chatRoomId,
      String filePath,
      MessageType type,
      ) async {
    if (_currentUserId == null || _currentReceiverId == null) return;

    emit(MediaUploadLoading(0.0));

    // File file = File(filePath);
    //
    try {
    //   // Get mime type based on file extension
    //   String fileType = _getMimeType(filePath);
    //
    //   // Send file via WebRTC
    //   Map<String, dynamic> fileInfo = await _webRTCService.sendFile(
    //     file,
    //     _currentReceiverId!,
    //     fileType,
    //   );
    //
    //   // Create message to notify about file
    //   final message = {
    //     "text": "Sent a file: ${fileInfo['fileName']}",
    //     "senderId": _currentUserId,
    //     "timestamp": ServerValue.timestamp,
    //     "status": "sent",
    //     "type": _getFileType(fileType),
    //     "fileId": fileInfo['fileId'],
    //     "fileName": fileInfo['fileName'],
    //     "fileType": fileType,
    //   };
    //
    //   await _chatRef.child(chatRoomId).push().set(message);
      emit(const MediaUploadSuccess());

    } catch (e,st) {
      print(e);
      print(st);
      emit(MediaUploadError(e.toString()));
    }
  }

  // Get MIME type based on file extension
  String _getMimeType(String filePath) {
    String ext = filePath.split('.').last.toLowerCase();

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'aac':
        return 'audio/aac';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  // Get cached file
  // Future<File?> getCachedFile(String fileId, String fileName) async {
  //   FileInfo? fileInfo = await _webRTCService.getCachedFile(fileId, fileName);
  //   return fileInfo?.file;
  // }

  /// ✍️ Update typing status
  void setTypingStatus(String chatRoomId, bool isTyping) {
    if (_currentUserId == null) return;
    _typingRef.child(chatRoomId).child(_currentUserId).set(isTyping);
  }
  Timer? _typingTimer;

  void onUserTyping(String chatRoomId) {
    setTypingStatus(chatRoomId, true);

    _typingTimer?.cancel(); // Cancel previous timer
    _typingTimer = Timer(const Duration(seconds: 2), () {
      setTypingStatus(chatRoomId, false);
    });
  }

  /// 🎯 Listen for typing status updates
  void listenForTypingStatus(String chatRoomId) {
    _typingSubscription = _typingRef.child(chatRoomId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        if (event.snapshot.value is Map) {
          final rawMap = event.snapshot.value as Map<dynamic, dynamic>;
          Map<String, bool> typingMap = rawMap.map((key, value) => MapEntry(key.toString(), value as bool));
          // emit(TypingStatusUpdated(typingMap));
        }
      }
    });
  }

  /// 🛑 Dispose of streams
  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _typingSubscription?.cancel();
    _webRTCService.dispose();
    return super.close();
  }
}