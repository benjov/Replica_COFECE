"""
Núcleo de cálculo de la réplica de Aradillas López (2018).

Contiene las secciones 3 a 8 del pipeline, que son idénticas entre años:
índices de precio Divisia, sistema EASI, utilidad indirecta, elasticidades,
markups NEIO y bienestar. La carga de datos (secciones 1 y 2) vive en los
módulos por año, porque el formato cambia: 2014 son archivos .asc del CD de
COFECE y 2022 son CSV descargados de INEGI.

Fuente de verdad metodológica: CD/programa_ENIGH_2014.g (código Gauss original).
Ante cualquier duda de implementación manda el Gauss, no el texto del paper.

Todas las correcciones verificadas contra el Gauss llevan su número de bug
(N4, N6, N8, N10, N11, N12) en el comentario. Ver CLAUDE.md para el detalle.
"""

import math
import warnings

import numpy as np
from scipy.optimize import minimize_scalar

# ---------------------------------------------------------------------------
# Constantes del Gauss. No cambiarlas sin anotar la razón en CLAUDE.md.
# ---------------------------------------------------------------------------
NUM_STEPS = 16       # iteraciones del bucle OLS (Gauss l.2449: num_steps=16)
CRITTT = 0.01        # trim 1% por cola, DENTRO del bucle (Gauss l.5535-5536)
FACTOR_CF = 1.25     # perturbación de precio para elasticidades (Gauss l.5837)
EPS_GASTO = 0.01     # piso de gasto por producto (Gauss l.1766 y análogas)
N_Z = 9              # variables de características del hogar
FACTOR_OUT = 1.5     # umbral IQR para outliers en la regresión de markups


# ===========================================================================
# SECCIÓN 3 — Índices de precio Divisia
# ===========================================================================
def divisia_price_index(gastos_componentes, precios_componentes):
    """Índice de precios Divisia (Stone generalizado) de una categoría.

        P_cat = (1/k) * Π_j (P_j / w_j)^{w_j},   k = Π_j w̄_j^{-w̄_j}

    donde w_j es la participación del producto j en el gasto de la categoría
    y w̄_j su media muestral.

    CORRECCIÓN N8 — causa de la compresión de elasticidades.
    El total se calcula como la SUMA DE LOS COMPONENTES (cada uno ya con piso
    EPS_GASTO), igual que el Gauss: gasto_hogar_frutas = Σ gasto_hogar_X con
    cada X ya con piso (l.1765-1766, 1979-1990). Tomar el total como argumento
    con el piso aplicado AL TOTAL hacía que, para hogares sin gasto real,
    w_j = 1 en cada producto — las participaciones sumaban n en vez de 1, y el
    índice dejaba de ser una media geométrica para volverse el PRODUCTO de los
    n precios (std ln P llegaba a 13.8 en Frutas y 14.9 en Verduras).

    Parámetros
    ----------
    gastos_componentes : lista de arrays (N,), cada uno ya con piso EPS_GASTO
    precios_componentes : lista de arrays (N,), precios por hogar

    Devuelve
    -------
    array (N,) con el índice de precios de la categoría
    """
    n_prod = len(gastos_componentes)
    if n_prod != len(precios_componentes):
        raise ValueError("gastos y precios deben tener el mismo número de componentes")
    if n_prod == 1:
        return np.asarray(precios_componentes[0], dtype=float)

    G = np.asarray(gastos_componentes, dtype=float)      # (n_prod, N)
    total = G.sum(axis=0)                                # N8: suma de componentes
    w = G / total

    w_bar = w.mean(axis=1)
    log_k = -np.sum(w_bar * np.log(np.where(w_bar > 0, w_bar, 1e-10)))

    log_P = np.zeros(G.shape[1])
    for j in range(n_prod):
        wj = np.where(w[j] > 0, w[j], 1e-10)
        Pj = np.where(precios_componentes[j] > 0, precios_componentes[j], 1e-10)
        log_P += w[j] * np.log(Pj / wj)

    return np.exp(log_P - log_k)


def piso_gasto(x, eps=EPS_GASTO):
    """Aplica el piso del Gauss a un gasto por PRODUCTO (l.1766 y análogas)."""
    x = np.asarray(x, dtype=float)
    return np.where(x > 0, x, eps)


