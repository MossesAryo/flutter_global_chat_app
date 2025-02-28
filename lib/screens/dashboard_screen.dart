import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globalchat/providers/userProvider.dart';
import 'package:globalchat/screens/chatroom_screen.dart';
import 'package:globalchat/screens/profile_screen.dart';
import 'package:globalchat/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  var user = FirebaseAuth.instance.currentUser;
  var db = FirebaseFirestore.instance;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  List<Map<String, dynamic>> chatroomsList = [];
  List<String> chatroomsIds = [];
  bool isLoading = true;

  // For search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredChatroomsList = [];
  List<String> filteredChatroomsIds = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    getChatrooms();

    _searchController.addListener(() {
      filterChatrooms(_searchController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void getChatrooms() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dataSnapshot = await db.collection("chatrooms").get();

      chatroomsList.clear();
      chatroomsIds.clear();

      for (var singleChatroomData in dataSnapshot.docs) {
        chatroomsList.add(singleChatroomData.data());
        chatroomsIds.add(singleChatroomData.id.toString());
      }

      filteredChatroomsList = List.from(chatroomsList);
      filteredChatroomsIds = List.from(chatroomsIds);
    } catch (e) {
      print("Error fetching chatrooms: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterChatrooms(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredChatroomsList = List.from(chatroomsList);
        filteredChatroomsIds = List.from(chatroomsIds);
        isSearching = false;
      });
      return;
    }

    final List<Map<String, dynamic>> tempList = [];
    final List<String> tempIds = [];

    for (int i = 0; i < chatroomsList.length; i++) {
      final chatroom = chatroomsList[i];
      final id = chatroomsIds[i];

      if ((chatroom["chatroom_name"] ?? "")
          .toLowerCase()
          .contains(query.toLowerCase())) {
        tempList.add(chatroom);
        tempIds.add(id);
      }
    }

    setState(() {
      filteredChatroomsList = tempList;
      filteredChatroomsIds = tempIds;
      isSearching = true;
    });
  }

  // Generate a gradient color based on the chatroom name
  List<Color> getChatroomColors(String name) {
    if (name.isEmpty) return [Colors.blue, Colors.blueAccent];

    final int hash = name.hashCode;

    // Create different gradient combinations based on the hash
    switch (hash % 5) {
      case 0:
        return [Colors.blue[700]!, Colors.blue[300]!];
      case 1:
        return [Colors.purple[700]!, Colors.purple[300]!];
      case 2:
        return [Colors.teal[700]!, Colors.teal[300]!];
      case 3:
        return [
          const Color.fromARGB(255, 56, 39, 152)!,
          const Color.fromARGB(255, 35, 84, 133)!
        ];
      case 4:
        return [Colors.deepOrange[700]!, Colors.deepOrange[300]!];
      default:
        return [Colors.blue[700]!, Colors.blue[300]!];
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldkey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search chatrooms...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: TextStyle(fontSize: 18),
              )
            : const Text(
                'Global Chat',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
        leading: InkWell(
          onTap: () {
            scaffoldkey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'profile-avatar',
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  userProvider.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _searchController.clear();
                  isSearching = false;
                  filteredChatroomsList = List.from(chatroomsList);
                  filteredChatroomsIds = List.from(chatroomsIds);
                } else {
                  isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
            onPressed: getChatrooms,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'profile-avatar-drawer',
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          userProvider.userName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userProvider.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userProvider.userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.people, color: Colors.blue),
                title: Text(
                  "Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProfileScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  await Future.delayed(
                      Duration(milliseconds: 800)); // For smoothness
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pop(); // Close dialog

                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SplashScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                    (route) => false,
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.grey),
                title: Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Global Chat",
                    applicationVersion: "1.0.0",
                    applicationIcon: FlutterLogo(size: 50),
                    children: [
                      Text(
                          "A modern chatroom application built with Flutter and Firebase."),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : filteredChatroomsList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSearching
                            ? Icons.search_off
                            : Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        isSearching
                            ? "No chatrooms match your search"
                            : "No chatrooms available",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredChatroomsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String chatroomName =
                          filteredChatroomsList[index]["chatroom_name"] ?? "";
                      String chatroomDescription = filteredChatroomsList[index]
                              ["description"] ??
                          "Join this chatroom";
                      List<Color> gradientColors =
                          getChatroomColors(chatroomName);

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          ChatroomScreen(
                                        chatroomName: chatroomName,
                                        chatroomId: filteredChatroomsIds[index],
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            gradientColors[0].withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              chatroomName.isNotEmpty
                                                  ? chatroomName[0]
                                                      .toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                chatroomName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                chatroomDescription,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create chatroom dialog (implementation not included)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Coming Soon"),
              content:
                  Text("Create new chatroom feature will be available soon!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }
}
