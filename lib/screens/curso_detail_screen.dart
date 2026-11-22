import 'package:flutter/material.dart';
import '../models/curso.dart';
import '../repositories/curso_repository.dart';
import 'curso_form_screen.dart';

class CursoDetailScreen extends StatefulWidget {
  final Curso curso;
  final int usuarioId;

  const CursoDetailScreen({
    super.key,
    required this.curso,
    required this.usuarioId,
  });

  @override
  State<CursoDetailScreen> createState() => _CursoDetailScreenState();
}

class _CursoDetailScreenState extends State<CursoDetailScreen> {
  final _cursoRepository = CursoRepository();
  late Curso _cursoAtual;
  bool _houveAlteracao = false;
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    _cursoAtual = widget.curso;
  }

  Future<void> _editar() async {
    final editou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CursoFormScreen(
          usuarioId: widget.usuarioId,
          curso: _cursoAtual,
        ),
      ),
    );

    if (editou == true && mounted) {
      final atualizados = await _cursoRepository.listar(
        usuarioId: widget.usuarioId,
      );
      final encontrado = atualizados.where((c) => c.id == _cursoAtual.id);
      if (encontrado.isNotEmpty) {
        setState(() {
          _cursoAtual = encontrado.first;
          _houveAlteracao = true;
        });
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir curso'),
        content: Text(
          'Tem certeza que deseja excluir "${_cursoAtual.titulo}"? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || _cursoAtual.id == null) return;

    setState(() => _excluindo = true);
    try {
      await _cursoRepository.excluir(_cursoAtual.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Curso excluído com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _excluindo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, _houveAlteracao);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _houveAlteracao),
          ),
          title: const Text('Detalhes do Curso'),
          actions: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: _excluindo ? null : _editar,
            ),
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _excluindo ? null : _confirmarExclusao,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _cursoAtual.titulo,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text(_cursoAtual.categoriaNome ?? 'Sem categoria'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: Text('${_cursoAtual.cargaHoraria} horas'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.bar_chart, size: 16),
                    label: Text(_cursoAtual.nivel),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoTile(
                label: 'Instrutor / Instituição',
                value: _cursoAtual.instrutor,
              ),
              if (_cursoAtual.urlMaterial != null)
                _InfoTile(
                  label: 'Link / Material de apoio',
                  value: _cursoAtual.urlMaterial!,
                ),
              const SizedBox(height: 12),
              Text(
                'Descrição',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                _cursoAtual.descricao,
                style: const TextStyle(fontSize: 15, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}