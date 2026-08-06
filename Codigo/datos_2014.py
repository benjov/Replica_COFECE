"""
Capa de datos de la ENIGH 2014 — secciones 1 y 2 del pipeline.

Lee los archivos .asc del CD de COFECE y entrega un `DatosAnio` listo para
`aradillas_core`. Fuente de verdad: CD/programa_ENIGH_2014.g.

Correcciones incorporadas: N4 (columnas del archivo de precios de referencia).
"""

from collections import defaultdict

import numpy as np

from datos_base import DatosAnio

# ---------------------------------------------------------------------------
# Períodos de deflactación (Gauss l.5837 y ss.)
# ---------------------------------------------------------------------------
FECHA_BASE = 2011.06        # los precios de referencia son de junio 2011
FECHA_INI = 2014.08         # ventana de levantamiento de la ENIGH 2014
FECHA_FIN = 2014.11
N_CIUDADES = 46
EPS = 0.01                  # piso de gasto por producto (Gauss l.1766)

# ---------------------------------------------------------------------------
# Columnas del INPC (Gauss l.290-355): 61 subgéneros contiguos, cols 6-66
# ---------------------------------------------------------------------------
INPC_COLS = [
    'tortilla', 'pan_dulce', 'pan_blanco', 'pollo', 'carne_res',
    'visceras_res', 'chorizo', 'jamon', 'salchichas', 'tocino',
    'leche_pasteurizada', 'leche_en_polvo', 'leche_evaporada',
    'queso_fresco', 'queso_oaxaca', 'crema_de_leche', 'queso_manchego',
    'mantequilla', 'queso_amarillo', 'huevo',
    'manzana', 'platano', 'aguacate', 'papaya', 'naranja', 'limon',
    'melon', 'uva', 'pera', 'guayaba', 'durazno', 'sandia', 'pina',
    'jitomate', 'papa', 'cebolla', 'tomate_verde', 'lechuga_col',
    'calabacita', 'zanahoria', 'chile_serrano', 'nopales', 'chayote',
    'chile_poblano', 'pepino', 'ejotes', 'chicharo', 'frijol',
    'jugos_nectares', 'refrescos', 'agua_embotellada',
    'antibioticos', 'cardiovasculares', 'analgesicos', 'nutricionales',
    'gastrointestinales', 'antigripales', 'medicina_tos', 'medicina_piel',
    'autobus_foraneo', 'transporte_aereo',
]

# ---------------------------------------------------------------------------
# CORRECCIÓN N4: las columnas del archivo de precios de referencia NO son
# contiguas. El Gauss (l.431-495) salta las columnas 62, 65 y 66. Leerlas de
# corrido desplazaba 6 productos; el peor caso era transporte aéreo, que tomaba
# 138 pesos (col 67) en vez de 2,279 (col 70). Índices en base 1.
# ---------------------------------------------------------------------------
REF_COL_GAUSS = {
    'tortillas': 5, 'pan_blanco': 6, 'pan_dulce': 7, 'pollo_entero': 8,
    'pollo_piezas': 9, 'huevo': 10, 'bistec_res': 11, 'molida_res': 12,
    'visceras_res': 13, 'chorizo': 14, 'jamon': 15, 'salchichas': 16,
    'tocino': 17, 'leche_pasteurizada': 18, 'leche_en_polvo': 19,
    'leche_maternizada': 20, 'leche_condensada': 21, 'queso_fresco': 22,
    'queso_oaxaca': 23, 'queso_amarillo': 24, 'crema_de_leche': 25,
    'mantequilla': 26, 'manzana': 27, 'platanos': 28, 'aguacate': 29,
    'papaya': 30, 'naranja': 31, 'limon': 32, 'melon': 33, 'uvas': 34,
    'pera': 35, 'guayaba': 36, 'sandia': 37, 'pina': 38, 'jitomate': 39,
    'papa': 40, 'cebolla': 41, 'tomate_verde': 42, 'col': 43, 'lechuga': 44,
    'calabacita': 45, 'zanahoria': 46, 'chile_serrano': 47, 'nopales': 48,
    'chayote': 49, 'chile_poblano': 50, 'pepino': 51, 'ejotes': 52,
    'chicharo': 53, 'frijol': 54, 'jugos_nectares': 55,
    'refrescos_envasados': 56, 'agua_embotellada': 57, 'antibioticos': 58,
    'cardiovasculares': 59, 'analgesicos': 60, 'nutricionales': 61,
    'gastrointestinales': 63, 'antigripales': 64, 'medicinas_tos': 67,
    'medicinas_piel': 68, 'autobus_foraneo': 69, 'transporte_aereo': 70,
}

