# Proyecto Transversal ASIXc1D - Grupo 3
**Archivo:** pro-asixc1d-g3  
**Elaborado por:** Xavier, Ivan, Iker y Piero  
**Institución:** Institut Tecnològic Barcelona  

---

## 1. Plano General de las Instalaciones INNOVATETECH

El CPD se ubica en la planta baja, en una zona central del edificio. El núcleo del CPD está completamente cerrado por una estructura acristalada técnica de alta resistencia, utilizando vidrio laminado de seguridad con tratamiento acústico y térmico.

Esta cristalera técnica permite:
* **Aislamiento Térmico:** Mantiene el aire frío dentro de la zona de racks, separándolo del resto del edificio.
* **Supervisión Visual:** Permite observar el estado de los equipos (LEDs de estado, orden) desde el exterior sin necesidad de entrar y alterar la temperatura de la sala.
* **Discreción y Estética:** El cristal cuenta con tecnología electrocromática (se vuelve opaco con un interruptor) para ocultar la sala durante visitas no autorizadas, manteniendo la máxima discreción.

### 1.1. Plano de la Sala del Rack
Se ha optado por una arquitectura de cinco servidores físicos distribuidos en cuatro racks para maximizar la seguridad y el rendimiento. Este esquema asegura el aislamiento de procesos críticos y facilita un crecimiento vertical ágil ante incrementos de la demanda futura.

La asignación de funciones específicas por servidor garantiza la independencia de procesos:
* **Rack 1: Servicio Web y SFTP (Secure File Transfer Protocol)**
    Centraliza el acceso externo de la empresa. Gestiona el portal corporativo y las interfaces de usuario (optimizado para tráfico HTTP/HTTPS) y aloja el servicio SFTP para el intercambio seguro y cifrado de archivos con clientes y proveedores.
* **Rack 2: Centralización de Logs (SIEM / Logging)**
    Encargado de recibir y almacenar todos los registros de eventos (logs) de la red y el hardware. Nodo crítico para la auditoría de seguridad, cumplimiento normativo y detección de anomalías en tiempo real.
* **Rack 3: Active Directory (AD)**
    Dedicado exclusivamente a la gestión de la infraestructura de identidad de la empresa (autenticación de usuarios, directivas de grupo GPOs y asignación de permisos centralizados).
* **Rack 4: Procesamiento de Audio y Vídeo**
    Servidor independiente dedicado a la transcodificación y distribución para las plataformas de streaming de audio y vídeo de *Innovate Tech*. Al estar segregado del AD, se garantiza que el alto consumo de CPU y ancho de banda no afecte la autenticación corporativa.
* **Rack 5: Base de Datos (DB Server)**
    Motor de datos neurálgico configurado con discos NVMe de ultra alta velocidad y redundancia para minimizar tiempos de respuesta y garantizar alta disponibilidad.

#### 1.1.1. Estructuración de los Racks
* **Dimensiones:** Armarios de **42U de altura**, 800 mm de ancho y 1100 mm de profundidad (con espacio lateral para gestión de cableado vertical).
* **Estándar de Distribución:** Arquitectura **Top of Rack (ToR)** para datos y **Bottom of Rack (BoR)** para energía.

#### 1.1.2. Componentes Técnicos Comunes por Rack
A excepción de los servidores específicos, cada rack cuenta con:
1.  **SAI/UPS en Rack (Unidades U1 a U3):** Ubicado en la base para mantener bajo el centro de gravedad. Sistema Online de Doble Conversión de 3000VA (3kVA) / 2700W con tarjeta de red SNMP para monitoreo remoto.
2.  **PDU Inteligentes:** Dos unidades conmutadas Zero-U fijadas verticalmente en la parte posterior. Conexiones de entrada IEC 320 C20 y salidas bloqueables (IEC C13 y C19) con capacidad de apagado/encendido remoto.
3.  **Paneles de Parcheo (Patch Panels - Unidades U41 y U42):** * 1U de cobre con 24 puertos RJ-45 Categoría 6A FTP apantallado (Keystone angular).
    * 1U de fibra óptica (FOBOT) con cassette deslizante para hasta 24 acopladores LC-Duplex Monomodo o Multimodo (OM4) destinados a enlaces (*uplinks*) hacia el Switch Core.
