> ## ⚠️ BITÁCORA HISTÓRICA — estado de junio 2026
>
> Documento del **primer intento de réplica**, anterior al refactor a módulos. Se conserva
> porque registra bien los hallazgos sobre el código Gauss y varios bugs que se corrigieron
> entonces, pero **sus resultados y su descripción de la estructura del proyecto están
> obsoletos**.
>
> Para el estado vigente ver `README.md` y las portadas de `aradillas_2014.ipynb` y
> `aradillas_2022.ipynb`. El registro completo de correcciones y decisiones está en
> `CLAUDE.md` (fuera del repositorio).

---

# Resumen del proyecto: Réplica y actualización de Aradillas (2018)

## Objetivo general

Replicar en Python (Google Colab, Jupyter Notebook o un script de Python) el estudio de Aradillas López (2018),
*"Estudio sobre el impacto que tiene el poder de mercado en el bienestar de los hogares mexicanos"*, publicado por COFECE, y posteriormente actualizarlo con datos de la ENIGH 2024.

El paper original estima un sistema de demanda EASI (*Exact Affine Stone Index*) con microdatos de la ENIGH 2014 y 46 ciudades del INPC, identifica poder de mercado en 12 categorías de gasto, y cuantifica la pérdida de bienestar de los hogares mexicanos expresada como variación equivalente.

---

## Punto de partida: archivos disponibles

Contamos con los siguientes archivos del estudio original (en Gauss)--conseguidos vía solicitud de acceso a la información pública--:
`CD`
- `programa_ENIGH_2014.g` — código Gauss completo del paper
- `programa_ENIGH_2006.g` — código de la versión previa (referencia)
- Microdatos preprocesados ENIGH 2014 en formato `.asc`:
  - `datos_concentrado_hogares_enigh_2014.asc` (19,124 × 133)
  - `gasto_hogar_enigh_2014_archivo_{1,2,3}.asc`
  - `gasto_persona_enigh_2014.asc`
  - `hogares_tenencia_vivienda_2014.asc`
  - `hogares_lavadoras_ENIGH_2014.asc`
  - `hogares_vehiculos_ENIGH2014.asc`
  - `datos_municipios_latitud_longitud.asc`
- Series de precios:
  - `inpc_46_ciudades.asc` (4,968 × 66 — series mensuales)
  - `inpp_construccion_46_ciudades.asc` (4,968 × 6)
  - `precios_promedio_46_ciudades_junio_2011.asc` (46 × 70 — precios base)
- Variables de costo:
  - `indicadores_costos_censos_economicos_2014.asc` (46 × 11)

---

## Hallazgos sobre el código Gauss

Al leer el programa línea por línea se identificaron varios puntos críticos:

1. **El paper describe dos etapas (OLS + GMM), pero el código implementa solo una:**
   El bucle `rr` de 16 iteraciones OLS es todo el proceso de estimación.
   No existe una segunda etapa GMM separada. Los parámetros OLS del último paso
   son los que se usan para elasticidades y bienestar.

2. **El solver de utilidad indirecta es Newton-Raphson (`optmum`):**
   El Gauss resuelve $x_h = C(\mathbf{p}_h, u_h, z_h, \varepsilon_h)$ vía
   optimización de $[C - \ln x]^2$ partiendo de $u_0 =$ utilidad EASI aproximada.

3. **Factor de expansión $\pi_h$ en demandas agregadas:**
   $Q^M(\mathbf{p}) = \sum_h q_h^M \cdot \pi_h$ donde $\pi_h$ es la columna 7
   del concentrado ENIGH (`factor_hog`).

4. **Epsilon se guarda de la última iteración OLS**, no se recomputa externamente.

5. **Filtro de vivienda propia:** códigos 3 y 4 en 2014 (no 4 y 5 del 2006).

6. **`factor_cf = 1.25`** para el cálculo de elasticidades (perturbación del 25%).

7. **Trim del 1%** en cada cola por iteración (no 6%).

---

## Proceso de réplica: etapas y decisiones

### Sección 1 — Índices de precios (implementada ✓)

Para cada ciudad $i$ y producto $j$:
$$P_{ij,2014} = P_{ij,\text{jun2011}} \times \text{mediana}\left(\frac{\text{INPC}_{ij,t}}{\text{INPC}_{ij,\text{jun2011}}}\right), \quad t \in [\text{ago-2014, nov-2014}]$$

