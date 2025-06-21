part of '../flutter_quran_screen.dart';

class AyahLongClickDialog extends StatelessWidget {
  const AyahLongClickDialog(
    this.ayah, {
    super.key,
    this.onTafseer,
    this.onErab,
  });

  final Ayah ayah;
  final void Function(Ayah)? onTafseer;
  final void Function(Ayah)? onErab;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00BF6D);
    const mainTextColor = Color(0xFF1F2937); // Tailwind gray-800
    const secondaryTextColor = Color(0xFF4B5563); // Tailwind gray-600
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 5,
        backgroundColor: primaryColor.withAlpha((0.08 * 255).toInt()),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أضف علامة',
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...Get.find<BookmarksController>()
                    .bookmarks
                    .sublist(0, 3)
                    .map((bookmark) => ListTile(
                          leading: const Icon(
                            Icons.bookmark,
                            color: primaryColor,
                          ),
                          title: Text(
                            bookmark.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: mainTextColor),
                          ),
                          onTap: () {
                            Get.find<BookmarksController>().saveBookmark(
                                ayahId: ayah.id,
                                page: ayah.page,
                                bookmarkId: bookmark.id);
                            Navigator.of(context).pop();
                          },
                        )),
                const Divider(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                            text: Get.find<QuranController>()
                                .staticPages[ayah.page - 1]
                                .ayahs
                                .firstWhere((element) => element.id == ayah.id)
                                .ayah))
                        .then((value) =>
                            ToastUtils().showToast("تم النسخ الى الحافظة"));
                    Navigator.of(context).pop();
                  },
                  child: const ListTile(
                      title: Text("نسخ الى الحافظة",
                          style: TextStyle(color: secondaryTextColor)),
                      leading: Icon(
                        Icons.copy_rounded,
                        color: primaryColor,
                      )),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (onTafseer != null) {
                            onTafseer!(ayah);
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'تفسير الآية',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (onErab != null) {
                            onErab!(ayah);
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'إعراب الآية',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
