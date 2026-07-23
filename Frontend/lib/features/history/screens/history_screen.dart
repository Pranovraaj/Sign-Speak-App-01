// lib/features/history/screens/history_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredHistory = ref.watch(filteredHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSlate : Colors.white,
        elevation: 0,
        title: Text(
          'History Archive',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.darkSlate,
          ),
        ),
        actions: [
          // Purge All history action
          if (filteredHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              tooltip: 'Purge Archive',
              onPressed: () => _confirmPurge(context, ref),
            )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(historySearchQueryProvider.notifier).state = val,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.darkSlate),
              decoration: InputDecoration(
                hintText: 'Search translations by keywords...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    ref.read(historySearchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),
          ),

          // Main history logs feed
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'History archive is empty',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = filteredHistory[index];
                      return _buildHistoryCard(context, ref, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, HistoryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Format timestamp
    final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    final dateString = DateFormat('yMMMd').add_jm().format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppTheme.darkSlateSecondary : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Base64 gesture capture preview
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90,
                height: 70,
                color: isDark ? AppTheme.darkSlate : Colors.grey.shade100,
                child: item.image != null && item.image!.isNotEmpty
                    ? Image.memory(
                        base64Decode(item.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image_rounded, size: 24),
                      )
                    : const Icon(Icons.videocam_rounded, color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Text & timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.text,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppTheme.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Delete action button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
              onPressed: () {
                ref.read(historyProvider.notifier).deleteRecord(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPurge(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSlateSecondary : Colors.white,
          title: Text(
            'Purge History Archive',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to permanently delete all translation logs from this console?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () {
                ref.read(historyProvider.notifier).clearAll();
                Navigator.pop(context);
              },
              child: const Text('PURGE ALL'),
            ),
          ],
        );
      },
    );
  }
}
