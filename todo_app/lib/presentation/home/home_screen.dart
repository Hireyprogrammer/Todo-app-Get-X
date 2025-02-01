import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:todo_app/presentation/tasks/add_task_screen.dart';
import '../../controllers/task_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
    Get.find<TaskController>().fetchTasks();
  }

  void _showProfileMenu(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Profile section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: const AssetImage('assets/images/profile.jpeg'),
                  ).animate()
                    .fadeIn()
                    .scale(),
                  const SizedBox(height: 16),
                  Text(
                    'Fisayomi',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Menu Items
            // _buildMenuItem(
            //   icon: Icons.person_outline,
            //   title: 'Edit Profile',
            //   onTap: () {
            //     Get.back();
            //     // Add navigation to edit profile screen
            //   },
            // ),
            _buildMenuItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'Confirm Logout',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await authController.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C9A92),
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF7C9A92),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      onTap: onTap,
    ).animate()
      .fadeIn()
      .slideX();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TaskController taskController = Get.find<TaskController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showProfileMenu(context, authController),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: const AssetImage('assets/images/profile.jpeg'),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -30, end: 0),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 30, end: 0),
                ],
              ),
              const SizedBox(height: 20),
              // Welcome Text with Animation
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome to Todo-App',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 20),
              // Task Illustration
              Center(
                child: Image.asset(
                  'assets/images/home-task.png',
                  height: 180,
                ).animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 30, end: 0),
              ),
              const SizedBox(height: 30),
              // Todo Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Todo Tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.to(
                      () => const AddTaskScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF7C9A92),
                      backgroundColor: const Color(0xFF7C9A92).withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -30, end: 0),
              const SizedBox(height: 20),
              // Tasks List
              Expanded(
                child: Obx(() {
                  if (taskController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C9A92),
                      ),
                    );
                  }
                  
                  if (taskController.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading tasks',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.red.shade300,
                            ),
                          ),
                          TextButton(
                            onPressed: () => taskController.fetchTasks(),
                            child: Text(
                              'Try Again',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF7C9A92),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (taskController.tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no-tasks.png',
                            height: 120,
                          ).animate()
                            .fadeIn()
                            .scale(),
                          const SizedBox(height: 16),
                          Text(
                            'No Tasks Added Yet',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3142),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first task',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn()
                      .scale();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: taskController.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskController.tasks[index];
                      return _buildTaskItem(
                        task.title,
                        task.completed,
                        onTap: () => taskController.toggleTask(task.id),
                        onDelete: () => taskController.deleteTask(task.id),
                      ).animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index))
                        .slideX();
                    },
                  );
                }),
              ).animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 30, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(String task, bool isCompleted, {
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.white,
                  border: Border.all(
                    color: isCompleted ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.green,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : const Color(0xFF2D3142),
                  height: 1.3,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              style: IconButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 