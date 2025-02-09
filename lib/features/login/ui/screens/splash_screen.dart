import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/services/get_x/shared_preferences_service.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/models/role_model.dart';
import '../../../users_management/data/models/user_model.dart';
import '../widgets/login_logo_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: LoginLogoWidget()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          _navigateToLogin();
          return Scaffold(body: Center(child: LoginLogoWidget()));
        }
      },
    );
  }

  Future<void> _initializeApp() async {
    final sharedPreferencesService = await putAsync(SharedPreferencesService().init());

    put(
      UserManagementController(
          read<RemoteDataSourceRepository<RoleModel>>(), read<FilterableDataSourceRepository<UserModel>>(), sharedPreferencesService),
      permanent: true,
    );
  }

  void _navigateToLogin() {
    // Delay navigation until after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      read<UserManagementController>().userNavigator.navigateToLogin();
    });
  }
}
