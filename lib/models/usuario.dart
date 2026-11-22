class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senhaHash;
  final String criadoEm;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome.trim(),
      'email': email.trim().toLowerCase(),
      'senha_hash': senhaHash,
      'criado_em': criadoEm,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senhaHash: map['senha_hash'] as String,
      criadoEm: map['criado_em'] as String,
    );
  }
}