import 'package:flutter/material.dart';
import 'package:skin_disease_app/models/dermatologist_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorCard extends StatelessWidget {
  final DermatologistModel doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Doctor image
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child:
                      doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: CachedNetworkImage(
                              imageUrl: doctor.imageUrl!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.grey,
                          ),
                ),
                const SizedBox(height: 8),

                // Doctor name
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),

                // Specialization
                Text(
                  doctor.specializations != null &&
                          doctor.specializations!.isNotEmpty
                      ? doctor.specializations!.first
                      : doctor.qualification,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
