import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/screens/kpi/kpi_form_screen.dart';
import 'package:page_transition/page_transition.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                "KPI's",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primaryBlue,
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "KPI's"),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchTerm = value.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       PageTransition(
                        //           child: const AddUserScreen(),
                        //           type: PageTransitionType.fade),
                        //     );
                        //   },
                        //   child: const Text("Add User"),
                        // ),
                        const SizedBox(width: 30),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     sendMail(
                        //         'guptasaksham9303@gmail.com', 'Saksham123');
                        //   },
                        //   child: const Text("Send Mail"),
                        // ),
                        // const SizedBox(width: 16),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('profiles')
                          .orderBy('name', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Something went wrong!',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No users found.'),
                          );
                        }
                        final filteredDocs = snapshot.data!.docs.where((doc) {
                          var userData = doc.data() as Map<String, dynamic>;
                          var name =
                              userData['name']?.toString().toLowerCase() ?? '';
                          return name.contains(_searchTerm);
                        }).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                var userData = filteredDocs[index].data()
                                    as Map<String, dynamic>;
                                bool isHovered = false;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                child: KpiFormScreen(
                                                  name: userData['name'],
                                                  email: userData['workEmail'],
                                                ),
                                                type: PageTransitionType.fade));
                                      },
                                      onHover: (hovering) {
                                        setState(() {
                                          isHovered = hovering;
                                        });
                                      },
                                      child: Container(
                                        color: isHovered
                                            ? Colors.grey[300]
                                            : Colors.transparent,
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: AppColors.grey,
                                            backgroundImage: AssetImage(
                                                'assets/images/profile.jpg'),
                                          ),
                                          title: Text(
                                              userData['name'] ?? "No Name"),
                                          subtitle: Text(
                                              userData['employeeType'] ??
                                                  "No Department"),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
