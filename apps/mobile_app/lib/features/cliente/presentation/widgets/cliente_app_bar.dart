import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puerta_a_puerta_app/features/auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ClienteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? accionesAdicionales;

  const ClienteAppBar({
    super.key,
    required this.titulo,
    this.accionesAdicionales,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      actions: [
        if (accionesAdicionales != null) ...accionesAdicionales!,
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar Sesión',
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
            );
          },
        ),
      ],
    );
  }
}