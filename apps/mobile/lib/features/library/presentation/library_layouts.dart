import 'package:flutter/material.dart';

import '../../../data/models/library_item.dart';
import '../../profile/domain/app_settings.dart';
import '../domain/library_layout.dart';
import 'library_item_tile.dart';

class ListLibraryLayout extends LibraryLayout {
  const ListLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return _lazyFeed(
      key: const Key('library-list'),
      items: items,
      onOpen: onOpen,
      kind: LibraryTileKind.list,
    );
  }
}

class CardsLibraryLayout extends LibraryLayout {
  const CardsLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return _lazyFeed(
      key: const Key('library-cards'),
      items: items,
      onOpen: onOpen,
      kind: LibraryTileKind.card,
    );
  }
}

class CompactLibraryLayout extends LibraryLayout {
  const CompactLibraryLayout();

  @override
  Widget build(BuildContext context, List<LibraryItem> items, ValueChanged<LibraryItem> onOpen) {
    return _lazyFeed(
      key: const Key('library-compact'),
      items: items,
      onOpen: onOpen,
      kind: LibraryTileKind.compact,
    );
  }
}

Widget _lazyFeed({
  required Key key,
  required List<LibraryItem> items,
  required ValueChanged<LibraryItem> onOpen,
  required LibraryTileKind kind,
}) {
  return ListView.builder(
    key: key,
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
    itemCount: items.length,
    itemBuilder: (context, index) {
      return LibraryItemTile(item: items[index], onOpen: onOpen, kind: kind);
    },
  );
}

LibraryLayout layoutFor(LibraryLayoutKind kind) {
  return switch (kind) {
    LibraryLayoutKind.list => const ListLibraryLayout(),
    LibraryLayoutKind.cards => const CardsLibraryLayout(),
    LibraryLayoutKind.compact => const CompactLibraryLayout(),
  };
}
