#!/usr/bin/env python3
"""
generar_tex.py — Genera un .tex a partir de datos_instalacion.txt y el JSON MQTT.
Uso: python3 generar_tex.py <carpeta_del_sitio> [prefijo]

  carpeta_del_sitio : ruta a la carpeta del sitio (ej. "Acapulco Cyti-Uagro")
  prefijo           : prefijo para imágenes (ej. "cytiuagro"). Si no se da,
                      se genera automáticamente del nombre de la carpeta.

El script busca:
  - datos_instalacion.txt  en la carpeta del sitio
  - *.json                 en la carpeta del sitio (primer JSON encontrado)
  - template.tex           en la carpeta padre (REPORTES DE INSTALACION/)
"""

import sys, os, json, re, glob as globmod, unicodedata

# ── Mapa de escapado LaTeX para caracteres especiales en español ──────────
LATEX_ESCAPE = {
    'á': "\\'a", 'é': "\\'e", 'í': "\\'i", 'ó': "\\'o", 'ú': "\\'u",
    'Á': "\\'A", 'É': "\\'E", 'Í': "\\'I", 'Ó': "\\'O", 'Ú': "\\'U",
    'à': '\\`a', 'è': '\\`e', 'ì': '\\`i', 'ò': '\\`o', 'ù': '\\`u',
    'ñ': '\\~n', 'Ñ': '\\~N', 'ü': '\\"u', 'Ü': '\\"U',
    '&': '\\&', '%': '\\%', '#': '\\#', '_': '\\_',
    '°': '\\textdegree{}',
}

def latex_esc(text):
    """Escapa caracteres especiales para LaTeX."""
    out = []
    for ch in text:
        out.append(LATEX_ESCAPE.get(ch, ch))
    return ''.join(out)

def parse_datos(path):
    """Lee datos_instalacion.txt y devuelve un dict clave→valor."""
    data = {}
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' not in line:
                continue
            key, _, val = line.partition('=')
            data[key.strip()] = val.strip()
    return data

def parse_pipe_fields(val):
    """Separa un valor con pipes: 'a | b | c' → ['a','b','c']."""
    return [v.strip() for v in val.split('|')]

def chip_for_status(status):
    """Devuelve el comando LaTeX de chip según el estado."""
    s = status.lower()
    if s == 'activo':  return '\\chipok{Activo}'
    if s == 'n/a':     return '\\chipna{N/A}'
    if s == 'pendiente': return '\\chipwarn{Pendiente}'
    if s == 'fallo':   return '\\chipfail{Fallo}'
    return '\\chipok{' + latex_esc(status) + '}'

def chip_for_result(result):
    s = result.strip().upper()
    if s == 'PASS':      return '\\chipok{PASS}'
    if s == 'FAIL':      return '\\chipfail{FAIL}'
    if s == 'PENDIENTE': return '\\chipwarn{Pendiente}'
    return '\\chipok{' + latex_esc(result) + '}'

def build_equipos_rows(data):
    """Genera las filas LaTeX de la tabla de equipos."""
    rows = []
    colors = ['white', 'tablerow']
    i = 0
    for n in range(1, 20):
        key = f'equipo{n}'
        if key not in data or not data[key]:
            continue
        parts = parse_pipe_fields(data[key])
        if len(parts) < 6:
            parts += [''] * (6 - len(parts))
        disp, modelo, idsn, ubic, prop, estado = parts[:6]
        color = colors[i % 2]
        row = (f'\\rowcolor{{{color}}}\n'
               f'{latex_esc(disp)} & {latex_esc(modelo)} & {latex_esc(idsn)} & '
               f'{latex_esc(ubic)} & {latex_esc(prop)} & {chip_for_status(estado)}\\\\')
        rows.append(row)
        i += 1
    return '\n'.join(rows)

def build_pruebas_rows(data):
    rows = []
    colors = ['white', 'tablerow']
    i = 0
    for n in range(1, 20):
        key = f'prueba{n}'
        if key not in data or not data[key]:
            continue
        parts = parse_pipe_fields(data[key])
        if len(parts) < 3:
            parts += [''] * (3 - len(parts))
        nombre, resultado, obs = parts[:3]
        color = colors[i % 2]
        row = (f'\\rowcolor{{{color}}}\n'
               f'{latex_esc(nombre)}&{chip_for_result(resultado)}&{latex_esc(obs)}\\\\')
        rows.append(row)
        i += 1
    return '\n'.join(rows)

