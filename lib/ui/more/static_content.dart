import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaticContentPage extends StatefulWidget {
  final String title;
  final int pageId;

  const StaticContentPage({super.key, required this.title, required this.pageId});

  @override
  State<StaticContentPage> createState() => _StaticContentPageState();
}

class _StaticContentPageState extends State<StaticContentPage> {
  String htmlContent = '';
  bool loading = true;
  String pageTitle = '';
  String url = '';

  static const cacheDuration = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    pageTitle = widget.title;
    loadContent();
  }

  Future<void> loadContent() async {
    final prefs = await SharedPreferences.getInstance();
    final contentKey = 'static_content_${widget.pageId}';
    final timestampKey = 'static_content_${widget.pageId}_ts';

    final cachedContent = prefs.getString(contentKey);
    final cachedTitle = prefs.getString('${contentKey}_title');
    url = prefs.getString('${contentKey}_url') ?? '';
    final cachedTime = prefs.getInt(timestampKey);

    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedContent != null && cachedTime != null && now - cachedTime < cacheDuration.inMilliseconds) {
      pageTitle = cachedTitle ?? widget.title;
      htmlContent = cachedContent;
    } else {
      try {
        final data = await ApiService.get('/hh/v1/page/${widget.pageId}');
        htmlContent = data['content'] ?? '';
        pageTitle = data['title'] ?? '';
        url = data['url'] ?? '';

        // Save to cache
        await prefs.setString(contentKey, htmlContent);
        await prefs.setString('${contentKey}_title', pageTitle);
        await prefs.setString('${contentKey}_url', url);
        await prefs.setInt(timestampKey, now);
      } catch (e) {
        debugPrint('❌ Error fetching content: $e');
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          if (url.isNotEmpty)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.shareFromSquare),
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: "$pageTitle\n$url", title: "Share - ($pageTitle)"));
              },
            ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? animatedLoader()
            : htmlContent.isEmpty
            ? const Center(child: Text('No content found.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Html(data: htmlContent),
              ),
      ),
    );
  }
}
