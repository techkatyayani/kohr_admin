import 'dart:developer';
import 'package:Kohr_Admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeManagementScreen extends StatefulWidget {
  const TimeManagementScreen({super.key});

  @override
  State<TimeManagementScreen> createState() => _TimeManagementScreenState();
}

class _TimeManagementScreenState extends State<TimeManagementScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  late TextEditingController _fullDayCountController;
  late TextEditingController _halfDayCountController;
  bool _isFullDayApply = false;
  bool _isHalfDayApply = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fullDayCountController = TextEditingController();
    _halfDayCountController = TextEditingController();
  }

  @override
  void dispose() {
    _fullDayCountController.dispose();
    _halfDayCountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, DocumentSnapshot document) async {
    try {
      final initialTime = document['clockInTime'] != null
          ? TimeOfDay.fromDateTime(
              DateFormat("HH:mm:ss").parse(document['clockInTime']))
          : TimeOfDay.now();

      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryBlue,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
                chipTheme: ChipThemeData(
                  brightness: Brightness.light,
                  backgroundColor: AppColors.primaryBlue,
                )),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final tempDate = DateTime(2000, 1, 1, picked.hour, picked.minute);
        final updatedClockInTime = DateFormat("HH:mm:ss").format(tempDate);

        await _firestore
            .collection('Masterdata')
            .doc('collections')
            .collection('Departments')
            .doc(document.id)
            .update({'clockInTime': updatedClockInTime});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Updated clock-in time to $updatedClockInTime'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child:
                      Text('Failed to update clock-in time: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      log('Error updating clock-in time: ${e.toString()}');
    }
  }

  Future<void> _showEditDeductionDialog(DocumentSnapshot document) async {
    _fullDayCountController.text =
        document['fullDayDeductionCount']?.toString() ?? '0';
    _halfDayCountController.text =
        document['halfDayDeductionCount']?.toString() ?? '0';
    _isFullDayApply = document['isFullDayDeductionApply'] ?? false;
    _isHalfDayApply = document['ishalfDayDeductionApply'] ?? false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primaryBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Edit Deduction Settings',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document['name'] ?? 'Unnamed Department',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormSection(
                  'Half Day Deduction',
                  _halfDayCountController,
                  _isHalfDayApply,
                  (value) => setState(() => _isHalfDayApply = value),
                ),
                const SizedBox(height: 16),
                _buildFormSection(
                  'Full Day Deduction',
                  _fullDayCountController,
                  _isFullDayApply,
                  (value) => setState(() => _isFullDayApply = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveDeductionSettings(document.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(
    String title,
    TextEditingController controller,
    bool isApplied,
    Function(bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Count',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: isApplied,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              'Apply ${title.toLowerCase()}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveDeductionSettings(String documentId) async {
    try {
      await _firestore
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .doc(documentId)
          .update({
        'fullDayDeductionCount': int.parse(_fullDayCountController.text),
        'halfDayDeductionCount': int.parse(_halfDayCountController.text),
        'isFullDayDeductionApply': _isFullDayApply,
        'ishalfDayDeductionApply': _isHalfDayApply,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Settings updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to update settings: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      log('Error updating deduction settings: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Department Clock-In Times',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage department schedules and clock-in times',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppColors.primaryBlue,
                  tabs: const [
                    Tab(text: 'Clock-In Times Management'),
                    Tab(text: 'Alert Mail Management'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryBlue.withOpacity(0.1),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // First tab - your existing content
                  _buildClockInTimesManagement(),
                  // Second tab
                  _buildAlertMailManagement(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockInTimesManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading departments',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading departments...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Departments Found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add departments to manage their clock-in times',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];
            return _buildDepartmentCard(document);
          },
        );
      },
    );
  }

  Widget _buildAlertMailManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 24, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Text(
                    'Error loading settings',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department Header
                  _buildDepartmentHeader(doc),
                  const Divider(height: 1),
                  // Deduction Settings
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Half Day'),
                              const SizedBox(height: 8),
                              _buildCompactDeductionRow(
                                'Count',
                                doc['halfDayDeductionCount']?.toString() ?? '0',
                              ),
                              _buildCompactDeductionRow(
                                'Apply',
                                doc['ishalfDayDeductionApply']?.toString() ??
                                    'false',
                              ),
                            ],
                          ),
                        ),
                        // Full Day Section
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Full Day'),
                              const SizedBox(height: 8),
                              _buildCompactDeductionRow(
                                'Count',
                                doc['fullDayDeductionCount']?.toString() ?? '0',
                              ),
                              _buildCompactDeductionRow(
                                'Apply',
                                doc['isFullDayDeductionApply']?.toString() ??
                                    'false',
                              ),
                            ],
                          ),
                        ),

                        // Half Day Section
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildCompactDeductionRow(String label, String value) {
    final bool isEnabled = value.toLowerCase() == 'true';
    final Color valueColor = isEnabled ? Colors.green : AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: valueColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(DocumentSnapshot document) {
    final hasClockInTime = document['clockInTime'] != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectTime(context, document),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasClockInTime
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasClockInTime
                          ? Icons.access_time
                          : Icons.access_time_outlined,
                      color: hasClockInTime
                          ? AppColors.primaryBlue
                          : Colors.orange[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document['name'] ?? 'Unnamed Department',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (hasClockInTime) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              document['clockInTime'],
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Text(
                            'No clock-in time set',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: hasClockInTime
                          ? Colors.blue.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        color: hasClockInTime
                            ? AppColors.primaryBlue
                            : Colors.orange[600],
                        size: 20,
                      ),
                      onPressed: () => _selectTime(context, document),
                      tooltip: 'Edit Clock-in Time',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentHeader(DocumentSnapshot doc) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              doc['name'] ?? 'Unnamed Department',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            onPressed: () => _showEditDeductionDialog(doc),
            tooltip: 'Edit Deduction Settings',
          ),
        ],
      ),
    );
  }
}
