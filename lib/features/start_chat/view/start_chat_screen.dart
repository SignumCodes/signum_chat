import 'package:flutter/material.dart';

class StartChatScreen extends StatefulWidget {
  const StartChatScreen({super.key});

  @override
  State<StartChatScreen> createState() => _StartChatScreenState();
}

class _StartChatScreenState extends State<StartChatScreen> {
  int _selectedGender = 1; // Default to "Both"
  final List<String> interests = ["Coding", "Gaming", "Anime"];
  final List<Map<String, dynamic>> genderOptions = [
    {"label": "Male", "icon": Icons.male, "color": Colors.purple},
    {"label": "Both", "icon": Icons.people, "color": Colors.purple},
    {"label": "Female", "icon": Icons.female, "color": Colors.purple}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: _buildAppBar(),
      body: Stack(
        children: [
          /// Top content (logo + social icons)
          Column(
            children: [
              _buildLogo(),
              _buildSocialIcons(),
            ],
          ),

          /// Bottom rounded section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.black, // Change as needed
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInterestsSection(),
                  _buildGenderFilter(),
                  _buildStartChatButton(),
                  _buildChatRules(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar Widget
  AppBar _buildAppBar() {
    return AppBar(

      title: const Text("New Chat"),
      actions: const [
        Icon(Icons.person, color: Colors.white),
        SizedBox(width: 15),
        Icon(Icons.notifications, color: Colors.white),
        SizedBox(width: 15),
        Icon(Icons.access_time, color: Colors.white),
        SizedBox(width: 15),
      ],
    );
  }

  // Logo Widget
  Widget _buildLogo() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.purple,
          child: Icon(Icons.masks, color: Colors.white, size: 50),
        ),
        SizedBox(height: 10),
        Text(
          "SignumChat.com",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  // Social Icons Section
  Widget _buildSocialIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 30, color: Colors.white),
        SizedBox(width: 20),
        Icon(Icons.language, size: 30, color: Colors.white),
        SizedBox(width: 20),
        Icon(Icons.music_note, size: 30, color: Colors.white),
      ],
    );
  }

  // Interests Section
  Widget _buildInterestsSection() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal:15,vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Interests (ON)", style: TextStyle(fontSize: 16, color: Colors.green)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(interest, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Text("You have no interests. Click to add some.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Gender Filter Section
  Widget _buildGenderFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gender Filter:", style: TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: genderOptions.map((gender) {
              int index = genderOptions.indexOf(gender);
              return _genderButton(index, gender["label"], gender["icon"], gender["color"]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Gender Selection Button Widget
  Widget _genderButton(int index, String text, IconData icon, Color color) {
    bool isSelected = _selectedGender == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Start Chat Button
  Widget _buildStartChatButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text("Start Text Chat", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  // Chat Rules Text
  Widget _buildChatRules() {
    return TextButton(
      onPressed: () {},
      child: const Text("Be respectful and follow our chat rules", style: TextStyle(color: Colors.blue)),
    );
  }
}
