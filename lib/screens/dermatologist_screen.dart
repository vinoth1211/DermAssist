import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/appointment_service.dart';
import 'package:skin_disease_app/widgets/doctor_card.dart';
import 'package:skin_disease_app/screens/doctor_detail_screen.dart';
import 'package:skin_disease_app/widgets/custom_text_field.dart';
import 'package:skin_disease_app/models/dermatologist_model.dart';

class DermatologistScreen extends StatefulWidget {
  const DermatologistScreen({super.key});

  @override
  State<DermatologistScreen> createState() => _DermatologistScreenState();
}

class _DermatologistScreenState extends State<DermatologistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDoctors() async {
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    await appointmentService.getAllDermatologists();
  }
  
  List<DermatologistModel> _getFilteredDoctors(List<DermatologistModel> doctors) {
    if (_searchQuery.isEmpty) {
      return doctors;
    }
    
    final query = _searchQuery.toLowerCase();
    return doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
          (doctor.specializations != null && 
           doctor.specializations!.any((spec) => spec.toLowerCase().contains(query))) ||
          doctor.hospital.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentService = Provider.of<AppointmentService>(context);
    final filteredDoctors = _getFilteredDoctors(appointmentService.doctors);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Dermatologists'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Search',
              hintText: isSmallScreen ? 'Search by name or specialty' : 'Search by name, specialization, or hospital',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Doctor filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Highest Rated', false),
                _buildFilterChip('Available Today', false),
                _buildFilterChip('Online', false),
                _buildFilterChip('Nearest', false),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Doctors list
          Expanded(
            child: appointmentService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No dermatologists found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12.0 : 16.0,
                          vertical: isSmallScreen ? 8.0 : 12.0
                        ),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return _buildDoctorListItem(doctor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement filtering logic
        },
      ),
    );
  }

  Widget _buildDoctorListItem(DermatologistModel doctor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final textScale = MediaQuery.of(context).textScaleFactor;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10.0 : 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctorId: doctor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                child: (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty)
                    ? Image.network(
                        doctor.imageUrl!,
                        width: isSmallScreen ? 70 : 90,
                        height: isSmallScreen ? 90 : 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isSmallScreen ? 70 : 90,
                            height: isSmallScreen ? 90 : 110,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: isSmallScreen ? 40 : 50,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      )
                    : Container(
                        width: isSmallScreen ? 70 : 90,
                        height: isSmallScreen ? 90 : 110,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: isSmallScreen ? 40 : 50,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              
              SizedBox(width: isSmallScreen ? 12 : 16),
              
              // Doctor information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor name and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 * textScale : 18 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: isSmallScreen ? 14 : 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                doctor.rating.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Specialization and experience
                    Text(
                      '${doctor.specializations != null && doctor.specializations!.isNotEmpty ? doctor.specializations!.first : doctor.qualification} · ${doctor.experience} Experience',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 * textScale : 14 * textScale,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    
                    // Hospital
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: isSmallScreen ? 14 : 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.hospital,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 * textScale : 13 * textScale,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (!isSmallScreen) const SizedBox(height: 4),
                    
                    // Address - hide on very small screens
                    if (!isSmallScreen || screenWidth > 320)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: isSmallScreen ? 14 : 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.address,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 * textScale : 13 * textScale,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    
                    // Consultation fee and book button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consultation Fee',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 * textScale : 12 * textScale,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                            Text(
                              '\$${doctor.consultationFee}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 * textScale : 16 * textScale,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailScreen(doctorId: doctor.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16, 
                              vertical: isSmallScreen ? 8 : 10
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 * textScale : 14 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
