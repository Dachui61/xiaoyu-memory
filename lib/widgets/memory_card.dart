import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/memory.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MemoryCard({super.key, required this.memory, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MM月dd日 HH:mm').format(memory.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: type icon + time
            Row(
              children: [
                Icon(_typeIcon(memory.type), size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(dateStr, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Spacer(),
                if (memory.tags.isNotEmpty)
                  ...memory.tags.take(2).map((t) => Container(
                    margin: EdgeInsets.only(left: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.aiPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 11, color: AppTheme.aiPurple)),
                  )),
              ],
            ),
            SizedBox(height: 10),
            // Title
            if (memory.title.isNotEmpty)
              Text(memory.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            // Content preview
            Text(memory.content, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
            // Summary
            if (memory.summary.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: AppTheme.aiPurple),
                    SizedBox(width: 6),
                    Expanded(child: Text(memory.summary, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'voice': return Icons.mic;
      case 'image': return Icons.photo;
      default: return Icons.note;
    }
  }
}
