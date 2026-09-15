"""
Capa de datos de la ENIGH 2022 — secciones 1 y 2 del pipeline.

Lee los CSV públicos de INEGI y entrega un `DatosAnio` para `aradillas_core`.
Misma estructura que `datos_2014.py`; ver ese módulo para la referencia contra
el Gauss, que sigue siendo la fuente de verdad metodológica.

Diferencias de formato respecto de 2014
---------------------------------------
* El hogar se identifica con `folioviv` + `foliohog` (en 2014 bastaba
  `folioviv`): una vivienda puede alojar varios hogares.
* Las claves de producto son alfanuméricas (A004) en vez de numéricas (1004).
  La conversión es determinista y se deriva de la tabla ya verificada de 2014,
  lo que además evita el bug N7 de `productos.py` (aguacate clasificado en
  Frutas cuando el Gauss lo pone en Verduras, y pera ausente).
* Los precios de referencia son de **2018** (`data_inp_pp/`), no de junio 2011,
  y se deflactan con las series por ciudad de `data_ciudades/`.
* **`ing_mon` no existe**: la ENIGH 2022 "Nueva serie" dejó de publicar el
  ingreso no monetario por separado. Se reconstruye desde `ingresos.csv`
  sumando las claves monetarias — ver `CORTE_MONETARIO`.
"""

import glob
import re
import unicodedata

import numpy as np
import pandas as pd

from datos_base import DatosAnio
from datos_2014 import CATEGORIAS as CATEGORIAS_2014

EPS = 0.01
N_Z = 9

# Ventana de levantamiento de la ENIGH 2022 (ago-nov), análoga a la de 2014.
ANIO_BASE = 2018            # los precios de referencia de data_inp_pp son de julio 2018
MES_BASE = 7                # CORRECCIÓN N16: la base del deflactor es el MISMO mes de
                            # las cotizaciones (el Gauss: jun-2011 contra INPC jun-2011).
                            # La mediana de todo 2018 desviaba >5 % el 22 % de los factores,
                            # hasta ±50 % en frutas estacionales (naranja, melón, uva).
MES_INI, MES_FIN = 8, 11
ANIO_ENIGH = 2022

# ---------------------------------------------------------------------------
# CORTE_MONETARIO — hasta qué clave P### de `ingresos.csv` se suma como ingreso.
#
# `ing_mon` no viene en el concentrado 2022. Se probó cortar en P067 bajo el
# supuesto de que las claves no monetarias van al final del catálogo
# (razón ing_mon/ing_cor: P067 -> 0.759, todas -> 0.877; 2014 = 0.794).
# ---------------------------------------------------------------------------
# RESUELTO (2026-08-04): NO hay que cortar. `ingresos.csv` ya contiene solo
# ingreso monetario — la suma de todas sus claves ($53,929) coincide con
# `ing_cor - estim_alqu - remu_espec` ($53,694), y `estim_alqu`, el componente
# no monetario principal, es imputado y no aparece en el archivo.
#
# Con el corte en P067 el bienestar salía imposible: el decil 1 daba una
# VE/ingreso de 270.8% (la VE triplicaba el ingreso) porque el corte amputaba
# ingreso monetario legítimo. Sin corte: 39.5% en el decil 1, 17.0% total,
# regresividad 6.82, reducción de Gini 8.4% — estructuralmente comparable al
# paper (30.9%, 15.7%, 4.42, 7.3%).
CORTE_MONETARIO = 999


