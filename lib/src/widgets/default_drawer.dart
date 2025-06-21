part of '../flutter_quran_screen.dart';

class _DefaultDrawer extends StatelessWidget {
  const _DefaultDrawer();

  @override
  Widget build(BuildContext context) {
    final jozzs = FlutterQuran().getAllJozzs();
    final hizbs = FlutterQuran().getAllHizbs();
    final surahs = FlutterQuran().getAllSurahs();
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          children: [
            // Search Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                trailing: const Icon(Icons.search_outlined, size: 28),
                title: const Text(
                  'بحث',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const _FlutterQuranSearchScreen()));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                hoverColor:
                    theme.colorScheme.primary.withAlpha((0.08 * 255).round()),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withAlpha((0.2 * 255).round())),
            const SizedBox(height: 16),
            // Index Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                      child: Text(
                        'الفهرس',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text('الجزء',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        jozzs.length,
                        (jozzIndex) => Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: theme.colorScheme.surface,
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            title: Text(
                              jozzs[jozzIndex],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            children: List.generate(2, (index) {
                              final hizbIndex = (index == 0 && jozzIndex == 0)
                                  ? 0
                                  : ((jozzIndex * 2 + index));
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  FlutterQuran().navigateToHizb(hizbIndex + 1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16),
                                  child: Text(
                                    hizbs[hizbIndex],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: const Text('السورة',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        surahs.length,
                        (index) => InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              FlutterQuran().navigateToSurah(index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16),
                            child: Text(
                              surahs[index],
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withAlpha((0.2 * 255).round())),
            const SizedBox(height: 16),
            // Bookmarks Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                      child: Text(
                        'العلامات',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    ...FlutterQuran()
                        .getUsedBookmarks()
                        .map((bookmark) => ListTile(
                              leading: Icon(
                                Icons.bookmark,
                                color: Color(bookmark.colorCode),
                                size: 28,
                              ),
                              title: Text(
                                bookmark.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              onTap: () =>
                                  FlutterQuran().navigateToBookmark(bookmark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hoverColor: theme.colorScheme.primary
                                  .withAlpha((0.08 * 255).round()),
                            )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
