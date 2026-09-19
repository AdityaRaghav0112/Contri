import 'package:flutter/material.dart';
import '../../core/models/profile.dart';
import '../../core/repositories/group_repository.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final GroupRepository _groupRepository = GroupRepository();

  String _selectedIcon = 'groups';
  final String _selectedCurrency = 'INR';
  final Set<String> _selectedMemberIds = {};
  List<Profile> _availableProfiles = [];
  bool _isLoadingProfiles = true;
  bool _isCreating = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'groups', 'icon': Icons.groups, 'label': 'General'},
    {'name': 'flight_takeoff', 'icon': Icons.flight_takeoff, 'label': 'Travel'},
    {'name': 'apartment', 'icon': Icons.apartment, 'label': 'Home'},
    {'name': 'local_movies', 'icon': Icons.local_movies, 'label': 'Movies'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Trip'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Food'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'label': 'Shopping'},
    {'name': 'sports_soccer', 'icon': Icons.sports_soccer, 'label': 'Sports'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _groupRepository.getAllProfiles();
    if (!mounted) return;
    setState(() {
      _availableProfiles = profiles;
      _isLoadingProfiles = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final newGroup = await _groupRepository.createGroup(
        name: name,
        icon: _selectedIcon,
        currency: _selectedCurrency,
        memberUserIds: _selectedMemberIds.toList(),
      );

      if (!mounted) return;
      Navigator.pop(context, newGroup);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating group: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF005048);
    const surface = Color(0xFFF2FBF9);
    const surfaceLow = Color(0xFFEDF6F3);
    const onSurface = Color(0xFF151D1C);
    const secondaryContainer = Color(0xFFCAE5E0);

    return Container(
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_add_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Create New Group',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Group Name Input
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: onSurface),
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. Goa Trip, Flat 204, Movie Club',
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                filled: true,
                fillColor: surfaceLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon Selector
            const Text(
              'Select Group Icon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _iconOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final opt = _iconOptions[index];
                  final isSelected = _selectedIcon == opt['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = opt['name'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primary : surfaceLow,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Add Members from available profiles
            const Text(
              'Add Members',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingProfiles)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_availableProfiles.isEmpty)
              const Text(
                'No other profiles found yet.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableProfiles.map((profile) {
                  final isSelected = _selectedMemberIds.contains(profile.id);
                  return FilterChip(
                    label: Text(profile.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMemberIds.add(profile.id);
                        } else {
                          _selectedMemberIds.remove(profile.id);
                        }
                      });
                    },
                    avatar: CircleAvatar(
                      backgroundColor: secondaryContainer,
                      child: Text(
                        profile.initials,
                        style: const TextStyle(fontSize: 10, color: primary),
                      ),
                    ),
                    selectedColor: secondaryContainer,
                    checkmarkColor: primary,
                    backgroundColor: surfaceLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Group',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
