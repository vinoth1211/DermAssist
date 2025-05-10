import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/models/appointment_model.dart';
import 'package:skin_disease_app/models/dermatologist_model.dart';
import 'package:skin_disease_app/services/appointment_service.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/screens/doctor_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  String _filter = 'upcoming'; // 'upcoming', 'past', 'all'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _filter = 'upcoming';
              break;
            case 1:
              _filter = 'past';
              break;
            case 2:
              _filter = 'all';
              break;
          }
        });
      }
    });
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);

      if (authService.user != null) {
        final appointments = await appointmentService.getUserAppointments(authService.user!.uid);
        
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _appointments = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<AppointmentModel> _getFilteredAppointments() {
    final now = DateTime.now();
    
    switch (_filter) {
      case 'upcoming':
        return _appointments.where((appointment) => 
          appointment.appointmentDate.isAfter(now) || 
          (appointment.appointmentDate.year == now.year && 
           appointment.appointmentDate.month == now.month && 
           appointment.appointmentDate.day == now.day)
        ).toList();
      case 'past':
        return _appointments.where((appointment) => 
          appointment.appointmentDate.isBefore(now) && 
          !(appointment.appointmentDate.year == now.year && 
            appointment.appointmentDate.month == now.month && 
            appointment.appointmentDate.day == now.day)
        ).toList();
      case 'all':
      default:
        return _appointments;
    }
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        setState(() {
          _isLoading = true;
        });
        
        final success = await appointmentService.cancelAppointment(appointment.id);
        
        if (success) {
          _loadAppointments();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment canceled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to cancel appointment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(AppointmentModel appointment) async {
    // Navigator to booking screen with pre-filled values
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(
          doctorId: appointment.doctorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: filteredAppointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == 'upcoming'
                                ? 'No upcoming appointments'
                                : _filter == 'past'
                                    ? 'No past appointments'
                                    : 'No appointments found',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _filter == 'upcoming'
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/dermatologists');
                                  },
                                  child: const Text('Book an Appointment'),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        final isUpcoming = appointment.appointmentDate.isAfter(DateTime.now()) ||
                            (appointment.appointmentDate.year == DateTime.now().year &&
                             appointment.appointmentDate.month == DateTime.now().month &&
                             appointment.appointmentDate.day == DateTime.now().day);
                             
                        return _buildAppointmentCard(appointment, isUpcoming, isSmallScreen);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dermatologists');
        },
        child: const Icon(Icons.add),
        tooltip: 'Book new appointment',
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isUpcoming, bool isSmallScreen) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final textScale = MediaQuery.of(context).textScaleFactor;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FutureBuilder<DermatologistModel?>(
                    future: Provider.of<AppointmentService>(context).getDoctorById(appointment.doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading doctor info...');
                      }
                      
                      if (snapshot.hasError || snapshot.data == null) {
                        return Text('Dr. ${appointment.doctorName}');
                      }
                      
                      final doctor = snapshot.data!;
                      return Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 * textScale : 18 * textScale,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Completed',
                    style: TextStyle(
                      color: isUpcoming ? Colors.green : Colors.grey[700],
                      fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Appointment details
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isSmallScreen ? 16 : 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(appointment.appointmentDate),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: isSmallScreen ? 16 : 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  appointment.consultationType == 'virtual' 
                      ? Icons.video_call 
                      : Icons.person,
                  size: isSmallScreen ? 16 : 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.consultationType == 'virtual'
                      ? 'Virtual Consultation'
                      : 'In-Person Visit',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                  ),
                ),
              ],
            ),
            
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                appointment.notes,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 * textScale : 14 * textScale,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            if (isUpcoming)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _rescheduleAppointment(appointment),
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Reschedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // View medical record associated with this appointment
                    },
                    icon: const Icon(Icons.article),
                    label: const Text('View Record'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Book a follow-up appointment
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailScreen(
                            doctorId: appointment.doctorId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Follow-up'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
