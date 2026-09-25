import 'dart:io';

import 'package:example/config/models/diary_entry.dart';
import 'package:example/ui/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

/// Widget de card para mostrar una entrada del diario
class EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen a la izquierda
              if (entry.hasImages) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewer(
                          imagePath: entry.imagePaths.first,
                          title: entry.title.isNotEmpty
                              ? entry.title
                              : entry.formattedDate,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(entry.imagePaths.first),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Contenido a la derecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Fecha/hora + Emoji de sentimiento
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          entry.sentiment.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Título
                    if (entry.title.isNotEmpty) ...[
                      Text(
                        entry.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Preview del contenido
                    Text(
                      entry.contentPreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Footer: Tags + Media icons
                    if (entry.tags.isNotEmpty || entry.hasMultimedia) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Tags (máximo 2 en cards con imagen)
                          if (entry.tags.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: entry.tags
                                    .take(entry.hasImages ? 2 : 3)
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                          // Media icons
                          if (entry.hasMultimedia) ...[
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (entry.hasAudio)
                                  Icon(
                                    Icons.mic_rounded,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                if (entry.hasAudio &&
                                    entry.imagePaths.length > 1)
                                  const SizedBox(width: 3),
                                if (entry.imagePaths.length > 1)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.image_rounded,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      Text(
                                        '+${entry.imagePaths.length - 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