def build_apoyo_rows(data):
    rows = []
    for n in range(1, 10):
        key = f'apoyo{n}'
        if key not in data or not data[key]:
            continue
        parts = parse_pipe_fields(data[key])
        if len(parts) < 3:
            parts += [''] * (3 - len(parts))
        nombre, cargo, fecha = parts[:3]
        rows.append(
            f'\\datafield{{Nombre}}{{{latex_esc(nombre)}}}&\n'
            f'\\datafield{{Cargo}}{{{latex_esc(cargo)}}}&\n'
            f'\\datafield{{Fecha}}{{{latex_esc(fecha)}}}\\\\'
        )
    return '\n'.join(rows)

def build_observaciones_items(data):
    items = []
    for n in range(1, 20):
        key = f'observacion_{n}'
        if key not in data or not data[key]:
            continue
        items.append(f'\\item {latex_esc(data[key])}')
    return '\n'.join(items)

def load_mqtt_data(site_dir):
    """Busca el primer .json en la carpeta y extrae el payload de anomalía detectada."""
    jsons = globmod.glob(os.path.join(site_dir, '*.json'))
    if not jsons:
        return {}
    with open(jsons[0], encoding='utf-8') as f:
        raw = json.load(f)
    # Buscar el mensaje con anomaly_active=true
    payload = {}
    for msg in raw.get('messages', []):
        p = msg.get('payload', {})
        if p.get('anomaly_active') is True:
            payload = p
            break
    if not payload and raw.get('messages'):
        payload = raw['messages'][0].get('payload', {})
    return payload

def make_prefijo(folder_name):
    """Genera un prefijo de imagen a partir del nombre de carpeta."""
    # Quitar acentos, minúsculas, solo alfanuméricos
    nfkd = unicodedata.normalize('NFKD', folder_name)
    clean = ''.join(c for c in nfkd if not unicodedata.combining(c))
    clean = re.sub(r'[^a-zA-Z0-9]', '', clean).lower()
    return clean

def build_footer_ubicacion(data):
    """Genera 'Ciudad, Edo.' para el footer a partir de ciudad_estado."""
    loc = data.get('ciudad_estado', '')
    # Intentar abreviar: "Acapulco, Guerrero" → "Acapulco, Gro."
    parts = [p.strip() for p in loc.split(',')]
    if len(parts) == 2 and len(parts[1]) > 4:
        return f'{parts[0]}, {parts[1][:3]}.'
    return loc

def build_footer_fecha(data):
    """Genera 'DD-Mes-AAAA' para el footer a partir de fecha_instalacion."""
    fecha = data.get('fecha_instalacion', '')
    # Intentar parsear "27 de Marzo de 2026" → "27-Mar-2026"
    m = re.match(r'(\d+)\s+de\s+(\w+)\s+de\s+(\d+)', fecha, re.IGNORECASE)
    if m:
        dia, mes, anio = m.group(1), m.group(2), m.group(3)
        return f'{dia}-{mes[:3]}-{anio}'
    return fecha

