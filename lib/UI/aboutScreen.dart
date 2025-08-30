import 'package:flutter/material.dart';

class AnxietyContentScreen extends StatelessWidget {
  const AnxietyContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Understanding Anxiety',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Card
            _buildIntroCard(),
            const SizedBox(height: 20),
            
            // Section 1: What is Anxiety?
            _buildSection(
              context: context,
              title: "1. What is Anxiety?",
              icon: Icons.psychology,
              color: const Color(0xFFFFD700),
              content: _buildAnxietyDefinitionContent(),
            ),
            
            // Section 2: Fight-or-Flight Response
            _buildSection(
              context: context,
              title: "2. God's Design: Fight-or-Flight Response",
              icon: Icons.favorite,
              color: const Color(0xFFFFD700),
              content: _buildFightOrFlightContent(),
            ),
            
            // Section 3: Neuroplasticity
            _buildSection(
              context: context,
              title: "3. The Role of Neuroplasticity",
              icon: Icons.psychology_alt,
              color: const Color(0xFFFFD700),
              content: _buildNeuroplasticityContent(),
            ),
            
            // Section 4: Childhood Experiences
            _buildSection(
              context: context,
              title: "4. Childhood Experiences & Anxiety",
              icon: Icons.child_care,
              color: const Color(0xFFFFD700),
              content: _buildChildhoodContent(),
            ),
            
            // Section 5: Perilous Times
            _buildSection(
              context: context,
              title: "5. Anxiety in Perilous Times",
              icon: Icons.public,
              color: const Color(0xFFFFD700),
              content: _buildPerilousTimesContent(),
            ),
            
            // Section 6: Natural Anxiety vs Spirit of Fear
            _buildSection(
              context: context,
              title: "6. Natural Anxiety vs Spirit of Fear",
              icon: Icons.balance,
              color: const Color(0xFFFFD700),
              content: _buildAnxietyVsFearContent(),
            ),
            
