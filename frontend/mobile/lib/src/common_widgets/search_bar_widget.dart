import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/data/ai_search_provider.dart';
import 'ai_search_button.dart';
import 'ai_prompt_panel.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  bool isAiSearchOpen = false;

  void _toggleAiSearch() {
    setState(() {
      isAiSearchOpen = !isAiSearchOpen;
      
      // Clear AI search results when switching back to normal search
      if (!isAiSearchOpen) {
        ref.read(aiSearchStateProvider.notifier).clearResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isAiSearchOpen) {
      return AiPromptPanel(onBackToSearch: _toggleAiSearch);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AiSearchButton(onTap: _toggleAiSearch),
        ],
      ),
    );
  }
}
