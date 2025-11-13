// At top of file: replace your current imports with these
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' as vm; // << use alias 'vm'
import 'dart:math';

class Community {
  final String id; // e.g. "community_25"
  final int areaNumber; // parsed 25
  final Path path; // in SVG coordinate space
  Rect? bounds; // computed from path
  double? severity;
  double? safety; // 0..10
  Color color;

  Community({
    required this.id,
    required this.areaNumber,
    required this.path,
    this.bounds,
    this.severity,
    this.safety,
    required this.color,
  });
}

class ChicagoMap extends StatefulWidget {
  /// path to SVG asset containing <path id="community_<N>" d="..."/>
  final String svgAssetPath;

  /// API url, e.g. "https://aegis-api-sszj.onrender.com/predict"
  final String apiUrl;

  /// default month/hour/year for predictions
  final int month;
  final int hour;
  final int year;

  /// callback when a community is selected (id, safety, severity).
  final void Function(Community)? onCommunityTap;

  const ChicagoMap({
    Key? key,
    required this.svgAssetPath,
    required this.apiUrl,
    this.month = 7,
    this.hour = 20,
    this.year = 2019,
    this.onCommunityTap,
  }) : super(key: key);

  @override
  State<ChicagoMap> createState() => _ChicagoMapState();
}

class _ChicagoMapState extends State<ChicagoMap> with TickerProviderStateMixin {
  List<Community> _communities = [];
  bool _loading = true;
  String? _error;

  // For InteractiveViewer control
  final TransformationController _transformationController = TransformationController();
  AnimationController? _animationController;
  Animation<Matrix4>? _animation;
  double _svgWidth = 0, _svgHeight = 0; // from viewBox or computed


  @override
  void initState() {
    super.initState();
    _loadSvgAndParse();
  }

  @override
  void didUpdateWidget(covariant ChicagoMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if any of the inputs changed (month/hour/year)
    if (oldWidget.month != widget.month ||
        oldWidget.hour != widget.hour ||
        oldWidget.year != widget.year) {
      debugPrint('🔄 Inputs changed: Month=${widget.month}, Hour=${widget.hour}, Year=${widget.year}');
      _fetchSeverityForAll();
    }
  }


