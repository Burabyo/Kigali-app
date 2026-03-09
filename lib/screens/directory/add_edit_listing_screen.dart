import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';

class AddEditListingScreen extends StatefulWidget {
  final Listing? listing; // null = create, non-null = edit

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  String _selectedCategory = 'Café';
  bool _isSaving = false;
  bool _isGettingLocation = false;

  bool get _isEditing => widget.listing != null;

  static const List<String> _categories = [
    'Café', 'Restaurant', 'Hospital', 'Police Station', 'Library',
    'Park', 'Tourist Attraction', 'Pharmacy', 'Bank', 'Supermarket',
    'Hotel', 'Gym', 'School', 'Utility Office',
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameCtrl = TextEditingController(text: l?.name ?? '');
    _addressCtrl = TextEditingController(text: l?.address ?? '');
    _contactCtrl = TextEditingController(text: l?.contactNumber ?? '');
    _descriptionCtrl = TextEditingController(text: l?.description ?? '');
    _latCtrl = TextEditingController(text: l?.latitude.toString() ?? '');
    _lngCtrl = TextEditingController(text: l?.longitude.toString() ?? '');
    _selectedCategory = l?.category ?? 'Café';
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _addressCtrl, _contactCtrl,
      _descriptionCtrl, _latCtrl, _lngCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latCtrl.text = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final listingsProv = context.read<ListingsProvider>();

    final listing = Listing(
      id: widget.listing?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text) ?? -1.9403,
      longitude: double.tryParse(_lngCtrl.text) ?? 29.8739,
      createdBy: auth.user?.uid ?? '',
      timestamp: widget.listing?.timestamp ?? DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await listingsProv.updateListing(listing);
    } else {
      success = await listingsProv.createListing(listing);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Listing updated!' : 'Listing created!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(listingsProv.errorMessage ?? 'Failed to save listing'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit Listing' : 'Add Listing'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.accentGold),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Basic Information'),
              const SizedBox(height: 12),
              _buildField(_nameCtrl, 'Place / Service Name',
                  Icons.storefront_outlined),
              const SizedBox(height: 14),
              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: AppTheme.cardDark,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(
                                color: AppTheme.textPrimary))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 14),
              _buildField(_addressCtrl, 'Address', Icons.location_on_outlined),
              const SizedBox(height: 14),
              _buildField(
                  _contactCtrl, 'Contact Number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _buildField(
                _descriptionCtrl,
                'Description',
                Icons.description_outlined,
                maxLines: 4,
                required: false,
              ),
              const SizedBox(height: 24),
              _sectionLabel('Location Coordinates'),
              const SizedBox(height: 4),
              const Text(
                'Enter coordinates manually or use your current location',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _latCtrl, 'Latitude', Icons.north,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      _lngCtrl, 'Longitude', Icons.east,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentGold),
                        )
                      : const Icon(Icons.my_location,
                          color: AppTheme.accentGold),
                  label: Text(
                    _isGettingLocation
                        ? 'Getting location...'
                        : 'Use Current Location',
                    style: const TextStyle(color: AppTheme.accentGold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accentGold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(
                      _isEditing ? 'Update Listing' : 'Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator ??
          (required
              ? (v) {
                  if (v == null || v.trim().isEmpty) return '$label is required';
                  return null;
                }
              : null),
    );
  }
}
