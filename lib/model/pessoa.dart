class Contato {
String nome;
String email;
int id;
Contato(this.nome, this.email);
Map<String, dynamic> toMap() {
  var map = Map<String, dynamic>();
      if (id != null) {
          map['id'] = id;
      }
  map['nome'] = nome;
  map['email'] = email;
  return map;
}


Contato.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.nome = map['nome'];
    this.email = map['email'];
}
}