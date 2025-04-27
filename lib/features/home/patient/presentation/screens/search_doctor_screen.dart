import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/presentation/controllers/search_doctor_controller.dart';
import 'package:medisafe/features/home/patient/presentation/screens/filtered_doctors_screen.dart';
import 'package:medisafe/models/search_filter_model.dart';

class SearchDoctorScreen extends ConsumerStatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  _SearchDoctorScreenState createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends ConsumerState<SearchDoctorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String? _selectedCategory;
  //DateTime? _selectedDate;

  // void _pickDate() async {
  //   DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //   );

  //   setState(() {
  //     _selectedDate = pickedDate;
  //   });
  // }

  void _performSearch() {
    final filter = SearchFilter(
      area: _areaController.text,
      category: _selectedCategory,
      //date: _selectedDate,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredDoctorsScreen(filter: filter),
      ),
    );

    ref.read(searchDoctorControllerProvider.notifier).searchDoctors(filter);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchDoctorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Your Specialist',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Area",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      hintText: "Select Area",
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Doctor, Specialist",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: <String>[
                      'Cardiology',
                      'Neurology',
                      'Pediatrics',
                      'General'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Doctor, Specialist",
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // const Text(
                  //   "Select Date",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // GestureDetector(
                  //   onTap: _pickDate,
                  //   child: AbsorbPointer(
                  //     child: TextFormField(
                  //       decoration: InputDecoration(
                  //         hintText: _selectedDate == null
                  //             ? "Select Date"
                  //             : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  //         prefixIcon: const Icon(Icons.calendar_today_outlined),
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         filled: true,
                  //         fillColor: Colors.grey[100],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchState.when(
                data: (doctors) => ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return ListTile(
                      title: Text(doctor.name),
                      subtitle: Text(doctor.specialization),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
