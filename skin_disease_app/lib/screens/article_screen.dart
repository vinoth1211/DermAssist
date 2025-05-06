import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/article_service.dart';
import 'package:skin_disease_app/models/article_model.dart';
import 'package:skin_disease_app/widgets/article_card.dart';
import 'package:skin_disease_app/screens/article_detail_screen.dart';
import 'package:skin_disease_app/widgets/custom_text_field.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  
  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCategories();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadArticles() async {
    final articleService = Provider.of<ArticleService>(context, listen: false);
    await articleService.getAllArticles();
  }
  
  Future<void> _loadCategories() async {
    final articleService = Provider.of<ArticleService>(context, listen: false);
    final categories = await articleService.getArticleCategories();
    
    if (!mounted) return;
    
    setState(() {
      _categories = categories;
    });
  }
  
  Future<void> _refreshArticles() async {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedCategory = null;
    });
    
    await _loadArticles();
  }
  
  List<ArticleModel> _getFilteredArticles(List<ArticleModel> articles) {
    var filtered = articles;
    
    // Filter by category if selected
    if (_selectedCategory != null) {
      filtered = filtered.where((article) => 
        article.category == _selectedCategory
      ).toList();
    }
    
    // Filter by search query if not empty
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((article) =>
        article.title.toLowerCase().contains(query) ||
        article.content.toLowerCase().contains(query) ||
        article.author.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final articleService = Provider.of<ArticleService>(context);
    final filteredArticles = _getFilteredArticles(articleService.articles);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Health Articles'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: _searchController,
                labelText: 'Search Articles',
                hintText: 'Search by title, content or author',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // Categories
            if (_categories.isNotEmpty)
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length + 1, // +1 for "All" category
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCategoryChip('All', _selectedCategory == null);
                    } else {
                      final category = _categories[index - 1];
                      return _buildCategoryChip(
                        category, 
                        _selectedCategory == category,
                      );
                    }
                  },
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Articles list
            Expanded(
              child: articleService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredArticles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No articles found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty || _selectedCategory != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextButton(
                                    onPressed: _refreshArticles,
                                    child: const Text('Clear filters'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = filteredArticles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ArticleCard(
                                article: article,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleDetailScreen(
                                        articleId: article.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? (label == 'All' ? null : label) : null;
          });
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }
}
