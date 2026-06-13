import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

/// Holds the UI state for the conversation list page.
class ConversationListState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? errorMessage;
  final bool isSelectionMode;
  final Set<int> selectedIds;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSelectionMode,
    Set<int>? selectedIds,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

/// Riverpod state notifier for the conversation list.
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final AppDatabase _db;

  ConversationListNotifier(this._db) : super(const ConversationListState());

  /// Load all non-archived conversations.
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations = await _db.allConversations();
      state = ConversationListState(conversations: conversations);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '加载对话列表失败喵: $e');
    }
  }

  /// Create a new conversation for the default character.
  Future<int?> createConversation() async {
    try {
      // Get or create the default character
      Character? character;
      try {
        character = await _db.getDefaultCharacter();
      } catch (_) {
        // Character not seeded — this happens after DB migration
        await _db.seedDefaultCharacter();
        character = await _db.getDefaultCharacter();
      }

      // Create a new conversation
      final now = DateTime.now();
      final title = '新对话 ${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      final convId = await _db.createConversation(character.id, title);

      // Refresh the list
      await loadConversations();

      return convId;
    } catch (e) {
      state = state.copyWith(errorMessage: '创建对话失败喵: $e');
      return null;
    }
  }

  /// Rename a conversation.
  Future<void> renameConversation(int id, String newTitle) async {
    try {
      await _db.updateConversationTitle(id, newTitle);
      await loadConversations();
    } catch (e) {
      state = state.copyWith(errorMessage: '重命名失败喵: $e');
    }
  }

  /// Delete a conversation by ID.
  Future<void> deleteConversation(int id) async {
    try {
      await _db.deleteConversation(id);
      await loadConversations();
    } catch (e) {
      state = state.copyWith(errorMessage: '删除失败喵: $e');
    }
  }

  /// Archive a conversation.
  Future<void> archiveConversation(int id) async {
    try {
      await _db.archiveConversation(id);
      await loadConversations();
    } catch (e) {
      state = state.copyWith(errorMessage: '归档失败喵: $e');
    }
  }

  // ──────────── Batch selection ────────────

  /// Enter or exit selection mode.
  void toggleSelectionMode() {
    if (state.isSelectionMode) {
      state = state.copyWith(isSelectionMode: false, selectedIds: const {});
    } else {
      state = state.copyWith(isSelectionMode: true, selectedIds: const {});
    }
  }

  /// Toggle a single conversation's selection state.
  void toggleSelection(int id) {
    final ids = Set<int>.from(state.selectedIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(selectedIds: ids);
  }

  /// Select all conversations.
  void selectAll() {
    state = state.copyWith(
      selectedIds: state.conversations.map((c) => c.id).toSet(),
    );
  }

  /// Deselect all conversations.
  void deselectAll() {
    state = state.copyWith(selectedIds: const {});
  }

  /// Delete all selected conversations.
  Future<void> batchDelete() async {
    final ids = state.selectedIds.toList();
    if (ids.isEmpty) return;

    state = state.copyWith(clearError: true);
    try {
      for (final id in ids) {
        await _db.deleteConversation(id);
      }
      state = state.copyWith(isSelectionMode: false, selectedIds: const {});
      await loadConversations();
    } catch (e) {
      state = state.copyWith(errorMessage: '批量删除失败喵: $e');
    }
  }
}

/// Riverpod provider for the conversation list.
final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return ConversationListNotifier(db);
  },
);
