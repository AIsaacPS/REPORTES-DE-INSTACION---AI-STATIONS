# REPORTES DE INSTALACIÓN — SkyAlert RED · AI Station

Guía para generar nuevos reportes de instalación de estaciones sísmicas inteligentes.

## Estructura del proyecto

```
REPORTES DE INSTALACION/
├── README.md
├── Barra Vieja/
│   ├── skyalert-report.cls       ← Clase LaTeX (NO modificar)
│   ├── barravieja.tex            ← Reporte (datos + contenido)
│   ├── barravieja.pdf            ← PDF generado
│   ├── barravieja_img1..12       ← Imágenes (png/jpeg)
│   ├── plot_ruido_sismico.py     ← Script para generar img11
│   ├── *.mseed                   ← 3 archivos MiniSEED (ENE, ENN, ENZ)
│   └── mqtt_test.json            ← JSON de prueba MQTT (opcional)
└── Acapulco Palmeiras/
    ├── skyalert-report.cls
    ├── palmeiras.tex
    ├── palmeiras.pdf
    ├── palmeiras_img1..12
    ├── plot_ruido_sismico.py
    ├── *.mseed
    └── mqtt_test.json
```

## Cómo crear un nuevo reporte

### 1. Crear la carpeta

Duplicar cualquier carpeta existente (ej. `Barra Vieja/`) y renombrarla con el nombre del nuevo sitio.

### 2. Preparar insumos

#### Imágenes (12 archivos)

Se necesitan 12 imágenes. Renombrarlas con el prefijo del sitio:

| Imagen | Contenido |
|--------|-----------|
| `{prefijo}_img1.png` | Logo de SkyAlert (mismo para todos, ya incluido) |
| `{prefijo}_img2` | Fachada / exterior del sitio |
| `{prefijo}_img3` | Recepción o acceso al área de instalación |
| `{prefijo}_img4` | Cuarto / habitación donde se instaló el equipo |
| `{prefijo}_img5` | Entorno de la instalación / gabinetes |
| `{prefijo}_img6` | Acercamiento al equipo instalado |
| `{prefijo}_img7` | Acelerómetro / sensor instalado |
| `{prefijo}_img8` | Proceso de instalación (barrenado, montaje, etc.) |
| `{prefijo}_img9` | Proceso de instalación (continuación) |
| `{prefijo}_img10` | Jetson / acceso remoto / equipo encendido |
| `{prefijo}_img11.png` | Captura de pantalla: formas de onda sísmicas (medición de ruido) |
| `{prefijo}_img12` | Captura de pantalla: confirmación de mensajes en AWS |

Formatos aceptados: `.png` o `.jpeg`. La img1 (logo) siempre es `.png`.

#### JSON de prueba MQTT (1 archivo)