# ===========================================================================
# SECCIÓN 4 — Sistema aproximado de demanda EASI
# ===========================================================================
def _get_q(pm_ln, n_cat):
    """Precios relativos: log-precio de cada categoría menos el de la última."""
    return pm_ln[:, :n_cat - 1] - pm_ln[:, [n_cat - 1]]


def _build_X(j, q, util, Z, n_z):
    """Matriz de covariados de la ecuación j, con simetría ya impuesta."""
    q_j = q[:, j:]
    q_Z = np.hstack([q_j * Z[:, [l]] for l in range(n_z)])
    return np.column_stack([
        np.ones(len(util)), util, util ** 2, util ** 3,
        Z, Z * util[:, np.newaxis], q_j, q_Z,
    ])


def _util_aproximada(sg, pm, wm, Z, B_mat, AZ_mats):
    """Utilidad EASI aproximada (Gauss l.5515-5529):

        u = [ln x - p'w + T(p,z)] / [1 - S(p)]
    """
    S = 0.5 * np.einsum("ij,jk,ik->i", pm, B_mat, pm)
    T = np.zeros(len(sg))
    for l in range(Z.shape[1]):
        T += 0.5 * Z[:, l] * np.einsum("ij,jk,ik->i", pm, AZ_mats[l], pm)
    num = np.log(sg) - np.sum(pm * wm, axis=1) + T
    den = 1.0 - S
    return np.where(np.abs(den) > 1e-10, num / den, num)


def _simetrizar(B_dict, AZ_dict, n_cat, n_z):
    """Arma B y AZ_l simétricas y cierra la última fila/columna por aditividad."""
    B = np.zeros((n_cat, n_cat))
    AZ = [np.zeros((n_cat, n_cat)) for _ in range(n_z)]
    last = n_cat - 1
    for (i, j), v in B_dict.items():
        B[i, j] = B[j, i] = v
    for (l, i, j), v in AZ_dict.items():
        AZ[l][i, j] = AZ[l][j, i] = v
    for k in range(last):
        B[last, k] = B[k, last] = -B[:last, k].sum()
        for l in range(n_z):
            AZ[l][last, k] = AZ[l][k, last] = -AZ[l][:last, k].sum()
    B[last, last] = -B[:last, last].sum()
    for l in range(n_z):
        AZ[l][last, last] = -AZ[l][:last, last].sum()
    return B, AZ


