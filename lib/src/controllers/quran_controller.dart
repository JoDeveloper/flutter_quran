import 'package:flutter/material.dart';
import 'package:flutter_quran/src/models/surah.dart';
import 'package:get/get.dart';

import '../models/ayah.dart';
import '../models/quran_page.dart';
import '../repository/quran_repository.dart';

class QuranController extends GetxController {
  QuranController({QuranRepository? quranRepository})
      : _quranRepository = quranRepository ?? QuranRepository();

  final QuranRepository _quranRepository;

  RxList<QuranPage> staticPages = <QuranPage>[].obs;
  List<int> quranStops = [];
  List<int> surahsStart = [];
  List<Surah> surahs = [];
  final List<Ayah> ayahs = [];
  int lastPage = 1;
  int? initialPage;

  PageController _pageController = PageController();

  Future<void> loadQuran({quranPages = QuranRepository.hafsPagesNumber}) async {
    lastPage = _quranRepository.getLastPage() ?? 1;
    if (lastPage != 0) {
      _pageController = PageController(initialPage: lastPage - 1);
    }
    if (staticPages.isEmpty || quranPages != staticPages.length) {
      final List<QuranPage> pages = List.generate(quranPages,
          (index) => QuranPage(pageNumber: index + 1, ayahs: [], lines: []));
      final List<int> localQuranStops = [];
      final List<int> localSurahsStart = [];
      final List<Surah> localSurahs = [];
      final List<Ayah> localAyahs = [];
      final quranJson = await _quranRepository.getQuran();
      int hizb = 1;
      int surahsIndex = 1;
      List<Ayah> thisSurahAyahs = [];
      Surah? lastSurah;
      Ayah? lastAyah;
      final int quranJsonLength = quranJson.length;
      for (int i = 0; i < quranJsonLength; i++) {
        final ayahJson = quranJson[i];
        final ayah = Ayah.fromJson(ayahJson);
        final ayahText = ayah.ayah;
        final ayahSurahNumber = ayah.surahNumber;
        final ayahPage = ayah.page;
        final ayahNumber = ayah.ayahNumber;
        if (ayahSurahNumber != surahsIndex) {
          if (lastSurah != null && lastAyah != null) {
            lastSurah.endPage = lastAyah.page;
            lastSurah.ayahs = thisSurahAyahs;
          }
          surahsIndex = ayahSurahNumber;
          thisSurahAyahs = [];
        }
        localAyahs.add(ayah);
        thisSurahAyahs.add(ayah);
        final page = pages[ayahPage - 1];
        page.ayahs.add(ayah);
        if (ayahText.contains('۞')) {
          page.hizb = hizb++;
          localQuranStops.add(ayahPage);
        }
        if (ayahText.contains('۩')) {
          page.hasSajda = true;
        }
        if (ayahNumber == 1) {
          if (ayahText.contains('۞')) {
            ayah.ayah = ayahText.replaceAll('۞', '');
          }
          page.numberOfNewSurahs++;
          final surah = Surah(
              index: ayahSurahNumber,
              startPage: ayahPage,
              endPage: 0,
              nameEn: ayah.surahNameEn,
              nameAr: ayah.surahNameAr,
              ayahs: []);
          localSurahs.add(surah);
          localSurahsStart.add(ayahPage - 1);
          lastSurah = surah;
        }
        lastAyah = ayah;
      }
      if (lastSurah != null && lastAyah != null) {
        lastSurah.endPage = lastAyah.page;
        lastSurah.ayahs = thisSurahAyahs;
      }
      for (QuranPage staticPage in pages) {
        _splitAyahLines(staticPage);
      }
      staticPages.value = pages;
      quranStops = localQuranStops;
      surahsStart = localSurahsStart;
      surahs = localSurahs;
      ayahs
        ..clear()
        ..addAll(localAyahs);
    }
  }

  void _splitAyahLines(QuranPage staticPage) {
    List<Ayah> ayas = [];
    for (Ayah aya in staticPage.ayahs) {
      if (aya.ayahNumber == 1 && ayas.isNotEmpty) {
        ayas = [];
      }
      final ayaText = aya.ayah;
      if (ayaText.contains('\n')) {
        final lines = ayaText.split('\n');
        for (int i = 0; i < lines.length; i++) {
          bool centered = false;
          if ((aya.centered && i == lines.length - 2)) {
            centered = true;
          }
          final a = Ayah.fromAya(
              ayah: aya, aya: lines[i], ayaText: lines[i], centered: centered);
          ayas.add(a);
          if (i < lines.length - 1) {
            staticPage.lines.add(Line([...ayas]));
            ayas = [];
          }
        }
      } else {
        ayas.add(aya);
      }
    }
  }

  List<Ayah> search(String searchText) {
    if (searchText.isEmpty) {
      return [];
    } else {
      final filteredAyahs = ayahs
          .where((aya) => aya.ayahText.contains(searchText.trim()))
          .toList();
      return filteredAyahs;
    }
  }

  saveLastPage(int lastPage) {
    this.lastPage = lastPage;
    _quranRepository.saveLastPage(lastPage);
  }

  animateToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    } else {
      _pageController = PageController(initialPage: page);
    }
  }

  get pageController => _pageController;
}