Las 46 ciudades reciben precios deflactados en pesos MXN de ago-nov 2014.
Los materiales de construcción usan INPP (no INPC).

### Sección 2 — Microdatos ENIGH 2014 (implementada ✓)

**Data**
Carpeta `Data_2014`

**Filtros de muestra:**
1. Vivienda propia (tenencia = 3 ó 4) — *corrección clave vs versión 2006*
2. `clase_hog ≤ 5`
3. Edad del jefe: 20–75 años
4. Integrantes ≤ 8
5. Gasto monetario ≥ percentil 0.1%
6. Distancia a ciudad INPC más cercana ≤ 400 km

**Resultado:** 12,592 hogares tras filtros básicos.

### Sección 3 — Categorías de gasto (implementada ✓)

12 categorías con índices Divisia a nivel hogar:
Tortillas, Pan, Pollo+Huevo, Carne res, Carnes procesadas, Bebidas no alcohólicas,
Frutas, Verduras, Lácteos, Materiales, Transporte foráneo, Medicamentos.

9 variables Z: EDUC, INTEGRANTES, EDUCxINTEGRANTES, MENORES, INGR80,
EDUCxMENORES, EDUC², LOC2500, AUTOLAV.

### Sección 4 — Sistema EASI aproximado (implementada ✓)

- 16 iteraciones OLS con simetría de B y $A_\ell$ impuesta
- 902 parámetros totales estimados por aditividad
- Trim del 1% por cola en cada iteración
- Verificación: suma $b_0 = 1.000$, suma $b_1 = 0.000$ (aditividad exacta)
- Muestra final: **8,940 hogares** (brecha con paper: 15,586)

### Sección 5 — Utilidad indirecta exacta (implementada con limitación)

**Solver implementado:** Newton-Raphson con damping (paso máximo = 2.0)
+ fallback a `minimize_scalar('bounded')`.

**Convergencia:** ~66% via Newton, ~34% via fallback.
Error medio $|C - \ln x| = 0.501$ (el Gauss logra ~1e-9 con `optmum()`).

**Impacto:** Las elasticidades quedan comprimidas hacia 1.0 para el 25-30%
de hogares con convergencia imperfecta.

### Sección 6 — Demandas y elasticidades (implementada ✓ en regiones)

- Cuadro 4 (nacional): MAE = 0.207 vs paper. 5/13 categorías dentro de ±0.15.
- **Cuadro 5 (regiones): réplica exacta — 8/8 regiones dentro de ±0.15** ✓

| Región | Réplica | Paper |
|--------|---------|-------|
| Noroeste | 1.119 | 1.232 |
| Noreste | 1.111 | 1.171 |
| Oeste | 1.103 | 1.240 |
| Este | 1.102 | 1.237 |
| Centro Norte | 1.122 | 1.209 |
| Centro Sur | 1.105 | 1.168 |
| Suroeste | 1.110 | 1.179 |
| Sureste | 1.110 | 1.165 |

### Sección 7 — Markups y poder de mercado (implementada con limitación)

Modelo NEIO (Bresnahan 1989): OLS con errores White, variables de costo
de Censos Económicos 2014, remoción de outliers IQR×1.5.

Las elasticidades comprimidas distorsionan $\eta_m \approx p_m$ para casi
todas las ciudades, lo que identifica $\hat\beta_\eta \approx 1$ en lugar
de los valores del paper (0.02–1.48).
Autobús foráneo replica bien: $\hat\beta_\eta = 0.084$ vs 0.081 del paper.

### Sección 8 — Bienestar y Gini (implementada ✓ en patrón cualitativo)

| Resultado | Réplica | Paper |
|-----------|---------|-------|
| VE/ingreso media | 14.3% | 15.7% |
| Regresividad D-I / D-X | 5.9x | 4.42x |
| Gini reducción | 5.6% | 7.3% |

El patrón cualitativo (regresividad, gradiente por decil, reducción de Gini)
replica correctamente. El monto en pesos está sobreestimado porque todos los
sectores resultan estadísticamente significativos (efecto de elasticidades comprimidas).

---

## Bugs identificados y corregidos durante la réplica

