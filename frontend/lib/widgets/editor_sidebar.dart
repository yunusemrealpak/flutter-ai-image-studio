import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Left sidebar with navigation icons
class EditorSidebar extends StatefulWidget {
  const EditorSidebar({Key? key}) : super(key: key);

  @override
  State<EditorSidebar> createState() => _EditorSidebarState();
}

class _EditorSidebarState extends State<EditorSidebar> {
  int _selectedIndex = 0;

  final List<_SidebarItem> _items = [
    _SidebarItem(
      icon: Icons.add_photo_alternate_outlined,
      activeIcon: Icons.add_photo_alternate,
      tooltip: 'Image Editor',
    ),
    _SidebarItem(
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune,
      tooltip: 'Adjustments',
    ),
    _SidebarItem(
      icon: Icons.show_chart_outlined,
      activeIcon: Icons.show_chart,
      tooltip: 'Curves',
    ),
    _SidebarItem(
      icon: Icons.crop_outlined,
      activeIcon: Icons.crop,
      tooltip: 'Crop & Resize',
    ),
    _SidebarItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      tooltip: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.sidebarWidth,
      color: AppTheme.sidebarBackground,
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingXXL),
          ...List.generate(_items.length, (index) {
            return _SidebarIconButton(
              item: _items[index],
              isSelected: _selectedIndex == index,
              onTap: () => setState(() => _selectedIndex = index),
            );
          }),
        ],
      ),
    );
  }
}

/// Sidebar item data model
class _SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;

  _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
  });
}

/// Individual sidebar icon button
class _SidebarIconButton extends StatelessWidget {
  final _SidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarIconButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingS,
        horizontal: AppTheme.spacingM,
      ),
      child: Tooltip(
        message: item.tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? AppTheme.iconActiveColor
                  : AppTheme.iconColor,
              size: AppTheme.sidebarIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
