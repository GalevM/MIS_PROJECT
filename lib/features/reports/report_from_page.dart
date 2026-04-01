import 'dart:io';
import 'package:flutter/material.dart';
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
  final _descCtrl = TextEditingController();
  String _category = 'road';
  final List<File> _images = [];
  double? _lat, _lng;
  String _address = '';
  bool _loadingLocation = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() { _address = 'Локацијата е одбиена'; _loadingLocation = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
      final placemarks = await placemarkFromCoordinates(_lat!, _lng!);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address = [p.street, p.subLocality, p.locality].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (e) {
      _address = 'Не може да се добие локација';
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 3) {
      _showSnack('Максимум 3 слики');
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (picked == null) return;

    // Copy to app's temp directory — iOS XFile paths can become invalid
    final appTempDir = await getTemporaryDirectory();
    final stablePath = p.join(appTempDir.path, '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}');
    final stableFile = await File(picked.path).copy(stablePath);

    setState(() => _images.add(stableFile));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
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
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_lat == null || _lng == null) {
      setState(() => _error = 'Прво добијте ја локацијата.');
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Внесете опис на проблемот.');
      return;
    }
    setState(() { _submitting = true; _error = null; });

    // Capture router BEFORE the async gap to avoid "use after dispose" crash
    final router = GoRouter.of(context);

    try {
      final id = await ref.read(reportNotifierProvider.notifier).submitReport(
        category: _category,
        description: _descCtrl.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
        address: _address,
        images: _images,
      );

      if (!mounted) return;

      // Replace the form page with the detail page (pop + push)
      // Using pushReplacement keeps the shell/bottom-nav alive
      router.pushReplacement('/report/$id');

      // Show snackbar after navigation with a small delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пријавата е успешно поднесена! 🎉')),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() { _error = 'Грешка: $e'; _submitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пријави Проблем'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image upload area
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: _images.isEmpty
                  ? Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary, width: 2, style: BorderStyle.solid),
                ),
                child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 42, color: AppTheme.primary),
                    const SizedBox(height: 8),
                    Text('Додади слика (опционално)', style: GoogleFonts.nunito(
                      color: AppTheme.primary, fontWeight: FontWeight.w700,
                    )),
                    Text('До 3 слики', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                )),
              )
                  : SizedBox(
                height: 160,
                child: Row(
                  children: [
                    ..._images.asMap().entries.map((e) => Expanded(
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(top: 4, right: 12, child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(e.key)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          )),
                        ],
                      ),
                    )),
                    if (_images.length < 3)
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary, width: 1.5),
                          ),
                          child: const Center(child: Icon(Icons.add, color: AppTheme.primary, size: 28)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _loadingLocation
                        ? Row(children: [
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Добивање локација...', style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.primary)),
                    ])
                        : Text(_address.isEmpty ? 'Локација недостапна' : _address,
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ),
                  IconButton(icon: const Icon(Icons.refresh, color: AppTheme.primary, size: 18), onPressed: _getLocation),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category
            Text('Категорија', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final selected = _category == cat['value'];
                return GestureDetector(
                  onTap: () => setState(() => _category = cat['value']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFCFD8DC), width: 1.5),
                      boxShadow: selected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 6)] : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(cat['label']!, style: GoogleFonts.nunito(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppTheme.textPrimary,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Description
            Text('Опис', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
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
                  Expanded(child: Text(_error!, style: GoogleFonts.nunito(color: Colors.red.shade700, fontSize: 13))),
                ]),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(_submitting ? 'Поднесување...' : 'Поднеси Пријава'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
