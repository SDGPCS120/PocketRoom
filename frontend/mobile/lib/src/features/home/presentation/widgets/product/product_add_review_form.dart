import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../providers/reviews_provider.dart';

class ProductAddReviewForm extends ConsumerStatefulWidget {
  final String productId;

  const ProductAddReviewForm({super.key, required this.productId});

  @override
  ConsumerState<ProductAddReviewForm> createState() => _ProductAddReviewFormState();
}

class _ProductAddReviewFormState extends ConsumerState<ProductAddReviewForm> {
  final _reviewFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  int _newRating = 5;
  bool _isExpanded = false;
  bool _isUploading = false;
  final List<XFile> _selectedPhotos = [];

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(pickedFiles);
      });
    }
  }

  Future<void> _submitReview() async {
    if (!(_reviewFormKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isUploading = true);

    try {
      final List<String> uploadedUrls = [];
      
      for (final file in _selectedPhotos) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final storageRef = FirebaseStorage.instance.ref().child('reviews/${widget.productId}/$fileName');
        
        final bytes = await file.readAsBytes();
        final uploadTask = storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      ref.read(reviewsProvider.notifier).addReview(
            widget.productId,
            Review(
              reviewerName: _nameController.text.trim(),
              text: _reviewController.text.trim(),
              rating: _newRating,
              date: DateTime.now(),
              photoUrls: uploadedUrls,
            ),
          );
      
      _nameController.clear();
      _reviewController.clear();
      setState(() {
        _newRating = 5;
        _isExpanded = false;
        _selectedPhotos.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post review: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isExpanded) {
      return OutlinedButton.icon(
        onPressed: () => setState(() => _isExpanded = true),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Write a Review'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Form(
        key: _reviewFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Write a Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _isExpanded = false;
                    _selectedPhotos.clear();
                  }),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            Text(
              'Share your thoughts with other customers.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Your rating',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                ...List.generate(5, (i) {
                  final score = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _newRating = score),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        score <= _newRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.orange.shade400,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Your Name', colorScheme),
              validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              decoration: _inputDecoration('What did you like or dislike?', colorScheme),
              validator: (v) => v!.isEmpty ? 'Please enter your review' : null,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_selectedPhotos.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: kIsWeb 
                                  ? NetworkImage(_selectedPhotos[index].path) as ImageProvider
                                  : FileImage(File(_selectedPhotos[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPhotos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add Photos'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 44,
                width: 120,
                child: FilledButton(
                  onPressed: _isUploading ? null : _submitReview,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 13),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
    );
  }
}
