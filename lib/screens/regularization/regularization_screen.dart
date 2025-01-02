import 'dart:developer';

import 'package:Kohr_Admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegularizationScreen extends StatefulWidget {
  const RegularizationScreen({super.key});

  @override
  State<RegularizationScreen> createState() => _RegularizationScreenState();
}

class _RegularizationScreenState extends State<RegularizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 1, vsync: this); // Adjust length to match tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(String time) {
    if (time != 'NA') {
      final DateTime dateTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(dateTime);
    }
    return 'NA';
  }

  String formatDateTimeWithTime(DateTime dateTime) {
    String formattedDateTime =
        DateFormat('d MMM yyyy, hh:mm a').format(dateTime);
    return formattedDateTime;
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
              padding: EdgeInsets.only(top: 10, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Regularization Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
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
                    SizedBox(
                      height: 50,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryBlue,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'Regularize Requests'),
                        ],
                
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchTerm = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by Employee Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * .7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('Regularization')
                                .orderBy('requestDate', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              final requests = snapshot.data?.docs.where((doc) {
                                    var data =
                                        doc.data() as Map<String, dynamic>;
                                    var employeeName = data['employeeName']
                                            ?.toString()
                                            .toLowerCase() ??
                                        '';
                                    return employeeName.contains(_searchTerm);
                                  }).toList() ??
                                  [];

                              if (requests.isEmpty) {
                                return const Center(
                                  child: Text('No records available'),
                                );
                              }

                              return ListView.builder(
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  DateTime requestDateTime =
                                      DateTime.parse(request['requestDate']);
                                  String formattedRequestTime =
                                      formatDateTimeWithTime(requestDateTime);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Stack(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: AppColors
                                                            .primaryBlue
                                                            .withOpacity(0.2),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            DateFormat('dd')
                                                                .format(DateTime
                                                                    .parse(request[
                                                                        'punchDate'])),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    ' EEEE\nMMM yyyy')
                                                                .format(DateTime
                                                                    .parse(request[
                                                                        'punchDate'])),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        10),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          request[
                                                              'employeeName'],
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(request['email']),
                                                        Text(
                                                          'Requested on: $formattedRequestTime',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Text(
                                                                "Comment: ",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  "${request['comment']}",
                                                                  maxLines: 4,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                'Current Clock In:'),
                                                            Text(
                                                              ' ${_formatTime(request['currentClockInTime'] ?? 'NA')}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .primaryBlue),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                'Current Clock Out:'),
                                                            Text(
                                                              ' ${_formatTime(request['currentClockOutTime'] ?? 'NA')}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .primaryBlue),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 40),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                'Requested Clock In:'),
                                                            Text(
                                                              ' ${_formatTime(request['regularizedClockInTime'] ?? 'NA')}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .primaryBlue),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                                'Requested Clock Out:'),
                                                            Text(
                                                              ' ${_formatTime(request['regularizedClockOutTime'] ?? 'NA')}',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .primaryBlue),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Column(
                                                      children: [
                                                        if (!request[
                                                            'isApproved']) ...{
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  _showConfirmationDialog(
                                                                      request
                                                                          .id);
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .primaryBlue,
                                                                ),
                                                                child: const Text(
                                                                    'Approve Request'),
                                                              ),
                                                            ],
                                                          ),
                                                        },
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          request['isApproved']
                                                              ? Colors.green
                                                              : Colors.red,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Text(
                                                      request['isApproved']
                                                          ? 'Approved'
                                                          : 'Pending',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      'Notify To: ${request['notifyTo']}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
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

  void _showConfirmationDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to Approve this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // First get the regularization request data
                final requestDoc = await _firestore
                    .collection('Regularization')
                    .doc(requestId)
                    .get();
                final requestData = requestDoc.data() as Map<String, dynamic>;

                // Format the date for the attendance document
                final punchDate = DateTime.parse(requestData['punchDate']);
                final attendanceDocId =
                    DateFormat('yyyy-MM-dd').format(punchDate);

                // Reference to the attendance document
                final attendanceRef = _firestore
                    .collection('profiles')
                    .doc(requestData['email'])
                    .collection('attendance')
                    .doc(attendanceDocId);

                // Update or create the attendance document
                await attendanceRef.set({
                  'clockInTime': requestData['regularizedClockInTime'],
                  'clockOutTime': requestData['regularizedClockOutTime'],
                  'isRegularize': true,
                }, SetOptions(merge: true));

                // Update the regularization status
                await _firestore
                    .collection('Regularization')
                    .doc(requestId)
                    .update({
                  'isApproved': true,
                });

                Navigator.pop(context);
              } catch (e) {
                log('Error updating attendance: $e');
                // Optionally show an error message to the user
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error updating attendance record'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
