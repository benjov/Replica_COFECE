# Poder de mercado y bienestar social en México — Réplica y actualización

Réplica en Python del estudio de Aradillas López (2018), *"Estudio sobre el impacto que tiene el poder de mercado en el bienestar de los hogares mexicanos"*, publicado por la COFECE, con datos de la ENIGH 2014. El repositorio incluye el código completo, la documentación de todas las decisiones metodológicas, y la base para la
actualización con datos de la ENIGH 2024.

---

## Referencia

> Aradillas López, A. (2018). *Estudio sobre el impacto que tiene el poder de mercado en el bienestar de los hogares mexicanos*. Comisión Federal de Competencia Económica (COFECE), México.

**Modelo econométrico:** Sistema de demanda EASI (*Exact Affine Stone Index*) de Lewbel & Pendakur (2009), estimado con microdatos de la ENIGH 2014 para 46 ciudades del sistema INPC del INEGI.

---

## Estructura del repositorio

```
.
├── README.md
├── Codigo/
│   └── aradillas_2014_DOCUMENTADO.ipynb   # Notebook principal (47 celdas)
│   └── RESUMEN_PROYECTO_REPLICA_ARADILLAS.md  # Historial de decisiones
├── Data_2014/
│   # Datos ENIGH 2014 (no incluidos*)
│   │   ├── datos_concentrado_hogares_enigh_2014.asc
│   │   ├── gasto_hogar_enigh_2014_archivo_1.asc
│   │   ├── gasto_hogar_enigh_2014_archivo_2.asc
│   │   ├── gasto_hogar_enigh_2014_archivo_3.asc
│   │   ├── gasto_persona_enigh_2014.asc
│   │   ├── hogares_tenencia_vivienda_2014.asc
│   │   ├── hogares_lavadoras_ENIGH_2014.asc
│   │   ├── hogares_vehiculos_ENIGH2014.asc
│   │   ├── datos_municipios_latitud_longitud.asc
│   │   ├── inpc_46_ciudades.asc
│   │   ├── inpp_construccion_46_ciudades.asc
│   │   ├── precios_promedio_46_ciudades_junio_2011.asc
│   │   └── indicadores_costos_censos_economicos_2014.asc
├── CD/
│   ├── programa_ENIGH_2014.g              # Código original en Gauss
│   ├── programa_ENIGH_2006.g              # Versión previa (referencia)
|   ├── Otros archivos de datos del paper de Aradillas 2018
└── outputs/
    ├── elastic_46_ciudades.npy            # Elasticidades (46 ciudades × 14 cats)
    └── elastic_nac.npy                    # Elasticidades nacionales (14 cats)
```
---

## Cómo usar el notebook

### Opción A — Google Colab (recomendada)

1. Abrir `aradillas_2014_DOCUMENTADO.ipynb` en Google Colab.
2. Subir los archivos `.asc` de la carpeta `Data_2014` al directorio `/content/` o montarlos desde Drive.
3. Ajustar `DATA_DIR` en la celda `upload_files`.
4. Ejecutar todas las celdas en orden.

**Tiempo estimado de ejecución:** 30–45 minutos en CPU estándar de Colab.
Las celdas más lentas son la estimación de utilidad indirecta (~3 min) y el cálculo de elasticidades contrafactuales (~15 min, 14 iteraciones × ~60 seg c/u).

### Opción B — Local

```bash
pip install numpy pandas scipy
jupyter notebook notebooks/aradillas_2014_DOCUMENTADO.ipynb
```

Ajustar `DATA_DIR` a la ruta local donde se tienen los archivos `.asc` de la carpeta `Data_2014`.

---

## Plan de actualización 2022

El notebook está estructurado para facilitar la actualización a ENIGH 2022 con cambios mínimos en cada sección.

### Cambios requeridos

**Sección 1 — Precios:**
```python
# Cambiar solo estas dos líneas
fecha_inicial = 2024.08
fecha_final   = 2024.11
```
Requiere: adecuar en notebook para que reciba archivos directamente descargados de INEGI

URL: https://www.inegi.org.mx/programas/enigh/nc/2022/ 

---

## Referencias

- Aradillas López, A. (2018). *Estudio sobre el impacto que tiene el poder de mercado   en el bienestar de los hogares mexicanos*. COFECE, México.
- Lewbel, A. & Pendakur, K. (2009). Tricks with Hicks: The EASI Demand System. *American Economic Review*, 99(3), 827–863.
- Bresnahan, T. (1989). Empirical Studies of Industries with Market Power. En *Handbook of Industrial Organization*, Vol. 2. Elsevier.
- Lewbel, A. (1989). Identification and Estimation of Equivalence Scales under Weak Separability. *Review of Economic Studies*, 56(2), 311–316.
- White, H. (1980). A Heteroskedasticity-Consistent Covariance Matrix Estimator and a Direct Test for Heteroskedasticity. *Econometrica*, 48(4), 817–838.
- INEGI. Encuesta Nacional de Ingresos y Gastos de los Hogares 2014.
- INEGI. Encuesta Nacional de Ingresos y Gastos de los Hogares 2024.
