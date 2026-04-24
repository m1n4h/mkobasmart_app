// lib/screens/dashboard/dashboard_screen.dart
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mkobasmart_app/widgets/category_nav_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localization/app_localizations.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/customer_header.dart';
import '../../widgets/pulse_animation.dart';
import '../authentication/auth_screen.dart';
import '../budget/budget_screen.dart';
import '../debts/debts_screen.dart';
import '../more/more_screen.dart';
import '../transactions/transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const DashboardContent(),
    const TransactionsScreen(),
    const DebtsScreen(),
    const BudgetScreen(),
    const MoreScreen(),
    const CategoryNavCard(),
  ];

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _ensureAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'dashboard'.tr(context),
            showBackButton: false,
            onMenuTap: () {
              // Open drawer or menu
            },
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  String _formatTsh(num value) {
    final rounded = value.round();
    final text = rounded.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return 'TSh ${buffer.toString()}';
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final summaryResponse = await ApiService.get('/dashboard/summary/');
    final chartsResponse = await ApiService.get('/dashboard/charts/?period=month');
    final categoryResponse =
        await ApiService.get('/dashboard/category_breakdown/?period=month');

    if (summaryResponse.statusCode != 200) {
      throw Exception('Failed to load dashboard summary');
    }

    final summary = json.decode(summaryResponse.body) as Map<String, dynamic>;
    final charts = chartsResponse.statusCode == 200
        ? (json.decode(chartsResponse.body) as List<dynamic>)
        : <dynamic>[];
    final categories = categoryResponse.statusCode == 200
        ? (json.decode(categoryResponse.body) as List<dynamic>)
        : <dynamic>[];

    return {
      'summary': summary,
      'charts': charts,
      'categories': categories,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load dashboard data from backend.',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          );
        }

        final summary = snapshot.data!['summary'] as Map<String, dynamic>;
        final charts = snapshot.data!['charts'] as List<dynamic>;
        final categories = snapshot.data!['categories'] as List<dynamic>;
        final recentTransactions =
            (summary['recent_transactions'] as List<dynamic>? ?? []);
        final totalIncome =
            double.tryParse(summary['total_income'].toString()) ?? 0;
        final totalExpenses =
            double.tryParse(summary['total_expenses'].toString()) ?? 0;
        final currentEquity =
            double.tryParse(summary['current_equity'].toString()) ?? 0;

        final chartSpots = <FlSpot>[];
        for (int i = 0; i < charts.length; i++) {
          final point = charts[i] as Map<String, dynamic>;
          final expense = double.tryParse(point['expense'].toString()) ?? 0;
          chartSpots.add(FlSpot(i.toDouble(), expense));
        }

        final chartLabels = charts
            .map((e) => (e as Map<String, dynamic>)['label'].toString())
            .toList();

        final topThree = categories.take(3).map((e) => e as Map<String, dynamic>).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              AnimatedCard(
                delay: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'current_equity'.tr(context),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTsh(currentEquity),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${'monthly_income'.tr(context)}: ${_formatTsh(totalIncome)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          '${'monthly_expenses'.tr(context)}: ${_formatTsh(totalExpenses)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCard(
                delay: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'expense_flow'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartSpots.isEmpty
                                  ? const [FlSpot(0, 0)]
                                  : chartSpots,
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx >= 0 && idx < chartLabels.length) {
                                    return Text(chartLabels[idx], style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedCard(
                delay: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'categories'.tr(context),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (topThree.isEmpty)
                      const Text('No expense categories yet.')
                    else
                      ...topThree.map((c) {
                        final total = double.tryParse(c['total'].toString()) ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c['category'].toString()),
                              Text(_formatTsh(total)),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
              AnimatedCard(
                delay: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'recent_transactions'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...recentTransactions.take(5).map((tx) {
                      final txMap = tx as Map<String, dynamic>;
                      final isExpense = txMap['transaction_type'] == 'expense';
                      final amount =
                          double.tryParse(txMap['amount'].toString()) ?? 0;
                      return _buildTransactionItem(
                        (txMap['description']?.toString().isNotEmpty ?? false)
                            ? txMap['description'].toString()
                            : (txMap['category_name'] ?? 'Transaction')
                                .toString(),
                        '${isExpense ? '-' : '+'}${_formatTsh(amount)}',
                        isExpense ? Icons.remove_circle : Icons.add_circle,
                      );
                    }).toList(),
                  ],
                ),
              ),
              AnimatedCard(
                delay: 400,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'savings'.tr(context),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTsh(totalIncome - totalExpenses),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PulseAnimation(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.savings,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(String title, String amount, IconData icon) {
    final isExpense = amount.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isExpense ? Colors.red : Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}