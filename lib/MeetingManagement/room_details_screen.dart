import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomId;
  final Map<String, dynamic> roomData;

  const RoomDetailsScreen({
    super.key,
    required this.roomId,
    required this.roomData,
  });

  @override
  Widget build(BuildContext context) {
    final String correctRoomId = roomData['roomId'];

    print('Current roomId: $correctRoomId');
    print('Current roomData: $roomData');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Meeting Room ${roomData['roomName']}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff09254A),
      ),
      body: Column(
        children: [
          _buildRoomInfoCard(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('MeetingBookings')
                  .where('roomId', isEqualTo: correctRoomId)
                  .snapshots(),
              builder: (context, snapshot) {
                print('==================== DEBUG INFO ====================');
                print('Room Details:');
                print('- Room ID being queried: "$correctRoomId"');
                print('- Room Name from roomData: "${roomData['roomName']}"');
                print('\nFirestore Connection:');
                print('- Connection State: ${snapshot.connectionState}');
                print('- Has Error: ${snapshot.hasError}');
                print('- Has Data: ${snapshot.hasData}');

                if (snapshot.hasData) {
                  final meetings = snapshot.data?.docs ?? [];
                  print('\nMeetings Data:');
                  print('- Number of meetings found: ${meetings.length}');
                  meetings.forEach((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    print('\nMeeting Details:');
                    print('- Meeting ID: ${doc.id}');
                    print('- Room ID in meeting: "${data['roomId']}"');
                    print('- Meeting Title: ${data['meetingTitle']}');
                  });
                }
                print('================================================');

                if (snapshot.hasError) {
                  print('Error in StreamBuilder: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meetings = snapshot.data?.docs ?? [];

                print('Is meetings empty? ${meetings.isEmpty}');

                if (meetings.isEmpty) {
                  return const Center(
                    child: Text('No meetings scheduled for this room'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meetingData =
                        meetings[index].data() as Map<String, dynamic>;
                    print(
                        'Building card for meeting: ${meetingData['meetingTitle']}');
                    return _buildMeetingCard(meetingData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.meeting_room, size: 28, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  roomData['roomName'] ?? 'Unknown Room',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.business, roomData['officeName'] ?? 'Unknown Office'),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Available: ${_formatTime(roomData['availableTimings']?['startTiming'])} - '
              '${_formatTime(roomData['availableTimings']?['endTiming'])}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    final List<Map<String, dynamic>> coHosts =
        List<Map<String, dynamic>>.from(meeting['coHosts'] ?? []);
    final List<Map<String, dynamic>> members =
        List<Map<String, dynamic>>.from(meeting['members'] ?? []);
    final bool isEnded = meeting['ended'] ?? false;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isEnded ? Colors.grey.shade50 : Colors.orange.shade50,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orange,
                      child: Text(
                        (meeting['hostName'] ?? '?')[0].toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting['meetingTitle'] ?? 'Untitled Meeting',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${meeting['hostName']} • ${meeting['department'] ?? 'No Department'} • ${meeting['channel'] ?? 'No Channel'}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isEnded ? 'Ended' : 'Scheduled',
                        style: TextStyle(
                          color: isEnded ? Colors.grey : Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(meeting['timings']['startTiming'])} - ${_formatTime(meeting['timings']['endTiming'])}',
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(meeting['meetingDateTime']),
                      style: TextStyle(color: Colors.grey[800], fontSize: 12),
                    ),
                  ],
                ),
                if (coHosts.isNotEmpty || members.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (coHosts.isNotEmpty) ...[
                        Text('Co-Hosts:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 4,
                          runSpacing: 0,
                          children: coHosts
                              .map((coHost) => Chip(
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    label: Text(coHost['name'],
                                        style: TextStyle(fontSize: 11)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: Colors.grey[200],
                                  ))
                              .toList(),
                        ),
                      ],
                      if (members.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Members:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 4,
                          runSpacing: 0,
                          children: members
                              .map((member) => Chip(
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          member['name'],
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                member['status']),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            member['status'] ?? 'pending',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: member['isAvailable']
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('hh:mm a').format(timestamp.toDate());
      }
      return 'Invalid Time';
    } catch (e) {
      return 'Invalid Time';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('dd MMM yyyy').format(timestamp.toDate());
      }
      return 'Invalid Date';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
