part of '../admin_team_user_actions.dart';

class _AdminUserDeviceLogsSheet extends StatefulWidget {
  const _AdminUserDeviceLogsSheet({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserDeviceLogsSheet> createState() =>
      _AdminUserDeviceLogsSheetState();
}

class _AdminUserDeviceLogsSheetState extends State<_AdminUserDeviceLogsSheet> {
  static const _statuses = ['ALL', 'PENDING', 'APPROVED', 'REJECTED'];

  final _actions = Get.find<AdminUserActionsController>();
  var _rows = <AdminDeviceChangeLog>[];
  var _meta = const AdminPaginationMeta.empty();
  var _status = 'ALL';
  var _page = 1;
  var _loading = true;
  String? _error;

  int get _totalPages => _meta.totalPages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _actions.fetchDeviceChangeLogs(
        user: widget.user,
        status: _status == 'ALL' ? null : _status,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _rows = result.rows;
        _meta = result.meta;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _rows = const [];
        _meta = const AdminPaginationMeta.empty();
        _error = _actions.toReadableError(error);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetPadding(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Logs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.user.fullName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final status in _statuses)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_deviceLogStatusLabel(status)),
                        selected: _status == status,
                        onSelected: _loading
                            ? null
                            : (_) {
                                setState(() {
                                  _status = status;
                                  _page = 1;
                                });
                                _load();
                              },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(child: _buildBody(context)),
            if (!_loading && _error == null && _totalPages > 1) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _page <= 1
                          ? null
                          : () {
                              setState(() => _page -= 1);
                              _load();
                            },
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Previous'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$_page / $_totalPages'),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _page >= _totalPages
                          ? null
                          : () {
                              setState(() => _page += 1);
                              _load();
                            },
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_rows.isEmpty) {
      return Center(
        child: Text(
          'No device change logs',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _DeviceLogCard(row: _rows[index]),
    );
  }
}

class _DeviceLogCard extends StatelessWidget {
  const _DeviceLogCard({required this.row});

  final AdminDeviceChangeLog row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: _deviceLogStatusLabel(row.status),
                status: row.status,
                compact: true,
              ),
              const Spacer(),
              Text(
                _deviceLogDateTime(row.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DeviceValueLine(
            label: 'Old device',
            value: row.currentDeviceIdSnapshot ?? '-',
          ),
          const SizedBox(height: 8),
          _DeviceValueLine(
            label: 'Requested device',
            value: row.requestedDeviceId.isEmpty ? '-' : row.requestedDeviceId,
          ),
          if (row.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(row.reason, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (row.actionAt != null || row.actionByName.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Text(
              [
                if (row.actionAt != null) _deviceLogDateTime(row.actionAt),
                if (row.actionByName.isNotEmpty) 'by ${row.actionByName}',
              ].join(' '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (row.actionNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(row.actionNote, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _DeviceValueLine extends StatelessWidget {
  const _DeviceValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

String _deviceLogDateTime(Object? value) {
  final text = _text(value, fallback: '-');
  if (text == '-') return text;
  final date = DateTime.tryParse(text)?.toLocal();
  if (date == null) return text;
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}

String _deviceLogStatusLabel(String status) {
  return switch (status) {
    'ALL' => 'All',
    'PENDING' => 'Pending',
    'APPROVED' => 'Approved',
    'REJECTED' => 'Rejected',
    _ => status,
  };
}
