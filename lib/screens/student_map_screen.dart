import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/config/app_config.dart';
import 'package:app/data/app_database.dart';
import 'package:app/models/student.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key, this.focusStudentId});

  final int? focusStudentId;

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  static const _vietnam = CameraPosition(
    target: LatLng(16.047, 108.206),
    zoom: 5.2,
  );

  GoogleMapController? _controller;
  List<_Pin> _pins = const [];
  List<StudentWithMajor> _failed = const [];
  bool _loading = true;
  bool _framed = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final students = await AppDatabase.instance.studentsWithMajor();
      final geocoding = Geocoding(locale: const Locale('vi', 'VN'));
      final pins = <_Pin>[];
      final failed = <StudentWithMajor>[];
      for (final student in students) {
        if (!mounted) return;
        final position = await _locate(geocoding, student.address);
        if (position == null) {
          failed.add(student);
        } else {
          pins.add(_Pin(student, position));
        }
      }
      if (!mounted) return;
      setState(() {
        _pins = pins;
        _failed = failed;
        _loading = false;
        _error = null;
      });
      _maybeFrame();
      _notifyMissingFocus();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<LatLng?> _locate(Geocoding geocoding, String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;
    final queries = <String>[trimmed];
    if (!_mentionsVietnam(trimmed)) {
      queries.add('$trimmed, Việt Nam');
    }
    for (final query in queries) {
      try {
        final results = await geocoding.locationFromAddress(query);
        if (results.isEmpty) continue;
        final hit = results.first;
        return LatLng(hit.latitude, hit.longitude);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  bool _mentionsVietnam(String address) {
    final lower = address.toLowerCase();
    return lower.contains('việt nam') ||
        lower.contains('viet nam') ||
        lower.contains('vietnam');
  }

  void _notifyMissingFocus() {
    final focusId = widget.focusStudentId;
    if (focusId == null) return;
    final found = _pins.any((pin) => pin.student.id == focusId);
    if (found || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Không định vị được địa chỉ của sinh viên này.'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _maybeFrame();
  }

  void _maybeFrame() {
    if (_framed || _controller == null || _loading || _pins.isEmpty) return;
    _framed = true;
    _frameCamera();
  }

  Future<void> _frameCamera() async {
    final controller = _controller;
    if (controller == null || _pins.isEmpty) return;
    final focusId = widget.focusStudentId;
    final focus = focusId == null
        ? null
        : _pins.cast<_Pin?>().firstWhere(
            (pin) => pin!.student.id == focusId,
            orElse: () => null,
          );
    try {
      if (focus != null || _pins.length == 1) {
        final target = (focus ?? _pins.first).position;
        await controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
        return;
      }
      final points = _pins.map((pin) => pin.position).toList();
      if (_isSamePoint(points)) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 15),
        );
        return;
      }
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(_bounds(points), 56),
      );
    } catch (_) {
      if (!mounted || _controller == null) return;
      final target = (focus ?? _pins.first).position;
      await _controller!.moveCamera(CameraUpdate.newLatLngZoom(target, 14));
    }
  }

  bool _isSamePoint(List<LatLng> points) {
    final first = points.first;
    return points.every(
      (point) =>
          (point.latitude - first.latitude).abs() < 0.0001 &&
          (point.longitude - first.longitude).abs() < 0.0001,
    );
  }

  LatLngBounds _bounds(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Marker> get _markers {
    return {
      for (final pin in _pins)
        Marker(
          markerId: MarkerId('student-${pin.student.id}'),
          position: pin.position,
          infoWindow: InfoWindow(
            title: pin.student.name,
            snippet: '${pin.student.nameMajor} · ${pin.student.address}',
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Vị trí sinh viên')),
      body: Column(
        children: [
          if (!AppConfig.hasMapsKey)
            Material(
              color: theme.colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Chưa có Maps API key. Dán cùng một key vào AppConfig.mapsApiKey và AndroidManifest (com.google.android.geo.API_KEY).',
                ),
              ),
            ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Không tải được bản đồ.\n$_error'),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _vietnam,
              markers: _markers,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          if (_failed.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: Material(
                color: theme.colorScheme.errorContainer,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        'Không xác định được vị trí',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    for (final student in _failed)
                      ListTile(
                        dense: true,
                        title: Text(student.name),
                        subtitle: Text(student.address),
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

class _Pin {
  const _Pin(this.student, this.position);

  final StudentWithMajor student;
  final LatLng position;
}
