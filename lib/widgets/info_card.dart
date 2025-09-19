import 'package:flutter/material.dart';
import '../models/location.dart';
import 'attraction_detail_page.dart';

enum ListType { brazilTop20, rioTop10 }

class LocationInfoCard extends StatelessWidget {
  final Location location;
  final ListType listType;
  final Function(Location, ListType)? onViewDetails;

  const LocationInfoCard({
    Key? key,
    required this.location,
    required this.listType, // Now required enum parameter
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        mainAxisSize: MainAxisSize.min, // Make it compact
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image - smaller height
          Container(
            height: 120,
            width: double.infinity,
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFF3F4F6),
            ),
            child: location.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      location.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ranking badge
                // Ranking badge and add to trip button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBadgeBackgroundColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getRankingIcon(),
                          SizedBox(width: 4),
                          Text(
                            '#${location.position ?? 1} in ${_getListDisplayName()}',
                            style: TextStyle(
                              color: _getBadgeTextColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add to trip button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${location.name} added to trip!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF374151),
                          size: 20,
                        ),
                        padding: EdgeInsets.all(6),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Title
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),

                SizedBox(height: 6),

                // Description preview - 2 lines max
                Text(
                  location.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12),

                // Details button - single, full width, bold
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onViewDetails?.call(location, listType);
                      // TODO: Navigate to detail screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF374151),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, // Bold text
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.image, size: 32, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _getRankingIcon() {
    switch (listType) {
      case ListType.rioTop10:
        return Icon(
          Icons.favorite,
          size: 12,
          color: Color(0xFFEF4444), // Red heart matching your marker
        );
      case ListType.brazilTop20:
        return Text('⭐', style: TextStyle(fontSize: 12));
    }
  }

  Color _getBadgeBackgroundColor() {
    switch (listType) {
      case ListType.rioTop10:
        return Color(0xFFEF4444).withOpacity(0.1); // Red background for Rio
      case ListType.brazilTop20:
        return Color(
          0xFFEAB308,
        ).withOpacity(0.1); // Yellow background for Brazil
    }
  }

  Color _getBadgeTextColor() {
    switch (listType) {
      case ListType.rioTop10:
        return Color(0xFFEF4444); // Red text for Rio
      case ListType.brazilTop20:
        return Color(0xFFEAB308); // Yellow text for Brazil
    }
  }

  String _getListDisplayName() {
    switch (listType) {
      case ListType.rioTop10:
        return 'Rio de Janeiro Top 10';
      case ListType.brazilTop20:
        return 'Top 20 Brazil';
    }
  }
}
