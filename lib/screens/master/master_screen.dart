import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/master/master_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  List<String> collections = [
    'Departments',
    'Designations',
    'Locations',
    'ReportingManagers',
    'WorkModes'
  ];

  List<IconData> icons = [
    Icons.business_center,
    Icons.badge,
    Icons.location_on,
    Icons.supervisor_account,
    Icons.workspaces_filled
  ];

  List<bool> _isHovered = [];

  @override
  void initState() {
    super.initState();
    // Initialize hover state for each item in the list
    _isHovered = List.filled(collections.length, false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Master Data",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 8,
              ),
              itemBuilder: (BuildContext context, int index) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHovered[index] = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHovered[index] = false;
                    });
                  },
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: MasterDetailsScreen(
                            masterType: collections[index],
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isHovered[index]
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: _isHovered[index]
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icons[index],
                            size: 30,
                            color: _isHovered[index]
                                ? AppColors.primaryBlue
                                : AppColors.grey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            collections[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isHovered[index]
                                  ? AppColors.primaryBlue
                                  : AppColors.black,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: _isHovered[index]
                                ? AppColors.primaryBlue
                                : AppColors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
