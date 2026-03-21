import '../../../core/services/api_client.dart';
import '../../../core/utils/extensions.dart';
import 'widgets/budget_result_page.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BudgetPlannerPage extends StatefulWidget {
  const BudgetPlannerPage({super.key});

  @override
  State<BudgetPlannerPage> createState() => _BudgetPlannerPageState();
}

class _BudgetPlannerPageState extends State<BudgetPlannerPage> {
  // UI state
  double _budget = 200000;
  final double _minBudget = 25000;
  final double _maxBudget = 500000;

  final Map<String, _ReqItem> _requiredItems = const {
    'sofa': _ReqItem(label: 'Sofa', icon: Icons.weekend),
    'bed': _ReqItem(label: 'Bed', icon: Icons.bed),
    'wardrobe': _ReqItem(label: 'Wardrobe', icon: Icons.door_sliding),
    'chair': _ReqItem(label: 'Chair', icon: Icons.chair_alt),
  };
  final Set<String> _selectedRequired = {'sofa', 'bed'};

  final List<String> _styles = const ['Modern', 'Minimal', 'Scandinavian', 'Classic'];
  String _selectedStyle = 'Modern';

  final List<_ColorOption> _colorOptions = const [
    _ColorOption(name: 'Oak', color: Color(0xFFD8B27C)),
    _ColorOption(name: 'Charcoal', color: Color(0xFF2E3A44)),
    _ColorOption(name: 'Navy', color: Color(0xFF0A1E8C)),
    _ColorOption(name: 'White', color: Color(0xFFFFFFFF), border: Color(0xFFBDBDBD)),
    _ColorOption(name: 'Sage', color: Color(0xFFA7BFA8)),
  ];
  final Set<String> _selectedColors = {'Oak', 'Navy'};

  bool _loading = false;

  // API base URL:
  String get baseUrl => ApiClient.baseUrl;

  Future<void> _generateBundle() async {
    if (_selectedRequired.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 1 required item.')),
      );
      return;
    }

    final payload = {
      "totalBudget": _budget.round(),
      "requiredCategories": _selectedRequired.toList(),
      "preferences": {
        "style": _selectedStyle,
        "colors": _selectedColors.toList(),
      }
    };

    setState(() => _loading = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/budget/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(res.body);
        final resultData = responseBody['data'] ?? responseBody;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BudgetResultPage(result: resultData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.statusCode}\n${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE39A3B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Budget Planner',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Center(
                child: Text('Total Budget', style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _budget.toLKR(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text('25K', style: TextStyle(color: Colors.black38, fontSize: 12)),
                  Spacer(),
                  Text('500K', style: TextStyle(color: Colors.black38, fontSize: 12)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: const Color(0xFFEDEDED),
                  thumbColor: Colors.white,
                  overlayColor: accent.withValues(alpha: 0.15),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: _budget,
                  min: _minBudget,
                  max: _maxBudget,
                  onChanged: (v) => setState(() => _budget = v),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Select Required Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _requiredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final key = _requiredItems.keys.elementAt(i);
                    final item = _requiredItems[key]!;
                    final selected = _selectedRequired.contains(key);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedRequired.remove(key);
                          } else {
                            _selectedRequired.add(key);
                          }
                        });
                      },
                      child: Container(
                        width: 86,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFFFF5EA) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? accent : const Color(0xFFE6E6E6),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, color: Colors.black87),
                            const SizedBox(height: 8),
                            Text(item.label,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text('Style Preference',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('What is your style preference?',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStyle,
                items: _styles
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStyle = v ?? _selectedStyle),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Preferred Colours',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Select the colours you’d like to see in your bundle.',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 14,
                children: _colorOptions.map((opt) {
                  final selected = _selectedColors.contains(opt.name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedColors.remove(opt.name);
                        } else {
                          _selectedColors.add(opt.name);
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: opt.color,
                            border: Border.all(
                              color: opt.border ?? (selected ? accent : const Color(0xFFE0E0E0)),
                              width: selected ? 2 : 1.2,
                            ),
                          ),
                          child: selected
                              ? Icon(Icons.check,
                                  color: opt.color == Colors.white ? Colors.black : Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(opt.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _generateBundle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Generate Bundle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReqItem {
  final String label;
  final IconData icon;
  const _ReqItem({required this.label, required this.icon});
}

class _ColorOption {
  final String name;
  final Color color;
  final Color? border;
  const _ColorOption({required this.name, required this.color, this.border});
}
