"""Diagnóstico: agregar Transporte foráneo deja a hogares con VE = 0 (P2, §5.1).

En 2014 sin recorte, Transporte foráneo entra al conjunto de sectores significativos y
la pérdida total BAJA (5.2 % -> 3.2 % del ingreso corriente). Este script mide a quién
afecta: qué hogares pasan de una VE positiva a cero, en qué ciudades y si compran o no
transporte. Corre en ~40 s.

Uso: /usr/bin/python3 Replica_COFECE/Codigo/diagnostico_ve_cero.py
"""
import os
import sys

import numpy as np

CODIGO = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, CODIGO)
import datos_2014                                        # noqa: E402
from aradillas_core import (estimar_easi, reconstruir_matrices, ModeloEASI,  # noqa: E402
                            demandas_marshallianas, elasticidades, estimar_markups,
                            variacion_equivalente, sectores_significativos)

d = datos_2014.cargar(os.path.join(os.path.dirname(CODIGO), 'Data_2014/'), verbose=False)
r = estimar_easi(d.precios_ln, d.w, d.gasto_total, d.Z, n_cat=d.n_cat,
                 aplicar_trim=False, verbose=False)
m = ModeloEASI(**reconstruir_matrices(r['beta'], n_cat=d.n_cat))
eps = r['epsilon']
util = m.utilidad_indirecta(d.precios_ln, d.Z, eps, d.w, d.gasto_total, verbose=False)
dem, _ = demandas_marshallianas(m, d.precios_ln, d.Z, util, eps, d.gasto_total,
                                d.factor_expansion, d.n_cat)
_, e_cd = elasticidades(m, d.precios_ln, d.Z, eps, d.w, d.gasto_total, d.factor_expansion,
                        dem, d.ciudad, d.n_ciudades, d.n_cat, util,
                        nombres=d.nombres_cat, verbose=False)
mk = estimar_markups(d.precios_por_ciudad(), e_cd, d.vars_costos)
sig = sectores_significativos(mk['t_eta'], mk['beta_eta'])
jt = d.nombres_cat.index('Transporte foráneo')
ML = mk['markup_lerner'][d.ciudad]

VE_con = variacion_equivalente(m, d.precios_ln, d.Z, eps, d.w, d.gasto_total, ML, sig,
                               verbose=False)
sig_sin = sig.copy()
sig_sin[jt] = 0.
VE_sin = variacion_equivalente(m, d.precios_ln, d.Z, eps, d.w, d.gasto_total, ML, sig_sin,
                               verbose=False)

cero = (VE_con <= 0) & (VE_sin > 0)
compra = d.gastos_cat[:, jt] > 0.1          # por encima del piso EPS de sus dos productos
mk_t = ML[:, jt]
print('sectores significativos:', [n for n, s in zip(d.nombres_cat, sig) if s])
print(f'N = {len(cero)} hogares')
print(f'markup de transporte en el tope de 5: {np.mean(mk_t >= 4.999) * 100:.1f} % de los hogares')
print(f'pasan a VE = 0 al agregar transporte: {cero.mean() * 100:.1f} %')
print(f'  en ciudades con markup de transporte > 1: {cero[mk_t > 1.0001].mean() * 100:.1f} %')
print(f'  en ciudades con markup de transporte = 1: {cero[mk_t <= 1.0001].mean() * 100:.1f} %')
print(f'compran transporte: {compra[cero].mean() * 100:.1f} % de los que caen a cero, '
      f'{compra[~cero].mean() * 100:.1f} % del resto')
