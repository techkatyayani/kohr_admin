import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_room.dart';
import 'edit_room.dart';
import 'room_details_screen.dart';

class MeetingRooms extends StatefulWidget {
  const MeetingRooms({super.key});

  @override
  State<MeetingRooms> createState() => _MeetingRoomsState();
}

class _MeetingRoomsState extends State<MeetingRooms> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatTime(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        DateTime dateTime = timestamp.toDate();
        return DateFormat('hh:mm a').format(dateTime);
      }
      return 'Invalid Time';
    } catch (e) {
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('MeetingRooms')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30, top: 20),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateRoomScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xff09254A)),
                    label: const Text(
                      'Create Room',
                      style: TextStyle(
                        color: Color(0xff09254A),
                        fontFamily: 'Sora',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final room = snapshot.data!.docs[index];
                final data = room.data() as Map<String, dynamic>;

                final availableTimings =
                    data['availableTimings'] as Map<String, dynamic>?;
                final startTime = availableTimings?['startTiming'];
                final endTime = availableTimings?['endTiming'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomDetailsScreen(
                              roomId: room.id,
                              roomData: data,
                            ),
                          ),
                        );
                      },
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12)),
                              child: Image.network(
                                data['roomImage'] ?? '',
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    color: Colors.grey[200],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.meeting_room,
                                            color: Color(0xff09254A), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Room #${data['roomId']}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Color(0xff09254A)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditRoomScreen(
                                                  documentId: room.id,
                                                  roomData: data,
                                                ),
                                              ),
                                            );
                                          },
                                          tooltip: 'Edit Room',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.room,
                                            color: Color(0xff09254A), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          data['roomName'] ?? 'Unknown Room',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.business,
                                            color: Color(0xff09254A), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          data['officeName'] ??
                                              'Unknown Office',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color: Color(0xff09254A), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${formatTime(startTime)} - ${formatTime(endTime)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (data['specifications'] != null)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (data['specifications']
                                                as List)
                                            .map((spec) => Chip(
                                                  label: Text(
                                                    spec.toString(),
                                                    style: const TextStyle(
                                                      color: Color(0xff09254A),
                                                      fontSize: 12,
                                                      fontFamily: 'Sora',
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xff09254A)
                                                          .withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 0),
                                                ))
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
