import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/curso.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/curso_repository.dart';

class CursoFormScreen extends StatefulWidget {
  final int usuarioId;
  final Curso? curso;

  const CursoFormScreen({
    super.key,
    required this.usuarioId,
    this.curso,
  });

  @override
  State<CursoFormScreen> createState() => _CursoFormScreenState();
}

class _CursoFormScreenState extends State<CursoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _instrutorController = TextEditingController();
  final _cargaHorariaController = TextEditingController();
  final _urlMaterialController = TextEditingController();

  final _cursoRepository = CursoRepository();
  final _categoriaRepository = CategoriaRepository();

  static const _niveis = ['Iniciante', 'Intermediário', 'Avançado'];
  String _nivelSelecionado = 'Iniciante';
  int? _categoriaIdSelecionada;
  List<Categoria> _categorias = [];
  bool _carregandoCategorias = true;
  bool _salvando = false;

  bool get _isEdicao => widget.curso != null;

  @override
  void initState() {
    super.initState();
    final curso = widget.curso;
    if (curso != null) {
      _tituloController.text = curso.titulo;
      _descricaoController.text = curso.descricao;
      _instrutorController.text = curso.instrutor;
      _cargaHorariaController.text = curso.cargaHoraria.toString();
      _urlMaterialController.text = curso.urlMaterial ?? '';
      _nivelSelecionado = _niveis.contains(curso.nivel) ? curso.nivel : 'Iniciante';
      _categoriaIdSelecionada = curso.categoriaId;
    }
    _carregarCategorias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _instrutorController.dispose();
    _cargaHorariaController.dispose();
    _urlMaterialController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    final lista = await _categoriaRepository.listarTodas();
    if (!mounted) return;
    setState(() {
      _categorias = lista;
      if (_categoriaIdSelecionada == null && lista.isNotEmpty) {
        _categoriaIdSelecionada = lista.first.id;
      }
      _carregandoCategorias = false;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriaIdSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ou cadastre uma categoria antes de salvar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final carga = int.parse(_cargaHorariaController.text.trim());
      final modelo = Curso(
        id: widget.curso?.id,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        instrutor: _instrutorController.text,
        cargaHoraria: carga,
        nivel: _nivelSelecionado,
        urlMaterial: _urlMaterialController.text,
        categoriaId: _categoriaIdSelecionada!,
        usuarioId: widget.usuarioId,
        criadoEm: widget.curso?.criadoEm ?? DateTime.now().toIso8601String(),
      );

      if (_isEdicao) {
        await _cursoRepository.atualizar(modelo);
      } else {
        await _cursoRepository.inserir(modelo);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdicao
                ? 'Curso atualizado com sucesso!'
                : 'Curso cadastrado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Curso' : 'Novo Curso Online'),
      ),
      body: _carregandoCategorias
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _tituloController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Título do curso *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if ((v?.trim().length ?? 0) < 3) {
                            return 'Informe o título (mínimo 3 caracteres).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _instrutorController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Instrutor ou instituição *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if ((v?.trim().length ?? 0) < 2) {
                            return 'Informe o nome do instrutor.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cargaHorariaController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Carga horária (h) *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final horas = int.tryParse(v?.trim() ?? '');
                                if (horas == null || horas <= 0) {
                                  return 'Informe um número maior que 0.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _nivelSelecionado,
                              decoration: const InputDecoration(
                                labelText: 'Nível',
                                border: OutlineInputBorder(),
                              ),
                              items: _niveis
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text(n),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => _nivelSelecionado = valor);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        value: _categoriaIdSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Categoria *',
                          border: OutlineInputBorder(),
                        ),
                        items: _categorias
                            .map(
                              (cat) => DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (valor) {
                          setState(() => _categoriaIdSelecionada = valor);
                        },
                        validator: (v) =>
                            v == null ? 'Selecione uma categoria.' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _urlMaterialController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Link do curso ou material (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Descrição e ementa *',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if ((v?.trim().length ?? 0) < 10) {
                            return 'Descreva o curso (mínimo 10 caracteres).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _salvando ? null : _salvar,
                          icon: const Icon(Icons.save),
                          label: Text(
                            _salvando
                                ? 'Salvando...'
                                : (_isEdicao ? 'Salvar Alterações' : 'Cadastrar Curso'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}