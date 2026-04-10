import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from obspy import read
from obspy.core import Stream

# ── Configuración de rutas ──────────────────────────────────────────────────
DATA_DIR = os.path.dirname(os.path.abspath(__file__))
MSEED_FILES = sorted([
    os.path.join(DATA_DIR, f)
    for f in os.listdir(DATA_DIR)
    if f.endswith(".mseed")
])

FACTOR_GAL = 0.0598550415          # counts → Gal (cm/s²)
COMP_LABELS = {"ENZ": "Vertical (Z)", "ENN": "Norte–Sur (N)", "ENE": "Este–Oeste (E)"}
COMP_COLORS = {"ENZ": "#e63946", "ENN": "#457b9d", "ENE": "#2a9d8f"}

# ── Lectura y preprocesamiento ──────────────────────────────────────────────
st = Stream()
for f in MSEED_FILES:
    st += read(f)

st.sort(keys=["channel"])          # orden reproducible

# Detrend simple + conversión a Gal
for tr in st:
    tr.detrend("simple")
    tr.data = tr.data * FACTOR_GAL

# ── Figura ──────────────────────────────────────────────────────────────────
fig, axes = plt.subplots(
    nrows=len(st), ncols=1,
    figsize=(14, 9),
    sharex=True,
    facecolor="#f8f9fa",
)
fig.suptitle(
    "Prueba de Ruido Sísmico en la Estación Barra Vieja\n(AIStation-SkyAlert)",
    fontsize=14, fontweight="bold", y=0.98,
)

for ax, tr in zip(axes, st):
    channel = tr.stats.channel
    label   = COMP_LABELS.get(channel, channel)
    color   = COMP_COLORS.get(channel, "#555555")

    times = tr.times("matplotlib")
    data  = tr.data
    rms   = np.sqrt(np.mean(data ** 2))

    ax.set_facecolor("#ffffff")
    ax.plot(times, data, color=color, linewidth=0.6, label=label)

    # Subtítulo con RMS
    ax.set_title(
        f"Componente {label}  |  RMS = {rms:.4f} Gal",
        fontsize=10, loc="left", pad=4, color="#333333",
    )
    ax.set_ylabel("Amplitud (Gal)", fontsize=9)
    ax.legend(loc="upper right", fontsize=9, framealpha=0.7)
    ax.grid(True, linestyle="--", linewidth=0.4, alpha=0.6, color="#cccccc")
    ax.tick_params(labelsize=8)

    # Anotación de estadísticas
    ax.annotate(
        f"Max: {data.max():.4f}  Min: {data.min():.4f}  RMS: {rms:.4f} Gal",
        xy=(0.01, 0.04), xycoords="axes fraction",
        fontsize=7.5, color="#555555",
        bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="#cccccc", alpha=0.8),
    )

# Eje de tiempo compartido
axes[-1].xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
axes[-1].xaxis.set_major_locator(mdates.AutoDateLocator())
axes[-1].set_xlabel("Tiempo (UTC)", fontsize=10)
fig.autofmt_xdate(rotation=30, ha="right")

# Metadatos del encabezado
start_str = st[0].stats.starttime.strftime("%Y-%m-%d  %H:%M:%S UTC")
net   = st[0].stats.network
sta   = st[0].stats.station
fs    = st[0].stats.sampling_rate
dur   = st[0].stats.npts / fs

fig.text(
    0.5, 0.005,
    f"Red: {net}  |  Estación: {sta}  |  Inicio: {start_str}  |  "
    f"Duración: {dur:.1f} s  |  Fs: {fs:.1f} Hz  |  Factor: {FACTOR_GAL} counts/Gal",
    ha="center", fontsize=7.5, color="#666666",
    style="italic",
)

plt.tight_layout(rect=[0, 0.02, 1, 0.96])

# ── Guardado y visualización ────────────────────────────────────────────────
out_path = os.path.join(DATA_DIR, "ruido_sismico_barra_vieja.png")
fig.savefig(out_path, dpi=200, bbox_inches="tight")
print(f"Figura guardada en: {out_path}")
plt.show()
