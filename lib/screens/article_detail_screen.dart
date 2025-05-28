import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/services/article_service.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skin_disease_app/models/article_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  ArticleModel? _article;
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isCheckingBookmark = true;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articleService = Provider.of<ArticleService>(context, listen: false);
      final article = await articleService.getArticleById(widget.articleId);

      if (article != null) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
        
        // Check if the article is bookmarked
        _checkIfBookmarked();
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article not found'),
            backgroundColor: Colors.red,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading article: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfBookmarked() async {
    setState(() {
      _isCheckingBookmark = true;
    });

    try {
      final articleService = Provider.of<ArticleService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (authService.user == null) {
        setState(() {
          _isBookmarked = false;
          _isCheckingBookmark = false;
        });
        return;
      }
      
      final isBookmarked = await articleService.isArticleBookmarked(
        authService.user!.uid,
        widget.articleId,
      );
      
      setState(() {
        _isBookmarked = isBookmarked;
        _isCheckingBookmark = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingBookmark = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_article == null) return;
    
    final articleService = Provider.of<ArticleService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to bookmark articles'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isCheckingBookmark = true;
    });
    
    try {
      bool success;
      if (_isBookmarked) {
        success = await articleService.removeBookmark(
          authService.user!.uid,
          widget.articleId,
        );
      } else {
        success = await articleService.bookmarkArticle(
          authService.user!.uid,
          widget.articleId,
        );
      }
      
      if (success) {
        setState(() {
          _isBookmarked = !_isBookmarked;
          _isCheckingBookmark = false;
        });
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Article bookmarked' : 'Bookmark removed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isCheckingBookmark = false;
        });
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update bookmark'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingBookmark = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareArticle() async {
    if (_article == null) return;
    
    final title = _article!.title;
    final author = _article!.author;
    final url = 'https://dermassist.app/articles/${_article!.id}';
    
    await Share.share(
      'Check out this article on DermAssist: "$title" by $author\n$url',
      subject: 'DermAssist Article: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          if (!_isLoading && _article != null)
            IconButton(
              onPressed: _shareArticle,
              icon: const Icon(Icons.share),
              tooltip: 'Share Article',
            ),
          if (!_isLoading && _article != null)
            IconButton(
              onPressed: _isCheckingBookmark ? null : _toggleBookmark,
              icon: _isCheckingBookmark
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
              tooltip: _isBookmarked ? 'Remove from Bookmarks' : 'Add to Bookmarks',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _article == null
              ? const Center(
                  child: Text('Article not found'),
                )
              : CustomScrollView(
                  slivers: [
                    // Hero image
                    SliverToBoxAdapter(
                      child: _article!.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _article!.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.article,
                                  size: 64,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                    ),
                    
                    // Article content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              _article!.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Category
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _article!.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Author and date
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.person),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _article!.author,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Skin Health Expert', // Placeholder as we don't have authorRole in our model
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('MMM d, yyyy').format(_article!.publishDate),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${_article!.readTime} min read',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Article content
                            Text(
                              _article!.content,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),
                            
                            // Tags
                            if (_article!.tags.isNotEmpty) ...[
                              Text(
                                'Tags',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _article!.tags.map((tag) => 
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  )
                                ).toList(),
                              ),
                              const SizedBox(height: 32),
                            ],
                            
                            // Related articles (placeholder)
                            Text(
                              'Related Articles',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Coming soon...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
