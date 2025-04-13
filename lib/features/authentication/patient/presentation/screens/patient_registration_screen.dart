// import 'dart:typed_data'; // Used to store image bytes for web
// import 'dart:io' show File; // Only used on mobile
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';
// import 'package:medisafe/utils/mobile_image_picker.dart';
// import 'package:medisafe/utils/web_image_picker.dart';

// class PatientRegistrationScreen extends ConsumerStatefulWidget {
//   const PatientRegistrationScreen({super.key});

//   @override
//   ConsumerState<PatientRegistrationScreen> createState() =>
//       _PatientRegistrationScreenState();
// }

// class _PatientRegistrationScreenState
//     extends ConsumerState<PatientRegistrationScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // Gender, DOB, Age
//   String _selectedGender = 'Male';
//   DateTime? _selectedDate;
//   int? _age;

//   // For mobile (picked file) and for web (image bytes)
//   File? _profileImage; // Used on mobile
//   Uint8List? _webImage; // Used on web

//   final ImagePicker _picker = ImagePicker();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   bool _isLoading = false;

//   // -----------------------------
//   // PICK IMAGE
//   // -----------------------------
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

//   // -----------------------------
//   // CALCULATE AGE
//   // -----------------------------
//   int _calculateAge(DateTime birthDate) {
//     final today = DateTime.now();
//     int age = today.year - birthDate.year;
//     if (today.month < birthDate.month ||
//         (today.month == birthDate.month && today.day < birthDate.day)) {
//       age--;
//     }
//     return age;
//   }

//   // -----------------------------
//   // REGISTER PATIENT
//   // -----------------------------
//   Future<void> _registerPatient() async {
//     // Check if form is valid & image is selected
//     if (!_formKey.currentState!.validate() &&
//         (_profileImage == null && _webImage == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please complete the form and select an image.'),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // 1. Create User in Firebase Auth
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       final userId = userCredential.user!.uid;

//       // 2. Upload Image to Firebase Storage
//       final storageRef = _storage.ref().child('patient_profiles/$userId.jpg');
//       UploadTask uploadTask;

//       if (kIsWeb && _webImage != null) {
//         // WEB: Upload bytes
//         uploadTask = storageRef.putData(
//           _webImage!,
//           SettableMetadata(contentType: 'image/jpeg'),
//         );
//       } else if (_profileImage != null) {
//         // MOBILE: Upload file
//         uploadTask = storageRef.putFile(_profileImage!);
//       } else {
//         throw Exception('No image selected.');
//       }

//       final storageSnapshot = await uploadTask.whenComplete(() => null);
//       final profileImageUrl = await storageSnapshot.ref.getDownloadURL();

//       // 3. Store Patient Info in Firestore
//       await _firestore.collection('patients').doc(userId).set({
//         'first_name': _firstNameController.text.trim(),
//         'last_name': _lastNameController.text.trim(),
//         'address': _addressController.text.trim(),
//         'email': _emailController.text.trim(),
//         'contact_number': _contactController.text.trim(),
//         'date_of_birth':
//             _selectedDate != null ? _selectedDate!.toIso8601String() : '',
//         'age': _age, // Store calculated age
//         'gender': _selectedGender,
//         'profile_image_url': profileImageUrl,
//       });

//       // 4. Notify success & navigate
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Patient registered successfully!')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => PatientLoginScreen()),
//       );
//     } catch (e) {
//       debugPrint('Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // -----------------------------
//   // BUILD
//   // -----------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : LayoutBuilder(
//                 builder: (context, constraints) {
//                   // Simple responsive approach:
//                   // If screen width > 600, constrain the form width to 600
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
//                                 'Patient Registration',
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),

//                               // Profile Image
//                               _buildProfileImageSelector(),
//                               const SizedBox(height: 10),

//                               // First Name
//                               _buildTextField(
//                                 controller: _firstNameController,
//                                 label: 'First Name',
//                                 icon: Icons.person,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your first name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 10),

//                               // Last Name
//                               _buildTextField(
//                                 controller: _lastNameController,
//                                 label: 'Last Name',
//                                 icon: Icons.person_outline,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your last name'
//                                     : null,
//                               ),
//                               const SizedBox(height: 10),

//                               // Address
//                               _buildTextField(
//                                 controller: _addressController,
//                                 label: 'Address',
//                                 icon: Icons.home,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Please enter your address'
//                                     : null,
//                               ),
//                               const SizedBox(height: 10),

