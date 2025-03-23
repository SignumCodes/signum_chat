import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class WebRTCService {
  // WebRTC connections
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCDataChannel> _dataChannels = {};
  final Map<String, StreamSubscription> _signalingSubs = {};

  // Firebase references
  final DatabaseReference _signalingRef = FirebaseDatabase.instance.ref("webrtc_signaling");
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Cache manager
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  // Media chunk size (500 KB)
  static const int CHUNK_SIZE = 500 * 1024;

  // Initialize WebRTC connection with a peer
  Future<void> initPeerConnection(String peerId, String chatRoomId) async {
    if (_peerConnections.containsKey(peerId)) return;

    // STUN servers for connection
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };

    // Create peer connection
    final RTCPeerConnection peerConnection =
    await createPeerConnection(configuration);
    _peerConnections[peerId] = peerConnection;

    // Setup data channel for file transfer
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    dataChannelDict.ordered = true;
    dataChannelDict.maxRetransmits = 30;

    RTCDataChannel dataChannel = await peerConnection.createDataChannel(
        'fileTransfer', dataChannelDict);
    _setupDataChannel(dataChannel, peerId);
    _dataChannels[peerId] = dataChannel;

    // Listen for ICE candidates and SDP offers/answers
    _listenForSignaling(peerId, chatRoomId);

    // Create offer if we're initiating the connection
    if (_currentUserId!.compareTo(peerId) < 0) {
      _createOffer(peerId, chatRoomId);
    }
  }

  // Setup data channel event handlers
  void _setupDataChannel(RTCDataChannel dataChannel, String peerId) {
    dataChannel.onMessage = (RTCDataChannelMessage message) async {
      if (message.isBinary) {
        // Process incoming file chunks
        await _handleFileChunk(message.binary, peerId);
      } else {
        // Process metadata
        await _handleMetadata(message.text, peerId);
      }
    };

    dataChannel.onDataChannelState = (RTCDataChannelState state) {
      print('DataChannel state: $state');
    };
  }

  // File transfer state tracking
  final Map<String, Map<String, dynamic>> _fileTransfers = {};

  // Handle file metadata
  Future<void> _handleMetadata(String metadata, String peerId) async {
    Map<String, dynamic> metadataMap =
    Map<String, dynamic>.from(await jsonDecode(metadata));

    if (metadataMap['type'] == 'fileStart') {
      String fileId = metadataMap['fileId'];
      String fileName = metadataMap['fileName'];
      String fileType = metadataMap['fileType'];
      int fileSize = metadataMap['fileSize'];
      int totalChunks = metadataMap['totalChunks'];

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileId-temp';

      _fileTransfers[fileId] = {
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'totalChunks': totalChunks,
        'receivedChunks': 0,
        'tempPath': tempPath,
        'file': await File(tempPath).create(),
      };

    } else if (metadataMap['type'] == 'fileEnd') {
      String fileId = metadataMap['fileId'];
      await _finalizeFileTransfer(fileId, peerId);
    }
  }

  // Handle incoming file chunk
  Future<void> _handleFileChunk(Uint8List data, String peerId) async {
    // First 36 bytes contain the fileId and chunkIndex
    String fileId = String.fromCharCodes(data.sublist(0, 36));
    int chunkIndex = ByteData.view(
        data.sublist(36, 40).buffer).getInt32(0, Endian.little);
    Uint8List chunkData = data.sublist(40);

    if (!_fileTransfers.containsKey(fileId)) return;

    Map<String, dynamic> transfer = _fileTransfers[fileId]!;
    File file = transfer['file'];

    // Write chunk at the correct position
    RandomAccessFile raf = await file.open(mode: FileMode.write);
    try {
      await raf.setPosition(chunkIndex * CHUNK_SIZE);
      await raf.writeFrom(chunkData);
    } finally {
      await raf.close();
    }

    transfer['receivedChunks']++;

    // Check if file transfer is complete
    if (transfer['receivedChunks'] >= transfer['totalChunks']) {
      await _finalizeFileTransfer(fileId, peerId);
    }
  }

  // Complete file transfer and store in cache
  Future<void> _finalizeFileTransfer(String fileId, String peerId) async {
    Map<String, dynamic> transfer = _fileTransfers[fileId]!;
    File tempFile = transfer['file'];
    String fileName = transfer['fileName'];
    String fileType = transfer['fileType'];

    // Store the file in cache instead of permanent storage
    String fileKey = '$fileId-$fileName';
    await cacheManager.putFile(
      fileKey,
      await tempFile.readAsBytes(),
      key: fileKey,
      maxAge: const Duration(days: 7), // Cache for 7 days
      fileExtension: fileType.split('/').last,
    );

    // Clean up temporary file
    await tempFile.delete();

    // Notify listeners that file transfer is complete
    Map<String, dynamic> notifyData = {
      'fileId': fileId,
      'fileName': fileName,
      'fileType': fileType,
      'senderId': peerId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _fileTransfers.remove(fileId);

    // Trigger callback to update UI
    if (onFileReceived != null) {
      onFileReceived!(notifyData);
    }
  }

  // Callback for file reception
  Function(Map<String, dynamic>)? onFileReceived;

  // Send file via WebRTC
  Future<Map<String, String>> sendFile(File file, String peerId, String fileType) async {
    if (!_dataChannels.containsKey(peerId) ||
        _dataChannels[peerId]!.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw Exception('Data channel not open');
    }

    String fileName = file.path.split('/').last;
    String fileId = '${DateTime.now().millisecondsSinceEpoch}-${_currentUserId!}';
    int fileSize = await file.length();
    int totalChunks = (fileSize / CHUNK_SIZE).ceil();

    RTCDataChannel dataChannel = _dataChannels[peerId]!;

    // Send metadata first
    Map<String, dynamic> metadata = {
      'type': 'fileStart',
      'fileId': fileId,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'totalChunks': totalChunks,
    };

    dataChannel.send(RTCDataChannelMessage(jsonEncode(metadata)));

    // Send file in chunks
    RandomAccessFile reader = await file.open(mode: FileMode.read);
    try {
      for (int i = 0; i < totalChunks; i++) {
        await reader.setPosition(i * CHUNK_SIZE);
        Uint8List chunk = await reader.read(CHUNK_SIZE);

        // Prepend fileId and chunkIndex to each chunk
        List<int> fileIdBytes = fileId.codeUnits;
        Uint8List indexBytes = Uint8List(4);
        ByteData.view(indexBytes.buffer).setInt32(0, i, Endian.little);

        Uint8List dataWithHeader = Uint8List(
            fileIdBytes.length + indexBytes.length + chunk.length);
        dataWithHeader.setRange(0, fileIdBytes.length, fileIdBytes);
        dataWithHeader.setRange(
            fileIdBytes.length, fileIdBytes.length + indexBytes.length, indexBytes);
        dataWithHeader.setRange(
            fileIdBytes.length + indexBytes.length,
            dataWithHeader.length,
            chunk);

        dataChannel.send(RTCDataChannelMessage.fromBinary(dataWithHeader));

        // Don't overwhelm the channel
        await Future.delayed(Duration(milliseconds: 10));
      }

      // Send end of file marker
      Map<String, dynamic> endMetadata = {
        'type': 'fileEnd',
        'fileId': fileId,
      };
      dataChannel.send(RTCDataChannelMessage(jsonEncode(endMetadata)));

    } finally {
      await reader.close();
    }

    // Store file in cache for local usage
    String fileKey = '$fileId-$fileName';
    await cacheManager.putFile(
      fileKey,
      await file.readAsBytes(),
      key: fileKey,
      maxAge: const Duration(days: 7),
      fileExtension: fileType.split('/').last,
    );

    // Return file information
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileType': fileType,
      'senderId': _currentUserId,
    };
  }

  // WebRTC signaling
  void _listenForSignaling(String peerId, String chatRoomId) {
    String signalingPath = '$chatRoomId/${_currentUserId}_$peerId';

    _signalingSubs[peerId] = _signalingRef
        .child(signalingPath)
        .onChildAdded
        .listen((event) async {
      if (event.snapshot.value == null) return;

      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
      String type = data['type'];

      if (type == 'offer' && _peerConnections.containsKey(peerId)) {
        await _peerConnections[peerId]!.setRemoteDescription(
          RTCSessionDescription(
            data['sdp'],
            data['type'],
          ),
        );
        await _createAnswer(peerId, chatRoomId);
      } else if (type == 'answer' && _peerConnections.containsKey(peerId)) {
        await _peerConnections[peerId]!.setRemoteDescription(
          RTCSessionDescription(
            data['sdp'],
            data['type'],
          ),
        );
      } else if (type == 'candidate' && _peerConnections.containsKey(peerId)) {
        await _peerConnections[peerId]!.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      }

      // Clean up signaling message after processing
      await _signalingRef.child(signalingPath).child(event.snapshot.key!).remove();
    });

    // Listen for ICE candidates
    _peerConnections[peerId]!.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignalingMessage(peerId, chatRoomId, {
        'type': 'candidate',
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    // Handle data channel from remote peer
    _peerConnections[peerId]!.onDataChannel = (RTCDataChannel channel) {
      if (channel.label == 'fileTransfer') {
        _setupDataChannel(channel, peerId);
        _dataChannels[peerId] = channel;
      }
    };
  }

  // Create WebRTC offer
  Future<void> _createOffer(String peerId, String chatRoomId) async {
    RTCSessionDescription description =
    await _peerConnections[peerId]!.createOffer({});
    await _peerConnections[peerId]!.setLocalDescription(description);

    _sendSignalingMessage(peerId, chatRoomId, {
      'type': description.type,
      'sdp': description.sdp,
    });
  }

  // Create WebRTC answer
  Future<void> _createAnswer(String peerId, String chatRoomId) async {
    RTCSessionDescription description =
    await _peerConnections[peerId]!.createAnswer({});
    await _peerConnections[peerId]!.setLocalDescription(description);

    _sendSignalingMessage(peerId, chatRoomId, {
      'type': description.type,
      'sdp': description.sdp,
    });
  }

  // Send signaling message via Firebase
  Future<void> _sendSignalingMessage(
      String peerId, String chatRoomId, Map<String, dynamic> message) async {
    String signalingPath = '$chatRoomId/${peerId}_${_currentUserId}';
    await _signalingRef.child(signalingPath).push().set(message);
  }

  // Get cached file
  Future<FileInfo?> getCachedFile(String fileId, String fileName) async {
    String fileKey = '$fileId-$fileName';
    return await cacheManager.getFileFromCache(fileKey);
  }

  // Dispose the WebRTC connections
  void dispose() {
    for (var sub in _signalingSubs.values) {
      sub.cancel();
    }

    for (var connection in _peerConnections.values) {
      connection.close();
    }

    for (var channel in _dataChannels.values) {
      channel.close();
    }

    _peerConnections.clear();
    _dataChannels.clear();
    _signalingSubs.clear();
  }
}