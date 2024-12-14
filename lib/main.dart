import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SheSecure',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  void _navigateToFeatures(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafetyHomeScreen(personalInfo: _formData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.pink[50], // Mild pink background
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png', 
                  height: 150,
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField('Name', 'Name'),
                      _buildTextField('Email', 'Email'),
                      _buildTextField('Phone', 'Phone'),
                      _buildTextField('Parent Name', 'Parent Name'),
                      _buildTextField('Emergency Contact', 'Emergency Contact'),
                      _buildTextField('Address', 'Address'),
                      _buildTextField('Blood Group', 'Blood Group'),
                      _buildTextField('Health Condition', 'Health Condition'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _navigateToFeatures(context);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(String label, String key) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: (value) => _formData[key] = value!,
    );
  }
}

class SafetyHomeScreen extends StatefulWidget {
  final Map<String, String> personalInfo;

  const SafetyHomeScreen({super.key, required this.personalInfo});

  @override
  State<SafetyHomeScreen> createState() => _SafetyHomeScreenState();
}

class _SafetyHomeScreenState extends State<SafetyHomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;

  void sendSOS() async {
    final String emergencyNumber =
        widget.personalInfo['Emergency Contact'] ?? '';
    const String message = 'I need help! Please reach me as soon as possible.';
    final Uri smsUri = Uri(
      scheme: 'smsto',
      path: emergencyNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not send SMS');
    }
  }

  void callEmergencyContact() async {
    final String emergencyNumber =
        widget.personalInfo['Emergency Contact'] ?? '';
    final String url = 'tel:$emergencyNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not place the call');
    }
  }

  void dialPolice() async {
    const String url = 'tel:100';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not place the call to police');
    }
  }

  void playAlarm() async {
    if (!_isAlarmPlaying) {
      await _audioPlayer.play(AssetSource('alarm.mp3'));
      setState(() {
        _isAlarmPlaying = true;
      });
    }
  }

  void stopAlarm() async {
    await _audioPlayer.stop();
    setState(() {
      _isAlarmPlaying = false;
    });
  }

  void fakeCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Incoming call from Emergency Contact!'),
        actions: [
          TextButton(
            child: const Text('Answer'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Decline'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void showSafetyTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Tips'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('- Be aware of surroundings.'),
            Text('- Trust your instincts; avoid risky situations.'),
            Text('- Keep your phone fully charged.'),
            Text('- Share your location with trusted contacts.'),
            Text('- Avoid isolated areas, especially at night.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showPersonalInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.personalInfo.entries
                .map((entry) => Text('${entry.key}: ${entry.value}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 150,
            color: Colors.pink[100],
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(20),
              children: [
                _buildActionButton('Dial 100', Icons.local_police_outlined,
                    Colors.blue, dialPolice),
                _buildActionButton(
                    'SOS Alert', Icons.sms_outlined, Colors.red, sendSOS),
                _buildActionButton('Emergency Call', Icons.phone_outlined,
                    Colors.pink, callEmergencyContact),
                _buildActionButton(
                  _isAlarmPlaying ? 'Stop Alarm' : 'Play Alarm',
                  Icons.volume_up_outlined,
                  Colors.orange,
                  _isAlarmPlaying ? stopAlarm : playAlarm,
                ),
                _buildActionButton(
                    'Safety Tips',
                    Icons.tips_and_updates_outlined,
                    Colors.green,
                    showSafetyTips),
                _buildActionButton(
                    'Fake Call', Icons.call_outlined, Colors.purple, fakeCall),
                _buildActionButton('Personal Info', Icons.person_outlined,
                    Colors.teal, showPersonalInfo),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.pink[100],
            padding: const EdgeInsets.all(15),
            child: const Text(
              '"Ensuring Safety for Every Woman"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 80, // Smaller width for the rectangle box
      height: 100, // Smaller height for the rectangle box
      padding: const EdgeInsets.all(4), // Small padding around the button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          elevation: 3, // Button shadow
          padding: EdgeInsets.zero, // Remove inner padding
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60, // Larger icon size
              color: color,
            ),
            const SizedBox(height: 4), // Small spacing between icon and text
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, // Smaller text size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
