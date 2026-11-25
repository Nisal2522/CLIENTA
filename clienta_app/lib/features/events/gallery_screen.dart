import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/store.dart';
import '../common/download_sheet.dart';
import 'section_scaffold.dart';

const _themes = [ArtTheme.tech, ArtTheme.ocean, ArtTheme.summit, ArtTheme.textile, ArtTheme.agri];

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _cols = 3;

  @override
  Widget build(BuildContext context) {
    final e = Store.instance.event(widget.eventId);
    final photos = e.gallery;
    return SectionScaffold(
      title: 'Photo Gallery',
      subtitle: '${photos.length} photos · ${e.title}',
      actions: [
        CircleIconBtn(
          icon: _cols == 3 ? Icons.grid_view_rounded : Icons.apps_rounded,
          size: 40,
          onTap: () => setState(() => _cols = _cols == 3 ? 2 : 3),
        ),
      ],
      body: photos.isEmpty
          ? StateView.empty(icon: Icons.photo_library_outlined, title: 'No photos yet', message: 'Photos will appear here during and after the event.')
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: GridView.builder(
                key: ValueKey(_cols),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _cols, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: photos.length,
                itemBuilder: (_, i) => FadeSlideIn(
                  index: i,
                  stagger: 30,
                  child: Pressable(
                    onTap: () => Navigator.of(context).push(AppRoute(PhotoViewer(photos: photos, initial: i, title: e.title), fadeOnly: true)),
                    child: Hero(
                      tag: photos[i],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_cols == 3 ? 14 : 20),
                        child: SmartImage(url: photos[i], seed: photos[i], theme: _themes[i % _themes.length]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.photos, required this.initial, required this.title});
  final List<String> photos;
  final int initial;
  final String title;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final _page = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  bool _chrome = true;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _chrome = !_chrome),
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0).abs() > 600) Navigator.pop(context);
            },
            child: PageView.builder(
              controller: _page,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: widget.photos[i],
                      child: SmartImage(url: widget.photos[i], seed: widget.photos[i], theme: _themes[i % _themes.length]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _chrome ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: IgnorePointer(
              ignoring: !_chrome,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(12, top + 8, 12, 14),
                    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        Expanded(
                          child: Column(
                            children: [
                              Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              Text('${_index + 1} of ${widget.photos.length}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                          onPressed: () => toast(context, 'Share sheet opened (prototype)', icon: Icons.ios_share_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.paddingOf(context).bottom + 20),
                    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
                    child: AppButton(
                      label: 'Download photo',
                      icon: Icons.download_rounded,
                      variant: ButtonVariant.light,
                      onPressed: () => simulateDownload(
                        context,
                        id: widget.photos[_index],
                        fileName: 'IMG_${(_index + 1).toString().padLeft(4, '0')}.jpg',
                        sizeLabel: '2.4 MB',
                        icon: Icons.image_rounded,
                        color: AppColors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
