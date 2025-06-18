import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:flutter_quran/src/utils/string_extensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'controllers/bookmarks_controller.dart';
import 'controllers/quran_controller.dart';
import 'models/quran_constants.dart';
import 'models/quran_page.dart';

part 'utils/images.dart';
part 'utils/toast_utils.dart';
part 'widgets/ayah_long_click_dialog.dart';
part 'widgets/bsmallah_widget.dart';
part 'widgets/default_drawer.dart';
part 'widgets/quran_line.dart';
part 'widgets/quran_page_bottom_info.dart';
part 'widgets/surah_header_widget.dart';

class FlutterQuranScreen extends GetView<QuranController> {
  const FlutterQuranScreen({
    this.showBottomWidget = true,
    this.useDefaultAppBar = true,
    this.bottomWidget,
    this.appBar,
    this.onPageChanged,
    super.key,
  });

  /// Whether to show the default bottom widget
  final bool showBottomWidget;

  /// Whether to use the default app bar
  final bool useDefaultAppBar;

  /// Custom bottom widget (replaces default if provided)
  final Widget? bottomWidget;

  /// Custom app bar (replaces default if provided)
  final PreferredSizeWidget? appBar;

  /// Callback when a Quran page changes
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    // Memoize device size and orientation
    final deviceSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);
    // Use Get.find for bookmarks controller (singleton)
    final BookmarksController bookmarksController =
        Get.find<BookmarksController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        brightness: theme.brightness, // Respect system theme
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: appBar ??
              (useDefaultAppBar
                  ? AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      iconTheme: IconThemeData(
                          color: theme.iconTheme.color ?? Colors.black),
                    )
                  : null),
          drawer: appBar == null && useDefaultAppBar
              ? const _DefaultDrawer()
              : null,
          body: Obx(() {
            final pages = controller.staticPages;
            if (pages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SafeArea(
              child: PageView.builder(
                itemCount: pages.length,
                controller: controller.pageController,
                onPageChanged: (page) {
                  onPageChanged?.call(page);
                  controller.saveLastPage(page + 1);
                },
                pageSnapping: true,
                itemBuilder: (ctx, index) {
                  List<String> newSurahs = [];
                  final page = pages[index];
                  final isFirstPage = index == 0 || index == 1;
                  return Container(
                    height: deviceSize.height * 0.8,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: isFirstPage
                              ? Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (page.ayahs.isNotEmpty)
                                          SurahHeaderWidget(
                                              page.ayahs[0].surahNameAr),
                                        if (index == 1)
                                          BasmallahWidget(
                                              page.ayahs[0].surahNumber),
                                        ...page.lines.map((line) {
                                          return _QuranLineWithBookmarks(
                                            line: line,
                                            bookmarksController:
                                                bookmarksController,
                                            deviceWidth: deviceSize.width,
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ListView(
                                      physics: orientation ==
                                              Orientation.portrait
                                          ? const NeverScrollableScrollPhysics()
                                          : null,
                                      children: [
                                        ...page.lines.map((line) {
                                          bool firstAyah = false;
                                          if (line.ayahs[0].ayahNumber == 1 &&
                                              !newSurahs.contains(
                                                  line.ayahs[0].surahNameAr)) {
                                            newSurahs
                                                .add(line.ayahs[0].surahNameAr);
                                            firstAyah = true;
                                          }
                                          return _QuranLineWithBookmarks(
                                            line: line,
                                            bookmarksController:
                                                bookmarksController,
                                            deviceWidth: deviceSize.width,
                                            firstAyah: firstAyah,
                                            showHeader: firstAyah,
                                            showBasmallah: firstAyah &&
                                                (line.ayahs[0].surahNumber !=
                                                    9),
                                            orientation: orientation,
                                            constraints: constraints,
                                            page: page,
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        bottomWidget ??
                            (showBottomWidget
                                ? QuranPageBottomInfoWidget(
                                    page: index + 1,
                                    hizb: page.hizb,
                                    surahName: page.ayahs.isNotEmpty
                                        ? page.ayahs.last.surahNameAr
                                        : '',
                                  )
                                : const SizedBox.shrink()),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Helper widget to reduce Obx nesting and improve performance
class _QuranLineWithBookmarks extends StatelessWidget {
  const _QuranLineWithBookmarks({
    required this.line,
    required this.bookmarksController,
    required this.deviceWidth,
    this.firstAyah = false,
    this.showHeader = false,
    this.showBasmallah = false,
    this.orientation,
    this.constraints,
    this.page,
    super.key,
  });

  final dynamic line;
  final BookmarksController bookmarksController;
  final double deviceWidth;
  final bool firstAyah;
  final bool showHeader;
  final bool showBasmallah;
  final Orientation? orientation;
  final BoxConstraints? constraints;
  final dynamic page;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bookmarks = bookmarksController.bookmarks;
      final bookmarksAyahs =
          bookmarks.map((bookmark) => bookmark.ayahId).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) SurahHeaderWidget(line.ayahs[0].surahNameAr),
          if (showBasmallah) BasmallahWidget(line.ayahs[0].surahNumber),
          SizedBox(
            width: deviceWidth - 30,
            height: orientation != null && constraints != null && page != null
                ? ((orientation == Orientation.portrait
                            ? constraints!.maxHeight
                            : deviceWidth) -
                        (page.numberOfNewSurahs *
                            (line.ayahs[0].surahNumber != 9 ? 110 : 80))) *
                    0.95 /
                    page.lines.length
                : null,
            child: QuranLine(
              line,
              bookmarksAyahs,
              bookmarks,
              boxFit: line.ayahs.last.centered ? BoxFit.scaleDown : BoxFit.fill,
            ),
          ),
        ],
      );
    });
  }
}

class _FlutterQuranSearchScreen extends StatefulWidget {
  const _FlutterQuranSearchScreen();

  @override
  State<_FlutterQuranSearchScreen> createState() =>
      _FlutterQuranSearchScreenState();
}

class _FlutterQuranSearchScreenState extends State<_FlutterQuranSearchScreen> {
  List<Ayah> ayahs = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بحث'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  onChanged: (txt) {
                    final searchResult = FlutterQuran().search(txt);
                    setState(() {
                      ayahs = [...searchResult];
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintText: 'بحث',
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: ayahs
                        .map((ayah) => Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    ayah.ayah.replaceAll('\n', ' '),
                                  ),
                                  subtitle: Text(ayah.surahNameAr),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    FlutterQuran().navigateToAyah(ayah);
                                  },
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
