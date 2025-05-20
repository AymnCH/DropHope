import 'package:drophope/main.dart';
import 'package:drophope/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class MessagesScreen extends StatefulWidget {
  final String? startNewConversationWith;
  final Function(Widget) navigateToScreen;

  const MessagesScreen({
    super.key,
    this.startNewConversationWith,
    this.navigateToScreen = _defaultNavigate,
  });

  static void _defaultNavigate(Widget screen) {}

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _conversations = [];

  List<Map<String, dynamic>> get conversations => _conversations;

  @override
  void initState() {
    super.initState();
    if (widget.startNewConversationWith != null) {
      _handleNewConversation(widget.startNewConversationWith!);
    }
  }

  void startNewConversation(String username) {
    _handleNewConversation(username);
  }

  void _handleNewConversation(String username) {
    setState(() {
      final existingConversationIndex = _conversations.indexWhere(
        (conv) => conv['username'] == username,
      );

      if (existingConversationIndex == -1) {
        _conversations.add({
          "username": username,
          "lastMessage": "Hello! I'm interested in your item.",
          "time": "Just now",
          "unread": 0,
          "messages": [
            {
              "sender": "You",
              "text": "Hello! I'm interested in your item.",
              "time": "Just now",
            },
          ],
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.navigateToScreen(
            ChatScreen(
              username: username,
              initialMessages: List<Map<String, String>>.from(
                _conversations.last['messages'],
              ),
              onSendMessage: (newMessage) {
                setState(() {
                  _conversations.last['messages'].add({
                    "sender": "You",
                    "text": newMessage,
                    "time": "Just now",
                  });
                  _conversations.last['lastMessage'] = newMessage;
                  _conversations.last['time'] = "Just now";
                });
              },
            ),
          );
        });
      } else {
        final conversation = _conversations[existingConversationIndex];
        widget.navigateToScreen(
          ChatScreen(
            username: username,
            initialMessages: List<Map<String, String>>.from(
              conversation['messages'],
            ),
            onSendMessage: (newMessage) {
              setState(() {
                conversation['messages'].add({
                  "sender": "You",
                  "text": newMessage,
                  "time": "Just now",
                });
                conversation['lastMessage'] = newMessage;
                conversation['time'] = "Just now";
              });
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = userStateKey.currentState;
    if (userState == null) {
      return const Center(child: Text("Error loading user data"));
    }

    final username = userState.username;
    final accountType = userState.accountType;
    final profilePicture = userState.profilePicture;

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      profilePicture != null
                          ? FileImage(File(profilePicture))
                          : null,
                  child:
                      profilePicture == null
                          ? const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.black,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  accountType == "PRO"
                                      ? const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 62, 145, 227),
                                          Color.fromARGB(255, 26, 215, 200),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : null,
                              color:
                                  accountType == "PRO" ? null : Colors.blueGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              accountType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          widget.navigateToScreen(const ProfileScreen());
                        },
                        child: const Text(
                          "View Profile",
                          style: TextStyle(
                            color: Color.fromRGBO(16, 90, 146, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: EdgeInsets.only(right: 300),
              child: Text(
                "Chat",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Expanded(
            child:
                _conversations.isEmpty
                    ? const Center(
                      child: Text(
                        "No messages to show",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            conversation['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(conversation['lastMessage']),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                conversation['time'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (conversation['unread'] > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.indigo,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    conversation['unread'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            widget.navigateToScreen(
                              ChatScreen(
                                username: conversation['username'],
                                initialMessages: List<Map<String, String>>.from(
                                  conversation['messages'],
                                ),
                                onSendMessage: (newMessage) {
                                  setState(() {
                                    conversation['messages'].add({
                                      "sender": "You",
                                      "text": newMessage,
                                      "time": "Just now",
                                    });
                                    conversation['lastMessage'] = newMessage;
                                    conversation['time'] = "Just now";
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String username;
  final List<Map<String, String>> initialMessages;
  final Function(String) onSendMessage;

  const ChatScreen({
    super.key,
    required this.username,
    required this.initialMessages,
    required this.onSendMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.initialMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "You", "text": message, "time": "Just now"});
      });
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.username)),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message['sender'] == "You";
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.indigo : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text']!,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['time']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        () => _handleSendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: Colors.indigo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
