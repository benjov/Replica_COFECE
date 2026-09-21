"""Congela TODAS las cifras citables del proyecto en un solo archivo.

Motivo: el reporte de hallazgos y CLAUDE.md citaban números de corridas distintas
(Pan de caja 0.940 y 0.971; Transporte foráneo con controles sectoriales 0.254 y
0.466; VE 2014 de 13.0 %, 14.3 % y 18.0 % según el denominador). Cada una era
correcta para SU configuración, pero nada decía cuál. Aquí cada cifra queda
atada a una configuración con nombre, al commit que la produjo, y con su
diagnóstico (`n_obs` × `n_ctrl` por regresión de markups; lección del 17-sep).

Uso, desde cualquier directorio:
    /usr/bin/python3 Replica_COFECE/Codigo/congelar_resultados.py            # todas
    /usr/bin/python3 Replica_COFECE/Codigo/congelar_resultados.py replica_2014 comparable_2022
    /usr/bin/python3 Replica_COFECE/Codigo/congelar_resultados.py --solo-md   # solo tablas

(`/usr/bin/python3` porque el `python3` de Homebrew no trae numpy.)

Escribe `Replica_COFECE/Resultados/resultados_congelados.json` (las
configuraciones que se corren se reemplazan; las demás se conservan) y
regenera `Resultados/RESULTADOS.md` con las tablas legibles.
"""
import datetime
import json
import math
import os
import platform
import subprocess
import sys
import time

import numpy as np

CODIGO = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(CODIGO)
SALIDA = os.path.join(REPO, 'Resultados')
sys.path.insert(0, CODIGO)

import costos_saic                                    # noqa: E402
from aradillas_core import (estimar_easi, reconstruir_matrices, ModeloEASI,  # noqa: E402
                            demandas_marshallianas, elasticidades,
                            estimar_markups, variacion_equivalente,
                            cuadro_10, gini, sectores_significativos, T_SIGNIF)

# ---------------------------------------------------------------------------
# Configuraciones. `denominador` es el canónico para la VE; se guardan también
# los demás disponibles para que ninguna cifra quede huérfana.
# ---------------------------------------------------------------------------
CONFIGS = {
    # Réplica de fidelidad al Gauss: trim, 12 categorías, VE/ing_total (l.6519),
    # Gini sobre ing_mon de la muestra completa (l.938).
    'replica_2014': dict(anio=2014, trim=True, pan_de_caja=False,
                         denominador='ing_total', base_gini='ing_mon',
                         costos=True, subtransporte=True),
    # §3 del reporte: el trim tampoco escala en el número de categorías.
    'replica_2014_13cat': dict(anio=2014, trim=True, pan_de_caja=True,
                               denominador='ing_total', base_gini='ing_mon',
                               costos=False, subtransporte=False),
    # Par comparable entre años: sin trim, ing_cor en VE y Gini.
    'comparable_2014': dict(anio=2014, trim=False, pan_de_caja=False,
                            denominador='ing_cor', base_gini='ing_cor',
                            costos=True, subtransporte=False),
    'comparable_2014_13cat': dict(anio=2014, trim=False, pan_de_caja=True,
                                  denominador='ing_cor', base_gini='ing_cor',
                                  costos=True, subtransporte=False),
    'comparable_2022': dict(anio=2022, trim=False, pan_de_caja=True,
                            denominador='ing_cor', base_gini='ing_cor',
                            costos=True, subtransporte=False),
    'comparable_2022_12cat': dict(anio=2022, trim=False, pan_de_caja=False,
                                  denominador='ing_cor', base_gini='ing_cor',
                                  costos=False, subtransporte=False),
    # §3 del reporte: el trim no escala con el tamaño de muestra.
    'trim_2022': dict(anio=2022, trim=True, pan_de_caja=True,
                      denominador='ing_cor', base_gini='ing_cor',
                      costos=False, subtransporte=False),
}

# Modos de controles de costo para D-H (ver CLAUDE.md §2 y costos_saic.py).
# 'rama' se guarda como diagnóstico: su cobertura cae a 4 controles en varias
# categorías y NO es citable.
MODOS_COSTOS = ('ciudad', 'sector', 'sector7', 'rama')

