import 'dart:io'; // For Mobile file handling
import 'dart:typed_data'; // For Web file handling

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/utils/functions/scroll_to_bottom.dart';
import '../cubit/chat_cubit.dart';
import '../model/message_model.dart';
import '../widget/attachement_option.dart';
import '../widget/chat_app_bar.dart';
import '../widget/meassge_list.dart';
import '../widget/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.receiverId,
    this.receiverName = 'John Doe',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingController;
  late AnimationController _micAnimationController;
  bool _showAttachments = false;
  bool _isRecording = false;
  String? _recordingPath;

  final _audioRecorder = AudioRecorder();
  // RecorderController _recorderController = RecorderController();
  PlayerController? _playerController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // _recorderController = RecorderController()
    //   ..androidEncoder = AndroidEncoder.aac
    //   ..androidOutputFormat = AndroidOutputFormat.mpeg4
    //   ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    //   ..sampleRate = 44100;

    // Initialize Firebase for Web
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb && Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      scrollToBottom(_scrollController);
    });

    // Initialize chat
    context.read<ChatCubit>().loadMessages(widget.chatRoomId);
    context.read<ChatCubit>().markMessagesAsSeen(widget.chatRoomId);
    context.read<ChatCubit>().listenForTypingStatus(widget.chatRoomId);

    // Set receiver ID for WebRTC connection (only for mobile)
    if (!kIsWeb) {
      context.read<ChatCubit>().setReceiverId(widget.receiverId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _micAnimationController.dispose();
    _audioRecorder.dispose();
    // _recorderController.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatCubit>().sendMessage(
        widget.chatRoomId,
        _messageController.text.trim(),
        MessageType.text,
      );
      _messageController.clear();
      Future.delayed(
          const Duration(milliseconds: 100), scrollToBottom(_scrollController));
    }
  }

  Future<void> _sendImage(ImageSource source) async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedImage != null) {
      setState(() {
        _showAttachments = false;
      });

      await context.read<ChatCubit>().sendMediaMessage(
        widget.chatRoomId,
        pickedImage.path,
        MessageType.image,
      );

      Future.delayed(
          const Duration(milliseconds: 100), scrollToBottom(_scrollController));
    }
  }

  Future<void> _sendFile() async {
    setState(() {
      _showAttachments = false;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.single.bytes;
        String fileName = result.files.single.name;

        if (fileBytes != null) {
          await context.read<ChatCubit>().sendMediaMessage(
            widget.chatRoomId,
            fileBytes as String, // Web: Send bytes instead of file path
            MessageType.file,
          );
        }
      } else {
        File file = File(result.files.single.path!);
        await context.read<ChatCubit>().sendMediaMessage(
          widget.chatRoomId,
          file.path,
          MessageType.file,
        );
      }

      Future.delayed(
          const Duration(milliseconds: 100), scrollToBottom(_scrollController));
    }
  }

  Future<void> _startVoiceRecording() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return;
      }
    }

    Directory? directory;
    if (!kIsWeb) {
      directory = await getTemporaryDirectory();
    }

    _recordingPath =
    '${directory?.path ?? ''}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _audioRecorder.start(const RecordConfig(),
        path: _recordingPath ?? '');
    // _recorderController.record();
    _micAnimationController.repeat(reverse: true);

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopVoiceRecording() async {
    if (!_isRecording) return;

    _micAnimationController.stop();
    await _audioRecorder.stop();
    // _recorderController.stop();

    setState(() {
      _isRecording = false;
    });

    if (_recordingPath != null) {
      await context.read<ChatCubit>().sendMediaMessage(
        widget.chatRoomId,
        _recordingPath!,
        MessageType.audio,
      );

      Future.delayed(
          const Duration(milliseconds: 100), scrollToBottom(_scrollController));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomChatAppBar(
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        typingController: _typingController,
        senderId: context.read<ChatCubit>().currentUser!,
        roomId: widget.chatRoomId,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
          image: const DecorationImage(
            image: AssetImage("assets/images/chat_background.png"),
            repeat: ImageRepeat.repeat,
            opacity: 0.07,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: MessageList(
                receiverName: widget.receiverName,
                chatRoomId: widget.chatRoomId,
                scrollController: _scrollController,
                // recordController: _recorderController,
              ),
            ),
            MessageInput(
              messageController: _messageController,
              sendMessage: _sendMessage,
              startVoiceRecording: _startVoiceRecording,
              stopVoiceRecording: (_) => _stopVoiceRecording(),
              sendImage: _sendImage,
              isRecording: _isRecording,
              micAnimationController: _micAnimationController,
              // recorderController: _recorderController,
              chatRoomId: widget.chatRoomId,
              onAttachmentToggle: (show) => setState(() {
                _showAttachments = show;
              }),
            ),
            if (_showAttachments) AttachmentOptions(onImagePicked: _sendImage, onFilePicked: _sendFile, onLocationPicked: () {  },),
          ],
        ),
      ),
    );
  }
}