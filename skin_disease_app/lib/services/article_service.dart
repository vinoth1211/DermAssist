import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_disease_app/models/article_model.dart';

class ArticleService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  List<ArticleModel> _articles = [];
  List<ArticleModel> _featuredArticles = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ArticleModel> get articles => _articles;
  List<ArticleModel> get featuredArticles => _featuredArticles;
  
  // Constructor
  ArticleService() {
    // Load initial articles
    getAllArticles();
    getFeaturedArticles();
  }
  
  // Fetch all articles
  Future<List<ArticleModel>> getAllArticles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('publishDate', descending: true)
          .get();
      
      _articles = snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return _articles;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching articles: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Fetch featured articles
  Future<List<ArticleModel>> getFeaturedArticles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('featured', isEqualTo: true)
          .orderBy('publishDate', descending: true)
          .limit(5)
          .get();
      
      _featuredArticles = snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return _featuredArticles;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching featured articles: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get article by ID
  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      final doc = await _firestore.collection('articles').doc(articleId).get();
      if (doc.exists) {
        // Increment view count (likes)
        await _firestore.collection('articles').doc(articleId).update({
          'likes': FieldValue.increment(1),
        });
        
        return ArticleModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      _error = 'Error getting article details: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get articles by category
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('category', isEqualTo: category)
          .orderBy('publishDate', descending: true)
          .get();
      
      final categoryArticles = snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return categoryArticles;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching articles by category: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Search articles
  Future<List<ArticleModel>> searchArticles(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // This is a simple implementation
      // In a real app, you might want to use a more sophisticated search solution
      final snapshot = await _firestore
          .collection('articles')
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();
      
      final searchResults = snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return searchResults;
    } catch (e) {
      _isLoading = false;
      _error = 'Error searching articles: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get article categories
  Future<List<String>> getArticleCategories() async {
    try {
      final snapshot = await _firestore.collection('articles').get();
      
      // Extract unique categories from all articles
      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final article = ArticleModel.fromMap(doc.data(), doc.id);
        categories.add(article.category);
      }
      
      return categories.toList()..sort();
    } catch (e) {
      _error = 'Error fetching article categories: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Save article to user's bookmarks
  Future<bool> bookmarkArticle(String userId, String articleId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('bookmarks').doc(articleId).set({
        'articleId': articleId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _error = 'Error bookmarking article: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Remove article from user's bookmarks
  Future<bool> removeBookmark(String userId, String articleId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('bookmarks').doc(articleId).delete();
      return true;
    } catch (e) {
      _error = 'Error removing bookmark: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Get user's bookmarked articles
  Future<List<ArticleModel>> getUserBookmarks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final bookmarksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .orderBy('savedAt', descending: true)
          .get();
      
      final articleIds = bookmarksSnapshot.docs.map((doc) => doc['articleId'] as String).toList();
      
      if (articleIds.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return [];
      }
      
      // Firebase doesn't support direct array queries with 'whereIn' for large arrays
      // So we need to chunk the requests if we have many bookmarks
      final List<ArticleModel> bookmarkedArticles = [];
      
      // Process in chunks of 10
      for (var i = 0; i < articleIds.length; i += 10) {
        final endIdx = i + 10 < articleIds.length ? i + 10 : articleIds.length;
        final chunk = articleIds.sublist(i, endIdx);
        
        final articlesSnapshot = await _firestore
            .collection('articles')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        bookmarkedArticles.addAll(
          articlesSnapshot.docs.map((doc) => ArticleModel.fromMap(doc.data(), doc.id)).toList()
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return bookmarkedArticles;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching bookmarked articles: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Check if an article is bookmarked by the user
  Future<bool> isArticleBookmarked(String userId, String articleId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(articleId)
          .get();
      
      return doc.exists;
    } catch (e) {
      _error = 'Error checking bookmark status: $e';
      notifyListeners();
      return false;
    }
  }
}
