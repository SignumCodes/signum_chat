import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/message_model.dart';

class MessageBubble extends StatelessWidget {
  final String receiverName;
  final Message message;
  final bool isMe;
  final bool showAvatar;
  // final RecorderController recorderController;

  const MessageBubble({
    Key? key,
    required this.receiverName,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    // required this.recorderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final formattedTime = DateFormat('h:mm a').format(time);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: Text(
                receiverName[0].toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            )
          else if (!isMe && !showAvatar)
            const SizedBox(width: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMe
                      ? [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)]
                      : [Colors.grey[800]!, Colors.grey[850]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: isMe ? const Radius.circular(5) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == "seen" ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.status == "seen"
                                ? Colors.blue[300]
                                : Colors.white60,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              height: 1.3,
            ),
          ),
        );
      case MessageType.image:
        return const ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          // child: Image.network(
          //   message.mediaUrl!,
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   loadingBuilder: (context, child, loadingProgress) {
          //     if (loadingProgress == null) return child;
          //     return Center(
          //       child: CircularProgressIndicator(
          //         value: loadingProgress.expectedTotalBytes != null
          //             ? loadingProgress.cumulativeBytesLoaded /
          //             loadingProgress.expectedTotalBytes!
          //             : null,
          //         valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[300]!),
          //       ),
          //     );
          //   },
          // ),
        );
      case MessageType.audio:
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              // Expanded(
              //   child: AudioWaveforms(
              //     enableGesture: true,
              //     size: Size(MediaQuery.of(context).size.width * 0.5, 30),
              //     recorderController: recorderController,
              //     waveStyle: const WaveStyle(
              //       waveColor: Colors.white,
              //       showMiddleLine: false,
              //       extendWaveform: true,
              //       spacing: 5,
              //       showDurationLabel: false,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
