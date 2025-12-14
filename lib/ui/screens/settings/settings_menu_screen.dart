// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../widgets/glass_card.dart';
// import '../../widgets/cyber_scaffold.dart';

// class SettingsMenuScreen extends StatelessWidget {
//   const SettingsMenuScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final txtColor = theme.colorScheme.onSurface;

//     return CyberScaffold(
//       enableBack: false,
//       body: ListView(
//         padding: const EdgeInsets.all(32),
//         children: [
//           Text(
//             "Settings",
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: txtColor,
//             ),
//           ),
//           const SizedBox(height: 32),

//           _buildMenuCard(
//             context,
//             title: "Identity & Profile",
//             subtitle: "Manage account details and security",
//             icon: PhosphorIconsRegular.userCircle,
//             onTap: () => context.push('/profile'),
//           ),

//           const SizedBox(height: 16),

//           _buildMenuCard(
//             context,
//             title: "Preferences",
//             subtitle: "Theme, Typography, and Density",
//             icon: PhosphorIconsRegular.sliders,
//             onTap: () => context.push('/appearance'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     final txtColor = Theme.of(context).colorScheme.onSurface;

//     return GlassCard(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: txtColor.withValues(alpha: 0.05),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: 32, color: txtColor),
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: txtColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(color: txtColor.withValues(alpha: 0.5)),
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             PhosphorIconsRegular.caretRight,
//             color: txtColor.withValues(alpha: 0.3),
//           ),
//         ],
//       ),
//     );
//   }
// }
