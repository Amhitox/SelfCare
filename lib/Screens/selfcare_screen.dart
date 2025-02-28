import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfCareScreen extends StatefulWidget {
  const SelfCareScreen({super.key});

  @override
  _SelfCareScreenState createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen> {
  String selectedCategory = 'Mental Health';

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Mental Health',
      'icon': Icons.psychology,
      'color': Color(0xFFFF9999),
      'resources': [
        {
          'title': 'Understanding Anxiety and Depression',
          'type': 'Article',
          'duration': '8 min',
          'image': 'https://images.unsplash.com/photo-1545389336-cf090694435e',
          'description':
              'Learn about the signs, symptoms, and coping strategies...',
          'url': 'https://www.healthline.com/health/anxiety-depression',
        },
        {
          'title': 'Mindfulness Meditation Guide',
          'type': 'Guide',
          'duration': '10 min',
          'image':
              'https://images.unsplash.com/photo-1527525443983-6e60c75fff46',
          'description': 'A beginner\'s guide to mindfulness meditation...',
          'url': 'https://www.mindful.org/how-to-meditate/',
        },
        {
          'title': 'Self-Care for Mental Health',
          'type': 'Resource',
          'duration': '12 min',
          'image':
              'https://images.unsplash.com/photo-1517842645767-c639042777db',
          'description':
              'Practical self-care strategies for mental wellness...',
          'url': 'https://www.psychologytoday.com/us/basics/self-care',
        },
      ],
    },
    {
      'title': 'Beauty & Skincare',
      'icon': Icons.spa,
      'color': Color(0xFFB19CD9),
      'resources': [
        {
          'title': 'Building a Skincare Routine',
          'type': 'Guide',
          'duration': '15 min',
          'image':
              'https://images.unsplash.com/photo-1498843053639-170ff2122f35',
          'description':
              'A comprehensive guide to creating your perfect skincare routine...',
          'url':
              'https://www.healthline.com/health/beauty-skin-care/skin-care-routine-steps',
        },
        {
          'title': 'Natural Beauty Remedies',
          'type': 'DIY Guide',
          'duration': '10 min',
          'image':
              'https://images.unsplash.com/photo-1522337660859-02fbefca4702',
          'description': 'DIY beauty treatments using natural ingredients...',
          'url': 'https://www.wellandgood.com/natural-beauty-remedies/',
        },
        {
          'title': 'Understanding Your Skin Type',
          'type': 'Article',
          'duration': '7 min',
          'image':
              'https://images.unsplash.com/photo-1540555700478-4be289fbecef',
          'description': 'How to identify and care for your skin type...',
          'url':
              'https://www.byrdie.com/how-to-determine-your-skin-type-4588619',
        },
      ],
    },
    {
      'title': 'Nutrition',
      'icon': Icons.restaurant,
      'color': Color(0xFF98D8AA),
      'resources': [
        {
          'title': 'Balanced Diet Essentials',
          'type': 'Guide',
          'duration': '12 min',
          'image':
              'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38',
          'description': 'Understanding the basics of a balanced diet...',
          'url': 'https://www.healthline.com/nutrition/healthy-eating-basics',
        },
        {
          'title': 'Meal Prep for Beginners',
          'type': 'Guide',
          'duration': '15 min',
          'image':
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352',
          'description': 'Getting started with meal preparation...',
          'url':
              'https://www.eatingwell.com/article/290666/the-ultimate-meal-prep-guide-for-beginners/',
        },
        {
          'title': 'Mindful Eating Practice',
          'type': 'Article',
          'duration': '8 min',
          'image':
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
          'description': 'Learn about mindful eating and its benefits...',
          'url': 'https://www.healthline.com/nutrition/mindful-eating-guide',
        },
      ],
    },
    {
      'title': 'Fitness',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFFB562),
      'resources': [
        {
          'title': 'Beginner\'s Guide to Yoga',
          'type': 'Guide',
          'duration': '20 min',
          'image':
              'https://images.unsplash.com/photo-1506126613408-eca07ce68773',
          'description': 'Start your yoga journey with basic poses...',
          'url': 'https://www.yogajournal.com/practice/beginners/',
        },
        {
          'title': 'Home Workout Routines',
          'type': 'Workout',
          'duration': '15 min',
          'image':
              'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
          'description': 'Effective exercises you can do at home...',
          'url': 'https://www.self.com/story/best-at-home-workouts',
        },
        {
          'title': 'Benefits of Walking',
          'type': 'Article',
          'duration': '6 min',
          'image':
              'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8',
          'description': 'Why walking is great for your health...',
          'url':
              'https://www.mayoclinic.org/healthy-lifestyle/fitness/in-depth/walking/art-20046261',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': '10 Minutes Morning Self-Care Routine',
      'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773',
      'category': 'Mental Health',
      'readTime': '5 min read',
      'isFeatured': true,
      'description':
          'Start your day with these simple yet effective self-care practices...',
    },
    {
      'title': 'Natural Skincare Tips for Glowing Skin',
      'image': 'https://images.unsplash.com/photo-1526947425960-945c6e72858f',
      'category': 'Beauty & Skincare',
      'readTime': '4 min read',
      'isFeatured': false,
      'description':
          'Discover natural ingredients for healthy, radiant skin...',
    },
    {
      'title': 'Mindful Eating Habits for Better Health',
      'image': 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38',
      'category': 'Nutrition',
      'readTime': '6 min read',
      'isFeatured': true,
      'description':
          'Learn how to develop a healthier relationship with food...',
    },
    {
      'title': 'Gentle Yoga for Stress Relief',
      'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773',
      'category': 'Fitness',
      'readTime': '7 min read',
      'isFeatured': false,
      'description': 'Easy yoga poses to help you relax and de-stress...',
    },
  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryData = categories.firstWhere(
      (category) => category['title'] == selectedCategory,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Featured Resources',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            _buildResourcesList(selectedCategoryData),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Self-Care',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Take care of yourself today',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['title'] == selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category['title']),
            child: Container(
              width: 100,
              margin: EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: isSelected
                    ? category['color']
                    : category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category['color'].withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : category['color'].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : category['color'],
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourcesList(Map<String, dynamic> categoryData) {
    final resources = categoryData['resources'] as List;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: resources.length,
        (context, index) {
          final resource = resources[index];

          return Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchUrl(resource['url']),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          resource['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryData['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                resource['type'],
                                style: TextStyle(
                                  color: categoryData['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              resource['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              resource['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  resource['duration'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: categoryData['color'],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
