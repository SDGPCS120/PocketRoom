import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../../common_widgets/glass_container.dart';
import '../../data/ai_search_provider.dart';

class AiPromptPanel extends ConsumerStatefulWidget {
  const AiPromptPanel({super.key});

  @override
  ConsumerState<AiPromptPanel> createState() => _AiPromptPanelState();
}

class _AiPromptPanelState extends ConsumerState<AiPromptPanel> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _onVoiceTap() async {
    if (!_isListening) {
      final status = await Permission.microphone.request();
      if (!mounted) return;
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
          onError: (val) {
            if (mounted) {
              setState(() => _isListening = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Speech recognition error: ${val.errorMsg}')),
              );
            }
          },
        );
        if (!mounted) return;
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _promptController.text = val.recognizedWords;
            }),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Speech recognition is not available on this device')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required for voice search')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onSendPrompt() async {
    final promptText = _promptController.text.trim();
    
    if (promptText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a search query'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GlassContainer(
        borderRadius: 32,
        blur: 15,
        opacity: 0.15,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.05),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _promptController,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'What kind of room are you designing?',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                  icon: _isListening ? Icons.mic : Icons.graphic_eq,
                  color: _isListening 
                      ? colorScheme.errorContainer.withOpacity(0.8) 
                      : colorScheme.surface.withOpacity(0.5),
                  iconColor: _isListening ? colorScheme.error : colorScheme.onSurface,
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