def clave_2022(clave_numerica):
    """Convierte una clave ENIGH numérica de 2014 a la alfanumérica de 2022.

    El prefijo numérico es el índice de la letra: 1->A, 2->B, 10->J, 13->M.
    Verificado: las 73 claves de las 12 categorías existen en gastoshogar 2022.
    """
    letra = chr(ord('A') + clave_numerica // 1000 - 1)
    return f"{letra}{clave_numerica % 1000:03d}"


# Categorías derivadas de la tabla verificada de 2014 (Gauss l.1940-2035).
CATEGORIAS = [
    (nombre, [(None if claves is None else [clave_2022(c) for c in claves], prod)
              for claves, prod in comps])
    for nombre, comps in CATEGORIAS_2014
]

# P1 — pan industrial como categoría propia (desviación deliberada del Gauss).
# Catálogo ENIGH 2022: A012 pan blanco, A013 pan dulce en piezas, A014 pan
# dulce empaquetado, A015 pan para sándwich, hamburguesa, hot dog y tostado.
# El Gauss solo usa A012+A013, así que el pan de caja quedaba FUERA del estudio.
# Se agrega A015 con el genérico INPC "Pan de caja"; "Pan" conserva A012+A013
# para seguir siendo comparable con 2014. A014 se deja fuera: no tiene serie
# INPC por ciudad. Va antes de Materiales, que debe seguir siendo el numerario.
CATEGORIAS.insert(
    next(i for i, (n, _) in enumerate(CATEGORIAS) if n == 'Pan') + 1,
    ('Pan de caja', [(['A015'], 'pan_de_caja')]))

# Nombre del genérico en los archivos de precios de INEGI, por producto.
# Los genéricos de 2022 no son uno a uno con los productos de 2014: la res ya
# no se desagrega en bistec/molida/vísceras, así que varios productos comparten
# genérico. Es el mismo criterio que usa el Gauss cuando asigna la misma serie
# INPC a bistec y molida.
GENERICO = {
    'tortillas': 'Tortilla de maíz', 'pan_blanco': 'Pan blanco',
    'pan_dulce': 'Pan dulce', 'pan_de_caja': 'Pan de caja',
    'pollo_entero': 'Pollo', 'pollo_piezas': 'Pollo',
    'huevo': 'Huevo', 'bistec_res': 'Carne de res', 'molida_res': 'Carne de res',
    'visceras_res': 'Vísceras de res', 'chorizo': 'Chorizo', 'jamon': 'Jamón',
    'salchichas': 'Salchichas', 'tocino': 'Tocino',
    'leche_pasteurizada': 'Leche pasteurizada y fresca',
    'leche_en_polvo': 'Leche en polvo',
    'leche_maternizada': 'Leche evaporada, condensada y maternizada',
    'leche_condensada': 'Leche evaporada, condensada y maternizada',
    'queso_fresco': 'Queso fresco', 'queso_oaxaca': 'Queso Oaxaca o asadero',
    'queso_amarillo': 'Queso amarillo', 'crema_de_leche': 'Crema de leche',
    'mantequilla': 'Mantequilla', 'manzana': 'Manzana', 'platanos': 'Plátanos',
    'aguacate': 'Aguacate', 'papaya': 'Papaya', 'naranja': 'Naranja',
    'limon': 'Limón', 'melon': 'Melón', 'uvas': 'Uva', 'pera': 'Pera',
    'guayaba': 'Guayaba', 'sandia': 'Sandía', 'pina': 'Piña',
    'jitomate': 'Jitomate', 'papa': 'Papa y otros tubérculos',
    'cebolla': 'Cebolla', 'tomate_verde': 'Tomate verde',
    'col': 'Lechuga y col', 'lechuga': 'Lechuga y col',
    'calabacita': 'Calabacita', 'zanahoria': 'Zanahoria',
    'chile_serrano': 'Chile serrano', 'nopales': 'Nopales',
    'chayote': 'Chayote', 'chile_poblano': 'Chile poblano', 'pepino': 'Pepino',
    'ejotes': 'Ejotes', 'chicharo': 'Chícharo', 'frijol': 'Frijol',
    'jugos_nectares': 'Jugos o néctares envasados',
    'refrescos_envasados': 'Refrescos envasados',
    'agua_embotellada': 'Agua embotellada', 'antibioticos': 'Antibióticos',
    'cardiovasculares': 'Cardiovasculares', 'analgesicos': 'Analgésicos',
    'nutricionales': 'Nutricionales', 'gastrointestinales': 'Gastrointestinales',
    'antigripales': 'Antigripales',
    'medicinas_tos': 'Expectorantes y descongestivos',
    'medicinas_piel': 'Dermatológicos', 'autobus_foraneo': 'Autobús foráneo',
    'transporte_aereo': 'Transporte aéreo',
    'materiales': 'Materiales de construcción',
}


# ---------------------------------------------------------------------------
# Correspondencia ciudad INPC -> municipio, para ubicar los 46 mercados.
#
# El nombre que usa INEGI en los archivos de precios ("Cd. Juárez, Chih.") no
# coincide con NOM_MUN del archivo geográfico, y varios nombres de municipio se
# repiten entre estados (Juárez, Cuauhtémoc), así que el cruce se hace por
# nombre Y entidad: la abreviatura del estado viene en el propio nombre INEGI.
#
# 43 de las 46 ciudades emparejan por nombre; estas tres no, y su
# correspondencia es la conocida:
# ---------------------------------------------------------------------------
CIUDAD_A_MUNICIPIO = {
    'area met': ('cuauhtemoc', 'CDMX'),      # cubre "Área Met." y "Área Metropolitana"
    'chetumal': ('othon p. blanco', 'Q.R.'),
    'tehuantepec': ('santo domingo tehuantepec', 'Oax.'),
    'villahermosa': ('centro', 'Tab.'),
}


def _municipio_de_ciudad(nombre_inpc):
    """Devuelve (municipio_normalizado, abreviatura_estado) de una ciudad INPC."""
    n = _norm(nombre_inpc)
    partes = [p.strip() for p in str(nombre_inpc).split(',')]
    estado = partes[1].strip() if len(partes) > 1 else ''
    base = _norm(partes[0])
    base = re.sub(r'^(area metropolitana de la |cd\.? |ciudad )', '', base).strip()
    for clave, (mun, ent) in CIUDAD_A_MUNICIPIO.items():
        if n.startswith(_norm(clave)) or base == _norm(clave):
            return mun, ent
    return base, estado


def _norm(s):
    """Normaliza texto para comparar nombres de ciudad y de genérico."""
    s = unicodedata.normalize('NFKD', str(s))
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'\s+', ' ', s).strip().lower()
    return s


