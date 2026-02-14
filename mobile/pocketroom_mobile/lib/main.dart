import 'package:flutter/material.dart';
import 'features/budget/ui/budget_planner_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BudgetPlannerPage(),
    );
  }
}
