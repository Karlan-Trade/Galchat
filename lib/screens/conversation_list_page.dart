import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/narrative_service.dart';
import '../state/conversation_state.dart';

/// Conversation list (save list) page.
///
/// Shows all non-archived conversations, lets users create, continue,
/// and delete conversations. (Backup is in the Settings page.)
class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  @override
  void initState() {
    super.initState();
    // Load conversations on first build
    Future.microtask(() {
      ref.read(conversationListProvider.notifier).loadConversations();
    });
  }

  Future<void> _createAndEnter() async {
    final useWizard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: '取消',
              onPressed: () => Navigator.pop(ctx),
            ),
            const SizedBox(width: 4),
            const Text('新建对话'),
          ],
        ),
        content: const Text(
            '是否使用向导设定故事背景喵？\n\n选「是」：初雪会通过几轮问答帮你搭建世界观和角色设定\n选「否」：直接开始对话，初雪会主动发来第一条消息'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('否，直接开始')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('是，使用向导')),
        ],
      ),
    );

    if (!mounted) return;

    // null = 取消（点空白或取消按钮），不创建对话
    if (useWizard == null) return;

    if (useWizard == true) {
      Navigator.pushNamed(context, '/story-setup').then((_) {
        ref.read(conversationListProvider.notifier).loadConversations();
      });
    } else {
      // Create conversation directly
      final convId = await ref
          .read(conversationListProvider.notifier)
          .createConversation();
      if (convId != null && mounted) {
        Navigator.pushNamed(context, '/chat', arguments: convId).then((_) {
          ref.read(conversationListProvider.notifier).loadConversations();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('创建对话失败喵...请检查设置后重试'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openConversation(int convId) {
    Navigator.pushNamed(context, '/chat', arguments: convId).then((_) {
      ref.read(conversationListProvider.notifier).loadConversations();
    });
  }

  void _openMemoryEditor(Conversation conversation) {
    Navigator.pushNamed(
      context,
      '/conversation-memory',
      arguments: {
        'conversationId': conversation.id,
        'title': '${conversation.title} · 记忆',
      },
    );
  }

  void _deleteConversation(int convId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后将无法恢复，确定要继续吗喵？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final ns = ref.read(narrativeServiceProvider);
              await ns.init();
              await ns.deleteConversationMemory(convId);
              await ref
                  .read(conversationListProvider.notifier)
                  .deleteConversation(convId);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _confirmBatchDelete() {
    final state = ref.read(conversationListProvider);
    final count = state.selectedIds.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的 $count 个对话吗？删除后将无法恢复喵...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final ids = state.selectedIds.toList();
              final ns = ref.read(narrativeServiceProvider);
              await ns.init();
              for (final id in ids) {
                await ns.deleteConversationMemory(id);
              }
              await ref.read(conversationListProvider.notifier).batchDelete();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    return Scaffold(
      appBar: state.isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: '退出选择',
                onPressed: notifier.toggleSelectionMode,
              ),
              title: Text('已选 ${state.selectedIds.length} 项'),
              actions: [
                TextButton(
                  onPressed:
                      state.selectedIds.length == state.conversations.length
                          ? notifier.deselectAll
                          : notifier.selectAll,
                  child: Text(
                    state.selectedIds.length == state.conversations.length
                        ? '取消全选'
                        : '全选',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: state.selectedIds.isEmpty ? null : Colors.red),
                  tooltip: '删除选中',
                  onPressed:
                      state.selectedIds.isEmpty ? null : _confirmBatchDelete,
                ),
              ],
            )
          : AppBar(
              title: const Text('初雪 · GalChat'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: '设置',
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? _EmptyState(onCreate: _createAndEnter)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.conversations.length + 1, // +1 for fab space
                  itemBuilder: (context, index) {
                    if (index < state.conversations.length) {
                      return _ConversationTile(
                        conversation: state.conversations[index],
                        isSelectionMode: state.isSelectionMode,
                        isSelected: state.selectedIds
                            .contains(state.conversations[index].id),
                        onTap: () =>
                            _openConversation(state.conversations[index].id),
                        onDelete: () =>
                            _deleteConversation(state.conversations[index].id),
                        onEditMemory: () =>
                            _openMemoryEditor(state.conversations[index]),
                        onRename: (newTitle) => ref
                            .read(conversationListProvider.notifier)
                            .renameConversation(
                                state.conversations[index].id, newTitle),
                        onToggleSelect: () => notifier
                            .toggleSelection(state.conversations[index].id),
                        onLongPress: () {
                          if (!state.isSelectionMode) {
                            notifier.toggleSelectionMode();
                            notifier
                                .toggleSelection(state.conversations[index].id);
                          }
                        },
                      );
                    }
                    // Bottom padding for FAB (hidden in selection mode)
                    return SizedBox(height: state.isSelectionMode ? 0 : 80);
                  },
                ),
      floatingActionButton: state.isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _createAndEnter,
              icon: const Icon(Icons.add),
              label: const Text('新对话'),
            ),
    );
  }
}

/// Empty state when no conversations exist.
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有任何对话喵~',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮开始和初雪聊天吧！',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('开始新对话'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single conversation tile in the list.
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEditMemory;
  final VoidCallback onToggleSelect;
  final VoidCallback onLongPress;
  final void Function(String newTitle) onRename;

  const _ConversationTile({
    required this.conversation,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onEditMemory,
    required this.onRename,
    required this.onToggleSelect,
    required this.onLongPress,
  });

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: '输入新标题'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) onRename(newTitle);
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = conversation.updatedAt;
    final dateStr = _formatDate(date);

    Widget tile = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.4)
              : theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: isSelectionMode ? onToggleSelect : onTap,
        onLongPress: isSelectionMode ? null : onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggleSelect(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                )
              : CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.chat,
                      color: theme.colorScheme.onPrimaryContainer, size: 20),
                ),
          title: Text(conversation.title,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(dateStr,
              style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          trailing: isSelectionMode
              ? null
              : PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'rename') _showRenameDialog(context);
                    if (action == 'memory') onEditMemory();
                    if (action == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('重命名'),
                            contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(
                        value: 'memory',
                        child: ListTile(
                            leading: Icon(Icons.psychology_alt_outlined),
                            title: Text('记忆'),
                            contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title:
                                Text('删除', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero)),
                  ],
                ),
        ),
      ),
    );

    // Wrap with Dismissible only when not in selection mode
    if (isSelectionMode) return tile;
    return Dismissible(
      key: Key('conv_${conversation.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: tile,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
