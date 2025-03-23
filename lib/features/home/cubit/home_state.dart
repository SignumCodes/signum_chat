part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class ChatMatched extends HomeState {
  final String matchedUserId;
  final String roomId;

  ChatMatched(this.matchedUserId, this.roomId);
}

class NoMatchFound extends HomeState {}

class StartChatError extends HomeState {
  final String message;
  StartChatError(this.message);
}

class SearchCancelled extends HomeState {}