// import 'dart:io';
// import 'dart:typed_data'; // Used to store image bytes for web
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:medisafe/utils/image_picker_helper.dart';

// //import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_login_screen.dart';
// import 'package:medisafe/utils/web_image_picker.dart';

// class DoctorRegistrationScreen extends ConsumerStatefulWidget {
//   const DoctorRegistrationScreen({super.key});

//   @override
//   _DoctorRegistrationScreenState createState() =>
//       _DoctorRegistrationScreenState();
// }

// class _DoctorRegistrationScreenState
//     extends ConsumerState<DoctorRegistrationScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _hospitalController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _positionController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   final TextEditingController _scheduleController = TextEditingController();

//   // Dropdown & Gender
//   String _selectedGender = 'Male';
//   DateTime? _selectedDate;
//   String? _selectedCategory;

//   // Image variables for Mobile & Web
//   File? _profileImage; // Used on mobile
//   Uint8List? _webImage; // Used on web

//   // Other
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   bool _isLoading = false;

//   // Doctor Categories
//   final List<String> _categories = [
//     'Cardiologist',
//     'Neurologist',
//     'General',
//     'Medicine'
//   ];

//   // ------------------------------------------------------
//   // PICK IMAGE (Handles both mobile & web)
//   // ------------------------------------------------------
//   Future<void> _pickImage() async {
//     final result = await (kIsWeb ? pickImageWeb() : pickImageMobile());

//     setState(() {
//       if (kIsWeb) {
//         _webImage = result['bytes'];
//         _profileImage = null;
//       } else {
//         _profileImage = result['file'];
//         _webImage = null;
//       }
//     });
//   }

//   // ------------------------------------------------------
//   // REGISTER DOCTOR
//   // ------------------------------------------------------
//   Future<void> _registerDoctor() async {
//     // Validate form & image
//     if (!_formKey.currentState!.validate() ||
//         (_profileImage == null && _webImage == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please complete the form and select an image.'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // 1. Create User in Firebase Authentication
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       final userId = userCredential.user!.uid;

//       // 2. Upload Image to Firebase Storage
//       final storageRef = _storage.ref().child('doctor_profiles/$userId.jpg');
//       UploadTask uploadTask;

//       if (kIsWeb) {
//         // WEB: Upload bytes
//         uploadTask = storageRef.putData(
//           _webImage!,
//           SettableMetadata(contentType: 'image/jpeg'),
//         );
//       } else {
//         // MOBILE: Upload file
//         uploadTask = storageRef.putFile(_profileImage!);
//       }

//       final storageSnapshot = await uploadTask.whenComplete(() => null);
//       final profileImageUrl = await storageSnapshot.ref.getDownloadURL();

//       // 3. Store Doctor Info in Firestore
//       await _firestore.collection('doctors').doc(userId).set({
//         'doctor_name': _nameController.text.trim(),
//         'clinic_name': _hospitalController.text.trim(),
//         'email': _emailController.text.trim(),
//         'contact_number': _contactController.text.trim(),
//         'date_of_birth':
//             _selectedDate != null ? _selectedDate!.toIso8601String() : '',
//         'qualifications': _positionController.text.trim(),
//         'gender': _selectedGender,
//         'experience': int.parse(_experienceController.text.trim()),
//         'specialization': _selectedCategory,
//         'available_time': _scheduleController.text.trim(),
//         'about': _bioController.text.trim(),
//         'profile_image_url': profileImageUrl,
//       });

//       // 4. Notify Success and Redirect
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Doctor registered successfully!')),
//       );

//       // Navigate to the Login Screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : LayoutBuilder(
//                 builder: (context, constraints) {
//                   // Simple responsive approach: limit max width on larger screens
//                   final maxWidth =
//                       constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

//                   return SingleChildScrollView(
//                     child: Center(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(maxWidth: maxWidth),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const SizedBox(height: 50),
//                               const Text(
//                                 'Doctor Registration',
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),

//                               // Profile Image
//                               _buildProfileImageSelector(),
//                               const SizedBox(height: 10),

//                               // Doctor Full Name
//                               _buildTextField(
//                                 controller: _nameController,
//                                 label: 'Doctor Full Name',
//                                 icon: Icons.person,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your full name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Hospital or Clinic
//                               _buildTextField(
//                                 controller: _hospitalController,
//                                 label: 'Hospital or Clinic Name & Address',
//                                 icon: Icons.local_hospital,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your hospital or clinic name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Doctor Email
//                               _buildTextField(
//                                 controller: _emailController,
//                                 label: 'Doctor Email',
//                                 icon: Icons.email,
//                                 keyboardType: TextInputType.emailAddress,
//                                 validator: (value) => value!.contains('@')
//                                     ? null
//                                     : 'Please enter a valid email',
//                               ),
//                               const SizedBox(height: 8),

