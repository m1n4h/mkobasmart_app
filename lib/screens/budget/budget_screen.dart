// lib/screens/budget/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Budget Overview Chart
          AnimatedCard(
            delay: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'budget_overview'.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 40,
                          title: 'Groceries 40%',
                          color: Colors.green,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 20,
                          title: 'Transport 20%',
                          color: Colors.blue,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 15,
                          title: 'Utilities 15%',
                          color: Colors.orange,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 15,
                          title: 'Shopping 15%',
                          color: Colors.purple,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 10,
                          title: 'Others 10%',
                          color: Colors.red,
                          radius: 60,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Category Budgets
          AnimatedCard(
            delay: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'category_budget'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text('set_budget'.tr(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBudgetItem('Groceries', 400000, 320000, Colors.green),
                _buildBudgetItem('Transport', 200000, 180000, Colors.blue),
                _buildBudgetItem('Utilities', 150000, 130000, Colors.orange),
                _buildBudgetItem('Shopping', 150000, 160000, Colors.red),
                _buildBudgetItem('Entertainment', 100000, 85000, Colors.purple),
              ],
            ),
          ),
          
          // Savings Goal
          AnimatedCard(
            delay: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Savings Goal',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Emergency Fund',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TSh 500,000 / 1,000,000',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          '50%',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                      ),
                      child: const Text('Add to Goal'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String category, double budget, double spent, Color color) {
    final percentage = spent / budget;
    final isOver = spent > budget;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                'TSh ${spent.toStringAsFixed(0)} / TSh ${budget.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOver ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage > 1 ? 1 : percentage,
            backgroundColor: Colors.grey[300],
            color: isOver ? Colors.red : color,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'over_budget'.tr(context),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}