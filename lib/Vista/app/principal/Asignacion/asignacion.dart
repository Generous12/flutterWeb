import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';

class AsignacionScreen extends StatelessWidget {
  const AsignacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProv = Provider.of<CaseProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asignación de Case'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    caseProv.modoCarrito
                        ? 'Modo Carrito: Activado'
                        : 'Modo Carrito: Desactivado',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Switch(
                    value: caseProv.modoCarrito,
                    activeColor: Colors.green,
                    onChanged: (_) {
                      caseProv.toggleModoCarrito();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Componentes seleccionados:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: caseProv.componentesSeleccionados.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay componentes seleccionados.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: caseProv.componentesSeleccionados.length,
                        itemBuilder: (context, index) {
                          final id = caseProv.componentesSeleccionados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text('Componente ID: $id'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  caseProv.quitarComponente(id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<int>(
                value: caseProv.idAreaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Área',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Área de Soporte')),
                  DropdownMenuItem(value: 2, child: Text('Área de Desarrollo')),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Área Administrativa'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) caseProv.seleccionarArea(value);
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar Asignación'),
                  onPressed: () {
                    if (!caseProv.modoCarrito) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Activa el modo carrito para realizar una asignación.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (caseProv.componentesSeleccionados.isEmpty ||
                        caseProv.idAreaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona al menos un componente y un área antes de confirmar.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asignación creada correctamente ✅'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    caseProv.limpiarCase();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
