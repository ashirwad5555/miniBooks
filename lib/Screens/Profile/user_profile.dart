import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../Subscription/subscription_page.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  File? _profileImage;

  // Sample admin data
  Map<String, dynamic> adminData = {
    'employeeId': 'ADMIN001',
    'name': 'Ashirwad Katkamwar',
    'email': 'ashirwadkatkamwar@gmail.com',
    'contactNo': '8308112825',
  };

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController.text = adminData['name'];
    _emailController.text = adminData['email'];
    _contactController.text = adminData['contactNo'];
  }

  // Add this method to handle image picking
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery, // Change to ImageSource.camera for camera
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage =
            File(pickedImage.path); // Use this image in your CircleAvatar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save logic here
                  if (_formKey.currentState!.validate()) {
                    _saveProfile();
                  }
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      backgroundColor: Color(0xF1FFD8BB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: _profileImage != null
                            ? FileImage(
                                _profileImage!) // Display the selected image
                            : NetworkImage(
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_3PTTNMSlcllsWjg0uRZs-JUJfS2LmZAwwA&s"),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: () {
                                // Implement image picking logic
                                _pickImage();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                _buildInfoTile(
                    'Employee ID', adminData['employeeId'], Icons.badge,
                    editable: false),
                _buildInfoTile('Name', adminData['name'], Icons.person,
                    controller: _nameController),
                _buildInfoTile('Email', adminData['email'], Icons.email,
                    controller: _emailController),
                _buildInfoTile(
                    'Contact No', adminData['contactNo'], Icons.phone,
                    controller: _contactController),
                const SizedBox(height: 20,),

                Container(
                  width: double.infinity,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SubscriptionPage()));
                    },
                    backgroundColor: Colors.deepPurple,  // Change button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20), // Adjust padding around the text
                      child: Text(
                        "Be a premium user",
                        style: TextStyle(
                          fontSize: 16, // Text size
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold, // Text weight
                        ),
                      ),
                    ),
                  ),

                ),

                SizedBox(height: 100,)

              ],
            ),
          ),

        ),

      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon,
      {bool editable = true, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(icon, color: Colors.orangeAccent),
              title: _isEditing && editable
                  ? TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter $label',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        return null;
                      },
                    )
                  : Text(value, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    // Update adminData with new values
    adminData['name'] = _nameController.text;
    adminData['email'] = _emailController.text;
    adminData['contactNo'] = _contactController.text;

    // Show a snackbar to confirm save
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }
}