Guardar el archivo JSON generado por la prueba MQTT en la carpeta del reporte. Este archivo contiene el payload de anomalía enviado a AWS y se usa para llenar la sección "Prueba MQTT" del reporte. Ver la sección [MQTT payload](#sección-mqtt-payload) para el mapeo de campos.

#### Archivos MiniSEED + script de gráficos (4 archivos)

Para generar la imagen de formas de onda sísmicas (`{prefijo}_img11.png`), se necesitan:

- **3 archivos `.mseed`** — uno por componente (ENE, ENN, ENZ), generados por el acelerómetro durante la medición de ruido sísmico en sitio. Formato de nombre típico:
  ```
  AAAA.DDD.HH.MM.SS.SSSS.SHAKE.AS.00.ENE.D.mseed   (Este–Oeste)
  AAAA.DDD.HH.MM.SS.SSSS.SHAKE.AS.00.ENN.D.mseed   (Norte–Sur)
  AAAA.DDD.HH.MM.SS.SSSS.SHAKE.AS.00.ENZ.D.mseed   (Vertical)
  ```
- **`plot_ruido_sismico.py`** — script de Python que lee los 3 MiniSEED, aplica detrend, convierte de counts a Gal y genera el gráfico PNG.

**Para generar el gráfico:**

```bash
cd "REPORTES DE INSTALACION/NombreSitio/"
python3 plot_ruido_sismico.py
```

El script detecta automáticamente todos los `.mseed` en su misma carpeta. Genera un archivo PNG que debe usarse como `{prefijo}_img11.png`.

**Dependencias Python:** `obspy`, `numpy`, `matplotlib`.

```bash
pip install obspy numpy matplotlib
```

**Al crear un nuevo reporte**, copiar `plot_ruido_sismico.py` de cualquier carpeta existente y modificar únicamente:

- La línea de `fig.suptitle(...)` con el nombre del nuevo sitio
- La línea de `out_path` con el nombre de salida deseado (ej. `ruido_sismico_nuevo_sitio.png`)

### 3. Editar el archivo `.tex`

Abrir el `.tex` y modificar **solo** las secciones indicadas abajo. Los caracteres especiales en español deben escaparse con la sintaxis de LaTeX.

#### Caracteres especiales (obligatorio)

| Carácter | Escribir en LaTeX |
|----------|-------------------|
| á | `\'a` |
| é | `\'e` |
| í | `\'i` |
| ó | `\'o` |
| ú | `\'u` |
| ñ | `\~n` |
| ü | `\"u` |
| ° | `\textdegree{}` |
| & | `\&` |

#### Sección: Metadata (preámbulo)

```latex
\sitename{Nombre del Sitio}              % Nombre del hotel/condominio/empresa
\sitelocation{Ciudad, Estado}             % Ej: Acapulco, Guerrero
\siteaddress{Direcci\'on completa}        % Dirección con código postal
\sitemaps{https://maps.app.goo.gl/...}   % Link de Google Maps
\sitelat{16.768045\textdegree{} N}        % Latitud
\sitelong{-99.785777\textdegree{} W}      % Longitud
\sitealt{0 m}                             % Altitud sobre nivel del mar
\seismiczone{Tipo D -- Alta Sismicidad}   % Zona sísmica (A, B, C o D)

\stationid{AISensorXXX}                   % ID de la estación
\sensormodel{AS-Explorer}                 % Modelo del sensor
\installdate{DD de Mes de AAAA}           % Fecha de instalación
\folio{Ruta-Estado-XX-AAAA}               % Folio de ruta
\reportid{AAAA-Edo-XXX}                   % ID del reporte

\authorname{Ing. Isaac P\'erez}           % Autor del reporte
\supportnames{Jorge Giles \& Omar Barrag\'an}  % Apoyo
\coverlogo{prefijo_img1}                  % Logo (sin extensión)
```

#### Sección: Contactos en sitio

```latex
\newcommand{\contactoA}{Nombre Completo\newline{\small Cargo -- +52 1 XXX XXX XXXX}}
\newcommand{\contactoB}{Nombre Completo\newline{\small Cargo -- +52 1 XXX XXX XXXX}}
```

#### Sección: Header y footer (en cada página después de `\newpage`)

```latex
\setheadertext{Nombre de la Secci\'on}
\setfootertext{AISensorXXX \textperiodcentered{} Ciudad, Edo. \textperiodcentered{} DD-Mes-AAAA}
```

#### Sección: Tabla de equipos

Modificar las filas de la tabla según los dispositivos instalados. Cada fila tiene:

```latex
\rowcolor{white}  % o \rowcolor{tablerow} para filas alternadas
Nombre del Dispositivo & Modelo & ID/SN & Ubicaci\'on & Propiedad & \chipok{Activo}\\
```

Valores de propiedad: `SkyAlert`, `Aliado`, o `--`.

Valores de estado disponibles:
- `\chipok{Activo}` — verde
- `\chipna{N/A}` — gris
- `\chipwarn{Pendiente}` — amarillo
- `\chipfail{Fallo}` — rojo

Si la estación **no tiene sensor secundario**, eliminar esa fila y cambiar el KPI de dispositivos activos de `6` a `5`.

#### Sección: Fotos

Cambiar los nombres de archivo y las descripciones (captions):

```latex
\photoframe{prefijo_imgN}{Descripci\'on de la foto}
```

#### Sección: MQTT payload

Esta sección se llena a partir del **archivo JSON de la prueba MQTT** realizada en sitio. Dicho archivo es generado automáticamente por el sistema al ejecutar la prueba de envío de anomalías a AWS IoT Core.

**Insumo requerido:** archivo `.json` con el payload de la prueba (ej. `mqtt_test_AISensor001.json`). Se recomienda guardarlo dentro de la carpeta del reporte como referencia.

Ejemplo de JSON de entrada:

```json
{
  "station_id": "AISensor001",
  "message": "ANOMALIA DETECTADA + IA ACTIVADA en 2026-03-27 16:45:36 (PGA: 2.5 Gals)",
  "pga_gals": 2.54,
  "anomaly_active": true,
  "timestamp": "2026-03-27T16:45:36.045826+00:00",
  "location_name": "Acapulco, Gro."
}
```

Mapeo de campos JSON → LaTeX:

| Campo JSON | Dónde va en el `.tex` |
|---|---|
| `station_id` | `"station\_id": "AISensorXXX"` |
| `message` | `"message": "ANOMALIA DETECTADA + IA ACTIVADA en FECHA (PGA: X.X Gals)"` |
| `pga_gals` | `\textcolor{accent}{VALOR,}` |
| `anomaly_active` | `\textcolor{amberdark}{true}` o `false` |
| `timestamp` | `"timestamp": "VALOR"` |
| `location_name` | `"location\_name": "Ciudad, Edo."` |

También actualizar la línea del broker (siempre es `xxxxxxxxxx.iot.us-east-1.amazonaws.com`) y la cantidad de mensajes entregados (ej. `4 / 4 (100%)`).

> **Nota:** Los guiones bajos en los nombres de campo JSON deben escaparse como `\_` en LaTeX.

#### Sección: Observaciones

Reescribir el contenido del `obsbox` y la lista enumerada según las condiciones específicas del sitio.

#### Sección: Pruebas realizadas

Modificar observaciones de cada prueba si difieren del estándar. Si se realizó medición de ruido sísmico, incluir el valor RMS.

#### Sección: Verificación y aceptación

```latex
\signblock{Encargado de la Instalaci\'on}{Ing. Isaac P\'erez}{Cargo}{DD / MM / AAAA}
\signblock{Encargado del Sitio (Aliado)}{Nombre del Contacto}{Cargo}{DD / MM / AAAA}
```

La tabla derecha debe llevar los datos del **contacto principal del sitio** (contactoA).

#### Sección: Apoyo en instalación

Agregar una fila por cada persona que apoyó:

```latex
\datafield{Nombre}{Nombre Completo}&
\datafield{Cargo}{Cargo}&
\datafield{Fecha}{DD / MM / AAAA}\\
```

### 4. Compilar

**En Overleaf:**
1. Subir todos los archivos de la carpeta (`.cls`, `.tex`, imágenes)
2. Compilador: **pdfLaTeX** (el default)
3. Compilar

**En terminal (local):**
```bash
pdflatex -interaction=nonstopmode nombre.tex
pdflatex -interaction=nonstopmode nombre.tex   # segunda pasada para referencias
```

Se requiere: TeX Live con los paquetes `sourcesanspro`, `sourcecodepro`, `fontawesome5`, `tcolorbox`, `tikz`, `fancyhdr`.

## Archivo `skyalert-report.cls`

Es la clase que define el diseño visual del reporte. **No debe modificarse** a menos que se quiera cambiar el diseño global de todos los reportes. Si se actualiza, copiar la nueva versión a todas las subcarpetas.

## Notas

- El reporte genera **6 páginas**: portada + datos generales + fotos + validación de señal + prueba MQTT + observaciones y firmas.
- Si el contenido de una página se desborda (más dispositivos, texto de observaciones más largo, etc.), reducir el `\vspace` entre secciones o el tamaño de fuente de la tabla (`\footnotesize` en vez de `\small`).
- Las imágenes de señal sísmica (img11) y AWS (img12) se renderizan a ancho completo (`\textwidth`). Usar capturas de pantalla con buena resolución.
