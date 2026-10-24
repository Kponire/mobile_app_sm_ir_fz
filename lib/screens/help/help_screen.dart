import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _FAQ(
      question: 'Why is my device offline?',
      answer:
          'Your ESP8266 controller may be offline due to WiFi issues, power loss, or network changes. Check that the device is powered on and your WiFi is working. Try pressing the Test Connection button in Device Management. If issues persist, restart the device.',
    ),
    _FAQ(
      question: 'Why is irrigation not starting?',
      answer:
          'Irrigation may be blocked if: (1) Rain is detected and "Stop on Rain" is enabled in Automation, (2) Tank level is too low, (3) The device is offline, (4) Scheduling is disabled. Check the Control screen for status warnings.',
    ),
    _FAQ(
      question: 'How do I calibrate sensors?',
      answer:
          'Sensor calibration is done via the device firmware. Connect to your ESP8266 via the serial monitor, and run the calibration commands. Refer to your device documentation for specific calibration steps for soil moisture and temperature sensors.',
    ),
    _FAQ(
      question: 'How to reset my device?',
      answer:
          'To factory reset your ESP8266: Press and hold the RESET button on the control box for 10 seconds until the LED blinks rapidly. Then re-configure WiFi using the SmartIrrig setup network. Alternatively, use the Restart Device option in Device Management.',
    ),
    _FAQ(
      question: 'How does fertigation work?',
      answer:
          'Fertigation delivers liquid fertilizer mixed with water through your irrigation system. Enable it in Automation Settings and set your fertilizer pumps (A, B, C for NPK components). The system will mix nutrients at the configured interval and duration.',
    ),
    _FAQ(
      question: 'What is the difference between irrigation and fertigation?',
      answer:
          'Irrigation delivers water only to your crops. Fertigation delivers water mixed with dissolved nutrients (NPK fertilizers). Use fertigation on a schedule (e.g., every 7 days) for nutrient feeding, and irrigation for regular watering.',
    ),
    _FAQ(
      question: 'Why is my soil moisture reading incorrect?',
      answer:
          'Soil moisture sensors can drift over time and need calibration. Also ensure the sensor is fully inserted into moist soil (not air) and wires are properly connected. Check for corrosion on sensor probes, which can cause inaccurate readings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: const AppMainBar(title: 'Help & Support', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need assistance?',
                          style: AppTextStyles.headlineMedium,
                        ),
                        Text(
                          'Browse FAQs or contact our support team.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // FAQ Section
            const SectionHeader(title: 'Frequently Asked Questions'),
            const SizedBox(height: AppSpacing.sm),

            ...List.generate(
              _faqs.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _FAQCard(faq: _faqs[i]),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contact section
            const SectionHeader(title: 'Contact Support'),
            const SizedBox(height: AppSpacing.sm),

            _ContactCard(
              icon: Icons.email_rounded,
              label: 'Email Support',
              detail: 'support@smartirrigation.io',
              color: AppColors.accentBlue,
              onTap: () => _launchUrl('mailto:support@smartirrigation.io'),
            ),

            const SizedBox(height: AppSpacing.sm),

            _ContactCard(
              icon: Icons.phone_rounded,
              label: 'Call Support',
              detail: '+234 800 000 0000',
              color: AppColors.primary,
              onTap: () => _launchUrl('tel:+2348000000000'),
            ),

            const SizedBox(height: AppSpacing.sm),

            _ContactCard(
              icon: Icons.chat_rounded,
              label: 'WhatsApp Support',
              detail: '+234 800 000 0000',
              color: AppColors.success,
              onTap: () => _launchUrl('https://wa.me/2348000000000'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Feedback button
            SecondaryButton(
              label: 'Send Feedback',
              icon: Icons.feedback_outlined,
              onPressed: () => _launchUrl(
                'mailto:feedback@smartirrigation.io?subject=App Feedback',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            SecondaryButton(
              label: 'View Documentation',
              icon: Icons.article_outlined,
              onPressed: () => _launchUrl('https://docs.smartirrigation.io'),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}

class _FAQCard extends StatefulWidget {
  final _FAQ faq;
  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: _toggle,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.faq.question,
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.faq.answer,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.headlineSmall),
                Text(detail, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
