import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/functions/scroll_to_bottom.dart';
import '../cubit/chat_cubit.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final String receiverName;
  final String chatRoomId;
  final ScrollController scrollController;
  // final RecorderController recordController;

  const MessageList({
    Key? key,
    required this.receiverName,
    required this.chatRoomId,
    required this.scrollController,
    // required this.recordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) {
          context.read<ChatCubit>().markMessagesAsSeen(chatRoomId);
          Future.delayed(const Duration(milliseconds: 100), () => scrollToBottom(scrollController));
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildLoadingIndicator();
        } else if (state is ChatLoaded && state.messages.isEmpty) {
          return _buildEmptyState();
        } else {
          state as ChatLoaded;
          return _buildMessageList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[300]!),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text("Loading conversation...", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatLoaded state) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 100, bottom: 16, left: 16, right: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final bool isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

        bool showDate = index == 0 || !_isSameDay(
          DateTime.fromMillisecondsSinceEpoch(state.messages[index - 1].timestamp),
          DateTime.fromMillisecondsSinceEpoch(message.timestamp),
        );

        bool showAvatar = index == state.messages.length - 1 ||
            state.messages[index + 1].senderId != message.senderId;

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.timestamp),
            MessageBubble(
              receiverName: receiverName,
              message: message,
              isMe: isMe,
              showAvatar: showAvatar,
              // recorderController: recordController,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 70, color: Colors.purple[300]),
          ),
          const SizedBox(height: 24),
          Text("No messages yet", style: TextStyle(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(20)),
            child: Text("Start a conversation with $receiverName", style: TextStyle(fontSize: 14, color: Colors.grey[400]), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(int timestamp) {
    final DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String formattedDate = _getFormattedDate(messageDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[700], thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
              child: Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[700], thickness: 0.5)),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat.EEEE().format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
