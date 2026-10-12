import 'package:flutter/material.dart';

import '../models/student.dart';

import '../services/api_service.dart';

import 'student_detail_screen.dart';

import 'student_form_screen.dart';

const Color paper = Color(0xFFF8F8F8);

const Color ink = Color(0xFF171717);

const Color muted = Color(0xFF666666);

const Color pink = Color(0xFFE0E0E0);

const Color yellow = Color(0xFFFFFFFF);

const Color mint = Color(0xFFD5D5D5);

const Color blue = Color(0xFFF0F0F0);

const Color lavender = Color(0xFFC8C8C8);

const Color paperLine = Color(0xFFDADADA);

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController searchController = TextEditingController();

  List<Student> students = [];

  bool isLoading = true;

  String? errorMessage;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    loadStudents();

    searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;

      errorMessage = null;
    });

    try {
      final result = await apiService.getStudents();

      if (!mounted) return;

      setState(() {
        students = result;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();

        isLoading = false;
      });
    }
  }

  List<Student> get filteredStudents {
    if (searchQuery.isEmpty) return students;

    return students.where((student) {
      final name = '${student.firstName} ${student.lastName}'.toLowerCase();

      return name.contains(searchQuery) ||
          student.id.toString().contains(searchQuery) ||
          student.age.toString().contains(searchQuery);
    }).toList();
  }

  Future<void> openAddStudent() async {
    final result = await Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => const StudentFormScreen()),
    );

    if (result == true && mounted) await loadStudents();
  }

  Future<void> openStudent(Student student) async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => StudentDetailScreen(studentId: student.id),
      ),
    );
  }

  Future<void> editStudent(Student student) async {
    final result = await Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
    );

    if (result == true && mounted) await loadStudents();
  }

  Future<void> deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: paper,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),

          side: const BorderSide(color: ink, width: 2),
        ),

        title: const Text(
          'Erase this doodle?',

          style: TextStyle(color: ink, fontWeight: FontWeight.w900),
        ),

        content: Text(
          'Delete ${student.firstName} ${student.lastName}?\n'
          'This action cannot be undone.',

          style: const TextStyle(color: muted, height: 1.5),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),

            child: const Text('Keep it!', style: TextStyle(color: ink)),
          ),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: pink,

              foregroundColor: ink,
            ),

            onPressed: () => Navigator.pop(dialogContext, true),

            child: const Text('Erase'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await apiService.deleteStudent(student.id);

      if (!mounted) return;

      setState(() {
        students.removeWhere((item) => item.id == student.id);
      });

      showMessage('Student removed successfully!');
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString(), isError: true);
    }
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: isError ? const Color(0xFF222222) : ink,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,

      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),

            Expanded(
              child: RefreshIndicator(
                color: ink,

                backgroundColor: Colors.white,

                onRefresh: loadStudents,

                child: buildBody(),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddStudent,

        backgroundColor: yellow,

        foregroundColor: ink,

        elevation: 3,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),

          side: const BorderSide(color: ink, width: 2),
        ),

        icon: const Icon(Icons.add_rounded, size: 25),

        label: const Text(
          'Add Student',

          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),

      decoration: const BoxDecoration(
        color: paper,

        border: Border(bottom: BorderSide(color: paperLine, width: 2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              doodleSticker(
                icon: Icons.school_rounded,

                color: yellow,

                size: 48,
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'MY LITTLE CAMPUS',

                      style: TextStyle(
                        color: muted,

                        fontSize: 10,

                        fontWeight: FontWeight.w900,

                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Student Book',

                      style: TextStyle(
                        color: ink,

                        fontSize: 24,

                        fontWeight: FontWeight.w900,

                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Refresh',

                onPressed: isLoading ? null : loadStudents,

                icon: const Icon(Icons.refresh_rounded, color: ink),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Hey there! ✨',

                      style: TextStyle(
                        color: muted,

                        fontSize: 15,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Let's meet\nyour students!",

                      style: TextStyle(
                        color: ink,

                        fontSize: 30,

                        height: 1.15,

                        fontWeight: FontWeight.w900,

                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              Transform.rotate(
                angle: 0.10,

                child: doodleSticker(
                  icon: Icons.auto_awesome_rounded,

                  color: lavender,

                  size: 70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Transform.rotate(
            angle: -0.008,

            child: Container(
              padding: const EdgeInsets.all(17),

              decoration: BoxDecoration(
                color: yellow,

                borderRadius: BorderRadius.circular(17),

                border: Border.all(color: ink, width: 2),

                boxShadow: const [BoxShadow(color: ink, offset: Offset(3, 4))],
              ),

              child: Row(
                children: [
                  doodleSticker(
                    icon: Icons.groups_rounded,

                    color: Colors.white,

                    size: 49,
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'OUR STUDENT COLLECTION',

                          style: TextStyle(
                            color: ink,

                            fontSize: 10,

                            fontWeight: FontWeight.w900,

                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          isLoading
                              ? 'Counting...'
                              : '${students.length} students',

                          style: const TextStyle(
                            color: ink,

                            fontSize: 25,

                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.star_rounded, size: 32, color: ink),
                ],
              ),
            ),
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'YOUR NOTEBOOK',

                  style: TextStyle(
                    color: ink,

                    fontSize: 12,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 1.7,
                  ),
                ),
              ),

              Transform.rotate(
                angle: 0.08,

                child: const Text(
                  '✎ let’s search!',

                  style: TextStyle(
                    color: muted,

                    fontSize: 12,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(16),

              border: Border.all(color: ink, width: 1.7),

              boxShadow: const [
                BoxShadow(color: paperLine, offset: Offset(3, 3)),
              ],
            ),

            child: TextField(
              controller: searchController,

              style: const TextStyle(color: ink, fontWeight: FontWeight.w600),

              decoration: InputDecoration(
                hintText: 'Name, student ID, or age...',

                hintStyle: const TextStyle(color: muted, fontSize: 13),

                prefixIcon: const Icon(Icons.search_rounded, color: ink),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: searchController.clear,

                        icon: const Icon(Icons.close_rounded, color: ink),
                      )
                    : null,

                border: InputBorder.none,

                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget doodleSticker({
    required IconData icon,

    required Color color,

    double size = 48,
  }) {
    return Container(
      height: size,

      width: size,

      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(size * 0.30),

        border: Border.all(color: ink, width: 1.8),
      ),

      child: Icon(icon, color: ink, size: size * 0.53),
    );
  }

  Widget buildBody() {
    if (isLoading && students.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: ink));
    }

    if (errorMessage != null && students.isEmpty) {
      return buildState(
        icon: Icons.cloud_off_rounded,

        title: 'Oops! Connection lost',

        message: errorMessage!,

        buttonText: 'Try again',

        onPressed: loadStudents,
      );
    }

    final filtered = filteredStudents;

    if (students.isEmpty) {
      return buildState(
        icon: Icons.menu_book_rounded,

        title: 'Your notebook is empty!',

        message: 'Add your first student and start your collection.',

        buttonText: 'Add first student',

        onPressed: openAddStudent,
      );
    }

    if (filtered.isEmpty) {
      return buildState(
        icon: Icons.search_off_rounded,

        title: 'No doodles found!',

        message: 'Try another name, student ID, or age.',

        buttonText: 'Clear search',

        onPressed: searchController.clear,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        final columns = constraints.maxWidth >= 1150 ? 3 : 2;

        if (!wide) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(17, 22, 17, 105),

            itemCount: filtered.length,

            itemBuilder: (context, index) {
              return buildStudentCard(filtered[index], index);
            },
          );
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(24, 24, 24, 105),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,

            crossAxisSpacing: 18,

            mainAxisSpacing: 18,

            mainAxisExtent: 164,
          ),

          itemCount: filtered.length,

          itemBuilder: (context, index) {
            return buildStudentCard(filtered[index], index);
          },
        );
      },
    );
  }

  Widget buildStudentCard(Student student, int index) {
    const colors = [pink, mint, blue, lavender, yellow];

    final color = colors[index % colors.length];

    final initials = [student.firstName, student.lastName]
        .where((name) => name.trim().isNotEmpty)
        .map((name) => name.trim()[0].toUpperCase())
        .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 13, right: 3, left: 2),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: ink, width: 1.6),

        boxShadow: const [BoxShadow(color: paperLine, offset: Offset(3, 4))],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),

        child: Dismissible(
          key: ValueKey(student.id),

          direction: DismissDirection.horizontal,

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await deleteStudent(student);
            } else if (direction == DismissDirection.endToStart) {
              await editStudent(student);
            }

            return false;
          },

          background: swipeBackground(
            color: pink,

            icon: Icons.delete_outline_rounded,

            label: 'Erase',

            alignment: Alignment.centerLeft,
          ),

          secondaryBackground: swipeBackground(
            color: mint,

            icon: Icons.edit_rounded,

            label: 'Edit',

            alignment: Alignment.centerRight,

            reverse: true,
          ),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: () => openStudent(student),

              onLongPress: () => openStudent(student),

              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Transform.rotate(
                          angle: -0.06,

                          child: Container(
                            height: 49,

                            width: 49,

                            decoration: BoxDecoration(
                              color: color,

                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(color: ink, width: 1.5),
                            ),

                            child: Center(
                              child: Text(
                                initials.isEmpty ? '?' : initials,

                                style: const TextStyle(
                                  color: ink,

                                  fontSize: 16,

                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                '${student.firstName} ${student.lastName}',

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: ink,

                                  fontSize: 14,

                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'ID #${student.id}',

                                style: const TextStyle(
                                  color: muted,

                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        PopupMenuButton<String>(
                          tooltip: 'Student actions',

                          color: paper,

                          icon: const Icon(
                            Icons.more_horiz_rounded,

                            color: ink,
                          ),

                          onSelected: (value) {
                            if (value == 'view') {
                              openStudent(student);
                            } else if (value == 'edit') {
                              editStudent(student);
                            } else if (value == 'delete') {
                              deleteStudent(student);
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'view',

                              child: Text('View details'),
                            ),

                            PopupMenuItem(
                              value: 'edit',

                              child: Text('Edit student'),
                            ),

                            PopupMenuItem(
                              value: 'delete',

                              child: Text('Delete student'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    Container(height: 1.5, color: paperLine),

                    const SizedBox(height: 11),

                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 16, color: ink),

                        const SizedBox(width: 6),

                        Text(
                          'Age ${student.age}',

                          style: const TextStyle(
                            color: ink,

                            fontSize: 12,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          'Open note ↗',

                          style: TextStyle(
                            color: muted,

                            fontSize: 11,

                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget swipeBackground({
    required Color color,

    required IconData icon,

    required String label,

    required Alignment alignment,

    bool reverse = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22),

      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: ink, width: 1.5),
      ),

      alignment: alignment,

      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,

        children: [
          if (reverse) ...[
            Text(
              label,

              style: const TextStyle(color: ink, fontWeight: FontWeight.w900),
            ),

            const SizedBox(width: 8),
          ],

          Icon(icon, color: ink),

          if (!reverse) ...[
            const SizedBox(width: 8),

            Text(
              label,

              style: const TextStyle(color: ink, fontWeight: FontWeight.w900),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildState({
    required IconData icon,

    required String title,

    required String message,

    required String buttonText,

    required VoidCallback onPressed,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.all(28),

      children: [
        const SizedBox(height: 65),

        Center(
          child: doodleSticker(icon: icon, color: lavender, size: 90),
        ),

        const SizedBox(height: 24),

        Text(
          title,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: ink,

            fontSize: 22,

            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          message,

          textAlign: TextAlign.center,

          style: const TextStyle(color: muted, height: 1.6),
        ),

        const SizedBox(height: 24),

        Center(
          child: OutlinedButton.icon(
            onPressed: onPressed,

            style: OutlinedButton.styleFrom(
              foregroundColor: ink,

              backgroundColor: yellow,

              side: const BorderSide(color: ink, width: 1.7),

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),

            icon: const Icon(Icons.edit_rounded),

            label: Text(
              buttonText,

              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
