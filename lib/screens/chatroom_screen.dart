import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:globalchat/providers/userProvider.dart';
import 'package:provider/provider.dart';

class ChatroomScreen extends StatefulWidget {
  final String chatroomName;
  final String chatroomId;

  const ChatroomScreen(
      {super.key, required this.chatroomName, required this.chatroomId});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  final TextEditingController messageText = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final db = FirebaseFirestore.instance;

  Future<void> sendMessage() async {
    if (messageText.text.isEmpty) {
      return;
    }

    final String currentUserId =
        Provider.of<UserProvider>(context, listen: false).userId;
    final String currentUserName =
        Provider.of<UserProvider>(context, listen: false).userName;

    Map<String, dynamic> messageToSend = {
      "text": messageText.text,
      "sender_name": currentUserName,
      "sender_id": currentUserId,
      "chatroom_id": widget.chatroomId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    messageText.clear();

    try {
      await db.collection('messages').add(messageToSend);
    } catch (e) {
      print(e);
    }
  }

  Widget messageBubble({
    required String senderName,
    required String text,
    required String senderId,
    Timestamp? timestamp,
  }) {
    final bool isMe =
        senderId == Provider.of<UserProvider>(context, listen: false).userId;
    final time = timestamp != null
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
        : "";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.chatroomName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[50], // Very light grey background
                child: StreamBuilder(
                    stream: db
                        .collection("messages")
                        .where("chatroom_id", isEqualTo: widget.chatroomId)
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      var allMessages = snapshot.data?.docs ?? [];

                      return allMessages.isEmpty
                          ? Center(
                              child: Text(
                                "Start a conversation!",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              itemCount: allMessages.length,
                              itemBuilder: (BuildContext context, int index) {
                                final message = allMessages[index];
                                return messageBubble(
                                  senderName: message["sender_name"],
                                  text: message["text"],
                                  senderId: message["sender_id"],
                                  timestamp: message["timestamp"],
                                );
                              });
                    }),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageText,
                      decoration: InputDecoration(
                        hintText: "Write Message Here...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageText.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
