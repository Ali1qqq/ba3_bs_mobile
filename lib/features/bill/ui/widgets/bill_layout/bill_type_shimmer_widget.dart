import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BillTypeShimmerWidget extends StatelessWidget {
  const BillTypeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: max(.25.sw, 350),
      height: 130,
      child: Stack(
        children: [
          // Main container with white background
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white, // Keep it white so elements are visible
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
              border: Border.all(color: Colors.grey[300]!, width: 2), // Simulated border
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: max(.25.sw, 350),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShimmerBox(width: 50, height: 15), // Placeholder for "كل الفواتير"
                    _buildShimmerBox(width: 30, height: 15), // Placeholder for numbers
                    _buildShimmerBox(width: 70, height: 15), // Placeholder for "الفواتير المعلقة"
                    _buildShimmerBox(width: 30, height: 15), // Placeholder for pending bills count
                  ],
                ),
              ),
            ),
          ),
          // Title bar with shimmer effect
          Positioned(
            top: 0,
            right: 0,
            child: _buildShimmerBox(width: 220, height: 30, borderRadius: 5),
          ),
          // Button placeholder with shimmer effect
          Positioned(
            bottom: 15,
            right: 0,
            left: 0,
            child: Center(
              child: _buildShimmerBox(width: 100, height: 35, borderRadius: 8),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer box method for individual elements
  Widget _buildShimmerBox({required double width, required double height, double borderRadius = 4}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300]!, // Lighter grey to differentiate from shimmer background
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
