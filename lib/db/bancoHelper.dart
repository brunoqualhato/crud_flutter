import 'dart:io';

import 'package:lista_de_contatos/model/pessoa.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
static DatabaseHelper _databaseHelper;
static Database _database;
String tabelaNome = 'tabela_contato';
String colId = 'id';
String colNome = 'nome';
String colEmail = 'email';
DatabaseHelper._createInstance();
factory DatabaseHelper() {
   if (_databaseHelper == null) {
       _databaseHelper = DatabaseHelper._createInstance();
   }
 
 return _databaseHelper;
}
Future<Database> get database async {
   if (_database == null) {
       _database = await inicializaBanco();
   }
 
 return _database;
}
Future<Database> inicializaBanco() async {
  Directory diretorio = await getApplicationDocumentsDirectory();
  String path = diretorio.path + 'contatos.db';
  
  var bandoDeContatos = await openDatabase
  (path, version: 1,  onCreate: _criaBanco);
 return bandoDeContatos;
}
void _criaBanco(Database db, int versao) async {
   await db.execute('CREATE TABLE $tabelaNome('
   '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
   '$colNome TEXT,'
   '$colEmail TEXT);');
/*
De uma forma direta, esse seria o SQL
CREATE TABLE tabela_contato(
id INTEGER PRIMARY KEY AUTOINCREMENT,
nome TEXT,
email TEXT
);
*/
}
Future<List<Map<String, dynamic>>> getContatoMapList() async {
   Database db = await this.database;
   var result = await db.rawQuery("SELECT * FROM tabela_contato");
 return result;
}
Future<int> inserirContato(Contato contato) async {
   Database db = await this.database;
   var result = await db.insert(tabelaNome, contato.toMap());
 return result;
}
Future<int> atualizarContato(Contato contato,int id) async {
   var db = await this.database;
   var result = await db.rawUpdate("UPDATE $tabelaNome SET $colNome = '${contato.nome}', $colEmail = '${contato.email}' WHERE $colId = '$id'");
 return result;
}
Future<int> apagarContato(int id) async {
   var db = await this.database;
   int result = await db.rawDelete('DELETE FROM $tabelaNome WHERE $colId = $id');
return result;
}
Future<List<Contato>> getListaDeContato() async {
   var contatoMapList = await getContatoMapList();
   int count = contatoMapList.length;
   List<Contato> listaDeContatos = List<Contato>();
   for (int i = 0; i < count; i++) {
      listaDeContatos.add(Contato.fromMapObject(contatoMapList[i]));
   }
 return listaDeContatos;
}
}