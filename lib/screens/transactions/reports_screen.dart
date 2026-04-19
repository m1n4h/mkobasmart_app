// lib/screens/transactions/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_card.dart';
import '../../localization/app_localizations.dart';
import '../../provider/transaction_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';
  final List<String> _periods = ['week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Insights'.tr(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                transactionProvider.filterByPeriod(value!);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cash Flow Chart
            AnimatedCard(
              delay: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Flow Trend',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Income & Expense Analysis',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('TSh ${value.toInt()}k');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                if (value.toInt() >= 0 && value.toInt() < months.length) {
                                  return Text(months[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 100),
                              FlSpot(1, 120),
                              FlSpot(2, 110),
                              FlSpot(3, 140),
                              FlSpot(4, 130),
                              FlSpot(5, 160),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 80),
                              FlSpot(1, 90),
                              FlSpot(2, 85),
                              FlSpot(3, 110),
                              FlSpot(4, 105),
                              FlSpot(5, 130),
                            ],
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Net Savings Card
            AnimatedCard(
              delay: 100,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Net Savings', style: TextStyle(color: Colors.white)),
                    Text(
                      'TSh ${(transactionProvider.totalIncome - transactionProvider.totalExpenses).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          '12.6% annualized return',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Spending Categories
            AnimatedCard(
              delay: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Categories',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem('Groceries', 40, Colors.green),
                  _buildCategoryItem('Transport', 20, Colors.blue),
                  _buildCategoryItem('Lifestyle', 30, Colors.orange),
                  _buildCategoryItem('Utilities', 10, Colors.red),
                ],
              ),
            ),
            
            // Financial Records
            AnimatedCard(
              delay: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Records',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildRecordItem('Salary', 'TSh 3,200,000', '01/01/2024'),
                  _buildRecordItem('Disbursements', 'TSh 146,000', '01/01/2024'),
                  _buildRecordItem('Transfers', 'TSh 50,000', '01/01/2024'),
                ],
              ),
            ),
            
            // Data Portability
            AnimatedCard(
              delay: 400,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: Text('Export CSV'.tr(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.cloud_upload),
                      label: Text('Backup Data'.tr(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
              Text('${percentage.toInt()}%', style: TextStyle(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            color: color,
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String title, String amount, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}