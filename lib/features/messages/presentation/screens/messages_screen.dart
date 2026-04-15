import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/message_thread_entity.dart';
import '../../data/repositories/fake_messages_repository.dart';
import '../bloc/messages_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';
import '../../../../shared/widgets/shimmer_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final MessagesBloc _bloc;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = MessagesBloc(repository: FakeMessagesRepository())
      ..add(const MessagesRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _refreshMessages() async {
    _bloc.add(const MessagesRequested());
    try {
      await _bloc.stream
          .firstWhere((state) => state.status != MessagesStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  Future<void> _openThread(MessageThreadEntity thread) async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: _bloc,
            child: _ChatThreadScreen(thread: thread),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved);

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );

    _bloc.add(const MessageThreadClosed());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<MessagesBloc, MessagesState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.visibleThreads != current.visibleThreads ||
              previous.searchQuery != current.searchQuery ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          if (state.status == MessagesStatus.loading ||
              state.status == MessagesStatus.initial) {
            return const _MessagesLoadingSkeleton();
          }

          if (state.status == MessagesStatus.failure) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SamsErrorState(
                title: 'Couldn\'t load messages',
                message:
                    state.errorMessage ??
                    'Failed to load messages. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<MessagesBloc>().add(const MessagesRequested()),
              ),
            );
          }

          final threads = state.visibleThreads;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'Messages'),
            body: Stack(
              children: [
                const Positioned(top: -90, right: -60, child: _BackdropBlob()),
                const Positioned(
                  bottom: 120,
                  left: -70,
                  child: _BackdropBlob(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshMessages,
                  color: SamsUiTokens.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: SamsUiTokens.pageInsets(
                      context,
                      top: 12,
                      bottom: 22,
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF063454), Color(0xFF0A4D78)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF063454,
                              ).withValues(alpha: 0.24),
                              blurRadius: 20,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SamsLocaleText(
                              'Friends & Faculty',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            SamsLocaleText(
                              'Search your friends, open chats, and stay connected in real time.',
                              style: TextStyle(
                                color: Color(0xFFE0EAF6),
                                fontSize: 12.6,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => context.read<MessagesBloc>().add(
                          MessagesSearchChanged(value),
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('Search messages'),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.primary,
                          ),
                          suffixIcon: state.searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<MessagesBloc>().add(
                                      const MessagesSearchChanged(''),
                                    );
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.78,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.35,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (threads.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 70),
                          child: EmptyStateWidget(
                            icon: Icons.person_search_rounded,
                            title: state.searchQuery.isEmpty
                                ? 'No messages yet'
                                : 'No friends found',
                            subtitle: state.searchQuery.isEmpty
                                ? 'Your updates and messages from SAMS will appear here.'
                                : 'Try another name or keyword.',
                            actionLabel: 'Refresh Updates',
                            onAction: () => context.read<MessagesBloc>().add(
                              const MessagesRequested(),
                            ),
                          ),
                        )
                      else
                        ...threads.asMap().entries.map((entry) {
                          final index = entry.key;
                          final thread = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == threads.length - 1 ? 0 : 9,
                            ),
                            child: _ThreadCard(
                              thread: thread,
                              onTap: () => _openThread(thread),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: threads.isEmpty ? null : () => _openThread(threads[0]),
              backgroundColor: SamsUiTokens.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_rounded),
              label: const SamsLocaleText('Start chatting'),
            ),
          );
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final MessageThreadEntity thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardGradient = _threadGradient(
      thread.id,
      Theme.of(context).brightness,
    );

    return SamsPressable(
      onTap: onTap,
      enableLift: true,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: cardGradient,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
        child: Row(
          children: [
            _ThreadAvatar(thread: thread, radius: 22),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(thread.lastSeenLabel),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.25,
                      fontSize: 12.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (thread.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: SamsUiTokens.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      thread.unreadCount > 99 ? '99+' : '${thread.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _threadGradient(String id, Brightness brightness) {
    final index = id.hashCode.abs() % _gradients.length;
    final base = _gradients[index];
    final opacity = brightness == Brightness.dark ? 0.16 : 0.12;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base[0].withValues(alpha: opacity),
        base[1].withValues(alpha: opacity * 0.72),
      ],
    );
  }
}

class _ChatThreadScreen extends StatefulWidget {
  const _ChatThreadScreen({required this.thread});

  final MessageThreadEntity thread;

  @override
  State<_ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<_ChatThreadScreen> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<MessagesBloc>().add(MessageThreadOpened(widget.thread));
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    context.read<MessagesBloc>().add(MessageSent(text));
    _composerController.clear();
    setState(() => _hasText = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (previous, current) {
        return previous.activeThread != current.activeThread ||
            previous.activeMessages != current.activeMessages ||
            previous.cachedConversations != current.cachedConversations ||
            previous.isThreadLoading != current.isThreadLoading;
      },
      builder: (context, state) {
        final inActiveThread = state.activeThread?.id == widget.thread.id;
        final thread = inActiveThread ? state.activeThread! : widget.thread;
        final messages = inActiveThread
            ? state.activeMessages
            : (state.cachedConversations[widget.thread.id] ?? const []);
        final isLoading = inActiveThread && state.isThreadLoading;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                _ThreadAvatar(thread: thread, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        thread.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        thread.isOnline
                            ? context.tr('Online')
                            : '${context.tr('Last seen')} ${context.tr(thread.lastSeenLabel)}',
                        style: const TextStyle(
                          fontSize: 11.8,
                          color: Color(0xFFE1ECF8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                top: -120,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0AA7A7).withValues(alpha: 0.09),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: isLoading
                          ? const _ConversationLoading()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                10,
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return _MessageBubble(message: message);
                              },
                            ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: isDark ? 0.90 : 0.68,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.32 : 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _composerController,
                              minLines: 1,
                              maxLines: 4,
                              onChanged: (value) {
                                final hasText = value.trim().isNotEmpty;
                                if (hasText != _hasText) {
                                  setState(() => _hasText = hasText);
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: context.tr('Type a message...'),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _hasText
                                    ? const [
                                        Color(0xFF0A4D78),
                                        Color(0xFF1E88E5),
                                      ]
                                    : [
                                        colorScheme.outlineVariant,
                                        colorScheme.outlineVariant,
                                      ],
                              ),
                            ),
                            child: IconButton(
                              onPressed: _hasText ? _sendMessage : null,
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sentByMe = message.sentByMe;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
          decoration: BoxDecoration(
            gradient: sentByMe
                ? const LinearGradient(
                    colors: [Color(0xFF0A4D78), Color(0xFF1E88E5)],
                  )
                : null,
            color: sentByMe ? null : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(sentByMe ? 14 : 4),
              bottomRight: Radius.circular(sentByMe ? 4 : 14),
            ),
            border: Border.all(
              color: sentByMe
                  ? Colors.transparent
                  : colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: sentByMe ? Colors.white : colorScheme.onSurface,
                  fontSize: 13.4,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  message.sentAtLabel,
                  style: TextStyle(
                    color: sentByMe
                        ? Colors.white.withValues(alpha: 0.82)
                        : colorScheme.onSurfaceVariant,
                    fontSize: 10.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.thread, required this.radius});

  final MessageThreadEntity thread;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(thread.name);
    final color = _avatarColorFor(thread.id);
    final size = radius * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.84), color],
            ),
          ),
          child: ClipOval(
            child: thread.avatarUrl.isEmpty
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : Image.network(
                    thread.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (thread.isOnline)
          Positioned(
            right: -0.8,
            bottom: -0.8,
            child: Container(
              width: math.max(8, radius * 0.46),
              height: math.max(8, radius * 0.46),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0DB66F),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static String _initials(String text) {
    final words = text
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return 'S';
    }
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    final first = words.first.substring(0, 1).toUpperCase();
    final last = words.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}

class _BackdropBlob extends StatelessWidget {
  const _BackdropBlob();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationLoading extends StatelessWidget {
  const _ConversationLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      children: [
        const SamsLoadingView(
          title: 'Loading your messages...',
          message: 'Preparing your inbox and latest conversation previews...',
        ),
        const SizedBox(height: 8),
        ...List.generate(
          6,
          (index) => Align(
            alignment: index.isEven
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: index == 5 ? 0 : 8),
              child: ShimmerWidget(
                width: index.isEven ? 220 : 170,
                height: 54,
                borderRadius: const BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color _avatarColorFor(String seed) {
  final colors = [
    const Color(0xFF1E88E5),
    const Color(0xFF0AA7A7),
    const Color(0xFF0E8F54),
    const Color(0xFFCB6A00),
    const Color(0xFF6C63FF),
    const Color(0xFFD95763),
  ];

  return colors[seed.hashCode.abs() % colors.length];
}

const List<List<Color>> _gradients = [
  [Color(0xFF1E88E5), Color(0xFF0A4D78)],
  [Color(0xFF0AA7A7), Color(0xFF0E8F54)],
  [Color(0xFFC47B07), Color(0xFFB7791F)],
  [Color(0xFF5C6BC0), Color(0xFF3949AB)],
  [Color(0xFFD95763), Color(0xFFB53D57)],
];

class _MessagesLoadingSkeleton extends StatelessWidget {
  const _MessagesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Messages'),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 10, bottom: 16),
        children: [
          const ShimmerWidget(
            height: 76,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          const SizedBox(height: 12),
          const ShimmerWidget(
            height: 46,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 4 ? 0 : 9),
              child: const ShimmerWidget(
                height: 88,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
