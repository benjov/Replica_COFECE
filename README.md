# Poder de mercado y bienestar social en México — Réplica y actualización

Réplica en Python del estudio de Aradillas López (2018), *"Estudio sobre el impacto que
tiene el poder de mercado en el bienestar de los hogares mexicanos"* (COFECE), y su
actualización a la ENIGH 2022.

> Aradillas López, A. (2018). *Estudio sobre el impacto que tiene el poder de mercado en el
> bienestar de los hogares mexicanos*. Comisión Federal de Competencia Económica, México.

**Modelo:** sistema de demanda EASI (*Exact Affine Stone Index*) de Lewbel & Pendakur
(2009), estimado con microdatos de la ENIGH para 46 ciudades del sistema INPC del INEGI;
markups vía NEIO (Bresnahan 1989) y bienestar vía variación equivalente.

---

## Fuente de verdad: el código Gauss, no el paper

`CD/programa_ENIGH_2014.g` es el programa original del estudio, obtenido por solicitud de
acceso a la información pública. **Ante cualquier discrepancia entre el código y el texto
publicado, manda el código.**

La decisión es deliberada: al replicar aparecieron varios casos en que corregir un error
verificado *aleja* los resultados de las cifras publicadas, lo que indica que el paper
incorpora errores que se compensan entre sí. Dos divergencias estructurales:

* El paper describe una estimación en **dos etapas (OLS + GMM)**; el Gauss implementa
  **solo el bucle OLS** de 16 iteraciones. Los parámetros publicados son OLS.
* El Gauss aplica un **filtro de vivienda propia** que descarta el 27 % de la muestra y que
  **el paper nunca menciona**.

---

## Estructura

```
.
├── README.md
├── Aradillas (2018).pdf
├── CD/                                 Material original de COFECE
│   ├── programa_ENIGH_2014.g           ← fuente de verdad metodológica
│   ├── programa_ENIGH_2006.g           versión previa, referencia
│   └── *.asc                           microdatos preprocesados 2006 y 2014
├── Codigo/
│   ├── aradillas_core.py               secciones 3-8: cálculo puro, sin I/O
│   ├── datos_base.py                   contrato DatosAnio entre datos y núcleo
│   ├── datos_2014.py                   secciones 1-2 de 2014 (.asc del CD)
│   ├── datos_2022.py                   secciones 1-2 de 2022 (CSV de INEGI)
│   ├── aradillas_2014.ipynb            réplica 2014       ← ejecutar este
│   ├── aradillas_2022.ipynb            actualización 2022 ← y este
│   ├── productos.py, municipios.py, inpc_lista_productos.py, datos_comparacion.py
│   └── RESUMEN_PROYECTO_REPLICA_ARADILLAS.md   bitácora histórica (v1, desactualizada)
├── Data_2014/                          no versionado
└── Data_2022/                          no versionado
```

**Los datos no están en el repositorio.** Son microdatos públicos de INEGI (891 MB solo
2022, con archivos que exceden el límite de GitHub) y se descargan de
[ENIGH](https://www.inegi.org.mx/programas/enigh/nc/2022/). Lo que sí viaja con el repo es
`CD/`, que **no se puede volver a obtener**: llegó por solicitud de acceso a la información.

### Arquitectura

El cálculo (secciones 3 a 8) es idéntico entre años y vive una sola vez en
`aradillas_core.py`, parametrizado por número de categorías. Lo que cambia entre años es la
carga de datos, en un módulo por año que entrega un `DatosAnio` — el contrato definido en
`datos_base.py`. **Agregar 2024 es escribir `datos_2024.cargar()`.**

`DatosAnio` valida en su constructor que todos los arreglos por hogar estén alineados: la
mayoría de los errores encontrados durante la réplica fueron desalineaciones de índices que
se propagaban en silencio hasta los cuadros finales.

---

## Cómo ejecutar

Desde el directorio que **contiene** `Replica_COFECE/`:

```bash
pip install numpy pandas scipy jupyter
jupyter notebook Replica_COFECE/Codigo/aradillas_2014.ipynb
```

Tiempos de referencia: 2014 ~30 s, 2022 ~6 min.

---

## Estado de los resultados

### Réplica 2014

| resultado | réplica | paper |
|---|---|---|
| **Gini observado** | **0.481** | **0.481** |
| Gini contrafactual | 0.451 | 0.446 |
| Cuadro 5 (elasticidades por región) | 8/8 dentro de ±0.15 | |
| Cuadro 8 (β_η) | dentro del rango publicado (0.02–1.48) | |
| Cuadro 4 (elasticidades) | MAE 0.239, 10/13 dentro de ±0.30 | |

**Limitación conocida:** la muestra final es de 8,940 hogares contra los 15,586 que reporta
el paper, y ninguna combinación de filtros documentados reproduce esa cifra.

### Actualización 2022

| resultado | 2022 | paper 2014 |
|---|---|---|
| VE / ingreso | **17.0 %** | 15.7 % |
| decil 1 | 39.5 % | 30.9 % |
| decil 10 | **5.8 %** | 5.7 % |
| Regresividad D1/D10 | **6.82** | 4.42 |
| Reducción de Gini | 8.4 % | 7.3 % |
| β_η de Pan | **1.496** | 1.477 |
| Sectores significativos | 9 de 12 | |

**Se corre sin el trim iterado del Gauss**, como desviación deliberada y documentada en la
portada del notebook: ese recorte, inocuo con 8,940 hogares, colapsa la varianza del
regresor de utilidad con 57,552 y deja al 76 % de los hogares sin efectos ingreso
identificados. Es un hallazgo del proyecto — **el algoritmo original no escala a muestras
del tamaño de la ENIGH moderna**.

### Advertencias vigentes

* **Las magnitudes en pesos de 2022 no están validadas**: la VE equivale al 77 % del gasto
  en categorías, contra ~53 % en 2014. Los porcentajes y los β_η sí son sólidos.
* **Los Gini de 2014 y 2022 no son comparables entre sí**: usan bases de ingreso distintas
  (la ENIGH 2022 "Nueva serie" dejó de publicar `ing_mon`). Es distinta definición, no
  distinta desigualdad.
* `Codigo/aradillas_2022_DOCUMENTADO.ipynb` es la **versión previa, con errores conocidos**
  (elasticidades comprimidas a −1, markups saturados). Se conserva por referencia
  histórica; **no usarlo**.

---

## Referencias

- Aradillas López, A. (2018). *Estudio sobre el impacto que tiene el poder de mercado en el
  bienestar de los hogares mexicanos*. COFECE, México.
- Lewbel, A. & Pendakur, K. (2009). Tricks with Hicks: The EASI Demand System.
  *American Economic Review*, 99(3), 827–863.
- Bresnahan, T. (1989). Empirical Studies of Industries with Market Power. En *Handbook of
  Industrial Organization*, Vol. 2. Elsevier.
- White, H. (1980). A Heteroskedasticity-Consistent Covariance Matrix Estimator and a
  Direct Test for Heteroskedasticity. *Econometrica*, 48(4), 817–838.
- INEGI. Encuesta Nacional de Ingresos y Gastos de los Hogares, 2014 y 2022.
