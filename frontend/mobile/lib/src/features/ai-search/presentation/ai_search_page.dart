import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common_widgets/glass_container.dart';
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
        backgroundColor: Colors.transparent,
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background decorations to enhance glass effect
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.1),
              ),
            ),
          ),
          
          Column(
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
            GlassContainer(
              padding: const EdgeInsets.all(24),
              borderRadius: 100,
              blur: 8,
              opacity: 0.1,
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: colorScheme.primary,
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
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: suggestions.map((text) {
        return GestureDetector(
          onTap: () => ref.read(aiSearchStateProvider.notifier).searchAi(text),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: 20,
            blur: 5,
            opacity: 0.05,
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