//                               // Contact Number
//                               _buildTextField(
//                                 controller: _contactController,
//                                 label: 'Contact Number',
//                                 icon: Icons.phone,
//                                 keyboardType: TextInputType.phone,
//                                 validator: (value) => value!.length >= 10
//                                     ? null
//                                     : 'Enter valid phone number',
//                               ),
//                               const SizedBox(height: 8),

//                               // Date of Birth
//                               _buildDateOfBirthPicker(context),
//                               const SizedBox(height: 8),

//                               // Position (Degree)
//                               _buildTextField(
//                                 controller: _positionController,
//                                 label: 'Position (Degree)',
//                                 icon: Icons.badge,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your position'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Experience (Years)
//                               _buildTextField(
//                                 controller: _experienceController,
//                                 label: 'Experience (Years)',
//                                 icon: Icons.timeline,
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter years of experience'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Category Dropdown
//                               _buildCategoryDropdown(),
//                               const SizedBox(height: 8),

//                               // Consultancy Schedule
//                               _buildTextField(
//                                 controller: _scheduleController,
//                                 label: 'Consultancy Schedule',
//                                 icon: Icons.schedule,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your consultancy schedule'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Bio
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: TextFormField(
//                                   controller: _bioController,
//                                   maxLines: 3,
//                                   decoration: InputDecoration(
//                                     labelText: 'Bio',
//                                     prefixIcon: const Icon(Icons.description),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                   ),
//                                   validator: (value) => value!.isEmpty
//                                       ? 'Please enter a bio'
//                                       : null,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),

//                               // Gender
//                               _buildGenderSelection(),
//                               const SizedBox(height: 8),

//                               // Password
//                               _buildTextField(
//                                 controller: _passwordController,
//                                 label: 'Password',
//                                 icon: Icons.lock,
//                                 obscureText: true,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your password'
//                                     : null,
//                               ),
//                               const SizedBox(height: 8),

//                               // Register Button
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 100,
//                                     vertical: 15,
//                                   ),
//                                   shape: const StadiumBorder(),
//                                   backgroundColor: Colors.purpleAccent,
//                                 ),
//                                 onPressed: () {
//                                   if (_formKey.currentState!.validate()) {
//                                     _registerDoctor().then((_) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content:
//                                               Text('Registration successful'),
//                                         ),
//                                       );
//                                       Navigator.of(context).pop();
//                                     }).catchError((error) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                               'Registration failed: $error'),
//                                         ),
//                                       );
//                                     });
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           'Please fill in all fields and select an image.',
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 child: const Text('Register'),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }

//   Widget _buildProfileImageSelector() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: CircleAvatar(
//         radius: 50,
//         backgroundColor: Colors.grey[200],
//         // For web: display MemoryImage if _webImage is not null
//         // For mobile: display FileImage if _profileImage is not null
//         backgroundImage: kIsWeb
//             ? (_webImage != null ? MemoryImage(_webImage!) : null)
//             : (_profileImage != null ? FileImage(_profileImage!) : null),
//         child:
//             (kIsWeb && _webImage == null) || (!kIsWeb && _profileImage == null)
//                 ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
//                 : null,
//       ),
//     );
//   }

//   // Category Dropdown
//   Widget _buildCategoryDropdown() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           labelText: 'Category',
//           prefixIcon: const Icon(Icons.category),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         items: _categories.map((category) {
//           return DropdownMenuItem<String>(
//             value: category,
//             child: Text(category),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             _selectedCategory = value;
//           });
//         },
//         validator: (value) => value == null ? 'Please select a category' : null,
//       ),
//     );
//   }

