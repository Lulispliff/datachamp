import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(IndicadorApp());
}

class IndicadorApp extends StatelessWidget {
  const IndicadorApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Indicadores',
      home: IndicadorScreen(),
    );
  }
}

class Indicador {
  final int id;
  String descricao;

  Indicador({required this.id, required this.descricao});
}

class Cotacao {
  final int id;
  final DateTime dataHora;
  final double valor;
  final Indicador indicador;

  Cotacao({
    required this.id,
    required this.dataHora,
    required this.valor,
    required this.indicador,
  });
}

class IndicadorScreen extends StatefulWidget {
  @override
  _IndicadorScreenState createState() => _IndicadorScreenState();
}

class _IndicadorScreenState extends State<IndicadorScreen> {
  List<Indicador> indicadores = [];
  List<Cotacao> cotacoes = [];
  int nextIndicadorId = 1;
  int nextCotacaoId = 1;

  TextEditingController descricaoController = TextEditingController();
  TextEditingController valorController = TextEditingController();

  Indicador? selectedIndicador;

  @override
  void initState() {
    super.initState();
    var indicador = Indicador(id: 1, descricao: "Euro");
    final cotacao =
        Cotacao(id: 1, dataHora: DateTime.now(), valor: 5, indicador: indicador);
    final cotacao2 =
        Cotacao(id: 1, dataHora: DateTime(2023, 11, 7), valor: 5.2, indicador: indicador);

    indicadores.add(indicador);
    cotacoes.add(cotacao);
    cotacoes.add(cotacao2);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cadastro de Indicadores'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Indicadores'),
              Tab(text: 'Cotações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildIndicadoresTab(),
            buildCotacoesTab(),
          ],
        ),
      ),
    );
  }

  Widget buildIndicadoresTab() {
    return Column(
      children: [
        Expanded(
          child: indicadores.isEmpty
              ? Center(
                  child: Text('Sua lista de indicadores está vazia'),
                )
              : ListView.builder(
                  itemCount: indicadores.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          'ID: ${indicadores[index].id} - Descrição: ${indicadores[index].descricao}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              modifyIndicador(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              removeIndicador(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {
              _showAddIndicadorDialog();
            },
            child: Text('Adicionar novo indicador'),
          ),
        ),
      ],
    );
  }

  Widget buildCotacoesTab() {
    return Column(
      children: [
        Expanded(
          child: cotacoes.isEmpty
              ? Center(
                  child: Text('Sua lista de cotações está vazia'),
                )
              : ListView.builder(
                  itemCount: cotacoes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          'ID: ${cotacoes[index].id} - Data/Hora: ${cotacoes[index].dataHora} - Valor: ${cotacoes[index].valor} - Indicador: ${cotacoes[index].indicador.descricao}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeCotacao(index);
                        },
                      ),
                    );
                  },
                ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: cotacoes
                      .map((cotacao) => FlSpot(
                            cotacoes.indexOf(cotacao).toDouble(),
                            cotacao.valor,
                          ))
                      .toList(),
                  isCurved: true,
                  color: Colors.green,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {
              _showAddCotacaoDialog();
            },
            child: Text('Registrar Cotação'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showChart(context);
          },
          child: Text('Mostrar Gráfico'),
        ),
      ],
    );
  }

  void _showAddIndicadorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar um novo indicador'),
          content: TextField(
            controller: descricaoController,
            decoration: InputDecoration(labelText: 'Descrição do Indicador'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                descricaoController.clear();
              },
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () {
                addIndicador();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCotacaoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar Cotação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Indicador>(
                value: selectedIndicador,
                items: indicadores.map((ind) {
                  return DropdownMenuItem<Indicador>(
                    value: ind,
                    child: Text(ind.descricao),
                  );
                }).toList(),
                onChanged: (ind) {
                  setState(() {
                    selectedIndicador = ind;
                  });
                },
                hint: Text('Selecione um indicador'),
              ),
              TextField(
                controller: valorController,
                decoration: InputDecoration(labelText: 'Valor da Cotação'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                selectedIndicador = null;
                valorController.clear();
              },
            ),
            TextButton(
              child: Text('Registrar'),
              onPressed: () {
                addCotacao();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addIndicador() {
    final descricao = descricaoController.text;
    if (descricao.isEmpty) {
      return;
    }

    final indicador = Indicador(id: nextIndicadorId, descricao: descricao);
    setState(() {
      indicadores.add(indicador);
      nextIndicadorId++;
      descricaoController.clear();
    });
  }

  void removeIndicador(int index) {
    setState(() {
      indicadores.removeAt(index);
    });
  }

  void addCotacao() {
    final valor = double.tryParse(valorController.text) ?? 0.0;
    if (selectedIndicador == null || valor <= 0.0) {
      return;
    }

    final cotacao = Cotacao(
      id: nextCotacaoId,
      dataHora: DateTime.now(),
      valor: valor,
      indicador: selectedIndicador!,
    );
    setState(() {
      cotacoes.add(cotacao);
      nextCotacaoId++;
      selectedIndicador = null;
      valorController.clear();
    });
  }

  void removeCotacao(int index) {
    setState(() {
      cotacoes.removeAt(index);
    });
  }

  void modifyIndicador(int index) {
    descricaoController.text = indicadores[index].descricao;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar Indicador'),
          content: TextField(
            controller: descricaoController,
            decoration: InputDecoration(labelText: 'Nova descrição do Indicador'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                descricaoController.clear();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                indicadores[index].descricao = descricaoController.text;
                Navigator.of(context).pop();
                descricaoController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChart(BuildContext context) {
    if (cotacoes.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Acompanhamento de Indicador'),
            content: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: cotacoes
                          .map((cotacao) => FlSpot(
                                cotacoes.indexOf(cotacao).toDouble(),
                                cotacao.valor,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Acompanhamento de Indicador'),
            content: Text('A lista de cotações está vazia. Não é possível gerar o gráfico.'),
            actions: <Widget>[
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

