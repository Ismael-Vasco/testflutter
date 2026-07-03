# Ejercicio práctico de desarrollo

Vas a construir una pequeña app de "Lista de Gastos Compartidos" (Split Expenses) desde cero. Es un ejercicio
pensado para resolverse en aproximadamente 60 minutos, que requiere estructurar el proyecto, tomar
decisiones de arquitectura y resolver varios detalles puntuales que no vienen resueltos en el enunciado, puedes
apoyarte y usar la IA como herramienta de ayuda para este ejercicio.


## Contexto de la app
La app permite registrar los gastos de un grupo de amigos y ver cuánto debe pagar o recibir cada persona. No se
entrega ningún proyecto base ni plantilla: debes crear la estructura de carpetas, los modelos, la capa de estado
y las pantallas desde cero.

## Requisitos funcionales
1. Pantalla de lista de gastos: mostrar cada gasto con nombre, monto y quién pagó.
2. Formulario para agregar un nuevo gasto (nombre del gasto, monto, quién pagó, seleccionado de una
lista fija de 4 personas).
3. Cálculo del balance: cuánto debe recibir o pagar cada persona respecto al promedio del grupo (esta
lógica de cálculo debes implementarla tú; se explica el criterio abajo).
4. Validación del formulario: no permitir montos negativos, en cero, ni campos vacíos.
5. Navegación entre la pantalla de lista y la pantalla de formulario usando go_router.
6. Manejo de estado con Riverpod, Cubit o BLoC (a elección propia).

## Detalles que requieren criterio propio
Estos puntos están puestos a propósito, ya que no se resuelven solo con leer el enunciado general:

- El criterio de cálculo del balance no es un algoritmo estándar: se calcula como (monto pagado por la
persona) menos (promedio total de gastos entre las 4 personas), y debe mostrarse en verde si la
persona debe recibir dinero y en rojo si debe pagar. Este comportamiento visual específico no viene en
ningún tutorial genérico.
- El balance de cada persona debe calcularse y reflejarse en pantalla automáticamente al agregar un
nuevo gasto, sin recargar manualmente la vista; esto depende de cómo se estructure el estado, no solo
de que "funcione" al usarlo una vez.
- Debes elegir entre Riverpod, Cubit o BLoC y justificar brevemente por qué, considerando el tamaño real
de esta app (una lista, un formulario y un cálculo derivado), no una respuesta genérica de "siempre se
usa X".
- Debes decidir qué mostrar cuando la lista de gastos está vacía (por ejemplo, al abrir la app por primera
vez), en lugar de dejar una pantalla en blanco sin ningún mensaje.
- Los montos deben mostrarse con 2 decimales de forma consistente en toda la app, incluyendo los casos
en que la suma o el promedio generen resultados con más decimales.
- Al final debes escribir un párrafo corto (5-7 líneas) explicando, en tus palabras, qué gestor de estado
elegiste y por qué, y qué decisiones de diseño tomaste para el cálculo del balance.

## Entregables
- Carpeta del proyecto Flutter (o enlace a repositorio) con el código funcionando.
- Captura de pantalla o video corto (máx. 1 min) mostrando la app funcionando.
- El párrafo de reflexión mencionado arriba.