def estimar_easi(pm_ln, w_mat, sg, Z, n_cat, aplicar_trim=True,
                 num_steps=NUM_STEPS, crittt=CRITTT, verbose=True):
    """Estima el sistema aproximado de demanda EASI por OLS iterado con simetría.

    Replica el bucle `rr` del Gauss (l.2452-5753): en cada iteración estima las
    n_cat-1 ecuaciones independientes, reconstruye B y AZ, recalcula la utilidad
    y recorta las colas. NO existe una segunda etapa GMM: el paper la describe
    pero el Gauss no la implementa.

    `aplicar_trim=False` desactiva el recorte por iteración. El Gauss SÍ recorta
    (y de forma acumulativa), pero eso impide converger: el criterio compara
    parámetros estimados sobre muestras distintas y además colapsa la varianza
    de la utilidad (4.03 -> 0.32 en 16 pasos). Ver CLAUDE.md §8ter.

    Devuelve
    -------
    dict con beta, B_mat, AZ_mats, util, epsilon, mask (índices sobrevivientes)
    """
    pm_ln = np.array(pm_ln, dtype=float)
    w_mat = np.array(w_mat, dtype=float)
    sg = np.array(sg, dtype=float)
    Z = np.array(Z, dtype=float)
    n_z = Z.shape[1]
    last = n_cat - 1

    w_bar = w_mat.mean(axis=0)
    util = np.log(sg) - pm_ln @ w_bar
    vivos = np.arange(len(util))
    beta = {}
    B_mat = AZ_mats = None
    params_prev = None
    epsilon = None

    for step in range(num_steps):
        q = _get_q(pm_ln, n_cat)
        B_dict, AZ_dict = {}, {}

        for j in range(last):
            X = _build_X(j, q, util, Z, n_z)
            Y = w_mat[:, j].copy()
            for jp in range(j):                       # simetría: restar cruzados
                if (jp, j) in B_dict:
                    Y -= q[:, jp] * B_dict[(jp, j)]
                for l in range(n_z):
                    if (l, jp, j) in AZ_dict:
                        Y -= q[:, jp] * Z[:, l] * AZ_dict[(l, jp, j)]
            try:
                b = np.linalg.solve(X.T @ X, X.T @ Y)
            except np.linalg.LinAlgError:
                b = np.linalg.lstsq(X, Y, rcond=None)[0]
            beta[j] = b
            n_q = last - j
            base_B = 4 + 2 * n_z
            base_AZ = base_B + n_q
            for k_idx, k in enumerate(range(j, last)):
                B_dict[(j, k)] = b[base_B + k_idx]
                for l in range(n_z):
                    AZ_dict[(l, j, k)] = b[base_AZ + l * n_q + k_idx]

        B_mat, AZ_mats = _simetrizar(B_dict, AZ_dict, n_cat, n_z)

        # residuos de la iteración: el Gauss usa los de la ÚLTIMA pasada
        epsilon = np.zeros((len(util), n_cat))
        for j in range(last):
            X = _build_X(j, q, util, Z, n_z)
            Y = w_mat[:, j].copy()
            for jp in range(j):
                if (jp, j) in B_dict:
                    Y -= q[:, jp] * B_dict[(jp, j)]
                for l in range(n_z):
                    if (l, jp, j) in AZ_dict:
                        Y -= q[:, jp] * Z[:, l] * AZ_dict[(l, jp, j)]
            epsilon[:, j] = Y - X @ beta[j]
        epsilon[:, last] = -epsilon[:, :last].sum(axis=1)

        params = np.concatenate([beta[j] for j in range(last)])
        if verbose:
            if params_prev is None:
                print(f"  Iteración  1: (primera estimación)  N={len(util)}")
            else:
                crit = np.linalg.norm(params - params_prev) / max(
                    np.linalg.norm(params_prev), 1e-10)
                print(f"  Iteración {step+1:2d}: criterio = {crit:.6f}  N={len(util)}")
        params_prev = params

        util = _util_aproximada(sg, pm_ln, w_mat, Z, B_mat, AZ_mats)

        if aplicar_trim:
            lo, hi = np.quantile(util, crittt), np.quantile(util, 1 - crittt)
            m = (util >= lo) & (util <= hi)
            pm_ln, w_mat, sg, Z = pm_ln[m], w_mat[m], sg[m], Z[m]
            util, vivos, epsilon = util[m], vivos[m], epsilon[m]

    if verbose:
        print(f"\nEstimación completada. Muestra final: {len(vivos)} hogares.")
    return {"beta": beta, "B_mat": B_mat, "AZ_mats": AZ_mats,
            "util": util, "epsilon": epsilon, "mask": vivos}


# ===========================================================================
# SECCIÓN 5 — Matrices de parámetros y utilidad indirecta exacta
# ===========================================================================
def reconstruir_matrices(beta, n_cat, n_z=N_Z):
    """Reconstruye b_poly, C, D, B y AZ_l desde los vectores beta[j].

    La última categoría se obtiene por aditividad: los b0 suman 1 y todo lo
    demás suma 0.
    """
    last = n_cat - 1
    b_poly = np.zeros((n_cat, 4))
    C = np.zeros((n_cat, n_z))
    D = np.zeros((n_cat, n_z))
    B_dict, AZ_dict = {}, {}

    for j in range(last):
        b = beta[j]
        n_q = last - j
        base_B = 4 + 2 * n_z
        base_AZ = base_B + n_q
        b_poly[j, :] = b[:4]
        C[j, :] = b[4:4 + n_z]
        D[j, :] = b[4 + n_z:4 + 2 * n_z]
        for k_idx, k in enumerate(range(j, last)):
            B_dict[(j, k)] = b[base_B + k_idx]
            for l in range(n_z):
                AZ_dict[(l, j, k)] = b[base_AZ + l * n_q + k_idx]

    B, AZ = _simetrizar(B_dict, AZ_dict, n_cat, n_z)
    b_poly[last, 0] = 1 - b_poly[:last, 0].sum()
    for r in range(1, 4):
        b_poly[last, r] = -b_poly[:last, r].sum()
    C[last, :] = -C[:last, :].sum(axis=0)
    D[last, :] = -D[:last, :].sum(axis=0)
    return {"b_poly": b_poly, "C_mat": C, "D_mat": D, "B_mat": B, "AZ_mats": AZ}


