import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'db/bancoHelper.dart';
import 'model/pessoa.dart';


void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Lista de Contatos',
     theme: ThemeData(
     primarySwatch: Colors.blue,
     ),
     home: ListaDeContatos(titulo: 'Lista de Contatos'),
   );
 }
}
class ListaDeContatos extends StatefulWidget {
ListaDeContatos({Key key, this.titulo}) : super(key: key);
final String titulo;
  @override
  _ListaDeContatosState createState() => _ListaDeContatosState();
}
class _ListaDeContatosState extends State<ListaDeContatos> {
//constantes para o formulário
final _email = TextEditingController();
final _nome = TextEditingController();
final _formKey = new GlobalKey<FormState>();
//variavel para o banco
static DatabaseHelper banco;
// variaveis para a lista de contatos
int tamanhoDaLista = 0;
List<Contato> listaDeContatos;
 @override
 void initState() {
  // instanciamos o banco;
  banco = new DatabaseHelper();
  // chamamos o método para inicializar
  banco.inicializaBanco();
  
  //chamamos o metodo para retornar a lista de contatos do banco
  Future<List<Contato>> listaDeContatos = banco.getListaDeContato();
  
  listaDeContatos.then((novaListaDeContatos) {
      //chamo o setState para alterar o estado
      //da lista com os novos valores
      setState(() {
        // pego os resultados do meu banco
        // atribuo a novaListaDeContatos a minha variavel local
        // assim a inicializando
        this.listaDeContatos = novaListaDeContatos;
  
        // chamo a funcão length para retornar
        // o tamanho da minha lista
        // e atribuir o valor a minha variavel local
        this.tamanhoDaLista = novaListaDeContatos.length;
      });
  });
}
// metodo para carregar a lista com novos dados
_carregarLista() {
//crio objeto do banco novamente
banco = new DatabaseHelper();
//inicializo o banco novamente
banco.inicializaBanco();
//pego os novos registros do banco caso haja
Future<List<Contato>> noteListFuture = banco.getListaDeContato();
  noteListFuture.then((novaListaDeContatos) {
      //altero o estado da minha lista
      //com os novos valores retornado do banco
      setState(() {
         //atribuo os novos valores a minha variavel local
         this.listaDeContatos = novaListaDeContatos;
   
         // atribuo o novo tamanho a minha variavel local
         this.tamanhoDaLista = novaListaDeContatos.length; 
      });
  });
}
 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(widget.titulo),
      ),
      body: _listaDeContatos(),
      floatingActionButton: FloatingActionButton(
           onPressed: () {
             _adicionarContato(); //chamo o AlertDialog
            },
      child: Icon(Icons.add),
      backgroundColor: Colors.blueAccent,
      ),
    );
}
void _removerItem(Contato contato, int index) {
    // chamo novamente para atualizar a lista ao remover item
    setState(() {
    // minha lista de contatos atual,
    // recebe a nova lista,
    //menos o indice que eu estou passando
    listaDeContatos = List.from(listaDeContatos)..removeAt(index);
  
    // pego o id do contato para remove-lo
    banco.apagarContato(contato.id);
    //minha lista recebe ela mesma,
    // meno uma posicao que é o indice que eu removi;
    tamanhoDaLista = tamanhoDaLista - 1;
    
    });
}
void _adicionarContato() {
_email.text = '';
_nome.text = '';
showDialog(
   context: context,
   builder: (BuildContext context) {
      return AlertDialog(  
        title: new Text("Novo Contato"),
        content: new Container(
             child: new Form(
          key: _formKey,
          child: new Column(
             mainAxisSize: MainAxisSize.min,
             children: <Widget>[
               campoDeNome(),
               Divider(
                 color: Colors.transparent,
                 height: 20.0,
               ),
               campoDeEmail()
              ],
            ),
          ),
        ),
       actions: <Widget>[
          new FlatButton(  
              child: new Text("Salvar"),
                 onPressed: () {
                   Contato _contato;
                   if (_formKey.currentState.validate()) {
            
         //crio o objeto do meu contato, passando seus parametros
         _contato = new Contato(_nome.text, _email.text);
   
         // chamo o metodo para inserir  contato
         banco.inserirContato(_contato);
   
         // carrego a lista com o novo registro
         _carregarLista();
      
        // limpo os campos do formulario
        _formKey.currentState.reset();
 
        // remove o AlertDialog da tela;
        Navigator.of(context).pop();
       }
      },
     ),
    ],
   );
  },
 );
}
void _atualizarContato(Contato contato) {
  _email.text = contato.email;
  _nome.text = contato.nome;

  showDialog(
    context: context,
    builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Atualizar Contato"),
          content: new Container(
              child: new Form(
                 key: _formKey,
                 child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        campoDeNome(),
                        Divider(
                        color: Colors.transparent,
                        height: 20.0,
                        ),
                        campoDeEmail()
                    ],
                 ),
              ),
          ),
     actions: <Widget>[
       new FlatButton(
          child: new Text("Atualizar"),
             onPressed: () {
                Contato _contato;
             
             // faz a validacao do formulario
             if (_formKey.currentState.validate()) {
             // crio um novo objeto  passando seus atributos
             _contato = new Contato(_nome.text, _email.text);
 
             //chamo o metodo para atualizar com os novos valores
             banco.atualizarContato(_contato, contato.id);
    
             //carrego a lista com os novos valores
             _carregarLista();
   
            //reseto os campos do formulario
           _formKey.currentState.reset();
    
            // retiro o alerta da tela
            Navigator.of(context).pop();
            }
          },
        ),
       ],
     );
   },
 );
}


Widget campoDeNome() {
   return new TextFormField(
         controller: _nome,
         keyboardType: TextInputType.text,
         validator: (valor) {
            if (valor.isEmpty && valor.length == 0) {
               return "Campo Obrigatório"; // retorna a mensagem
                //caso o campo esteja vazio
            }
         },
         decoration: new InputDecoration(
            hintText: 'Nome',
            labelText: 'Nome completo',
            border: OutlineInputBorder(),
         ),
   );
}


Widget campoDeEmail() {
   return new TextFormField(  
     controller: _email,
     validator: (valor) {
         if (valor.isEmpty && valor.length == 0) {
              return "Campo Obrigatório"; // retorna a mensagem
             // caso o campo esteja vazio
         }
     },
     decoration: new InputDecoration(
          hintText: 'Email',
          labelText: 'Email',
          border: OutlineInputBorder(),
     ),
  );
}


Widget _listaDeContatos() {
   return ListView.builder(
     physics: const AlwaysScrollableScrollPhysics(),
     itemCount: tamanhoDaLista,
     itemBuilder: (context, index) {
        return GestureDetector(
           child: ListTile(
           //pego o nome do contato com base na posicao da lista
           title: Text(listaDeContatos[index].nome),
 
           //pego o email do contato com base na posicao da lista
           subtitle: Text(listaDeContatos[index].email),
         
           leading: CircleAvatar(
            //pego o nome do contato com base no indice
            // da lista e pego a primeira letra do nome
            child: Text(listaDeContatos[index].nome[0]),
            ),
        ),
         //clique longo para atualizar
         onLongPress: () => _atualizarContato(listaDeContatos[index]),


         //clique curto para remover
         onTap: () => _removerItem(listaDeContatos[0], index),
         );
       },
     );
   }
}