# Cifras publicadas (Aradillas 2018), por nombre de categoría.
PAPER = {
    'elasticidad': {'Tortillas': 1.054, 'Pan': 1.462, 'Pollo+Huevo': 1.261,
                    'Carne res': 0.735, 'Carnes proc.': 0.968, 'Lácteos': 1.289,
                    'Frutas': 1.415, 'Verduras': 1.389, 'Bebidas': 1.110,
                    'Medicamentos': 0.943, 'Materiales': 0.934,
                    'Trans. aéreo': 1.246, 'Autobús foráneo': 0.847},
    'region': {'Noroeste': 1.232, 'Noreste': 1.171, 'Oeste': 1.240, 'Este': 1.237,
               'Centro Norte': 1.209, 'Centro Sur': 1.168, 'Suroeste': 1.179,
               'Sureste': 1.165},
    'beta_eta': {'Tortillas': 0.183, 'Pan': 1.477, 'Pollo+Huevo': 0.139,
                 'Carne res': 0.047, 'Carnes proc.': 0.017, 'Lácteos': 0.626,
                 'Frutas': 1.120, 'Verduras': 0.328, 'Bebidas': 0.047,
                 'Medicamentos': 0.026, 'Materiales': 0.493,
                 'Trans. aéreo': 0.196, 'Autobús foráneo': 0.081},
    't_eta': {'Tortillas': 3.223, 'Pan': 16.268, 'Pollo+Huevo': 1.796,
              'Carne res': 2.851, 'Carnes proc.': 0.906, 'Lácteos': 3.933,
              'Frutas': 12.033, 'Verduras': 3.249, 'Bebidas': 1.531,
              'Medicamentos': 1.566, 'Materiales': 5.535, 'Trans. aéreo': 4.368,
              'Autobús foráneo': 2.718},
    'sobreprecio_pct': {'Frutas': 238.52, 'Pan': 199.95, 'Materiales': 113.25,
                        'Lácteos': 95.43, 'Verduras': 30.47, 'Trans. aéreo': 27.40,
                        'Tortillas': 26.19, 'Autobús foráneo': 14.54,
                        'Carne res': 8.13, 'Pollo+Huevo': 14.02, 'Bebidas': 4.85,
                        'Medicamentos': 4.36, 'Carnes proc.': 1.86},
    've_pct_decil': [30.9, 23.6, 21.4, 18.9, 16.7, 15.1, 13.6, 11.9, 9.5, 5.7],
    've_pct_total': 15.7, 've_pesos_total': 1497, 'regresividad': 4.42,
    'gini_observado': 0.481, 'gini_contrafactual': 0.446, 'gini_reduccion_pct': 7.3,
    'muestra': 15586,
}
REGIONES = {'Noroeste': [2, 3, 8, 10, 25, 26], 'Noreste': [5, 19, 28],
            'Oeste': [6, 14, 16, 18], 'Este': [13, 21, 29, 30],
            'Centro Norte': [1, 11, 22, 24, 32], 'Centro Sur': [9, 15, 17],
            'Suroeste': [7, 12, 20], 'Sureste': [4, 23, 27, 31]}
NO_ALIMENTOS = ('Medicamentos', 'Transporte foráneo', 'Materiales')


def _f(x, nd=4):
    x = float(x)
    return None if not math.isfinite(x) else round(x, nd)


def _lista(a, nd=4):
    return [_f(v, nd) for v in np.asarray(a, dtype=float)]


def _git():
    def g(*a):
        try:
            return subprocess.run(['git', '-C', REPO, *a], capture_output=True,
                                  text=True, check=True).stdout.strip()
        except Exception:
            return None
    return {'commit': g('rev-parse', '--short', 'HEAD'), 'rama': g('branch', '--show-current'),
            'cambios_sin_commit': bool(g('status', '--porcelain', '--', 'Codigo'))}


def _cargar(cfg):
    if cfg['anio'] == 2014:
        import datos_2014
        return datos_2014.cargar(os.path.join(REPO, 'Data_2014/'), verbose=False,
                                 pan_de_caja=cfg['pan_de_caja'])
    import datos_2022
    original = list(datos_2022.CATEGORIAS)
    if not cfg['pan_de_caja']:
        datos_2022.CATEGORIAS[:] = [c for c in original if c[0] != 'Pan de caja']
    try:
        return datos_2022.cargar(os.path.join(REPO, 'Data_2022/'), verbose=False)
    finally:
        datos_2022.CATEGORIAS[:] = original


def _ingresos(d):
    """Denominadores de VE y bases de Gini disponibles para el año."""
    den = {'ing_cor': d.ingreso_cor, 'ing_mon': d.ingreso_mon,
           'ing_total': d.ingreso_total}
    gin = {'ing_cor': d.ingreso_cor_completo, 'ing_mon': d.ingreso_mon_completo}
    return ({k: v for k, v in den.items() if v is not None},
            {k: v for k, v in gin.items() if v is not None})