class ModeloEASI:
    """Funciones del sistema EASI estimado, con el solver de utilidad indirecta.

    La ecuación de costo C(p,u,z,ε) = ln x es un polinomio cúbico en u. El Gauss
    la resuelve con optmum() (Newton con line search desde la utilidad
    aproximada u0). Se replica con Newton amortiguado, que se queda cerca de u0
    igual que optmum; con los precios ya corregidos (N8) converge en ~97% de los
    hogares. Resolver el cúbico en forma cerrada da raíces exactas pero alejadas
    de u0 y económicamente implausibles — ver CLAUDE.md §8bis.
    """

    def __init__(self, b_poly, C_mat, D_mat, B_mat, AZ_mats):
        self.b_poly = b_poly
        self.C_mat = C_mat
        self.D_mat = D_mat
        self.B_mat = B_mat
        self.AZ_mats = AZ_mats
        self.n_z = len(AZ_mats)

    def T(self, p, z):
        return 0.5 * sum(float(z[l] * p @ self.AZ_mats[l] @ p)
                         for l in range(self.n_z))

    def S(self, p):
        return 0.5 * float(p @ self.B_mat @ p)

    def m(self, u, z):
        return (self.b_poly @ np.array([1., u, u ** 2, u ** 3])
                + self.C_mat @ z + self.D_mat @ z * u)

    def dm_du(self, u, z):
        return (self.b_poly @ np.array([0., 1., 2. * u, 3. * u ** 2])
                + self.D_mat @ z)

    def AZ_grad(self, p, z):
        return sum(z[l] * self.AZ_mats[l] @ p for l in range(self.n_z))

    def f_cost(self, u, p, z, eps, T, S, ln_x):
        return u * (1. + S) + float(p @ self.m(u, z)) + T + float(p @ eps) - ln_x

    def u0(self, ln_x, p, wh, T, S):
        return (ln_x - float(p @ wh) + T) / max(1.0 - S, 1e-10)

    def newton_damped(self, p, z, eps, wh, ln_x,
                      max_iter=50, tol=1e-10, max_step=2.0):
        T, S = self.T(p, z), self.S(p)
        u = self.u0(ln_x, p, wh, T, S)
        for _ in range(max_iter):
            fv = self.f_cost(u, p, z, eps, T, S, ln_x)
            if abs(fv) < tol:
                break
            fp = (1. + S) + float(p @ self.dm_du(u, z))
            if abs(fp) < 1e-14:
                break
            step = fv / fp
            if abs(step) > max_step:
                step = math.copysign(max_step, step)
            u -= step
        return u, abs(self.f_cost(u, p, z, eps, T, S, ln_x))

    def coef_cubico(self, p, z, eps, ln_x):
        """Coeficientes [a3,a2,a1,a0] de f(u)=0, que es un cúbico exacto en u."""
        S = self.S(p)
        return [
            float(p @ self.b_poly[:, 3]),
            float(p @ self.b_poly[:, 2]),
            (1. + S) + float(p @ self.b_poly[:, 1]) + float(p @ (self.D_mat @ z)),
            (float(p @ self.b_poly[:, 0]) + float(p @ (self.C_mat @ z))
             + self.T(p, z) + float(p @ eps) - ln_x),
        ]

    def resolver_utilidad(self, p, z, eps, wh, ln_x):
        """Raíz exacta del cúbico, eligiendo la más cercana a u0.

        La ecuación de costo C(p,u,z,ε) = ln x es un polinomio cúbico en u, así
        que no hay por qué iterar. Se elige la raíz real más cercana a la
        utilidad aproximada u0, que es el punto de partida de `optmum` en el
        Gauss.

        Medido sobre 4,000 hogares de 2022: error mediano 1.8e-15 y 100 % por
        debajo de 1e-6, contra 57.6 % de Newton+fallback (cuyo p90 de error era
        2.21: el fallback no rescataba al 42 % de los hogares, les devolvía un
        valor que no resuelve la ecuación). Donde ambos métodos funcionan
        coinciden exactamente.

        Se intenta Newton primero solo por velocidad: cuando converge, su
        resultado es idéntico al de la raíz exacta.
        """
        u, err = self.newton_damped(p, z, eps, wh, ln_x)
        if err < 1e-6:
            return u, False

        coefs = self.coef_cubico(p, z, eps, ln_x)
        escala = max(abs(c) for c in coefs) or 1.0
        while len(coefs) > 2 and abs(coefs[0]) < 1e-14 * escala:
            coefs = coefs[1:]          # degradar el grado si el líder es ~0
        if len(coefs) >= 2:
            raices = np.roots(coefs)
            reales = raices[np.abs(raices.imag) < 1e-8].real
            if reales.size:
                T, S = self.T(p, z), self.S(p)
                u0 = self.u0(ln_x, p, wh, T, S)
                u_ex = float(reales[np.argmin(np.abs(reales - u0))])
                if abs(self.f_cost(u_ex, p, z, eps, T, S, ln_x)) < err:
                    return u_ex, True
        T, S = self.T(p, z), self.S(p)
        u0 = self.u0(ln_x, p, wh, T, S)
        for hw in (2, 4, 6, 8):
            try:
                with warnings.catch_warnings():
                    warnings.simplefilter("ignore")
                    res = minimize_scalar(
                        lambda uu: self.f_cost(uu, p, z, eps, T, S, ln_x) ** 2,
                        bounds=(u0 - hw, u0 + hw), method="bounded",
                        options={"xatol": 1e-10, "maxiter": 1000})
                e2 = abs(self.f_cost(res.x, p, z, eps, T, S, ln_x))
                if e2 < 1e-6:
                    return res.x, True
                if e2 < err:
                    u, err = res.x, e2
            except Exception:
                pass
        return u, True

    def utilidad_indirecta(self, pm, Z, epsilon, wm, sg, verbose=True):
        """Resuelve la utilidad indirecta exacta para toda la muestra."""
        N = len(sg)
        util = np.zeros(N)
        n_fb = 0
        for i in range(N):
            util[i], fb = self.resolver_utilidad(
                pm[i], Z[i], epsilon[i], wm[i], math.log(sg[i]))
            n_fb += fb
            if verbose and i % 2000 == 0:
                print(f"  {i}/{N}  (fallbacks: {n_fb})")
        if verbose:
            print(f"\nNewton converge: {N-n_fb}/{N} ({(N-n_fb)/N*100:.1f}%)")
            print(f"Utilidad: media={util.mean():.4f}  std={util.std():.4f}"
                  f"  rango [{util.min():.3f}, {util.max():.3f}]")
        return util

    def shares_ajustados(self, p, z, u, eps):
        """Participaciones de gasto predichas, recortadas a no negativas."""
        w = self.m(u, z) + self.AZ_grad(p, z) + self.B_mat @ p * u + eps
        w = np.maximum(w, 0)
        s = w.sum()
        return w / s if s > 0 else w