# Qué serie del INPC deflacta cada producto (Gauss l.560-660)
PRECIO_A_INPC = {
    'tortillas': 'tortilla', 'pan_blanco': 'pan_blanco', 'pan_dulce': 'pan_dulce',
    'pollo_entero': 'pollo', 'pollo_piezas': 'pollo', 'huevo': 'huevo',
    'bistec_res': 'carne_res', 'molida_res': 'carne_res',
    'visceras_res': 'visceras_res', 'chorizo': 'chorizo', 'jamon': 'jamon',
    'salchichas': 'salchichas', 'tocino': 'tocino',
    'leche_pasteurizada': 'leche_pasteurizada', 'leche_en_polvo': 'leche_en_polvo',
    'leche_maternizada': 'leche_evaporada', 'leche_condensada': 'leche_evaporada',
    'queso_fresco': 'queso_fresco', 'queso_oaxaca': 'queso_oaxaca',
    'queso_amarillo': 'queso_amarillo', 'crema_de_leche': 'crema_de_leche',
    'mantequilla': 'mantequilla', 'manzana': 'manzana', 'platanos': 'platano',
    'aguacate': 'aguacate', 'papaya': 'papaya', 'naranja': 'naranja',
    'limon': 'limon', 'melon': 'melon', 'uvas': 'uva', 'pera': 'pera',
    'guayaba': 'guayaba', 'sandia': 'sandia', 'pina': 'pina',
    'jitomate': 'jitomate', 'papa': 'papa', 'cebolla': 'cebolla',
    'tomate_verde': 'tomate_verde', 'col': 'lechuga_col', 'lechuga': 'lechuga_col',
    'calabacita': 'calabacita', 'zanahoria': 'zanahoria',
    'chile_serrano': 'chile_serrano', 'nopales': 'nopales', 'chayote': 'chayote',
    'chile_poblano': 'chile_poblano', 'pepino': 'pepino', 'ejotes': 'ejotes',
    'chicharo': 'chicharo', 'frijol': 'frijol', 'jugos_nectares': 'jugos_nectares',
    'refrescos_envasados': 'refrescos', 'agua_embotellada': 'agua_embotellada',
    'antibioticos': 'antibioticos', 'cardiovasculares': 'cardiovasculares',
    'analgesicos': 'analgesicos', 'nutricionales': 'nutricionales',
    'gastrointestinales': 'gastrointestinales', 'antigripales': 'antigripales',
    'medicinas_tos': 'medicina_tos', 'medicinas_piel': 'medicina_piel',
    'autobus_foraneo': 'autobus_foraneo', 'transporte_aereo': 'transporte_aereo',
}

