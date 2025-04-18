import 'package:flutter/material.dart';
import '../../domain/entities/related_service_entity.dart';

/// {@template service_card}
/// A card widget to display information about a related service.
/// {@endtemplate}
class ServiceCard extends StatelessWidget {
  final RelatedServiceEntity service;
  final VoidCallback? onTap; // Callback when the card is tapped

  /// {@macro service_card}
  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Clip the image to the card shape
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Add vertical margin
      child: InkWell( // Make the card tappable
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row( // Use Row for Image | Text Column layout
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // --- Image --- 
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for image
                child: Image.network(
                  service.imageUrl,
                  width: 80, // Fixed width for image
                  height: 80, // Fixed height for image
                  fit: BoxFit.cover,
                  // Add loading and error placeholders for robustness
                  loadingBuilder: (context, child, loadingProgress) {
                     if (loadingProgress == null) return child;
                     return Container(
                         width: 80,
                         height: 80,
                         alignment: Alignment.center,
                         child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                   ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                   : null,
                         ),
                     );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                     width: 80,
                     height: 80,
                     color: Colors.grey[200],
                     alignment: Alignment.center,
                     child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ), 
                ),
              ),
              const SizedBox(width: 12), // Space between image and text

              // --- Text Column ---
              Expanded( // Allow text column to take remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      service.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), // Space between title and price
                    // Price
                    Text(
                      '\$${service.price.toStringAsFixed(2)}', // Format price
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                         color: Theme.of(context).colorScheme.primary, // Use primary color for price
                         fontWeight: FontWeight.w600,
                      ),
                    ),
                     // TODO: Add other info like rating or description if needed
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
 