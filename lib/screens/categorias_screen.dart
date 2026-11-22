import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../repositories/categoria_repository.dart';

class CategoriasScreen extends StatefulWidget {
  final VoidCallback onCategoriasAlteradas;

  const CategoriasScreen({
    super.key,
    required this.onCategoriasAlteradas,
  });

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final _categoriaRepository = CategoriaRepository();
  List<Categoria> _categorias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    setState(() => _carregando = true);
    try {
      final lista = await _categoriaRepository.listarTodas();
      if (!mounted) return;
      setState(() => _categorias = lista);
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _abrirFormularioCategoria({Categoria? categoria}) async {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: categoria?.nome ?? '');
    final descController = TextEditingController(text: categoria?.descricao ?? '');

    final salvou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(categoria == null ? 'Nova Categoria' : 'Editar Categoria'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da categoria *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().length ?? 0) < 2
                    ? 'Informe o nome da categoria.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.trim().length ?? 0) < 3
                    ? 'Informe uma breve descrição.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final model = Categoria(
                  id: categoria?.id,
                  nome: nomeController.text,
                  descricao: descController.text,
                );
                if (categoria == null) {
                  await _categoriaRepository.inserir(model);
                } else {
                  await _categoriaRepository.atualizar(model);
                }
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    nomeController.dispose();
    descController.dispose();

    if (salvou == true && mounted) {
      await _carregarCategorias();
      widget.onCategoriasAlteradas();
    }
  }

  Future<void> _excluirCategoria(Categoria categoria) async {
    if (categoria.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir a categoria "${categoria.nome}"?'),
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

    if (confirmar != true) return;

    try {
      await _categoriaRepository.excluir(categoria.id!);
      if (!mounted) return;
      await _carregarCategorias();
      widget.onCategoriasAlteradas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria excluída.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
    return Scaffold(
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _categorias.isEmpty
              ? const Center(child: Text('Nenhuma categoria cadastrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final cat = _categorias[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.folder_outlined),
                        ),
                        title: Text(
                          cat.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(cat.descricao),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _abrirFormularioCategoria(categoria: cat),
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _excluirCategoria(cat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioCategoria(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
      ),
    );
  }
}