# ===========================================================================
# SECCIÓN 6 — Demandas Marshallianas y elasticidades
# ===========================================================================
def demandas_marshallianas(modelo, pm, Z, util, epsilon, sg, pi, n_cat):
    """Demandas q_h = exp(-p) · w_h · x_h y su agregado Q = Σ q_h · π_h."""
    N = len(sg)
    q_h = np.zeros((N, n_cat))
    for i in range(N):
        w = modelo.shares_ajustados(pm[i], Z[i], util[i], epsilon[i])
        q_h[i] = np.exp(-pm[i]) * w * sg[i]
    return q_h, (q_h * pi[:, np.newaxis]).sum(axis=0)


def elasticidades(modelo, pm, Z, epsilon, wm, sg, pi, demandas_orig,
                  ciudad, n_ciudades, n_cat, util_orig,
                  factor_cf=FACTOR_CF, factores_extra=None,
                  nombres=None, verbose=True):
    """Elasticidades-precio por perturbación contrafactual del 25%.

    Para cada categoría sube su precio un `factor_cf`, resuelve de nuevo la
    utilidad indirecta, recalcula las demandas y compara agregados ponderados
    por el factor de expansión.

    CORRECCIÓN N6: se agrega sobre TODOS los hogares. El código anterior
    descartaba aquellos donde la demanda contrafactual subía, lo que introduce
    sesgo de selección; el Gauss (l.6146) suma sobre todos.

    `factores_extra` permite pasar sub-categorías cuyo shock no es uniforme
    (transporte aéreo y autobús comparten la categoría 11 y se perturban vía el
    cambio que cada uno induce en el índice Divisia): lista de
    (nombre, indice_categoria, factor_por_hogar).
    """
    ln_f = math.log(factor_cf)
    casos = [(nombres[j] if nombres else f"cat {j+1}", j, None)
             for j in range(n_cat)]
    if factores_extra:
        casos += list(factores_extra)

    e_nac = np.zeros(len(casos))
    e_ciudad = np.zeros((n_ciudades, len(casos)))

    for idx, (nombre, categ, fac_h) in enumerate(casos):
        if verbose:
            print(f"  [{idx+1:2d}] {nombre:<22}", end=" ")
        pm_cf = pm.copy()
        pm_cf[:, categ] += ln_f if fac_h is None else np.log(fac_h)

        N = len(sg)
        dem_cf = np.zeros(N)
        for i in range(N):
            u_cf, _ = modelo.resolver_utilidad(
                pm_cf[i], Z[i], epsilon[i], wm[i], math.log(sg[i]))
            u_cf = min(u_cf, util_orig[i])          # subir precios no mejora utilidad
            w = modelo.shares_ajustados(pm_cf[i], Z[i], u_cf, epsilon[i])
            dem_cf[i] = np.exp(-pm_cf[i][categ]) * w[categ] * sg[i]

        lf = ln_f if fac_h is None else math.log(np.mean(fac_h))
        num = (dem_cf * pi).sum()
        den = (demandas_orig[:, categ] * pi).sum()
        e_nac[idx] = (math.log(num) - math.log(den)) / lf if num > 0 and den > 0 else 0.

        for m in range(n_ciudades):
            sel = ciudad == m
            if not sel.any():
                continue
            a = (dem_cf[sel] * pi[sel]).sum()
            b = (demandas_orig[sel, categ] * pi[sel]).sum()
            if a > 0 and b > 0:
                v = (math.log(a) - math.log(b)) / lf
                e_ciudad[m, idx] = v if -1e10 < v <= 0 else 0.
        if verbose:
            print(f"e={abs(e_nac[idx]):.3f}")

    return e_nac, e_ciudad


