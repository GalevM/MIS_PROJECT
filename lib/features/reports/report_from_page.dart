import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mis_project/features/reports/report_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/themes/app_constants.dart';
import '../../core/themes/app_theme.dart';

class ReportFormPage extends ConsumerStatefulWidget {
  const ReportFormPage({super.key});

  @override
  ConsumerState<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends ConsumerState<ReportFormPage> {
  final _descCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _focusNode   = FocusNode();

  String _category = 'road';
  final List<File> _images = [];

  double? _lat, _lng;
  String  _address = '';

  bool _loadingLocation    = false;
  bool _loadingSuggestions = false;
  bool _submitting         = false;
  bool _locationFromGPS    = false;
  String? _error;

  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getGPSLocation();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }


  Future<void> _getGPSLocation() async {
    setState(() { _loadingLocation = true; _locationFromGPS = false; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Локацијата е одбиена во поставки');
        setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;

      try {
        final marks = await placemarkFromCoordinates(_lat!, _lng!);
        if (marks.isNotEmpty) {
          final m = marks.first;
          _address = [m.street, m.subLocality, m.locality]
              .where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (_) {
        _address = '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';
      }

      _addressCtrl.text = _address;
      setState(() => _locationFromGPS = true);
    } catch (e) {
      _showSnack('Не може да се добие GPS локација');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }


  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().length < 3) { setState(() => _suggestions = []); return; }
    setState(() => _loadingSuggestions = true);
    try {
      final apiKey  = dotenv.env['GEOAPIFY_KEY'] ?? '';
      final encoded = Uri.encodeComponent(query);
      final uri     = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete'
            '?text=$encoded&lang=mk&limit=6&apiKey=$apiKey',
      );
      final client   = HttpClient();
      final req      = await client.getUrl(uri);
      final response = await req.close();
      final body     = await response.transform(const Utf8Decoder()).join();
      client.close();

      final data     = jsonDecode(body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (mounted) setState(() => _suggestions = features.cast<Map<String, dynamic>>());
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  void _onAddressChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() { _suggestions = []; _lat = null; _lng = null; _locationFromGPS = false; });
      return;
    }
    setState(() { _locationFromGPS = false; _lat = null; _lng = null; });
    _debounce = Timer(const Duration(milliseconds: 420), () => _fetchSuggestions(value));
  }


  void _selectSuggestion(Map<String, dynamic> feat) {
    final props = feat['properties'] as Map<String, dynamic>;
    final name  = (props['formatted'] as String?) ?? '';
    final lat   = (props['lat'] as num?)?.toDouble();
    final lon   = (props['lon'] as num?)?.toDouble();
    if (lat == null || lon == null) return;

    _addressCtrl.text = name;
    _focusNode.unfocus();
    setState(() { _lat = lat; _lng = lon; _address = name; _suggestions = []; _locationFromGPS = false; });
  }



  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 3) { _showSnack('Максимум 3 слики'); return; }
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 75, maxWidth: 1920, maxHeight: 1920);
    if (picked == null) return;
    final tmp  = await getTemporaryDirectory();
    final dest = p.join(tmp.path, '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}');
    setState(() => _images.add(File(picked.path)..copySync(dest)));
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('Камера', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onTap: () { context.pop(); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Галерија', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              onTap: () { context.pop(); _pickImage(ImageSource.gallery); },
            ),
          ],
        )),
      ),
    );
  }


  Future<void> _submit() async {
    if (_lat == null || _lng == null) {
      setState(() => _error = 'Одберете локација или користете GPS за земанје на моменталната локација.');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Внесете опис на проблемот.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    final router = GoRouter.of(context);
    try {
      final id = await ref.read(reportNotifierProvider.notifier).submitReport(
        category:    _category,
        description: _descCtrl.text.trim(),
        latitude:    _lat!,
        longitude:   _lng!,
        address:     _address,
        images:      _images,
      );
      if (!mounted) return;
      router.pushReplacement('/report/$id');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пријавата е успешно поднесена! 🎉')));
      });
    } catch (e) {
      if (mounted) setState(() { _error = 'Грешка: $e'; _submitting = false; });
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пријави Проблем'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: GestureDetector(
        onTap: () { _focusNode.unfocus(); setState(() => _suggestions = []); },
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _ImagePickerSection(
                images: _images,
                onAdd: _showImageSheet,
                onRemove: (i) => setState(() => _images.removeAt(i)),
              ),

              const SizedBox(height: 20),

              _fieldLabel('Локација'),
              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _addressCtrl,
                      focusNode: _focusNode,
                      onChanged: _onAddressChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Пребарај адреса...',
                        prefixIcon: _loadingSuggestions
                            ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2)))
                            : Icon(
                            _locationFromGPS ? Icons.my_location : Icons.search,
                            color: _locationFromGPS ? AppTheme.success : AppTheme.textMuted,
                            size: 20),
                        suffixIcon: _addressCtrl.text.isNotEmpty
                            ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _addressCtrl.clear();
                              setState(() { _suggestions = []; _lat = null; _lng = null; _locationFromGPS = false; });
                            })
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Tooltip(
                    message: 'Моментална локација',
                    child: GestureDetector(
                      onTap: _loadingLocation ? null : _getGPSLocation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: _locationFromGPS ? AppTheme.success : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _locationFromGPS ? AppTheme.success : AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                        child: _loadingLocation
                            ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _locationFromGPS ? Colors.white : AppTheme.primary,
                            ))
                            : Icon(Icons.my_location,
                            color: _locationFromGPS ? Colors.white : AppTheme.primary,
                            size: 22),
                      ),
                    ),
                  ),
                ],
              ),

              if (_lat != null && _suggestions.isEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: _locationFromGPS ? AppTheme.successLight : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _locationFromGPS
                          ? AppTheme.success.withOpacity(0.4)
                          : AppTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _locationFromGPS ? Icons.my_location : Icons.location_on_outlined,
                      size: 15,
                      color: _locationFromGPS ? AppTheme.success : AppTheme.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(child: Text(
                      _address.isNotEmpty
                          ? _address
                          : '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                      style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: _locationFromGPS ? AppTheme.success : AppTheme.primary,
                      ),
                      maxLines: 2,
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _locationFromGPS
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _locationFromGPS ? 'GPS' : 'Избрано',
                        style: GoogleFonts.nunito(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: _locationFromGPS ? AppTheme.success : AppTheme.primary,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],

              // Suggestions dropdown
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCFD8DC)),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: _suggestions.asMap().entries.map((entry) {
                        final feat  = entry.value;
                        final props = feat['properties'] as Map<String, dynamic>;
                        final name  = props['formatted'] as String? ?? '';
                        final city  = props['city'] as String?
                            ?? props['county'] as String? ?? '';
                        final isLast = entry.key == _suggestions.length - 1;
                        return Column(children: [
                          InkWell(
                            onTap: () => _selectSuggestion(feat),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              child: Row(children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.location_on_outlined,
                                      color: AppTheme.primary, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: GoogleFonts.nunito(
                                        fontSize: 13, fontWeight: FontWeight.w700),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    if (city.isNotEmpty)
                                      Text(city, style: GoogleFonts.nunito(
                                          fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                )),
                                const Icon(Icons.north_west, size: 13, color: AppTheme.textMuted),
                              ]),
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, indent: 56),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              _fieldLabel('Категорија'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final sel = _category == cat['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppTheme.primary : const Color(0xFFCFD8DC),
                          width: 1.5,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 6)]
                            : [],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(cat['label']!, style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppTheme.textPrimary,
                        )),
                      ]),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _fieldLabel('Опис'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(hintText: 'Опишете го проблемот...'),
              ),

              const SizedBox(height: 12),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: GoogleFonts.nunito(
                        color: Colors.red.shade700, fontSize: 13))),
                  ]),
                ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(_submitting ? 'Поднесување...' : 'Поднеси Пријава'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted));
}


class _ImagePickerSection extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  const _ImagePickerSection({required this.images, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          height: 148,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary, width: 2),
          ),
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.primary),
              const SizedBox(height: 8),
              Text('Додади слика', style: GoogleFonts.nunito(
                  color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 14)),
              Text('До 3 слики · Опционално', style: GoogleFonts.nunito(
                  fontSize: 11, color: AppTheme.textMuted)),
            ],
          )),
        ),
      );
    }
    return SizedBox(
      height: 148,
      child: Row(children: [
        ...images.asMap().entries.map((e) => Expanded(
          child: Stack(fit: StackFit.expand, children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover),
              ),
            ),
            Positioned(top: 4, right: 12, child: GestureDetector(
              onTap: () => onRemove(e.key),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 13),
              ),
            )),
          ]),
        )),
        if (images.length < 3)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 68,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary, width: 1.5),
              ),
              child: const Center(child: Icon(Icons.add_photo_alternate_outlined,
                  color: AppTheme.primary, size: 26)),
            ),
          ),
      ]),
    );
  }
}