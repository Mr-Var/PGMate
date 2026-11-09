import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/services/file_store.dart';
import '../../core/services/providers.dart';
import 'state_views.dart';

/// Full-screen viewer for a privately stored image or PDF, with sharing.
class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = FileStore.isPdf(path);
    return Scaffold(
      backgroundColor: isPdf ? null : Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isPdf ? null : Colors.black,
        foregroundColor: isPdf ? null : Colors.white,
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () async {
              final f = await ref.read(fileStoreProvider).resolve(path);
              await ref.read(exportServiceProvider).shareFile(f, mime: isPdf ? 'application/pdf' : 'image/jpeg');
            },
          ),
        ],
      ),
      body: FutureBuilder<File>(
        future: ref.read(fileStoreProvider).resolve(path),
        builder: (context, snap) {
          if (snap.hasError) return ErrorState(error: snap.error!);
          final f = snap.data;
          if (f == null) return const Center(child: CircularProgressIndicator());
          if (isPdf) {
            return PdfPreview(
              build: (_) => f.readAsBytes(),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: false,
            );
          }
          return InteractiveViewer(
            maxScale: 5,
            child: Center(child: Image.file(f, errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, color: Colors.white))),
          );
        },
      ),
    );
  }
}
