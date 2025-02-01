import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../controllers/task_controller.dart';
import '../../core/utils/notification_helper.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Track input fields dynamically
  final RxList<TextEditingController> _controllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  bool get canAddMore => _controllers.length < 5;

  Widget _buildTaskInputs() {
    return Obx(() => Column(
      children: [
        ...List.generate(_controllers.length, (index) => 
          _buildTaskInput(index)
        ),
        if (canAddMore)
          TextButton.icon(
            onPressed: () {
              _controllers.add(TextEditingController());
            },
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF7C9A92)),
            label: Text(
              'Add another task',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7C9A92),
              ),
            ),
          ).animate().fadeIn(),
      ],
    ));
  }

  Widget _buildTaskInput(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter your task...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            if (_controllers.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () {
                  _controllers[index].dispose();
                  _controllers.removeAt(index);
                },
              ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 200 * index))
      .slideX();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C9A92).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Main content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ).animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -10, end: 0),
                      
                    const SizedBox(height: 20),
                    
                    // Welcome Text with Animation
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Welcome Onboard!',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                      
                    const SizedBox(height: 30),
                    
                    // Task Image with animation
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/task.png',
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ).animate()
                      .fadeIn(duration: 800.ms)
                      .scaleXY(begin: 0.8, end: 1.0),
                      
                    const SizedBox(height: 25),
                    
                    // Subtitle with shimmer effect
                    ShimmerText(
                      'Add What your want to do later on...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF7C9A92),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Task Input Fields with animations
                    _buildTaskInputs(),
                    
                    const SizedBox(height: 30),
                    
                    // Add to List Button with animation
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final taskController = Get.find<TaskController>();
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          final tasks = _controllers
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();
              
          if (tasks.isNotEmpty) {
            for (final task in tasks) {
              await taskController.createTask(task);
            }
          } else {
            NotificationHelper.showError('Please enter at least one task');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C9A92),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF7C9A92).withOpacity(0.3),
        ),
        child: Text(
          'Add Task to list',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: 500.ms)
      .slideY(begin: 10, end: 0);
  }
}

class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ShimmerText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          const Color(0xFF7C9A92),
          const Color(0xFF7C9A92).withOpacity(0.5),
          const Color(0xFF7C9A92),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: 2000.ms,
      color: Colors.white.withOpacity(0.5),
    );
  }
} 