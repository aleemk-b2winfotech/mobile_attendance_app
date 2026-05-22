part of '../admin_team_user_actions.dart';

class _AdminUserLocationSheet extends StatefulWidget {
  const _AdminUserLocationSheet({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserLocationSheet> createState() =>
      _AdminUserLocationSheetState();
}

class _AdminUserLocationSheetState extends State<_AdminUserLocationSheet> {
  final _actions = Get.find<AdminUserActionsController>();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _radius = TextEditingController(text: '100');
  bool _loading = true;
  bool _saving = false;
  bool _resolvingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _radius.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final location = await _actions.fetchLocation(widget.user);
      _lat.text = location.latitude.toString();
      _lng.text = location.longitude.toString();
      _radius.text = location.radiusMeters.toString();
    } catch (_) {
      // Keep the inputs editable even when the user has no saved office profile.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetPadding(
      child: _loading
          ? const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.fullName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _lat,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lng,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _radius,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Radius meters'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _resolvingCurrentLocation
                      ? null
                      : _setCurrentLocation,
                  icon: _resolvingCurrentLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text('Set Current Location'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const ButtonSpinner()
                      : const Text('Save Location'),
                ),
              ],
            ),
    );
  }

  Future<void> _setCurrentLocation() async {
    setState(() => _resolvingCurrentLocation = true);
    try {
      final position = await _actions.resolveCurrentLocation();
      if (!mounted) return;
      setState(() {
        _lat.text = position.latitude.toStringAsFixed(6);
        _lng.text = position.longitude.toStringAsFixed(6);
      });
    } catch (error) {
      if (!mounted) return;
      _showSnack(
        context,
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _resolvingCurrentLocation = false);
    }
  }

  Future<void> _save() async {
    final location = AdminUserLocationDraft.tryParse(
      latitude: _lat.text,
      longitude: _lng.text,
      radiusMeters: _radius.text,
    );

    if (location == null) {
      _showSnack(context, 'Enter valid location values.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final message = await _actions.updateLocation(
        user: widget.user,
        location: location,
      );
      if (!mounted) return;
      if (message != null) {
        _showSnack(context, message, isError: true);
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