def _leer_inegi(path, skiprows=5):
    """Lee un CSV de consulta en línea de INEGI (encabezado de varias líneas)."""
    df = pd.read_csv(path, skiprows=skiprows, encoding='latin-1')
    df.columns = [c.strip() for c in df.columns]
    return df


def precios_referencia(data_dir, con_originales=False):
    """Precios promedio por ciudad y genérico del año base (data_inp_pp).

    Con `con_originales=True` devuelve además el diccionario
    ciudad_normalizada -> nombre original de INEGI, que hace falta para
    resolver el municipio (el nombre trae la abreviatura del estado).
    """
    df = pd.concat([_leer_inegi(f)
                    for f in sorted(glob.glob(data_dir + 'data_inp_pp/*.CSV'))],
                   ignore_index=True)
    df['Precio promedio'] = pd.to_numeric(df['Precio promedio'], errors='coerce')
    df = df.dropna(subset=['Precio promedio'])
    df['ciudad'] = df['Nombre ciudad'].map(_norm)
    df['generico'] = df['Genérico'].map(_norm)
    # Un precio por ciudad y genérico: mediana sobre especificaciones y meses
    precios = df.groupby(['ciudad', 'generico'])['Precio promedio'].median()
    if con_originales:
        orig = dict(zip(df['ciudad'], df['Nombre ciudad']))
        return precios, orig
    return precios



