import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/fake_messages_repository.dart';
import '../bloc/messages_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const Color _samsPrimary = SamsUiTokens.primary;

  Future<void> _refreshMessages(BuildContext context) async {
    final bloc = context.read<MessagesBloc>();
    bloc.add(const MessagesRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != MessagesStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessagesBloc(repository: FakeMessagesRepository())..add(const MessagesRequested()),
      child: BlocBuilder<MessagesBloc, MessagesState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.threads != current.threads ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          final horizontalPadding = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
          final chats = state.threads;

          if (state.status == MessagesStatus.loading || state.status == MessagesStatus.initial) {
            return const _MessagesLoadingSkeleton();
          }

          if (state.status == MessagesStatus.failure) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              body: SamsErrorState(
                title: 'Couldn\'t load messages',
                message: state.errorMessage ?? 'Failed to load messages. Please try again.',
                retryLabel: 'Retry',
                onRetry: () => context.read<MessagesBloc>().add(const MessagesRequested()),
              ),
            );
          }

          return Scaffold(
  backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshMessages(context),
        color: SamsUiTokens.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 14),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search messages',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SamsUiTokens.divider),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: _samsPrimary, width: 1.3),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (chats.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 72),
                child: EmptyStateWidget(
                  icon: Icons.mark_chat_unread_rounded,
                  title: 'No messages yet',
                  subtitle: 'Start a new conversation and your chats will appear here.',
                  actionLabel: 'Refresh Inbox',
                  onAction: () => context.read<MessagesBloc>().add(const MessagesRequested()),
                ),
              )
            else
              ...chats.asMap().entries.map((entry) {
                final index = entry.key;
                final chat = entry.value;

                return Padding(
                  padding: EdgeInsets.only(bottom: index == chats.length - 1 ? 0 : 8),
                  child: ListTile(
                    onTap: () {},
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFE1E7EF)),
                    ),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _samsPrimary.withValues(alpha: 0.12),
                      child: const Icon(Icons.person, color: _samsPrimary, size: 16),
                    ),
                    title: Text(
                      chat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        chat.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    trailing: const SizedBox.shrink(),
                  ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _samsPrimary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
          );
        },
      ),
    );
  }
}

class _MessagesLoadingSkeleton extends StatelessWidget {
  const _MessagesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 10, bottom: 16),
        children: [
          const ShimmerWidget(height: 46, borderRadius: BorderRadius.all(Radius.circular(12))),
          const SizedBox(height: 12),
          const SamsLoadingView(
            title: 'Loading your messages...',
            message: 'Syncing your latest conversations from SAMS...',
          ),
          const SizedBox(height: 10),
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 3 ? 0 : 8),
              child: const ShimmerWidget(
                height: 58,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
