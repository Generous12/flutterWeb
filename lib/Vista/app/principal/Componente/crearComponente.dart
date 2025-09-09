import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/textfield.dart';
import 'package:timeline_tile/timeline_tile.dart';

class FlujoCrearComponente extends StatefulWidget {
  const FlujoCrearComponente({super.key});

  @override
  State<FlujoCrearComponente> createState() => _FlujoCrearComponenteState();
}

class _FlujoCrearComponenteState extends State<FlujoCrearComponente> {
  int pasoActual = 0;
  bool puedeContinuar = false;

  // GlobalKeys para cada formulario
  final tipoComponenteKey = GlobalKey<_TipoComponenteFormState>();
  final atributoFormKey = GlobalKey<_AtributoFormState>();
  final componenteFormKey = GlobalKey<_ComponenteFormState>();
  final valorAtributoFormKey = GlobalKey<_ValorAtributoFormState>();

  late List<Widget> pasosWidgets;

  @override
  void initState() {
    super.initState();
    pasosWidgets = [
      TipoComponenteForm(
        key: tipoComponenteKey,
        onValidChange: (isValid) => setState(() => puedeContinuar = isValid),
      ),
      AtributoForm(
        key: atributoFormKey,
        onValidChange: (isValid) => setState(() => puedeContinuar = isValid),
      ),
      ComponenteForm(
        key: componenteFormKey,
        onValidChange: (isValid) => setState(() => puedeContinuar = isValid),
      ),
      ValorAtributoForm(
        key: valorAtributoFormKey,
        onValidChange: (isValid) => setState(() => puedeContinuar = isValid),
      ),
    ];
  }

  void siguientePaso() {
    if (pasoActual < pasosWidgets.length - 1) {
      setState(() {
        pasoActual++;
        puedeContinuar = false;
      });
    }
  }

  void anteriorPaso() {
    if (pasoActual > 0) {
      final provider = Provider.of<ComponentService>(context, listen: false);
      switch (pasoActual) {
        case 1:
          provider.tipoSeleccionado = null;
          break;
        case 2:
          provider.atributos.clear();
          provider.valoresAtributos.clear();
          break;
        case 3:
          provider.componenteCreado = null;
          break;
        case 4:
          provider.valoresAtributos.clear();
          break;
      }
      setState(() {
        pasoActual--;
        puedeContinuar = true;
      });
    }
  }

