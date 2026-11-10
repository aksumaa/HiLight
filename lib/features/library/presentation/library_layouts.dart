import 'package:flutter/material.dart';

import '../../../data/models/library_item.dart';
import '../../profile/domain/app_settings.dart';
import '../domain/library_layout.dart';
import 'library_item_tile.dart';

class ListLibraryLayout extends LibraryLayout {
  const ListLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return ListView(
      key: const Key('library-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final item in items)
          LibraryItemTile(item: item, onOpen: onOpen),
      ],
    );
  }
}

class CardsLibraryLayout extends LibraryLayout {
  const CardsLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return ListView(
      key: const Key('library-cards'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final item in items)
          LibraryItemTile(item: item, onOpen: onOpen, kind: LibraryTileKind.card),
      ],
    );
  }
}

class CompactLibraryLayout extends LibraryLayout {
  const CompactLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return ListView(
      key: const Key('library-compact'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final item in items)
          LibraryItemTile(item: item, onOpen: onOpen, kind: LibraryTileKind.compact),
      ],
    );
  }
}

LibraryLayout layoutFor(LibraryLayoutKind kind) {
  return switch (kind) {
    LibraryLayoutKind.list => const ListLibraryLayout(),
    LibraryLayoutKind.cards => const CardsLibraryLayout(),
    LibraryLayoutKind.compact => const CompactLibraryLayout(),
  };
}
