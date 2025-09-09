import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
import 'package:proyecto_web/Controlador/mysql/conexion.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () async {
            final provider = Provider.of<ComponentService>(
              context,
              listen: false,
            );

            if (provider.tipoSeleccionado != null) {
              final salir = await showCustomDialog(
                context: context,
                title: "Confirmar salida",
                message:
                    "Hay un tipo de componente en proceso: '${provider.tipoSeleccionado!.nombre}'. ¿Deseas salir y perder los cambios?",
                confirmButtonText: "Sí",
                cancelButtonText: "No",
              );

              if (salir == true) {
                provider.reset();
                Navigator.pop(context);
              }
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
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
                      height: 30,
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
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: index <= pasoActual
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
                      child: LoadingOverlayButtonHabilitar(
                        text: "Volver",
                        enabled: true,
                        onPressedLogic: () async {
                          anteriorPaso();
                        },
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
                            navegarConSlideDerecha(
                              context,
                              const VisualizarComponenteScreen(),
                            );
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

//PASO 1 ASIGNAMOS NOMBRE DEL COMPONENTE
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

//PASO 2 CREAMOS LOS ATRIBUTOS PAR EL COMOPONENTE
class AtributoForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  const AtributoForm({super.key, required this.onValidChange});

  @override
  State<AtributoForm> createState() => _AtributoFormState();
}

class _AtributoFormState extends State<AtributoForm> {
  final List<Map<String, dynamic>> atributos = [];
  final List<String> tipos = ["Texto", "Número", "Fecha"];
  final Map<String, String> abreviaturas = {
    "Texto": "T",
    "Número": "N",
    "Fecha": "F",
  };

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

  Future<void> _seleccionarTipo(Map<String, dynamic> attr) async {
    final seleccionado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona el tipo de atributo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tipos
              .map(
                (t) => ListTile(
                  title: Text(t),
                  onTap: () => Navigator.pop(context, t),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (seleccionado != null) {
      setState(() => attr["tipo"] = seleccionado);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Creacion de los atributos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 0),
          ...atributos.asMap().entries.map((entry) {
            final index = entry.key;
            final attr = entry.value;

            return Dismissible(
              key: ValueKey(attr["controller"]),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                final eliminado = attr;

                setState(() {
                  atributos.removeAt(index);
                  _validate();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Atributo eliminado"),
                    duration: const Duration(seconds: 8),
                    action: SnackBarAction(
                      label: "Deshacer",
                      textColor: Colors.blue,
                      onPressed: () {
                        setState(() {
                          atributos.insert(index, eliminado);
                          _validate();
                        });
                      },
                    ),
                  ),
                );
              },
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: attr["controller"],
                        hintText: "Ingresar los atributos del componente",
                        label: "Nombre Atributo",
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _seleccionarTipo(attr),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey.shade100,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          abreviaturas[attr["tipo"]] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _addAtributo,
            icon: const Icon(Icons.add),
            label: const Text("Añadir atributo"),
          ),
        ],
      ),
    );
  }
}

//PASO 3 ASIGNMAOS NOMBRE DE INVENTARIO Y CANTIDAD
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

    final provider = Provider.of<ComponentService>(context, listen: false);
    if (provider.tipoSeleccionado != null) {
      final base = provider.tipoSeleccionado!.nombre
          .substring(0, 3)
          .toUpperCase();
      final codigoGenerado = "$base-${DateTime.now().millisecondsSinceEpoch}";
      codigoController.text = codigoGenerado;
    }

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Asignar nombre de inventario y cantidad",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: codigoController,
                  hintText: "Se genera a partir del nombre del componente",
                  label: "Código de Inventario",
                ),
                CustomTextField(
                  controller: cantidadController,
                  hintText: "Ingrese la cantidad",
                  label: "Cantidad",
                  isNumeric: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PASO 4 ASIGNAMOS LOS VALORES ACORDE A LOS ATRIBUTOS CREADOS
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
    for (var i = 0; i < provider.atributos.length; i++) {
      controllers[i] = TextEditingController();
      controllers[i]!.addListener(_validate);
    }
  }

  void _validate() {
    widget.onValidChange(
      controllers.values.any((c) => c.text.trim().isNotEmpty),
    );
  }

  void guardar(ComponentService provider) {
    controllers.forEach((index, controller) {
      final valor = controller.text.trim();
      if (valor.isNotEmpty) {
        provider.setValorAtributo(index, valor);
        // Ahora se guarda con index
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Agregar datos a los atributos creados",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: provider.atributos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attr = entry.value;
                  final controller = controllers[index]!;

                  return CustomTextField(
                    key: ValueKey("attr_${index}"),
                    controller: controller,
                    hintText: "Ingresar el valor",
                    label: "Valor de ${attr.nombre}",
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//VISUALIZACION DE LOS CAMBIOSimport

class VisualizarComponenteScreen extends StatelessWidget {
  const VisualizarComponenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Visualizar Componente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.tipoSeleccionado == null
            ? const Center(
                child: Text(
                  "No hay componente creado todavía",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoCard(
                      icon: LucideIcons.package,
                      title: "Tipo de Componente",
                      subtitle: provider.tipoSeleccionado!.nombre,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),

                    if (provider.componenteCreado != null)
                      _InfoCard(
                        icon: LucideIcons.layers,
                        title: "Componente Creado",
                        subtitle:
                            "Código: ${provider.componenteCreado!.codigoInventario}\n"
                            "Cantidad: ${provider.componenteCreado!.cantidad}",
                        color: Colors.black87,
                      ),
                    const SizedBox(height: 24),

                    const Text(
                      "Atributos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...provider.atributos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attr = entry.value;
                      final valor =
                          provider.valoresAtributos[index] ?? "(Sin valor)";

                      return _AttributeCard(
                        icon: LucideIcons.settings,
                        nombre: attr.nombre,
                        tipo: attr.tipoDato,
                        valor: valor,
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoadingOverlayButtonHabilitar(
            text: "Registrar",
            enabled: true,
            onPressedLogic: () async {
              final confirmado = await showCustomDialog(
                context: context,
                title: "Confirmar",
                message: "¿Deseas guardar el componente?",
                confirmButtonText: "Sí",
                cancelButtonText: "No",
              );

              if (confirmado == true) {
                try {
                  final api = ComponenteApiService();

                  // 1. Registrar Tipo de Componente
                  final tipo = provider
                      .tipoSeleccionado; // asumimos que lo tienes en provider
                  final tipoId = await api.registrarTipoComponente(tipo!);

                  // 2. Registrar los Atributos asociados
                  final atributos = provider.atributos;
                  final Map<int, int> mapaAtributoIds = {};

                  for (final atributo in atributos) {
                    final res = await http.post(
                      Uri.parse("${api.baseUrl}/atributo"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "id_tipo": tipoId,
                        "nombre_atributo": atributo.nombre,
                        "tipo_dato": atributo.tipoDato,
                      }),
                    );
                    if (res.statusCode != 200) {
                      throw Exception(
                        "Error creando atributo: ${atributo.nombre}",
                      );
                    }

                    final attrId = jsonDecode(res.body)["id"];
                    mapaAtributoIds[atributo.id!] = attrId;
                  }

                  // 3. Registrar el Componente
                  final componente = provider.componenteCreado!
                    ..idTipo = tipoId;
                  final compId = await api.registrarComponente(componente);

                  // 4. Registrar los valores de atributos
                  for (final entry in provider.valoresAtributos.entries) {
                    final idAtributoLocal = entry.key; // id del atributo local
                    final valor = entry.value; // valor escrito por el usuario
                    final idAtributoReal = mapaAtributoIds[idAtributoLocal];

                    if (idAtributoReal == null) continue;

                    await api.registrarValorAtributo(
                      idComponente: compId,
                      idAtributo: idAtributoReal,
                      valor: valor,
                    );
                  }

                  // ✅ Listo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Componente registrado con éxito"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}

class _AttributeCard extends StatelessWidget {
  final IconData icon;
  final String nombre;
  final String tipo;
  final String valor;

  const _AttributeCard({
    required this.icon,
    required this.nombre,
    required this.tipo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.15),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "Tipo: $tipo",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
