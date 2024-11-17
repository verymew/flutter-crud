
import 'package:crud_sqlite/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final txtNome = TextEditingController();
  final txtEmail = TextEditingController();

  int? usuarioIdParaEditar;

  // Controlar estado da tela
  List<Map<String, Object?>> usuarios = [];

  @override
  void initState() {
    super.initState();
    _atualizarListaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nome:',
            ),
            controller: txtNome,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email:',
            ),
            controller: txtEmail,
          ),
          ElevatedButton(
            onPressed: () async {
              if (usuarioIdParaEditar == null) {
                final id = await SqlHelper.gravar(txtNome.text, txtEmail.text);
                final snack = SnackBar(
                  content: Text('Salvo com sucesso! ID: $id'),
                  showCloseIcon: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              } else {
                await SqlHelper.gravar(txtNome.text, txtEmail.text, usuarioIdParaEditar!);
                final snack = SnackBar(
                  content: Text('Usuário atualizado com sucesso!'),
                  showCloseIcon: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
                usuarioIdParaEditar = null;
              }
              _limparCampos();
              _atualizarListaUsuario();
            },
            child: Text(usuarioIdParaEditar == null ? 'Gravar' : 'Salvar'),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, indice) => ListTile(
                title: Text('${usuarios[indice]["nome"]}'),
                subtitle: Text(usuarios[indice]["email"].toString()),
                leading: CircleAvatar(),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          usuarioIdParaEditar = usuarios[indice]["idusuario"] as int;
                          txtNome.text = usuarios[indice]["nome"].toString();
                          txtEmail.text = usuarios[indice]["email"].toString();
                        });
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        // Excluir usuário
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Excluir item?'),
                            content: Text('Tem certeza que deseja excluir este usuário?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Lottie.asset('assets/lottie/sync4.json'),
                                    ),
                                  );
                                  await Future.delayed(Duration(seconds: 2));

                                  int id = usuarios[indice]["idusuario"] as int;
                                  await SqlHelper.deletar(id);
                                  _atualizarListaUsuario();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              separatorBuilder: (context, index) => Divider(),
              itemCount: usuarios.length,
            ),
          ),
        ],
      ),
    );
  }

  _atualizarListaUsuario() async {
    usuarios = await SqlHelper.listar();
    setState(() {});
  }

  _limparCampos() {
    txtNome.clear();
    txtEmail.clear();
  }
}