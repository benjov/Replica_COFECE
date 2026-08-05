"""
Contrato entre la capa de datos y el núcleo de cálculo.

Las secciones 1 y 2 del pipeline (precios locales y microdatos ENIGH) difieren
entre años: 2014 lee los .asc del CD de COFECE y 2022 lee los CSV que publica
INEGI. Las secciones 3 a 8 son idénticas y viven en `aradillas_core`.

`DatosAnio` es lo que cada módulo por año debe entregar para que el núcleo
pueda correr sin saber de qué año se trata. Añadir un año nuevo (2024) es
escribir un `datos_2024.cargar()` que devuelva esta estructura.
"""

from dataclasses import dataclass, field, replace

import numpy as np


@dataclass
class DatosAnio:
    """Datos de un año, listos para el núcleo de cálculo.

    Todos los arrays por hogar tienen la misma longitud N y están alineados
    entre sí. Mantener esa alineación es crítico: la mayoría de los bugs
    encontrados en la réplica 2022 fueron desalineaciones de índices.
    """

    anio: int
    n_cat: int
    nombres_cat: list

    # --- muestra estimable (N hogares) ---
    precios_ln: np.ndarray        # (N, n_cat)  log del índice Divisia por categoría
    w: np.ndarray                 # (N, n_cat)  participaciones de gasto
    gasto_total: np.ndarray       # (N,)        gasto en las n_cat categorías
    gastos_cat: np.ndarray        # (N, n_cat)  gasto por categoría
    Z: np.ndarray                 # (N, 9)      características del hogar
    factor_expansion: np.ndarray  # (N,)        π_h, factor de expansión ENIGH
    ciudad: np.ndarray            # (N,)        índice de ciudad INPC, base 0
    ingreso_mon: np.ndarray       # (N,)        ing_mon; denominador de la VE (N11)

    # --- agregados por ciudad (secciones 6 y 7) ---
    n_ciudades: int
    vars_costos: np.ndarray       # (n_ciudades, k) Censos Económicos
    # Precio de cada PRODUCTO en cada ciudad, en pesos (producto -> (n_ciudades,)).
    # El precio por CATEGORÍA no es un campo fijo porque se pondera con los
    # gastos de la muestra vigente, que cambia tras el trim del bucle EASI:
    # se calcula con el método precios_por_ciudad().
    precios_producto_ciudad: dict
    # Gasto por PRODUCTO y hogar (producto -> (N,)), ya con piso EPS.
    gastos_producto: dict
    # Composición: nombre de categoría -> lista de nombres de producto.
    composicion: dict

    # --- muestra completa, sin filtros (sección 8) ---
    # El Gauss calcula el Gini sobre TODOS los hogares del concentrado, antes
    # del filtro de muestra (l.938 va antes de la l.1101). Ver N10.
    ingreso_mon_completo: np.ndarray

    # --- sub-categorías con tratamiento especial ---
    # Transporte foráneo agrega autobús + aéreo en una sola categoría con
    # índice Divisia; sus elasticidades se reportan por separado perturbando
    # el sub-precio correspondiente. Claves: g_autobus, g_aereo, p_autobus,
    # p_aereo.
    subcat: dict = field(default_factory=dict)

    def __post_init__(self):
        n = len(self.gasto_total)
        esperado = {
            "precios_ln": (n, self.n_cat), "w": (n, self.n_cat),
            "gastos_cat": (n, self.n_cat), "Z": (n, 9),
        }
        for nombre, shape in esperado.items():
            real = np.asarray(getattr(self, nombre)).shape
            if real != shape:
                raise ValueError(
                    f"{nombre} tiene shape {real}, se esperaba {shape}")
        for nombre in ("factor_expansion", "ciudad", "ingreso_mon"):
            real = len(np.asarray(getattr(self, nombre)))
            if real != n:
                raise ValueError(
                    f"{nombre} tiene largo {real}, se esperaba {n}")
        for k, v in self.subcat.items():
            if len(np.asarray(v)) != n:
                raise ValueError(f"subcat['{k}'] tiene largo {len(v)}, se esperaba {n}")

    @property
    def n_hogares(self):
        return len(self.gasto_total)

    def submuestra(self, mask):
        """Aplica una máscara de hogares a todo lo que va por hogar.

        Se usa después del trim del bucle EASI, que devuelve los índices
        sobrevivientes. `ingreso_mon_completo`, `precios_ciudad` y
        `vars_costos` NO se filtran: no son por hogar.
        """
        return replace(
            self,
            precios_ln=self.precios_ln[mask],
            w=self.w[mask],
            gasto_total=self.gasto_total[mask],
            gastos_cat=self.gastos_cat[mask],
            Z=self.Z[mask],
            factor_expansion=self.factor_expansion[mask],
            ciudad=self.ciudad[mask],
            ingreso_mon=self.ingreso_mon[mask],
            subcat={k: np.asarray(v)[mask] for k, v in self.subcat.items()},
            gastos_producto={k: np.asarray(v)[mask]
                             for k, v in self.gastos_producto.items()},
        )

    def precios_por_ciudad(self, categorias=None):
        """Precio en pesos de cada categoría en cada ciudad.

        Réplica del Gauss: precio_cat = Σ_i P_ciudad_i · w̄_i, donde w̄_i es la
        participación agregada del producto i dentro de su categoría, calculada
        sobre la muestra VIGENTE. Por eso es un método y no un campo: en el
        notebook se construye después del trim, y usar las participaciones
        pre-trim daría markups distintos.

        `categorias` permite pedir un subconjunto o añadir sub-categorías
        (p. ej. autobús y aéreo por separado); por defecto usa `composicion`.
        """
        comp = categorias if categorias is not None else self.composicion
        P = np.zeros((self.n_ciudades, len(comp)))
        for j, (_, productos) in enumerate(comp.items()):
            totales = np.array([self.gastos_producto[p].sum() for p in productos],
                               dtype=float)
            s = totales.sum()
            pesos = totales / s if s > 0 else np.full(len(productos),
                                                      1.0 / len(productos))
            for prod, wgt in zip(productos, pesos):
                P[:, j] += self.precios_producto_ciudad[prod] * wgt
        return P

    def resumen(self):
        return (f"ENIGH {self.anio}: {self.n_hogares} hogares, "
                f"{self.n_cat} categorías, {self.n_ciudades} ciudades")
