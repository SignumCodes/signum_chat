import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String receiverId;
  final String senderId;
  final String receiverName;
  final String roomId;
  final AnimationController typingController;

  const CustomChatAppBar({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.typingController,
    required this.senderId,
    required this.roomId,
  });

  @override
  _CustomChatAppBarState createState() => _CustomChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomChatAppBarState extends State<CustomChatAppBar> {
  final DatabaseReference _typingRef =
  FirebaseDatabase.instance.ref("typing_status");
  StreamSubscription<DatabaseEvent>? _typingSubscription;
  String statusText = "Online"; // Default status

  @override
  void initState() {
    super.initState();
    listenForTypingStatus();
  }

  /// 🎯 Listen for typing status updates
  void listenForTypingStatus() {
    _typingSubscription =
        _typingRef.child(widget.roomId).onValue.listen((event) {
          if (event.snapshot.value != null && event.snapshot.value is Map) {
            final rawMap = event.snapshot.value as Map<dynamic, dynamic>;
            Map<String, bool> typingMap =
            rawMap.map((key, value) => MapEntry(key.toString(), value as bool));

            // Check if the receiver is typing
            bool isReceiverTyping = typingMap[widget.receiverId] ?? false;

            setState(() {
              if (isReceiverTyping) {
                statusText = "Typing...";
                widget.typingController.forward();
              } else {
                statusText = "Online";
                widget.typingController.reverse();
              }
            });
          }
        });
  }

  @override
  void dispose() {
    _typingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9C27B0).withOpacity(0.95),
              const Color(0xFF4A148C).withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'avatar-${widget.receiverId}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF9C27B0),
                child: Text(
                  widget.receiverName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  statusText, // Shows "Online" or "Typing..."
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {},
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white70),
                  SizedBox(width: 8),
                  Text('Search'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.white70),
                  SizedBox(width: 8),
                  Text('Block user'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, color: Colors.white70),
                  SizedBox(width: 8),
                  Text('Clear chat'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}