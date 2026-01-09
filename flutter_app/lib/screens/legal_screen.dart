import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('?? Legal & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legal & Support',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '???? MEENGLE (PTY) LTD - South Africa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Legal Documents
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legal Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () => _showTermsOfService(context),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your data (POPIA)',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.people,
                    title: 'Community Guidelines',
                    subtitle: 'Rules for safe, respectful community',
                    onTap: () => _showCommunityGuidelines(context),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.cookie,
                    title: 'Cookie Policy',
                    subtitle: 'How we use cookies and tracking',
                    onTap: () => _showCookiePolicy(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Safety & Support
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Safety & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.security,
                    title: 'Safety Tips',
                    subtitle: 'Stay safe on MEENGLE (South Africa)',
                    onTap: () => _showSafetyTips(context),
                  ),
                  const SizedBox(height: 12),
                  _buildLegalCard(
                    icon: Icons.help,
                    title: 'FAQ',
                    subtitle: 'Answers to common questions',
                    onTap: () => _showFAQ(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // South African Support
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '???? South African Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactRow('Legal', 'legal@meengle.co.za'),
                        _buildContactRow('Privacy (POPIA)', 'privacy@meengle.co.za'),
                        _buildContactRow('Safety Concerns', 'safety@meengle.co.za'),
                        _buildContactRow('General Support', 'support@meengle.co.za'),
                        _buildContactRow('Information Officer', 'info@meengle.co.za'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Emergency Contacts
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '?? Emergency Contacts (South Africa)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmergencyContactRow('SAPS (South African Police)', '10177 (toll-free)'),
                        _buildEmergencyContactRow('Emergency Services', '112 (mobile)'),
                        _buildEmergencyContactRow('SAPS Crime Line', '086 001 0600'),
                        _buildEmergencyContactRow('Rape Crisis (Sexual Assault)', '0800 35 2500 (24/7)'),
                        _buildEmergencyContactRow('Gender-Based Violence Hotline', '0800 050 150'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'MEENGLE (PTY) LTD',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registered in South Africa | POPIA Compliant',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2024 All rights reserved',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF667eea)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () => _launchEmail(email),
            child: Text(
              email,
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactRow(String service, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          GestureDetector(
            onTap: () => _launchPhone(number),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showTermsOfService(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'Terms of Service',
      content: _getTermsOfService(),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'Privacy Policy',
      content: _getPrivacyPolicy(),
    );
  }

  void _showCommunityGuidelines(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'Community Guidelines',
      content: _getCommunityGuidelines(),
    );
  }

  void _showCookiePolicy(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'Cookie Policy',
      content: _getCookiePolicy(),
    );
  }

  void _showSafetyTips(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'Safety Tips',
      content: _getSafetyTips(),
    );
  }

  void _showFAQ(BuildContext context) {
    _showLegalDialog(
      context: context,
      title: 'FAQ',
      content: _getFAQ(),
    );
  }

  void _showLegalDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTermsOfService() {
    return '''MEENGLE - TERMS OF SERVICE

Last Updated: January 2024
Jurisdiction: South Africa (POPIA Compliant)

1. ACCEPTANCE OF TERMS
By accessing and using MEENGLE ("Service"), you accept and agree to be bound by the terms and provision of this agreement. MEENGLE is operated by MEENGLE (PTY) LTD, a South African company.

2. ELIGIBILITY & ACCOUNT CREATION
You must be at least 18 years old to use MEENGLE. By creating an account, you represent and warrant that:
- All information you provide is true, accurate, and current
- You will maintain the confidentiality of your password
- You are responsible for all activity under your account
- You will not share your account with others
- You will use MEENGLE only for lawful purposes

3. USER CONDUCT
You agree NOT to:
- Post offensive, abusive, defamatory, or obscene content
- Use MEENGLE for spam, scams, or fraudulent purposes
- Share explicit sexual content without consent
- Impersonate another person or entity
- Collect or track personal information of other users
- Use bots, scrapers, or automated tools
- Engage in catfishing or deceptive practices
- Solicit money or goods from other users
- Violate South African law

4. PAYMENTS & SUBSCRIPTIONS
- Subscriptions renew automatically unless cancelled
- Cancellation must be made at least 24 hours before renewal
- No refunds for partial subscription periods (subject to CPA protections)
- Prices are in South African Rand (ZAR)
- All sales are final

5. CONSUMER PROTECTION ACT (CPA) COMPLIANCE
In accordance with the Consumer Protection Act, 2008:
- You have the right to return services within 30 days if unsafe or not fit
- You cannot be held liable for unauthorized charges if reported within 40 days
- MEENGLE must disclose all material information
- You have the right to cancel auto-renewal subscriptions anytime
- Complaints can be escalated to the South African National Consumer Commission

6. PRIVACY & DATA PROTECTION (POPIA COMPLIANCE)
Your use of MEENGLE is governed by our Privacy Policy, which complies with the Protection of Personal Information Act, 2013 (POPIA). We do NOT sell your data to third parties.

7. GOVERNING LAW
These Terms are governed by South African law and jurisdiction.

8. CONTACT INFORMATION
If you have questions about these Terms:
- Email: legal@meengle.co.za
- Information Officer (POPIA): info@meengle.co.za
- Support: support@meengle.co.za

© 2024 MEENGLE (PTY) LTD. All rights reserved.''';
  }

  String _getPrivacyPolicy() {
    return '''MEENGLE - PRIVACY POLICY

Last Updated: January 2024
Jurisdiction: South Africa (POPIA Compliant)

1. INTRODUCTION
At MEENGLE (PTY) LTD, we respect your privacy and are committed to protecting your personal information. This Privacy Policy complies with the Protection of Personal Information Act, 2013 (POPIA).

2. INFORMATION WE COLLECT
A. Information You Provide:
- Account Registration: Name, email, phone number, date of birth, location, gender
- Profile Information: Bio, interests, photos, relationship goals, education
- Payment Information: Processed via Stripe (we do NOT store full card numbers)
- Messages & Communications: All messages between users
- Support Requests: Emails, complaints, and customer service interactions

B. Information Collected Automatically:
- Device Information: IP address, device type, operating system, browser type
- Usage Data: Pages visited, features used, interactions, time spent
- Location Data: Approximate location (if you grant permission)
- Cookies & Tracking: Session cookies, preference cookies, analytics tracking

3. HOW WE USE YOUR INFORMATION
Under POPIA, we process personal information based on:
- Your consent
- Contract (performance of service agreement)
- Legal obligation
- Legitimate interest (safety, fraud prevention, service improvement)

We use your information to:
- Provide and improve the Service
- Match you with potential partners
- Send notifications and updates
- Detect fraud and abuse
- Comply with legal obligations
- Send optional promotional communications

4. DATA SHARING
We DO NOT sell your personal data. We may share information with:
- Other Users: Your profile information for matching
- Service Providers: Third parties under data processing agreements
- Law Enforcement: If required by South African law
- Business Transfers: If MEENGLE is acquired or merges

5. DATA RETENTION
- Active Accounts: All information retained while account is active
- Deleted Accounts: Most data deleted within 30 days; legal/fraud data retained for 3 years
- Messages: Deleted when both users delete conversation (or within 90 days of account deletion)
- Payment Records: Retained for 3 years for tax compliance

6. YOUR POPIA RIGHTS
You have the right to:
- Know if we hold your personal information
- Access your personal data
- Correct inaccurate information
- Delete your account and data
- Object to processing
- Restrict processing
- Lodge a complaint with the Information Regulator

To exercise these rights, contact: privacy@meengle.co.za

7. DATA SECURITY
We implement industry-standard security measures:
- SSL/TLS encryption for all data in transit
- Password hashing with bcryptjs
- Access controls for authorized staff only
- 24/7 security monitoring
- Regular security audits

8. INFORMATION OFFICER & COMPLAINTS
MEENGLE's Information Officer:
- Email: info@meengle.co.za
- Phone: +27 [Your Number]

Information Regulator (South Africa):
- Email: complaints.IR@justice.gov.za
- Website: www.inforegulator.org.za
- Phone: +27 10 500 3200

9. CONTACT US
For privacy questions:
- Privacy: privacy@meengle.co.za
- Information Officer: info@meengle.co.za
- Support: support@meengle.co.za

© 2024 MEENGLE (PTY) LTD. POPIA Compliant.''';
  }

  String _getCommunityGuidelines() {
    return '''MEENGLE - COMMUNITY GUIDELINES

Last Updated: January 2024
South African Platform

These guidelines ensure MEENGLE remains a safe, respectful place.

? BE RESPECTFUL & AUTHENTIC
- Be genuine and honest in your profile
- Use recent, clear photos of yourself
- Treat all users with kindness and respect
- Accept rejection gracefully
- Report problematic users

? PROHIBITED BEHAVIOR
1. Harassment & Abuse
- Repeated unwanted messages
- Threats, insults, or degrading language
- Doxxing (sharing personal information)
- Coordinated attacks

2. Discrimination & Hate Speech (Illegal in SA)
- Racist, sexist, religious, ethnic slurs
- Discriminating based on protected characteristics
- Hate speech or extremist content

3. Sexual Offences & Exploitation
- Child exploitation (18+ only)
- Non-consensual image sharing (illegal)
- Sexual harassment or coercion
- Human trafficking

4. Fraud & Scams
- Catfishing or using fake identities
- Romance scams or asking for money
- Fake investment opportunities
- Phishing or malicious links

5. Illegal Activity
- Promoting illegal substances or weapons
- Soliciting illegal services
- Any violation of South African law

?? ENFORCEMENT & CONSEQUENCES
- First Offense: Warning or temporary suspension (24 hours - 7 days)
- Second Offense: Extended suspension (7 days - 30 days)
- Third Offense: Permanent ban
- Severe Violations: Immediate permanent ban + police report

For serious crimes, we will report to SAPS (South African Police Service).

?? REPORT & BLOCK
- Block: Click the menu on any profile or message and select "Block"
- Report: Use the report feature to alert our moderation team
- Details: Provide specific examples and screenshots
- Police: For serious crimes, contact SAPS on 10177

?? South African Laws Referenced:
- Criminal Law (Sexual Offences and Related Matters) Amendment Act
- Promotion of Equality and Prevention of Unfair Discrimination Act (PEPUDA)
- Protection from Harassment Act
- SAPS Emergency: 10177

© 2024 MEENGLE (PTY) LTD. South Africa.''';
  }

  String _getCookiePolicy() {
    return '''MEENGLE - COOKIE POLICY

Last Updated: January 2024
ECTA Compliant (South Africa)

1. WHAT ARE COOKIES?
Cookies are small text files stored on your device when you visit a website. They help websites recognize you, remember your preferences, and track your activity.

2. WHY MEENGLE USES COOKIES
- Essential/Functional: Keep you logged in, maintain session, enable features
- Analytical: Understand how users interact with MEENGLE (Google Analytics)
- Preference: Remember your settings, language, theme
- Marketing: Track conversion goals and user journeys

3. TYPES OF COOKIES MEENGLE USES
- session_id: Maintain your login session
- auth_token: Authentication token for API requests (30 days)
- user_preferences: Remember your settings (1 year)
- _ga: Google Analytics tracking (2 years)
- _gid: Google Analytics session tracking (24 hours)
- language_preference: Remember your language choice (1 year)
- theme_preference: Remember light/dark theme choice (1 year)

4. THIRD-PARTY COOKIES
We use third-party services that may set their own cookies:
- Google Analytics: Tracks website usage
- Stripe: Processes payments securely
- Socket.IO: Enables real-time messaging

5. MANAGING COOKIES
You can control cookies through your browser settings:
- Chrome: Settings ? Privacy and security ? Cookies and other site data
- Firefox: Preferences ? Privacy & Security ? Cookies and Site Data
- Safari: Preferences ? Privacy ? Cookies and website data

6. DISABLING COOKIES
You can disable cookies, but this may affect functionality:
- You may be logged out automatically
- Your preferences won't be saved
- Some features may not work properly

7. CONSENT
When you first visit MEENGLE, you'll see a cookie consent banner. By accepting:
- You consent to all cookies listed above
- You can withdraw consent anytime in settings
- Essential cookies are used regardless of consent

For questions: privacy@meengle.co.za

© 2024 MEENGLE (PTY) LTD. ECTA Compliant.''';
  }

  String _getSafetyTips() {
    return '''MEENGLE - SAFETY TIPS
South African Edition

Your safety is our top priority. Follow these guidelines.

?? PROTECTING YOUR ACCOUNT
- Use a strong, unique password (12+ characters)
- Enable two-factor authentication in Settings
- Never share your password
- Keep your email secure

?? PROFILE & PHOTO SAFETY
- Use recent, clear photos of yourself
- Don't share identifying information in bio
- Never post explicit photos (illegal in certain circumstances)
- Be cautious with location sharing

?? SAFE MESSAGING PRACTICES
- Take time before meeting (at least a week)
- Verify their story - ask questions
- Trust your instincts
- NEVER send money (biggest red flag!)

Red Flags:
? They ask for money or Bitcoin
? They claim to love you after days
? Only 1-2 photos
? Refuse to video call
? Claim to be "newly in town"
? Claim to be rich/mysterious

?? MEETING SAFELY IN SOUTH AFRICA
Safe Public Places:
- Johannesburg: Sandton, Menlyn, The Grove
- Cape Town: V&A Waterfront, Camps Bay
- Durban: The Pavilion, Umhlanga
- Pretoria: Hatfield, Menlyn

Safety Checklist:
? Tell a trusted friend where you're going
? Share your location via WhatsApp
? Arrange your own transportation (Uber, Bolt, Indriver)
? Keep your phone charged
? Set up a safety call (friend checks after 30 mins)
? Meet during daylight for first dates
? Do a video call before meeting

?? FINANCIAL SAFETY
NEVER:
? Send money to someone you haven't met
? Share credit card information via message
? Invest in cryptocurrencies they promote
? Buy gift cards at their request

?? EMERGENCY CONTACTS (South Africa)
- SAPS: 10177 (toll-free) or 0860 10 10 10
- Emergency Services: 112 (mobile)
- SAPS Crime Line: 086 001 0600
- Rape Crisis: 0800 35 2500 (24/7)
- Gender-Based Violence: 0800 050 150

If you feel unsafe:
1. Leave immediately
2. Tell staff/security
3. Call SAPS on 10177
4. Go to nearest police station

Report to MEENGLE: safety@meengle.co.za

Remember: Your safety is more important than anything else.

© 2024 MEENGLE (PTY) LTD. South Africa.''';
  }

  String _getFAQ() {
    return '''MEENGLE - FREQUENTLY ASKED QUESTIONS

Q: How do I create a MEENGLE account?
A: Click "Sign Up", enter your email, create a password, verify your email, complete your profile with photos and bio, and start discovering matches!

Q: Do I need to use my real name and photo?
A: Yes. MEENGLE requires authentic profiles to maintain trust and safety. Catfishing is against our community guidelines.

Q: Is MEENGLE safe?
A: MEENGLE has photo verification, profile review, blocking/reporting tools, and AI fraud detection. Always meet in public, verify information independently, and trust your instincts.

Q: What age do I need to be?
A: You must be at least 18 years old. We verify age during signup.

Q: How does matching work?
A: MEENGLE uses AI-powered matching based on location, age preferences, interests, values, and activity. The algorithm learns from your interactions.

Q: What's the difference between free and premium?
A: Free: 10 daily swipes, basic messaging
Premium: Unlimited swipes, advanced search, no ads, boost feature

Q: Can I delete my account?
A: Yes. Go to Settings ? Account ? Delete Account. Your data will be deleted within 30-90 days.

Q: How do I report someone?
A: Click the menu on their profile or message and select "Report". Choose the reason and provide details.

Q: What happens if I'm banned?
A: Violations result in warnings, suspension, or permanent ban depending on severity. Serious crimes are reported to SAPS.

Q: How is my data protected?
A: We use SSL/TLS encryption, password hashing, access controls, and follow POPIA (South Africa's data protection law).

Q: Can I unsubscribe from emails?
A: Yes. Go to Settings ? Email Preferences or click "Unsubscribe" in any marketing email.

Q: How do I contact support?
A: Email support@meengle.co.za or go to Settings ? Help & Support.

Q: Is MEENGLE available in South Africa?
A: Yes! MEENGLE is fully adapted for South Africa with POPIA compliance, local contacts, and SAPS emergency information.

For more questions, email: support@meengle.co.za

© 2024 MEENGLE (PTY) LTD.''';
  }
}
