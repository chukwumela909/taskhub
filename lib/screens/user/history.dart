import 'package:flutter/material.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task History',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 24,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/filter.svg',
                        width: 24,
                        height: 24,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'View all your previous tasks',
                  style: TextStyle(
                    color: const Color(0xFF606060).withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Task list
                _buildActivityItem(
                  title: 'Web Development',
                  date: '28th January, 2025',
                  amount: '400',
                  status: 'Completed',
                  statusColor: primaryColor.withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'House Cleaning',
                  date: '25th January, 2025',
                  amount: '200',
                  status: 'Completed',
                  statusColor: primaryColor.withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'Poster Design',
                  date: '22nd January, 2025',
                  amount: '400',
                  status: 'Completed',
                  statusColor: primaryColor.withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'Wall Tiling',
                  date: '18th January, 2025',
                  amount: '400',
                  status: 'Cancelled',
                  statusColor: const Color(0xFF606060).withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'Mobile App UI',
                  date: '15th January, 2025',
                  amount: '600',
                  status: 'Completed',
                  statusColor: primaryColor.withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'Logo Design',
                  date: '10th January, 2025',
                  amount: '300',
                  status: 'Completed',
                  statusColor: primaryColor.withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  title: 'Garden Work',
                  date: '5th January, 2025',
                  amount: '350',
                  status: 'Cancelled',
                  statusColor: const Color(0xFF606060).withOpacity(0.7),
                  statusBgColor: const Color(0xFFF7F5FB),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - icon and task details
        Row(
          children: [
            // Icon placeholder
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset('assets/icons/activity-icon.svg'),
            ),
            const SizedBox(width: 12),
            // Text details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF606060),
                    fontSize: 18,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 15,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Right side - price and status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Text(
                  '₦',
                  style: TextStyle(
                  color: Color(0xFF606060),
                    fontSize: 18,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF606060),
                    fontSize: 17,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

