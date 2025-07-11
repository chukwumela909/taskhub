import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/screens/user/faq.dart';

class GetHelpScreen extends StatefulWidget {
  const GetHelpScreen({Key? key}) : super(key: key);

  @override
  _GetHelpScreenState createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends State<GetHelpScreen> {
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
              color: Color(0xfff6f3fb),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Get Help',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Help Icon --
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/help.svg',
                    width: 32,
                    height: 32,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // -- Title --
            Center(
              child: Text(
                'We\'re Here to Help',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // -- Subtitle --
            Center(
              child: Text(
                'Need assistance? Get in touch with our support team and we\'ll be happy to help you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Geist',
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // -- Contact Information Section --
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // -- Email Contact Card --
            _buildContactCard(
              icon: 'assets/icons/email-icon.svg',
              title: 'Email Support',
              subtitle: 'Send us an email and we\'ll respond within 24 hours',
              contactInfo: 'hello@ngtaskhub.com',
              onTap: () => _launchEmail('hello@ngtaskhub.com'),
              onCopy: () => _copyToClipboard('hello@ngtaskhub.com', 'Email copied to clipboard'),
            ),
            const SizedBox(height: 16),

            // -- Phone Contact Card --
            _buildContactCard(
              icon: 'assets/icons/phone-icon.svg',
              title: 'Phone Support',
              subtitle: 'Call us directly for immediate assistance',
              contactInfo: '+234 802 524 3900',
              onTap: () => _launchPhone('+2348025243900'),
              onCopy: () => _copyToClipboard('+234 802 524 3900', 'Phone number copied to clipboard'),
            ),
            const SizedBox(height: 32),

            // -- Support Hours Section --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F9FF),
                border: Border.all(
                  color: Color(0xFF0284C7).withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF0284C7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.access_time,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Support Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Geist',
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSupportHour('Monday - Friday', '9:00 AM - 6:00 PM'),
                  const SizedBox(height: 8),
                  _buildSupportHour('Saturday', '10:00 AM - 4:00 PM'),
                  const SizedBox(height: 8),
                  _buildSupportHour('Sunday', 'Closed'),
                  const SizedBox(height: 12),
                  Text(
                    'All times are in West Africa Time (WAT)',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Geist',
                      color: Color(0xFF0284C7).withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -- FAQ Section --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/faq.svg',
                            width: 20,
                            height: 20,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Geist',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Check out our FAQ section for quick answers to common questions before reaching out.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Geist',
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View FAQ',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -- Emergency Notice --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFF9E6),
                border: Border.all(
                  color: attentionWarning.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: attentionWarning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: attentionWarning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Need Immediate Help?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: attentionWarning,
                            fontSize: 14,
                            fontFamily: 'Geist',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "For urgent issues, please call our phone support line directly. We're here to help!",
                          style: TextStyle(
                            fontSize: 14,
                            color: attentionWarning.withOpacity(0.8),
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String icon,
    required String title,
    required String subtitle,
    required String contactInfo,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 24,
                    height: 24,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Geist',
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Geist',
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    contactInfo,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: title == 'Email Support' ? 'Send Email' : 'Call Now',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportHour(String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Geist',
            color: Color(0xFF0284C7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Geist',
            color: Color(0xFF0284C7).withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Geist'),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _launchEmail(String email) async {
    try {
      // Simple fallback - just copy to clipboard for demo
      _copyToClipboard(email, 'Email copied to clipboard - Open your email app to send');
    } catch (e) {
      _copyToClipboard(email, 'Email copied to clipboard');
    }
  }

  void _launchPhone(String phoneNumber) async {
    try {
      // Simple fallback - just copy to clipboard for demo
      _copyToClipboard(phoneNumber, 'Phone number copied to clipboard');
    } catch (e) {
      _copyToClipboard(phoneNumber, 'Phone number copied to clipboard');
    }
  }
} 