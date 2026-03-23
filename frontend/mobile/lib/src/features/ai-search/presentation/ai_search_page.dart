import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_search_provider.dart';
import '../data/ai_search_state.dart';
import 'widgets/ai_prompt_panel.dart';
import 'widgets/ai_search_results_view.dart';

class AiSearchPage extends ConsumerWidget {
  const AiSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiSearchStateProvider);
    final isInitial = state is AiSearchInitial;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: colorScheme.onSurface, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Interior Assistant',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (isInitial)
                  _buildWelcomeState(context, ref)
                else
                  const AiSearchResultsView(),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
          ),
          const AiPromptPanel(),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D3).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Color(0xFFD84B3E),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How can I help you design\nyour room today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try describing the vibe or specific items you need.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            _buildSuggestions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final suggestions = [
      'Modern oak dining table',
      'Blue ergonomic office chair',
      'Minimalist coffee table',
      'Comfy gray velvet sofa',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: suggestions.map((text) {
        return ActionChip(
          label: Text(
            text,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () {
            ref.read(aiSearchStateProvider.notifier).searchAi(text);
          },
        );
      }).toList(),
    );
  }
}