  @override
  void dispose() {
    _animationController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadSvgAndParse() async {
    try {
      final raw = await rootBundle.loadString(widget.svgAssetPath);
      final doc = xml.XmlDocument.parse(raw);

      // --- Parse <svg> dimensions ---
      final svgEl = doc.findElements('svg').first;
      final viewBoxAttr = svgEl.getAttribute('viewBox');
      if (viewBoxAttr != null) {
        final parts = viewBoxAttr
            .split(RegExp(r'[\s,]+'))
            .map((s) => double.tryParse(s))
            .toList();
        if (parts.length >= 4 && parts[2] != null && parts[3] != null) {
          _svgWidth = parts[2]!;
          _svgHeight = parts[3]!;
        }
      } else {
        final w = double.tryParse(svgEl.getAttribute('width') ?? '');
        final h = double.tryParse(svgEl.getAttribute('height') ?? '');
        if (w != null && h != null) {
          _svgWidth = w;
          _svgHeight = h;
        }
      }

      final paths = <Community>[];
      final addedIds = <String>{};

      // --- 1️⃣ Handle grouped <g id="community_X"> FIRST ---
      for (final gEl in doc.findAllElements('g')) {
        final id = gEl.getAttribute('id');
        if (id == null || !id.startsWith('community_')) continue;

        final areaNumber = _extractAreaNumber(id);
        Path combinedPath = Path();

        for (final innerPath in gEl.findAllElements('path')) {
          final d = innerPath.getAttribute('d');
          if (d == null) continue;

          // Skip paths that are purely strokes (no fill or fill="none")
          final fillAttr = innerPath.getAttribute('fill');
          final strokeAttr = innerPath.getAttribute('stroke');
          final isStrokeOnly =
          ((fillAttr == null || fillAttr == 'none') && strokeAttr != null);

          if (isStrokeOnly) continue;

          final subPath = parseSvgPathData(d);
          combinedPath.addPath(subPath, Offset.zero);
        }

        if (combinedPath.computeMetrics().isEmpty) continue;
        final bounds = combinedPath.getBounds();
        paths.add(Community(
          id: id,
          areaNumber: areaNumber ?? 0,
          path: combinedPath,
          bounds: bounds,
          color: Colors.grey.shade400,
        ));
        addedIds.add(id);
      }

// --- 2️⃣ Handle standalone <path id="community_X"> ---
      for (final pathEl in doc.findAllElements('path')) {
        final id = pathEl.getAttribute('id');
        final d = pathEl.getAttribute('d');
        if (id == null || !id.startsWith('community_')) continue;
        if (d == null) continue;
        if (addedIds.contains(id)) continue;

        final fillAttr = pathEl.getAttribute('fill');
        final strokeAttr = pathEl.getAttribute('stroke');
        final isStrokeOnly =
        ((fillAttr == null || fillAttr == 'none') && strokeAttr != null);
        if (isStrokeOnly) continue;

        final areaNumber = _extractAreaNumber(id);
        final Path p = parseSvgPathData(d);
        final bounds = p.getBounds();

        paths.add(Community(
          id: id,
          areaNumber: areaNumber ?? 0,
          path: p,
          bounds: bounds,
          color: Colors.grey.shade400,
        ));
        addedIds.add(id);
      }


      // --- 3️⃣ Extra safety: detect <path> without IDs inside untagged groups ---
      // Sometimes grouped communities don’t repeat "id" in <g> or <path>.
      for (final gEl in doc.findAllElements('g')) {
        final id = gEl.getAttribute('id');
        if (id == null) continue;
        if (!id.startsWith('community_')) continue;
        if (addedIds.contains(id)) continue;

        Path combinedPath = Path();
        for (final innerPath in gEl.findAllElements('path')) {
          final d = innerPath.getAttribute('d');
          if (d == null) continue;
          final subPath = parseSvgPathData(d);
          combinedPath.addPath(subPath, Offset.zero);
        }

        if (combinedPath.computeMetrics().isEmpty) continue;
        final areaNumber = _extractAreaNumber(id);
        final bounds = combinedPath.getBounds();

        paths.add(Community(
          id: id,
          areaNumber: areaNumber ?? 0,
          path: combinedPath,
          bounds: bounds,
          color: Colors.grey.shade400,
        ));
        addedIds.add(id);
      }

      // --- ✅ Done ---
      setState(() {
        _communities = paths;
        _loading = false;
      });

      print("✅ Loaded ${paths.length} communities total");
      for (final c in paths) {
        debugPrint(" - ${c.id}");
      }

      // Fetch colors/safety data
      unawaited(_fetchSeverityForAll());
    } catch (e, st) {
      setState(() {
        _error = 'Failed to parse SVG: $e';
        _loading = false;
      });
      debugPrint('SVG parse error: $e\n$st');
    }
  }


  int? _extractAreaNumber(String id) {
    final m = RegExp(r'(\d+)').firstMatch(id);
    if (m != null) return int.tryParse(m.group(0)!);
    return null;
  }

  /// Fetch severity for a single community (by Community.areaNumber),
  /// Fetch severity for a single community (by Community.areaNumber),
  /// update severity/safety on the community object and recolor.
  Future<void> _fetchSeverity(Community c) async {
    try {
      final body = json.encode({
        "Community_Area": c.areaNumber,
        "Month": widget.month,
        "Hour": widget.hour,
        "Year": widget.year
      });
      print('➡️ Sending request for ${c.id}: $body');

      final resp = await http.post(
        Uri.parse(widget.apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('⬅️ Response for ${c.id}: ${resp.body}');
        final severity = (data['severity_score'] is num)
            ? (data['severity_score'] as num).toDouble()
            : double.tryParse('${data['severity_score']}') ?? 0.0;
        print('📊 Parsed severity for ${c.id}: $severity');

        // --- Update the community and trigger repaint ---
        setState(() {
          c.severity = severity;
          _computeSafetyAndColor(c); // safety & color
        });

      } else {
        debugPrint('API error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('fetchSeverity error: $e');
    }
  }

  /// Fetch severity for all communities sequentially
  Future<void> _fetchSeverityForAll() async {
    if (_communities.isEmpty) return;

    for (final c in _communities) {
      await _fetchSeverity(c);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // optional: final setState to refresh all colors
    setState(() {});
  }







  /// Converts severity -> safety 0..10 using user's formula (adapted to Dart).double _severityToSafety(double sev) {
  double _severityToSafety(double sev) {
    // Use fixed min/max just like the backend
    const double sMin = 0.7;
    const double sMax = 33.5167;

    double safety;
    if (sMax > sMin) {
      final scaled = (sev - sMin) / (sMax - sMin);
      safety = 10.0 * (1.0 - scaled);
    } else {
      safety = 10.0 - sev;
    }
    // clamp 0..10
    return safety.clamp(0.0, 10.0);
  }


  /// Color mapping: safety 0 (unsafe) -> red; safety 10 (safe) -> green
  Color _safetyToColor(double safety) {
    // Rescale tight range 7..8 to 0..1
    const double minSafe = 7.0;
    const double maxSafe = 8.0;
    double t = ((safety - minSafe) / (maxSafe - minSafe)).clamp(0.0, 1.0);

    // Adjusted sigmoid for contrast
    const double k = 10.0; // milder slope than 20
    const double center = 0.5; // center of 0..1 after rescaling
    t = 1 / (1 + exp(-k * (t - center)));

    // HSV hue: 0 (red) → 120 (green)
    final hue = t * 120.0;

    // full vivid colors
    final hsv = HSVColor.fromAHSV(1.0, hue, 0.85, 0.85);
    return hsv.toColor();
  }




  void _computeSafetyAndColor(Community c) {
    if (c.severity == null) return;
    final safety = _severityToSafety(c.severity!);
    c.safety = safety;
    c.color = _safetyToColor(safety);

    // --- NEW LOG ---
    debugPrint("🟢 ${c.id}: severity=${c.severity}, safety=${c.safety}");
  }


  // Animate to a target rect (community bounds) by adjusting the transformation matrix
  Future<void> _animateToBounds(Rect bounds, {double padding = 20.0}) async {
    final size = context.size ?? Size(300, 300);

    // get current matrix as vm.Matrix4
    final vm.Matrix4 current = vm.Matrix4.fromList(_transformationController.value.storage);

    // compute scale to fit bounds into size
    final targetScaleX = (size.width - padding * 2) / bounds.width;
    final targetScaleY = (size.height - padding * 2) / bounds.height;
    final scale = min(targetScaleX, targetScaleY).clamp(0.5, 20.0);

    // compute translation so that bounds center becomes center of viewport
    final viewportCenter = Offset(size.width / 2, size.height / 2);
    final boundsCenter = bounds.center;

    // build target matrix (vm.Matrix4)
    final vm.Matrix4 target = vm.Matrix4.identity();
    target.translate(viewportCenter.dx, viewportCenter.dy);
    target.scale(scale);
    target.translate(-boundsCenter.dx, -boundsCenter.dy);

    _animationController?.dispose();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    // Create Tween using lists (Matrix4Tween expects Matrix4 from same package — use vm.Matrix4)
    final tween = Matrix4Tween(begin: current, end: target);
    _animation = tween.animate(CurveTween(curve: Curves.easeOut).animate(_animationController!))
      ..addListener(() {
        // assign back to the TransformationController using a Matrix4 constructed from storage
        _transformationController.value = Matrix4.fromList((_animation!.value as vm.Matrix4).storage);
      });

    await _animationController!.forward(from: 0.0);
  }


  void _onTap(Offset localPosition) {
    // retrieve the current transformation matrix and invert it (use vm.Matrix4)
    final vm.Matrix4 m = vm.Matrix4.fromList(_transformationController.value.storage);
    final vm.Matrix4 inverse = vm.Matrix4.inverted(m);

    // transform the tapped point into SVG coordinates
    final vm.Vector3 v = inverse.transform3(vm.Vector3(localPosition.dx, localPosition.dy, 0.0));
    final Offset pts = Offset(v.x, v.y);

    // find which community contains this point (topmost)
    for (final c in _communities.reversed) {
      if (c.path.contains(pts)) {
        if (c.severity == null) _fetchSeverity(c);
        if (c.bounds != null) _animateToBounds(c.bounds!.inflate(10));
        widget.onCommunityTap?.call(c);
        setState(() {});
        break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    // compute combined bounds to scale initial fit
    Rect combined = Rect.zero;
    if (_communities.isNotEmpty) {
      combined = _communities.map((c) => c.bounds ?? Rect.zero).reduce((a, b) => a.expandToInclude(b));
    } else {
      combined = Rect.fromLTWH(0, 0, _svgWidth > 0 ? _svgWidth : 1000, _svgHeight > 0 ? _svgHeight : 1000);
    }

    // Build a CustomPaint that draws all communities using their Paths
    final painter = _SvgMapPainter(communities: List.from(_communities));


    // We'll wrap in GestureDetector to get taps and in InteractiveViewer for pan/zoom
    return LayoutBuilder(builder: (context, constraints) {
      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

      // compute initial scale to fit combined into canvas
      final double scaleX = canvasSize.width / combined.width;
      final double scaleY = canvasSize.height / combined.height;
      final double initialScale = min(scaleX, scaleY);

      // compute initial matrix to center
      final Matrix4 initMatrix = Matrix4.identity();
      initMatrix.translate(canvasSize.width / 2, canvasSize.height / 2);
      initMatrix.scale(initialScale);
      initMatrix.translate(-combined.center.dx, -combined.center.dy);

      // If transformation matrix is identity (first build), set the controller to initial
      if (_transformationController.value == Matrix4.identity()) {
        _transformationController.value = initMatrix;
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _onTap(details.localPosition),
        child: InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(2000),
          minScale: 0.2,
          maxScale: 30.0,
          child: CustomPaint(
            size: Size(combined.width, combined.height),
            painter: painter,
          ),
        ),
      );
    });
  }
}

class _SvgMapPainter extends CustomPainter {
  final List<Community> communities;
  _SvgMapPainter({required this.communities});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = Colors.black.withOpacity(0.4);

    for (final c in communities) {
      fill.color = c.color;
      canvas.drawPath(c.path, fill);
      canvas.drawPath(c.path, stroke);
    }
  }

  @override
  @override
  bool shouldRepaint(covariant _SvgMapPainter oldDelegate) {
    // Repaint if color data changed
    if (oldDelegate.communities.length != communities.length) return true;
    for (int i = 0; i < communities.length; i++) {
      if (oldDelegate.communities[i].color != communities[i].color) {
        return true;
      }
    }
    return false;
  }

}