            // Battle Section: Satan's Role
            _buildBattleSection(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Color(0xFFFFD700),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Understanding Anxiety',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'A comprehensive guide to understanding anxiety from both scientific and Christian perspectives.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB0B0B0),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFFFFD700),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFD700),
            ),
          ),
          iconColor: const Color(0xFFFFD700),
          collapsedIconColor: const Color(0xFFFFD700),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A0000), Color(0xFF2A0000)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield, color: Color(0xFFFF6B6B), size: 24),
          ),
          title: const Text(
            'Battle Section: Satan\'s Role in Anxiety',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
          iconColor: const Color(0xFFFF6B6B),
          collapsedIconColor: const Color(0xFFFF6B6B),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentText(
                    'The enemy often exploits our unhealed wounds and traumas as open doors for his schemes. When emotional or spiritual healing has not taken place, Satan sees this as an opportunity to introduce the spirit of fear—a counterfeit emotion not given to us by God.',
                  ),
                  const SizedBox(height: 16),
                  _buildSubheading('Satan\'s Strategy: A Master Plan of Destruction'),
                  _buildContentText('Satan does not stop at the initial wound. He builds on it by planting lies that redefine your identity based on trauma:'),
                  const SizedBox(height: 12),
                  _buildWarningBox('He attacks your identity:', '"You don\'t belong anywhere. You are worthless and unworthy of love."'),
                  _buildWarningBox('He isolates you from others:', '"Everyone is staring at you because you\'re ugly. No one wants you—not even your own parents."'),
                  const SizedBox(height: 16),
                  _buildSubheading('The Cascade of Destruction: When Fear Invites Other Spirits'),
                  const SizedBox(height: 12),
                  _buildDestructionStep('1. Anger', 'When you feel the world is against you, anger may rise as a defense mechanism.'),
                  _buildDestructionStep('2. Depression', 'Unable to reconcile your emotions, you retreat into isolation. A deep sadness settles over you.'),
                  _buildDestructionStep('3. Suicidal Thoughts', 'Now, the enemy whispers: "End it all. You don\'t have to suffer anymore."'),
                  const SizedBox(height: 16),
                  _buildVictoryBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildIntroCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFFFFD700), width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFFFFD700).withOpacity(0.1),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: const Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.psychology,
  //               color: Color(0xFFFFD700),
  //               size: 28,
  //             ),
  //             SizedBox(width: 12),
  //             Text(
  //               'Understanding Anxiety',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(0xFFFFD700),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 16),
  //         Text(
  //           'A comprehensive guide to understanding anxiety from both scientific and Christian perspectives.',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Color(0xFFB0B0B0),
  //             height: 1.5,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSection({
  //   required String title,
  //   required IconData icon,
  //   required Color color,
  //   required Widget content,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF2A2A2A),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.3),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Theme(
  //       data: Theme.of(context as BuildContext).copyWith(
  //         dividerColor: Colors.transparent,
  //         colorScheme: Theme.of(context as BuildContext).colorScheme.copyWith(
  //           primary: const Color(0xFFFFD700),
  //         ),
  //       ),
  //       child: ExpansionTile(
  //         leading: Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.2),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: color.withOpacity(0.3)),
  //           ),
  //           child: Icon(icon, color: color, size: 24),
  //         ),
  //         title: Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: 17,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFFFFD700),
  //           ),
  //         ),
  //         iconColor: const Color(0xFFFFD700),
  //         collapsedIconColor: const Color(0xFFFFD700),
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: const BoxDecoration(
  //               color: Color(0xFF1E1E1E),
  //               borderRadius: BorderRadius.only(
  //                 bottomLeft: Radius.circular(12),
  //                 bottomRight: Radius.circular(12),
  //               ),
  //             ),
  //             child: content,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAnxietyDefinitionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'Anxiety is a natural response to stress. In small doses, it can actually be helpful—alerting us to danger, helping us focus, and preparing us for important events. However, anxiety disorders go beyond everyday nervousness. They involve intense and often overwhelming fear or worry.',
        ),
        const SizedBox(height: 16),
        _buildHighlightBox(
          'Anxiety disorders are the most common mental health conditions, affecting nearly 30% of adults at some point in their lives. The good news? You can learn how to be in control of anxiety and lead fulfilling lives.',
          const Color(0xFFFFD700),
        ),
        const SizedBox(height: 16),
        _buildSubheading('When Anxiety Becomes a Disorder'),
        _buildContentText('To be diagnosed with an anxiety disorder, the fear or anxiety must:'),
        const SizedBox(height: 8),
        _buildBulletPoint('Be excessive or not appropriate for the situation or age'),
        _buildBulletPoint('Disrupt the person\'s ability to function in daily life (work, school, relationships, etc.)'),
      ],
    );
  }

  Widget _buildFightOrFlightContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'God, in his divine wisdom, created the human body with intricate systems to help us respond to danger, threats, or high-stress situations. One of those systems is the fight-or-flight response, which is an automatic, God-given reaction designed to protect us.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('The Science Behind It (Created by God)'),
        _buildContentText(
          'When faced with a perceived threat, the brain\'s amygdala sends a distress signal to the hypothalamus, which activates the autonomic nervous system—specifically, the sympathetic nervous system. This triggers the release of adrenaline (epinephrine) and other stress hormones.',
        ),
        const SizedBox(height: 12),
        _buildContentText('These changes prepare the body to either confront the danger (fight) or flee from it (flight):'),
        const SizedBox(height: 8),
        _buildBulletPoint('Heart rate increases – pumps blood to muscles faster'),
        _buildBulletPoint('Breathing quickens – increases oxygen intake'),
        _buildBulletPoint('Muscles tense – ready to act'),
        _buildBulletPoint('Pupils dilate – sharpens vision'),
        _buildBulletPoint('Digestion slows – to conserve energy'),
        const SizedBox(height: 16),
        _buildScriptureBox(
          '✝ The Christian Perspective',
          'The fight-or-flight system is not a flaw—it is a God-designed feature of your body to help you survive and stay alert.',
          [
            '"Be alert and of sober mind. Your enemy the devil prowls around like a roaring lion looking for someone to devour." – 1 Peter 5:8 (NIV)',
            '"The prudent see danger and take refuge, but the simple keep going and pay the penalty." – Proverbs 27:12 (NIV)',
          ],
        ),
      ],
    );
  }

  Widget _buildNeuroplasticityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'Neuroplasticity refers to the brain\'s ability to reorganize and form new neural connections throughout life. This remarkable ability allows the brain to adapt in response to experiences, learning, trauma, and even thought patterns.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('1. How Anxiety Is Reinforced Through Neuroplasticity'),
        _buildContentText(
          'When someone experiences chronic anxiety, their brain can form and strengthen neural pathways associated with fear, worry, and hypervigilance. Over time, these anxious thought patterns become habitual.',
        ),
        const SizedBox(height: 12),
        _buildContentText('For example:'),
        _buildBulletPoint('Constant worry strengthens neural loops of fear and rumination'),
        _buildBulletPoint('Avoidance behaviors reinforce the belief that certain situations are dangerous'),
        _buildBulletPoint('Negative self-talk deepens patterns of insecurity and panic'),
        const SizedBox(height: 16),
        _buildSubheading('2. Healing Anxiety Through Neuroplasticity'),
        _buildContentText(
          'The good news is that the same neuroplastic processes that create anxiety can also be used to heal and transform the anxious mind. Through intentional practices, the brain can form new, healthier pathways.',
        ),
        const SizedBox(height: 12),
        _buildContentText('This can include:'),
        _buildBulletPoint('Cognitive Behavioral Therapy (CBT) to reshape negative thinking'),
        _buildBulletPoint('Mindfulness and prayer, which calm the nervous system'),
        _buildBulletPoint('Gratitude and worship, which shift focus from fear to faith'),
        _buildBulletPoint('Scripture meditation, which replaces lies with God\'s truth'),
        const SizedBox(height: 16),
        _buildScriptureBox(
          'A Christian Perspective',
          'God designed our brains with the capacity for renewal and transformation.',
          ['"Do not be conformed to this world, but be transformed by the renewing of your mind." – Romans 12:2'],
        ),
      ],
    );
  }

  Widget _buildChildhoodContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'Childhood is a foundational period during which emotional, psychological, and neurological patterns are formed. The experiences a child undergoes—whether nurturing or traumatic—play a critical role in shaping how they perceive themselves, others, and the world around them.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('1. Early Experiences Shape Core Beliefs'),
        _buildContentText(
          'When a child experiences neglect, abuse, abandonment, criticism, or instability, their brain may begin to associate the world with danger, rejection, or unpredictability.',
        ),
        const SizedBox(height: 12),
        _buildContentText('These experiences can form core beliefs, such as:'),
        _buildBulletPoint('"I\'m not safe."'),
        _buildBulletPoint('"I\'m not good enough."'),
        _buildBulletPoint('"People will leave me."'),
        _buildBulletPoint('"I can\'t trust anyone."'),
        const SizedBox(height: 16),
        _buildSubheading('2. Attachment and Emotional Regulation'),
        _buildContentText(
          'Children learn how to regulate their emotions by watching and being comforted by their caregivers. If a caregiver is emotionally unavailable, inconsistent, or volatile, the child may struggle to develop healthy emotional regulation.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('3. Development of the Nervous System'),
        _buildContentText(
          'Repeated stress or trauma in childhood—often called Adverse Childhood Experiences (ACEs)—can dysregulate a child\'s nervous system.',
        ),
        const SizedBox(height: 16),
        _buildScriptureBox(
          'A Christian Perspective',
          'From a biblical standpoint, we are called to bring our brokenness to God for healing and restoration. The pain of childhood is real, but it does not have to define us.',
          ['God is a Father to the fatherless (Psalm 68:5) and a healer of the brokenhearted.'],
        ),
      ],
    );
  }

  Widget _buildPerilousTimesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'In today\'s world, we are increasingly exposed to uncertainty, social unrest, global crises, violence, and economic instability—circumstances often referred to as perilous times.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('1. Constant Exposure to Distressing News'),
        _buildContentText(
          'With the 24/7 news cycle and social media, individuals are constantly exposed to headlines of disaster, violence, disease, and division.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('2. Loss of Safety and Predictability'),
        _buildContentText(
          'One of the greatest contributors to anxiety is uncertainty. In times of global or societal upheaval, people often feel a loss of control over their environment.',
        ),
        const SizedBox(height: 16),
        _buildSubheading('3. Collective Trauma and Emotional Contagion'),
        _buildContentText(
          'During perilous times, communities often experience collective trauma, such as the emotional toll of pandemics, wars, or widespread injustice.',
        ),
        const SizedBox(height: 16),
        _buildScriptureBox(
          'A Christian Perspective',
          'Scripture speaks clearly about perilous times: "But know this, that in the last days perilous times will come…" (2 Timothy 3:1). While the world may feel increasingly chaotic, God\'s Word offers peace in the midst of the storm.',
          [
            '"God is our refuge and strength, a very present help in trouble. Therefore we will not fear…" (Psalm 46:1-2)',
            '"You will keep in perfect peace those whose minds are steadfast, because they trust in you." (Isaiah 26:3)',
          ],
        ),
      ],
    );
  }

  Widget _buildAnxietyVsFearContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentText(
          'From a Christian viewpoint, it\'s important to distinguish between natural anxiety and the spirit of fear. Struggling with natural forms of anxiety—such as circumspection, caution, and alertness in response to potential danger—does not mean that a person is demon-possessed.',
        ),
        const SizedBox(height: 16),
        _buildHighlightBox(
          'A lack of clarity on this distinction can lead believers to unnecessary guilt and spiritual confusion. Many may feel as though experiencing anxiety is a sign that they are not trusting God, which can create shame or spiritual discouragement.',
          const Color(0xFFFFD700),
        ),
        const SizedBox(height: 16),
        _buildContentText(
          'However, God designed the human body with mechanisms to respond to danger and protect itself. This instinct is natural and even beneficial when it functions within healthy boundaries.',
        ),
        const SizedBox(height: 16),
        _buildContentText(
          'The issue arises when anxiety becomes disproportionate—when it overwhelms, controls, or paralyzes. This is when the spirit of fear may be at work, and deeper spiritual intervention and healing may be necessary.',
        ),
      ],
    );
  }

  // Widget _buildBattleSection() {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 20),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFF4A0000), Color(0xFF2A0000)],
  //       ),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFFFF6B6B).withOpacity(0.2),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Theme(
  //       data: Theme.of(context as BuildContext).copyWith(
  //         dividerColor: Colors.transparent,
  //       ),
  //       child: ExpansionTile(
  //         leading: Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFFF6B6B).withOpacity(0.2),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
  //           ),
  //           child: const Icon(Icons.shield, color: Color(0xFFFF6B6B), size: 24),
  //         ),
  //         title: const Text(
  //           'Battle Section: Satan\'s Role in Anxiety',
  //           style: TextStyle(
  //             fontSize: 17,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFFFF6B6B),
  //           ),
  //         ),
  //         iconColor: const Color(0xFFFF6B6B),
  //         collapsedIconColor: const Color(0xFFFF6B6B),
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: const BoxDecoration(
  //               color: Color(0xFF1E1E1E),
  //               borderRadius: BorderRadius.only(
  //                 bottomLeft: Radius.circular(12),
  //                 bottomRight: Radius.circular(12),
  //               ),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 _buildContentText(
  //                   'The enemy often exploits our unhealed wounds and traumas as open doors for his schemes. When emotional or spiritual healing has not taken place, Satan sees this as an opportunity to introduce the spirit of fear—a counterfeit emotion not given to us by God.',
  //                 ),
  //                 const SizedBox(height: 16),
  //                 _buildSubheading('Satan\'s Strategy: A Master Plan of Destruction'),
  //                 _buildContentText('Satan does not stop at the initial wound. He builds on it by planting lies that redefine your identity based on trauma:'),
  //                 const SizedBox(height: 12),
  //                 _buildWarningBox('He attacks your identity:', '"You don\'t belong anywhere. You are worthless and unworthy of love."'),
  //                 _buildWarningBox('He isolates you from others:', '"Everyone is staring at you because you\'re ugly. No one wants you—not even your own parents."'),
  //                 const SizedBox(height: 16),
  //                 _buildSubheading('The Cascade of Destruction: When Fear Invites Other Spirits'),
  //                 const SizedBox(height: 12),
  //                 _buildDestructionStep('1. Anger', 'When you feel the world is against you, anger may rise as a defense mechanism.'),
  //                 _buildDestructionStep('2. Depression', 'Unable to reconcile your emotions, you retreat into isolation. A deep sadness settles over you.'),
  //                 _buildDestructionStep('3. Suicidal Thoughts', 'Now, the enemy whispers: "End it all. You don\'t have to suffer anymore."'),
  //                 const SizedBox(height: 16),
  //                 _buildVictoryBox(),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFFE0E0E0),
        height: 1.6,
      ),
    );
  }

  Widget _buildSubheading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFE0E0E0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFFFFD700),
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildScriptureBox(String title, String description, List<String> verses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFE0E0E0),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...verses.map((verse) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2A0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
            ),
            child: Text(
              verse,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF81C784),
                height: 1.4,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE0C0C0),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestructionStep(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8C00),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFE0E0E0),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A4A1A), Color(0xFF0A3A0A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Breaking Free: Healing from Fear, Lies, and Trauma',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Freedom begins with a renewed belief system. Healing doesn\'t mean pretending the trauma never happened—it means interpreting it through the truth of God\'s Word. We are not defined by our pain. Our scars become testimonies of God\'s power to redeem and restore.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF81C784),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}