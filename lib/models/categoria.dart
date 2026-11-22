class Categoria {
  final int? id;
  final String nome;
  final String descricao;

  Categoria({
    this.id,
    required this.nome,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome.trim(),
      'descricao': descricao.trim(),
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
    );
  }
}