# ===========================================================================
# SECCIÓN 7 — Markups y poder de mercado (NEIO, Bresnahan 1989)
# ===========================================================================
def estimar_markups(precios_ciudad, elastic_ciudad, vars_costos,
                    factor_out=FACTOR_OUT, markup_max=5.0):
    """Estima β_η por categoría y deriva los markups por ciudad.

    Modelo de sobreprecios (ecuación 17 del paper): se regresa el precio de
    cada ciudad sobre η_m = -p_m/ε_m y las variables de costo de los Censos
    Económicos, con errores estándar de White y remoción de outliers por IQR.

    Nota: cuando las elasticidades están comprimidas hacia -1, η_m ≈ p_m y la
    regresión devuelve β ≈ 1 con t enormes por colinealidad casi perfecta. Eso
    es una identidad algebraica, no poder de mercado. Ver CLAUDE.md §6.0.
    """
    n_ciudades, n_cat = precios_ciudad.shape
    beta_eta = np.zeros(n_cat)
    t_eta = np.zeros(n_cat)
    se_eta = np.zeros(n_cat)
    markup = np.ones((n_ciudades, n_cat))

    for j in range(n_cat):
        p_m = precios_ciudad[:, j]
        e_m = elastic_ciudad[:, j]
        neg = e_m < 0
        if neg.sum() < 5:
            continue

        eta = -p_m[neg] * (1.0 / e_m[neg])
        X = np.column_stack([eta, vars_costos[neg]])
        Y = p_m[neg]

        out = np.zeros(X.shape[0], dtype=bool)
        for c in range(X.shape[1]):
            q25, q75 = np.percentile(X[:, c], 25), np.percentile(X[:, c], 75)
            iqr = q75 - q25
            out |= (X[:, c] < q25 - factor_out * iqr) | (X[:, c] > q75 + factor_out * iqr)
        X, Y = X[~out], Y[~out]
        if X.shape[0] < 4:
            continue

        n = X.shape[0]
        X = np.column_stack([X, np.ones(n)])
        try:
            b = np.linalg.solve(X.T @ X, X.T @ Y)
        except np.linalg.LinAlgError:
            b = np.linalg.lstsq(X, Y, rcond=None)[0]

        resid = Y - X @ b
        Sigma = (X.T @ X) / n
        Omega = (X.T @ (X * resid[:, np.newaxis] ** 2)) / n
        try:
            V = np.linalg.solve(Sigma, np.linalg.solve(Sigma, Omega).T).T
            se = math.sqrt(abs(V[0, 0]) / n)
        except np.linalg.LinAlgError:
            se = float("nan")

        beta_eta[j] = b[0]
        se_eta[j] = se
        t_eta[j] = b[0] / se if se and se > 0 else 0.

        b_cap = min(b[0], 1.0)
        e_prom = e_m[neg].mean()
        for m in range(n_ciudades):
            em = e_m[m]
            eta_c = -p_m[m] * (1. / em if em < 0 else 1. / e_prom)
            cm = p_m[m] - b_cap * eta_c
            markup[m, j] = max(1., min(markup_max, p_m[m] / cm)) if cm > 0 else 1.

    # V2 — markup para el CONTRAFACTUAL DE BIENESTAR: el Gauss (l.6345, 6380) no
    # usa el markup de esta regresión, sino el índice de Lerner derivado
    # directamente de la elasticidad: tasa = -1/ε, markup = 1 + tasa.
    # Son dos objetos distintos: `markup` sirve para el Cuadro 9 (sobreprecios);
    # `markup_lerner` es el que entra en la variación equivalente.
    markup_lerner = np.ones_like(markup)
    with np.errstate(divide="ignore", invalid="ignore"):
        tasa = -1.0 / elastic_ciudad
    tasa = np.where(np.isfinite(tasa) & (elastic_ciudad < 0), tasa, 0.0)
    markup_lerner = 1.0 + np.clip(tasa, 0.0, markup_max - 1.0)

    return {"beta_eta": beta_eta, "t_eta": t_eta, "se_eta": se_eta,
            "markup": markup, "markup_lerner": markup_lerner}