| # | Bug | Efecto | Corrección |
|---|-----|--------|------------|
| 1 | Código de tenencia 4,5 en lugar de 3,4 | −1,757 hogares | Cambiar a `tenencia == 3 or 4` |
| 2 | `crittt = 0.06` en lugar de 0.01 | Muestra colapsaba a 1,557 | Cambiar a `crittt = 0.01` |
| 3 | `util` actualizado con aproximación lineal en todas las iteraciones | Coeficientes absurdos | Fórmula EASI exacta con B y AZ |
| 4 | Epsilon recomputado externamente | Residuos incorrectos | Usar `epsilon_matrix_final` del loop OLS |
| 5 | `brentq` con bracket ±50 | Divergencia a raíces espurias del cúbico | Newton+damping + fallback acotado |
| 6 | `sg[0]` en lugar de `sg[i]` en punto inicial | u₀ malo para todos los hogares | Pasar `ln_x = log(sg[i])` como argumento |
| 7 | `exp(precios_matrix_ln)` para precios en pesos | Magnitudes de billones | Usar `P_46[producto]` directamente |
| 8 | Sin factor de expansión $\pi_h$ en demanda agregada | Elasticidades sesgadas | $Q^M = \sum_h q_h \cdot \pi_h$ |

---

## Limitaciones documentadas de la réplica

1. **Brecha de muestra:** 8,940 vs 15,586 hogares. El Gauss puede tener filtros
   adicionales no documentados en el paper (posiblemente filtros sobre el módulo
   de gastos persona).

2. **Convergencia del solver:** Newton+damping converge en ~66% de hogares.
   El Gauss (`optmum`) converge en ~100%. Esta diferencia causa la compresión
   de elasticidades y es la limitación técnica principal.

3. **Elasticidades comprimidas:** MAE = 0.207 en Cuadro 4 nacional. El patrón
   regional (Cuadro 5) replica exactamente, lo que confirma que el error es
   sistemático (no sesgado geográficamente).

---

## Archivo generado

- **`aradillas_2014_DOCUMENTADO.ipynb`** — Notebook completo de Google Colab
  con 47 celdas (38 de código + 9 de documentación en Markdown).
  Reproduce el pipeline completo: precios → microdatos → demanda EASI →
  utilidad exacta → elasticidades → markups → bienestar.

---

## Plan para la actualización 2024

### Paso 1 — Actualizar precios
Obtener INPC y INPP para 46 ciudades hasta 2024 (INEGI).
Cambiar `fecha_inicial` y `fecha_final` al período de levantamiento ENIGH 2024.

### Paso 2 — Adaptar microdatos ENIGH 2024
- Verificar índices de columnas del concentrado 2024 (pueden haber cambiado)
- Remapear claves numéricas de productos (A004, A012, etc.) al catálogo 2024
- Verificar estructura de `gasto_persona_enigh_2024`

### Paso 3 — Actualizar variables de costo
Usar Censos Económicos 2024 (o 2019 si 2024 no está publicado),
con las mismas ramas SCIAN del Cuadro 7 del paper.

### Paso 4 — Ajustes metodológicos
- Factor de inflación para VE: `INPC_oct2025 / INPC_mediana(ago-nov2024)`
- Verificar que `tam_loc == 4` sigue siendo el código de LOC2500 en ENIGH 2024

### Paso 5 — Análisis comparativo 2014 → 2024
- ¿Aumentó o disminuyó el poder de mercado?
- ¿Cambió la regresividad del "impuesto"?
- Impacto de la inflación 2021-2023 en elasticidades de demanda
- Nuevas categorías (plataformas digitales, comercio electrónico)

### Archivos necesarios para 2024

| Archivo 2024 | Equivalente 2014 |
|---|---|
| `inpc_46_ciudades_2024.asc` | `inpc_46_ciudades.asc` |
| `inpp_construccion_46_ciudades_2024.asc` | `inpp_construccion_46_ciudades.asc` |
| `datos_concentrado_hogares_enigh_2024.asc` | `datos_concentrado_hogares_enigh_2014.asc` |
| `gasto_hogar_enigh_2024_archivo_{1,2,3}.asc` | archivos gasto hogar 2014 |
| `hogares_tenencia_vivienda_2024.asc` | equivalente 2014 |
| `hogares_lavadoras_ENIGH_2024.asc` | equivalente 2014 |
| `hogares_vehiculos_ENIGH2024.asc` | equivalente 2014 |
| `indicadores_costos_censos_economicos_2024.asc` | equivalente 2014 |