//   // Gender Selection
//   Widget _buildGenderSelection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           const Text('Gender:'),
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'Male',
//                 groupValue: _selectedGender,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedGender = value!;
//                   });
//                 },
//               ),
//               const Text('Male'),
//             ],
//           ),
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'Female',
//                 groupValue: _selectedGender,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedGender = value!;
//                   });
//                 },
//               ),
//               const Text('Female'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Date of Birth Picker
//   Widget _buildDateOfBirthPicker(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         final pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime(2000),
//           firstDate: DateTime(1900),
//           lastDate: DateTime.now(),
//         );
//         if (pickedDate != null) {
//           setState(() {
//             _selectedDate = pickedDate;
//           });
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: 'Date of Birth',
//             prefixIcon: const Icon(Icons.calendar_today),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//           child: Text(
//             _selectedDate == null
//                 ? 'Select Date'
//                 : _selectedDate!.toLocal().toString().split(' ')[0],
//           ),
//         ),
//       ),
//     );
//   }

//   // Reusable Text Field
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     required String? Function(String?) validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         obscureText: obscureText,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';

import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_login_screen.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  _DoctorRegistrationScreenState createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  String? _selectedCategory;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  final List<String> _categories = [
    'Cardiologist',
    'Neurologist',
    'General',
    'Medicine'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate() || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the form and select an image.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userId = userCredential.user!.uid;

      final storageRef = _storage.ref().child('doctor_profiles/$userId.jpg');
      final uploadTask = storageRef.putFile(_profileImage!);
      final storageSnapshot = await uploadTask.whenComplete(() => null);
      final profileImageUrl = await storageSnapshot.ref.getDownloadURL();

      await _firestore.collection('doctors').doc(userId).set({
        'doctor_name': _nameController.text.trim(),
        'clinic_name': _hospitalController.text.trim(),
        'email': _emailController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'date_of_birth':
            _selectedDate != null ? _selectedDate!.toIso8601String() : '',
        'qualifications': _positionController.text.trim(),
        'gender': _selectedGender,
        'experience': int.parse(_experienceController.text.trim()),
        'specialization': _selectedCategory,
        'available_time': _scheduleController.text.trim(),
        'about': _bioController.text.trim(),
        'profile_image_url': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor registered successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                      constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              const Pacifico(
                                  text: "Doctor Registration", size: 30.0),
                              const SizedBox(height: 15),
                              _buildProfileImageSelector(),
                              const SizedBox(height: 10),
                              _buildTextField(_nameController,
                                  'Doctor Full Name', Icons.person,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your full name'
                                      : null),
                              const SizedBox(height: 8),
                              _buildTextField(
                                  _hospitalController,
                                  'Hospital or Clinic Name & Address',
                                  Icons.local_hospital,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your hospital or clinic name'
                                      : null),
                              const SizedBox(height: 8),
                              _buildTextField(
                                  _emailController, 'Doctor Email', Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.contains('@')
                                      ? null
                                      : 'Please enter a valid email'),
                              const SizedBox(height: 8),
                              _buildTextField(_contactController,
                                  'Contact Number', Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value!.length >= 10
                                      ? null
                                      : 'Enter valid phone number'),
                              const SizedBox(height: 8),
                              _buildDateOfBirthPicker(context),
                              const SizedBox(height: 8),
                              _buildTextField(_positionController,
                                  'Position (Degree)', Icons.badge,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your position'
                                      : null),
                              const SizedBox(height: 8),
                              _buildTextField(_experienceController,
                                  'Experience (Years)', Icons.timeline,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter years of experience'
                                      : null),
                              const SizedBox(height: 8),
                              _buildCategoryDropdown(),
                              const SizedBox(height: 8),
                              _buildTextField(_scheduleController,
                                  'Consultancy Schedule', Icons.schedule,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your consultancy schedule'
                                      : null),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  controller: _bioController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Bio',
                                    prefixIcon: const Icon(Icons.description),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter a bio'
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildGenderSelection(),
                              const SizedBox(height: 8),
                              _buildTextField(
                                  _passwordController, 'Password', Icons.lock,
                                  obscureText: true,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your password'
                                      : null),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: AppColors.buttonColor,
                                ),
                                onPressed: _registerDoctor,
                                child: const Pacifico(
                                  text: "Register",
                                  size: 20.0,
                                  color: AppColors.appColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProfileImageSelector() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: _categories
            .map((category) =>
                DropdownMenuItem(value: category, child: Text(category)))
            .toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Gender:'),
          Row(
            children: [
              Radio<String>(
                fillColor: WidgetStateProperty.all(Colors.black),
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const Text('Male'),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                fillColor: WidgetStateProperty.all(Colors.black),
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const Text('Female'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthPicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(_selectedDate == null
              ? 'Select Date'
              : _selectedDate!.toLocal().toString().split(' ')[0]),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.buttonColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.buttonColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
