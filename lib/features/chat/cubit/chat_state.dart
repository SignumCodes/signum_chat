part of 'chat_cubit.dart';



// Chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class TypingStatusUpdated extends ChatState {
  final Map<String, bool> typingMap; // Maps userId -> isTyping

  const TypingStatusUpdated(this.typingMap);

  @override
  List<Object> get props => [typingMap];
}

class MessageSent extends ChatState {
  final String messageId;

  const MessageSent(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageDelivered extends ChatState {
  final String messageId;

  const MessageDelivered(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageSeen extends ChatState {
  final String messageId;

  const MessageSeen(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MediaUploadLoading extends ChatState {
  final double progress;

  const MediaUploadLoading(this.progress);

  @override
  List<Object> get props => [progress];
}

class MediaUploadSuccess extends ChatState {

  const MediaUploadSuccess();

  @override
  List<Object> get props => [];
}

class MediaUploadError extends ChatState {
  final String error;

  const MediaUploadError(this.error);

  @override
  List<Object> get props => [error];
}