# ---------------------------------------------------------------------------
# Las 12 categorías de demanda: nombre -> [(claves ENIGH, producto de precio)].
# Verificado contra el Gauss l.1940-2035. Ojo: el aguacate va en VERDURAS y la
# pera en FRUTAS (en productos.py, que usa el notebook 2022, están al revés
# — bug N7).
# ---------------------------------------------------------------------------
CATEGORIAS = [
    ("Tortillas", [([1004], 'tortillas')]),
    ("Pan", [([1012], 'pan_blanco'), ([1013], 'pan_dulce')]),
    ("Pollo+Huevo", [([1059], 'pollo_entero'), ([1057], 'pollo_piezas'),
                     ([1093], 'huevo')]),
    ("Carne res", [([1025], 'bistec_res'), ([1034], 'molida_res'),
                   ([1037], 'visceras_res')]),
    ("Carnes proc.", [([1049], 'chorizo'), ([1052], 'jamon'),
                      ([1055], 'salchichas'), ([1054], 'tocino')]),
    ("Lácteos", [([1075], 'leche_pasteurizada'), ([1078], 'leche_en_polvo'),
                 ([1079], 'leche_maternizada'), ([1076], 'leche_condensada'),
                 ([1085], 'queso_fresco'), ([1087], 'queso_oaxaca'),
                 ([1082], 'queso_amarillo'), ([1089], 'crema_de_leche'),
                 ([1090], 'mantequilla')]),
    ("Frutas", [([1158], 'manzana'), ([1166], 'platanos'), ([1161], 'papaya'),
                ([1160], 'naranja'), ([1154], 'limon'), ([1159], 'melon'),
                ([1169], 'uvas'), ([1162], 'pera'), ([1152], 'guayaba'),
                ([1168], 'sandia'), ([1163], 'pina')]),
    ("Verduras", [([1108], 'aguacate'), ([1124], 'jitomate'), ([1102], 'papa'),
                  ([1112], 'cebolla'), ([1129], 'tomate_verde'), ([1120], 'col'),
                  ([1125], 'lechuga'), ([1111], 'calabacita'),
                  ([1130], 'zanahoria'), ([1117], 'chile_serrano'),
                  ([1126], 'nopales'), ([1113], 'chayote'),
                  ([1116], 'chile_poblano'), ([1127], 'pepino'),
                  ([1121], 'ejotes'), ([1114], 'chicharo'), ([1137], 'frijol')]),
    ("Bebidas", [([1218], 'jugos_nectares'), ([1220], 'refrescos_envasados'),
                 ([1215], 'agua_embotellada')]),
    ("Medicamentos", [([10028, 10052], 'antibioticos'),
                      ([10031, 10056], 'cardiovasculares'),
                      ([10026, 10050], 'analgesicos'),
                      ([10033, 10055], 'nutricionales'),
                      ([10020, 10044], 'gastrointestinales'),
                      ([10021, 10045], 'antigripales'),
                      ([10024, 10048], 'medicinas_tos'),
                      ([10022, 10046], 'medicinas_piel')]),
    ("Transporte foráneo", [([2002, 2006], 'autobus_foraneo'),
                            ([13001, 13003], 'transporte_aereo')]),
    ("Materiales", [(None, 'materiales')]),   # viene del concentrado, col 121
]

# Columnas del concentrado (Gauss l.20-40), en base 0
COL_FACTOR = 6        # factor_hog  (col 7)
COL_TAM_LOC = 2       # tam_loc     (col 3)
COL_CLASE_HOG = 7     # clase_hog   (col 8)
COL_EDAD_JEFE = 9     # edad_jefe   (col 10)
COL_EDUCA_JEFE = 10   # educa_jefe  (col 11)
COL_TOT_INTEG = 11    # tot_integ   (col 12)
COL_MENORES = 15      # menores     (col 16)
COL_ING_TOTAL = 21    # ing_total   (col 22)
COL_ING_COR = 22      # ing_cor     (col 23)  <- base comparable entre años
COL_ING_MON = 23      # ing_mon     (col 24)  <- base del Gini y de la VE (N10/N11)
COL_GASTO_MON = 65    # gasto_mon   (col 66)
COL_MATERIALES = 120  # mater_serv  (col 121)
COL_ESTADO = 130      # entidad     (col 131)
COL_MUNICIPIO = 131   # municipio   (col 132)


def _deflactar(precio_base, serie, est, mun, est_i, mun_i, fecha,
               f_base=FECHA_BASE, f_ini=FECHA_INI, f_fin=FECHA_FIN):
    """P_2014 = P_jun2011 · mediana(INPC_t / INPC_jun2011), t en la ventana."""
    ciudad = (est == est_i) & (mun == mun_i)
    periodo = (fecha >= f_ini) & (fecha <= f_fin)
    v_per = serie[ciudad & periodo]
    v_ref = serie[ciudad & (fecha == f_base)]
    if len(v_per) == 0 or len(v_ref) == 0 or v_ref[0] == 0:
        return np.nan
    return precio_base * np.median(v_per / v_ref[0])


