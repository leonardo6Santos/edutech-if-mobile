class Curso {
  final int? id;
  final String titulo;
  final String descricao;
  final String instrutor;
  final int cargaHoraria;
  final String nivel;
  final String? urlMaterial;
  final int categoriaId;
  final int usuarioId;
  final String criadoEm;
  final String? categoriaNome;

  Curso({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.instrutor,
    required this.cargaHoraria,
    required this.nivel,
    this.urlMaterial,
    required this.categoriaId,
    required this.usuarioId,
    required this.criadoEm,
    this.categoriaNome,
  });

  Curso copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? instrutor,
    int? cargaHoraria,
    String? nivel,
    String? urlMaterial,
    int? categoriaId,
    int? usuarioId,
    String? criadoEm,
    String? categoriaNome,
  }) {
    return Curso(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      instrutor: instrutor ?? this.instrutor,
      cargaHoraria: cargaHoraria ?? this.cargaHoraria,
      nivel: nivel ?? this.nivel,
      urlMaterial: urlMaterial ?? this.urlMaterial,
      categoriaId: categoriaId ?? this.categoriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      criadoEm: criadoEm ?? this.criadoEm,
      categoriaNome: categoriaNome ?? this.categoriaNome,
    );
  }

  Map<String, dynamic> toMap() {
    final materialLimpo = urlMaterial?.trim();
    return {
      'id': id,
      'titulo': titulo.trim(),
      'descricao': descricao.trim(),
      'instrutor': instrutor.trim(),
      'carga_horaria': cargaHoraria,
      'nivel': nivel,
      'url_material': (materialLimpo == null || materialLimpo.isEmpty)
          ? null
          : materialLimpo,
      'categoria_id': categoriaId,
      'usuario_id': usuarioId,
      'criado_em': criadoEm,
    };
  }

  factory Curso.fromMap(Map<String, dynamic> map) {
    return Curso(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      instrutor: map['instrutor'] as String,
      cargaHoraria: map['carga_horaria'] as int,
      nivel: map['nivel'] as String,
      urlMaterial: map['url_material'] as String?,
      categoriaId: map['categoria_id'] as int,
      usuarioId: map['usuario_id'] as int,
      criadoEm: map['criado_em'] as String,
      categoriaNome: map['categoria_nome'] as String?,
    );
  }
}