  Future<void> guardarPaso() async {
    final provider = Provider.of<ComponentService>(context, listen: false);
    switch (pasoActual) {
      case 0:
        await tipoComponenteKey.currentState?.guardar(provider);
        break;
      case 1:
        atributoFormKey.currentState?.guardar(provider);
        break;
      case 2:
        componenteFormKey.currentState?.guardar(provider);
        break;
      case 3:
        valorAtributoFormKey.currentState?.guardar(provider);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Componente"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timeline
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pasosWidgets.length,
                itemBuilder: (context, index) {
                  return TimelineTile(
                    axis: TimelineAxis.horizontal,
                    alignment: TimelineAlign.center,
                    isFirst: index == 0,
                    isLast: index == pasosWidgets.length - 1,
                    indicatorStyle: IndicatorStyle(
                      width: 30,
                      height: 25,
                      indicator: Container(
                        decoration: BoxDecoration(
                          color: index < pasoActual
                              ? Colors.blue
                              : index == pasoActual
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            index < pasoActual
                                ? LucideIcons.checkCircle
                                : LucideIcons.circle,
                            color: index <= pasoActual
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(child: pasosWidgets[pasoActual]),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (pasoActual > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: anteriorPaso,
                        child: const Text("Volver"),
                      ),
                    ),
                  if (pasoActual > 0) const SizedBox(width: 12),
                  Expanded(
                    child: LoadingOverlayButtonHabilitar(
                      text: pasoActual == pasosWidgets.length - 1
                          ? "Finalizado"
                          : "Continuar",
                      enabled: puedeContinuar,
                      onPressedLogic: () async {
                        if (puedeContinuar) {
                          await guardarPaso();
                          if (pasoActual < pasosWidgets.length - 1) {
                            siguientePaso();
                          } else {
                            debugPrint("✅ Flujo finalizado");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipoComponenteForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  TipoComponenteForm({super.key, required this.onValidChange});

  @override
  State<TipoComponenteForm> createState() => _TipoComponenteFormState();
}

class _TipoComponenteFormState extends State<TipoComponenteForm> {
  final TextEditingController nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombreController.addListener(_validate);
  }

  void _validate() {
    widget.onValidChange(nombreController.text.trim().isNotEmpty);
  }

  Future<void> guardar(ComponentService provider) async {
    final nombre = nombreController.text.trim();
    if (nombre.isEmpty) return;

    final confirmado = await showCustomDialog(
      context: context,
      title: "Confirmar",
      message: "¿Deseas crear el tipo de componente '$nombre'?",
      confirmButtonText: "Sí",
      cancelButtonText: "No",
    );

    if (confirmado == true) {
      provider.crearTipoComponente(nombre);
      await showCustomDialog(
        context: context,
        title: "¡Listo!",
        message: "El tipo de componente '$nombre' se creó correctamente.",
        confirmButtonText: "Aceptar",
      );
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registrar componente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: nombreController,
                  hintText: "Ingresa el nombre del componente",
                  label: "Nombre de componente",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AtributoForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  const AtributoForm({super.key, required this.onValidChange});

  @override
  State<AtributoForm> createState() => _AtributoFormState();
}

class _AtributoFormState extends State<AtributoForm> {
  final List<Map<String, dynamic>> atributos = [];
  final List<String> tipos = ["Texto", "Número", "Fecha"];

  @override
  void initState() {
    super.initState();
    _addAtributo();
  }

  void _addAtributo() {
    final controller = TextEditingController();
    controller.addListener(_validate);
    atributos.add({"controller": controller, "tipo": tipos[0]});
    setState(() {});
  }

  void _validate() {
    widget.onValidChange(
      atributos.any((attr) => attr["controller"].text.trim().isNotEmpty),
    );
  }

  void guardar(ComponentService provider) {
    for (var attr in atributos) {
      final nombre = attr["controller"].text.trim();
      final tipo = attr["tipo"];
      if (nombre.isNotEmpty) {
        provider.agregarAtributo(nombre, tipo);
      }
    }
  }

  @override
  void dispose() {
    for (var attr in atributos) {
      (attr["controller"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...atributos.map((attr) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: attr["controller"],
                  decoration: const InputDecoration(
                    labelText: "Nombre Atributo",
                  ),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: attr["tipo"],
                  items: tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => attr["tipo"] = v);
                  },
                ),
              ),
            ],
          );
        }),
        TextButton.icon(
          onPressed: _addAtributo,
          icon: const Icon(Icons.add),
          label: const Text("Añadir atributo"),
        ),
      ],
    );
  }
}

class ComponenteForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  const ComponenteForm({super.key, required this.onValidChange});

  @override
  State<ComponenteForm> createState() => _ComponenteFormState();
}

class _ComponenteFormState extends State<ComponenteForm> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    codigoController.addListener(_validate);
    cantidadController.addListener(_validate);
  }

  void _validate() {
    widget.onValidChange(
      codigoController.text.isNotEmpty && cantidadController.text.isNotEmpty,
    );
  }

  void guardar(ComponentService provider) {
    final codigo = codigoController.text.trim();
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;
    if (codigo.isNotEmpty && cantidad > 0) {
      provider.crearComponente(codigo, cantidad);
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: codigoController,
          decoration: const InputDecoration(labelText: "Código de Inventario"),
        ),
        TextField(
          controller: cantidadController,
          decoration: const InputDecoration(labelText: "Cantidad"),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class ValorAtributoForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  const ValorAtributoForm({super.key, required this.onValidChange});

  @override
  State<ValorAtributoForm> createState() => _ValorAtributoFormState();
}

class _ValorAtributoFormState extends State<ValorAtributoForm> {
  final Map<int, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ComponentService>(context, listen: false);
    for (var attr in provider.atributos) {
      controllers[attr.id!] = TextEditingController();
      controllers[attr.id!]!.addListener(_validate);
    }
  }

  void _validate() {
    widget.onValidChange(
      controllers.values.any((c) => c.text.trim().isNotEmpty),
    );
  }

  void guardar(ComponentService provider) {
    controllers.forEach((id, controller) {
      final valor = controller.text.trim();
      if (valor.isNotEmpty) {
        provider.setValorAtributo(id, valor);
      }
    });
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentService>(context);
    return Column(
      children: provider.atributos.map((attr) {
        final controller = controllers[attr.id!]!;
        return CustomTextField(
          controller: controller,
          hintText: "Ingresar el valor",
          label: "Valor de ${attr.nombre}",
        );
      }).toList(),
    );
  }
}
