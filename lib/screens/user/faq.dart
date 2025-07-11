import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/theme/const_value.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<int> expandedItems = [2, 5]; // Items that are expanded by default (0-indexed)

  final List<FAQItem> faqItems = [
    FAQItem(
      question: "How does TaskHub work?",
      answer: "TaskHub connects users who need tasks completed with skilled taskers in their area. Simply post a task, receive offers from qualified taskers, choose the best one, and get your task completed safely and efficiently.",
    ),
    FAQItem(
      question: "How do I post a task on TaskHub?",
      answer: "To post a task, tap the 'Post Task' button on your dashboard, describe what you need done, set your budget and timeline, add photos if needed, and publish your task. You'll start receiving offers from interested taskers shortly.",
    ),
    FAQItem(
      question: "How is payment handled on TaskHub?",
      answer: "TaskHub uses a secure payment system. Payment is held in escrow when you accept a tasker's offer and is only released when you're satisfied with the completed work. This protects both users and taskers.",
    ),
    FAQItem(
      question: "What if I'm not satisfied with the work?",
      answer: "If you're not satisfied with the completed work, you can request revisions or contact our support team. We have dispute resolution processes in place to ensure fair outcomes for all parties involved.",
    ),
    FAQItem(
      question: "How do I become a tasker?",
      answer: "To become a tasker, go to your profile and tap 'Become a Tasker'. You'll need to complete your profile, verify your identity, add your skills and experience, and pass our background check process.",
    ),
    FAQItem(
      question: "What types of tasks can I post?",
      answer: "You can post a wide variety of tasks including home repairs, cleaning, delivery, tutoring, graphic design, writing, virtual assistance, and many more. Check our guidelines for prohibited task types.",
    ),
    FAQItem(
      question: "How are taskers vetted?",
      answer: "All taskers go through a comprehensive vetting process including identity verification, background checks, skill assessments, and review of their experience and qualifications before they can accept tasks.",
    ),
    FAQItem(
      question: "What are the fees for using TaskHub?",
      answer: "TaskHub charges a small service fee on completed tasks. Users pay a 3% service fee, while taskers pay a 15% service fee. There are no upfront costs or subscription fees to use the platform.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xfff7f7f7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF606060),
              size: 20,
            ),
          ),
        ),
        title: Text(
          'FAQ',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
            color: Color(0xFF606060),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider line
            Container(
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(height: 40),
            
            // Title and subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Find answers to common questions about TaskHub. If you can\'t find what you\'re looking for, contact our support team.',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // FAQ Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: List.generate(faqItems.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9.0),
                    child: _buildFAQItem(index),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    final isExpanded = expandedItems.contains(index);
    final faqItem = faqItems[index];
    
    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Question header
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  expandedItems.remove(index);
                } else {
                  expandedItems.add(index);
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isExpanded ? 15 : 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faqItem.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.7),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Arrow icon
                  Container(
                    width: 21,
                    height: 21,
                    child: Transform.rotate(
                      angle: isExpanded ? 3.14159 : 0, // 180 degrees in radians
                      child: SvgPicture.asset(
                        'assets/icons/arrow-right.svg',
                        width: 21,
                        height: 21,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Answer content (expanded)
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 17,
                right: 17,
                bottom: 17,
              ),
              child: Text(
                faqItem.answer,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.5),
                  height: 1.29,
                  letterSpacing: -0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
} 