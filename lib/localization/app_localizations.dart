// lib/localization/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'MkobaSmart',
      'skip': 'Skip',
      'continue': 'Continue',
      'next': 'Next',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'total': 'Total',
      'view_all': 'View All',
      
      // Navigation
      'dashboard': 'Dashboard',
      'transactions': 'Transactions',
      'debts': 'Debts',
      'budget': 'Budget',
      'more': 'More',
      'settings': 'Settings',
      'profile': 'Profile',
      
      // Authentication
      'welcome_back': 'Welcome Back',
      'sign_in': 'Sign In',
      'email_or_phone': 'Email or Phone',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'phone_number': 'Phone Number',
      'sign_in_google': 'Sign in with Google',
      'continue_as_guest': 'Continue as Guest',
      'create_account': 'Create Account',
      'dont_have_account': "Don't have an account?",
      'reset_instructions': 'Send Reset Instructions',
      'remember_password': 'Remembered your password?',
      // In 'en' map add:
'already_have_account': 'Already have an account?',


      // Dashboard
      'current_equity': 'Current Equity',
      'deposit': 'Deposit',
      'transfer': 'Transfer',
      'expense_flow': 'Expense Flow',
      'monthly_expenditure': 'Monthly Expenditure',
      'recent_transactions': 'Recent Transactions',
      'categories': 'Categories',
      'income': 'Income',
      'expenses': 'Expenses',
      'savings': 'Savings',
      'budget_overview': 'Budget Overview',
      'set_budget': 'Set Budget',
      'monthly_income': 'Monthly Income',
      'monthly_expenses': 'Monthly Expenses',
      
      // Transaction
      'add_transaction': 'Add Transaction',
      'transaction_history': 'Transaction History',
      'transaction_type': 'Transaction Type',
      'amount': 'Amount',
      'date': 'Date',
      'category': 'Category',
      'description': 'Description',
      'receipt': 'Receipt',
      'add_photo': 'Add Photo',
      
      // Debts
      'debt_tracking': 'Debt Tracking',
      'money_owed_to_me': "Money Owed to Me",
      'money_i_owe': "Money I Owe",
      'lenders': 'Lenders',
      'borrowers': 'Borrowers',
      'due_date': 'Due Date',
      'status': 'Status',
      
      // Budget
      'budget_planning': 'Budget Planning',
      'category_budget': 'Category Budget',
      'remaining': 'Remaining',
      'spent': 'Spent',
      'over_budget': 'Over Budget',
      
      // Reports
      'reports_insights': 'Reports & Insights',
      'cash_flow': 'Cash Flow',
      'revenue_expense_analysis': 'Revenue and Expenses Analysis',
      'monthly_performance': 'Monthly Performance',
      'income_calendar': 'Income Calendar',
      'expense_calendar': 'Expense Calendar',
      
      // Settings
      'personal_info': 'Personal Information',
      'change_password': 'Change Password',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_default': 'System Default',
      'notifications': 'Notifications',
      'data_export': 'Data Export',
      'logout': 'Logout',
      'help_support': 'Help & Support',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      
      // Onboarding
      'onboarding_title_1': 'Smart Financial Management',
      'onboarding_desc_1': 'Track your income, expenses, and debts all in one place',
      'onboarding_title_2': 'Visual Insights',
      'onboarding_desc_2': 'Beautiful charts and graphs to understand your spending',
      'onboarding_title_3': 'Stay in Control',
      'onboarding_desc_3': 'Set budgets and get notified when you overspend',
      
      // Animations & Messages
      'loading': 'Loading...',
      'no_data': 'No data available',
      'error_occurred': 'An error occurred',
      'success': 'Success!',
      'network_error': 'Network error',
    },
    'sw': {
      // Common
      'app_name': 'MkobaSmart',
      'skip': 'Ruka',
      'continue': 'Endelea',
      'next': 'Inayofuata',
      'back': 'Nyuma',
      'save': 'Hifadhi',
      'cancel': 'Ghairi',
      'delete': 'Futa',
      'edit': 'Hariri',
      'search': 'Tafuta',
      'filter': 'Chuja',
      'total': 'Jumla',
      'view_all': 'Tazama Zote',
      
      // Navigation
      'dashboard': 'Dashibodi',
      'transactions': 'Miamala',
      'debts': 'Madeni',
      'budget': 'Bajeti',
      'more': 'Zaidi',
      'settings': 'Mipangilio',
      'profile': 'Wasifu',
      
      // Authentication
      'welcome_back': 'Karibu Tena',
      'sign_in': 'Ingia',
      'email_or_phone': 'Barua pepe au Simu',
      'password': 'Nenosiri',
      'forgot_password': 'Umesahau Nenosiri?',
      'phone_number': 'Namba ya Simu',
      'sign_in_google': 'Ingia kwa Google',
      'continue_as_guest': 'Endelea kama Mgeni',
      'create_account': 'Tengeneza Akaunti',
      'dont_have_account': 'Huna akaunti?',
      'reset_instructions': 'Tuma Maelekezo ya Kuweka Upya',
      'remember_password': 'Unalikumbuka nenosiri lako?',
      
// In 'sw' map add:
'already_have_account': 'Tayari una akaunti?',
      // Dashboard
      'current_equity': 'Thamani ya Sasa',
      'deposit': 'Weka',
      'transfer': 'Hamisha',
      'expense_flow': 'Mtiririko wa Matumizi',
      'monthly_expenditure': 'Matumizi ya Mwezi',
      'recent_transactions': 'Miamala ya Hivi Karibuni',
      'categories': 'Makundi',
      'income': 'Mapato',
      'expenses': 'Matumizi',
      'savings': 'Akiba',
      'budget_overview': 'Muhtasari wa Bajeti',
      'set_budget': 'Weka Bajeti',
      'monthly_income': 'Mapato ya Mwezi',
      'monthly_expenses': 'Matumizi ya Mwezi',
      
      // Transaction
      'add_transaction': 'Ongeza Miamala',
      'transaction_history': 'Historia ya Miamala',
      'transaction_type': 'Aina ya Miamala',
      'amount': 'Kiasi',
      'date': 'Tarehe',
      'category': 'Kategoria',
      'description': 'Maelezo',
      'receipt': 'Risiti',
      'add_photo': 'Ongeza Picha',
      
      // Debts
      'debt_tracking': 'Ufuatiliaji wa Madeni',
      'money_owed_to_me': 'Ninaodaiwa',
      'money_i_owe': 'Ninazodaiwa',
      'lenders': 'Wakopeshaji',
      'borrowers': 'Wakopaji',
      'due_date': 'Tarehe ya Malipo',
      'status': 'Hali',
      
      // Budget
      'budget_planning': 'Mipango ya Bajeti',
      'category_budget': 'Bajeti ya Kategoria',
      'remaining': 'Iliyobaki',
      'spent': 'Iliyotumika',
      'over_budget': 'Ziada ya Bajeti',
      
      // Reports
      'reports_insights': 'Ripoti na Uchambuzi',
      'cash_flow': 'Mtiririko wa Fedha',
      'revenue_expense_analysis': 'Uchambuzi wa Mapato na Matumizi',
      'monthly_performance': 'Utendaji wa Mwezi',
      'income_calendar': 'Kalenda ya Mapato',
      'expense_calendar': 'Kalenda ya Matumizi',
      
      // Settings
      'personal_info': 'Taarifa Binafsi',
      'change_password': 'Badilisha Nenosiri',
      'language': 'Lugha',
      'theme': 'Mandhari',
      'dark_mode': 'Mandhari Nyeusi',
      'light_mode': 'Mandhari Nyepesi',
      'system_default': 'Chaguo la Mfumo',
      'notifications': 'Arifa',
      'data_export': 'Hamisha Data',
      'logout': 'Toka',
      'help_support': 'Usaidizi',
      'privacy_policy': 'Sera ya Faragha',
      'terms_conditions': 'Masharti na Kanuni',
      
      // Onboarding
      'onboarding_title_1': 'Usimamizi wa Fedha Mahiri',
      'onboarding_desc_1': 'Fuatilia mapato, matumizi na madeni yako sehemu moja',
      'onboarding_title_2': 'Muonekano wa Takwimu',
      'onboarding_desc_2': 'Chati na grafu nzuri za kuelewa matumizi yako',
      'onboarding_title_3': 'Dumisha Udhibiti',
      'onboarding_desc_3': 'Weka bajeti na pokea arifa unapozidi matumizi',
      
      // Animations & Messages
      'loading': 'Inapakia...',
      'no_data': 'Hakuna taarifa',
      'error_occurred': 'Hitilafu imetokea',
      'success': 'Imefanikiwa!',
      'network_error': 'Hitilafu ya mtandao',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension Translate on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)?.translate(this) ?? this;
  }
}