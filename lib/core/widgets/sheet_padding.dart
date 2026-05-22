import 'package:flutter/material.dart';

class SheetPadding extends StatelessWidget {
  const SheetPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
