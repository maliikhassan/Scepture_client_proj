import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:scapture/Providers/CategoryProvider.dart';
import 'package:scapture/Providers/NegthoughtsProvider.dart';
import 'package:scapture/Providers/UserGETXProvider.dart';
import 'package:scapture/UI/NegThoughtsScreen.dart';
import 'package:scapture/UI/Scaptures.dart';
import 'package:scapture/UI/SubscriptionPlans.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCategory(Map<String, dynamic> category) {
    Get.to(() => NegThoughtScreen(
      anxId: category['id'].toString(),
      name: category['name'] as String? ?? 'Unnamed Category',
      description: category['description'] as String? ?? '',
    ));
  }

  void _navigateToScaptures(Map<String, dynamic> negThought) {
    final userData = userController.userData.value;
    final bool? isPremium = userData?['is_premium'];
    
    if (isPremium == true) {
      Get.to(() => ScapturesScreen(
        negId: negThought['id'].toString(),
        Neg_name: negThought['thought_text'] as String? ?? 'Unnamed Thought',
      ));
    } else {
      Get.to(() => SubscriptionScreen());
    }
  }

  void _handleSearchResultTap(String item, NegThoughtsProvider negThoughtsProvider, CategoryProvider categoryProvider) {
    // Find if it's a category
    final category = categoryProvider.categories.firstWhereOrNull(
      (cat) => (cat['name'] as String? ?? 'Unnamed Category') == item,
    );
    
    if (category != null) {
      _navigateToCategory(category);
      return;
    }

    // Find if it's a negative thought
    final negThought = negThoughtsProvider.negThoughts.firstWhereOrNull(
      (neg) => (neg['thought_text'] as String? ?? 'Unnamed Thought') == item,
    );
    
    if (negThought != null) {
      _navigateToScaptures(negThought);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<NegThoughtsProvider, CategoryProvider>(
        builder: (context, negThoughtsProvider, categoryProvider, child) {
          if (negThoughtsProvider.isLoading || categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (negThoughtsProvider.errorMessage != null ||
              categoryProvider.errorMessage != null) {
            return Center(
              child: Text(
                negThoughtsProvider.errorMessage ??
                    categoryProvider.errorMessage ??
                    'Unknown error',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final query = _searchController.text.toLowerCase().trim();
          final isSearching = query.isNotEmpty;

          // For search results
          if (isSearching) {
            final mergedList = [
              ...categoryProvider.categories.map(
                (cat) => cat['name'] as String? ?? 'Unnamed Category',
              ),
              ...negThoughtsProvider.negThoughts.map(
                (neg) => neg['thought_text'] as String? ?? 'Unnamed Thought',
              ),
            ];

            final filteredList = mergedList.where((item) {
              return item.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return GestureDetector(
                              onTap: () => _handleSearchResultTap(item, negThoughtsProvider, categoryProvider),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          // Default view with categories and negative thoughts
          final categories = categoryProvider.categories.take(2).toList();
          final negThoughts = negThoughtsProvider.negThoughts.take(4).toList();

          return Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFBF04),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   'Search Results...',
                      //   style: TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      //const SizedBox(height: 20),
                      const Text(
                        'Categories.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...categories.asMap().entries.map((entry) {
                        final category = entry.value;
                        final isFirst = entry.key == 0;
                        return GestureDetector(
                          onTap: () => _navigateToCategory(category),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              color: isFirst ? Colors.black : Color(0xFF4ECDC4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['name'] as String? ?? 'Unnamed Category',
                                        style: TextStyle(
                                          color: isFirst ? Colors.white : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isFirst 
                                            ? 'Excessive hard-to-control\nconcern about different things.'
                                            : 'Fear of Social interactions and\nbeing negatively evaluated.',
                                        style: TextStyle(
                                          color: isFirst ? Colors.white70 : Colors.black87,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isFirst ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isFirst ? '80+' : '60+',
                                    style: TextStyle(
                                      color: isFirst ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      const Text(
                        'Negative Thoughts.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: negThoughts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final negThought = negThoughts[index];
                            return GestureDetector(
                              onTap: () => _navigateToScaptures(negThought),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black,width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  negThought['thought_text'] as String? ?? 'Unnamed Thought',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[800],
          hintText: 'Search your queries here...',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}