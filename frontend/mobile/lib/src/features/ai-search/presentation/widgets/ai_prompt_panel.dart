import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_search_provider.dart';

class AiPromptPanel extends ConsumerStatefulWidget {
  const AiPromptPanel({super.key});

  @override
  ConsumerState<AiPromptPanel> createState() => _AiPromptPanelState();
}

class _AiPromptPanelState extends ConsumerState<AiPromptPanel> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _onVoiceTap() {
    // Placeholder for voice search functionality
  }

  void _onSendPrompt() async {
    final promptText = _promptController.text.trim();
    
    if (promptText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search query'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call AI search
      await ref.read(aiSearchStateProvider.notifier).searchAi(promptText);
      
      // Clear the input field after successful search
      _promptController.clear();
      
      // Unfocus to hide keyboard
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), // Extra bottom padding for safe area
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _promptController,
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'What kind of room are you designing?',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(
                icon: Icons.graphic_eq,
                color: colorScheme.surface,
                iconColor: colorScheme.onSurface,
                onTap: _onVoiceTap,
              ),
              const SizedBox(height: 8),
              _buildIconButton(
                icon: Icons.send,
                color: colorScheme.primary,
                iconColor: colorScheme.onPrimary,
                isLoading: _isLoading,
                onTap: _onSendPrompt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
        ),
      ),
    );
  }
}
