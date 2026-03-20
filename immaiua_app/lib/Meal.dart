import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';

import 'main.dart';
import 'profile_screen.dart';
import 'Calenda.dart';
import 'ai_image.dart';
import 'camera_log.dart';
import 'nav_bar.dart'; // MainScaffold

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  int _index = 1; // Meal tab
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Fetch initial foods with reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().fetchFoods(reset: true);
      context.read<MealProvider>().fetchCategories();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Add search listener with debouncing
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    // Trigger load more when user scrolls near bottom (200px threshold)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MealProvider>().fetchFoods();
    }
  }

  void _onSearchChanged() {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer (500ms debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MealProvider>().fetchFoods(
        reset: true,
        search: _searchController.text,
      );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<MealProvider>().clearSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
        break;

      case 1:
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AiImageScreen()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  void _openDetail({int? foodId, String? foodName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraLogScreen(foodId: foodId, foodName: foodName),
      ),
    );
  }

  void _showCategoryDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CategorySelectionSheet(),
    );
  }

  void _showFavoritesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FavoritesSheet(
        onTapFood: (foodId, foodName) {
          Navigator.pop(context);
          _openDetail(foodId: foodId, foodName: foodName);
        },
      ),
    );
  }

  void _showMyListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _MyListSheet(),
    );
  }

  // Helper method to get category icon
  IconData _getCategoryIconData(String? categoryName) {
    if (categoryName == null) return Icons.fastfood_rounded;

    switch (categoryName.toLowerCase()) {
      case 'boiled':
        return Icons.soup_kitchen;
      case 'curry':
        return Icons.set_meal;
      case 'fried':
        return Icons.ramen_dining;
      case 'stir-fried':
        return Icons.local_dining;
      case 'grilled':
        return Icons.kebab_dining;
      case 'dessert':
        return Icons.cake;
      case 'beverage':
        return Icons.local_cafe;
      default:
        return Icons.fastfood_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,

      body: SafeArea(
        top: false,
        bottom: false,
        child: Consumer2<MealProvider, UserProvider>(
          builder: (context, mealProvider, userProvider, child) {
            final items = mealProvider.foodList;
            final tdee =
                (userProvider.profile?['tdee'] as num?)?.toInt() ?? 2000;
            final safeTdee = tdee > 0 ? tdee : 2000;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                /* ================= SEARCH BAR ================= */
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search_rounded),
                          hintText: 'Search by name..',
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                /* ================= CATEGORY ================= */
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<MealProvider>(
                      builder: (context, provider, child) {
                        // Get category name if one is selected
                        String categoryTitle = "Category";
                        if (provider.selectedCategoryId != null) {
                          final category = provider.categories.firstWhere(
                            (c) =>
                                c['category_id'] == provider.selectedCategoryId,
                            orElse: () => {'name': 'Category'},
                          );
                          categoryTitle = category['name'];
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _MealCategoryCard(
                              icon: Icons.restaurant_menu_rounded,
                              title: categoryTitle,
                              onTap: _showCategoryDialog,
                              isSelected: provider.selectedCategoryId != null,
                            ),
                            _MealCategoryCard(
                              icon: Icons.bookmark_rounded,
                              title: "Favorites",
                              onTap: _showFavoritesSheet,
                            ),
                            _MealCategoryCard(
                              icon: Icons.list_alt_rounded,
                              title: "My List",
                              onTap: _showMyListSheet,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 22)),

                /* ================= SECTION TITLE ================= */
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<MealProvider>(
                      builder: (context, provider, child) {
                        // Determine header text and icon based on selected category
                        String headerText = "All Foods";
                        IconData headerIcon = Icons.fastfood_rounded;

                        if (provider.selectedCategoryId != null &&
                            provider.categories.isNotEmpty) {
                          final category = provider.categories.firstWhere(
                            (c) =>
                                c['category_id'] == provider.selectedCategoryId,
                            orElse: () => {'name': 'All Foods'},
                          );
                          headerText = category['name'];
                          headerIcon = _getCategoryIconData(category['name']);
                        }

                        return Row(
                          children: [
                            Icon(
                              headerIcon,
                              size: 22,
                              color: const Color(0xFFFF9900),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              headerText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                /* ================= FOOD LIST (PAGINATED) ================= */
                if (mealProvider.isLoading && items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (mealProvider.error != null && items.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text("Error: ${mealProvider.error}")),
                  )
                else if (items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No foods found."),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Show loading indicator at bottom when loading more
                          if (index >= items.length) {
                            if (mealProvider.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final item = items[index];
                          final kcal = (item['calories'] as num).toInt();
                          final percent = (kcal / safeTdee * 100)
                              .toStringAsFixed(1);

                          return _MealRecentItem(
                            name: item['name'] ?? "Unknown Food",
                            subtitle:
                                "$percent% of calories per day (TDEE: $safeTdee)",
                            kcal: kcal.toString(),
                            categoryName: item['category_name'],
                            onTap: () {
                              _openDetail(
                                foodId: item['food_id'],
                                foodName: item['name'],
                              );
                            },
                          );
                        },
                        childCount:
                            items.length + (mealProvider.hasMore ? 1 : 0),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/* ===================================================================== */
/*                     CATEGORY CARD                                    */
/* ===================================================================== */

class _MealCategoryCard extends StatelessWidget {
  const _MealCategoryCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB84D) : const Color(0xFFFFE1C7),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF9900), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================================================================== */
/*                       RECENT ITEM                                    */
/* ===================================================================== */

class _MealRecentItem extends StatelessWidget {
  const _MealRecentItem({
    required this.name,
    required this.subtitle,
    required this.kcal,
    required this.onTap,
    this.categoryName,
  });

  final String name;
  final String subtitle;
  final String kcal;
  final VoidCallback onTap;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
        ),
        child: Row(
          children: [
            _getCategoryIcon(categoryName),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Text(
              "$kcal kcal",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFFF8A47),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getCategoryIcon(String? categoryName) {
    const color = Color(0xFFFF9900);
    const size = 28.0;

    if (categoryName == null) {
      return const Icon(Icons.fastfood, size: size, color: Colors.black87);
    }

    switch (categoryName.toLowerCase()) {
      case 'boiled':
        return const Icon(Icons.soup_kitchen, size: size, color: color);
      case 'curry':
        return const Icon(Icons.set_meal, size: size, color: color);
      case 'fried':
        return const Icon(Icons.ramen_dining, size: size, color: color);
      case 'stir-fried':
        return const Icon(Icons.local_dining, size: size, color: color);
      case 'grilled':
        return const Icon(Icons.kebab_dining, size: size, color: color);
      case 'dessert':
        return const Icon(Icons.cake, size: size, color: color);
      case 'beverage':
        return const Icon(Icons.local_cafe, size: size, color: color);
      default:
        return const Icon(Icons.fastfood, size: size, color: Colors.black87);
    }
  }
}
/* ===================================================================== */
/*                  CATEGORY SELECTION SHEET                             */
/* ===================================================================== */

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        final selectedId = provider.selectedCategoryId;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (selectedId != null)
                    TextButton(
                      onPressed: () {
                        provider.clearCategoryFilter();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // "All" option
              ListTile(
                leading: const Icon(
                  Icons.all_inclusive,
                  color: Color(0xFFFF9900),
                ),
                title: const Text('All Categories'),
                trailing: selectedId == null
                    ? const Icon(Icons.check, color: Color(0xFFFF9900))
                    : null,
                selected: selectedId == null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  provider.clearCategoryFilter();
                  Navigator.pop(context);
                },
              ),

              const Divider(),

              // Category options
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final id = category['category_id'];
                    final name = category['name'];
                    final description = category['description'] ?? '';

                    return ListTile(
                      leading: _getCategoryIcon(name),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: description.isNotEmpty
                          ? Text(description)
                          : null,
                      trailing: selectedId == id
                          ? const Icon(Icons.check, color: Color(0xFFFF9900))
                          : null,
                      selected: selectedId == id,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        provider.fetchFoods(reset: true, categoryId: id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Icon _getCategoryIcon(String name) {
    const color = Color(0xFFFF9900);
    switch (name.toLowerCase()) {
      case 'boiled':
        return const Icon(Icons.soup_kitchen, color: color);
      case 'curry':
        return const Icon(Icons.set_meal, color: color);
      case 'fried':
        return const Icon(Icons.ramen_dining, color: color);
      case 'stir-fried':
        return const Icon(Icons.local_dining, color: color);
      case 'grilled':
        return const Icon(Icons.kebab_dining, color: color);
      case 'dessert':
        return const Icon(Icons.cake, color: color);
      case 'beverage':
        return const Icon(Icons.local_cafe, color: color);
      default:
        return const Icon(Icons.fastfood, color: color);
    }
  }
}

/* ==========================================================
   FAVORITES SHEET
========================================================== */

class _FavoritesSheet extends StatefulWidget {
  final void Function(int foodId, String foodName) onTapFood;

  const _FavoritesSheet({required this.onTapFood});

  @override
  State<_FavoritesSheet> createState() => _FavoritesSheetState();
}

class _FavoritesSheetState extends State<_FavoritesSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _favorites = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      final response = await authService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = List<Map<String, dynamic>>.from(
            response.data['favorites'] ?? [],
          );
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.bookmark_rounded, color: Color(0xFFFF9900)),
                  SizedBox(width: 8),
                  Text(
                    'Favorites',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _favorites.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No favorites yet',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _favorites.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final food = _favorites[index];
                        final foodId = food['food_id'] as int? ?? 0;
                        final name = food['name'] as String? ?? 'Unknown';
                        final calories = food['calories']?.toString() ?? '0';
                        final categoryName = food['category_name'] as String?;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFE1C7),
                            child: Icon(
                              _getCategoryIcon(categoryName),
                              color: const Color(0xFFFF9900),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('$calories kcal'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => widget.onTapFood(foodId, name),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'boiled':
        return Icons.water_drop;
      case 'curry':
        return Icons.soup_kitchen;
      case 'fried':
        return Icons.restaurant;
      case 'stir-fried':
        return Icons.rice_bowl;
      case 'grilled':
        return Icons.outdoor_grill;
      case 'dessert':
        return Icons.cake;
      case 'beverage':
        return Icons.local_cafe;
      default:
        return Icons.fastfood;
    }
  }
}

/* ==========================================================
   MY LIST SHEET (Custom Menus)
========================================================== */

class _MyListSheet extends StatefulWidget {
  const _MyListSheet();

  @override
  State<_MyListSheet> createState() => _MyListSheetState();
}

class _MyListSheetState extends State<_MyListSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _menus = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      final response = await authService.getMenus();
      if (mounted) {
        setState(() {
          _menus = List<Map<String, dynamic>>.from(
            response.data['menus'] ?? [],
          );
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Menu name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      final response = await authService.createMenu(
        name,
        description: descController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _menus.insert(0, Map<String, dynamic>.from(response.data));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create menu: $e')));
      }
    }
  }

  Future<void> _deleteMenu(int menuId, int index) async {
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      await authService.deleteMenu(menuId);
      if (mounted) {
        setState(() => _menus.removeAt(index));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.list_alt_rounded, color: Color(0xFFFF9900)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'My List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Create button
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _menus.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.list_alt_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No menus yet',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showCreateDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first menu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9900),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _menus.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final menu = _menus[index];
                        final menuId = menu['menu_id'] as int? ?? 0;
                        final name = menu['name'] as String? ?? 'Unnamed';
                        final desc = menu['description'] as String?;
                        final count = menu['item_count'] as int? ?? 0;

                        return Dismissible(
                          key: Key('menu_$menuId'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red.shade100,
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                          onDismissed: (_) => _deleteMenu(menuId, index),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFFE1C7),
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                color: Color(0xFFFF9900),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              desc != null && desc.isNotEmpty
                                  ? desc
                                  : '$count item${count == 1 ? '' : 's'}',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
