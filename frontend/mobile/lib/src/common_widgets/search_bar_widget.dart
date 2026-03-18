import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/data/providers.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current search query
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSuffixActions(String currentQuery) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI search coming soon')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD84B3E),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch to see if we need to show the clear button
    final currentQuery = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5D3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: _buildSuffixActions(currentQuery),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    );
  }
}
