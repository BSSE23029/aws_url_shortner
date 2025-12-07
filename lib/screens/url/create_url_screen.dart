import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class CreateUrlScreen extends StatefulWidget {
  const CreateUrlScreen({super.key});

  @override
  State<CreateUrlScreen> createState() => _CreateUrlScreenState();
}

class _CreateUrlScreenState extends State<CreateUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _customCodeController = TextEditingController();
  bool _useCustomCode = false;
  bool _isCreating = false;
  String? _createdShortUrl;

  @override
  void dispose() {
    _urlController.dispose();
    _customCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateUrl() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCreating = true);

      // Generate optimistic short code
      final shortCode = _useCustomCode && _customCodeController.text.isNotEmpty
          ? _customCodeController.text
          : _generateRandomCode();

      final shortUrl = 'https://short.ly/$shortCode';

      // Show optimistic success immediately
      setState(() {
        _createdShortUrl = shortUrl;
        _isCreating = false;
      });

      // Create optimistic URL model
      final newUrl = UrlModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        originalUrl: _urlController.text,
        shortCode: shortCode,
        shortUrl: shortUrl,
        createdAt: DateTime.now(),
        userId: 'user_123',
      );

      // In real app: Add to state manager optimistically
      // await appState.addUrlOptimistic(newUrl);

      // Simulate Lambda function call (runs in background)
      _createUrlInBackground(newUrl);
    }
  }

  Future<void> _createUrlInBackground(UrlModel url) async {
    // Simulate API call to API Gateway -> Lambda -> DynamoDB
    await Future.delayed(const Duration(milliseconds: 800));

    // In real app: Update with actual response from backend
    // If it fails, show error and rollback optimistic update
  }

  String _generateRandomCode() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      7,
      (index) =>
          chars[(DateTime.now().microsecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  void _copyToClipboard() {
    if (_createdShortUrl != null) {
      // Copy to clipboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Copied to clipboard!'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _urlController.clear();
      _customCodeController.clear();
      _createdShortUrl = null;
      _useCustomCode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Short URL')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _createdShortUrl == null
              ? _buildCreationForm()
              : _buildSuccessView(),
        ),
      ),
    );
  }

  Widget _buildCreationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Shorten Your Link',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a long URL to create a shortened version',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // URL Input
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Long URL',
              hintText: 'https://example.com/very/long/url',
              prefixIcon: Icon(Icons.link),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a URL';
              }
              if (!value.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'URL must start with http:// or https://';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Custom Code Option
          Row(
            children: [
              Checkbox(
                value: _useCustomCode,
                onChanged: (value) {
                  setState(() {
                    _useCustomCode = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _useCustomCode = !_useCustomCode;
                    });
                  },
                  child: Text(
                    'Customize short code',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),

          // Custom Code Input
          if (_useCustomCode) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _customCodeController,
              decoration: InputDecoration(
                labelText: 'Custom Code',
                hintText: 'my-custom-link',
                prefixIcon: const Icon(Icons.edit),
                helperText: 'Only letters, numbers, and hyphens allowed',
              ),
              validator: (value) {
                if (_useCustomCode && (value == null || value.isEmpty)) {
                  return 'Please enter a custom code';
                }
                if (_useCustomCode &&
                    !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value!)) {
                  return 'Only letters, numbers, and hyphens allowed';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 32),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.skyBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.accentTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your link will be created instantly with zero latency',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Create Button
          ElevatedButton(
            onPressed: _isCreating ? null : _handleCreateUrl,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create Short URL'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        // Success Animation
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, size: 80, color: AppTheme.success),
        ),
        const SizedBox(height: 24),

        Text(
          'URL Created!',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(color: AppTheme.success),
        ),
        const SizedBox(height: 8),
        Text(
          'Your short URL is ready to use',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // Short URL Display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentTeal, width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: AppTheme.accentTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _createdShortUrl!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Link'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share functionality
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Original URL
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original URL',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                _urlController.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Actions
        ElevatedButton(
          onPressed: _resetForm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Create Another'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }
}
