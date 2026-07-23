// lib/features/tutorial/widgets/gesture_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/gesture_model.dart';
import '../providers/tutorial_provider.dart';

class GestureCard extends ConsumerWidget {
  final GestureModel gesture;
  final VoidCallback? onPracticeTap;

  const GestureCard({
    super.key,
    required this.gesture,
    this.onPracticeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final progress = ref.watch(progressProvider);
    final isBookmarked = bookmarks.contains(gesture.id);
    final isCompleted = progress.contains(gesture.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visual Image Container
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Load local gesture asset image with safety fallback
                Image.asset(
                  gesture.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        size: 32,
                      ),
                    );
                  },
                ),

                // Top Bar overlay inside card
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status completed indicator
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Learned',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      else if (gesture.isLiveRecognized)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.neonCyan : AppTheme.lightAccent).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded, size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Live ML',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      else
                        const SizedBox(),

                      // Bookmark button
                      GestureDetector(
                        onTap: () {
                          ref.read(bookmarksProvider.notifier).toggle(gesture.id);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black26,
                          radius: 14,
                          child: Icon(
                            isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isBookmarked ? Colors.amber : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Container
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  gesture.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppTheme.darkSlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  gesture.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Action Practice trigger
                ElevatedButton(
                  onPressed: onPracticeTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                    foregroundColor: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: (isDark ? AppTheme.neonCyan : AppTheme.lightAccent).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(gesture.isLiveRecognized ? Icons.videocam_rounded : Icons.menu_book_rounded, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        gesture.isLiveRecognized ? 'Practice Camera' : 'Study Details',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