//                               // Email
//                               _buildTextField(
//                                 controller: _emailController,
//                                 label: 'Email',
//                                 icon: Icons.email,
//                                 keyboardType: TextInputType.emailAddress,
//                                 validator: (value) => value!.contains('@')
//                                     ? null
//                                     : 'Please enter a valid email',
//                               ),
//                               const SizedBox(height: 10),

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
//                               const SizedBox(height: 10),

//                               // Date of Birth + Age
//                               _buildDateOfBirthPicker(context),
//                               const SizedBox(height: 10),
//                               if (_age != null) ...[
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20),
//                                   child: Text(
//                                     'Age: $_age',
//                                     style: const TextStyle(
//                                         fontSize: 18, color: Colors.black),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                               ],

//                               // Gender Selection
//                               _buildGenderSelection(),
//                               const SizedBox(height: 10),

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
//                               const SizedBox(height: 10),

//                               // Register Button
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 100,
//                                     vertical: 15,
//                                   ),
//                                   shape: const StadiumBorder(),
//                                   backgroundColor: Colors.deepPurple,
//                                 ),
//                                 onPressed: () {
//                                   if (_formKey.currentState!.validate()) {
//                                     _registerPatient();
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

//   // -----------------------------
//   // PROFILE IMAGE SELECTOR
//   // -----------------------------
//   Widget _buildProfileImageSelector() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: CircleAvatar(
//         radius: 50,
//         backgroundColor: Colors.grey[200],
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

//   // -----------------------------
//   // GENDER SELECTION
//   // -----------------------------
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
//                   setState(() => _selectedGender = value!);
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
//                   setState(() => _selectedGender = value!);
//                 },
//               ),
//               const Text('Female'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // -----------------------------
//   // DATE OF BIRTH PICKER
//   // -----------------------------
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
//             _age = _calculateAge(pickedDate);
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

//   // -----------------------------
//   // REUSABLE TEXT FIELD
//   // -----------------------------
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

import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';

class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  ConsumerState<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends ConsumerState<PatientRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  int? _age;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate() || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete the form and select an image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userId = userCredential.user!.uid;

      final storageRef = _storage.ref().child('patient_profiles/$userId.jpg');
      final uploadTask = storageRef.putFile(_profileImage!);
      final storageSnapshot = await uploadTask.whenComplete(() => null);
      final profileImageUrl = await storageSnapshot.ref.getDownloadURL();

      await _firestore.collection('patients').doc(userId).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'date_of_birth':
            _selectedDate != null ? _selectedDate!.toIso8601String() : '',
        'age': _age,
        'gender': _selectedGender,
        'profile_image_url': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient registered successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientLoginScreen()),
      );
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                              Pacifico(
                                  text: 'Patient Registration', size: 30.0),
                              const SizedBox(height: 20),
                              _buildProfileImageSelector(),
                              const SizedBox(height: 10),
                              _buildTextField(_firstNameController,
                                  'First Name', Icons.person,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your first name'
                                      : null),
                              const SizedBox(height: 10),
                              _buildTextField(_lastNameController, 'Last Name',
                                  Icons.person_outline,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your last name'
                                      : null),
                              const SizedBox(height: 10),
                              _buildTextField(
                                  _addressController, 'Address', Icons.home,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your address'
                                      : null),
                              const SizedBox(height: 10),
                              _buildTextField(
                                  _emailController, 'Email', Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.contains('@')
                                      ? null
                                      : 'Please enter a valid email'),
                              const SizedBox(height: 10),
                              _buildTextField(_contactController,
                                  'Contact Number', Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value!.length >= 10
                                      ? null
                                      : 'Enter valid phone number'),
                              const SizedBox(height: 10),
                              _buildDateOfBirthPicker(context),
                              const SizedBox(height: 10),
                              if (_age != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text('Age: $_age',
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.black)),
                                ),
                              const SizedBox(height: 10),
                              _buildGenderSelection(),
                              const SizedBox(height: 10),
                              _buildTextField(
                                  _passwordController, 'Password', Icons.lock,
                                  obscureText: true,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your password'
                                      : null),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 15),
                                  //shape: const StadiumBorder(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: AppColors.buttonColor,
                                ),
                                onPressed: _registerPatient,
                                child: const Text('Register',
                                    style: TextStyle(
                                        color: AppColors.buttonTextColor)),
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
            _age = _calculateAge(pickedDate);
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
        ),
        validator: validator,
      ),
    );
  }
}
