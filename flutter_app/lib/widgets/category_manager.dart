import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

/// Widget to manage chat categories
class ChatCategoryManager extends StatefulWidget {
  final String userId;
  final VoidCallback onCategoryCreated;

  const ChatCategoryManager({
    required this.userId,
    required this.onCategoryCreated,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatCategoryManager> createState() => _ChatCategoryManagerState();
}

class _ChatCategoryManagerState extends State<ChatCategoryManager> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = '#FF6B9A';

  final List<String> _colorOptions = [
    '#FF6B9A', // Pink
    '#FF8C94', // Light pink
    '#FF6B6B', // Red
    '#FFA500', // Orange
    '#FFD93D', // Yellow
    '#6BCB77', // Green
    '#4D96FF', // Blue
    '#9D4EDD', // Purple
    '#3A86FF', // Sky blue
    '#FF006E', // Hot pink
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manage Chat Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Create new category section
                  const Text(
                    'Create New Category',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name input
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.amber.shade700),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description input
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.amber.shade700),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Color picker
                  const Text(
                    'Select Color:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _createCategory(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                      ),
                      child: const Text('Create Category'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Existing categories
                  const Text(
                    'Existing Categories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (provider.chatCategories.isEmpty)
                    const Center(
                      child: Text(
                        'No categories yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: provider.chatCategories.length,
                        itemBuilder: (context, index) {
                          final category = provider.chatCategories[index];
                          return _buildCategoryTile(context, provider, category);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    CategoryProvider provider,
    ChatCategory category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(category.color.replaceFirst('#', '0xff'))).withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(int.parse(category.color.replaceFirst('#', '0xff'))).withAlpha(102),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Color(int.parse(category.color.replaceFirst('#', '0xff'))),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (category.description != null)
                  Text(
                    category.description!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${category.messageCount}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          if (!category.isDefault)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () => _editCategory(context, provider, category),
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _deleteCategory(context, provider, category.id),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _createCategory(BuildContext context, CategoryProvider provider) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final success = await provider.createChatCategory(
      userId: widget.userId,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      color: _selectedColor,
    );

    if (success && mounted) {
      _nameController.clear();
      _descriptionController.clear();
      _selectedColor = '#FF6B9A';
      widget.onCategoryCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created!')),
      );
    }
  }

  void _editCategory(
    BuildContext context,
    CategoryProvider provider,
    ChatCategory category,
  ) {
    // Similar to create, but for updating
    // Implementation for editing
  }

  void _deleteCategory(
    BuildContext context,
    CategoryProvider provider,
    String categoryId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteChatCategory(categoryId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted')),
        );
      }
    }
  }
}

/// Widget to manage match categories
class MatchCategoryManager extends StatefulWidget {
  final String userId;
  final VoidCallback onCategoryCreated;

  const MatchCategoryManager({
    required this.userId,
    required this.onCategoryCreated,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchCategoryManager> createState() => _MatchCategoryManagerState();
}

class _MatchCategoryManagerState extends State<MatchCategoryManager> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = '#FF6B9A';
  String _selectedIcon = '??';

  final List<String> _colorOptions = [
    '#FF6B9A', '#FF8C94', '#FF6B6B', '#FFA500',
    '#FFD93D', '#6BCB77', '#4D96FF', '#9D4EDD',
    '#3A86FF', '#FF006E',
  ];

  final List<String> _iconOptions = [
    '??', '??', '??', '??', '?', '??', '??', '?',
    '??', '??', '??', '??', '??', '??', '??', '??',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manage Match Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name input
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.amber.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Icon picker
                  const Text(
                    'Select Icon:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconOptions.map((icon) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _selectedIcon == icon
                                ? Colors.amber.shade700
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedIcon == icon
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Color picker
                  const Text(
                    'Select Color:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _createCategory(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                      ),
                      child: const Text('Create Category'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Existing categories
                  const Text(
                    'Existing Categories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (provider.matchCategories.isEmpty)
                    const Center(
                      child: Text(
                        'No categories yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: provider.matchCategories.length,
                        itemBuilder: (context, index) {
                          final category = provider.matchCategories[index];
                          return _buildCategoryTile(context, provider, category);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    CategoryProvider provider,
    MatchCategory category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(category.color.replaceFirst('#', '0xff'))).withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(int.parse(category.color.replaceFirst('#', '0xff'))).withAlpha(102),
        ),
      ),
      child: Row(
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${category.matchCount}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          if (!category.isDefault)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _deleteCategory(context, provider, category.id),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _createCategory(BuildContext context, CategoryProvider provider) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final success = await provider.createMatchCategory(
      userId: widget.userId,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      color: _selectedColor,
      icon: _selectedIcon,
    );

    if (success && mounted) {
      _nameController.clear();
      _descriptionController.clear();
      _selectedColor = '#FF6B9A';
      _selectedIcon = '??';
      widget.onCategoryCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created!')),
      );
    }
  }

  void _deleteCategory(
    BuildContext context,
    CategoryProvider provider,
    String categoryId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteMatchCategory(categoryId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted')),
        );
      }
    }
  }
}
