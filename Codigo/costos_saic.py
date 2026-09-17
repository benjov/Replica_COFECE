"""Variables de costo POR SECTOR y ciudad, desde los Censos Económicos (SAIC).

Resuelve la divergencia D-H: el paper declara controles de costo específicos por
categoría de gasto (Cuadro 6, parte 2, y Cuadro 7 con el mapeo a ramas SCIAN),
pero el archivo que carga el Gauss (`indicadores_costos_censos_economicos_2014.asc`,
[46,11]) solo tiene dimensión de ciudad: las mismas 11 columnas para las 12
categorías. Este módulo construye lo que el paper describe.

Fuente: API del Sistema Automatizado de Información Censal (SAIC) de INEGI,
`POST https://www.inegi.org.mx/app/api/saic/consulta/tabla/6/`. Años censales
disponibles: 2003, 2008, 2013, 2018, 2023 (2013 ≈ Censos Económicos 2014, el que
usó el estudio; 2023 para la actualización 2022).

Confidencialidad: INEGI suprime celdas con pocas unidades económicas. Se resuelve
con una regla de respaldo — se usa el nivel SCIAN más fino con las siete variables
completas, subiendo clase → subrama → rama → subsector → sector. `modo='rama'`
se detiene en rama (más fiel al Cuadro 7, deja huecos); `modo='sector'` llega a
sector (cobertura completa, controles más diluidos). Correr ambos y comparar.
"""

import json
import os
import time
import urllib.request

import numpy as np
import pandas as pd

API = 'https://www.inegi.org.mx/app/api/saic/consulta/tabla/6/'

# Siete variables específicas por categoría (Cuadro 6, parte 2), en el orden que
# usa el Gauss (l.6209): producción bruta/UE, UE, personal/UE, remuneraciones/UE,
# consumo intermedio/UE, activos fijos/UE, depreciación/UE.
VARS = ['UE', 'A111A', 'H001A', 'J000A', 'A121A', 'Q000A', 'Q000B']
# Cuatro variables agregadas de mercado (Cuadro 6, parte 1): gastos totales/UE,
# valor agregado/UE, valor agregado/empleado, valor agregado/activos.
VARS_MERCADO = ['UE', 'A700A', 'A131A', 'H001A', 'Q000A']
SECTORES_MERCADO = ['31-33', '43', '46']   # manufacturas y comercio

# Cuadro 7 del paper (p. 83-84): ramas, subramas y clases SCIAN por categoría.
# Ojo: Pan distingue panificación industrial (311811) de tradicional (311812) en
# los COSTOS, mientras que la categoría de gasto del Gauss solo tiene panadería
# tradicional (A012+A013) — ver P1/D-F.
CUADRO7 = {
    'Tortillas': ['31183'],
    'Pan': ['311811', '311812'],
    'Pan de caja': ['311811'],          # P1: sector propio, solo panificación industrial
    'Pollo+Huevo': ['311612', '43111', '431122', '43114', '461122', '46211'],
    'Carne res': ['311612', '431121', '461121', '46211'],
    'Carnes proc.': ['311613', '43111', '43117', '46115', '46211'],
    'Lácteos': ['31151', '43111', '43116', '46115', '46211'],
    'Frutas': ['3114', '43111', '43113', '46111', '46113', '46211'],
    'Verduras': ['3114', '43111', '43113', '46111', '46113', '46211'],
    'Bebidas': ['31192', '31211', '43111', '431211', '46111', '461213', '46211'],
    'Medicamentos': ['3254', '4331', '46411'],
    'Transporte foráneo': ['4852', '481'],
    'Materiales': ['3273', '3274', '33122', '4671'],
}


def _sector(cod):
    if cod[:2] in ('48', '49'):
        return '48-49'
    if cod[:2] in ('31', '32', '33'):
        return '31-33'
    return cod[:2]


def _padres(cod, modo='sector'):
    """Códigos de respaldo, del más fino al más agregado."""
    out = [cod[:n] for n in (6, 5, 4, 3) if len(cod) > n]
    if modo == 'rama':                      # se detiene en rama (4 dígitos)
        return [c for c in out if len(c) >= 4]
    s = _sector(cod)
    if s != cod and s not in out:
        out.append(s)
    return out