4.  **Electrónica de Red (Switch ToR - Unidad U40):** Switch gestionable L2/L3 con 24 puertos nativos de 1GbE/10GbE Base-T y 4 puertos SFP+ de alta velocidad (10Gbps/25Gbps).

---

## 1.2. Sistema de Climatización del CPD

En lugar de un diseño abierto convencional donde el aire se mezcla perdiendo eficiencia, la estructura acristalada crea un recinto estanco:

* **Efecto Estanco:** El aire frío inyectado por las unidades de precisión (**CRAC**) se mantiene aislado, permitiendo trabajar a una temperatura constante de **21°C** con consumo mínimo.
* **Control de Presión Positiva:** El sistema inyecta más aire del que extrae. Al abrir la puerta, el aire sale expulsado impidiendo físicamente la entrada de polvo.
* **Humedad Controlada:** Mantenida de forma estricta entre **45% y 50%** para evitar fallos por corrosión o electricidad estática.

> 🔒 **Seguridad por Oscuridad (Medidas de Camuflaje)**
> * **Señalización:** Se prohíbe el uso de carteles con las palabras "CPD", "Data Center" o "Servidores". En la puerta se indicará únicamente: `"PROHIBIDO EL PASO A PERSONAS NO AUTORIZADAS"`. En los planos de evacuación públicos figurará como `"Zona Técnica"`.
> * **Vidrio Electrocrómico:** Permite volver opaca la cristalera de la sala mediante un interruptor para ocultar los racks ante visitas externas.

---

## 1.3. Distribución y Gestión del Cableado (Normativa ANSI/TIA-942)

* **Cableado de Energía (Bajo Suelo):** Canalizado por el suelo técnico elevado (a 50 cm de altura) mediante bandejas de acero tipo rejilla. Separado físicamente de los datos para evitar interferencias electromagnéticas (EMI).
* **Cableado de Datos (Aéreo):** Conexiones de fibra y cobre Cat 6A distribuidas en pasarelas aéreas. Se utiliza un código de colores estricto:
    * 🔵 **Azul:** Datos
    * 🔴 **Rojo:** Gestión / Logs
    * 🟡 **Amarillo:** Fibra Óptica

---

## 2. Infraestructura Eléctrica y Consumos

### 2.1. Tabla de Consumo Eléctrico Estimado

| Equipamiento | Consumo Aproximado |
| :--- | :--- |
| 5 Servidores Físicos | 2500 W |
| 4 Switches Gestionables | 400 W |
| Router / Módem | 50 W |
| Sistema NAS / Backups | 300 W |
| Climatización Auxiliar | 500 W |
| **Total Estimado** | **3750 W** |

> **Propuesta:** Se implementa un SAI de **5000 VA** que proporciona una autonomía de entre 20 y 30 minutos para permitir apagados controlados o persistencia frente a microcortes.

---

## 3. Implementación del CPD en la Nube (AWS & Ansible)

La arquitectura física se replica en AWS distribuyendo los servicios en instancias independientes (utilizando imágenes limpias sin software preinstalado del Marketplace):

### 3.1. Inventario de Servidores e IP de la Infraestructura

| Servidor | Servicios Instalados | IP Pública | IP Privada |
| :--- | :--- | :--- | :--- |
| **Servidor-Web** | Nginx, SFTP (ProFTPd) | `54.197.85.133` | `172.31.26.247/20` |
| **Servidor Audio/Vídeo** | Icecast, Jitsi-Meet | `34.202.38.124` | `172.31.22.20/20` |
| **Servidor-Logs** | Elastic, Kibana, AuditBeat | `34.229.219.83` | `172.31.29.157/20` |
| **Servidor-Directorio Actiu** | LDAP | `44.223.1.104` | `172.31.22.126/20` |
| **Servidor BD** | MySQL | `34.226.127.76` | `172.31.30.119/20` |

* **Repositorio del Proyecto:** [GitHub Repository](https://github.com/ITB2526-PieroYcaza/ProyectoTransversal-Grupo3.git)

### 3.2. Automatización con Ansible
El despliegue de los servidores de Logs y Directorio Activo (LDAP) se gestiona de forma centralizada desde el Servidor Web usando claves SSH (`ServidorWeb.pem`) y configurando el comportamiento de Ansible:

```ini
# Archivo: ansible.cfg
[defaults]
host_key_checking = False
inventory = inventory
