import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/route/route.dart';
import '../../../core/services/app_navigator.dart';
import '../../home/cubit/home_cubit.dart';
import '../cubit/chat_cubit.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController messageController;
  final Function sendMessage;
  final GestureLongPressCallback startVoiceRecording;
  final Function(dynamic) stopVoiceRecording;  // Change in MessageInput class
  final Function sendImage;
  final bool isRecording;
  final AnimationController micAnimationController;
  // final dynamic recorderController;
  final String chatRoomId;
  final Function(bool) onAttachmentToggle;


  const MessageInput({
    super.key,
    required this.messageController,
    required this.sendMessage,
    required this.startVoiceRecording,
    required this.stopVoiceRecording,
    required this.sendImage,
    required this.isRecording,
    required this.micAnimationController,
    // required this.recorderController,
    required this.chatRoomId,
    required this.onAttachmentToggle,
  });

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _showEmoji = false;
  bool _showAttachments = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -3),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSkipButton(),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _showEmoji = !_showEmoji;
                    _showAttachments = false;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  _showAttachments ? Icons.close : Icons.attach_file,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _showAttachments = !_showAttachments;
                    _showEmoji = false;
                  });
                  // Notify parent about the change
                  widget.onAttachmentToggle(_showAttachments);
                },
              ),
              Expanded(
                child: TextField(
                  controller: widget.messageController,
                  onChanged: (text) {
                    if(text.isEmpty){

                    }
                    // widget.isRecording = true;
                      context.read<ChatCubit>().onUserTyping(
                        widget.chatRoomId,
                      );},
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.isRecording ? "Recording..." : "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: widget.isRecording ? null : widget.startVoiceRecording,
                onLongPressEnd: (d) => widget.stopVoiceRecording(d),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isRecording
                          ? [Colors.red, Colors.redAccent]
                          : [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: AnimatedBuilder(
                      animation: widget.micAnimationController,
                      builder: (context, child) {
                        return Icon(
                          widget.isRecording ? Icons.mic : Icons.send_rounded,
                          color: Colors.white,
                          size: widget.isRecording ? 28 : 24,
                        );
                      },
                    ),
                    onPressed: widget.isRecording ? null : () => widget.sendMessage(),
                  ),
                ),
              ),
            ],
          ),
          if (widget.isRecording) _buildRecordingIndicator(),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[800],
            ),
            // child: AudioWaveforms(
            //   enableGesture: true,
            //   size: Size(MediaQuery.of(context).size.width * 0.7, 40),
            //   recorderController: widget.recorderController!,
            // ),
          ),
          const SizedBox(width: 8),
          Text("Recording...", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) async {
        if (state is ChatMatched) {
          context.read<HomeCubit>().cancelSearch();
          AppNavigator.replaceWith(AppRoute.chatScreen, arguments: {
            "matchedUserId": state.matchedUserId,
            "roomId": state.roomId,
            "name": await context.read<HomeCubit>().getUserName(state.matchedUserId),
          });
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: state is HomeLoading ? null : () => context.read<HomeCubit>().findRandomUser('both', ['all']),
          child: Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
              ),
            ),
            child: state is HomeLoading
                ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
                : const Center(child: Text('SKIP')),
          ),
        );
      },
    );
  }
}
