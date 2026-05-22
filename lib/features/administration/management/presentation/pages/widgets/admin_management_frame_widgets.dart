part of '../admin_management_pages.dart';

class _AdminPageFrame extends StatelessWidget {
  const _AdminPageFrame({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: title,
              showDivider: true,
              background: Colors.white,
              onBack: Navigator.of(context).canPop()
                  ? () => Navigator.of(context).pop()
                  : null,
              trailing: trailing,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _PagedBody extends StatelessWidget {
  const _PagedBody({
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.child,
  });

  final bool loading;
  final String? error;
  final bool isEmpty;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (loading) return const CenteredProgress();
    if (error != null) {
      return CenterErrorView(message: error!, onRetry: onRetry);
    }
    if (isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [EmptyInfoCard(title: emptyTitle, message: emptyMessage)],
      );
    }
    return child;
  }
}

class _FilterBand extends StatelessWidget {
  const _FilterBand({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
