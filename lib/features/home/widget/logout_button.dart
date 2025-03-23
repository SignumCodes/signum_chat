import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/route/route.dart';
import '../../../core/services/app_navigator.dart';
import '../../authentication/cubit/auth_cubit.dart';
import '../../authentication/cubit/auth_state.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, state) {
        if (state is AuthInitial) {
          AppNavigator.replaceWith(AppRoute.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: Colors.white, size: 24),
          tooltip: "Logout",
        ),
      ),
    );
  }

  /// **🔔 Show Logout Confirmation Dialog with Button Loading Indicator**
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false; // Local state to track loading
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    setState(() => isLoading = true); // Start loading
                    context.read<AuthCubit>().logout().then((_) {
                      Navigator.pop(context); // Close dialog after logout
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Logout"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}