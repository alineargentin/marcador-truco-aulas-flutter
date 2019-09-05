import 'package:flutter/material.dart';
import 'package:marcador_truco/models/player.dart';
import 'package:screen/screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _playerOne = Player(name: "Nós", score: 0, victories: 0);
  var _playerTwo = Player(name: "Eles", score: 0, victories: 0);

  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    // Instale o plugin Screen e adicione um código para deixar a tela sempre ativa enquanto joga:
    Screen.keepOn(true);

    super.initState();
    _resetPlayers();
  }

  void _resetPlayer({Player player, bool resetVictories = true}) {
    setState(() {
      player.score = 0;
      if (resetVictories) player.victories = 0;
    });
  }

  void _resetPlayers({bool resetVictories = true}) {
    _resetPlayer(player: _playerOne, resetVictories: resetVictories);
    _resetPlayer(player: _playerTwo, resetVictories: resetVictories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Marcador Pontos (Truco!)"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Zerar',
                  message:
                      'Tem certeza que deseja começar novamente a pontuação? Isso limpará também as vitórias.',
                  confirm: () {
                    _resetPlayers();
                  },
                  cancel: () {});
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Iniciar nova partida',
                  message:
                      'Deseja iniciar uma nova partida? Isso vai manter as vitórias.',
                  confirm: () {
                    _resetPlayers(resetVictories: false);
                  },
                  cancel: () {});
            },
            icon: Icon(Icons.fiber_new),
          )
        ],
      ),
      body: Container(padding: EdgeInsets.all(20.0), child: _showPlayers()),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _showPlayerBoard(Player player) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _showPlayerName(player),
          _showPlayerScore(player.score),
          _showPlayerVictories(player.victories),
          _showScoreButtons(player),
        ],
      ),
    );
  }

  Widget _showPlayers() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _showPlayerBoard(_playerOne),
        _showPlayerBoard(_playerTwo),
      ],
    );
  }

  Widget _showPlayerName(Player player) {
    // Trocar os nomes dos usuários ao clicar em cima do nome (Text).
    // Pode-se utilizar um GestureDetector e exibir um AlertDialog com um TextField.
    return GestureDetector(
      onTap: () {
        // atualiza texto do controller pra atualizar no Text Field
        _textFieldController.text = player.name;
        // mostra o dialog passando o jogador para que seja atualizado
        _showTextEditDialog(player);
      },
      child: Text(
        player.name.toUpperCase(),
        style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
            color: Colors.deepOrange),
      ),
    );
  }

  Widget _showPlayerVictories(int victories) {
    return Text(
      "vitórias ( $victories )",
      style: TextStyle(fontWeight: FontWeight.w300),
    );
  }

  Widget _showPlayerScore(int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52.0),
      child: Text(
        "$score",
        style: TextStyle(fontSize: 120.0),
      ),
    );
  }

  Widget _buildRoundedButton(
      {String text, double size = 52.0, Color color, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          color: color,
          height: size,
          width: size,
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

// Não deixar que seja possível ficar com pontos negativos ao clicar
// em (-1) e também não pode ultrapassar 12 pontos.

  Widget _showScoreButtons(Player player) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildRoundedButton(
          text: '-1',
          color: Colors.black.withOpacity(0.1),
          onTap: () {
            setState(() {
              if (player.score > 0) player.score--;
            });
          },
        ),
        //MÃO DE FERRO
        _buildRoundedButton(
          text: '+1',
          color: Colors.deepOrangeAccent,
          onTap: () {
            setState(() {
              if (player.score < 12) player.score++;
              if (_playerOne.score == 11 && _playerTwo.score == 11)
                _showDialog(
                  title: 'MÃO DE FERRO',
                  message: 'Todas as cartas devem estar encobertas!',
                  confirm: () {
                    setState(() {});
                  },
                );
            });

            if (player.score == 12) {
              _showDialog(
                  title: 'Fim do jogo',
                  message: '${player.name} ganhou!',
                  confirm: () {
                    setState(() {
                      player.victories++;
                    });

                    _resetPlayers(resetVictories: false);
                  },
                  cancel: () {
                    setState(() {
                      player.score--;
                    });
                  });
            }
          },
        ),
      ],
    );
  }

  //Transformar o AlertDialog em modal
  //para que somente desapareça da tela ao clicar em CANCEL ou OK. Uma dia
  //, precisa utilizar o atributo barrierDismissible
  void _showDialog(
      {String title, String message, Function confirm, Function cancel}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            // if ternário para não exibir botão de cancelar se não receber a função
            cancel != null
                ? FlatButton(
                    child: Text("CANCEL"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (cancel != null) cancel();
                    },
                  )
                : null,
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm != null) confirm();
              },
            ),
          ],
        );
      },
    );
  }

  /// Exibe um texto para edição e atualiza o nome do player com o texto inserido
  void _showTextEditDialog(Player player) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar nome'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Digite o nome"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('OK'),
                onPressed: () {
                  if (_textFieldController.text.length > 0) {
                    setState(() {
                      player.name = _textFieldController.text;
                    });
                  }
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
