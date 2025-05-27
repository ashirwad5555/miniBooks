// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import '../../NavBar/nav_bar.dart';
// import '../../services/api_service.dart';
// import '../../providers/auth_provider.dart';
// import '../../Theme/mytheme.dart';

// class AuthScreen extends ConsumerStatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends ConsumerState<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   bool isLogin = true;
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   final Map<String, String> _authData = {
//     'name': '',
//     'email': '',
//     'contactNo': '',
//     'password': '',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     try {
//       if (!_formKey.currentState!.validate()) return;

//       _formKey.currentState!.save();

//       setState(() {
//         _isLoading = true;
//       });

//       if (isLogin) {
//         // Login logic
//         await ref.read(userProvider.notifier).login(
//               _authData['email'] ?? '',
//               _authData['password'] ?? '',
//             );

//         // If we got here, login was successful
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => FluidNavBarDemo()),
//         );
//       } else {
//         // Register logic
//         await ref.read(userProvider.notifier).register({
//           'name': _authData['name'],
//           'email': _authData['email'],
//           'contactNo': _authData['contactNo'],
//           'password': _authData['password'],
//         });

//         // If we got here, registration was successful
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => FluidNavBarDemo()),
//         );
//       }
//     } catch (error) {
//       // Show error dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => AlertDialog(
//           titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//           actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
//           title: const Row(
//             children: [
//               Icon(Icons.error_outline, color: Colors.red, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Authentication Error',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 error.toString(),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please try again or report this issue.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//               ),
//             ],
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 minimumSize: const Size(60, 30),
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 textStyle: const TextStyle(fontSize: 12),
//               ),
//               child: const Text('Report'),
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Issue reported'),
//                     duration: const Duration(seconds: 2),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 );
//                 Navigator.of(ctx).pop();
//               },
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 minimumSize: const Size(70, 30),
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 textStyle: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.refresh, size: 14),
//                   SizedBox(width: 4),
//                   Text('Retry'),
//                 ],
//               ),
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//             ),
//           ],
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _switchAuthMode() {
//     try {
//       setState(() {
//         isLogin = !isLogin;
//       });
//       _animationController.reset();
//       _animationController.forward();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Error switching mode'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.primaryColor;
//     final cardColor = theme.cardColor;
//     final textTheme = theme.textTheme;
//     final isDarkMode = theme.brightness == Brightness.dark;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDarkMode
//                 ? [
//                     Colors.grey[900]!,
//                     Colors.grey[800]!,
//                   ]
//                 : [
//                     Colors.orange[50]!,
//                     Colors.orange[100]!,
//                   ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth < 360 ? 12.0 : 16.0,
//                   vertical: 12.0,
//                 ),
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Card(
//                     elevation: 8,
//                     color: cardColor,
//                     shadowColor: isDarkMode
//                         ? Colors.black.withOpacity(0.6)
//                         : Colors.grey.withOpacity(0.4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       side: BorderSide(
//                         color: isDarkMode
//                             ? theme.dividerColor
//                             : Colors.transparent,
//                         width: 1,
//                       ),
//                     ),
//                     child: Container(
//                       width: double.infinity,
//                       constraints: const BoxConstraints(maxWidth: 400),
//                       padding: EdgeInsets.all(
//                         screenWidth < 360 ? 16.0 : 20.0,
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Hero(
//                               tag: 'app_icon',
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: primaryColor.withOpacity(0.1),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   isLogin
//                                       ? Icons.book_outlined
//                                       : Icons.app_registration,
//                                   size: 40,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               isLogin
//                                   ? 'Welcome to Mini-Books'
//                                   : 'Join Mini-Books',
//                               style: textTheme.headlineMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 22,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               isLogin
//                                   ? 'Sign in to access your books'
//                                   : 'Create an account to get started',
//                               textAlign: TextAlign.center,
//                               style: textTheme.bodyMedium?.copyWith(
//                                 fontSize: 13,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                               child: Column(
//                                 children: [
//                                   if (!isLogin)
//                                     _buildTextField(
//                                       label: 'Full Name',
//                                       icon: Icons.person_outline,
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Please enter your name';
//                                         }
//                                         return null;
//                                       },
//                                       onSaved: (value) {
//                                         _authData['name'] = value!;
//                                       },
//                                       theme: theme,
//                                     ),
//                                   if (!isLogin) const SizedBox(height: 12),
//                                   _buildTextField(
//                                     label: 'Email Address',
//                                     icon: Icons.email_outlined,
//                                     keyboardType: TextInputType.emailAddress,
//                                     validator: (value) {
//                                       if (value == null ||
//                                           !value.contains('@')) {
//                                         return 'Invalid email';
//                                       }
//                                       return null;
//                                     },
//                                     onSaved: (value) =>
//                                         _authData['email'] = value!,
//                                     theme: theme,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   if (!isLogin)
//                                     _buildTextField(
//                                       label: 'Phone Number',
//                                       icon: Icons.phone_outlined,
//                                       keyboardType: TextInputType.phone,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.digitsOnly,
//                                         LengthLimitingTextInputFormatter(10),
//                                       ],
//                                       validator: (value) {
//                                         if (value == null ||
//                                             value.length < 10) {
//                                           return 'Invalid phone number';
//                                         }
//                                         return null;
//                                       },
//                                       onSaved: (value) =>
//                                           _authData['contactNo'] = value!,
//                                       theme: theme,
//                                     ),
//                                   if (!isLogin) const SizedBox(height: 12),
//                                   _buildPasswordField(theme: theme),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             SizedBox(
//                               width: double.infinity,
//                               height: 46,
//                               child: ElevatedButton(
//                                 onPressed: _isLoading ? null : _submit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: primaryColor,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 2,
//                                   shadowColor: primaryColor.withOpacity(0.4),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                                 child: _isLoading
//                                     ? const SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                           valueColor:
//                                               AlwaysStoppedAnimation<Color>(
//                                             Colors.white,
//                                           ),
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : Text(
//                                         isLogin ? 'LOGIN' : 'SIGN UP',
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 0.8,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   isLogin
//                                       ? 'Don\'t have an account?'
//                                       : 'Already have an account?',
//                                   style: textTheme.bodyMedium?.copyWith(
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: _switchAuthMode,
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: primaryColor,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 6,
//                                       vertical: 2,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     isLogin ? 'Sign Up' : 'Login',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required IconData icon,
//     required ThemeData theme,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//     void Function(String?)? onSaved,
//     String? hint,
//     int? maxLines = 1,
//   }) {
//     final isDarkMode = theme.brightness == Brightness.dark;
//     final primaryColor = theme.primaryColor;

//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon, color: primaryColor, size: 18),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(
//             width: 1,
//             color: theme.dividerColor,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(
//             width: 1,
//             color: theme.dividerColor,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(width: 1.5, color: primaryColor),
//         ),
//         filled: true,
//         fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
//         labelStyle: TextStyle(
//           color: theme.textTheme.bodyMedium?.color,
//           fontSize: 13,
//         ),
//         hintStyle: TextStyle(color: theme.hintColor, fontSize: 13),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         isDense: true,
//       ),
//       style: TextStyle(
//         color: theme.textTheme.bodyLarge?.color,
//         fontSize: 14,
//       ),
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       onSaved: onSaved,
//       maxLines: maxLines,
//     );
//   }

//   Widget _buildPasswordField({required ThemeData theme}) {
//     final isDarkMode = theme.brightness == Brightness.dark;
//     final primaryColor = theme.primaryColor;

//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: 'Password',
//         prefixIcon: Icon(Icons.lock_outline, color: primaryColor, size: 18),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword ? Icons.visibility_off : Icons.visibility,
//             color: theme.iconTheme.color,
//             size: 18,
//           ),
//           onPressed: () {
//             setState(() {
//               _obscurePassword = !_obscurePassword;
//             });
//           },
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//           visualDensity: VisualDensity.compact,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(
//             width: 1,
//             color: theme.dividerColor,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(
//             width: 1,
//             color: theme.dividerColor,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(width: 1.5, color: primaryColor),
//         ),
//         filled: true,
//         fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
//         labelStyle: TextStyle(
//           color: theme.textTheme.bodyMedium?.color,
//           fontSize: 13,
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         isDense: true,
//       ),
//       style: TextStyle(
//         color: theme.textTheme.bodyLarge?.color,
//         fontSize: 14,
//       ),
//       obscureText: _obscurePassword,
//       validator: (value) {
//         if (value == null || value.length < 6) {
//           return 'Password must be at least 6 characters';
//         }
//         return null;
//       },
//       onSaved: (value) => _authData['password'] = value!,
//     );
//   }
// }
