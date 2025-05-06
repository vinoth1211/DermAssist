import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/services/appointment_service.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skin_disease_app/models/dermatologist_model.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DermatologistModel? _doctor;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _consultationType = 'virtual'; // 'virtual' or 'in-person'
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDoctorDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final doctor = await appointmentService.getDoctorById(widget.doctorId);

      if (doctor != null) {
        setState(() {
          _doctor = doctor;
          _isLoading = false;
        });
        
        // Load available time slots for the selected date
        _loadAvailableTimeSlots();
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor not found'),
            backgroundColor: Colors.red,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading doctor details: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_doctor == null) return;
    
    setState(() {
      _isLoading = true;
      _selectedTimeSlot = null;
    });
    
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final availableSlots = await appointmentService.getAvailableTimeSlots(
        _doctor!.id,
        _selectedDate,
      );
      
      setState(() {
        _availableTimeSlots = availableSlots;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading time slots: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _availableTimeSlots = [];
        _isLoading = false;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _bookAppointment() async {
    if (_doctor == null || _selectedTimeSlot == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (authService.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to book an appointment'),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Show confirmation dialog
      if (!mounted) return;
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doctor: ${_doctor!.name}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}'),
              const SizedBox(height: 8),
              Text('Time: $_selectedTimeSlot'),
              const SizedBox(height: 8),
              Text('Consultation Type: ${_consultationType == 'virtual' ? 'Virtual' : 'In-Person'}'),
              const SizedBox(height: 8),
              Text('Fee: \$${_doctor!.consultationFee}'),
              const SizedBox(height: 16),
              const Text(
                'Note: Appointment confirmation will be sent to your registered email address. Please arrive 15 minutes before your scheduled time.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      
      if (confirm != true) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Parse time from the selected time slot and create a DateTime object
      final timeParts = _selectedTimeSlot!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);
      final isPm = _selectedTimeSlot!.contains('PM');
      
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        isPm && hour != 12 ? hour + 12 : (hour == 12 && !isPm ? 0 : hour),
        minute,
      );
      
      final appointmentId = await appointmentService.bookAppointment(
        doctorId: _doctor!.id,
        userId: authService.user!.uid,
        dateTime: appointmentDateTime,
        consultationType: _consultationType,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      if (appointmentId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to book appointment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctor == null
              ? const Center(child: Text('Doctor not found'))
              : CustomScrollView(
                  slivers: [
                    // App bar with doctor image
                    SliverAppBar(
                      expandedHeight: 200.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _doctor!.imageUrl != null && _doctor!.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _doctor!.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.person, size: 80)),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: const Center(child: Icon(Icons.person, size: 80)),
                              ),
                      ),
                    ),
                    
                    // Doctor info
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and rating
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _doctor!.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _doctor!.specializations != null && _doctor!.specializations!.isNotEmpty
                                            ? _doctor!.specializations!.join(', ')
                                            : _doctor!.qualification,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _doctor!.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Stats (Patients, Experience, Reviews)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.people,
                                    value: '1500+',
                                    label: 'Patients',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.history,
                                    value: _doctor!.experience,
                                    label: 'Experience',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.star,
                                    value: '500+',
                                    label: 'Reviews',
                                    iconColor: Colors.amber,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Hospital info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_hospital,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _doctor!.hospital,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_doctor!.address),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_doctor!.phoneNumber),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Tab bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.black87,
                                indicator: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tabs: const [
                                  Tab(text: 'Book'),
                                  Tab(text: 'About'),
                                  Tab(text: 'Reviews'),
                                ],
                              ),
                            ),
                            
                            // Tab content
                            SizedBox(
                              height: 400,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab 1: Book Appointment
                                  _buildBookAppointmentTab(),
                                  
                                  // Tab 2: About
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        const Text(
                                          'About Doctor',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Dr. ${_doctor!.name} is a highly skilled dermatologist with ${_doctor!.experience} of experience. '
                                          'Specializing in ${_doctor!.specializations != null && _doctor!.specializations!.isNotEmpty ? _doctor!.specializations!.join(", ") : "dermatology"}, '
                                          'they have helped thousands of patients with skin conditions and concerns.\n\n'
                                          'Qualification: ${_doctor!.qualification}\n'
                                          'Currently practicing at ${_doctor!.hospital}.',
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Education & Training',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Example education info (in a real app, this would come from the database)
                                        const ListTile(
                                          leading: Icon(Icons.school),
                                          title: Text('Medical School'),
                                          subtitle: Text('Stanford University School of Medicine'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.medical_services),
                                          title: Text('Residency'),
                                          subtitle: Text('Dermatology, Mayo Clinic'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        const ListTile(
                                          leading: Icon(Icons.workspace_premium),
                                          title: Text('Certification'),
                                          subtitle: Text('Board Certified in Dermatology'),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Tab 3: Reviews
                                  const Center(
                                    child: Text('Reviews coming soon'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBookAppointmentTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consultation type
            const Text(
              'Consultation Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Virtual'),
                    value: 'virtual',
                    groupValue: _consultationType,
                    onChanged: (value) {
                      setState(() {
                        _consultationType = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('In-Person'),
                    value: 'in-person',
                    groupValue: _consultationType,
                    onChanged: (value) {
                      setState(() {
                        _consultationType = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date picker
            const Text(
              'Select Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time slots
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_availableTimeSlots.isEmpty)
              const Text(
                'No available slots for this date. Please select another date.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((timeSlot) {
                  final isSelected = timeSlot == _selectedTimeSlot;
                  return ChoiceChip(
                    label: Text(timeSlot),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeSlot = selected ? timeSlot : null;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Book button and fee
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consultation Fee'),
                    Text(
                      '\$${_doctor!.consultationFee}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _selectedTimeSlot == null || _isLoading
                        ? null
                        : _bookAppointment,
                    text: 'Book Appointment',
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