# Variantes de la ruta de bienestar: lo que hace el Gauss contra lo que describe
# el paper (§4 y Anexo D). Cada una cambia UNA pieza respecto de 'gauss', salvo
# 'paper', que las cambia todas.
#   umbral: el Gauss usa cdfni(0.99)=2.326 (l.6373) = configuración del Anexo D;
#           el texto principal (Cuadro 10) usa 95 % (una cola, 1.645).
#   markup: el Gauss usa -1/ε (Lerner, l.6345); el paper dice restar "los markups
#           estimados" del Cuadro 9, que incluyen β_η (ec. 15').
#   estadístico: el Gauss calcula medianas (l.6520); los pies de los Cuadros 10
#           y 16 dicen "media de los hogares".
VARIANTES_VE = {
    'gauss': (T_SIGNIF, 'markup_lerner', 'mediana'),
    'umbral_95': (1.645, 'markup_lerner', 'mediana'),
    'markup_neio': (T_SIGNIF, 'markup', 'mediana'),
    'media': (T_SIGNIF, 'markup_lerner', 'media'),
    'paper': (1.645, 'markup', 'media'),
}


def _variantes_ve(modelo, d, eps, mk, denominador, base_gini, ingreso_gini):
    out, cache = {}, {}
    for nombre, (umbral, clave_mk, estad) in VARIANTES_VE.items():
        sig = sectores_significativos(mk['t_eta'][:d.n_cat], mk['beta_eta'][:d.n_cat],
                                      umbral=umbral)
        llave = (umbral, clave_mk)
        if llave not in cache:
            cache[llave] = variacion_equivalente(
                modelo, d.precios_ln, d.Z, eps, d.w, d.gasto_total,
                mk[clave_mk][d.ciudad][:, :d.n_cat], sig, verbose=False)
        VE = cache[llave]
        c10 = cuadro_10(VE, denominador, estadistico=estad)
        g = gini(ingreso_gini, c10['tasas'])
        out[nombre] = {'umbral_t': umbral, 'markup': clave_mk, 'estadistico': estad,
                       'significativos': [n for n, s in zip(d.nombres_cat, sig) if s],
                       've_pesos_total': _f(c10['total']['VE'], 1),
                       've_pct_total': _f(c10['total']['pct'], 2),
                       've_pct_decil': [_f(f['pct'], 2) for f in c10['deciles']],
                       'regresividad': _f(c10['regresividad'], 3),
                       'gini_' + base_gini: {'observado': _f(g['observado']),
                                             'contrafactual': _f(g['contrafactual']),
                                             'reduccion_pct': _f(g['reduccion_pct'], 2)}}
    return out


def _bienestar(modelo, d, eps, mk, denominadores, bases_gini):
    sig = sectores_significativos(mk['t_eta'][:d.n_cat], mk['beta_eta'][:d.n_cat])
    VE = variacion_equivalente(modelo, d.precios_ln, d.Z, eps, d.w, d.gasto_total,
                               mk['markup_lerner'][d.ciudad][:, :d.n_cat], sig,
                               verbose=False)
    out = {'significativos': [n for n, s in zip(d.nombres_cat, sig) if s],
           'n_significativos': int(sig.sum()),
           've_pesos_mediana': _f(np.median(VE), 1), 've_pesos_media': _f(VE.mean(), 1),
           've_cero_pct': _f(100 * np.mean(VE <= 0), 2),
           'por_denominador': {}}
    for nom, ing in denominadores.items():
        c10 = cuadro_10(VE, ing)
        fila = {'ve_pct_total': _f(c10['total']['pct'], 2),
                've_pct_decil': [_f(f['pct'], 2) for f in c10['deciles']],
                've_pesos_decil': [_f(f['VE'], 1) for f in c10['deciles']],
                'regresividad': _f(c10['regresividad'], 3), 'gini': {}}
        for base, ing_c in bases_gini.items():
            g = gini(ing_c, c10['tasas'])
            fila['gini'][base] = {'observado': _f(g['observado']),
                                  'contrafactual': _f(g['contrafactual']),
                                  'reduccion_pct': _f(g['reduccion_pct'], 2), 'n': int(g['n'])}
        out['por_denominador'][nom] = fila
    # Contraprueba: la misma VE sin Transporte foráneo, cuya variación de precios
    # entre ciudades no es real (auditoría de precios). Si cambia mucho, la cifra
    # de bienestar depende de un sector no interpretable.
    if 'Transporte foráneo' in out['significativos']:
        sig_st = sig.copy()
        sig_st[d.nombres_cat.index('Transporte foráneo')] = 0.
        VE_st = variacion_equivalente(modelo, d.precios_ln, d.Z, eps, d.w, d.gasto_total,
                                      mk['markup_lerner'][d.ciudad][:, :d.n_cat], sig_st,
                                      verbose=False)
        out['sin_transporte'] = {
            've_cero_pct': _f(100 * np.mean(VE_st <= 0), 2),
            've_pct_total': {nom: _f(cuadro_10(VE_st, ing)['total']['pct'], 2)
                             for nom, ing in denominadores.items()}}
    return out


