import 'package:flutter/material.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("KPI's"),
    );
  }
}
