import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/presentation/controllers/search_doctor_controller.dart';
import 'package:medisafe/models/search_filter_model.dart';

class SearchDoctorScreen extends ConsumerStatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  _SearchDoctorScreenState createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends ConsumerState<SearchDoctorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String? _selectedCategory;

  void _performSearch() {
    final area = _areaController.text.trim();
    final category = _selectedCategory;

    // Debug print: Inputs before search
    print('Performing search with area="$area" and category="$category"');

    final filter = SearchFilter(
      area: area.isNotEmpty ? area : null,
      category: category,
    );

    if ((filter.area == null || filter.area!.isEmpty) &&
        (filter.category == null || filter.category!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter area or select a specialist')),
      );
      return;
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
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
                      blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Area",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      hintText: "Enter Area",
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Doctor, Specialist",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: <String>[
                      'Cardiologist',
                      'Neurologist',
                      'Pediatrics',
                      'General'
                    ]
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select Specialist",
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
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
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Search', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchState.when(
                data: (doctors) {
                  // Debug print: Number of doctors returned
                  print('Search returned ${doctors.length} doctors');

                  if (doctors.isEmpty) {
                    return const Center(child: Text('No doctors found.'));
                  }
                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return ListTile(
                        title: Text(doctor.name),
                        subtitle: Text(doctor.specialization),
                        // You can add onTap navigation here if needed
                      );
                    },
                  );
                },
                loading: () {
                  print('Search loading...');
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, _) {
                  print('Search error: $error');
                  return Center(child: Text('Error: $error'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
