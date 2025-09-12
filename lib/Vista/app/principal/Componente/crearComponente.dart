import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
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

  final tipoComponenteKey = GlobalKey<_TipoYAtributoFormState>();

  final componenteFormKey = GlobalKey<_ComponenteFormState>();
  final valorAtributoFormKey = GlobalKey<_ValorAtributoFormState>();

  late List<Widget> pasosWidgets;

  @override
  void initState() {
    super.initState();
    pasosWidgets = [
      TipoYAtributoForm(
        key: tipoComponenteKey,
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
        componenteFormKey.currentState?.guardar(provider);
        break;
      case 2:
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
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: pasosWidgets.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 100, // ancho fijo para que las líneas se conecten
                    child: TimelineTile(
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

//PASO 1 y 2  ASIGNAMOS NOMBRE DEL COMPONENTE Y CREAMS ATRIBUTOS
class TipoYAtributoForm extends StatefulWidget {
  final ValueChanged<bool> onValidChange;

  const TipoYAtributoForm({super.key, required this.onValidChange});

  @override
  State<TipoYAtributoForm> createState() => _TipoYAtributoFormState();
}

class _TipoYAtributoFormState extends State<TipoYAtributoForm> {
  // Tipo de componente
  final TextEditingController nombreController = TextEditingController();

  // Atributos
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
    nombreController.addListener(_validate);
    _addAtributo();
  }

  void _validate() {
    final bool isValid =
        nombreController.text.trim().isNotEmpty &&
        atributos.any((attr) => attr["controller"].text.trim().isNotEmpty);
    widget.onValidChange(isValid);
  }

  void _addAtributo() {
    final controller = TextEditingController();
    controller.addListener(_validate);
    atributos.add({"controller": controller, "tipo": tipos[0]});
    setState(() {});
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
      _validate();
    }
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

      for (var attr in atributos) {
        final nombreAttr = attr["controller"].text.trim();
        final tipo = attr["tipo"];
        if (nombreAttr.isNotEmpty) {
          provider.agregarAtributo(nombreAttr, tipo);
        }
      }

      await showCustomDialog(
        context: context,
        title: "¡Listo!",
        message:
            "El tipo de componente '$nombre' y sus atributos se crearon correctamente.",
        confirmButtonText: "Aceptar",
      );
    } else {
      // Si da "No", frena la navegación y sale de la pantalla
      provider.reset();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    for (var attr in atributos) {
      (attr["controller"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registrar componente y atributos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: nombreController,
            hintText: "Ingresa el nombre del componente",
            label: "Nombre de componente",
          ),
          const SizedBox(height: 16),
          const Text(
            "Atributos del componente",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                    duration: const Duration(seconds: 1),
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
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
                        hintText: "Nombre del atributo",
                        label: "Atributo",
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _addAtributo,
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
            label: const Text(
              "Añadir atributo",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
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
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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

    // Inicializamos los controllers usando los IDs únicos de los atributos
    for (var attr in provider.atributos) {
      // Todos los atributos deben tener un ID único asignado previamente
      controllers[attr.id!] = TextEditingController(
        text: provider.valoresAtributos[attr.id!] ?? '',
      );
      controllers[attr.id!]!.addListener(_validate);
    }
  }

  void _validate() {
    widget.onValidChange(
      controllers.values.any((c) => c.text.trim().isNotEmpty),
    );
  }

  void guardar(ComponentService provider) {
    controllers.forEach((attrId, controller) {
      final valor = controller.text.trim();
      if (valor.isNotEmpty) {
        provider.setValorAtributo(attrId, valor);
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
                children: provider.atributos.map((attr) {
                  final controller = controllers[attr.id!]!;
                  return CustomTextField(
                    key: ValueKey("attr_${attr.id}"),
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

class VisualizarComponenteScreen extends StatelessWidget {
  const VisualizarComponenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
                    // Mostramos los valores usando el ID real del atributo
                    ...provider.atributos.map((attr) {
                      final valor =
                          provider.valoresAtributos[attr.id!] ?? "(Sin valor)";

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
              print("🖱️ Botón presionado, mostrando diálogo de confirmación");
              final confirmado = await showCustomDialog(
                context: context,
                title: "Confirmar",
                message: "¿Deseas guardar el componente?",
                confirmButtonText: "Sí",
                cancelButtonText: "No",
              );

              if (confirmado == true) {
                print("➡️ Usuario confirmó, intentando guardar en backend");
                final exito = await Provider.of<ComponentService>(
                  context,
                  listen: false,
                ).guardarEnBackendB();

                if (exito) {
                  showCustomDialog(
                    context: context,
                    title: "Éxito",
                    message: "Componente guardado correctamente",
                    confirmButtonText: "Cerrar",
                  );
                } else {
                  showCustomDialog(
                    context: context,
                    title: "Error",
                    message: "Componente no guardado",
                    confirmButtonText: "Cerrar",
                  );
                }
              } else {
                print("⏹️ Usuario canceló la acción");
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