def _markups_json(mk, nombres):
    return {n: {'beta_eta': _f(mk['beta_eta'][j]), 't_eta': _f(mk['t_eta'][j], 3),
                'n_obs': int(mk['n_obs'][j]), 'n_ctrl': int(mk['n_ctrl'][j]),
                'significativo': bool(mk['beta_eta'][j] > 0 and mk['t_eta'][j] >= T_SIGNIF)}
            for j, n in enumerate(nombres)}


def correr(nombre, cfg):
    t0 = time.time()
    print(f'\n=== {nombre} ===', flush=True)
    d = _cargar(cfg)
    n_pre = d.n_hogares
    res = estimar_easi(d.precios_ln, d.w, d.gasto_total, d.Z, n_cat=d.n_cat,
                       aplicar_trim=cfg['trim'], verbose=False)
    d = d.submuestra(res['mask'])
    modelo = ModeloEASI(**reconstruir_matrices(res['beta'], n_cat=d.n_cat))
    eps = res['epsilon']

    # Utilidad exacta, hogar por hogar, contando cuántos requieren la raíz
    # exacta del cúbico (Newton no converge), y la pendiente del cúbico en el
    # punto de arranque u0: el diagnóstico de §3 (efectos ingreso planos).
    util = np.zeros(d.n_hogares)
    n_fb = 0
    pend = np.zeros(d.n_hogares)
    for i in range(d.n_hogares):
        p, z, ln_x = d.precios_ln[i], d.Z[i], math.log(d.gasto_total[i])
        util[i], fb = modelo.resolver_utilidad(p, z, eps[i], d.w[i], ln_x)
        n_fb += fb
        a3, a2, a1, _ = modelo.coef_cubico(p, z, eps[i], ln_x)
        u0 = modelo.u0(ln_x, p, d.w[i], modelo.T(p, z), modelo.S(p))
        pend[i] = 3 * a3 * u0 ** 2 + 2 * a2 * u0 + a1
    print(f'  N={d.n_hogares}  utilidad lista ({time.time() - t0:.0f} s)', flush=True)

    dem, _ = demandas_marshallianas(modelo, d.precios_ln, d.Z, util, eps,
                                    d.gasto_total, d.factor_expansion, d.n_cat)
    nombres = list(d.nombres_cat)
    extra = None
    if cfg['subtransporte']:
        g_a, g_e = d.subcat['g_autobus'], d.subcat['g_aereo']
        p_a, p_e = d.subcat['p_autobus'], d.subcat['p_aereo']
        w_a, w_e = g_a / (g_a + g_e), g_e / (g_a + g_e)
        pi = d.factor_expansion
        wba, wbe = (w_a * pi).sum() / pi.sum(), (w_e * pi).sum() / pi.sum()
        k_t = wba ** (-wba) * wbe ** (-wbe)
        po = (1 / k_t) * (p_a / w_a) ** w_a * (p_e / w_e) ** w_e
        cf_aereo = (1 / k_t) * (p_a / w_a) ** w_a * ((p_e * 1.25) / w_e) ** w_e / po
        cf_bus = (1 / k_t) * ((p_a * 1.25) / w_a) ** w_a * (p_e / w_e) ** w_e / po
        j_t = nombres.index('Transporte foráneo')
        extra = [('Trans. aéreo', j_t, cf_aereo), ('Autobús foráneo', j_t, cf_bus)]
    e_nac, e_cd = elasticidades(modelo, d.precios_ln, d.Z, eps, d.w, d.gasto_total,
                                d.factor_expansion, dem, d.ciudad, d.n_ciudades,
                                d.n_cat, util, factores_extra=extra, nombres=nombres,
                                verbose=False)
    nombres_ext = nombres + ([n for n, _, _ in extra] if extra else [])
    e_nac = np.abs(e_nac)
    print(f'  elasticidades listas ({time.time() - t0:.0f} s)', flush=True)

    comp = dict(d.composicion)
    if extra:
        comp['Trans. aéreo'] = ['transporte_aereo']
        comp['Autobús foráneo'] = ['autobus_foraneo']
    P_cat = d.precios_por_ciudad(comp)
    denominadores, bases_gini = _ingresos(d)

    out = {'config': cfg, 'categorias': nombres,
           'muestra': {'antes_easi': int(n_pre), 'final': int(d.n_hogares),
                       'ciudades': int(d.n_ciudades)},
           'diagnostico': {
               'util_media': _f(util.mean()), 'util_std': _f(util.std()),
               'util_min': _f(util.min()), 'util_max': _f(util.max()),
               'newton_converge_pct': _f(100 * (1 - n_fb / d.n_hogares), 2),
               'pendiente_u0_mediana': _f(np.median(pend)),
               'pendiente_u0_plana_pct': _f(100 * np.mean(np.abs(pend) < 0.3), 2),
               'util_aprox_std': _f(np.std(res['util']))},
           'elasticidad': dict(zip(nombres_ext, _lista(e_nac))),
           'elasticidad_rango': [_f(e_nac.min()), _f(e_nac.max())]}

    # Cuadro 4/5 y 9 contra el paper, solo en la réplica.
    if cfg['subtransporte']:
        difs = [abs(out['elasticidad'][c] - v) for c, v in PAPER['elasticidad'].items()]
        out['cuadro4'] = {'mae': _f(np.mean(difs)),
                          'dentro_015': int(sum(x < 0.15 for x in difs)),
                          'dentro_030': int(sum(x < 0.30 for x in difs)), 'n': len(difs)}
        est = np.loadtxt(os.path.join(REPO, 'Data_2014/precios_promedio_46_ciudades_junio_2011.asc'))[:, 0]
        alim = [nombres.index(n) for n in nombres if n not in NO_ALIMENTOS]
        reg = {}
        for r, ents in REGIONES.items():
            cs = [c for c in range(d.n_ciudades) if int(est[c]) in ents]
            vs = [abs(e_cd[c, j]) for c in cs for j in alim if abs(e_cd[c, j]) > 0]
            reg[r] = _f(np.mean(vs)) if vs else None
        out['cuadro5'] = {'region': reg, 'dentro_015': int(sum(
            abs(reg[r] - PAPER['region'][r]) < 0.15 for r in reg if reg[r] is not None))}

    # Markups y bienestar por modo de controles de costo.
    modos = MODOS_COSTOS if cfg['costos'] else ('ciudad',)
    costos = {}
    if cfg['costos']:
        anio_c = 2013 if cfg['anio'] == 2014 else 2023
        cache = os.path.join(REPO, f"Data_{cfg['anio']}/costos_saic_{anio_c}.csv")
        for m in ('rama', 'sector'):
            base = costos_saic.cargar(anio_c, d.claves_ciudad, nombres_ext, cache=cache,
                                      modo=m, verbose=False)
            costos[m] = base
            costos[m + '7'] = {k: v[:, 4:] for k, v in base.items()}
    out['markups'] = {}
    for modo in modos:
        vc = d.vars_costos if modo == 'ciudad' else costos[modo]
        mk = estimar_markups(P_cat, e_cd, vc, nombres=nombres_ext)
        bloque = {'cuadro8': _markups_json(mk, nombres_ext),
                  'bienestar': _bienestar(modelo, d, eps, mk, denominadores, bases_gini)}
        if modo == 'ciudad':
            bloque['variantes_ve'] = _variantes_ve(
                modelo, d, eps, mk, denominadores[cfg['denominador']], cfg['base_gini'],
                bases_gini[cfg['base_gini']])
            mkv = mk['markup']
            bloque['sobreprecio_pct'] = {
                n: _f((mkv[:, j][mkv[:, j] > 1].mean() - 1) * 100 if (mkv[:, j] > 1).any() else 0., 2)
                for j, n in enumerate(nombres_ext)}
        out['markups'][modo] = bloque
        b = bloque['bienestar']
        print(f"  {modo:<8} signif {b['n_significativos']}/{d.n_cat}  VE/{cfg['denominador']} "
              f"{b['por_denominador'][cfg['denominador']]['ve_pct_total']}%", flush=True)
    out['segundos'] = round(time.time() - t0)
    print(f'  listo en {out["segundos"]} s', flush=True)
    return out