def _consulta(anio, ciudades, actecos, variables, intentos=3):
    cuerpo = {'anios': [anio], 'ageos': list(ciudades), 'actecos': list(actecos),
              'varcens': [{'nom': n, 'pos': i} for i, n in enumerate(variables)],
              'stratums': [0], 'indicators': [], 'calcs': [], 'total': False,
              'orden': '1', 'desc': True, 'page': 0, 'reg': 20000}
    req = urllib.request.Request(
        API, data=json.dumps(cuerpo).encode(),
        headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'})
    for intento in range(intentos):
        try:
            r = json.load(urllib.request.urlopen(req, timeout=300))
            if r.get('success'):
                return json.loads(r['data'])['info']
            raise RuntimeError(f'SAIC respondió: {r}')
        except Exception:
            if intento == intentos - 1:
                raise
            time.sleep(5 * (intento + 1))


def descargar(anio, claves_ciudad, cache=None, verbose=True):
    """Descarga (o lee del caché) las filas ciudad × código para `anio`.

    Devuelve un DataFrame con columnas: ciudad, codigo, y las variables.
    `claves_ciudad`: claves INEGI de municipio (5 dígitos) o entidad (2, CDMX).
    """
    if cache and os.path.exists(cache):
        df = pd.read_csv(cache, dtype={'ciudad': str, 'codigo': str})
        if verbose:
            print(f'  costos SAIC {anio}: {len(df)} filas leídas de {os.path.basename(cache)}')
        return df

    codigos = sorted({c for v in CUADRO7.values() for c in v})
    codigos += sorted({p for c in codigos for p in _padres(c)})
    codigos = sorted(set(codigos) | set(SECTORES_MERCADO))
    ciudades = sorted(set(claves_ciudad) - {None})

    filas = []
    for variables in (VARS, VARS_MERCADO):
        for f in _consulta(anio, ciudades, codigos, variables):
            fila = {'ciudad': (f.get('enti', '')[:2] + f.get('muni', '')[:3]).strip(),
                    'codigo': f['actividad'].split()[0]}
            fila.update({k.split('|')[0]: v for d in f['zxc'] for k, v in d.items()})
            filas.append(fila)
    df = pd.DataFrame(filas).groupby(['ciudad', 'codigo'], as_index=False).first()
    if verbose:
        print(f'  costos SAIC {anio}: {len(df)} filas descargadas '
              f'({len(ciudades)} ciudades × {len(codigos)} códigos)')
    if cache:
        df.to_csv(cache, index=False)
    return df


def _tabla(df, variables):
    """{(ciudad, codigo): {var: valor}} solo con filas completas."""
    out = {}
    for fila in df.to_dict('records'):
        vals = {v: fila.get(v) for v in variables}
        if all(pd.notna(vals[v]) for v in variables):
            out[(fila['ciudad'], fila['codigo'])] = vals
    return out


def construir(df, claves_ciudad, nombres_cat, modo='sector', verbose=True):
    """Matriz de costos (n_ciudades, 11) por categoría.

    Devuelve `dict nombre_categoría -> array (n_ciudades, 11)`: las cuatro
    variables de mercado del Cuadro 6 (iguales para todas las categorías) más
    las siete específicas de la categoría.
    """
    tab = _tabla(df, VARS)
    tab_mer = _tabla(df, VARS_MERCADO)
    n = len(claves_ciudad)

    # --- cuatro variables agregadas de mercado (manufacturas + comercio) ------
    mercado = np.full((n, 4), np.nan)
    for i, ciudad in enumerate(claves_ciudad):
        partes = [tab_mer[(ciudad, s)] for s in SECTORES_MERCADO if (ciudad, s) in tab_mer]
        if not partes:
            continue
        ue = sum(p['UE'] for p in partes)
        gastos = sum(p['A700A'] for p in partes)
        va = sum(p['A131A'] for p in partes)
        empl = sum(p['H001A'] for p in partes)
        activos = sum(p['Q000A'] for p in partes)
        if ue > 0:
            mercado[i] = [gastos / ue, va / ue,
                          va / empl if empl else np.nan,
                          va / activos if activos else np.nan]

    salida, usos = {}, {}
    for cat in nombres_cat:
        codigos = CUADRO7.get(cat)
        X = np.full((n, 7), np.nan)
        if codigos is None:
            if verbose:
                print(f'  ⚠ {cat}: sin mapeo en el Cuadro 7, se usan solo las de mercado')
            salida[cat] = np.column_stack([mercado, X])
            continue
        niveles = []
        for i, ciudad in enumerate(claves_ciudad):
            partes = []
            for cod in codigos:
                for c in [cod] + _padres(cod, modo):
                    if (ciudad, c) in tab:
                        partes.append(tab[(ciudad, c)])
                        niveles.append(len(c) if c != _sector(cod) else 2)
                        break
            if len(partes) < len(codigos):
                continue
            ue = sum(p['UE'] for p in partes)
            if ue <= 0:
                continue
            X[i] = [sum(p['A111A'] for p in partes) / ue, ue,
                    sum(p['H001A'] for p in partes) / ue,
                    sum(p['J000A'] for p in partes) / ue,
                    sum(p['A121A'] for p in partes) / ue,
                    sum(p['Q000A'] for p in partes) / ue,
                    sum(p['Q000B'] for p in partes) / ue]
        completas = int((~np.isnan(X).any(axis=1)).sum())
        usos[cat] = (completas, float(np.mean(niveles)) if niveles else np.nan)
        salida[cat] = np.column_stack([mercado, X])

    if verbose:
        print(f'  costos por sector (modo {modo!r}): ciudades completas por categoría')
        for cat, (completas, nivel) in usos.items():
            print(f'    {cat:<20} {completas:>2}/{n}   nivel SCIAN medio {nivel:.1f} dígitos')
    return salida


def cargar(anio, claves_ciudad, nombres_cat, cache=None, modo='sector', verbose=True):
    """Atajo: descarga (o lee del caché) y construye las matrices por categoría."""
    df = descargar(anio, claves_ciudad, cache=cache, verbose=verbose)
    return construir(df, claves_ciudad, nombres_cat, modo=modo, verbose=verbose)
