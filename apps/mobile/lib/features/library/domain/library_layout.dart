import 'package:flutter/widgets.dart';

import '../../../data/models/library_item.dart';

/// How a list of items is drawn. The library screen picks one saved strategy.
abstract class LibraryLayout {
  const LibraryLayout();

  Widget build(
    BuildContext context,
    List<LibraryItem> items,
    ValueChanged<LibraryItem> onOpen,
  );
}
