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
import 'package:proyecto_web/Vista/app/principal/inicio.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/cropper.dart';
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
      setState(() {
        pasoActual--;
        // Si quieres que pueda continuar según los datos que ya tiene:
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
        title: const Text("Crear Componente", style: TextStyle(fontSize: 20)),
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
                navegarYRemoverConSlideIzquierda(context, const InicioScreen());
              }
            } else {
              provider.reset();
              navegarYRemoverConSlideIzquierda(context, const InicioScreen());
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
                      enabled: puedeContinuar,
                      onPressedLogic: () async {
                        if (!puedeContinuar) return;

                        final provider = Provider.of<ComponentService>(
                          context,
                          listen: false,
                        );

                        // 🔹 Validar si ya hay datos en el provider según el paso
                        bool guardar = false;
                        switch (pasoActual) {
                          case 0:
                            // Paso 0: Tipo de componente
                            guardar = provider.tipoSeleccionado == null;
                            break;
                          case 1:
                            // Paso 1: Componente
                            guardar = provider.componenteCreado == null;
                            break;
                          case 2:
                            // Paso 2: Valores de atributos
                            guardar = provider.valoresAtributos.isEmpty;
                            break;
                        }

                        // 🔹 Guardar solo si no existe
                        if (guardar) {
                          await guardarPaso();
                        }

                        // 🔹 Avanzar al siguiente paso o finalizar
                        if (pasoActual < pasosWidgets.length - 1) {
                          siguientePaso();
                        } else {
                          debugPrint("✅ Flujo finalizado");
                          navegarConSlideDerecha(
                            context,
                            const VisualizarComponenteScreen(),
                          );
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

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ComponentService>(context, listen: false);
    if (provider.tipoSeleccionado != null) {
      nombreController.text = provider.tipoSeleccionado!.nombre;
      atributos.clear();
      for (var attr in provider.atributos) {
        final controller = TextEditingController(text: attr.nombre);
        controller.addListener(_validate);
        atributos.add({"controller": controller, "tipo": attr.tipoDato});
      }
    }

    nombreController.addListener(_validate);
  }

  void _validate() {
    final bool isValid =
        nombreController.text.trim().length > 3 &&
        atributos.isNotEmpty &&
        atributos.any((attr) => attr["controller"].text.trim().isNotEmpty);

    widget.onValidChange(isValid);
  }

  void _addAtributo() {
    final controller = TextEditingController();
    controller.addListener(_validate);
    atributos.add({"controller": controller, "tipo": tipos[0]});
    setState(() => _validate());
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

    // Comparamos con el valor actual en el provider
    final nombreOriginal = provider.tipoSeleccionado?.nombre ?? '';
    final cambiosEnNombre = nombre != nombreOriginal;

    // Comparamos atributos
    bool cambiosEnAtributos = false;
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

    // Si hubo cambios, actualizamos
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

  Future<Plantilla?> mostrarDialogoPlantilla(BuildContext context) async {
    final Map<String, IconData> iconosPlantilla = {
      "Periféricos": LucideIcons.mouse,
      "RAM": LucideIcons.cpu,
      "Procesador": LucideIcons.cpu,
      "Disco duro / SSD": LucideIcons.hardDrive,
      "Tarjeta de video": LucideIcons.monitor,
    };

    return showDialog<Plantilla>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona una plantilla"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: plantillas.map((p) {
            return ListTile(
              leading: Icon(
                iconosPlantilla[p.nombre] ?? LucideIcons.box,
                color: Colors.blue,
              ),
              title: Text(p.nombre),
              onTap: () => Navigator.pop(context, p),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
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
            onPressed: () async {
              final seleccion = await mostrarDialogoPlantilla(context);
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

//IMAGENES INCLUIDAS
class _ComponenteFormState extends State<ComponenteForm> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final List<File> _imagenesSeleccionadas = [];
  File? _imagenPrincipal;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ComponentService>(context, listen: false);

    if (provider.componenteCreado != null) {
      codigoController.text = provider.componenteCreado!.codigoInventario;
      cantidadController.text = provider.componenteCreado!.cantidad.toString();
      _imagenesSeleccionadas.addAll(provider.componenteCreado!.imagenes ?? []);
      if (_imagenesSeleccionadas.isNotEmpty) {
        _imagenPrincipal = _imagenesSeleccionadas.first;
      }
    } else if (provider.tipoSeleccionado != null) {
      codigoController.text = generarCodigoInventario(
        provider.tipoSeleccionado!.nombre,
      );
    }

    codigoController.addListener(_validate);
    cantidadController.addListener(_validate);
  }

  void _validate() {
    widget.onValidChange(
      codigoController.text.isNotEmpty && cantidadController.text.isNotEmpty,
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

          // 🔹 Actualizamos el provider con las imágenes
          provider.crearComponente(
            codigoController.text.trim(),
            int.tryParse(cantidadController.text.trim()) ?? 0,
            imagenes: _imagenesSeleccionadas,
          );
        });
      }
    }
  }

  void guardar(ComponentService provider) {
    final codigo = codigoController.text.trim();
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;

    final componenteOriginal = provider.componenteCreado;

    // Revisamos si hubo cambios
    final cambios =
        componenteOriginal == null ||
        componenteOriginal.codigoInventario != codigo ||
        componenteOriginal.cantidad != cantidad ||
        !listEquals(componenteOriginal.imagenes ?? [], _imagenesSeleccionadas);

    if (cambios) {
      provider.crearComponente(
        codigo,
        cantidad,
        imagenes: _imagenesSeleccionadas.isNotEmpty
            ? _imagenesSeleccionadas
            : null,
        reemplazar: true, // similar al paso anterior
      );
    }
  }

  String generarCodigoInventario(String nombre) {
    // Tomamos las primeras 3 letras del nombre (o todo si es más corto) y lo ponemos en mayúsculas
    final cleanName = nombre.replaceAll(' ', '').toUpperCase();
    final prefix = cleanName.length >= 3
        ? cleanName.substring(0, 3)
        : cleanName;

    // Agregamos fecha en formato año-mes-día
    final now = DateTime.now();
    final datePart =
        "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    // Número aleatorio de 3 dígitos
    final randomNumber = (100 + Random().nextInt(900)).toString();

    // Combinamos todo
    return "$prefix-$datePart-$randomNumber";
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
            "Asignar nombre de inventario, cantidad e imágenes (opcional)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: codigoController,
            hintText: "Se genera a partir del nombre del componente",
            label: "Generar codigo de inventario",
          ),

          CustomTextField(
            controller: cantidadController,
            hintText: "Ingrese la cantidad",
            label: "Cantidad",
            isNumeric: true,
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
                        // opcional: mostrar imagen fullscreen
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

class VisualizarComponenteScreen extends StatelessWidget {
  const VisualizarComponenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComponentService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 48,
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
                Provider.of<ComponentService>(context, listen: false).reset();
                navegarYRemoverConSlideIzquierda(context, const InicioScreen());
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
                    if (provider.componenteCreado != null &&
                        provider.componenteCreado!.imagenes != null &&
                        provider.componenteCreado!.imagenes!.isNotEmpty)
                      Column(
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
                              itemCount:
                                  provider.componenteCreado!.imagenes!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
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
                  final continuar = await showCustomDialog(
                    context: context,
                    title: "Éxito",
                    message:
                        "Componente guardado correctamente.\n\n¿Deseas registrar otro?",
                    confirmButtonText: "Sí",
                    cancelButtonText: "No",
                  );

                  if (continuar == true) {
                    print("🔄 Usuario quiere seguir registrando");
                    Provider.of<ComponentService>(
                      context,
                      listen: false,
                    ).reset();
                    navegarYRemoverConSlideIzquierda(
                      context,
                      const FlujoCrearComponente(),
                    );
                  } else {
                    print("🏠 Usuario quiere volver al inicio");
                    Provider.of<ComponentService>(
                      context,
                      listen: false,
                    ).reset();
                    navegarYRemoverConSlideIzquierda(
                      context,
                      const InicioScreen(),
                    );
                  }
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