# ===========================================================================
# SECCIÓN 8 — Variación equivalente y bienestar
# ===========================================================================
# V1 — umbral de significancia del Gauss: cdfni(0.99) = 2.326 (una cola, 99 %),
# no 1.645 (95 %). Determina qué sectores entran al contrafactual (l.6376).
T_SIGNIF = 2.326


def sectores_significativos(t_eta, beta_eta, umbral=T_SIGNIF):
    """Indicadora de sectores que entran al contrafactual de bienestar."""
    return np.array([float(t >= umbral and b > 0)
                     for t, b in zip(t_eta, beta_eta)])


def variacion_equivalente(modelo, pm, Z, epsilon, wm, sg, markup_hogar, sig,
                          verbose=True):
    """Variación equivalente de eliminar el poder de mercado.

    Compara el costo de alcanzar la utilidad observada a precios de mercado
    contra el mismo costo a precios competitivos p0 = p1 - ln(markup), aplicando
    la reducción solo en los sectores con β_η significativo.
    """
    N = len(sg)
    p0 = pm - np.log(markup_hogar) * sig[np.newaxis, :]
    VE = np.zeros(N)

    def costo(p, u, z, eps):
        try:
            return math.exp(u + float(p @ modelo.m(u, z)) + modelo.T(p, z)
                            + modelo.S(p) * u + float(p @ eps))
        except OverflowError:
            return float("inf")

    for i in range(N):
        p1, z, eps, wh = pm[i], Z[i], epsilon[i], wm[i]
        ln_x = math.log(sg[i])
        u1 = modelo.u0(ln_x, p1, wh, modelo.T(p1, z), modelo.S(p1))
        c1 = costo(p1, u1, z, eps)
        c0 = costo(p0[i], u1, z, eps)
        if c1 > 0 and math.isfinite(c1) and math.isfinite(c0):
            VE[i] = ((c1 - c0) / c1) * sg[i]
        if verbose and i % 2000 == 0:
            print(f"  {i}/{N}...")
    return np.maximum(VE, 0.)


