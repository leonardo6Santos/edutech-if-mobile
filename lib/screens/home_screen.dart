import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'categorias_screen.dart';
import 'curso_form_screen.dart';
import 'cursos_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceAtual = 0;
  int _versaoCursos = 0;
  int _versaoCategorias = 0;

  void _atualizarCursos() {
    setState(() => _versaoCursos++);
  }

  void _atualizarCategorias() {
    setState(() => _versaoCategorias++);
  }

  Future<void> _abrirNovoCurso() async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CursoFormScreen(usuarioId: widget.usuario.id!),
      ),
    );

    if (alterou == true) {
      _atualizarCursos();
    }
  }

  Future<void> _confirmarLogout() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar sessão'),
        content: Text(
          'Deseja realmente sair da conta de ${widget.usuario.nome}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (sair == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      CursosListScreen(
        key: ValueKey('cursos_$_versaoCursos'),
        usuarioId: widget.usuario.id!,
        onDadosAlterados: _atualizarCursos,
      ),
      CategoriasScreen(
        key: ValueKey('categorias_$_versaoCategorias'),
        onCategoriasAlteradas: () {
          _atualizarCategorias();
          _atualizarCursos();
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EduTechIF'),
            Text(
              'Olá, ${widget.usuario.nome}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sair (Logout)',
            icon: const Icon(Icons.logout),
            onPressed: _confirmarLogout,
          ),
        ],
      ),
      body: telas[_indiceAtual],
      floatingActionButton: _indiceAtual == 0
          ? FloatingActionButton.extended(
              onPressed: _abrirNovoCurso,
              icon: const Icon(Icons.add),
              label: const Text('Novo Curso'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (novoIndice) {
          setState(() => _indiceAtual = novoIndice);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Cursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}