def _precios_por_ciudad(data_dir):
    """Sección 1: precios de los 46 mercados, en pesos de ago-nov 2014."""
    inpc = np.loadtxt(data_dir + 'inpc_46_ciudades.asc')
    inpp = np.loadtxt(data_dir + 'inpp_construccion_46_ciudades.asc')
    ref = np.loadtxt(data_dir + 'precios_promedio_46_ciudades_junio_2011.asc')

    inpc_fecha, inpc_est, inpc_mun = inpc[:, 0], inpc[:, 1], inpc[:, 2]
    inpc_data = {c: inpc[:, 5 + i] for i, c in enumerate(INPC_COLS)}

    ref_est, ref_mun = ref[:, 0], ref[:, 1]
    ref_lat, ref_lon = ref[:, 2] * np.pi / 180, ref[:, 3] * np.pi / 180
    ref_data = {p: ref[:, c - 1] for p, c in REF_COL_GAUSS.items()}   # N4
    ref_data['materiales'] = np.full(N_CIUDADES, 100.0)

    P46 = {}
    for prod in REF_COL_GAUSS:
        serie = inpc_data[PRECIO_A_INPC[prod]]
        P46[prod] = np.array([
            _deflactar(ref_data[prod][i], serie, inpc_est, inpc_mun,
                       ref_est[i], ref_mun[i], inpc_fecha)
            for i in range(N_CIUDADES)])

    # Materiales de construcción: se deflactan con INPP, no con INPC
    ipp_fecha, ipp_est, ipp_mun, ipp_serie = inpp[:, 0], inpp[:, 1], inpp[:, 2], inpp[:, 5]
    P46['materiales'] = np.array([
        _deflactar(ref_data['materiales'][i], ipp_serie, ipp_est, ipp_mun,
                   ref_est[i], ref_mun[i], ipp_fecha)
        for i in range(N_CIUDADES)])
    P46['materiales'] = np.where(np.isnan(P46['materiales']),
                                 ref_data['materiales'], P46['materiales'])
    return P46, ref_lat, ref_lon


def _vars_costos(data_dir):
    """Sección 7.1: variables de costo de los Censos Económicos (Gauss l.6182-6205)."""
    c = np.loadtxt(data_dir + 'indicadores_costos_censos_economicos_2014.asc')
    UE = c[:, 9]
    return np.column_stack([
        c[:, 3] / UE,    # producción bruta por UE
        UE,              # unidades económicas
        c[:, 0] / UE,    # empleados por UE
        c[:, 2] / UE,    # remuneraciones por UE
        c[:, 4] / UE,    # consumo intermedio por UE
        c[:, 6] / UE,    # activos fijos por UE
        c[:, 7] / UE,    # depreciación por UE
    ])


