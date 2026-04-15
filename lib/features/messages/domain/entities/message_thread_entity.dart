import 'package:equatable/equatable.dart';

class MessageThreadEntity extends Equatable {
  const MessageThreadEntity({
    required this.id,
    required this.name,
    required this.message,
    required this.avatarUrl,
    required this.lastSeenLabel,
    this.isOnline = false,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final String message;
  final String avatarUrl;
  final String lastSeenLabel;
  final bool isOnline;
  final int unreadCount;

  MessageThreadEntity copyWith({
    String? id,
    String? name,
    String? message,
    String? avatarUrl,
    String? lastSeenLabel,
    bool? isOnline,
    int? unreadCount,
  }) {
    return MessageThreadEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      message: message ?? this.message,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeenLabel: lastSeenLabel ?? this.lastSeenLabel,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    message,
    avatarUrl,
    lastSeenLabel,
    isOnline,
    unreadCount,
  ];
}
