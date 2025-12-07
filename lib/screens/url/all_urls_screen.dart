import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_loader.dart';

class AllUrlsScreen extends StatefulWidget {
  const AllUrlsScreen({super.key});

  @override
  State<AllUrlsScreen> createState() => _AllUrlsScreenState();
}

class _AllUrlsScreenState extends State<AllUrlsScreen> {
  bool _isLoading = true;
  List<UrlModel> _urls = [];
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, clicks, alphabetical

  @override
  void initState() {
    super.initState();
    _loadUrls();
  }

  Future<void> _loadUrls() async {
    setState(() => _isLoading = true);

    // Simulate DAX read
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _urls = _generateMockUrls();
      _isLoading = false;
    });
  }

  List<UrlModel> _generateMockUrls() {
    return List.generate(
      15,
      (index) => UrlModel(
        id: 'url_$index',
        originalUrl: 'https://example.com/path/to/resource/$index',
        shortCode: 'abc${index}xyz',
        shortUrl: 'https://short.ly/abc${index}xyz',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        clickCount: (150 - index * 10),
        userId: 'user_123',
      ),
    );
  }

  List<UrlModel> get _filteredUrls {
    var filtered = _urls.where((url) {
      if (_searchQuery.isEmpty) return true;
      return url.originalUrl.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          url.shortCode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'clicks':
        filtered.sort((a, b) => b.clickCount.compareTo(a.clickCount));
        break;
      case 'alphabetical':
        filtered.sort((a, b) => a.shortCode.compareTo(b.shortCode));
        break;
      case 'recent':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All URLs'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: _sortBy == 'recent' ? AppTheme.accentTeal : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Recent',
                      style: TextStyle(
                        color: _sortBy == 'recent' ? AppTheme.accentTeal : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clicks',
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 20,
                      color: _sortBy == 'clicks' ? AppTheme.accentTeal : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Clicks',
                      style: TextStyle(
                        color: _sortBy == 'clicks' ? AppTheme.accentTeal : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'alphabetical',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 20,
                      color: _sortBy == 'alphabetical'
                          ? AppTheme.accentTeal
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alphabetical',
                      style: TextStyle(
                        color: _sortBy == 'alphabetical'
                            ? AppTheme.accentTeal
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search URLs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Stats Summary
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat('Total', _urls.length.toString()),
                    _buildQuickStat('Showing', _filteredUrls.length.toString()),
                    _buildQuickStat(
                      'Total Clicks',
                      _urls
                          .fold<int>(0, (sum, url) => sum + url.clickCount)
                          .toString(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // URL List
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) => const UrlCardSkeleton(),
                  )
                : _filteredUrls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.link_off,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No URLs found'
                              : 'No URLs yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Create your first short URL',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUrls,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredUrls.length,
                      itemBuilder: (context, index) {
                        final url = _filteredUrls[index];
                        return _buildUrlCard(url);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-url');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create URL'),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.accentTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildUrlCard(UrlModel url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/url-details', arguments: url);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      url.shortUrl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                url.originalUrl,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mouse, size: 14, color: AppTheme.accentTeal),
                        const SizedBox(width: 4),
                        Text(
                          '${url.clickCount}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.accentTeal,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(url.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