MESES = {'ene': 1, 'feb': 2, 'mar': 3, 'abr': 4, 'may': 5, 'jun': 6,
         'jul': 7, 'ago': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dic': 12}


def _serie_inpc(path):
    """Lee un CSV de INPC por ciudad y devuelve (fechas, {generico: serie}).

    El encabezado de INEGI es una ruta de clasificación larga; el producto es
    el último segmento, con la forma "NNN Nombre". Se reutiliza el criterio de
    `inpc_lista_productos.target_columns`, que Victor ya había resuelto.
    """
    df = pd.read_csv(path, skiprows=5, encoding='latin-1', low_memory=False)
    fila_fecha = df.index[df.iloc[:, 0].astype(str).str.strip() == 'Fecha']
    ini = (fila_fecha[0] + 1) if len(fila_fecha) else 2
    cuerpo = df.iloc[ini:].copy()

    etiquetas = {}
    for col in df.columns[1:]:
        cola = str(col).split(',')[-1].strip()
        m = re.match(r'^\d+\s+(.*)$', cola)
        if m:
            etiquetas.setdefault(_norm(m.group(1)), col)

    fechas = []
    for v in cuerpo.iloc[:, 0].astype(str):
        partes = v.strip().strip('"').split()
        if len(partes) == 2 and _norm(partes[0])[:3] in MESES:
            fechas.append(int(partes[1]) + MESES[_norm(partes[0])[:3]] / 100)
        else:
            fechas.append(np.nan)
    fechas = np.array(fechas, dtype=float)

    series = {}
    for gen, col in etiquetas.items():
        series[gen] = pd.to_numeric(cuerpo[col], errors='coerce').to_numpy(float)
    return fechas, series


def deflactar_precios(data_dir, pref, ciudades, ciudades_orig, verbose=True):
    """Lleva los precios de referencia de julio 2018 a la ventana ago-nov 2022.

        P_2022 = P_jul2018 * mediana(INPC_t / INPC_jul2018),  t en ago-nov 2022

    Misma lógica que el Gauss para 2014 (l.560-660), cambiando el mes base.
    """
    from inpc_lista_productos import mapping_ciudades_inpc
    slug = {_norm(k): v for k, v in mapping_ciudades_inpc.items()}

    factores = {}
    sin_serie = []
    for c in ciudades:
        nombre = ciudades_orig[c]
        arch = slug.get(_norm(nombre))
        if arch is None:      # variantes del sufijo estatal ("Q.R." vs "Q. Roo.")
            base = _norm(str(nombre).split(',')[0])
            arch = next((v for k, v in slug.items()
                         if _norm(k).split(',')[0] == base), None)
        ruta = data_dir + f'data_ciudades/{arch}.CSV' if arch else None
        if not ruta or not glob.glob(ruta):
            sin_serie.append(nombre)
            continue
        fechas, series = _serie_inpc(ruta)
        base = np.isclose(fechas, ANIO_BASE + MES_BASE / 100)      # N16
        vent = (fechas >= ANIO_ENIGH + MES_INI / 100) & (fechas <= ANIO_ENIGH + MES_FIN / 100)
        for gen, serie in series.items():
            # Series sin dato en el mes base o en la ventana: se omiten (sin
            # np.nanmedian sobre vacíos, que llena la salida de advertencias)
            b, v = serie[base], serie[vent]
            b, v = b[np.isfinite(b)], v[np.isfinite(v)]
            if b.size and v.size and np.median(b) > 0:
                factores[(c, gen)] = float(np.median(v) / np.median(b))
    if verbose:
        if sin_serie:
            print(f'  sin serie INPC ({len(sin_serie)}): {sin_serie[:3]}...')
        f = np.array(list(factores.values()))
        print(f'  factores de deflactación 2018->2022: mediana={np.median(f):.3f} '
              f'[{f.min():.2f}, {f.max():.2f}]  ({len(factores)} pares)')
    return factores



def precios_materiales(data_dir, ciudades, ciudades_orig, base=100.0, verbose=True):
    """Índice de materiales de construcción por ciudad, deflactado con INPP.

    En 2014 los materiales parten de un índice 100 y se deflactan con el INPP
    de construcción de cada ciudad, lo que les da variación transversal
    (103.94-122.56). Sin esa variación, Materiales -que es la ÚLTIMA categoría
    y por tanto el numerario del sistema (q = p - p_ultima)- queda constante
    entre ciudades y degrada la identificación.
    """
    # El INPP no usa el formato "NNN Nombre" de los genéricos: sus columnas
    # terminan directamente en el nombre de la ciudad, así que se parsea aparte.
    df = pd.read_csv(data_dir + 'inpp_construccion.CSV', skiprows=5,
                     encoding='latin-1', low_memory=False)
    fila = df.index[df.iloc[:, 0].astype(str).str.strip() == 'Fecha']
    cuerpo = df.iloc[(fila[0] + 1) if len(fila) else 2:].copy()

    fechas = []
    for v in cuerpo.iloc[:, 0].astype(str):
        partes = v.strip().strip('"').split()
        fechas.append(int(partes[1]) + MESES[_norm(partes[0])[:3]] / 100
                      if len(partes) == 2 and _norm(partes[0])[:3] in MESES else np.nan)
    fechas = np.array(fechas, dtype=float)

    # OJO: el nombre de ciudad CONTIENE una coma ("Mérida, Yuc."), así que
    # cortar por la última deja solo la abreviatura del estado. Se toman los
    # dos últimos segmentos cuando el final parece abreviatura estatal.
    idx = {}
    for col in df.columns[1:]:
        partes = [x.strip() for x in str(col).split(',')]
        ultimo = partes[-1]
        nombre = (', '.join(partes[-2:]) if len(partes) >= 2 and len(ultimo) <= 6
                  and ultimo.endswith('.') else ultimo)
        idx.setdefault(nombre, pd.to_numeric(cuerpo[col], errors='coerce')
                       .to_numpy(float))

    P = np.full(len(ciudades), np.nan)
    base_m = np.isclose(fechas, ANIO_BASE + MES_BASE / 100)        # N16
    vent = (fechas >= ANIO_ENIGH + MES_INI / 100) & (fechas <= ANIO_ENIGH + MES_FIN / 100)
    for i, c in enumerate(ciudades):
        nom = _norm(str(ciudades_orig[c]).split(',')[0])
        cand = next((k for k in idx if _norm(k).split(',')[0] == nom), None)
        if cand is None:
            cand = next((k for k in idx if nom in _norm(k)), None)
        if cand is None:
            continue
        serie = idx[cand]
        b, v = serie[base_m], serie[vent]
        b, v = b[np.isfinite(b)], v[np.isfinite(v)]
        if b.size and v.size and np.median(b) > 0:
            P[i] = base * (np.median(v) / np.median(b))
    faltan = int(np.isnan(P).sum())
    if faltan:
        P = np.where(np.isnan(P), np.nanmedian(P), P)
    if verbose:
        print(f'  materiales (INPP): [{P.min():.1f}, {P.max():.1f}]'
              f'{f"  ({faltan} ciudades imputadas)" if faltan else ""}')
    return P


def _hogar_id(df):
    return df['folioviv'].astype(str) + '_' + df['foliohog'].astype(str)


def ingreso_monetario(data_dir, hogares, corte=CORTE_MONETARIO):
    """Reconstruye `ing_mon` sumando las claves monetarias de ingresos.csv.

    Devuelve una serie alineada con `hogares` (ids folioviv_foliohog).
    Ver `CORTE_MONETARIO`: por defecto se usan todas las claves.
    """
    ing = pd.read_csv(data_dir + 'ingresos.csv',
                      usecols=['folioviv', 'foliohog', 'clave', 'ing_tri'],
                      dtype={'folioviv': str, 'clave': str})
    ing['ing_tri'] = pd.to_numeric(ing['ing_tri'], errors='coerce').fillna(0)
    ing['num'] = ing['clave'].str.extract(r'[A-Z](\d+)').astype(float)
    ing = ing[ing['num'] <= corte]
    s = ing.assign(hog=_hogar_id(ing)).groupby('hog')['ing_tri'].sum()
    return s.reindex(hogares).fillna(0.0).to_numpy()


def cargar(data_dir, corte_monetario=CORTE_MONETARIO, verbose=True):
    """Carga la ENIGH 2022 y devuelve un `DatosAnio`.

    `corte_monetario` fija hasta qué clave P### se considera ingreso monetario;
    se expone como argumento para poder reproducir la prueba con P067.
    """
    if not data_dir.endswith('/'):
        data_dir += '/'

    conc = pd.read_csv(data_dir + 'concentradohogar.csv', dtype={'folioviv': str})
    conc.columns = [c.strip().lstrip('﻿') for c in conc.columns]
    conc['hog'] = _hogar_id(conc)
    num = ['factor', 'tam_loc', 'clase_hog', 'edad_jefe', 'educa_jefe',
           'tot_integ', 'menores', 'ing_cor', 'gasto_mon', 'mater_serv']
    for c in num:
        conc[c] = pd.to_numeric(conc[c], errors='coerce').fillna(0)

    # ing_mon reconstruido, sobre la muestra COMPLETA (lo pide el Gini, N10)
    ing_mon_todos = ingreso_monetario(data_dir, conc['hog'], corte_monetario)
    ing_cor_todos = conc['ing_cor'].to_numpy(float)
    if verbose:
        r = ing_mon_todos.sum() / conc['ing_cor'].sum()
        print(f'ing_mon reconstruido (corte P{corte_monetario:03d}): '
              f'razón ing_mon/ing_cor = {r:.3f}   [2014: 0.794]')

    # --- filtros de muestra (Gauss l.1101) ---------------------------------
    viv = pd.read_csv(data_dir + 'viviendas.csv', dtype={'folioviv': str},
                      low_memory=False)
    viv.columns = [c.strip().lstrip('﻿') for c in viv.columns]
    viv['tenencia'] = pd.to_numeric(viv['tenencia'], errors='coerce')
    propias = set(viv.loc[viv['tenencia'].isin([3, 4]), 'folioviv'])

    mask = (conc['folioviv'].isin(propias)
            & (conc['clase_hog'] <= 5)
            & conc['edad_jefe'].between(20, 75)
            & (conc['tot_integ'] <= 8)
            & (conc['gasto_mon'] >= conc['gasto_mon'].quantile(0.001)))
    conc = conc[mask].reset_index(drop=True)
    ing_mon = ing_mon_todos[mask.to_numpy()]
    if verbose:
        print(f'Hogares después de filtros básicos: {len(conc)}')

    # --- geografía y ciudad más cercana ------------------------------------
    geo = pd.read_csv(data_dir + 'datos_geograficos_municipios.csv',
                      dtype={'CVE_ENT': str, 'CVE_MUN': str})
    geo['clave'] = geo['CVE_ENT'] + geo['CVE_MUN']
    geo = geo.dropna(subset=['LAT_DECIMAL', 'LON_DECIMAL'])
    cent = geo.groupby('clave')[['LAT_DECIMAL', 'LON_DECIMAL']].first()

    conc['clave_mun'] = conc['ubica_geo'].astype(str).str.zfill(5).str[:5]
    lat = conc['clave_mun'].map(cent['LAT_DECIMAL']).to_numpy(dtype=float)
    lon = conc['clave_mun'].map(cent['LON_DECIMAL']).to_numpy(dtype=float)

    pref, ciudades_orig = precios_referencia(data_dir, con_originales=True)
    ciudades = sorted(pref.index.get_level_values('ciudad').unique())

    # Coordenadas de cada ciudad INPC: municipio + entidad (ver
    # CIUDAD_A_MUNICIPIO). Se pondera por población para quedarse con la
    # cabecera cuando el municipio tiene varias localidades.
    geo['pob'] = pd.to_numeric(geo['POB_TOTAL'], errors='coerce').fillna(0)
    geo['mun_n'] = geo['NOM_MUN'].map(_norm)
    geo['ent_n'] = geo['NOM_ABR'].map(lambda x: _norm(x).replace('.', ''))
    cab = (geo.sort_values('pob', ascending=False)
              .groupby(['ent_n', 'mun_n'])[['LAT_DECIMAL', 'LON_DECIMAL', 'clave']].first())

    # cd_clave: clave INEGI de municipio (ent+mun) de cada ciudad, para cruzar
    # los Censos Económicos por municipio y no por posición (N15)
    cd_lat, cd_lon, cd_clave, sin_coord = [], [], [], []
    for c in ciudades:
        mun, ent = _municipio_de_ciudad(ciudades_orig[c])
        ent_n = _norm(ent).replace('.', '')
        fila = None
        if (ent_n, mun) in cab.index:
            fila = cab.loc[(ent_n, mun)]
        elif ent_n in cab.index.get_level_values('ent_n'):
            # nombre corto de INEGI ("Oaxaca, Oax.") contra el municipio
            # completo ("Oaxaca de Juárez"): buscar por prefijo en la entidad
            en_ent = cab.xs(ent_n, level='ent_n')
            # Primero palabra completa: "iguala" debe dar "iguala de la
            # independencia", no "igualapa" (otro municipio, más corto).
            pre = ([m for m in en_ent.index if m.startswith(mun + ' ')]
                   or [m for m in en_ent.index if m.startswith(mun)])
            if pre:
                fila = en_ent.loc[sorted(pre, key=len)[0]]
        if fila is None and mun in cab.index.get_level_values('mun_n'):
            cand = cab.xs(mun, level='mun_n', drop_level=False)
            fila = cand.iloc[0] if len(cand) == 1 else None
        if fila is None:
            sin_coord.append(c)
            cd_lat.append(np.nan); cd_lon.append(np.nan); cd_clave.append(None)
        else:
            cd_lat.append(float(fila['LAT_DECIMAL']))
            cd_lon.append(float(fila['LON_DECIMAL']))
            cd_clave.append(str(fila['clave']))
    if sin_coord:
        raise ValueError(f"ciudades INPC sin coordenadas: {sin_coord}")
    if verbose:
        print(f'Coordenadas resueltas para las {len(ciudades)} ciudades INPC.')
    cd_lat = np.radians(np.array(cd_lat))
    cd_lon = np.radians(np.array(cd_lon))
    lat_r, lon_r = np.radians(lat), np.radians(lon)

    arg = (np.sin(lat_r)[:, None] * np.sin(cd_lat)[None, :]
           + np.cos(lat_r)[:, None] * np.cos(cd_lat)[None, :]
           * np.cos(cd_lon[None, :] - lon_r[:, None]))
    dist = np.arccos(np.clip(arg, -1, 1)) * 6371
    dist = np.where(np.isnan(dist), np.inf, dist)
    ciudad = dist.argmin(axis=1)
    cerca = dist.min(axis=1) <= 400
    conc, ciudad, ing_mon = conc[cerca].reset_index(drop=True), ciudad[cerca], ing_mon[cerca]
    if verbose:
        print(f'Hogares después de filtro de distancia (<=400 km): {len(conc)}')

    # --- precios por ciudad y producto -------------------------------------
    # Precios de referencia 2018 deflactados a ago-nov 2022 con la serie INPC
    # de cada ciudad (`data_ciudades/`).
    factores = deflactar_precios(data_dir, pref, ciudades, ciudades_orig, verbose)
    fac_global = float(np.median(list(factores.values()))) if factores else 1.0

    P_ciudad = {}
    for prod, gen in GENERICO.items():
        if prod == 'materiales':
            # Materiales de construcción no cotiza en el archivo de precios:
            # va por INPP, igual que en 2014, donde la referencia es índice 100.
            P_ciudad[prod] = precios_materiales(
                data_dir, ciudades, ciudades_orig, verbose=verbose)
            continue
        g = _norm(gen)
        P_ciudad[prod] = np.array([
            pref.get((c, g), np.nan) for c in ciudades], dtype=float)
        if np.isnan(P_ciudad[prod]).all():
            raise ValueError(f"sin precios para el genérico {gen!r} ({prod})")
        # ciudades sin cotización del producto: se imputa la mediana nacional.
        # Imputar en muchas ciudades borra la variación transversal que
        # identifica β_η, así que se avisa (caso: pan de caja, ver P1).
        faltan = int(np.isnan(P_ciudad[prod]).sum())
        if verbose and faltan > 5:
            print(f'  ⚠ {prod}: precio imputado (mediana) en {faltan} de '
                  f'{len(ciudades)} ciudades')
        med = np.nanmedian(P_ciudad[prod])
        P_ciudad[prod] = np.where(np.isnan(P_ciudad[prod]), med, P_ciudad[prod])
        # deflactar 2018 -> ago-nov 2022 con la serie INPC de cada ciudad
        fac = np.array([factores.get((c, g), np.nan) for c in ciudades])
        fac = np.where(np.isnan(fac), np.nanmedian(fac) if np.isfinite(fac).any()
                       else fac_global, fac)
        P_ciudad[prod] = P_ciudad[prod] * fac

    # --- gasto por producto -------------------------------------------------
    quiero = {c for _, comps in CATEGORIAS for cl, _ in comps if cl for c in cl}
    acum = {}
    for archivo, cols in (('gastoshogar.csv', ['folioviv', 'foliohog', 'clave', 'gasto_tri']),
                          ('gastospersona.csv', ['folioviv', 'foliohog', 'clave', 'gasto_tri'])):
        g = pd.read_csv(data_dir + archivo, usecols=cols,
                        dtype={'folioviv': str, 'clave': str})
        g = g[g['clave'].isin(quiero)]
        g['gasto_tri'] = pd.to_numeric(g['gasto_tri'], errors='coerce').fillna(0)
        g['hog'] = _hogar_id(g)
        s = g.groupby(['hog', 'clave'])['gasto_tri'].sum()
        for (h, c), v in s.items():
            acum[(h, c)] = acum.get((h, c), 0.0) + v

    hogs = conc['hog'].to_numpy()
    pos = {h: i for i, h in enumerate(hogs)}
    por_clave = {c: np.zeros(len(hogs)) for c in quiero}
    for (h, c), v in acum.items():
        i = pos.get(h)
        if i is not None:
            por_clave[c][i] += v

    gastos_producto = {}
    for _, comps in CATEGORIAS:
        for claves, prod in comps:
            bruto = (conc['mater_serv'].to_numpy(dtype=float) if claves is None
                     else np.sum([por_clave[c] for c in claves], axis=0))
            gastos_producto[prod] = np.where(bruto > 0, bruto, EPS)

    precios_producto = {p: P_ciudad[p][ciudad] for p in gastos_producto}

    # --- categorías e índices Divisia --------------------------------------
    from aradillas_core import divisia_price_index

    composicion = {nom: [p for _, p in comps] for nom, comps in CATEGORIAS}
    n_cat = len(CATEGORIAS)
    gastos_cat = np.zeros((len(conc), n_cat))
    precios_cat = np.zeros((len(conc), n_cat))
    for j, (nom, comps) in enumerate(CATEGORIAS):
        prods = [p for _, p in comps]
        gastos_cat[:, j] = np.sum([gastos_producto[p] for p in prods], axis=0)
        precios_cat[:, j] = divisia_price_index(
            [gastos_producto[p] for p in prods],
            [precios_producto[p] for p in prods])

    rel = (gastos_cat >= 10).sum(axis=1) >= 1
    conc = conc[rel].reset_index(drop=True)
    ciudad, ing_mon = ciudad[rel], ing_mon[rel]
    gastos_cat, precios_cat = gastos_cat[rel], precios_cat[rel]
    gastos_producto = {k: v[rel] for k, v in gastos_producto.items()}
    precios_producto = {k: v[rel] for k, v in precios_producto.items()}
    if verbose:
        print(f'Hogares finales en la muestra: {len(conc)}')

    gasto_total = gastos_cat.sum(axis=1)
    w = gastos_cat / gasto_total[:, None]

    # --- variables Z --------------------------------------------------------
    hog = pd.read_csv(data_dir + 'hogares.csv', dtype={'folioviv': str})
    hog.columns = [c.strip().lstrip('﻿') for c in hog.columns]
    hog['hog'] = _hogar_id(hog)
    for c in ('num_lavad', 'num_auto', 'num_van', 'num_pickup'):
        hog[c] = pd.to_numeric(hog[c], errors='coerce').fillna(0)
    hog = hog.set_index('hog')
    lav = (hog['num_lavad'].reindex(conc['hog']).fillna(0) > 0).to_numpy(float)
    veh = ((hog[['num_auto', 'num_van', 'num_pickup']].sum(axis=1)
            .reindex(conc['hog']).fillna(0)) > 0).to_numpy(float)

    Z1 = conc['educa_jefe'].to_numpy(float)
    Z2 = conc['tot_integ'].to_numpy(float)
    Z4 = conc['menores'].to_numpy(float)
    # Z5 usa ing_cor: la ENIGH 2022 ya no publica ing_total (Nueva serie)
    Z5 = (conc['ing_cor'] >= conc['ing_cor'].quantile(0.8)).to_numpy(float)
    Z = np.column_stack([Z1, Z2, Z1 * Z2, Z4, Z5, Z1 * Z4, Z1 ** 2,
                         (conc['tam_loc'] == 4).to_numpy(float), veh * lav])

    # --- variables de costo (Censos Económicos) -----------------------------
    vars_costos = _vars_costos(data_dir, cd_clave,
                               [ciudades_orig[c] for c in ciudades], verbose)

    datos = DatosAnio(
        anio=2022, n_cat=n_cat,
        nombres_cat=[n for n, _ in CATEGORIAS],
        precios_ln=np.log(precios_cat), w=w, gasto_total=gasto_total,
        gastos_cat=gastos_cat, Z=Z,
        factor_expansion=conc['factor'].to_numpy(float), ciudad=ciudad,
        ingreso_mon=ing_mon,
        ingreso_cor=conc['ing_cor'].to_numpy(float),
        ingreso_cor_completo=ing_cor_todos,
        n_ciudades=len(ciudades), vars_costos=vars_costos,
        precios_producto_ciudad=P_ciudad,
        gastos_producto=gastos_producto, composicion=composicion,
        ingreso_mon_completo=ing_mon_todos,
        subcat={'g_autobus': gastos_producto['autobus_foraneo'],
                'g_aereo': gastos_producto['transporte_aereo'],
                'p_autobus': precios_producto['autobus_foraneo'],
                'p_aereo': precios_producto['transporte_aereo']},
    )
    if verbose:
        print(datos.resumen())
    return datos


def _vars_costos(data_dir, claves_ciudad, nombres=None, verbose=True):
    """Variables de costo por ciudad, de los Censos Económicos (año censal 2023).

    Mismas siete variables que en 2014 (Gauss l.6205), en el mismo orden:
    producción bruta por UE, unidades económicas, personal ocupado por UE,
    remuneraciones por UE, consumo intermedio por UE, activos fijos por UE y
    depreciación por UE.

    CORRECCIÓN N15: se cruza por clave de municipio y por código de variable.
    La versión anterior leía con `skiprows=13` (perdía los ocho primeros
    municipios), tomaba columnas por posición (cuatro de las siete variables
    eran otras) y asignaba filas por orden: ninguna de las 46 ciudades recibía
    sus propios datos. Fresnillo viene en archivo aparte y con otro orden de
    columnas, por eso se lee por nombre.

    Una ciudad sin fila municipal usa el total de su entidad, si existe. Es el
    caso del Área Metropolitana de la Cd. de México: el Gauss de 2014 usa el total
    de la entidad (≈415 mil UE), y `censo_economico_2023.csv` trae CDMX solo como
    "Total estatal" (425,005 UE), que la versión anterior descartaba al filtrar
    únicamente "Total municipal". Verificado idéntico a una consulta directa a
    SAIC (7 de 7 variables).
    """
    tablas = []
    for arch in ('censo_economico_2023.csv', 'censo_economico_fresnillo_2023.csv'):
        df = pd.read_csv(data_dir + arch, skiprows=4, encoding='utf-8-sig')
        act = df['Actividad económica'].astype(str)
        df = df[act.str.contains('Total municipal|Total estatal', na=False)]
        # municipio: ent+mun (5 dígitos); total estatal: solo ent (2 dígitos)
        estatal = df['Actividad económica'].astype(str).str.contains('Total estatal')
        clave = df['Entidad'].astype(str).str[:2] + np.where(
            estatal, '', df['Municipio'].astype(str).str[:3])
        # "A111A Producción bruta total (millones de pesos)" -> "A111A"
        df = df.rename(columns={c: str(c).split(' ')[0] for c in df.columns})
        tablas.append(df.assign(clave=clave).set_index('clave'))
    cols = ['A111A', 'UE', 'H001A', 'J000A', 'A121A', 'Q000A', 'Q000B']
    censo = pd.concat(tablas)[cols].apply(pd.to_numeric, errors='coerce')

    claves = [c if c in censo.index or c is None or c[:2] not in censo.index else c[:2]
              for c in claves_ciudad]
    estatales = [i for i, (a, b) in enumerate(zip(claves_ciudad, claves)) if a != b]
    M = censo.reindex(claves)
    UE = M['UE']
    with np.errstate(divide='ignore', invalid='ignore'):
        X = np.column_stack([M['A111A'] / UE, UE, M['H001A'] / UE, M['J000A'] / UE,
                             M['A121A'] / UE, M['Q000A'] / UE, M['Q000B'] / UE]).astype(float)
    X = np.where(np.isfinite(X), X, np.nan)
    faltan = np.isnan(X).any(axis=1)
    if faltan.any():
        X = np.where(np.isnan(X), np.nanmedian(X, axis=0), X)
    if verbose:
        nom = nombres or [str(c) for c in claves_ciudad]
        msj = f'  variables de costo: censo propio en {int((~faltan).sum())} de {len(X)} ciudades'
        if estatales:
            msj += f'; total estatal en {[nom[i] for i in estatales]}'
        if faltan.any():
            msj += f'; mediana imputada en {[nom[i] for i in np.flatnonzero(faltan)]}'
        print(msj)
    return X
