import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/data/ai_search_provider.dart';

class AiPromptPanel extends ConsumerStatefulWidget {
  final VoidCallback onBackToSearch;

  const AiPromptPanel({super.key, required this.onBackToSearch});

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
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: TextField(
                        controller: _promptController,
                        maxLines: 4,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Ask Anything....................',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Voice Search',
                        child: Material(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _onVoiceTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.graphic_eq,
                                color: Colors.grey[800],
                                size: 20,
                                semanticLabel: 'Voice Search',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Tooltip(
                        message: 'Send',
                        child: Material(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _isLoading ? null : _onSendPrompt,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                      semanticLabel: 'Send',
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Back to Search',
            child: Material(
              color: const Color(0xFFFFE5D3),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.onBackToSearch,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 24,
                    semanticLabel: 'Back to Search',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
