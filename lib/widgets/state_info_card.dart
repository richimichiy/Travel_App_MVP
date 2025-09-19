import 'package:flutter/material.dart';
import '../models/states.dart';

class StateInfoCard extends StatelessWidget {
  final States state;
  final Function(States)? onExploreLocations;

  const StateInfoCard({Key? key, required this.state, this.onExploreLocations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.75, // Bigger than location card
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image - larger for states
          Container(
            height: 160, // Bigger than location card (was 120)
            width: double.infinity,
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFF3F4F6),
            ),
            child: state.imageUrl != null && state.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      state.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(), // Just empty gray container
                    ),
                  )
                : Container(), // Just empty gray container
          ),

          // Content - scrollable for longer descriptions
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge (placeholder)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.1), // Info Blue
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏛️', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Text(
                          'Historic Region', // Placeholder category
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // State name - larger title
                  Text(
                    state.name,
                    style: TextStyle(
                      fontSize: 22, // Bigger than location card (was 18)
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),

                  SizedBox(height: 8),

                  // Full description - no truncation, scrollable
                  Text(
                    state.description.isNotEmpty
                        ? state.description
                        : 'Discover the rich culture, stunning landscapes, and unique attractions that make ${state.name} a remarkable destination. From historic sites to natural wonders, this Brazilian state offers unforgettable experiences for every type of traveler.',
                    style: TextStyle(
                      fontSize: 14, // Slightly bigger than location card
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                    // No maxLines - show full description
                  ),

                  SizedBox(height: 16),

                  // Action button - only Explore Locations
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onExploreLocations?.call(state);
                        // TODO: Show state locations on map
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF374151),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Explore Locations',
                        style: TextStyle(fontSize: 14),
                      ),
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

  Widget _buildStatePlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏛️', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              state.name,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