def cuadro_10(VE, ingreso, estadistico="mediana"):
    """V4 — el Gauss reporta MEDIANAS, no medias (l.6520 y ss.:
    `VE_2014_todo_pais = quantile(VE_2014, 0.5)`). Con una distribución de VE
    sesgada la diferencia es grande, y comparar nuestra media contra la mediana
    publicada exageraba la brecha.
    `estadistico="media"` recupera el comportamiento anterior."""
    """Pérdida de bienestar por decil de ingreso.

    CORRECCIÓN N11: el denominador es ing_mon (columna 24 del concentrado), no
    ing_total (columna 22). Es la misma base que usa el Gauss para el Gini
    (l.938). Con ing_mon la VE/ingreso da 15.8% contra el 15.7% del paper; con
    ing_total daba 10.0%.

    CORRECCIÓN N12: se usa np.nanmean. Con ing_mon hay hogares con ingreso
    monetario cero (solo ingreso no monetario) y .mean() propagaba nan al
    decil 1, la regresividad y el Gini contrafactual.
    """
    ing = np.asarray(ingreso, dtype=float)
    cortes = np.percentile(ing[ing > 0], np.arange(10, 101, 10))
    decil = np.searchsorted(cortes, ing, side="left") + 1
    decil = np.clip(decil, 1, 10)

    ratio = VE / np.where(ing > 0, ing, np.nan)
    if estadistico == "mediana":
        agg, agg_nan = np.median, np.nanmedian
    elif estadistico == "media":
        agg, agg_nan = np.mean, np.nanmean
    else:
        raise ValueError("estadistico debe ser 'mediana' o 'media'")

    filas = []
    for d in range(1, 11):
        s = decil == d
        if not s.any():
            continue
        filas.append({"decil": d, "VE": agg(VE[s]),
                      "pct": agg_nan(ratio[s]) * 100})
    total = {"decil": "Tot", "VE": agg(VE), "pct": agg_nan(ratio) * 100}
    r1 = agg_nan(ratio[decil == 1])
    r10 = agg_nan(ratio[decil == 10])
    return {"deciles": filas, "total": total, "regresividad": r1 / r10,
            "tasas": [f["pct"] for f in filas]}


def gini(ingreso_completo, tasas_decil):
    """Gini observado y contrafactual, según el Gauss (l.938 y 7410-7433).

    CORRECCIÓN N10. Tres diferencias respecto de lo que hacía el notebook:
      1. la base es ing_mon (columna 24 del concentrado), no ing_total;
      2. se calcula sobre los hogares COMPLETOS del concentrado — la l.938 va
         antes del filtro de muestra de la l.1101, así que no aplica filtros
         ni trim;
      3. el contrafactual es multiplicativo por decil, ingreso · 1/(1 - tasa),
         no sumar la VE en pesos hogar por hogar.

    Con la base correcta el Gini observado da 0.481 y el contrafactual 0.446,
    exactamente los del paper.

    Parámetros
    ----------
    ingreso_completo : array de ing_mon de TODOS los hogares del concentrado
    tasas_decil : lista de 10 tasas VE/ingreso en porcentaje, de cuadro_10
    """
    y = np.sort(np.asarray(ingreso_completo, dtype=float))
    y = y[y > 0]
    n = len(y)
    rk = np.arange(1, n + 1)

    def coef(v):
        return (n + 1) / n - (2 / n) * ((v * (n + 1 - rk)).sum() / v.sum())

    tasas = np.asarray(tasas_decil, dtype=float) / 100.0
    dec = np.minimum((rk - 1) * 10 // n, 9)
    g_obs = coef(y)
    g_cf = coef(y * (1.0 / (1.0 - tasas[dec])))
    return {"observado": g_obs, "contrafactual": g_cf,
            "reduccion_pct": (g_obs - g_cf) / g_obs * 100, "n": n}