# ---------------------------------------------------------------------------
# Tablas legibles
# ---------------------------------------------------------------------------
def _n(x, spec='.1f'):
    """Formatea un número; '—' si falta (p. ej. regresividad 0/0 cuando la VE mediana es 0)."""
    return '—' if x is None else format(x, spec)


def _bt(c):
    if c is None:
        return '—'
    if c['n_obs'] == 0 or c['t_eta'] is None or (c['beta_eta'] == 0 and c['t_eta'] == 0):
        return 'n/i'          # regresión no identificada (sin grados de libertad)
    t = c['t_eta']
    return f"{c['beta_eta']:.3f} ({t:.2f}){'*' if c['significativo'] else ''}"


def markdown(todo):
    L = ['# Resultados congelados', '',
         'Generado por `Codigo/congelar_resultados.py`. **No editar a mano**: toda cifra que se',
         'cite en P2 o en el reporte debe salir de aquí (o de `resultados_congelados.json`).', '',
         f"* generado: {todo['_meta']['fecha']}",
         f"* código: commit `{todo['_meta']['git']['commit']}` "
         f"(rama `{todo['_meta']['git']['rama']}`"
         f"{', con cambios sin commit en Codigo/' if todo['_meta']['git']['cambios_sin_commit'] else ''})",
         f"* entorno: {todo['_meta']['entorno']}", '',
         '`*` = significativo (β > 0 y t ≥ 2.326, V1). `n×k` = ciudades × controles que '
         'entraron a la regresión de markups.', '']
    cf = {k: v for k, v in todo.items() if not k.startswith('_')}

    L += ['## Configuraciones', '', '| nombre | año | trim | categorías | VE / | Gini sobre | N final | s |',
          '|---|---|---|---|---|---|---|---|']
    for k, r in cf.items():
        c = r['config']
        L.append(f"| `{k}` | {c['anio']} | {'sí' if c['trim'] else 'no'} | {len(r['categorias'])} | "
                 f"{c['denominador']} | {c['base_gini']} | {r['muestra']['final']:,} | {r['segundos']} |")

    L += ['', '## Diagnóstico del estimador', '',
          '| config | N | util std | util rango | Newton % | f\'(u0) mediana | planos % | elasticidades |',
          '|---|---|---|---|---|---|---|---|']
    for k, r in cf.items():
        g = r['diagnostico']
        L.append(f"| `{k}` | {r['muestra']['final']:,} | {g['util_std']:.3f} | "
                 f"[{g['util_min']:.1f}, {g['util_max']:.1f}] | {g['newton_converge_pct']:.1f} | "
                 f"{g['pendiente_u0_mediana']:.3f} | {g['pendiente_u0_plana_pct']:.1f} | "
                 f"[{r['elasticidad_rango'][0]:.3f}, {r['elasticidad_rango'][1]:.3f}] |")

    if 'replica_2014' in cf:
        r = cf['replica_2014']
        L += ['', '## Réplica 2014 contra el paper (`replica_2014`)', '',
              '| categoría | elasticidad | paper | β_η (t) | n×k | β paper (t) | sobreprecio % | paper % |',
              '|---|---|---|---|---|---|---|---|']
        c8 = r['markups']['ciudad']['cuadro8']
        sp = r['markups']['ciudad']['sobreprecio_pct']
        PAPER_T = PAPER['t_eta']
        for n in r['elasticidad']:
            pe = PAPER['elasticidad'].get(n)
            pb = PAPER['beta_eta'].get(n)
            L.append(f"| {n} | {r['elasticidad'][n]:.3f} | {pe if pe else '—'} | {_bt(c8[n])} | "
                     f"{c8[n]['n_obs']}×{c8[n]['n_ctrl']} | "
                     f"{f'{pb} ({PAPER_T[n]})' if pb else '—'} | "
                     f"{sp[n]:.1f} | {PAPER['sobreprecio_pct'].get(n, '—')} |")
        c4 = r['cuadro4']
        L += ['', f"Cuadro 4: MAE {c4['mae']:.3f}; dentro de ±0.15: {c4['dentro_015']}/{c4['n']}; "
              f"±0.30: {c4['dentro_030']}/{c4['n']}. Cuadro 5: {r['cuadro5']['dentro_015']}/8 "
              f"regiones dentro de ±0.15.", '',
              '| región | réplica | paper |', '|---|---|---|']
        for reg, v in r['cuadro5']['region'].items():
            L.append(f"| {reg} | {v:.3f} | {PAPER['region'][reg]} |")
        b = r['markups']['ciudad']['bienestar']
        L += ['', '**Cuadro 10** (mediana de VE/ingreso por decil, V4):', '',
              '| denominador | ' + ' | '.join(f'D{i}' for i in range(1, 11)) + ' | total | D1/D10 | Gini obs → cf (ing_mon) | reducción |',
              '|---|' + '---|' * 14]
        for den, f in b['por_denominador'].items():
            g = f['gini']['ing_mon']
            L.append(f"| {den}{' (Gauss)' if den == 'ing_total' else ''} | " +
                     ' | '.join(f'{x:.1f}' for x in f['ve_pct_decil']) +
                     f" | {_n(f['ve_pct_total'])} | {_n(f['regresividad'], '.2f')} | "
                     f"{g['observado']:.3f} → {g['contrafactual']:.3f} | {g['reduccion_pct']:.1f} % |")
        L.append('| paper | ' + ' | '.join(str(x) for x in PAPER['ve_pct_decil']) +
                 f" | {PAPER['ve_pct_total']} | {PAPER['regresividad']} | 0.481 → 0.446 | 7.3 % |")
        L.append(f"\nVE en pesos: mediana {b['ve_pesos_mediana']:,.0f}, media {b['ve_pesos_media']:,.0f} "
                 f"(paper: {PAPER['ve_pesos_total']:,}). Significativos: {b['n_significativos']}/12.")

    pares = [('comparable_2014', 'comparable_2022')]
    if all(p in cf for p in pares[0]):
        a, z = cf['comparable_2014'], cf['comparable_2022']
        L += ['', '## Comparación 2014 ↔ 2022 (ambos sin trim, `ing_cor`)', '',
              '| categoría | elast. 2014 | elast. 2022 | β_η 2014 | n×k | β_η 2022 | n×k |',
              '|---|---|---|---|---|---|---|']
        ca, cz = a['markups']['ciudad']['cuadro8'], z['markups']['ciudad']['cuadro8']
        for n in z['categorias']:
            ea = f"{a['elasticidad'][n]:.3f}" if n in a['elasticidad'] else '—'
            L.append(f"| {n} | {ea} | {z['elasticidad'][n]:.3f} | {_bt(ca.get(n))} | "
                     f"{(str(ca[n]['n_obs']) + '×' + str(ca[n]['n_ctrl'])) if n in ca else '—'} | "
                     f"{_bt(cz[n])} | {cz[n]['n_obs']}×{cz[n]['n_ctrl']} |")
        L += ['', '| | ' + ' | '.join(f'D{i}' for i in range(1, 11)) + ' | total | D1/D10 | Gini obs → cf | reducción | signif. |',
              '|---|' + '---|' * 15]
        for et, r in (('2014', a), ('2022', z)):
            b = r['markups']['ciudad']['bienestar']
            f = b['por_denominador']['ing_cor']
            g = f['gini']['ing_cor']
            L.append(f"| {et} | " + ' | '.join(f'{x:.1f}' for x in f['ve_pct_decil']) +
                     f" | {_n(f['ve_pct_total'])} | {_n(f['regresividad'], '.2f')} | "
                     f"{g['observado']:.3f} → {g['contrafactual']:.3f} | {g['reduccion_pct']:.1f} % | "
                     f"{b['n_significativos']}/{len(r['categorias'])} |")

    L += ['', '## Ruta de bienestar: Gauss contra lo que describe el paper', '',
          '`gauss` = t ≥ 2.326, markup −1/ε, mediana (lo que hace el programa; equivale al '
          'Anexo D del paper). `umbral_95` = t ≥ 1.645 (texto principal, Cuadro 10). '
          '`markup_neio` = markup del Cuadro 9, con β_η (ec. 15\'). `media` = media en vez de '
          'mediana (pies de los Cuadros 10 y 16). `paper` = las tres a la vez. Paper: Cuadro 10 '
          '(95 %) \\$1,497 y 15.7 %; Cuadro 16 (99 %) \\$1,414 y 14.4 %.', '',
          '| config | variante | sectores | VE \\$ | VE/ingreso | D1/D10 | reducción Gini |',
          '|---|---|---|---|---|---|---|']
    for k, r in cf.items():
        vv = r['markups']['ciudad'].get('variantes_ve')
        if not vv:
            continue
        for nombre, v in vv.items():
            gk = [x for x in v if x.startswith('gini_')][0]
            L.append(f"| `{k}` | {nombre} | {len(v['significativos'])} | {_n(v['ve_pesos_total'], ',.0f')} | "
                     f"{_n(v['ve_pct_total'])} % | {_n(v['regresividad'], '.2f')} | "
                     f"{_n(v[gk]['reduccion_pct'])} % |")

    for k in ('replica_2014', 'comparable_2014', 'comparable_2014_13cat', 'comparable_2022'):
        if k not in cf or len(cf[k]['markups']) < 2:
            continue
        r = cf[k]
        modos = [m for m in MODOS_COSTOS if m in r['markups']]
        den = r['config']['denominador']
        base = r['config']['base_gini']
        L += ['', f'## D-H — controles de costo (`{k}`)', '',
              '`ciudad` = los 7 del Gauss, iguales para todas las categorías. `sector` = Cuadro 7 '
              '(4 de mercado + 7 específicas). `sector7` = solo las 7 específicas. `rama` NO es '
              'citable (cobertura).', '',
              '| categoría | ' + ' | '.join(modos) + ' |', '|---|' + '---|' * len(modos)]
        for n in r['markups']['ciudad']['cuadro8']:
            L.append(f'| {n} | ' + ' | '.join(
                f"{_bt(r['markups'][m]['cuadro8'][n])} [{r['markups'][m]['cuadro8'][n]['n_obs']}×"
                f"{r['markups'][m]['cuadro8'][n]['n_ctrl']}]" for m in modos) + ' |')
        L.append('| **significativos** | ' + ' | '.join(
            f"{r['markups'][m]['bienestar']['n_significativos']}/{len(r['categorias'])}" for m in modos) + ' |')
        L.append(f'| **VE/{den}** | ' + ' | '.join(
            f"{r['markups'][m]['bienestar']['por_denominador'][den]['ve_pct_total']:.1f} %" for m in modos) + ' |')
        L.append('| hogares con VE = 0 | ' + ' | '.join(
            f"{_n(r['markups'][m]['bienestar'].get('ve_cero_pct'))} %" for m in modos) + ' |')
        L.append(f'| VE/{den} sin Transporte foráneo | ' + ' | '.join(
            (f"{_n(r['markups'][m]['bienestar']['sin_transporte']['ve_pct_total'][den])} %"
             if 'sin_transporte' in r['markups'][m]['bienestar'] else '(no entra)') for m in modos) + ' |')
        L.append(f'| **reducción Gini ({base})** | ' + ' | '.join(
            f"{_n(r['markups'][m]['bienestar']['por_denominador'][den]['gini'][base]['reduccion_pct'])} %"
            for m in modos) + ' |')

    L += ['', '## Pan de caja (P1)', '',
          '| config | Pan de caja β (t) | Pan β (t) | Pan de caja elast. | significativos | VE total |',
          '|---|---|---|---|---|---|']
    for k in ('replica_2014', 'replica_2014_13cat', 'comparable_2014', 'comparable_2014_13cat',
              'comparable_2022_12cat', 'comparable_2022'):
        if k not in cf:
            continue
        r = cf[k]
        c8 = r['markups']['ciudad']['cuadro8']
        b = r['markups']['ciudad']['bienestar']
        den = r['config']['denominador']
        pc = c8.get('Pan de caja')
        ela = f"{r['elasticidad']['Pan de caja']:.3f}" if pc else '—'
        L.append(f"| `{k}` | {_bt(pc)} | {_bt(c8['Pan'])} | {ela} | "
                 f"{b['n_significativos']}/{len(r['categorias'])} | "
                 f"{b['por_denominador'][den]['ve_pct_total']:.1f} % ({den}) |")
    return '\n'.join(L) + '\n'


