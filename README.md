# REPORTES DE INSTALACIÓN — SkyAlert RED · AI Station

Guía para generar nuevos reportes de instalación de estaciones sísmicas inteligentes.

## Estructura del proyecto

```
REPORTES DE INSTALACION/
├── README.md
├── generar_tex.py                ← Script generador de .tex
├── template.tex                  ← Plantilla LaTeX con placeholders
├── datos_instalacion_template.txt ← Template limpio para nuevos sitios
├── Barra Vieja/
│   ├── *.txt                     ← Datos del sitio (llenar primero)
│   ├── skyalert-report.cls       ← Clase LaTeX
│   ├── barravieja.tex            ← Reporte generado
│   ├── barravieja.pdf            ← PDF compilado
│   ├── barravieja_img1..12       ← Imágenes (png/jpeg)
│   ├── plot_ruido_sismico.py     ← Script para generar img11
│   ├── *.mseed                   ← 3 archivos MiniSEED (ENE, ENN, ENZ)
│   └── *.json                    ← JSON de prueba MQTT
└── Acapulco Cyti-Uagro/
    ├── *.txt
    ├── skyalert-report.cls
    ├── acapulcocytiuagro.tex
    ├── acapulcocytiuagro.pdf
    ├── 1..12 (png/jpeg)
    ├── plot_ruido_sismico.py
    ├── *.mseed
    └── *.json
```

## Cómo crear un nuevo reporte

### 1. Crear la carpeta

1. Crear una nueva carpeta con el nombre del sitio
2. Copiar `datos_instalacion_template.txt` dentro de la carpeta y renombrarlo (ej. `NombreSitio.txt`)
3. Copiar `skyalert-report.cls` y `plot_ruido_sismico.py` de cualquier carpeta existente

### 1.5. Llenar el `.txt` de datos

Abrir la copia de `datos_instalacion_template.txt` y llenar todos los campos. El script se encarga de:

- Escapar caracteres especiales a LaTeX (acentos, ñ, &, etc.)
- Formatear latitud/longitud con grados y N/W
- Formatear altitud con msnm
- Leer el JSON MQTT automáticamente
- Generar filas de equipos, pruebas, observaciones y apoyo

Campos del `.txt`:

- Datos del sitio (nombre, dirección, coordenadas, zona sísmica)
- Datos de la estación (ID, modelo, fecha, folio)
- Contactos en sitio
- Equipos instalados (formato: `dispositivo | modelo | id_sn | ubicacion | propiedad | estado`)
- KPIs
- Descripciones de fotos (captions)
- Datos de prueba MQTT
- Observaciones
- Pruebas realizadas (formato: `nombre | resultado | observacion`)
- Firmas y apoyo en instalación

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

### 3. Generar el archivo `.tex` (automático)

Una vez llenado `datos_instalacion.txt` y con el archivo JSON MQTT en la carpeta, ejecutar el script generador:

```bash
cd "REPORTES DE INSTALACION/"
python3 generar_tex.py "Nombre del Sitio" [prefijo]
```

- `Nombre del Sitio` — carpeta del sitio (ej. `"Acapulco Cyti-Uagro"`)
- `prefijo` — (opcional) prefijo para imágenes. Si no se da, se genera automáticamente del nombre de la carpeta (ej. `acapulcocytiuagro`)

El script:
1. Lee `datos_instalacion.txt` de la carpeta del sitio
2. Lee el primer archivo `.json` de la carpeta (datos MQTT)
3. Aplica el escapado LaTeX automáticamente (acentos, ñ, &, etc.)
4. Genera las filas de equipos, pruebas, observaciones y apoyo
5. Produce el archivo `{prefijo}.tex` listo para compilar

**Ejemplo:**

```bash
python3 generar_tex.py "Acapulco Cyti-Uagro"
# → Genera: Acapulco Cyti-Uagro/acapulcocytiuagro.tex
```

**Archivos del generador** (en la raíz de `REPORTES DE INSTALACION/`):
- `generar_tex.py` — script principal
- `template.tex` — plantilla LaTeX con placeholders `{{campo}}`

> **Nota:** Después de generar el `.tex`, se puede revisar y ajustar manualmente si se necesitan cambios puntuales (ej. `\vspace`, tamaño de fuente en tablas).

#### Edición manual (alternativa)

Si se prefiere no usar el generador, se puede editar el `.tex` directamente. Los caracteres especiales en español deben escaparse manualmente:

| Carácter | LaTeX |
|----------|-------|
| á é í ó ú | `\'a \'e \'i \'o \'u` |
| ñ | `\~n` |
| ü | `\"u` |
| ° | `\textdegree{}` |
| & | `\&` |

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
