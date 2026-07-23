// lib/features/tutorial/screens/tutorial_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/gesture_model.dart';
import '../providers/tutorial_provider.dart';
import '../widgets/gesture_card.dart';
import 'quiz_challenge_screen.dart';
import '../../practice/screens/practice_mode_screen.dart';

// Riverpod provider to hold the gesture currently selected for individual practice
final selectedPracticeGestureProvider = StateProvider<GestureModel?>((ref) => null);

class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);
    final filteredGestures = ref.watch(filteredGesturesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSlate : Colors.white,
        elevation: 0,
        title: Text(
          'Learning Console',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
        actions: [
          // Launch Quiz challenge trigger
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizChallengeScreen()),
                );
              },
              icon: const Icon(Icons.star_half_rounded, color: Colors.amber, size: 20),
              label: Text(
                'Quiz Challenge',
                style: GoogleFonts.outfit(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar Panel
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
              decoration: InputDecoration(
                hintText: 'Search for gestures or sequences...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),
          ),

          // Horizontal Categories Filter Row
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: AppConstants.categories.length,
              itemBuilder: (context, index) {
                final cat = AppConstants.categories[index];
                final isSelected = activeCategory.toLowerCase() == cat.toLowerCase();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: isDark ? AppTheme.neonPurple.withOpacity(0.2) : AppTheme.lightAccent.withOpacity(0.2),
                    checkmarkColor: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                    labelStyle: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppTheme.neonCyan : AppTheme.lightAccent)
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    onSelected: (selected) {
                      ref.read(activeCategoryProvider.notifier).state = cat;
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),

          // Main Tutorials Grid View
          Expanded(
            child: filteredGestures.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.find_in_page_outlined,
                          size: 64,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No gestures match your query',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.80,
                    ),
                    itemCount: filteredGestures.length,
                    itemBuilder: (context, index) {
                      final item = filteredGestures[index];
                      return GestureCard(
                        gesture: item,
                        onPracticeTap: () {
                          if (item.isLiveRecognized) {
                            // Set selected practice gesture in Riverpod and open Practice Screen
                            ref.read(selectedPracticeGestureProvider.notifier).state = item;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PracticeModeScreen()),
                            );
                          } else {
                            // Fallback dialog for non-live recognized sequences
                            _showGestureDetailDialog(context, item);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Detailed Modal Dialog for studying detailed descriptions
  void _showGestureDetailDialog(BuildContext context, GestureModel gesture) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text(
            gesture.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  gesture.image,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey, height: 160),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Category: ${gesture.category}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.neonCyan : AppTheme.lightAccent,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gesture.description,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            )
          ],
        );
      },
    );
  }
}
