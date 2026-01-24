import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data class for region information
class RegionData {
  const RegionData(this.name, this.learned, this.total, this.color, this.icon);

  final String name;
  final int learned;
  final int total;
  final Color color;
  final IconData icon;

  double get progress => learned / total;
}

/// Region progress item showing learning progress
class RegionProgressItem extends StatelessWidget {
  const RegionProgressItem({super.key, required this.region});

  final RegionData region;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: region.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(region.icon, color: region.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      region.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      '${region.learned}/${region.total}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: region.progress,
                    backgroundColor: region.color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(region.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
