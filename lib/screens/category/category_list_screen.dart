import 'package:flutter/material.dart';
import 'package:mkobasmart_app/models/category_model.dart';
import 'package:mkobasmart_app/widgets/customer_header.dart';
import 'package:provider/provider.dart';
import '../../provider/category_provider.dart';
import '../../localization/app_localizations.dart'; // Required for .tr(context)
import 'add_category_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    // Use microtask to avoid calling notifyListeners during build
    Future.microtask(() =>
        context.read<CategoryProvider>().fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: CustomHeader(
        title: AppLocalizations.of(context)?.translate('categories') ?? 'Categories', 
        showBackButton: true
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty 
              ? const Center(child: Text("No categories found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    
                    // Safe color parsing
                    final colorStr = category.color.replaceAll('#', '0xFF');
                    final categoryColor = Color(int.parse(colorStr));

                    return Card(
                      elevation: 0,
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.category_outlined, color: categoryColor),
                        ),
                        title: Text(
                          category.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(
                          category.categoryType.toUpperCase(),
                          style: TextStyle(color: categoryColor, fontSize: 12),
                        ),
                        // Inside ListView.builder -> ListTile
trailing: category.isDefault 
    ? const Icon(Icons.lock_outline, size: 18)
    : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () => _showEditCategory(category),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(category.id),
          ),
          
        ],
      ),
                      )
                      
                    );
                  },
                  
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
        ),
        label: const Text("New Category", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
  void _confirmDelete(int id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Futa Category?"),
      content: const Text("Je, una uhakika unataka kufuta category hii?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hapana")),
        TextButton(
          onPressed: () {
            Provider.of<CategoryProvider>(context, listen: false).removeCategory(id);
            Navigator.pop(context);
          }, 
          child: const Text("Ndio, Futa", style: TextStyle(color: Colors.red))
        ),
      ],
    ),
  );
}
// Inside _CategoryListScreenState class, add this method:

void _showEditCategory(Category category) {
  final nameController = TextEditingController(text: category.name);
  String selectedType = category.categoryType;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Category"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
          DropdownButton<String>(
            value: selectedType,
            items: const [
              DropdownMenuItem(value: 'income', child: Text("Income")),
              DropdownMenuItem(value: 'expense', child: Text("Expense")),
            ],
            onChanged: (val) => selectedType = val!,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            final updatedCat = Category(
              id: category.id,
              name: nameController.text,
              categoryType: selectedType,
              color: category.color,
              isDefault: category.isDefault,
            );
            await Provider.of<CategoryProvider>(context, listen: false).updateExistingCategory(updatedCat);
            Navigator.pop(context);
          },
          child: const Text("Update"),
        ),
      ],
    ),
  );
}
}