import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Clases/plantillasComponente.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Vista/app/principal/Asignacion/asignacion.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/cropper.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';
import 'package:proyecto_web/Widgets/toastalertSo.dart';
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
        onValidChange: (isValid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => puedeContinuar = isValid);
            }
          });
        },
      ),
      ComponenteForm(
        key: componenteFormKey,
        onValidChange: (isValid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => puedeContinuar = isValid);
            }
          });
        },
      ),
      ValorAtributoForm(
        key: valorAtributoFormKey,
        onValidChange: (isValid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => puedeContinuar = isValid);
            }
          });
        },
      ),
      _ResumenComponente(),
    ];
  }

  void siguientePaso() {
    if (pasoActual < pasosWidgets.length - 1) {
      setState(() {
        pasoActual++;
        puedeContinuar = pasoActual == pasosWidgets.length - 1 ? true : false;
      });
    }
  }

  void anteriorPaso() {
    if (pasoActual > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            pasoActual--;
            puedeContinuar = true;
          });
        }
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

  Future<void> _guardarComponenteFinal() async {
    final confirmado = await showCustomDialog(
      context: context,
      title: "Confirmar",
      message: "¿Deseas guardar el componente?",
      confirmButtonText: "Sí",
      cancelButtonText: "No",
    );

    if (confirmado != true) return;

    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    final exito = await Provider.of<ComponentService>(context, listen: false)
        .guardarEnBackendB(
          idUsuarioCreador: usuarioProvider.idUsuario ?? "",
          rolCreador: usuarioProvider.rol ?? "",
        );

    if (!exito) {
      await showCustomDialog(
        context: context,
        title: "Error",
        message: "❌ El componente no se guardó correctamente.",
        confirmButtonText: "Cerrar",
      );
      return;
    }

    final accion = await showCustomDialog(
      context: context,
      title: "Éxito",
      message:
          "Componente guardado correctamente.\n\n¿Qué deseas hacer a continuación?",
      confirmButtonText: "Registrar otro",
      cancelButtonText: "Crear asignación",
    );

    final provider = Provider.of<ComponentService>(context, listen: false);
    provider.reset();

    if (accion == true) {
      setState(() {
        pasoActual = 0;
        puedeContinuar = false;
      });

      tipoComponenteKey.currentState?.reset();
      componenteFormKey.currentState?.reset();
      valorAtributoFormKey.currentState?.reset();

      ToastUtil.showSuccess("Crear nuevo componente");
    } else {
      navegarConSlideDerecha(context, const AsignacionScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
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
              return true;
            } else {
              return false;
            }
          } else {
            provider.reset();
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Crear Componente",
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: Colors.black,
            toolbarHeight: 48,
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
                  provider.reset();
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: pasosWidgets.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 100,
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
                                    ? const Color(0xFF2196F3)
                                    : index == pasoActual
                                    ? const Color(0xFF448AFF)
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

                Expanded(
                  child: SingleChildScrollView(child: pasosWidgets[pasoActual]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                          enabled: pasoActual == pasosWidgets.length - 1
                              ? true
                              : puedeContinuar,
                          onPressedLogic: () async {
                            if (pasoActual < pasosWidgets.length - 1) {
                              if (!puedeContinuar) return;
                              await guardarPaso();
                              siguientePaso();
                            } else {
                              await _guardarComponenteFinal();
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
        ),
      ),
    );
  }
}

class _ResumenComponente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentService>(context);

    if (provider.tipoSeleccionado == null) {
      return const Center(
        child: Text(
          "No hay componente creado todavía",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            icon: LucideIcons.package,
            title: "Tipo de Componente",
            subtitle: provider.tipoSeleccionado!.nombre,
            color: Colors.blue,
          ),
          if (provider.componenteCreado != null)
            _InfoCard(
              icon: LucideIcons.layers,
              title: "Componente Creado",
              subtitle:
                  "Código: ${provider.componenteCreado!.codigoInventario}\n"
                  "Estado: ${provider.componenteCreado!.estado}",
              color: Colors.black87,
            ),
          if (provider.componenteCreado != null)
            _InfoCard(
              icon: LucideIcons.package,
              title: "Tipo Guardado",
              subtitle: provider.componenteCreado!.tipoNombre,
              color: Colors.blueGrey,
            ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Atributos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...provider.atributos.map((attr) {
            final valor = provider.valoresAtributos[attr.id!] ?? "(Sin valor)";
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16,
              ),
              child: _AttributeCard(
                icon: LucideIcons.settings,
                nombre: attr.nombre,
                tipo: attr.tipoDato,
                valor: valor,
              ),
            );
          }).toList(),

          if (provider.componenteCreado != null &&
              provider.componenteCreado!.imagenes != null &&
              provider.componenteCreado!.imagenes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Imágenes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.componenteCreado!.imagenes!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final file =
                            provider.componenteCreado!.imagenes![index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
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
  final List<Plantilla> plantillas = [
    Plantilla(
      nombre: "Periféricos",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"},
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Tipo de conexión", "tipo": "Texto"},
        {"nombre": "Color", "tipo": "Texto"},
        {"nombre": "Dimensiones", "tipo": "Texto"},
        {"nombre": "Peso", "tipo": "Número"},
      ],
    ),
    Plantilla(
      nombre: "RAM",
      atributos: [
        {"nombre": "Capacidad", "tipo": "Número"}, // GB
        {"nombre": "Velocidad", "tipo": "Número"}, // MHz
        {"nombre": "Tipo", "tipo": "Texto"}, // DDR4, DDR5, etc.
        {"nombre": "Latencia", "tipo": "Número"}, // CL
        {"nombre": "Voltaje", "tipo": "Número"}, // V
      ],
    ),
    Plantilla(
      nombre: "Procesador",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"}, // Intel, AMD
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Número de núcleos", "tipo": "Número"},
        {"nombre": "Número de hilos", "tipo": "Número"},
        {"nombre": "Frecuencia base", "tipo": "Número"}, // GHz
        {"nombre": "Frecuencia turbo", "tipo": "Número"}, // GHz
        {"nombre": "Litografía", "tipo": "Número"}, // nm
      ],
    ),
    Plantilla(
      nombre: "Disco duro / SSD",
      atributos: [
        {"nombre": "Capacidad", "tipo": "Número"}, // GB/TB
        {"nombre": "Tipo", "tipo": "Texto"}, // SSD, HDD
        {"nombre": "Interfaz", "tipo": "Texto"}, // SATA, NVMe
        {"nombre": "Velocidad de lectura", "tipo": "Número"}, // MB/s
        {"nombre": "Velocidad de escritura", "tipo": "Número"}, // MB/s
        {"nombre": "Formato", "tipo": "Texto"}, // 2.5", M.2, etc.
      ],
    ),
    Plantilla(
      nombre: "Tarjeta de video",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"}, // Nvidia, AMD
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Memoria", "tipo": "Número"}, // GB
        {"nombre": "Tipo de memoria", "tipo": "Texto"}, // GDDR6, etc.
        {"nombre": "Frecuencia del núcleo", "tipo": "Número"}, // MHz
        {"nombre": "Consumo energético", "tipo": "Número"}, // W
      ],
    ),
    Plantilla(
      nombre: "Placa base",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"},
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Socket", "tipo": "Texto"}, // LGA1700, AM5, etc.
        {"nombre": "Chipset", "tipo": "Texto"},
        {"nombre": "Memoria máxima", "tipo": "Número"}, // GB
        {"nombre": "Ranuras RAM", "tipo": "Número"},
        {"nombre": "Formato", "tipo": "Texto"}, // ATX, Micro-ATX
      ],
    ),
  ];

  final TextEditingController nombreController = TextEditingController();
  final List<Map<String, dynamic>> atributos = [];
  final List<String> tipos = ["Texto", "Número", "Fecha"];
  final Map<String, String> abreviaturas = {
    "Texto": "T",
    "Número": "N",
    "Fecha": "F",
  };
  void reset() {
    nombreController.clear();
    for (var attr in atributos) {
      (attr["controller"] as TextEditingController).dispose();
    }
    atributos.clear();
    widget.onValidChange(false);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<ComponentService>(context, listen: false);

    if (provider.tipoSeleccionado != null) {
      nombreController.text = provider.tipoSeleccionado!.nombre;

      for (var attr in atributos) {
        (attr["controller"] as TextEditingController).dispose();
      }
      atributos.clear();

      for (var attr in provider.atributos) {
        final controller = TextEditingController(text: attr.nombre);
        controller.addListener(_validate);
        atributos.add({"controller": controller, "tipo": attr.tipoDato});
      }
      _validate();
      setState(() {});
    }
  }

  void _validate() {
    final bool isValid =
        nombreController.text.trim().length > 2 &&
        atributos.isNotEmpty &&
        atributos.any((attr) => attr["controller"].text.trim().isNotEmpty);

    widget.onValidChange(isValid);
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

    final nombreOriginal = provider.tipoSeleccionado?.nombre ?? '';
    final cambiosEnNombre = nombre != nombreOriginal;

    final atributosUI = atributos
        .map(
          (attr) => {
            "nombre": attr["controller"].text.trim(),
            "tipo": attr["tipo"],
          },
        )
        .toList();

    final atributosAEliminar = provider.atributos.where((a) {
      return !atributosUI.any(
        (uiAttr) =>
            uiAttr["nombre"] == a.nombre && uiAttr["tipo"] == a.tipoDato,
      );
    }).toList();

    for (var eliminado in atributosAEliminar) {
      provider.eliminarAtributo(eliminado.id!);
    }

    bool cambiosEnAtributos = atributosAEliminar.isNotEmpty;
    if (!cambiosEnAtributos) {
      for (int i = 0; i < atributos.length; i++) {
        final nombreAttr = atributos[i]["controller"].text.trim();
        final tipoAttr = atributos[i]["tipo"];

        if (i >= provider.atributos.length ||
            nombreAttr != provider.atributos[i].nombre ||
            tipoAttr != provider.atributos[i].tipoDato) {
          cambiosEnAtributos = true;
          break;
        }
      }
    }

    if (cambiosEnNombre || cambiosEnAtributos) {
      provider.crearTipoComponente(nombre, reemplazar: true);

      for (var attr in atributos) {
        final nombreAttr = attr["controller"].text.trim();
        final tipo = attr["tipo"];
        if (nombreAttr.isNotEmpty) {
          provider.agregarAtributo(nombreAttr, tipo, reemplazar: true);
        }
      }
    }
  }

  Future<Plantilla?> mostrarModalPlantilla(BuildContext context) async {
    final Map<String, IconData> iconosPlantilla = {
      "Periféricos": LucideIcons.mouse,
      "RAM": LucideIcons.cpu,
      "Procesador": LucideIcons.cpu,
      "Disco duro / SSD": LucideIcons.hardDrive,
      "Tarjeta de video": LucideIcons.monitor,
    };

    return showModalBottomSheet<Plantilla>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Selecciona una plantilla",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...plantillas.map((p) {
                    return ListTile(
                      leading: Icon(
                        iconosPlantilla[p.nombre] ?? LucideIcons.box,
                        color: Colors.blue,
                      ),
                      title: Text(p.nombre),
                      onTap: () => Navigator.pop(context, p),
                    );
                  }).toList(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    for (var attr in atributos) {
      (attr["controller"] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addAtributo() {
    final controller = TextEditingController();
    controller.addListener(_validate);
    atributos.add({"controller": controller, "tipo": tipos[0]});
    setState(() => _validate());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: nombreController,
            hintText: "Ingresa el nombre del componente",
            label: "Nombre de componente",
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lista de Atributos",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addAtributo,
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  "Añadir atributo",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
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
                SnackBarUtil.mostrarSnackBarPersonalizado(
                  context: context,
                  mensaje: "Atributo eliminado",
                  icono: Icons.delete,
                  duracion: const Duration(milliseconds: 500),
                  textoAccion: "Deshacer",
                  onAccion: () {
                    setState(() {
                      atributos.insert(index, eliminado);
                      _validate();
                    });
                  },
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
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.all(1),
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
                        suffixIcon: GestureDetector(
                          onTap: () => _seleccionarTipo(attr),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                abreviaturas[attr["tipo"]] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
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
            onPressed: () async {
              final seleccion = await mostrarModalPlantilla(context);
              if (seleccion != null) {
                for (var attr in atributos) {
                  (attr["controller"] as TextEditingController).dispose();
                }
                atributos.clear();
                for (var attr in seleccion.atributos) {
                  final controller = TextEditingController(
                    text: attr["nombre"],
                  );
                  controller.addListener(_validate);
                  atributos.add({
                    "controller": controller,
                    "tipo": attr["tipo"],
                  });
                }
                setState(() {});
                _validate();
              }
            },
            icon: const Icon(Icons.list, color: Colors.black),
            label: const Text(
              "Usar plantilla",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 5),
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
  final List<File> _imagenesSeleccionadas = [];
  File? _imagenPrincipal;
  String? _tipoSeleccionado;
  String? _estadoSeleccionado = "Disponible";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<ComponentService>(context, listen: false);

    if (provider.componenteCreado != null) {
      codigoController.text = provider.componenteCreado!.codigoInventario;
      _estadoSeleccionado = provider.componenteCreado!.estado;

      _imagenesSeleccionadas.clear();
      _imagenesSeleccionadas.addAll(provider.componenteCreado!.imagenes ?? []);
      _imagenPrincipal = _imagenesSeleccionadas.isNotEmpty
          ? _imagenesSeleccionadas.first
          : null;
      _tipoSeleccionado = provider.componenteCreado!.tipoNombre;
      _validate();
      setState(() {});
    } else if (provider.tipoSeleccionado != null &&
        codigoController.text.isEmpty) {
      codigoController.text = generarCodigoInventario(
        provider.tipoSeleccionado!.nombre,
      );
    }
    codigoController.addListener(_validate);
  }

  void _validate() {
    widget.onValidChange(
      codigoController.text.isNotEmpty &&
          _imagenesSeleccionadas.isNotEmpty &&
          _tipoSeleccionado != null &&
          _estadoSeleccionado != null,
    );
  }

  Future<void> _seleccionarImagen() async {
    if (_imagenesSeleccionadas.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Máximo 4 imágenes permitidas")),
      );
      return;
    }

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seleccionar origen de la imagen"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo),
            label: const Text("Galería"),
          ),
        ],
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: const Color(0xFFA30000),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            initAspectRatio: CropAspectRatioPreset.original,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPresetCustom4x5(),
              CropAspectRatioPresetCustom3x4(),
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        final provider = Provider.of<ComponentService>(context, listen: false);
        final newImage = File(croppedFile.path);

        setState(() {
          _imagenesSeleccionadas.add(newImage);
          if (_imagenPrincipal == null) {
            _imagenPrincipal = newImage;
          }

          provider.crearComponente(
            codigoController.text.trim(),
            estado: _estadoSeleccionado,
            imagenes: _imagenesSeleccionadas,
          );
          _validate();
        });
      }
    }
  }

  void guardar(ComponentService provider) {
    final codigo = codigoController.text.trim();

    final componenteOriginal = provider.componenteCreado;

    final cambios =
        componenteOriginal == null ||
        componenteOriginal.codigoInventario != codigo ||
        componenteOriginal.estado != _estadoSeleccionado ||
        componenteOriginal.tipoNombre != _tipoSeleccionado ||
        !listEquals(componenteOriginal.imagenes ?? [], _imagenesSeleccionadas);

    if (cambios) {
      provider.crearComponente(
        codigo,
        estado: _estadoSeleccionado,
        imagenes: _imagenesSeleccionadas.isNotEmpty
            ? _imagenesSeleccionadas
            : null,
        tipoNombre: _tipoSeleccionado,

        reemplazar: true,
      );
    }
  }

  String generarCodigoInventario(String nombre) {
    final cleanName = nombre.replaceAll(' ', '').toUpperCase();
    final prefix = cleanName.length >= 3
        ? cleanName.substring(0, 3)
        : cleanName;

    final now = DateTime.now();
    final datePart =
        "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    final randomNumber = (100 + Random().nextInt(900)).toString();

    return "$prefix-$datePart-$randomNumber";
  }

  void reset() {
    codigoController.clear();

    // Limpiar imágenes
    for (var img in _imagenesSeleccionadas) {
      if (img.existsSync()) {
        // opcional: eliminar físicamente si deseas
        // img.deleteSync();
      }
    }
    _imagenesSeleccionadas.clear();
    _imagenPrincipal = null;
    _tipoSeleccionado = null;
    _estadoSeleccionado = "Disponible";
    widget.onValidChange(false);
    setState(() {});
  }

  @override
  void dispose() {
    codigoController.dispose();
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
            "Asignar nombre de inventario, cantidad e imágenes (opcional)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: codigoController,
            hintText: "Se genera a partir del nombre del componente",
            label: "Generar codigo de inventario",
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AbsorbPointer(
                  absorbing: true,
                  child: Opacity(
                    opacity: 0.8,
                    child: CustomDropdownSelector(
                      labelText: "Estado",
                      hintText: "Seleccione el estado",
                      value: _estadoSeleccionado ?? "Disponible",
                      items: const ["Disponible", "Mantenimiento", "En uso"],
                      onChanged: (nuevoValor) {},
                      onClear: () {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: CustomDropdownSelector(
                  labelText: "Tipo",
                  hintText: "Selecciona...",
                  value: _tipoSeleccionado,
                  items: const ["Componentes", "Periféricos"],
                  onChanged: (value) {
                    setState(() {
                      _tipoSeleccionado = value;
                    });

                    final provider = Provider.of<ComponentService>(
                      context,
                      listen: false,
                    );
                    provider.crearComponente(
                      codigoController.text.trim(),
                      estado: _estadoSeleccionado,
                      imagenes: _imagenesSeleccionadas,
                      tipoNombre: _tipoSeleccionado,
                      reemplazar: true,
                    );

                    debugPrint("Seleccionado: $_tipoSeleccionado");
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MasonryGridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _imagenesSeleccionadas.length < 4
                ? _imagenesSeleccionadas.length + 1
                : _imagenesSeleccionadas.length,
            itemBuilder: (context, index) {
              if (index < _imagenesSeleccionadas.length) {
                final image = _imagenesSeleccionadas[index];
                final isSelected = image == _imagenPrincipal;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _imagenPrincipal = image;
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(image, fit: BoxFit.cover),
                      ),
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Iconsax.tick_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imagenesSeleccionadas.removeAt(index);

                            if (_imagenesSeleccionadas.isEmpty) {
                              _imagenPrincipal = null;
                            } else if (_imagenPrincipal == image) {
                              _imagenPrincipal = _imagenesSeleccionadas.first;
                            }
                          });
                        },
                        child: const Icon(
                          LucideIcons.trash,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.add_circle,
                        color: Colors.black87,
                        size: 30,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
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

  void reset() {
    setState(() {
      for (var controller in controllers.values) {
        controller.clear();
      }
      widget.onValidChange(false);
    });
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
          SingleChildScrollView(
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
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 20,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.15),
              radius: 18,
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tipo: $tipo",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
