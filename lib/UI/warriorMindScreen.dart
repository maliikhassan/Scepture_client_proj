import 'package:flutter/material.dart';

class WarriorsMindScreen extends StatelessWidget {
  const WarriorsMindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'A Warrior\'s Mind Devotional',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opening Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Do you have a Warriors mind in the midst of your struggles?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Christ in the Storm Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Christ in the Storm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Life can bring storms that feel overwhelming.Circumstances that tower over us like giants, uncertainties that shake our confidence, and fears that whisper, "You can\'t handle this." But as followers of Christ, we have a truth that changes everything: we can overcome anything through Him.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jesus Himself said, "Be of good cheer; I have overcome the world" (John 16:33). That means no matter how intimidating the situation looks, we have access to His victory. There is no fear we cannot conquer because we know that God is in control of everything—from the wind and waves to the unseen battles of the heart and mind.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'In Mark 4:35–41, Jesus was asleep in the boat during a violent storm while the disciples panicked. They saw danger; He saw peace. They focused on the waves; He rested in the authority He carried. That same Jesus lives in us. When we focus on the Jesus in our boat—our situation—we shift our attention from what\'s happening around us to the One who has power over it all.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This devotional, A Warrior\'s Mind, will help you anchor your heart in that truth. Through the stories of David, Gideon, Deborah, Joshua, Nehemiah, Paul, and Jesus Himself, you\'ll learn how to face anxiety, fear, and spiritual opposition with courage and victory-minded faith. Remember: the One in you is greater than anything against you. The battle may feel fierce, but with Christ in your boat, you will not sink.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section Title
            const Text(
              'A Warriors Mind Devotional',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Day 1 - David
            _buildDevotionalCard(
              day: 1,
              title: 'David: Confidence Over Fear',
              readStory: 'David, the young shepherd, faced Goliath when trained soldiers were too afraid. With a sling and stones, he declared the battle belonged to God and won. (1 Samuel 17)',
              declareScripture: '"The battle is the Lord\'s." – 1 Samuel 17:47',
              reflect: 'Anxiety magnifies the enemy. Faith magnifies the God who has never lost a battle. Your giants are no match for His power.',
              pray: 'Lord, when fear towers over me, remind me the battle is Yours. Give me courage to face my giants with trust in You.',
              warriorsMind: 'Stand before your giants knowing they fall not by your power, but by God\'s hand.',
              gradient: [const Color(0xFFFF6B6B), const Color(0xFFE74C3C)],
            ),
            
            // Day 2 - Gideon
            _buildDevotionalCard(
              day: 2,
              title: 'Gideon: Obedience Over Insecurity',
              readStory: 'Gideon called himself the least in his family, but God called him a mighty warrior. With only 300 men, he obeyed and defeated the Midianites. (Judges 6–7)',
              declareScripture: '"Go in the strength you have… Am I not sending you?" – Judges 6:14',
              reflect: 'Anxiety whispers, "You\'re not enough." God\'s voice says, "I am with you." Obedience brings victory, even in weakness.',
              pray: 'Father, replace my doubt with Your truth. Help me step into battles knowing You\'ve already equipped me.',
              warriorsMind: 'True strength is trusting God\'s command over your self-doubt.',
              gradient: [const Color(0xFFFFD93D), const Color(0xFFF39C12)],
            ),
            
            // Day 3 - Deborah
            _buildDevotionalCard(
              day: 3,
              title: 'Deborah: Courage Over Hesitation',
              readStory: 'As Israel\'s judge, Deborah led the nation into battle against Sisera\'s army. Her bold faith stirred others to act and win. (Judges 4–5)',
              declareScripture: '"Up! For this is the day the Lord has given Sisera into your hands." – Judges 4:14',
              reflect: 'Courage isn\'t fearlessness—it\'s moving forward despite it. Your faith can inspire others to fight their battles too.',
              pray: 'Lord, give me courage that moves me into action and ignites faith in those around me.',
              warriorsMind: 'Lead with faith, and fear will lose its grip—not just on you, but on those you influence.',
              gradient: [const Color(0xFF6BCF7F), const Color(0xFF27AE60)],
            ),
            
            // Day 4 - Joshua
            _buildDevotionalCard(
              day: 4,
              title: 'Joshua: Trust Over Logic',
              readStory: 'God told Joshua to take Jericho by marching around it for seven days, then shouting. Obedience—not weapons—brought the walls down. (Joshua 6)',
              declareScripture: '"See, I have delivered Jericho into your hands." – Joshua 6:2',
              reflect: 'Anxiety clings to control. Faith lets go and follows God\'s plan, even when it defies human logic.',
              pray: 'Father, help me trust Your instructions, especially when they don\'t make sense to me.',
              warriorsMind: 'Obedience to God\'s voice is the most powerful battle strategy.',
              gradient: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
            ),
            
            // Day 5 - Nehemiah
            _buildDevotionalCard(
              day: 5,
              title: 'Nehemiah: Focus Over Distraction',
              readStory: 'Nehemiah rebuilt Jerusalem\'s walls while enemies tried to stop him. He refused to be lured away from his work. (Nehemiah 4 & 6)',
              declareScripture: '"I am doing a great work and I cannot come down." – Nehemiah 6:3',
              reflect: 'Fear and distraction are tools of the enemy. Staying on mission protects your peace.',
              pray: 'Lord, keep me focused on what You\'ve called me to do. Silence the noise that tries to pull me away.',
              warriorsMind: 'Stay on your post—your focus is your fortress.',
              gradient: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
            ),
            
            // Day 6 - Paul
            _buildDevotionalCard(
              day: 6,
              title: 'Paul: Endurance Over Quitting',
              readStory: 'Paul endured prison, shipwrecks, beatings, and persecution but finished his mission faithfully. (2 Timothy 4:7; Acts 16, 27)',
              declareScripture: '"I have fought the good fight, I have finished the race, I have kept the faith." – 2 Timothy 4:7',
              reflect: 'The enemy wants you to quit early. Victory belongs to those who keep going.',
              pray: 'Jesus, give me endurance when the battle is long and my strength is low.',
              warriorsMind: 'A true warrior doesn\'t just start the fight—they finish it with faith intact.',
              gradient: [const Color(0xFFE67E22), const Color(0xFFD35400)],
            ),
            
            // Day 7 - Jesus
            _buildDevotionalCard(
              day: 7,
              title: 'Jesus: Victory Over the Enemy',
              readStory: 'After fasting 40 days, Jesus was tempted by Satan. He defeated each temptation by quoting Scripture. (Matthew 4:1–11)',
              declareScripture: '"It is written…" – Matthew 4:4, 7, 10',
              reflect: 'The enemy\'s lies are only broken by God\'s truth. The Word of God is your strongest weapon.',
              pray: 'Lord, let Your Word be my sword. Teach me to use it in every battle I face.',
              warriorsMind: 'The Word of God in your mouth is a weapon no enemy can withstand.',
              gradient: [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
            ),
            
            const SizedBox(height: 24),
            
            // The Calm After the Storm - Closing Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Calm After the Storm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'You\'ve now journeyed through the lives of warriors who faced overwhelming odds—giants, armies, walls, distractions, hardships, and even the enemy himself. Each one overcame, not because they were the strongest or smartest, but because they trusted the God who never loses a battle.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Jesus said, "Be of good cheer; I have overcome the world" (John 16:33). That victory is yours, too. The same Jesus who calmed the storm for His disciples is in your boat today. The waves may still roar, and the wind may still howl, but the presence of the Prince of Peace means you can rest even when the storm is raging.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fear will try to distract you from His authority. Anxiety will try to magnify your problem. But a warrior\'s mind focuses on the truth: Christ is in control, and nothing can stand against Him. When you keep your eyes on Him instead of the storm, you\'ll find a strength, courage, and peace that cannot be shaken.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'As you step forward from this devotional, remember the warriors who came before you. Remember that you, too, are equipped with the armor of God, the promises of Scripture, and the power of the Holy Spirit. You are not just surviving the battle—you are winning it, because the One who commands the wind and the waves is fighting for you.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'The battle belongs to the Lord. The victory belongs to you.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDevotionalCard({
    required int day,
    required String title,
    required String readStory,
    required String declareScripture,
    required String reflect,
    required String pray,
    required String warriorsMind,
    required List<Color> gradient,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day and Title
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Day $day – $title',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Read Story
                _buildSection('Read Story:', readStory),
                const SizedBox(height: 12),
                
                // Declare Scripture
                _buildSection('Declare Scripture:', declareScripture),
                const SizedBox(height: 12),
                
                // Reflect
                _buildSection('Reflect:', reflect),
                const SizedBox(height: 12),
                
                // Pray
                _buildSection('Pray:', pray),
                const SizedBox(height: 12),
                
                // Warrior's Mind
                _buildSection('Warrior\'s Mind:', warriorsMind),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}