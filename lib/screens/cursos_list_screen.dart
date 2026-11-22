import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/curso.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/curso_repository.dart';
import 'curso_detail_screen.dart';
import 'curso_form_screen.dart';

class CursosListScreen extends StatefulWidget {
  final int usuarioId;
  final VoidCallback onDadosAlterados;

  const CursosListScreen({
    super.key,
    required this.usuarioId,
    required this.onDadosAlterados,
  });

  @override
  State<CursosListScreen> createState() => _CursosListScreenState();
}

class _CursosListScreenState extends State<CursosListScreen> {
  final _cursoRepository = CursoRepository();
  final _categoriaRepository = CategoriaRepository();
  final _buscaController = TextEditingController();

  List<Curso> _cursos = [];
  List<Categoria> _categorias = [];
  int? _categoriaSelecionadaId;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTudo() async {
    setState(() => _carregando = true);
    try {
      final categorias = await _categoriaRepository.listarTodas();
      final cursos = await _cursoRepository.listar(
        usuarioId: widget.usuarioId,
        categoriaId: _categoriaSelecionadaId,
        busca: _buscaController.text,
      );

      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        _cursos = cursos;
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _filtrarCursos() async {
    final cursos = await _cursoRepository.listar(
      usuarioId: widget.usuarioId,
      categoriaId: _categoriaSelecionadaId,
      busca: _buscaController.text,
    );

    if (!mounted) return;
    setState(() => _cursos = cursos);
  }

  Future<void> _abrirDetalhes(Curso curso) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CursoDetailScreen(
          curso: curso,
          usuarioId: widget.usuarioId,
        ),
      ),
    );

    if (alterou == true) {
      await _filtrarCursos();
      widget.onDadosAlterados();
    }
  }

  Future<void> _abrirEdicao(Curso curso) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CursoFormScreen(
          usuarioId: widget.usuarioId,
          curso: curso,
        ),
      ),
    );

    if (alterou == true) {
      await _filtrarCursos();
      widget.onDadosAlterados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _buscaController,
            onChanged: (_) => _filtrarCursos(),
            decoration: InputDecoration(
              hintText: 'Buscar por título, instrutor ou tema...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _buscaController.clear();
                        _filtrarCursos();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: _categoriaSelecionadaId == null,
                  onSelected: (_) {
                    setState(() => _categoriaSelecionadaId = null);
                    _filtrarCursos();
                  },
                ),
              ),
              ..._categorias.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.nome),
                    selected: _categoriaSelecionadaId == cat.id,
                    onSelected: (_) {
                      setState(() {
                        _categoriaSelecionadaId =
                            _categoriaSelecionadaId == cat.id ? null : cat.id;
                      });
                      _filtrarCursos();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _cursos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhum curso encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Toque em "Novo Curso" para cadastrar um curso online.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarTudo,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: _cursos.length,
                        itemBuilder: (context, index) {
                          final curso = _cursos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              onTap: () => _abrirDetalhes(curso),
                              title: Text(
                                curso.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Instrutor: ${curso.instrutor}'),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Chip(
                                          label: Text(
                                            curso.categoriaNome ?? 'Sem categoria',
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Chip(
                                          label: Text('${curso.cargaHoraria}h'),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Chip(
                                          label: Text(curso.nivel),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Editar curso',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _abrirEdicao(curso),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}