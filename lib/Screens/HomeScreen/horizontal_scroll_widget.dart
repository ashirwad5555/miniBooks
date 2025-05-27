import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mini_books/Screens/BookSummaryPage/BookDetails.dart';

// Static top books data
final List<Map<String, dynamic>> staticTopBooks = [
    {
    "title": "10-Minute Toughness",
    "author": "",
    "coverImage": "path/to/default_image.png",
    "aiGeneratedSummary": [
      {
        "title": "15-Second Centered Breath",
        "content":
            "A technique to control heart rate and improve focus under pressure. Breathe in for six seconds, hold for two, and breathe out for seven. This triggers a relaxation response and steadies heart rate, enhancing clear thinking and performance."
      },
      {
        "title": "Performance Statement",
        "content":
            "A personalized statement that focuses on what it takes to be successful in competition. It helps reduce negative self-talk and maintains focus on key performance aspects. For example, a cyclist might use /'Weight back and breathe easy,/' while a business executive might use /'Listen first; then decide; be swift and confident./'"
      },
      {
        "title": "Visualizations",
        "content":
            "A three-part visualization process: 1) Visualize past success, 2) Visualize ultimate success, and 3) Visualize a successful upcoming performance. Each visualization should last one minute and include sensory details (what you see, hear, and feel). End each visualization by congratulating yourself on an excellent performance."
      },
      {
        "title": "Identity Statement",
        "content":
            "A tool to boost self-confidence and shape self-image. It follows the format: /'I am incredibly [key strength]; I am the [what you want to be known for]./' For example: /'I am more motivated than my competition; I am the most effective sports psychology consultant in the world./'"
      },
      {
        "title": "10-MT Workout",
        "content":
            "A comprehensive mental workout designed to control arousal, create precise and effective focus, and improve self-image. It combines the centered breath, performance statement, visualizations, and identity statement into a structured routine for mental toughness."
      }
    ],
    "category Tags": [
      "Self-Help",
      "Sports & Outdoors",
      "Psychology & Counseling"
    ],
    "main_tag": "Philosophy, Psychology & Self-Help"
  },
  {
    "title":
        "100 Focused 25 Great Ways To Improve Your Focus And Concentration How To Be 100",
    "author": "",
    "coverImage":
        "Book_covers/job_GzWXDCIfS6K3sJ34i8U_xg_results/0044_1_an-alternative-book-cover-for-100-focuse_CWMmEtXrRheNpyySveMvXQ_2SlWfPbMRDKtzjLWmeDCxQ.png",
    "aiGeneratedSummary": [
      {
        "title": "Be Aware of How Your Mind Works",
        "content":
            "Develop metacognition, the ability to be aware of how your mind works. Observe your thought processes, use self-reflection questions, and keep a journal to identify patterns in your thinking. This awareness will help you develop strategies to improve concentration."
      },
      {
        "title": "Set Your Priorities and Create a Schedule",
        "content":
            "Identify tasks that are truly important and create an effective schedule around them. Prioritizing helps you focus on what matters most and allocate your time and energy efficiently."
      },
      {
        "title": "Finish the Current Task Before Moving To Another One",
        "content":
            "Minimize attention residue by avoiding leaving tasks unfinished. Whenever possible, complete one task before moving on to another to maintain focus and reduce mental clutter."
      },
      {
        "title": "The Mind Sprint Exercise",
        "content":
            "Practice focused work sessions, starting with short periods and gradually increasing the duration. This exercise trains your mind to maintain concentration for longer periods, eventually allowing you to work without distraction for hours."
      },
      {
        "title": "Take Breaks Strategically In Your Working Hours",
        "content":
            "Incorporate strategic breaks into your work schedule. Resting your mind and body for a few minutes between difficult tasks helps manage stress and maintain focus over longer periods."
      },
      {
        "title": "Learn and Practice Compartmentalization",
        "content":
            "Master the skill of compartmentalization, which is the opposite of multitasking. Fully immerse your mind in one task at a time, blocking out everything unrelated. This technique enhances focus and productivity by eliminating distractions."
      }
    ],
    "category Tags": [
      "Self-Help, Cognitive Psychology, Personal Growth, Mental Health, Productivity"
    ],
    "main_tag": "Miscellaneous"
  },
  {
    "title":
        "100 Free Tools to Create Content for Social Media  Web 2022 Free Online Tools Book 2",
    "author": "",
    "coverImage":
        "Book_covers/job_GzWXDCIfS6K3sJ34i8U_xg_results/0043_4_a-digital-illustration-of-a-book-with-th_zNbtzYbsS0O23scwOI28Pw_ZkqMcLOsRqSJPfYPQ7sdfQ_cover.png",
    "aiGeneratedSummary": [
      {
        "title": "Free Stock Photo Resources",
        "content":
            "46 amazing sites offering free stock photos for commercial use without attribution. Includes searchable databases and specialized sites like openclipart.org for clip art."
      },
      {
        "title": "Understanding Picture Copyrights",
        "content":
            "Explanation of CC0 and CC1 licenses. CC0 allows free editing, distribution, and publication for personal or commercial use without attribution. CC1 requires appropriate credit according to specified requirements."
      },
      {
        "title": "Online Image Editing Tools",
        "content":
            "6 powerful online image editing tools, including BeFunky for customized graphic designs, effects, collages, and selfie editing. These tools offer templates or from-scratch design options."
      },
      {
        "title": "Smartphone Photo Editing Apps",
        "content":
            "8 best photo editor apps for creating beautiful images directly on smartphones, enhancing mobile photography capabilities."
      },
      {
        "title": "Infographic Creation Tools",
        "content":
            "4 tools for creating educational and interactive infographics, including Canva, Easel.ly, and Pictochart for template-based designs. Google Charts for creating interactive charts embeddable in webpages."
      },
      {
        "title": "3D Book Cover Mockup Tools",
        "content":
            "7 free tools for creating 3D book cover mockups. Highlights MagicMockups for visualizing book covers, web pages, and online courses on various devices."
      },
      {
        "title": "Free Online Logo Makers",
        "content":
            "10 free online logo maker tools for text-based or icon-based logos. Features Logoshi, an AI-powered tool that generates logo variations based on business name, slogan, or even hand-drawn sketches."
      },
      {
        "title": "Screenshot and Screencast Tools",
        "content":
            "5 tools for taking and annotating screenshots and recording screencasts. Includes Recordit for simple, free screen and voice recording, ideal for creating tutorial videos."
      }
    ],
    "category Tags": [
      "Social Media Guides, Internet & Social Media, Computer & Technology, Business & Money, Digital Marketing"
    ],
    "main_tag": "Miscellaneous"
  },
  {
    "title": "100 Ways to Motivate Yourself",
    "author": "",
    "coverImage": "path/to/default_image.png",
    "aiGeneratedSummary": [
      {
        "title": "Meditate on your mortality",
        "content":
            "Use death as a motivator by imagining your last moments each morning. This practice helps you appreciate each day and live with more intensity and purpose. Remember that life is finite, which can drive you to make the most of every moment."
      },
      {
        "title": "Tell yourself, /'I am the problem/'",
        "content":
            "Shift from victim mentality to problem-solver by taking responsibility for your situation. This approach focuses your energy on what you can control - your attitude, expectations, and actions - rather than external circumstances."
      },
      {
        "title": "Wildly exaggerate your goals",
        "content":
            "Boost creativity and motivation by dramatically inflating your goals. This exercise forces you to think outside the box and generate innovative ideas to achieve seemingly impossible targets, energizing your approach to more realistic objectives."
      },
      {
        "title": "Turn everything into a game",
        "content":
            "Inject elements of competition and curiosity into your tasks to make them more engaging. Challenge yourself or others, set time limits, and approach work with a sense of playfulness to maintain motivation and interest."
      },
      {
        "title": "Forward yourself the finished list",
        "content":
            "Reinforce your identity as a /'finisher/' by sending yourself a daily email listing completed tasks. This practice boosts motivation by reminding you of your accomplishments and encouraging you to maintain productivity."
      },
      {
        "title": "Control your personal motivation",
        "content":
            "Pay attention to what inspires and motivates you. Identify your personal /'buttons/' that drive your motivation and use them to create a customized system for self-motivation."
      },
      {
        "title": "Embrace self-motivation as control",
        "content":
            "Recognize that self-motivation is about taking control of your life and actions. The more you motivate yourself, the more in control you become of your outcomes and experiences."
      },
      {
        "title": "Create a 5-day motivation program",
        "content":
            "Implement a structured approach to motivation by trying different techniques each day of the week. This method allows you to experiment with various strategies and find what works best for you."
      }
    ],
    "category Tags": [
      "Self-Help",
      "Business & Money",
      "Personal Transformation"
    ],
    "main_tag": "Philosophy, Psychology & Self-Help"
  },
  {
    "title":
        "10Minute Declutter The StressFree Habit for Simplifying Your Home",
    "author": "",
    "coverImage":
        "Book_covers/job_GzWXDCIfS6K3sJ34i8U_xg_results/0042_2_a-minimalist-book-cover-with-the-title-1_JlzOPGoHTCO04RKzW3ggLg_XqKeTBtmQve4X58VbUZkVA_cover.png",
    "aiGeneratedSummary": [
      {
        "title": "Freedom through Simplicity",
        "content":
            "The less you have, the more free you are. Organizing and eliminating clutter frees you from stress and anxiety by reducing feelings of overwhelm."
      },
      {
        "title": "Clutter as a Reflection of Inner Self",
        "content":
            "Clutter often mirrors our internal state. Feelings of disorganization, depression, stress, or insecurity can manifest in how we manage our daily lives and spaces."
      },
      {
        "title": "Designated Spaces for Sentimental Items",
        "content":
            "Allocate limited space for sentimental items, such as a single display shelf. Having a designated spot for everything makes it easier to evaluate the importance of each possession."
      },
      {
        "title": "Value Over Cost",
        "content":
            "When deciding to keep an item, focus on its current value to you rather than its original cost. If you no longer need it, it should go."
      },
      {
        "title": "Clutter as a Source of Stress",
        "content":
            "A chaotic and cluttered area is a major source of stress. Each item in a cluttered space represents an unfinished task, causing mental agitation."
      },
      {
        "title": "Simplicity and Happiness",
        "content":
            "Simplicity is crucial for happiness. Feeling satisfied with what you have and having few desires is vital for contentment."
      },
      {
        "title": "Energy Boost from Organization",
        "content":
            "A clean and organized space can increase energy levels and foster a sense of pride and control over your personal environment."
      },
      {
        "title": "Time Over Possessions",
        "content":
            "Happiness comes from how we spend our time, not from what we own. Focus on experiences rather than accumulating possessions."
      },
      {
        "title": "Letting Go with Purpose",
        "content":
            "When giving away items, do so willingly, knowing they may benefit someone else. Consider streamlining possessions to the most essential, useful, and meaningful."
      }
    ],
    "category Tags": [
      "Self-Help",
      "Home Improvement",
      "Stress Management",
      "Lifestyle",
      "Cleaning & Organizing",
    ],
    "main_tag": "Miscellaneous"
  },
 
];

class HorizontalScrollWidget extends ConsumerStatefulWidget {
  const HorizontalScrollWidget({super.key});

  @override
  _HorizontalScrollWidgetState createState() => _HorizontalScrollWidgetState();
}

class _HorizontalScrollWidgetState
    extends ConsumerState<HorizontalScrollWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= staticTopBooks.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: staticTopBooks.length,
            itemBuilder: (context, index) {
              final book = staticTopBooks[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOutQuint.transform(value),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3.0, vertical: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetails(bookData: book),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF8A65),
                                Color(0xFFFF5722),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Hero(
                                  tag: 'book-cover-${book['title']}',
                                  child: Container(
                                    width: 120,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/${book['coverImage']}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print(
                                              'Failed to load image: assets/${book['coverImage']}');
                                          return Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.grey[600],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        book['title'],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        book['author'] ?? "Unknown Author",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: staticTopBooks.length,
          effect: CustomizableEffect(
            spacing: 8,
            dotDecoration: DotDecoration(
              width: 8,
              height: 8,
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            activeDotDecoration: DotDecoration(
              width: 24,
              height: 8,
              color: const Color(0xFFFF5722),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