def cargar(data_dir, verbose=True):
    """Carga la ENIGH 2014 y devuelve un `DatosAnio`."""
    if not data_dir.endswith('/'):
        data_dir += '/'

    P46, c46_lat, c46_lon = _precios_por_ciudad(data_dir)

    # --- microdatos ---------------------------------------------------------
    mun = np.loadtxt(data_dir + 'datos_municipios_latitud_longitud.asc')
    conc = np.loadtxt(data_dir + 'datos_concentrado_hogares_enigh_2014.asc')
    ten = np.loadtxt(data_dir + 'hogares_tenencia_vivienda_2014.asc')
    lav = np.loadtxt(data_dir + 'hogares_lavadoras_ENIGH_2014.asc')
    veh = np.loadtxt(data_dir + 'hogares_vehiculos_ENIGH_2014.asc')
    gastos = np.vstack([np.loadtxt(data_dir + f'gasto_hogar_enigh_2014_archivo_{k}.asc')
                        for k in (1, 2, 3)])
    gastos_p = np.loadtxt(data_dir + 'gasto_persona_enigh_2014.asc')

    ingreso_mon_completo = conc[:, COL_ING_MON].copy()   # antes de filtrar (N10)
    ingreso_cor_completo = conc[:, COL_ING_COR].copy()

    # Filtros de muestra (Gauss l.1101). Vivienda propia = tenencia 3 ó 4;
    # está en el Gauss aunque el paper no lo menciona (divergencia D-B).
    propias = set(ten[:, 0][(ten[:, 1] == 3) | (ten[:, 1] == 4)])
    vivienda_propia = np.array([f in propias for f in conc[:, 0]])
    mask = (vivienda_propia
            & (conc[:, COL_CLASE_HOG] <= 5)
            & (conc[:, COL_EDAD_JEFE] >= 20) & (conc[:, COL_EDAD_JEFE] <= 75)
            & (conc[:, COL_TOT_INTEG] <= 8)
            & (conc[:, COL_GASTO_MON] >= np.quantile(conc[:, COL_GASTO_MON], 0.001)))
    conc = conc[mask]
    if verbose:
        print(f'Hogares después de filtros básicos: {len(conc)}')

    # Ciudad INPC más cercana y filtro de 400 km
    lookup = {}
    for k in range(len(mun)):
        key = (mun[k, 0], mun[k, 1])
        if key not in lookup:
            lookup[key] = (mun[k, 2] * np.pi / 180, mun[k, 3] * np.pi / 180)
    lat = np.zeros(len(conc))
    lon = np.zeros(len(conc))
    for i in range(len(conc)):
        p = lookup.get((conc[i, COL_ESTADO], conc[i, COL_MUNICIPIO]))
        if p:
            lat[i], lon[i] = p
    arg = (np.sin(lat)[:, None] * np.sin(c46_lat)[None, :]
           + np.cos(lat)[:, None] * np.cos(c46_lat)[None, :]
           * np.cos(c46_lon[None, :] - lon[:, None]))
    dist = np.arccos(np.clip(arg, -1, 1)) * 6371
    ciudad = dist.argmin(axis=1)
    cerca = dist.min(axis=1) <= 400
    conc, ciudad = conc[cerca], ciudad[cerca]
    if verbose:
        print(f'Hogares después de filtro de distancia (<=400 km): {len(conc)}')

    # --- gasto por producto -------------------------------------------------
    claves_todas = sorted({c for _, comps in CATEGORIAS
                           for cl, _ in comps if cl for c in cl})
    idx = {c: j for j, c in enumerate(claves_todas)}
    acum = np.zeros((len(conc), len(claves_todas)))
    fila = {f: i for i, f in enumerate(conc[:, 0])}
    for src in (gastos, gastos_p):
        for k in range(len(src)):
            i = fila.get(src[k, 0])
            j = idx.get(src[k, 1])
            if i is not None and j is not None:
                acum[i, j] += src[k, 2]

    gastos_producto = {}
    for _, comps in CATEGORIAS:
        for claves, prod in comps:
            if claves is None:                       # materiales: del concentrado
                bruto = conc[:, COL_MATERIALES]
            else:
                bruto = acum[:, [idx[c] for c in claves]].sum(axis=1)
            gastos_producto[prod] = np.where(bruto > 0, bruto, EPS)   # piso por producto

    precios_producto = {p: P46[p][ciudad] for p in gastos_producto}

    # --- categorías, índices Divisia y participaciones ----------------------
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

    # Filtro de relevancia: al menos una categoría con gasto >= 10
    rel = (gastos_cat >= 10).sum(axis=1) >= 1
    conc, ciudad = conc[rel], ciudad[rel]
    gastos_cat, precios_cat = gastos_cat[rel], precios_cat[rel]
    gastos_producto = {k: v[rel] for k, v in gastos_producto.items()}
    if verbose:
        print(f'Hogares finales en la muestra: {len(conc)}')

    gasto_total = gastos_cat.sum(axis=1)
    w = gastos_cat / gasto_total[:, None]

    # --- variables Z --------------------------------------------------------
    def _tiene(tabla):
        d = defaultdict(float)
        for k in range(len(tabla)):
            d[tabla[k, 0]] += tabla[k, 1]
        return np.array([float(d.get(f, 0) > 0) for f in conc[:, 0]])

    Z1 = conc[:, COL_EDUCA_JEFE]
    Z2 = conc[:, COL_TOT_INTEG]
    Z4 = conc[:, COL_MENORES]
    Z = np.column_stack([
        Z1, Z2, Z1 * Z2, Z4,
        (conc[:, COL_ING_TOTAL] >= np.quantile(conc[:, COL_ING_TOTAL], 0.8)).astype(float),
        Z1 * Z4, Z1 ** 2,
        (conc[:, COL_TAM_LOC] == 4).astype(float),
        _tiene(veh) * _tiene(lav),
    ])

    datos = DatosAnio(
        anio=2014, n_cat=n_cat,
        nombres_cat=[n for n, _ in CATEGORIAS],
        precios_ln=np.log(precios_cat), w=w, gasto_total=gasto_total,
        gastos_cat=gastos_cat, Z=Z,
        factor_expansion=conc[:, COL_FACTOR], ciudad=ciudad,
        ingreso_mon=conc[:, COL_ING_MON],
        ingreso_cor=conc[:, COL_ING_COR],
        ingreso_total=conc[:, COL_ING_TOTAL],
        ingreso_cor_completo=ingreso_cor_completo,
        n_ciudades=N_CIUDADES, vars_costos=_vars_costos(data_dir),
        precios_producto_ciudad={p: P46[p] for p in gastos_producto},
        gastos_producto=gastos_producto, composicion=composicion,
        ingreso_mon_completo=ingreso_mon_completo,
        subcat={'g_autobus': gastos_producto['autobus_foraneo'],
                'g_aereo': gastos_producto['transporte_aereo'],
                'p_autobus': precios_producto['autobus_foraneo'][rel],
                'p_aereo': precios_producto['transporte_aereo'][rel]},
    )
    if verbose:
        print(datos.resumen())
    return datos
