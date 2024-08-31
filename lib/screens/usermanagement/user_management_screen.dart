import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
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
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Text(
              "User Management",
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
                      Tab(text: 'Summary'),
                      Tab(text: 'Dashboard'),
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
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Add User"),
                      ),
                      const SizedBox(width: 30)
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Something went wrong!',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No users found.'),
                        );
                      }

                      // Filter the data based on the search term
                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        var userData = doc.data() as Map<String, dynamic>;
                        var name =
                            userData['name']?.toString().toLowerCase() ?? '';
                        return name.contains(_searchTerm);
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Total Strength: ${filteredDocs.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                                      // Handle tap
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
                                          backgroundColor: Colors.grey,
                                          backgroundImage: AssetImage(
                                              'assets/images/profile.jpg'),
                                        ),
                                        title:
                                            Text(userData['name'] ?? "No Name"),
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
    );
  }
}
