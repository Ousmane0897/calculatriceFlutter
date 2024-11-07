import 'package:flutter/material.dart';
import 'package:calculatrice/bouttons.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.orange),
    home: const Calculatrice(),
    debugShowCheckedModeBanner: false,
  ));
}

class Calculatrice extends StatefulWidget {
  const Calculatrice({super.key});

  @override
  State<Calculatrice> createState() {
    return CalculatriceState();
  }
}

class CalculatriceState extends State<Calculatrice> {
  String valeur1 = ""; // 0-9
  String operation = ""; // + - * /
  String valeur2 = ""; // 0-9
  @override
  Widget build(BuildContext context) {
    final screenSize =
        MediaQuery.of(context).size; //Helps to get the screeen size
    return Scaffold(
        backgroundColor: Colors.black,
        // AppBar
        appBar: AppBar(
          title: const Center(
            child: Text("Application calculatrice"),
          ),
          elevation: 15,
          backgroundColor: Colors.orange,
        ),
        //body
        body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  //output
                  child: SingleChildScrollView(
                      reverse: true,
                      child: Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "$valeur1$operation$valeur2".isEmpty
                                ? "0"
                                : "$valeur1$operation$valeur2",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ))),
                ),
                //Bouttons
                Wrap(
                  // Wrap nous permet d'avoir plusieurs widget dans un seul widget
                  children: Btn.buttonValues
                      .map((value) => SizedBox(
                            // SizedBox Flutter is a box that can contain something inside it and you can decide how big or small that box should be.
                            width: value == Btn.n0
                                ? screenSize.width / 2
                                : screenSize.width / 4,
                            height: screenSize.height / 9,
                            child: builButton(value),
                          ))
                      .toList(),
                )
              ],
            )));
  }

  Widget builButton(value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(100)),
        child: InkWell(
          // InkWell is the material widget in flutter. It responds to the touch action as performed by the user. Inkwell will respond when the user clicks the button
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.calculate
          ].contains(value)
            ? Colors.orange
            : Colors.black87;
  }

  //La partie logique
  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  // Calcul du résultat
  void calculate() {
    if (valeur1.isEmpty) return;
    if (operation.isEmpty) return;
    if (valeur2.isEmpty) return;

    final double num1 = double.parse(valeur1);
    final double num2 = double.parse(valeur2);

    var result = 0.0;
    switch (operation) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    setState(() {
      valeur1 = result.toStringAsPrecision(3);

      if (valeur1.endsWith(".0")) {
        valeur1 = valeur1.substring(0, valeur1.length - 2);
      }

      operation = "";
      valeur2 = "";
    });
  }

  //Convertir le résultat en pourcentage
  void convertToPercentage() {
    // ex: 434+324
    if (valeur1.isNotEmpty && operation.isNotEmpty && valeur2.isNotEmpty) {
      // calculer avant la conversion
      calculate();
    }

    if (operation.isNotEmpty) {
      // Ne peut pas etre convertis
      return;
    }

    final number = double.parse(valeur1);
    setState(() {
      valeur1 = "${(number / 100)}";
      operation = "";
      valeur2 = "";
    });
  }

  //Effacer toute les valeurs tapées
  void clearAll() {
    setState(() {
      valeur1 = "";
      operation = "";
      valeur2 = "";
    });
  }

  //Effacer une valeur à partir de la droite
  void delete() {
    if (valeur2.isNotEmpty) {
      // 12323 => 1232
      valeur2 = valeur2.substring(0, valeur2.length - 1);
    } else if (operation.isNotEmpty) {
      operation = "";
    } else if (valeur1.isNotEmpty) {
      valeur1 = valeur1.substring(0, valeur1.length - 1);
    }

    setState(() {});
  }

  // appends value to the end
  void appendValue(String value) {
    // valeur1 operation valeur2
    // 234       +      5343

    // Si la valeur tapée est une opération (+ - * /) et non un point "."
    if (value != Btn.dot && int.tryParse(value) == null) {
      // operation pressed
      if (operation.isNotEmpty && valeur2.isNotEmpty) {
        // TODO calculate the equation before assigning new operation
        calculate();
      }
      operation = value;
    }
    // Donner la valeur tapée à la variable valeur1
    else if (valeur1.isEmpty || operation.isEmpty) {
      // Vérifier si la valeur est "." | ex: valeur1 = "1.2"
      if (value == Btn.dot && valeur1.contains(Btn.dot)) return;
      if (value == Btn.dot && (valeur1.isEmpty || valeur1 == Btn.n0)) {
        // ex: valeur1 = "" | "0"
        value = "0.";
      }
      valeur1 += value;
    }
    //  Donner la valeur tapée à la variable valeur2
    else if (valeur2.isEmpty || operation.isNotEmpty) {
      // Vérifier si la valeur est "." | ex: valeur1 = "1.2"
      if (value == Btn.dot && valeur2.contains(Btn.dot)) return;
      if (value == Btn.dot && (valeur2.isEmpty || valeur2 == Btn.n0)) {
        // valeur1 = "" | "0"
        value = "0.";
      }
      valeur2 += value;
    }

    setState(() {});
  }
}
