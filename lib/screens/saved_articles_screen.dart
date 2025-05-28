import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/article_service.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/widgets/article_card.dart';
import 'package:skin_disease_app/models/article_model.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  bool _isLoading = true;
  List<ArticleModel> _savedArticles = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSavedArticles());
  }

  Future<void> _loadSavedArticles() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final articleService = Provider.of<ArticleService>(
        context,
        listen: false,
      );

      if (authService.user != null) {
        final articles = await articleService.getSavedArticles(
          authService.user!.uid,
        );
        if (!mounted) return;
        setState(() {
          _savedArticles = articles;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _savedArticles = [];
          _isLoading = false;
          _error = 'You need to be logged in to view saved articles';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error loading saved articles: $e';
      });
    }
  }

  Future<void> _removeFromSaved(String articleId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final articleService = Provider.of<ArticleService>(
        context,
        listen: false,
      );

      if (authService.user != null) {
        final success = await articleService.removeBookmark(
          authService.user!.uid,
          articleId,
        );

        if (success) {
          setState(() {
            _savedArticles.removeWhere((article) => article.id == articleId);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Article removed from saved'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to remove article from saved'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : _savedArticles.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No saved articles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Articles you save will appear here',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/articles');
                      },
                      child: const Text('Browse Articles'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadSavedArticles,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: ListView.builder(
                    itemCount: _savedArticles.length,
                    itemBuilder: (context, index) {
                      final article = _savedArticles[index];
                      return Dismissible(
                        key: Key(article.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeFromSaved(article.id);
                        },
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Remove Article'),
                                  content: const Text(
                                    'Are you sure you want to remove this article from saved?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ArticleCard(
                            article: article,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/article_detail',
                                arguments: {'articleId': article.id},
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