def main(nombres):
    os.makedirs(SALIDA, exist_ok=True)
    ruta = os.path.join(SALIDA, 'resultados_congelados.json')
    todo = json.load(open(ruta)) if os.path.exists(ruta) else {}
    for n in nombres:
        todo[n] = correr(n, CONFIGS[n])
        todo['_meta'] = {'fecha': datetime.datetime.now().isoformat(timespec='seconds'),
                         'git': _git(),
                         'entorno': f"Python {platform.python_version()}, numpy {np.__version__}",
                         'umbral_t': T_SIGNIF}
        # Guardar tras cada configuración: una corrida larga que falla a la mitad
        # no pierde lo ya calculado.
        json.dump(todo, open(ruta, 'w'), ensure_ascii=False, indent=1)
        with open(os.path.join(SALIDA, 'RESULTADOS.md'), 'w') as f:
            f.write(markdown(todo))
    print(f'\nEscrito {ruta}')


if __name__ == '__main__':
    if sys.argv[1:] == ['--solo-md']:        # regenerar tablas sin volver a estimar
        todo = json.load(open(os.path.join(SALIDA, 'resultados_congelados.json')))
        with open(os.path.join(SALIDA, 'RESULTADOS.md'), 'w') as f:
            f.write(markdown(todo))
        sys.exit(0)
    pedidas = sys.argv[1:] or list(CONFIGS)
    faltan = [p for p in pedidas if p not in CONFIGS]
    if faltan:
        sys.exit(f'Configuraciones desconocidas: {faltan}. Disponibles: {list(CONFIGS)}')
    main(pedidas)
