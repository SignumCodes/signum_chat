import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("active_users");
  final DatabaseReference _chatRoomsRef = FirebaseDatabase.instance.ref("chat_rooms");

  StreamSubscription<DatabaseEvent>? _userListener;
  bool _isSearching = false;
  Timer? _searchTimeoutTimer;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Start searching for a user
  Future<void> findRandomUser(String gender, List<String> interests) async {
    if (currentUserId == null) {
      emit(StartChatError("User not authenticated"));
      return;
    }

    _isSearching = true;
    emit(HomeLoading());

    try {
      // Add current user to active users
      await _addUserToActive(gender, interests);

      // Try to find an immediate match
      String? matchedUserId = await _searchForExistingUser(gender, interests);

      if (matchedUserId != null) {
        await _createMatch(matchedUserId);
      } else {
        // Start listening for potential matches
        _startMatchListener();
        _startSearchTimeout();
      }
    } catch (e) {
      debugPrint("🚨 Error: ${e.toString()}");
      emit(StartChatError("Error: ${e.toString()}"));
      _cleanup();
    }
  }

  /// Add user to the active users list
  Future<void> _addUserToActive(String gender, List<String> interests) async {
    debugPrint("🔥 Adding user: $currentUserId to active_users");
    await _dbRef.child(currentUserId!).set({
      "active": true,
      "gender": gender,
      "interests": interests,
      "timestamp": ServerValue.timestamp,
    });
  }

  /// Search for an existing user match
  Future<String?> _searchForExistingUser(String gender, List<String> interests) async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final Map<dynamic, dynamic>? users = snapshot.value as Map<dynamic, dynamic>?;
    if (users == null) return null;

    List<String> potentialMatches = [];

    users.forEach((userId, userData) {
      if (userId is String &&
          userData is Map<dynamic, dynamic> &&
          userId != currentUserId &&
          userData["active"] == true &&
          !userData.containsKey("matched_with") &&
          _matchesCriteria(userData, gender, interests)) {
        potentialMatches.add(userId);
      }
    });

    if (potentialMatches.isNotEmpty) {
      potentialMatches.shuffle();
      return potentialMatches.first;
    }

    return null;
  }

  /// Create a chat match and update Firebase
  Future<void> _createMatch(String matchedUserId) async {
    debugPrint("✅ Found match: $matchedUserId");

    String chatRoomId = _generateChatRoomId(currentUserId!, matchedUserId);

    try {
      await _chatRoomsRef.child(chatRoomId).set({
        "user1": currentUserId,
        "user2": matchedUserId,
        "created_at": ServerValue.timestamp,
      });

      debugPrint("🔥 Created Chat Room: $chatRoomId");

      // Update both users
      final updates = {
        "active_users/$currentUserId/matched_with": matchedUserId,
        "active_users/$currentUserId/chat_room": chatRoomId,
        "active_users/$matchedUserId/matched_with": currentUserId,
        "active_users/$matchedUserId/chat_room": chatRoomId,
      };

      await FirebaseDatabase.instance.ref().update(updates);

      emit(ChatMatched(matchedUserId, chatRoomId));
    } catch (e) {
      debugPrint("🚨 Error creating match: $e");
      emit(StartChatError("Failed to create match. Try again."));
    } finally {
      _cleanup();
    }
  }

  /// Listen for a match
  void _startMatchListener() {
    _userListener?.cancel();
    _userListener = _dbRef.child(currentUserId!).onValue.listen((event) {
      if (!_isSearching) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return;

      if (data.containsKey("matched_with") && data.containsKey("chat_room")) {
        final matchedUserId = data["matched_with"].toString();
        final chatRoomId = data["chat_room"].toString();

        emit(ChatMatched(matchedUserId, chatRoomId));
        _cleanup();
      }
    });
  }

  /// Start a timeout if no match is found
  void _startSearchTimeout() {
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_isSearching) {
        emit(NoMatchFound());
        _cleanup();
      }
    });
  }

  /// Check if a user matches the search criteria
  bool _matchesCriteria(Map<dynamic, dynamic> user, String gender, List<String> interests) {
    // Gender Matching
    final userGender = user["gender"];
    if (gender != "Both" &&
        userGender != "Both" &&
        userGender != gender) {
      return false;
    }

    // Interest Matching - need at least one common interest
    final List<dynamic> userInterests = user["interests"] ?? [];
    return userInterests.any((interest) => interests.contains(interest));
  }

  /// Generate a consistent chat room ID
  String _generateChatRoomId(String user1, String user2) {
    List<String> sortedUsers = [user1, user2]..sort();
    return "${sortedUsers[0]}_${sortedUsers[1]}";
  }

  /// Cancel search and clean up resources
  Future<void> cancelSearch() async {
    if (!_isSearching) return;

    emit(SearchCancelled());
    _cleanup();
  }

  /// Cleanup user from active users list
  void _cleanup() {
    _isSearching = false;
    _userListener?.cancel();
    _userListener = null;
    _searchTimeoutTimer?.cancel();
    _searchTimeoutTimer = null;

    if (currentUserId != null) {
      _dbRef.child(currentUserId!).remove().catchError((e) {
        debugPrint("🚨 Error removing user: $e");
      });
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
print(userId);
      if (userDoc.exists) {
        return userDoc['username']; // Get the "name" field
      } else {
        return 'Unknown'; // User does not exist
      }
    } catch (e) {
      print('Error fetching user: $e');
      return 'Unknown';
    }
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}