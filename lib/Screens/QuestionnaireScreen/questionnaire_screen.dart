import 'package:flutter/material.dart';

import '../../NavBar/nav_bar.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _currentStep = 0;
  String? _selectedRole;
  int? _age;
  String? _country;

  // Create a TextEditingController
  final TextEditingController _agecontroller = TextEditingController();
  final TextEditingController _countrycontroller = TextEditingController();

  final List<String> _roles = [
    'Teacher',
    'Student',
    'Working Professional',
    'Lawyer',
    'Doctor',
    'Other'
  ];

  final List<IconData> _roleIcons = [
    Icons.school,
    Icons.book,
    Icons.work,
    Icons.gavel,
    Icons.local_hospital,
    Icons.person
  ];

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildRoleSelection();
      case 1:
        return _buildAgeInput();
      case 2:
        return _buildCountryInput();
      default:
        return Container();
    }
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'What describes you?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          _roles.length,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedRole = _roles[index]),
              icon: Icon(_roleIcons[index],
                  color: _selectedRole == _roles[index]
                      ? Colors.white
                      : Colors.purple),
              label: Text(_roles[index]),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRole == _roles[index]
                    ? Colors.purple.shade600
                    : Colors.white,
                foregroundColor: _selectedRole == _roles[index]
                    ? Colors.white
                    : Colors.purple.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.purple.shade600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'What is your age?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _agecontroller,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter your age',
            prefixIcon: Icon(Icons.cake, color: Colors.purple.shade600),
          ),
          onChanged: (value)  { setState(() => _age = int.tryParse(value));

            },
        ),
        const SizedBox(height: 20),
        const Image(
          image: NetworkImage(
              'https://cdn-icons-png.freepik.com/256/2454/2454297.png?semt=ais_hybrid'),
          height: 200,
        ),
      ],
    );
  }

  Widget _buildCountryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Which country are you from?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _countrycontroller,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter your country',
            prefixIcon: Icon(Icons.public, color: Colors.purple.shade600),
          ),
          onChanged: (value) => setState(() => _country = value),
        ),
        const SizedBox(height: 20),
        const Image(
          image: NetworkImage(
              'https://cdn-icons-png.flaticon.com/512/9746/9746676.png'),
          height: 200,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Get better recommendations"),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(_currentStep),
                ),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Back'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        // Navigate to home screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FluidNavBarDemo()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(_currentStep < 2 ? 'Next' : 'Finish', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