def main():
    if len(sys.argv) < 2:
        print('Uso: python3 generar_tex.py <carpeta_del_sitio> [prefijo]')
        sys.exit(1)

    site_dir = sys.argv[1]
    if not os.path.isdir(site_dir):
        print(f'Error: no existe la carpeta "{site_dir}"')
        sys.exit(1)

    # Cargar datos
    datos_path = os.path.join(site_dir, 'datos_instalacion.txt')
    if not os.path.isfile(datos_path):
        # Buscar cualquier .txt en la carpeta
        txts = globmod.glob(os.path.join(site_dir, '*.txt'))
        if txts:
            datos_path = txts[0]
        else:
            print(f'Error: no se encontró ningún .txt en "{site_dir}"')
            sys.exit(1)

    data = parse_datos(datos_path)

    # Prefijo
    folder_name = os.path.basename(os.path.normpath(site_dir))
    prefijo = sys.argv[2] if len(sys.argv) > 2 else make_prefijo(folder_name)

    # Template
    script_dir = os.path.dirname(os.path.abspath(__file__))
    template_path = os.path.join(script_dir, 'template.tex')
    if not os.path.isfile(template_path):
        print(f'Error: no se encontró template.tex en "{script_dir}"')
        sys.exit(1)

    with open(template_path, encoding='utf-8') as f:
        template = f.read()

    # Datos MQTT del JSON
    mqtt = load_mqtt_data(site_dir)

    # Construir secciones compuestas
    equipos_rows = build_equipos_rows(data)
    pruebas_rows = build_pruebas_rows(data)
    apoyo_rows = build_apoyo_rows(data)
    obs_items = build_observaciones_items(data)
    footer_ubic = build_footer_ubicacion(data)
    footer_fecha = build_footer_fecha(data)

    # Mapeo de placeholders → valores
    replacements = {
        'prefijo': prefijo,
        'footer_ubicacion': latex_esc(footer_ubic),
        'footer_fecha': latex_esc(footer_fecha),
        'equipos_rows': equipos_rows,
        'pruebas_rows': pruebas_rows,
        'apoyo_rows': apoyo_rows,
        'observaciones_items': obs_items,
        # MQTT desde JSON
        'mqtt_station_id': latex_esc(mqtt.get('station_id', data.get('station_id', ''))),
        'mqtt_message': latex_esc(mqtt.get('message', '')),
        'mqtt_pga': str(mqtt.get('pga_gals', '')),
        'mqtt_anomaly_active': str(mqtt.get('anomaly_active', 'true')).lower(),
        'mqtt_timestamp': latex_esc(mqtt.get('timestamp', '')),
        'mqtt_location': latex_esc(mqtt.get('location_name', '')),
    }

    # Formatear latitud y longitud con grados
    lat_raw = data.get('latitud', '')
    lon_raw = data.get('longitud', '')
    try:
        lat_val = float(lat_raw)
        replacements['latitud'] = f'{abs(lat_val)}\\textdegree{{}} {"N" if lat_val >= 0 else "S"}'
    except ValueError:
        replacements['latitud'] = latex_esc(lat_raw)
    try:
        lon_val = float(lon_raw)
        replacements['longitud'] = f'{abs(lon_val)}\\textdegree{{}} {"E" if lon_val >= 0 else "W"}'
    except ValueError:
        replacements['longitud'] = latex_esc(lon_raw)

    # Formatear altitud con msnm
    alt_raw = data.get('altitud', '')
    try:
        alt_val = float(alt_raw)
        replacements['altitud'] = f'{alt_val} msnm'
    except ValueError:
        replacements['altitud'] = latex_esc(alt_raw)

    # Campos simples del txt → escapados a LaTeX
    simple_fields = [
        'nombre_sitio', 'ciudad_estado', 'direccion', 'google_maps_url',
        'altitud', 'zona_sismica',
        'station_id', 'modelo_sensor', 'fecha_instalacion', 'folio', 'reporte_id',
        'autor', 'apoyo',
        'contacto1_nombre', 'contacto1_cargo', 'contacto1_telefono',
        'contacto2_nombre', 'contacto2_cargo', 'contacto2_telefono',
        'dispositivos_activos', 'conectividad', 'resolucion_adc', 'latencia',
        'img2_caption', 'img3_caption', 'img4_caption', 'img5_caption',
        'img6_caption', 'img7_caption', 'img8_caption', 'img9_caption',
        'img10_caption', 'img12_caption',
        'mqtt_broker', 'mqtt_mensajes',
        'observacion_general',
        'firma_instalador_nombre', 'firma_instalador_cargo', 'firma_instalador_fecha',
        'firma_aliado_nombre', 'firma_aliado_cargo', 'firma_aliado_fecha',
    ]
    for field in simple_fields:
        if field not in replacements:
            val = data.get(field, '')
            # No escapar URLs
            if 'url' in field or 'maps' in field:
                replacements[field] = val
            else:
                replacements[field] = latex_esc(val)

    # Reemplazar placeholders <<campo>>
    def replace_placeholder(m):
        key = m.group(1).strip()
        return replacements.get(key, '')

    output = re.sub(r'<<(\w+)>>', replace_placeholder, template)

    # Escribir .tex
    out_name = f'{prefijo}.tex'
    out_path = os.path.join(site_dir, out_name)
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(output)

    print(f'✓ Generado: {out_path}')

if __name__ == '__main__':
    main()
