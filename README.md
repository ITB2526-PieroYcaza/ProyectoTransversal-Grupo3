# pro-asixc1d-g3

<a name="indice"></a>
# Índice

    * [1.1. Plano sala del rack:](#1-1-plano-sala-del-rack)
    * [1.1.1. Estructuración de los Racks:](#1-1-1-estructuracion-de-los-racks)
      * [1.1.2. Componentes Técnicos Comunes por Rack:](#1-1-2-componentes-tecnicos-comunes-por-rack)
    * [1.2. Sistema de climatización del CPD:](#1-2-sistema-de-climatizacion-del-cpd)
    * [1.3. Medidas para dificultar la identificación de la sala:](#1-3-medidas-para-dificultar-la-identificacion-de-la-sala)
      * [1.3.1. Señalización Restrictiva:](#1-3-1-sealizacion-restrictiva)
      * [1.3.2. Seguridad de Rutas y Suministros:](#1-3-2-seguridad-de-rutas-y-suministros)
      * [1.3.3. Camuflaje Arquitectónico y Estético:](#1-3-3-camuflaje-arquitectonico-y-estetico)
    * [1.4. distribución y gestión del cableado:](#1-4-distribucion-y-gestion-del-cableado)
    * [1.5. Terra Tècnic (Suelo Técnico Elevado):](#1-5-terra-tecnic-suelo-tecnico-elevado)
      * [1.5.1. Sostre Tècnic (Falso Techo Registrable):](#1-5-1-sostre-tecnic-falso-techo-registrable)
      * [1.5.2. Estanqueidad con la Cristalera:](#1-5-2-estanqueidad-con-la-cristalera)
  * [2.	Infraestructura elèctrica:](#2-infraestructura-electrica)
    * [2.1 Sistemas de alimentación redundante:](#2-1-sistemas-de-alimentacion-redundante)
    * [2.2. Sistema SAI / UPS:](#2-2-sistema-sai--ups)
    * [2.3. Consumo eléctrico estimado:](#2-3-consumo-electrico-estimado)
    * [2.4. Distribución eléctrica en racks:](#2-4-distribucion-electrica-en-racks)
    * [2.5. Eficiencia energética:](#2-5-eficiencia-energetica)
    * [2.6. Seguridad Física](#2-6-seguridad-fisica)
      * [2.6.1. Medidas Pasivas:](#2-6-1-medidas-pasivas)
      * [2.6.2. Medidas activas:](#2-6-2-medidas-activas)
    * [2.7. Seguridad lógica](#2-7-seguridad-logica)
      * [2.7.1. Seguridad Lógica Pasiva:](#2-7-1-seguridad-logica-pasiva)
      * [2.7.2. Seguridad Lógica Activa:](#2-7-2-seguridad-logica-activa)
  * [2.8. Prevención de riesgos laborales:](#2-8-prevencion-de-riesgos-laborales)
      * [2.8.1. Riesgos Eléctricos:](#2-8-1-riesgos-electricos)
      * [2.8.2. Riesgos Ergonómicos:](#2-8-2-riesgos-ergonomicos)
      * [2.8.3. Riesgos por Ruido:](#2-8-3-riesgos-por-ruido)
      * [2.8.4. Riesgos Térmicos:](#2-8-4-riesgos-termicos)
      * [2.8.5. Riesgos de Incendio:](#2-8-5-riesgos-de-incendio)
      * [2.8.6. Riesgos de Caídas:](#2-8-6-riesgos-de-caidas)
      * [2.8.7. Riesgos por Radiaciones Electromagnéticas:](#2-8-7-riesgos-por-radiaciones-electromagneticas)
      * [2.8.8. Medidas Organizativas Generales:](#2-8-8-medidas-organizativas-generales)
  * [Implementación del CPD en la nube AWS con los servicios utilizados. Iker](#implementacion-del-cpd-en-la-nube-aws-con-los-servicios-utilizados-iker)
  * [2.10. Implementación de CPD a la nube AWS con los servicios utilizados](#2-10-implementacion-de-cpd-a-la-nube-aws-con-los-servicios-utilizados)
  * [3. Ansible - Creació de servidors (Logs | LDAP) .Iker](#3-ansible---creacio-de-servidors-logs--ldap-iker)
  * [4. Implantació dels serveis d'àudio i vídeo (Ivan)](#4-implantacio-dels-serveis-d-audio-i-video-ivan)
  * [5. Servidor MySQL (xavi-piero)](#5-servidor-mysql-xavi-piero)
    * [5.1 BBDDs](#5-1-bbdds)
    * [5.2 Script bash - Gestió d’usuaris:](#5-2-script-bash---gestio-d-usuaris)
      * [codi (link github)](#codi-link-github)
    * [5.3 Creación de la base de datos de la Web: (piero)](#5-3-creacion-de-la-base-de-datos-de-la-web-piero)
    * [5.3 Triggers y eventos periódicos:](#5-3-triggers-y-eventos-periodicos)
  * [6. Servidor Web - SFTP (xavi)](#6-servidor-web---sftp-xavi)
    * [6.1 Nginx:](#6-1-nginx)
      * [6.1.1. Creación de certificados SSL:](#6-1-1-creacion-de-certificados-ssl)
      * [6.1.2. Configuración de la Página:](#6-1-2-configuracion-de-la-pagina)
      * [6.1.3. Configuración PHP](#6-1-3-configuracion-php)
    * [6.2 SFTP](#6-2-sftp)
      * [6.2.1 Configuración del servicio:](#6-2-1-configuracion-del-servicio)
      * [6.2.2. Creación de usuarios:](#6-2-2-creacion-de-usuarios)
      * [6.2.3. Pruebas:](#6-2-3-pruebas)

---

<div align="justify">

 GRUPO 3 PROYECTO TRANSVERSAL ASIXc1D

* Plano general de las instalaciones INNOCATETECH:

El CPD se ubica en la planta baja, en una zona central. El núcleo del CPD está completamente cerrado por una estructura acristalada técnica de alta resistencia en este proyecto utilizamos vidrio laminado de seguridad con tratamiento acústico y térmico. 

Esta cristalera permite:

* Aislamiento Térmico: Mantiene el aire frío dentro de la zona de racks, separándolo del resto del edificio.

* Supervisión Visual: Permite observar el estado de los equipos (LEDs de estado, orden) desde el exterior sin necesidad de entrar y alterar la temperatura de la sala.

* Discreción y Estética: El cristal puede ser electrocromático (se vuelve opaco con un interruptor) para ocultar la sala durante visitas no autorizadas, manteniendo la máxima discreción.

</div>

<a name="1-1-plano-sala-del-rack"></a>
### 1.1. Plano sala del rack:
[↑ Volver al índice](#indice)

<div align='justify'>

Hemos optado por una arquitectura de cinco servidores físicos distribuidos en cuatro racks para maximizar la seguridad y el rendimiento. Este esquema no solo asegura el aislamiento de procesos críticos, sino que facilita un crecimiento vertical y ágil ante el posible incremento de las futuras demandas.

Hemos asignado cada servidor a una función específica para garantizar la independencia de procesos:

* Rack 1: Servicio Web y SFTP (Secure File Transfer Protocol) Este servidor centraliza el acceso externo de la empresa. Por un lado, gestiona el portal corporativo y las interfaces de usuario de las plataformas digitales, optimizado para un alto tráfico de peticiones HTTP/HTTPS. Por otro lado, aloja el servicio SFTP para el intercambio seguro, robusto y cifrado de archivos con clientes y proveedores.
* Rack 2: Centralización de Logs (SIEM / Logging) Encargado de recibir y almacenar todos los registros de eventos (logs) de la red y el hardware. Es un nodo crítico para la auditoría de seguridad, el cumplimiento normativo y la detección de anomalías en tiempo real.
* Rack 3: Active Directory (AD) Dedicado exclusivamente a la gestión de la infraestructura de identidad de la empresa. Controla la autenticación de usuarios, las directivas de grupo (GPOs) y la asignación de permisos centralizados de forma segura.
* Rack 4: Procesamiento de Audio y Vídeo Servidor independiente dedicado a las capacidades de procesamiento, transcodificación y distribución para las plataformas de streaming de audio y contenido de vídeo de InnovateTech. Al estar separado del Active Directory, se garantiza que el alto consumo de ancho de banda y CPU no afecte la autenticación de la empresa.
* Rack 5: Base de Datos (DB Server) El motor de datos neurálgico de la organización. Está configurado con discos NVMe de ultra alta velocidad y redundancia para minimizar los tiempos de respuesta de las consultas y garantizar la alta disponibilidad de la información.

</div>

<a name="1-1-1-estructuracion-de-los-racks"></a>
### 1.1.1. Estructuración de los Racks:
[↑ Volver al índice](#indice)

<div align='justify'>

Para garantizar la alta disponibilidad, la eficiencia en el cableado y el mantenimiento ágil, cada uno de los 5 racks independientes se estructurará internamente utilizando armarios de 42U de altura, 800 mm de ancho y 1100 mm de profundidad (permitiendo espacio lateral para la gestión de cableado vertical).

Todos los racks seguirán un estándar de distribución homogéneo basado en la arquitectura Top of Rack (ToR) para datos y Bottom of Rack (BoR) para energía.

</div>

<a name="1-1-2-componentes-tecnicos-comunes-por-rack"></a>
#### 1.1.2. Componentes Técnicos Comunes por Rack:
[↑ Volver al índice](#indice)

<div align='justify'>

A excepción de los servidores específicos, cada rack contará con los siguientes elementos de infraestructura interna:

* Sistema de Alimentación Ininterrumpida (SAI/UPS) en Rack: Este sistema se ubicará en la base del rack, específicamente de la unidad U1 a la U3, con el objetivo de mantener el centro de gravedad lo más bajo posible por motivos de estabilidad. Se implementará un SAI de tecnología Online de Doble Conversión con una capacidad de 3000VA (3kVA) / 2700W en un formato rackeable de 2U o 3U, el cual incorporará una tarjeta de red SNMP para la monitorización remota del estado de las baterías y los consumos eléctricos. En cuanto a la redundancia, el equipo estará configurado para alimentar de forma continua la línea "A" de los servidores, mientras que la línea "B" se conectará a un bypass estático de la red general del CPD o a un segundo SAI centralizado según disponibilidad presupuestaria.

* Unidades de Distribución de Energía (PDU) Inteligentes: Para la distribución eléctrica interna se instalarán dos PDU conmutadas e inteligentes con un factor de forma Zero-U, lo que permite fijarlas verticalmente en la parte posterior del chasis del rack sin ocupar espacio de unidades útiles frontales. Estas unidades contarán con conexiones de entrada tipo IEC 320 C20 y salidas bloqueables para evitar desconexiones accidentales, distribuidas en puertos tipo IEC C13 y C19, ofreciendo además la capacidad de realizar el encendido o apagado remoto de enchufes individuales y la medición de corriente en tiempo real por cada puerto.

* Paneles de Parcheo (Patch Panels): La gestión del cableado estructurado se centralizará en la parte superior del rack, ocupando las unidades U41 y U42. Por un lado, se dispondrá de un patch panel de cobre de 1U con 24 puertos RJ-45 Categoría 6A FTP apantallado, diseñado con tecnología Keystone angular para facilitar la caída natural y fluida del cable hacia los organizadores verticales. Por otro lado, se integrará un patch panel de fibra óptica (FOBOT) de 1U equipado con un cassette deslizante para albergar hasta 24 acopladores LC-Duplex Monomodo o Multimodo (OM4), el cual estará destinado exclusivamente a gestionar los enlaces de alta velocidad o uplinks hacia el Switch Core del CPD.
* Electrónica de Red (Switch ToR): La conectividad de red local se resolverá mediante la arquitectura Top of Rack (ToR) situando el switch en la unidad U40, justo debajo de los paneles de parcheo para minimizar la longitud de los latiguillos. Se utilizará un switch gestionable con capacidades de Capa 2 y Capa 3 (L2/L3) que dispondrá de 24 puertos nativos de 1GbE/10GbE Base-T para la conexión de los servidores del rack, complementado con 4 puertos SFP+ de alta velocidad de 10Gbps/25Gbps para asegurar los uplinks hacia el núcleo de la infraestructura de red.

* Gestión de Cableado y Accesorios: Para garantizar un flujo de aire óptimo y un mantenimiento limpio, se instalarán dos organizadores de cable horizontales de 1U con pasacables de escobilla situados estratégicamente entre el switch y los patch panels. Adicionalmente, cada rack incluirá una bandeja fija ventilada de 1U para dar soporte a herramientas o dispositivos que no dispongan de un formato nativo rackeable, así como un kit de monitorización ambiental compuesto por sondas de temperatura y humedad conectadas directamente a la PDU o al SAI para alertar sobre cualquier anomalía térmica interna.

</div>

<a name="1-2-sistema-de-climatizacion-del-cpd"></a>
### 1.2. Sistema de climatización del CPD:
[↑ Volver al índice](#indice)

<div align='justify'>

En un CPD convencional abierto, el aire frío se mezcla rápidamente con el aire caliente ambiental, obligando a las unidades de aire acondicionado a trabajar a máxima potencia en la mayoría de casos. Por eso nosotros hemos optado por las cristaleras ya que estas rompen este ciclo creando un recinto estanco:

* Efecto Estanco: Al estar sellado, el aire frío inyectado por las unidades de precisión (CRAC) no se mezcla con el aire caliente de la oficina. Esto permite que los servidores trabajen a una temperatura constante de 21°C con un consumo eléctrico mínimo.

* Control de Presión Positiva: El sistema inyecta más aire del que extrae, creando una presión superior dentro del cristal. Al abrir la puerta, el aire sale hacia afuera, impidiendo físicamente la entrada de polvo o partículas que podrían dañar los componentes internos de los servidores.

* Humedad Controlada: Se mantiene entre el 45% y 50% para evitar fallos por electricidad estática o corrosión.

</div>

<p align="center">
  <img src="images/img_1.png" alt="Imagen 1" />
</p>



<a name="1-3-medidas-para-dificultar-la-identificacion-de-la-sala"></a>
### 1.3. Medidas para dificultar la identificación de la sala:
[↑ Volver al índice](#indice)

<div align='justify'>

Para proteger la infraestructura crítica de InnovateTech, es fundamental aplicar el principio de seguridad por oscuridad. El objetivo es que el CPD pase desapercibido para cualquier persona ajena al departamento de IT, minimizando el riesgo de sabotaje o ataques dirigidos.

</div>

<a name="1-3-1-sealizacion-restrictiva"></a>
#### 1.3.1. Señalización Restrictiva:
[↑ Volver al índice](#indice)

<div align='justify'>

Por precaución a cualquier tipo de incidente ajeno a nuestro departamento de IT, nunca deberemos de usar carteles que digan "CPD", "Data Center" o "Servidores", con el  objetivo de conseguir discreción y que pase desapercibido por usuarios externos.

La placa de la puerta, señalizará solamente con un cartel que diga: 

"PROHIBIDO EL PASO A PERSONAS NO AUTORIZADAS".

</div>

<p align="center">
  <img src="images/img_2.png" alt="Imagen 2" />
</p>

<div align="justify">
Como normal general en los planos públicos o de evacuación de la empresa, la sala se identificará únicamente como "Zona Técnica" o "Localización de Riesgo Especial", sin especificar su contenido crítico.

</div>

<a name="1-3-2-seguridad-de-rutas-y-suministros"></a>
#### 1.3.2. Seguridad de Rutas y Suministros:
[↑ Volver al índice](#indice)

<div align='justify'>

Las bandejas de cables y tuberías de refrigeración transcurrirá siempre por falsos techos cerrados, nunca de forma vista en pasillos comunes.

En el directorio del edificio o del ascensor, no figurará ninguna referencia a la ubicación de la infraestructura tecnológica.

</div>

<a name="1-3-3-camuflaje-arquitectonico-y-estetico"></a>
#### 1.3.3. Camuflaje Arquitectónico y Estético:
[↑ Volver al índice](#indice)

<div align='justify'>

Dado que el CPD se ha diseñado como una sala acristalada, se implementará un sistema de vidrio electrocrómico inteligente, el cual permite que el cristal se vuelva opaco (en tono blanco o negro) mediante un interruptor. Esta tecnología garantiza que, ante la presencia de personal externo, la sala se perciba simplemente como una pared decorativa o una sala de juntas vacía.

Para reforzar esta discreción, la perfilería de la cristalera será idéntica a la utilizada en el resto de las oficinas, evitando que destaque como un elemento de alta seguridad. Asimismo, el CPD se ubica estratégicamente en el núcleo del edificio, eliminando cualquier ventana al exterior para prevenir la visibilidad desde la calle o la exposición ante drones y fotografía externa.

</div>

<p align="center">
  <img src="images/img_3.png" alt="Imagen 3" />
</p>



<a name="1-4-distribucion-y-gestion-del-cableado"></a>
### 1.4. distribución y gestión del cableado:
[↑ Volver al índice](#indice)

<div align='justify'>

Para la distribución y gestión del cableado en el CPD de InnovateTech, seguiremos un modelo de alta eficiencia basado en la normativa ANSI/TIA-942, asegurando que el despliegue sea escalable, ordenado y no interfiera con el sistema de climatización de la zona acristalada.

La gestión se dividirá en dos niveles físicos totalmente segregados para evitar interferencias electromagnéticas (EMI) y facilitar el mantenimiento de los 5 servidores:

- Cableado de Energía (Bajo Suelo):

* Toda la alimentación eléctrica (procedente del SAI y el cuadro eléctrico) discurrirán por el suelo técnico.
* Se utilizarán bandejas de acero tipo rejilla situadas a una altura diferente de las canalizaciones de aire frío para no obstruir el flujo.
* Cada rack contará con dos unidades de distribución de energía (PDU) inteligentes para ofrecer redundancia a los servidores.

- Cableado de Datos (Aéreo):

* Las conexiones de fibra óptica y cobre (Categoría 6A) se distribuirán mediante bandejas aéreas ancladas a la parte superior de los racks o suspendidas del techo técnico.
* Este despliegue aéreo permite una rápida identificación de los puertos y evita que el cableado de datos acumule calor en la zona inferior.
* Se utilizará un código de colores estricto (ej. Azul para datos, Rojo para gestión/logs, Amarillo para fibra) para minimizar errores humanos durante las intervenciones.

- Gestión Interna en el Rack:

* Organizadores Verticales y Horizontales: Se instalarán guías en los laterales de cada uno de los 4 racks para peinar el cableado. Esto evita las "madejas" de cables que bloquean la salida de aire caliente de los servidores.
* Latiguillos a Medida: Se emplearán cables de la longitud exacta para evitar excedentes enrollados que perjudiquen la estética y la ventilación.
* Etiquetado Industrial: Cada extremo de cada cable estará identificado con etiquetas permanentes que indiquen origen, destino y servicio (ej. SRV-WEB-01 to SW-CORE-01).

</div>

<a name="1-5-terra-tecnic-suelo-tecnico-elevado"></a>
### 1.5. Terra Tècnic (Suelo Técnico Elevado):
[↑ Volver al índice](#indice)

<div align='justify'>

Se instalará un sistema de pavimento elevado a 50 cm de altura respecto al suelo real del edificio.

* La estructura estará formada por baldosas de 60x60 cm con núcleo de sulfato de calcio de alta densidad y acabado superior en vinilo antiestático. Se apoya sobre pedestales regulables de acero galvanizado unidos por travesaños para garantizar la estabilidad de los 4 racks.
* Su función térmica dentro del espacio vacío inferior (plénum) actúa como canal de impulsión del aire frío proveniente de la unidad CRAC. El aire sale exclusivamente a través de baldosas perforadas estratégicamente situadas frente a la entrada de los servidores.
* Para la gestión de Energía, a este nivel se utilizará para canalizar el cableado eléctrico y las tomas de tierra, manteniéndolos ocultos y separados de los datos.

</div>

<a name="1-5-1-sostre-tecnic-falso-techo-registrable"></a>
#### 1.5.1. Sostre Tècnic (Falso Techo Registrable):
[↑ Volver al índice](#indice)

<div align='justify'>

El techo se situará a una altura libre de 2,80 metros.

* Material: Placas de fibra mineral acústica con alta resistencia al fuego y propiedades de absorción sonora, necesarias para mitigar el ruido de los ventiladores.
* Retorno de Aire: El espacio superior se utiliza como plénum de retorno para el aire caliente que expulsan los servidores. Mediante rejillas de extracción, el aire caliente vuelve a la unidad CRAC para ser enfriado nuevamente.
* Seguridad y Sensores: En el sostre tècnic se integrarán:
* El sistema de detección de incendios por aspiración (VESDA).
* Las boquillas de descarga del gas extintor FM-200.
* Los sensores de temperatura y humedad conectados al sistema de monitorización.

</div>

<a name="1-5-2-estanqueidad-con-la-cristalera"></a>
#### 1.5.2. Estanqueidad con la Cristalera:
[↑ Volver al índice](#indice)

<div align='justify'>

Un punto crítico de este diseño es que tanto el suelo como el techo técnico estarán sellados herméticamente en sus perímetros contra la cristalera. Esto asegura que la presión positiva y el efecto estanco se mantengan dentro de la zona de racks, evitando fugas de aire hacia el resto de la oficina.

</div>

<a name="2-infraestructura-electrica"></a>
## 2.	Infraestructura elèctrica:
[↑ Volver al índice](#indice)

<div align='justify'>

La infraestructura eléctrica del CPD estará diseñada para garantizar la continuidad del servicio incluso ante fallos eléctricos, evitando pérdidas de datos y caídas de servicios críticos. Para ello, implementaremos una arquitectura eléctrica redundante y segura que permita mantener los servidores y sistemas de red operativos en todo momento.

</div>

<a name="2-1-sistemas-de-alimentacion-redundante"></a>
### 2.1 Sistemas de alimentación redundante:
[↑ Volver al índice](#indice)

<div align='justify'>

Todos los racks dispondrán de alimentación redundante mediante dos líneas eléctricas independientes conectadas a diferentes PDUs (Power Distribution Units). Esto permitirá que, en caso de fallo de una línea eléctrica, los equipos continúen funcionando utilizando la línea secundaria sin interrupción del servicio.

Los servidores críticos contarán con fuentes de alimentación redundantes conectadas a PDUs separadas, reduciendo así el riesgo de caída total de un sistema por fallo eléctrico.

Además, la instalación dispondrá de:

* Cuadros eléctricos independientes para climatización y servidores.
* Protección mediante magnetotérmicos y diferenciales.
* Sistema de puesta a tierra reglamentario.
* Protección frente a sobretensiones y picos eléctricos.

</div>

<a name="2-2-sistema-sai--ups"></a>
### 2.2. Sistema SAI / UPS:
[↑ Volver al índice](#indice)

<div align='justify'>

Para proteger la infraestructura frente a cortes eléctricos, instalaremos un sistema de alimentación ininterrumpida (SAI/UPS) online de doble conversión. Este sistema permitirá mantener operativos los servicios críticos durante un tiempo determinado mientras se restablece el suministro eléctrico o se realiza un apagado controlado de los servidores.

El SAI protegerá frente a cortes de corriente, microcortes eléctricos, variaciones de tensión, picos eléctricos, fluctuaciones de frecuencia.

</div>

<a name="2-3-consumo-electrico-estimado"></a>
### 2.3. Consumo eléctrico estimado:
[↑ Volver al índice](#indice)

<div align='justify'>

Hemos realizado una estimación aproximada del consumo energético total de la infraestructura IT teniendo en cuenta los equipos instalados dentro del CPD.

</div>

| EQUIPAMIENTO  | CONSUMO APROXIMADO |
| --- | --- |
| 5 servidores físicos | 2500 W |
| 4 switches gestionables | 400 W |
| Router / modem | 50 W |
| Sistema NAS / Backups | 300 W |
| Climatización auxiliar | 500 W |
| Total estimado | 3750 W |

<div align='justify'>

Teniendo en cuenta este consumo, proponemos la utilización de un SAI de aproximadamente 5000 VA, proporcionando autonomía suficiente para mantener la infraestructura operativa entre 20 y 30 minutos.

Este tiempo nos permitirá mantener los servicios activos temporalmente, evitar pérdidas de información, realizar backups o apagados controlados, también nos permitirá proteger la integridad de la base de datos y sistemas que sean críticos.

Hemos calculado los valores de consumo de forma aproximada utilizando consumos medios habituales de servidores rack empresariales, electrónica de red y sistemas auxiliares del CPD, añadiendo además un margen de seguridad para soportar posibles picos de carga y futuras ampliaciones de la infraestructura.

</div>

<a name="2-4-distribucion-electrica-en-racks"></a>
### 2.4. Distribución eléctrica en racks:
[↑ Volver al índice](#indice)

<div align='justify'>

Cada rack dispondrá de:

* Dos unidades de distribución de energía (PDU) inteligentes para garantizar redundancia eléctrica.
* Cableado eléctrico separado del cableado de datos.
* Organización vertical del cableado
* Etiquetado de conexiones eléctricas
* Tomas protegidas frente a sobretensiones

La distribución eléctrica seguirá el modelo descrito en la gestión de cableado del CPD, utilizando canalizaciones bajo suelo técnico para la alimentación eléctrica y evitando interferencias electromagnéticas con el cableado de datos.

Además, la organización interna de los racks contará con guías verticales y horizontales para mantener el cableado ordenado y evitar obstrucciones en el flujo de aire generado por el sistema de climatización.

</div>

<a name="2-5-eficiencia-energetica"></a>
### 2.5. Eficiencia energética:
[↑ Volver al índice](#indice)

<div align='justify'>

Con el objetivo de reducir el impacto medioambiental y optimizar el consumo eléctrico, el CPD implementará medidas de eficiencia energética:

* Uso de servidores virtualizados para reducir el hardware físico.
* Equipos con certificación energética eficiente.
* Optimización del sistema de climatización para mantener una temperatura estable con el mejor consumo posible.
* Monitorización del consumo energético
* Apagado automático de equipos no críticos fuera de horario

Estas medidas nos permitirán reducir el consumo eléctrico total del CPD y mejorar la sostenibilidad de la infraestructura tecnológica.

</div>

<a name="2-6-seguridad-fisica"></a>
### 2.6. Seguridad Física
[↑ Volver al índice](#indice)

<div align='justify'>

Para la parte de la seguridad física, hemos implementado las siguientes medidas:

</div>

<a name="2-6-1-medidas-pasivas"></a>
#### 2.6.1. Medidas Pasivas:
[↑ Volver al índice](#indice)

<div align='justify'>

* Traslado de nuestros servidores a una ubicación segura, alejada de zonas de riesgo, donde solo tiene acceso el personal autorizado (los administradores).
* Control ambiental de la temperatura y humedad de la sala.
* La sala está ubicada en una segunda planta, donde la información a nivel físico estará protegida de robos o vandalismo.

</div>

<a name="2-6-2-medidas-activas"></a>
#### 2.6.2. Medidas activas:
[↑ Volver al índice](#indice)

<div align='justify'>

* Para garantizar que no pueda acceder cualquiera, hemos implementado un control de acceso con tarjetas de proximidad.
* Además, contamos con cámaras de videovigilancia que monitorean el perímetro las 24 horas del día.

</div>

<a name="2-7-seguridad-logica"></a>
### 2.7. Seguridad lógica
[↑ Volver al índice](#indice)



<a name="2-7-1-seguridad-logica-pasiva"></a>
#### 2.7.1. Seguridad Lógica Pasiva:
[↑ Volver al índice](#indice)

<div align='justify'>

* Una de las medidas preventivas realizadas a nivel de equipos es el cifrado de datos con herramientas avanzadas para lograr una mayor seguridad en nuestros sistemas.
* Implementamos la verificación de usuarios mediante contraseñas y autenticación en dos pasos, ayudándonos a verificar de manera eficiente que los empleados se identifican correctamente.
* Para la división de permisos y evitar que todos tengan acceso a la misma información, hemos agregado roles y permisos según el cargo del personal.
* Esto ayudará a que solo las personas autorizadas puedan acceder a información específica, evitando mezclas entre departamentos.

</div>

<a name="2-7-2-seguridad-logica-activa"></a>
#### 2.7.2. Seguridad Lógica Activa:
[↑ Volver al índice](#indice)

<div align='justify'>

* Para evitar visitas no autorizadas del exterior, hemos añadido un sistema de detección de intrusos que bloqueará ataques que puedan afectar a nuestro funcionamiento.
* También implementamos antivirus y antimalware, algunos de los cuales serán Bitdefender, GravityZone o Business Security.
* Contaremos con una empresa externa contratada que se encargará de monitorear y auditar las actividades de los dispositivos de la empresa en busca de vulnerabilidades o para localizar anomalías dentro de los sistemas.

</div>

<a name="2-8-prevencion-de-riesgos-laborales"></a>
## 2.8. Prevención de riesgos laborales:
[↑ Volver al índice](#indice)



<a name="2-8-1-riesgos-electricos"></a>
#### 2.8.1. Riesgos Eléctricos:
[↑ Volver al índice](#indice)

<div align='justify'>

* Instalación con toma de tierra reglamentaria.
* Protecciones diferenciales y magnetotérmicas en todos los cuadros eléctricos.
* Señalización de peligro eléctrico (riesgo de electrocución) en armarios y racks.
* Prohibición de acceder a los cuadros eléctricos sin los EPI adecuados (guantes aislantes).
* Procedimiento de bloqueo y etiquetado LOTO antes de realizar tareas de mantenimiento.

</div>

<a name="2-8-2-riesgos-ergonomicos"></a>
#### 2.8.2. Riesgos Ergonómicos:
[↑ Volver al índice](#indice)

<div align='justify'>

* Altura regulable de los racks para evitar posturas forzadas.
* Uso de soportes para manipular equipos pesados (servidores, SAI/UPS).
* Formación en manipulación manual de cargas (RD 487/1997).
* Iluminación adecuada en los pasillos fríos/calientes para reducir la fatiga visual.

</div>

<a name="2-8-3-riesgos-por-ruido"></a>
#### 2.8.3. Riesgos por Ruido:
[↑ Volver al índice](#indice)

<div align='justify'>

* Medición del nivel de ruido de los sistemas de refrigeración (límite: 85 dB).
* Protección auditiva obligatoria si la permanencia es prolongada.
* Limitación del tiempo de exposición sin EPI.

</div>

<a name="2-8-4-riesgos-termicos"></a>
#### 2.8.4. Riesgos Térmicos:
[↑ Volver al índice](#indice)

<div align='justify'>

* Control de temperatura entre 18°C y 27°C (recomendación ASHRAE).
* Señalización de zonas de frío intenso (cold aisle / pasillo frío).
* Ropa adecuada para el personal que trabaja en zonas de climatización forzada.

</div>

<a name="2-8-5-riesgos-de-incendio"></a>
#### 2.8.5. Riesgos de Incendio:
[↑ Volver al índice](#indice)

<div align='justify'>

* Sistemas de detección precoz de humo (VESDA o similar).
* Extinción automática con gas inerte (FM-200 o Novec 1230); no se debe usar agua ni CO₂ en la zona de servidores.
* Vías de evacuación señalizadas y libres de obstáculos (RD 485/1997).
* Puertas cortafuegos RF-120 en los accesos.
* Simulacros periódicos de evacuación.

</div>

<a name="2-8-6-riesgos-de-caidas"></a>
#### 2.8.6. Riesgos de Caídas:
[↑ Volver al índice](#indice)

<div align='justify'>

* Suelo técnico con superficie antideslizante.
* Tapas del suelo técnico correctamente fijadas cuando no se estén realizando trabajos.
* Señalización de desniveles u obstáculos.
* Iluminación de emergencia autónoma en todos los pasillos.

</div>

<a name="2-8-7-riesgos-por-radiaciones-electromagneticas"></a>
#### 2.8.7. Riesgos por Radiaciones Electromagnéticas:
[↑ Volver al índice](#indice)

<div align='justify'>

* Distancia de seguridad a los equipos de gran emisión (antenas, switches de gran potencia).
* Evaluación periódica de los niveles de exposición.

</div>

<a name="2-8-8-medidas-organizativas-generales"></a>
#### 2.8.8. Medidas Organizativas Generales:
[↑ Volver al índice](#indice)

<div align='justify'>

* Acceso restringido: solo personal autorizado con formación en PRL.
* Registro de entrada/salida del personal al CPD.
* Procedimientos escritos para todas las tareas de mantenimiento.
* Equipos de trabajo en parejas (nunca trabajar solo en el CPD).
* Plan de emergencia y teléfonos de emergencia visibles.

</div>

<a name="implementacion-del-cpd-en-la-nube-aws-con-los-servicios-utilizados-iker"></a>
## Implementación del CPD en la nube AWS con los servicios utilizados. Iker
[↑ Volver al índice](#indice)

<div align='justify'>

(mínimo de 4 - los servicios de audio, vídeo y bases de datos se valoran en los otros bloques). ○ Los servicios a montar (no se pueden utilizar AMIs del marketplace con software instalado) son: 

* Servicio web 
* Servicio de transferencia de ficheros seguro (sftp). Se autenticará con los usuarios de directorio activo. 
* Servicio de centralización de logs que recoja los logs de todos los equipos. 
* Servicio de directorio activo para guardar los usuarios. 
* Cada servicio deberá estar instalado en un servidor diferente (a excepción del servicio web y sftp). ○ Dos de las máquinas (como mínimo) deben estar configuradas con Ansible (incluyendo toda la configuración realizada en el servidor). ○ Las máquinas se deben administrar con un usuario específico (no se podrá utilizar el usuario por defecto del servidor) y el acceso se realizará con clave pública/privada (sin utilizar contraseña).

* Servidor Web y servidor SFTP juntos. 

* Dos maquinas configuradas en Ansible 

* Cada maquina tiene un usario admin.

* Acceso con llave privada/publica (no contraseña)

Implementació al núvol AWS (5 p)

○ Web/sftp (1p)

○ LDAP (0,5p)

○ Logs centralitzats (1,5p)

○ Ansible (1,5p)

○ Usuaris administració (0,5p)

</div>

<a name="2-10-implementacion-de-cpd-a-la-nube-aws-con-los-servicios-utilizados"></a>
## 2.10. Implementación de CPD a la nube AWS con los servicios utilizados
[↑ Volver al índice](#indice)

<div align='justify'>

Primero de todo, lanzaremos la primera instancia, que será el servidor Web-SFTP, y desde ahí mismo lanzaremos las otras dos instancias, que serán el servidor Directorio Activo (LDAP) y el servidor de logs.

</div>

<p align="center">
  <img src="images/img_4.png" alt="Imagen 4" />
</p>

<div align="justify">
Creamos un grupo de seguridad para el servidor Web-SFTP, como es un servidor que solo necesita los puertos 22, 443 y 80 únicamente. Los configuramos y añadimos a nuestra instancia:

</div>

| Servidor | Servicios | IP Pública | IP Privada |
| --- | --- | --- | --- |
| Servidor-Web | Nginx, SFTP | 54.197.85.133 | 172.31.26.247/20 |
| Servidor audio, video i videollamada | Icecast (audio-video), jitsi-meet (video-videollamada). | 34.202.38.124 | 172.31.22.20/20 |
| Servidor-Logs | Elastic, Kibana, AuditBeat | 34.229.219.83 | 172.31.29.157/20 |
| Servidor-Directori Actiu | LDAP | 44.223.1.104 | 172.31.22.126/20 |
| Servidor BD | Mysql | 34.226.127.76 | 172.31.30.119/20  |
| Repositorio github: https://github.com/ITB2526-PieroYcaza/ProyectoTransversal-Grupo3.git |  |  |  |



<a name="3-ansible---creacio-de-servidors-logs--ldap-iker"></a>
## 3. Ansible - Creació de servidors (Logs | LDAP) .Iker
[↑ Volver al índice](#indice)

<div align='justify'>

Entramos sin necesidad de contraseña a nuestro usuario que usaremos para el servidor Web-SFTP.

</div>

<p align="center">
  <img src="images/img_5.png" alt="Imagen 5" />
</p>

<div align="justify">
Ahora guardamos temporalmente las credenciales de AWS para que Ansible pueda crear las máquinas, necesita mis claves temporales que se tendran que ir renovando.

</div>

<p align="center">
  <img src="images/img_6.png" alt="Imagen 6" />
</p>

<div align="justify">
Playbook para crear los servidores de log y Directorio Activo:

</div>

<p align="center">
  <img src="images/img_7.png" alt="Imagen 7" />
</p>

<div align="justify">
Lanzamos el playbook de Ansible y creamos los dos servidores automatizados.

</div>

<p align="center">
  <img src="images/img_8.png" alt="Imagen 8" />
</p>

<div align="justify">
Ahora configuramos los servidores de logs y directorio activo mediante Ansible. 

Primero de todo, desde mi servidor web, dentro del fichero .ssh, creamos un fichero llamado ServidorWeb.pem, que dentro irá la llave de la clave .pem original que uso para conectarme a mi servidor. Así podemos entrar a configurar a los otros servidores sin necesidad de contraseña. Le damos también los permisos adecuados. 

</div>

<p align="center">
  <img src="images/img_9.png" alt="Imagen 9" />
</p>



<p align="center">
  <img src="images/img_10.png" alt="Imagen 10" />
</p>

<div align="justify">
El siguiente paso es crear un fichero en donde irán las IPs privadas de los dos servidores que configuraremos vía Ansible:

</div>

<p align="center">
  <img src="images/img_11.png" alt="Imagen 11" />
</p>

<div align="justify">
Luego, en el segundo fichero, indicamos cómo se comporta el Ansible, la primera linea host_key_checking = False. Como al conectarnos por ssh por primera vez nos pide si queremos conectarnos, al poner “false” hacemos que ansible entre sin preguntar nada, evitando que se quede esperando en la terminal a que escribamos “yes”.

Con el inventario = inventory: Le indicamos al Ansible que busque las IPs de los servidores en el archivo llamado inventory que creamos antes. 

</div>

<p align="center">
  <img src="images/img_12.png" alt="Imagen 12" />
</p>

<div align="justify">
Comprobamos si se puede acceder por ping, que se conecta por SSH, asegurándonos de que podamos controlar los otros dos servidores. Los servidores nos devuelven el mensaje “ping”: “pong”. 

</div>

<p align="center">
  <img src="images/img_13.png" alt="Imagen 13" />
</p>

<div align="justify">
Ahora reescribimos el fichero inventory para indicarle más precisamente las máquinas en donde Ansible instalará los servicios correspondientes. 

Creamos grupos separados para cada máquina [directorio_activo] y [servidor_logs] para que Ansible sepa dónde instalar cada servicio. Luego creamos otro grupo [remoto:children] que engloba los grupos anteriores para cuando tengamos que hacer algo igual en las dos máquinas, lo metemos dentro de ese grupo. Y por último, en [remotos:var] le definimos el usuario que tienen las máquinas ahora mismo, que es Ubuntu, y la clave privada (ServidorWeb.pem).

</div>

<p align="center">
  <img src="images/img_14.png" alt="Imagen 14" />
</p>



<p align="center">
  <img src="images/img_15.png" alt="Imagen 15" />
</p>



<p align="center">
  <img src="images/img_16.png" alt="Imagen 16" />
</p>

<div align="justify">
ghp_MOCK_TOKEN_REMOVED_BY_SAFETY_SCRIPT

</div>

<a name="4-implantacio-dels-serveis-d-audio-i-video-ivan"></a>
## 4. Implantació dels serveis d'àudio i vídeo (Ivan)
[↑ Volver al índice](#indice)



<a name="5-servidor-mysql-xavi-piero"></a>
## 5. Servidor MySQL (xavi-piero)
[↑ Volver al índice](#indice)



<a name="5-1-bbdds"></a>
### 5.1 BBDDs
[↑ Volver al índice](#indice)

<div align='justify'>

* InnovateTech: Cubrirá todas las necesidades de la página web (usuarios, productos, servicios, etc).
* LDAP: Base de datos conectada al servicio LDAP del servidor respectivo. Almacena los usuarios de la empresa e información sobre estos.
* ICECAST: Base de datos conectada al servidor ICECAST de audio y video, almacenando todos los datos necesarios para el funcionamiento del servicio.
* Audit: Base de datos conectada al servidor Elastic. Este almacenará todos los logs registrados por el servidor de logs.

</div>

<a name="5-2-script-bash---gestio-d-usuaris"></a>
### 5.2 Script bash - Gestió d’usuaris:
[↑ Volver al índice](#indice)

<div align='justify'>

Es un script automatizado para crear, modificar y eliminar usuarios de MySQL:

</div>

<a name="codi-link-github"></a>
#### codi (link github)
[↑ Volver al índice](#indice)

<div align='justify'>

Prueba del funcionamiento + creación de usuario admin 

</div>

<p align="center">
  <img src="images/img_17.png" alt="Imagen 17" />
</p>



<a name="5-3-creacion-de-la-base-de-datos-de-la-web-piero"></a>
### 5.3 Creación de la base de datos de la Web: (piero)
[↑ Volver al índice](#indice)

<div align='justify'>

Para dar soporte a los servicios de InnovateTech (gestión de personal, streaming de audio y vídeo, videollamadas y mediciones de ancho de banda), se implementa una base de datos relacional sobre un servidor EC2 dedicado con MySQL.

La base de datos innovatetech_db está compuesta por 9 tablas: departamentos, empleados, grupos_calidad, usuarios_sistema, llamadas, videos, mediciones_ancho_banda, avisos_auditoria y control_backups. Sobre estas tablas se implementan triggers de seguridad y auditoría, y un evento periódico de backup automático.

La implementación se divide en dos fases: primero la creación de la estructura, y después la aplicación de la lógica de control de acceso mediante triggers y eventos.

* Dentro del servidor con el servicio MySQL se crea un directorio que almacenará el fichero Innovatetech_DB.sql.

</div>

<p align="center">
  <img src="images/img_18.png" alt="Imagen 18" />
</p>

<div align="justify">
* Dentro del directorio se crea el nano del fichero de la base de datos, el contenido del fichero se encuentra en el git del proyecto.

</div>

<p align="center">
  <img src="images/img_19.png" alt="Imagen 19" />
</p>

<div align="justify">
* Posteriormente, ejecutamos el comando que permitirá ejecutar el fichero y crear la base de datos.

</div>

<p align="center">
  <img src="images/img_20.png" alt="Imagen 20" />
</p>

<div align="justify">
* Verificamos haciendo un SHOW TABLES.

</div>

<p align="center">
  <img src="images/img_21.png" alt="Imagen 21" />
</p>

<div align="justify">
* Por último se reinicia el servicio

</div>

<p align="center">
  <img src="images/img_22.png" alt="Imagen 22" />
</p>



<a name="5-3-triggers-y-eventos-periodicos"></a>
### 5.3 Triggers y eventos periódicos:
[↑ Volver al índice](#indice)

<div align='justify'>

Una vez creada la estructura de la base de datos, se implementa la lógica de seguridad y automatización mediante triggers y un evento periódico.

Los triggers cubren tres áreas: el control de cuotas de llamadas (límite de minutos mensuales y llamadas diarias por usuario), el bloqueo de usuarios en estado bloqueado para que no puedan realizar ni recibir llamadas, y la auditoría de accesos no autorizados, registrando en la tabla avisos_auditoria cualquier intento de modificar tablas restringidas según el rol del usuario de base de datos.

El evento periódico realiza un backup automático diario a las 02:00 AM exportando las tablas críticas a ficheros .csv, minimizando así el impacto en el rendimiento del servidor durante el horario laboral. Cada ejecución queda registrada en la tabla control_backups con la fecha, las tablas incluidas y el resultado.

* Primero se crea el fichero Triggers_y_Eventos.sql, el contenido del mismo está en este enlace del git.

</div>

<p align="center">
  <img src="images/img_23.png" alt="Imagen 23" />
</p>

<div align="justify">
* Seguidamente, se el comando que permitirá ejecutarlo.

</div>

<p align="center">
  <img src="images/img_24.png" alt="Imagen 24" />
</p>

<div align="justify">
* Se hacen las verificaciones de los triggers.

</div>

<p align="center">
  <img src="images/img_25.png" alt="Imagen 25" />
</p>



<p align="center">
  <img src="images/img_26.png" alt="Imagen 26" />
</p>

<div align="justify">
* Se hacen las verificaciones de los eventos.

</div>

<p align="center">
  <img src="images/img_27.png" alt="Imagen 27" />
</p>

<div align="justify">
* Para la realización de los backups es necesario que creemos el directorio en el /var/ y se ajusta la propiadad hacia mysql como propietario y grupo

</div>

<p align="center">
  <img src="images/img_28.png" alt="Imagen 28" />
</p>

<div align="justify">
* Y para que persista tras reinicios, se añade al fichero lo siguiente “event_scheduler = ON”

</div>

<p align="center">
  <img src="images/img_29.png" alt="Imagen 29" />
</p>

<div align="justify">
* Finalmente se reinicia el servicio.

</div>

<p align="center">
  <img src="images/img_30.png" alt="Imagen 30" />
</p>



<a name="6-servidor-web---sftp-xavi"></a>
## 6. Servidor Web - SFTP (xavi)
[↑ Volver al índice](#indice)



<a name="6-1-nginx"></a>
### 6.1 Nginx:
[↑ Volver al índice](#indice)

<div align='justify'>

Verificamos la instalación:

</div>

<p align="center">
  <img src="images/img_31.png" alt="Imagen 31" />
</p>



<a name="6-1-1-creacion-de-certificados-ssl"></a>
#### 6.1.1. Creación de certificados SSL:
[↑ Volver al índice](#indice)



<p align="center">
  <img src="images/img_32.png" alt="Imagen 32" />
</p>



<a name="6-1-2-configuracion-de-la-pagina"></a>
#### 6.1.2. Configuración de la Página:
[↑ Volver al índice](#indice)

<div align='justify'>

Instalamos y verificamos la versión de php:

</div>

<p align="center">
  <img src="images/img_33.png" alt="Imagen 33" />
</p>



<p align="center">
  <img src="images/img_34.png" alt="Imagen 34" />
</p>

<div align="justify">
Hacemos las configuraciones necesarias para el funcionamiento de la página con las siguientes funciones:

* Compatibilidad con PHP
* Funcionamiento HTTPS
* Redirección 80->443
* Uso de certificados autofirmados
* Encriptado con TLSv1.2-3

</div>

<p align="center">
  <img src="images/img_35.png" alt="Imagen 35" />
</p>

<div align="justify">
Y vemos los archivos en la ruta:

</div>

<p align="center">
  <img src="images/img_36.png" alt="Imagen 36" />
</p>



<a name="6-1-3-configuracion-php"></a>
#### 6.1.3. Configuración PHP
[↑ Volver al índice](#indice)

<div align='justify'>

Ahora necesitamos conectar el php de la pagina con la BD y el LDAP de nuestro projecto:

config.php:

enganchar imagen cuando se configure server LDAP

</div>

<a name="6-2-sftp"></a>
### 6.2 SFTP
[↑ Volver al índice](#indice)

<div align='justify'>

Instalamos proFTPd:

</div>

<p align="center">
  <img src="images/img_37.png" alt="Imagen 37" />
</p>



<a name="6-2-1-configuracion-del-servicio"></a>
#### 6.2.1 Configuración del servicio:
[↑ Volver al índice](#indice)

<div align='justify'>

Modo Standalone:

</div>

<p align="center">
  <img src="images/img_38.png" alt="Imagen 38" />
</p>

<div align="justify">
Configuración para inicio de sesión con usuarios ftp

</div>

<p align="center">
  <img src="images/img_39.png" alt="Imagen 39" />
</p>

<div align="justify">
Login Anónimo:

</div>

<p align="center">
  <img src="images/img_40.png" alt="Imagen 40" />
</p>

<div align="justify">
Habilitamos y configuramos SFTP:

</div>

<p align="center">
  <img src="images/img_41.png" alt="Imagen 41" />
</p>

<div align="justify">
Las siguientes configuraciones permite el uso de SFTP tanto de usuarios registrados como anónimos:

</div>

<p align="center">
  <img src="images/img_42.png" alt="Imagen 42" />
</p>

<div align="justify">
Habilitamos el módulo de sftp: (/etc/profptd/modules.conf)

</div>

<p align="center">
  <img src="images/img_43.png" alt="Imagen 43" />
</p>

<div align="justify">
Abrimos el puerto 2222 configurado al sftp.conf

</div>

<p align="center">
  <img src="images/img_44.png" alt="Imagen 44" />
</p>



<a name="6-2-2-creacion-de-usuarios"></a>
#### 6.2.2. Creación de usuarios:
[↑ Volver al índice](#indice)

<div align='justify'>

Creamos usuarios para todos los miembros del grupo:

</div>

<p align="center">
  <img src="images/img_45.png" alt="Imagen 45" />
</p>



<p align="center">
  <img src="images/img_46.png" alt="Imagen 46" />
</p>



<a name="6-2-3-pruebas"></a>
#### 6.2.3. Pruebas:
[↑ Volver al índice](#indice)

<div align='justify'>

Primero verificamos los permisos de la estructura de directorios del FTP:

</div>

<p align="center">
  <img src="images/img_47.png" alt="Imagen 47" />
</p>

<div align="justify">
PRUEBA DE CONEXIÓN SFTP desde el server mysql:

Conexión con usuario:

</div>

<p align="center">
  <img src="images/img_48.png" alt="Imagen 48" />
</p>

<div align="justify">
Conexión anónima FTP:

</div>

<p align="center">
  <img src="images/img_49.png" alt="Imagen 49" />
</p>

