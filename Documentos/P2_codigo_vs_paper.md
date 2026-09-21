# Lo que el programa hace y el documento no dice

## Divergencias entre el código y el texto de Aradillas López (2018), y su efecto sobre las conclusiones

*Borrador para discusión — 20 de septiembre de 2026.*
*Proyecto: réplica y actualización del estudio COFECE sobre poder de mercado y bienestar.*

> **Regla de citación.** Toda cifra de este documento sale de
> `Resultados/resultados_congelados.json`, generado por `Codigo/congelar_resultados.py`, y
> lleva el nombre de la configuración que la produjo (`replica_2014`, `comparable_2022`,
> etc.; ver §1.3). Las excepciones son las pruebas de precios (§7, de
> `Codigo/auditoria_precios.ipynb`), el diagnóstico de §5.1 (`Codigo/diagnostico_ve_cero.py`)
> y unas pocas cifras marcadas como *medición histórica*, con su fecha.

---

## Resumen

Aradillas López (2018) estima, para la COFECE, cuánto pierden los hogares mexicanos por el
poder de mercado en doce categorías de gasto. Sus conclusiones más citadas son cuatro:
hay poder de mercado en nueve de las doce categorías (diez rubros, contando por separado
los dos transportes); el sobreprecio promedio es de 98 %;
la pérdida equivale al **15.7 % del ingreso** de los hogares, con un impacto regresivo
(30.9 % en el decil más pobre, 5.7 % en el más rico); y sin poder de mercado **el Gini
sería 7.3 % menor**.

Obtuvimos por solicitud de acceso a la información el programa Gauss que produjo el
estudio, lo replicamos en Python y lo contrastamos línea por línea con el documento. Hay
cinco resultados.

1. **La réplica valida el diagnóstico cualitativo.** El Gini observado coincide al decimal
   (0.481), la pérdida es regresiva en todas las especificaciones que probamos y los
   parámetros de poder de mercado caen en el rango publicado, con 9 de 12 sectores
   significativos.

2. **El programa y el documento divergen en once puntos verificables** (§3). Cuatro son
   de fondo: el documento describe un estimador en dos etapas que el código no implementa;
   dos filtros de muestra no declarados eliminan el 45 % de los hogares de la encuesta; los controles de
   costo que el documento describe como específicos por sector son iguales para todos los
   sectores; y el markup que entra en la pérdida de bienestar **no es el markup estimado**,
   sino uno que ignora el parámetro de poder de mercado.

3. **El programa entregado no genera por sí mismo las cifras publicadas.** Está
   configurado con el umbral de significancia del Anexo D (99 %), no el del texto
   principal (95 %); calcula medianas donde el documento reporta medias; no convierte a
   pesos mensuales ni reexpresa a pesos de octubre de 2015; y no contiene el bootstrap con
   el que se reportan los errores estándar. Las cifras publicadas pasaron por pasos que no
   están en el código.

4. **La dirección de las conclusiones es robusta; su magnitud no está identificada.** Con
   el mismo código y los mismos datos, decisiones de especificación que el documento no
   discute mueven la pérdida de bienestar de 2014 entre **3.1 % y 16.0 % del ingreso**
   (§5). Ninguna de esas decisiones cambia el signo ni el patrón regresivo. Implementar los
   controles de costo por sector que describe el documento, en cambio, **no cambia la
   pérdida** una vez que se aísla un problema del propio cálculo de bienestar (§5.1):
   agregar un sector con markup extremo puede *reducir* la pérdida calculada.

5. **El estimador tiene dos límites que solo se ven al actualizar el estudio** (§6 y §7):
   deja de funcionar cuando crece la muestra o el número de categorías, y en algunas
   categorías la variación de precios entre ciudades, que es la que identifica el poder
   de mercado, no corresponde a la variación real.

El enunciado que proponemos en lugar del original: *el poder de mercado impone a los
hogares mexicanos una pérdida de bienestar positiva y regresiva, concentrada en
alimentos básicos; su magnitud, sin embargo, depende de decisiones de especificación que
el estudio no reporta, y no está identificada con la precisión que se le atribuye.*

---

## 1. Alcance, fuentes y criterio

### 1.1 Fuentes

* **El documento**: Aradillas López, A. (2018), *Estudio sobre el impacto que tiene el
  poder de mercado en el bienestar de los hogares mexicanos*, COFECE.
* **El programa**: `programa_ENIGH_2014.g` (Gauss, ~8,000 líneas) y los archivos `.asc`
  preprocesados que carga, obtenidos por solicitud de acceso a la información pública.
  Las referencias de línea (l.NNNN) de este documento son a ese archivo.
* **Los datos**: ENIGH 2014, INPC por ciudad, precios promedio del INPC y Censos
  Económicos, todos de INEGI.

### 1.2 Criterio: fidelidad al programa, no a las cifras publicadas

Cuando reproducir las cifras publicadas y ser fiel al programa entran en conflicto, la
réplica sigue al programa. La razón es empírica: durante el proyecto, **tres veces una
configuración coincidió con el documento por razones equivocadas**, y las tres se
descubrieron solo al implementar la versión fiel al código (Anexo A). Coincidir con una
cifra publicada no es evidencia de estar bien.

Consecuencia: las diferencias entre la réplica y el documento no se tratan como errores
por corregir, sino como resultados. Son la materia de este documento.

### 1.3 Configuraciones

Todas las cifras provienen de una de estas corridas, congeladas el 20 de septiembre de
2026 (commit indicado en `Resultados/RESULTADOS.md`):

| configuración | año | recorte iterativo | categorías | denominador de la VE | para qué |
|---|---|---|---|---|---|
| `replica_2014` | 2014 | sí (como el Gauss) | 12 | ingreso total (como el Gauss) | réplica de fidelidad |
| `comparable_2014` | 2014 | no | 12 | ingreso corriente | comparación entre años |
| `comparable_2022` | 2022 | no | 13 | ingreso corriente | actualización |
| `replica_2014_13cat`, `comparable_2014_13cat`, `comparable_2022_12cat`, `trim_2022` | | | | | pruebas de §6 y §7 |

### 1.4 Qué NO es este documento

No es un inventario de los errores de nuestra réplica en Python. Esos se encontraron y
corrigieron (N4 a N17; Anexo A), y **no son críticas al estudio original**. Aquí solo se
reportan divergencias entre el programa original y el documento original, y propiedades
del método original.

---

## 2. Qué reproduce la réplica

Configuración `replica_2014`: 8,940 hogares, 46 ciudades.

| resultado | réplica | documento | lectura |
|---|---|---|---|
| **Gini observado** | **0.481** | **0.481** | exacto |
| Categorías con poder de mercado | 9 de 12 (al 99 %) | 9 de 12 al 95 %; 8 al 99 % (Anexo D) | número parecido, composición distinta |
| Rango de β_η | −0.01 a 0.80 | 0.02 a 1.48 | mismo orden de magnitud |
| Elasticidades nacionales (Cuadro 4) | error medio 0.239; 10 de 13 a menos de 0.30 | | parcial |
| Elasticidades por región (Cuadro 5) | 7 de 8 a menos de 0.15 | | replica |
| VE / ingreso, total (mediana, como el programa) | 13.0 % | 14.4 % (Anexo D) · 15.7 % (Cuadro 10) | cerca |
| VE / ingreso, decil 1 → decil 10 | 25.8 % → 4.5 % | 30.9 % → 5.7 % | mismo patrón |
| Reducción del Gini | 5.7 % | 7.3 % | mismo signo, menor |
| Sobreprecio promedio (Cuadro 9) | 35.5 % | 98.23 % | **no replica** |
| Muestra | 8,940 | 15,586 | **no reproducible** (§3, D-C) |

Los sectores significativos de la réplica son tortillas, pan, pollo y huevo, carne de res,
lácteos, frutas, verduras, bebidas y materiales. El documento incluye, en lugar de
bebidas, los dos transportes. Eso importa en §5.

---

## 3. Las divergencias

Once divergencias, todas verificables en el programa. Se agrupan según lo que afectan.

| # | el documento dice | el programa hace | líneas | efecto medido |
|---|---|---|---|---|
| **Estimación** | | | | |
| D-A | estimación en dos etapas, OLS y GMM | solo el bucle OLS de 16 iteraciones | 2452–5753 | los parámetros publicados son OLS |
| D-D | (no lo menciona) | recorta el 1 % de cada cola de la utilidad en cada una de las 16 iteraciones, de forma acumulada | 5671–5722 | se pierde el 28 % de la muestra; ver §6 |
| **Muestra** | | | | |
| D-B | universo: distancia ≤ 400 km y gasto en las categorías | además exige vivienda propia | 1101 | descarta 5,215 hogares (27 %) |
| D-C | 15,586 hogares, 80 % de la ENIGH | ninguna combinación de filtros lo reproduce | — | 12,372 antes del recorte, 8,940 después |
| **Precios** | | | | |
| D-E | índices de precio por categoría | un piso de 0.01 pesos a los gastos nulos entra en los pesos del índice | 1766 y análogas | pesos inventados en categorías poco compradas |
| D-F | categoría "Pan" | solo pan blanco y pan dulce en piezas; el pan industrial queda fuera | 361–363 | un sector concentrado sin medir |
| **Poder de mercado** | | | | |
| D-H | controles de costo específicos por sector (Cuadros 6 y 7) | los mismos controles de ciudad para todos los sectores | 6182–6209 | §4 |
| **Bienestar** | | | | |
| D-I | se restan "los markups estimados" (Cuadro 9, con β_η) | markup = −1/ε, sin β_η | 6345–6385 | §5 |
| D-J | resultados principales al 95 % | umbral de 99 % (el del Anexo D) | 6373 | §5 |
| D-K | "la media de los hogares", en pesos mensuales de octubre de 2015 | mediana, en pesos trimestrales de la encuesta | 6518–6532 | §5 |
| D-L | errores estándar por *subsampling bootstrap* (Politis y Romano) | no hay bootstrap en el programa | — | los intervalos publicados no son reproducibles |
| **Resultado** | | | | |
| D-G | — | tres correcciones verificadas de nuestra réplica alejan los resultados de los publicados | — | Anexo A |

### D-A — El estimador descrito no es el implementado

El documento describe una estimación en dos etapas: OLS para obtener valores iniciales y
GMM para la estimación final. El programa implementa **solo el bucle OLS** (l.2452 a
5753); la palabra GMM no aparece en el código. Los parámetros publicados son los de la
primera etapa.

*Efecto sobre las conclusiones:* ninguno directo sobre los números, porque la réplica usa
el mismo OLS. Pero la sección metodológica describe propiedades (eficiencia,
instrumentos) que los resultados no tienen.

### D-B y D-C — La muestra

El programa descarta a los hogares que no son propietarios de su vivienda (l.1101). Es el
filtro que más elimina, **5,215 hogares, el 27 % de la encuesta**, y el documento no lo
menciona al describir el universo del estudio. El resultado queda sesgado hacia
propietarios, y ese sesgo no se discute.

| filtro | descarta | quedan |
|---|---|---|
| ENIGH 2014 | | 19,124 |
| vivienda propia (no declarado) | 5,215 | 13,909 |
| edad del jefe, tamaño del hogar, gasto mínimo | 1,317 | 12,592 |
| distancia ≤ 400 km | 131 | 12,461 |
| gasto en al menos una categoría | 89 | **12,372** |
| recorte iterativo (D-D, no declarado) | 3,432 | **8,940** |

El documento declara **15,586 hogares**. Sin el filtro de vivienda propia, el universo
sería de 17,151; aplicando al pie de la letra el criterio del documento (gasto en al menos
un alimento *y* en al menos una categoría no alimentaria), de 9,970. Ninguna combinación
llega a 15,586. La muestra con la que se estimó (8,940) es el 57 % de la declarada.

*Efecto sobre las conclusiones:* los resultados son representativos de hogares
propietarios con gasto en las categorías, no "de los hogares mexicanos".

### D-E — El piso numérico en los índices de precio

Para evitar el logaritmo de cero, el programa asigna 0.01 pesos a cada producto que el
hogar no compra (l.1766 y análogas). Ese valor entra después en los pesos del índice de
precios de la categoría. En los hogares que no compran nada de una categoría, todos sus
productos pesan lo mismo:

* **Transporte**: el 71.5 % de los hogares no gasta en autobús ni en avión, y recibe un
  reparto 50/50 entre los dos. La participación real es 73/27.
* **Carne de res**: las vísceras las compra el 2.1 % de los hogares y representan el 3.4 %
  del gasto, pero pesan en promedio el 22.8 % del índice.

*(Medición histórica, agosto de 2026.)* Es la explicación más probable de que carne de
res sea la categoría peor replicada (elasticidad 1.52 contra 0.735 publicada).

### D-F — El pan industrial no está en el estudio

La categoría "Pan" del programa (l.361–363) usa las claves ENIGH de pan blanco (A012) y
pan dulce en piezas (A013). Deja fuera el pan dulce empaquetado (A014) y el pan de caja
(A015), es decir, **el segmento industrial y concentrado**. El CD que acompaña al programa
incluye archivos de precios de pan de caja que el programa nunca carga.

Es una omisión, no una mezcla de mercados. El β_η de "Pan" mide la panadería tradicional:
un mercado atomizado que resulta, de forma contraintuitiva, entre los de mayor poder de
mercado medido. La medición del pan industrial está en §8.

### D-H — Los controles de costo no son específicos por sector

Ver §4.

### D-I — El markup de la pérdida de bienestar no es el markup estimado

Es la divergencia de mayor consecuencia para la interpretación, y no se había documentado.

El documento (ec. 15') generaliza la regla de sobreprecio con el parámetro de poder de
mercado β_η, y en §4 dice que los precios contrafactuales se obtienen *"sustrayendo los
markups estimados"* del Cuadro 9. El programa (l.6345–6385) hace otra cosa: calcula el
sobreprecio del Cuadro 9 con β_η, pero para el bienestar usa **−1/ε**, el markup de
monopolio que implica la elasticidad, **sin β_η**. El β_η estimado solo decide qué
sectores entran (si es significativo); su valor no escala la pérdida.

Sus implicaciones:

1. Un sector con β_η = 0.08 (materiales en la réplica) y uno con β_η = 0.80 (frutas)
   entran con el markup completo de monopolio, siempre que ambos sean significativos.
2. La magnitud de la pérdida depende de las **elasticidades** y de **qué sectores cruzan el
   umbral**, no del poder de mercado estimado.
3. Los sobreprecios del Cuadro 9 (98 % en promedio) y la pérdida del Cuadro 10 (15.7 %)
   **no provienen del mismo markup**.

Medido en §5: si se usa el markup estimado, como describe el documento, la pérdida de 2014
baja de 13.0 % a **7.2 %** del ingreso.

### D-J, D-K y D-L — El programa no produce las cifras publicadas

* **Umbral (D-J).** El programa usa `cdfni(0.99)` = 2.326 (l.6373), que es el criterio del
  **Anexo D** (99 %, Cuadro 16: \$1,414 y 14.4 %). Los resultados del texto principal
  (Cuadro 10: \$1,497 y 15.7 %) usan 95 %. El programa entregado es, al menos en esto, el
  del anexo.
* **Estadístico y unidades (D-K).** El programa reporta **medianas** trimestrales
  (`quantile(VE_2014, 0.5)`, l.6520 y ss.). El documento dice *"el costo en el bienestar
  mensual… en pesos de octubre de 2015, promedio para los hogares fue de \$1,497"*, y los
  pies de los Cuadros 10 y 16 dicen *"la media de los hogares"*.
* **Errores estándar (D-L).** Los Cuadros 10, 16 y 17 reportan errores estándar por
  *subsampling bootstrap*. El programa no contiene ningún remuestreo.

*Efecto sobre las conclusiones:* los cuadros de bienestar publicados salen de un
procesamiento que no está en el código entregado. La réplica puede acercarse a ellos
(§5), pero no reproducirlos.

---

## 4. D-H cuantificado: controles de costo por sector

### Lo que dice el documento y lo que hace el programa

El documento: *"variables de costos de insumos por empresa **específicos para aquellas
ramas de actividad económica relacionadas con cada una de las doce categorías** de
gasto"*; el Cuadro 7 da el mapeo de cada categoría a ramas SCIAN.

El programa (l.6182–6209) carga `indicadores_costos_censos_economicos_2014.asc`, una
matriz de **46 filas (ciudades) por 11 columnas**, sin dimensión de sector. Luego hay
**trece reasignaciones consecutivas** de la matriz de controles, cada una sobrescribe a la
anterior y solo sobrevive la última (siete variables). Todo el bloque está dentro del
bucle de categorías: tortillas, pan, medicamentos y transporte aéreo comparten
exactamente los mismos controles.

### Lo que medimos

Construimos los controles que describe el documento: Censos Económicos por municipio y
rama SCIAN, desde la API de INEGI (años censales 2013 y 2023), con el mapeo del Cuadro 7.
Reestimamos la regresión de poder de mercado de tres maneras:

* `ciudad`: los 7 controles del programa, iguales para todos los sectores;
* `sector7`: 7 controles específicos del sector (mismo número que el programa);
* `sector`: los 11 que declara el Cuadro 6 (4 de mercado y 7 del sector).

| | `ciudad` (7, el programa) | `sector7` (7 del sector) | `sector` (11, Cuadro 6) |
|---|---|---|---|
| **2014, réplica** (`replica_2014`, VE / ingreso total) | | | |
| sectores significativos | 9 de 12 | 9 de 12 | 7 de 12 |
| VE / ingreso | 13.0 % | 13.0 % | 4.3 % |
| reducción del Gini | 5.7 % | 5.7 % | 1.8 % |
| **2014, sin recorte** (`comparable_2014`, VE / ingreso corriente) | | | |
| sectores significativos | 9 de 12 | 8 de 12 | 8 de 12 |
| VE / ingreso | 3.2 % | 5.2 % | 5.2 % |
| reducción del Gini | 2.0 % | 2.7 % | 2.7 % |
| **2022** (`comparable_2022`, VE / ingreso corriente) | | | |
| sectores significativos | 9 de 13 | 10 de 13 | 11 de 13 |
| VE / ingreso | 5.8 % | 2.2 % | 2.2 % |
| reducción del Gini | 2.8 % | 0.8 % | 0.7 % |
| hogares con VE = 0 | 1 % | 23 % | 22 % |

Las regresiones usan entre 44 y 46 ciudades con sus 7 u 11 controles completos, salvo
Transporte foráneo (37 a 43 ciudades). El detalle por categoría, con ciudades × controles
por regresión, está en `Resultados/RESULTADOS.md`.

### Lectura

1. **Con el mismo número de controles, el poder de mercado casi no cambia.** En la réplica
   de 2014, sustituir los 7 controles de ciudad por 7 del sector deja los mismos 9 sectores
   y la misma pérdida (13.0 %). En 2022 los β_η se reordenan sin que ninguno domine (Pan de
   caja 0.94 → 0.84; Materiales 0.51 → 0.60). La hipótesis de que sin controles por sector
   el poder de mercado se sobreestima *por construcción* **no se sostiene**, y eso respalda
   las conclusiones cualitativas del estudio.
2. **Los cambios de la pérdida entre especificaciones los produce un solo sector.** Sin
   recorte, la pérdida de 2014 sube de 3.2 % a 5.2 % y la de 2022 baja de 5.8 % a 2.2 %.
   En ambos casos, lo único que distingue a las dos especificaciones en el cálculo de
   bienestar es **Transporte foráneo**: entra al conjunto significativo en una y no en la
   otra. Quitándolo del cálculo, las dos especificaciones coinciden:

   | | con Transporte foráneo | sin él | hogares con VE = 0 (con → sin) |
   |---|---|---|---|
   | 2014 sin recorte, controles de ciudad | 3.2 % | **5.2 %** (= controles del sector) | 20 % → 5 % |
   | 2022, controles del sector (7) | 2.2 % | **5.8 %** (= controles de ciudad) | 23 % → 1 % |

   El "factor de 2.6" que atribuíamos a D-H en 2022 **no es un efecto de los controles de
   costo**: es Transporte foráneo, precisamente el sector cuya variación de precios no es
   real (§7), activando el problema de cálculo de §5.1.
3. **Lo que sí mueve el resultado es el número de controles.** Con los 11 que declara el
   Cuadro 6 sobre 46 ciudades, en 2014 la pérdida cae de 13.0 % a **4.3 %** y los sectores
   significativos de 9 a 7: salen tortillas y materiales. Con 46 observaciones, cuatro
   regresores más bastan para cambiar qué sectores cruzan el umbral. Encaja con que el
   programa declare once variables y su única línea viva use siete.
4. **Por D-I, los controles afectan la pérdida solo a través del umbral.** El valor de β_η
   no entra en la variación equivalente. Cambiar los controles cambia la pérdida
   únicamente cuando algún sector entra o sale del conjunto significativo, y entonces la
   cambia de golpe.

---

## 5. La magnitud de la pérdida no está identificada

Esta sección junta D-D, D-H, D-I, D-J y D-K. Todas son decisiones que el documento no
discute y que mueven la cifra central. Cada renglón cambia **una** cosa respecto del
programa (`replica_2014`), salvo el último.

VE / ingreso total, ENIGH 2014 (configuración base `replica_2014`; la fila "sin recorte" es
`comparable_2014` con el mismo denominador):

| variante | divergencia | sectores | VE / ingreso | decil 1 | decil 10 | D1/D10 | reducción del Gini |
|---|---|---|---|---|---|---|---|
| **el programa** | — | 9 | **13.0 %** | 25.8 % | 4.5 % | 5.68 | 5.7 % |
| sin recorte iterativo | D-D | 9 | **3.1 %** | 8.2 % | 0.9 % | 8.68 | 1.5 % |
| 11 controles de costo por sector (Cuadro 6) | D-H | 7 | 4.3 % | 10.0 % | 1.6 % | 6.31 | 1.8 % |
| 7 controles de costo por sector | D-H | 9 | 13.0 % | 25.8 % | 4.5 % | 5.68 | 5.7 % |
| umbral de 95 % | D-J | 9 | 13.0 % | 25.8 % | 4.5 % | 5.68 | 5.7 % |
| markup estimado, con β_η | D-I | 9 | 7.2 % | 14.2 % | 2.6 % | 5.50 | 2.9 % |
| media en vez de mediana | D-K | 9 | **16.0 %** | 29.8 % | 5.8 % | 5.18 | 6.3 % |
| **lo que describe el documento** (95 %, β_η, media) | D-I, D-J, D-K | 9 | **9.1 %** | 16.8 % | 3.2 % | 5.22 | 3.3 % |
| *documento, Cuadro 10 (95 %)* | | 9 | *15.7 %* | *30.9 %* | *5.7 %* | *4.42* | *7.3 %* |
| *documento, Anexo D (99 %)* | | 8 | *14.4 %* | | | | |

El umbral no cambia nada en la réplica porque ningún sector tiene su estadístico entre
1.645 y 2.326. En el documento sí cambia: pollo y huevo tiene t = 1.80.

La fila "sin recorte" incluye a Transporte foráneo entre los significativos, y con él el
20 % de los hogares queda con pérdida cero (§5.1). Sin ese sector, la pérdida sin recorte
es 5.0 %.

Tres lecturas:

1. **El intervalo es amplio: de 3.1 % a 16.0 % del ingreso**, con los mismos datos y el
   mismo programa. La cifra de 15.7 % es un punto dentro de un rango que el documento no
   reporta. La reducción del Gini va de 1.5 % a 6.3 %.
2. **Hacer lo que describe el documento no reproduce el documento.** Con el umbral, el
   markup y el estadístico que declara el texto, la pérdida es 9.1 %, no 15.7 %. La
   variante más cercana a lo publicado (16.0 %) es la del programa **con medias**, que
   usa el markup de monopolio que el texto no describe.
3. **El patrón regresivo sobrevive a todo.** En todas las variantes la carga relativa del
   decil 1 es entre 5.2 y 8.7 veces la del decil 10 (4.4 en el documento).

Sobre los pesos: la VE media del programa es de \$4,495 trimestrales, que equivalen a
\$1,498 mensuales, casi exactamente los \$1,497 publicados. Es consistente con que el
documento haya dividido entre tres. No lo tomamos como confirmación: falta el ajuste a
pesos de octubre de 2015, que el documento declara, y la experiencia del proyecto es que
estas coincidencias engañan.

### 5.1 Agregar un sector con poder de mercado puede *reducir* la pérdida calculada

Es una propiedad del cálculo del programa, no una divergencia con el documento, y es la que
explica la lectura 2 de §4.

La pérdida de cada hogar compara el costo de alcanzar su utilidad a precios observados con
el costo a precios contrafactuales, que son los observados menos ln(markup) en los sectores
significativos. Con el markup −1/ε (D-I), un sector de elasticidad baja recibe un markup
enorme: Transporte foráneo tiene elasticidad nacional de 0.17 en 2014 (sin recorte) y 0.55
en 2022, y en el 12 % de los hogares de 2014 su markup choca con el tope de 5 que impone el
programa, es decir, un recorte de precio contrafactual de ln 5 ≈ 1.6.

Medido en 2014 sin recorte (`Codigo/diagnostico_ve_cero.py`), al agregar Transporte
foráneo al cálculo:

* el 16 % de los hogares pasa de una pérdida positiva a **cero** (el programa recorta a cero
  las pérdidas negativas: `VE = max(VE, 0)`);
* el efecto se concentra **por completo** en las ciudades donde el markup de transporte es
  mayor que 1: ahí cae a cero el 35 % de los hogares; donde el markup es 1, ninguno;
* **no depende de que el hogar compre transporte**: compran el 33 % de los que caen a cero y
  el 35 % del resto.

Es decir, ante un recorte de precio tan grande, la función de costo estimada deja de
responder en la dirección correcta para una parte de los hogares. Una hipótesis consistente
con lo medido es que, con cambios de precio de esa magnitud, dominan los términos
cuadráticos en precios del sistema EASI; **no la hemos verificado**.

Consecuencia: **incluir un sector con poder de mercado puede bajar la pérdida total**, que es
lo contrario de lo que el concepto exige. Pasa en 2014 sin recorte (20 % de hogares en cero),
en 2022 con controles del sector (23 %), en 2022 con recorte (89 %, §6.1) y en 2014 con 13
categorías sin recorte (87 %, §6.2). En la réplica fiel al programa no pasa (0 %), porque
Transporte foráneo no resulta significativo.

El documento incluye los dos transportes entre los sectores de su cálculo de bienestar
(§4 del documento). No podemos saber si el problema afectó a sus cifras, porque su programa
no reproduce su conjunto de sectores.

---

## 6. El estimador no escala

El recorte iterativo (D-D) no es un defecto en abstracto: con la muestra de 2014 es inocuo,
y con muestras o sistemas más grandes destruye la identificación. Solo se ve al actualizar
el estudio.

### 6.1 En el tamaño de la muestra

| | 2014, con recorte (`replica_2014`) | 2022, con recorte (`trim_2022`) | 2022, sin recorte (`comparable_2022`) |
|---|---|---|---|
| hogares en la estimación | 8,940 | 41,646 | 57,552 |
| desviación estándar de la utilidad del bucle | 1.17 | **0.43** | 0.77 |
| hogares con efectos ingreso planos (\|f′(u₀)\| < 0.3) | 7 % | **65 %** | 37 % |
| hogares donde converge el solver de Newton | 97 % | 62 % | 86 % |
| elasticidades | [0.44, 1.74] | [0.51, 1.25], 7 de 13 entre 0.88 y 1.08 | [0.55, 1.66] |
| **hogares con VE = 0** | 0 % | **89 %** | 1 % |

Con recorte, 2022 no produce una cifra de bienestar: el 89 % de los hogares queda con
pérdida cero. Entra además Transporte foráneo, el sector cuya variación de precios no es
real (§7).
Incluso sin recorte, el 37 % de los hogares de 2022 tiene efectos ingreso planos, contra el
7 % de 2014. La identificación con la ENIGH moderna es más débil aunque la muestra sea
seis veces mayor.

**Mecanismo.** El recorte elimina las colas de la utilidad en cada iteración. Con 8,940
hogares las colas se regeneran entre iteraciones y la varianza sobrevive; con 57,552 los
cuantiles son estables, el recorte muerde siempre en el mismo lugar y la varianza
colapsa. Sin varianza en ese regresor, los efectos ingreso quedan sin identificar: la
función de costo se vuelve plana en el punto de arranque (columna "planos") y las
elasticidades pierden sentido.

### 6.2 En el número de categorías

Con la muestra de 2014, agregar una sola categoría (pan de caja) con recorte degrada
**todo** el sistema, no solo la categoría nueva:

| ENIGH 2014 | 12 categorías, con recorte (`replica_2014`) | 13 categorías, con recorte (`replica_2014_13cat`) | 13 categorías, sin recorte (`comparable_2014_13cat`) |
|---|---|---|---|
| sectores significativos | 9 de 12 | **4 de 13** | 8 de 13 |
| elasticidad de tortillas | 0.842 | **0.137** | 0.949 |
| β_η de lácteos (t) | 0.578 (7.20) | **−0.011 (−0.15)** | 0.436 (4.80) |
| β_η de pan de caja (t) | — | 0.074 (1.53) | 0.352 (2.56) |
| desviación estándar de la utilidad | 1.31 | 2.84 | 3.46 |
| hogares con efectos ingreso planos | 7.0 % | **28.7 %** | 6.4 % |
| hogares con VE = 0 | 0 % | 0 % | **87 %** |

El sistema pasa de 902 a 1,044 parámetros, y el recorte deja 8.6 observaciones por
parámetro (13.7 sin recorte). Los insumos son idénticos en las dos primeras columnas: el
daño lo producen las iteraciones, no los datos.

Sin recorte, la demanda y el poder de mercado vuelven a estimarse bien, **pero la ruta de
bienestar se rompe**: el 87 % de los hogares queda con pérdida cero y la utilidad llega a
68.6. Con la muestra de 2014, un sistema de 13 categorías no sostiene el cálculo de
bienestar en ninguna de las dos configuraciones. Con la de 2022, sí (§8).

**Implicación práctica.** Cualquier actualización con la ENIGH moderna, o cualquier
extensión que agregue sectores, tiene que desactivar el recorte. Aplicarlo produce
resultados inservibles con apariencia de normalidad. Fue lo que ocurrió en la primera
versión de nuestra actualización a 2022, con las trece elasticidades pegadas a −1.

---

## 7. Un límite del identificador: los precios entre ciudades

El modelo identifica el poder de mercado con la **variación de precios entre las 46
ciudades**. Si esa variación no corresponde a la real, β_η no mide lo que dice medir, por
significativo que resulte.

El estudio construye los precios deflactando un precio de referencia (junio de 2011) con
el INPC de cada ciudad hasta la ventana de la encuesta. Contrastamos esos precios con los
**niveles observados** que INEGI publica para las mismas ciudades y la misma ventana
(`Codigo/auditoria_precios.ipynb`):

| producto | nivel (réplica / observado) 2014 | correlación entre ciudades 2014 | 2022 |
|---|---|---|---|
| Tortillas | 0.97 | **0.97** | 0.89 |
| Pan blanco | 0.95 | 0.90 | 0.85 |
| Manzana | 0.98 | 0.88 | 0.85 |
| Carne de res (bistec) | 0.94 | 0.64 | 0.80 |
| Huevo | 1.07 | 0.70 | 0.68 |
| Leche | 1.02 | 0.55 | 0.61 |
| Transporte aéreo | 0.87 | **0.24** | 0.50 |
| Refrescos | 0.94 | **−0.21** | 0.41 |
| Autobús foráneo | 1.14 | **0.02** | 0.51 |
| Pan de caja | — | — | **0.28** |

**Los niveles son correctos, la estructura entre ciudades no siempre.** En 2014, el precio
de autobús que usa el estudio no tiene relación con el observado (0.02), y el de refrescos
la tiene invertida (−0.21). No es mezcla de productos: separar vuelos nacionales e
internacionales sube la correlación del aéreo solo de 0.20 a 0.25. Es el método: arrastrar
un precio tres años con el índice de cada ciudad no reconstruye la estructura de precios
entre ciudades.

*Efecto sobre las conclusiones:* los β_η de **transporte** y **bebidas** no son
interpretables como poder de mercado. En el documento, los dos transportes están entre los
sectores significativos que entran a la pérdida de bienestar.

---

## 8. Lo que la réplica permite decir de 2022

Con la ENIGH 2022 corrimos el mismo programa, sin recorte (§6) y con el ingreso corriente
como denominador, porque la ENIGH 2022 "Nueva serie" ya no publica el ingreso total. Para
comparar, 2014 se corre igual (`comparable_2014`). Se agrega una categoría: el pan de caja
(D-F).

### 8.1 Poder de mercado

| categoría | β_η 2014 (t) | β_η 2022 (t) | |
|---|---|---|---|
| Pan | 1.011 (9.20)* | 1.315 (7.61)* | el más alto en ambos años |
| **Pan de caja** | — | **0.940 (9.12)*** | nuevo, ver 8.3 |
| Frutas | 0.966 (7.86)* | 0.690 (5.85)* | |
| Materiales de construcción | 0.009 (1.26) | **0.513 (4.74)*** | gana significancia |
| Medicamentos | 0.310 (3.29)* | 0.514 (15.94)* | |
| Tortillas | 0.119 (2.15) | 0.327 (3.34)* | gana significancia |
| Bebidas | 0.272 (3.71)* | 0.272 (5.08)* | no interpretable (§7) |
| Carnes procesadas | 0.197 (1.52) | 0.197 (5.87)* | gana significancia |
| Carne de res | 0.403 (4.16)* | 0.131 (4.62)* | |
| Pollo y huevo | 0.268 (2.71)* | 0.129 (2.27) | pierde significancia |
| Lácteos | 0.726 (5.53)* | 0.057 (0.84) | pierde significancia |
| Verduras | 0.502 (7.77)* | 0.004 (0.07) | pierde significancia |
| Transporte foráneo | 0.032 (2.42)* | 0.280 (1.29) | no interpretable (§7) |
| **significativos** | 9 de 12 | 9 de 13 | |

`*` = significativo al 99 % (t ≥ 2.326), como en el programa. El poder de mercado medido
**se reconfigura** más que crecer parejo: gana en materiales, medicamentos y tortillas,
aparece un sector concentrado nuevo (pan de caja) y retrocede en lácteos, verduras, carne
de res y pollo.

### 8.2 Bienestar

| VE / ingreso corriente | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | total | D1/D10 | reducción del Gini |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 2014 | 8.6 | 6.1 | 5.1 | 4.3 | 3.6 | 3.2 | 2.6 | 2.3 | 1.4 | 1.0 | **3.2 %** | 8.9 | 2.0 % |
| 2022 | 11.0 | 8.6 | 8.0 | 7.3 | 6.7 | 6.0 | 5.4 | 4.7 | 3.8 | 2.4 | **5.8 %** | 4.6 | 2.8 % |

La carga casi se duplica y se vuelve menos regresiva. **El aumento no se debe a haber
agregado pan de caja**: con las mismas 12 categorías que 2014 (`comparable_2022_12cat`), la
pérdida de 2022 es todavía mayor, 7.1 % (D1/D10 = 5.5; reducción del Gini 3.8 %). Agregar
un sector cambia qué otros sectores cruzan el umbral: sin pan de caja, pollo y huevo es
significativo (t = 2.53); con él, no (t = 2.27).

Pero todo lo dicho en §5 aplica, amplificado. En 2022, las mismas variantes de la ruta de
bienestar dan:

| variante | sectores | VE / ingreso | D1/D10 |
|---|---|---|---|
| el programa | 9 | 5.8 % | 4.6 |
| umbral de 95 % (entra pollo y huevo, t = 2.27) | 10 | 6.9 % | 5.4 |
| media en vez de mediana | 9 | 8.0 % | 4.6 |
| markup estimado, con β_η | 9 | 9.2 % | 5.6 |
| lo que describe el documento | 10 | **12.4 %** | 5.5 |
| controles de costo por sector (7 u 11) | 10 u 11 | **2.2 %** | 2.9 a 3.2 |

De 2.2 % a 12.4 % del ingreso. Una afirmación del tipo "la carga pasó de X a Y" solo es
defendible si ambos años se corren con la misma especificación, y aun así el nivel depende
de ella.

**Pero el extremo inferior no es informativo.** El 2.2 % de los controles sectoriales se
debe a que Transporte foráneo entra al cálculo y deja al 23 % de los hogares con pérdida
cero (§5.1). Sin ese sector, la pérdida con controles sectoriales es 5.8 %, igual a la del
programa. Descontado ese artefacto, el rango de 2022 va de **5.8 % a 12.4 %**, un factor de
2.1, y se explica por las divergencias de la ruta de bienestar (D-I, D-J, D-K), no por los
controles de costo.

### 8.3 Pan de caja

| | β_η (t) | elasticidad |
|---|---|---|
| 2014, sin recorte (`comparable_2014_13cat`) | 0.352 (2.56)* | 0.819 |
| 2022 (`comparable_2022`) | 0.940 (9.12)* | 1.271 |

El β_η medido del pan industrial casi se triplica, y en 2022 es el segundo sector después
de la panadería tradicional. **Tres salvedades impiden citarlo como hallazgo firme:**

1. **Los precios se construyen distinto en cada año.** En 2014 no hay precio de referencia
   de pan de caja que se pueda validar: el archivo del CD correlaciona 0.107 con los
   precios de INEGI y el INPC de 2014 no trae su serie. Por eso en 2014 se usan precios
   *observados* de la ventana de la encuesta, y en 2022 el precio de referencia
   *deflactado*, como el resto de las categorías.
2. **En 2022, la variación entre ciudades del precio de pan de caja correlaciona solo 0.28
   con la observada** (§7): es de las más débiles de la auditoría.
3. **En 2014 el sistema de 13 categorías no sostiene el bienestar** (§6.2): el 87 % de los
   hogares queda con pérdida cero.

Lo que sí se sostiene es que **el pan industrial estaba fuera del estudio** (D-F) y que en
2022 tiene un β_η alto y significativo con cualquier especificación de costos (0.84 a 0.94,
t de 9 a 15).

---

## 9. ¿Qué conclusiones sobreviven?

| conclusión del estudio | estado | por qué |
|---|---|---|
| Hay poder de mercado en la mayoría de las categorías | **se sostiene** | 9 de 12 en la réplica, con cualquier especificación de costos con 7 controles |
| Pan y frutas, los de mayor poder de mercado | **se sostiene, con matiz** | los dos más altos en la réplica; pero "Pan" es solo panadería tradicional (D-F) |
| Sobreprecio promedio de 98 % | **no se replica** | 35.5 % en la réplica; además no es el markup que entra al bienestar (D-I) |
| La pérdida es del 15.7 % del ingreso | **no identificada** | entre 3.1 % y 16.0 % según decisiones no reportadas (§5) |
| La pérdida es regresiva | **se sostiene** | en todas las variantes |
| El Gini sería 7.3 % menor | **dirección sí, magnitud no** | entre 1.5 % y 6.3 % en 2014 según la variante (§5) |
| Transporte tiene poder de mercado | **no interpretable** | la variación de precios que lo identifica no es real (§7), y su inclusión distorsiona el cálculo de bienestar (§5.1) |
| Los controles de costo son específicos por sector | **no, aunque con el mismo número de controles casi no importa** | con 7 controles del sector, el poder de mercado y la pérdida quedan prácticamente iguales; con los 11 que declara el Cuadro 6, la pérdida de 2014 cae a 4.3 % (§4) |
| Los resultados describen a los hogares mexicanos | **no** | la muestra efectiva excluye a los no propietarios y es el 57 % de la declarada (D-B, D-C) |

---

## 10. Limitaciones de este documento

* **El programa puede no ser la versión final.** D-J, D-K y D-L sugieren que las cifras
  publicadas salieron de un procesamiento posterior. Si existe otra versión del programa,
  algunas divergencias podrían desaparecer; las de diseño (D-A, D-B, D-H, D-I) no.
* **La muestra no se reproduce** (D-C). Todo lo medido aquí es sobre 12,372 hogares antes
  del recorte, no 15,586.
* **Dos denominadores.** La réplica de 2014 divide por el ingreso total, como el programa
  (l.6519). La comparación con 2022 usa el ingreso corriente, porque la ENIGH 2022 "Nueva
  serie" ya no publica el ingreso total. Son cifras distintas y no deben mezclarse.
* **Carne de res** sigue sin replicarse (1.52 contra 0.735), probablemente por D-E.
* **No evaluamos** la parte del estudio sobre crecimiento económico.

---

## Anexo A — Errores de nuestra réplica, corregidos

No son críticas al estudio original. Se listan porque condicionan la lectura de versiones
anteriores de este trabajo.

| # | error | efecto |
|---|---|---|
| N4 | columnas del archivo de precios leídas como contiguas | transporte aéreo a \$138 en vez de \$2,279 |
| N6 | se descartaban hogares cuya demanda contrafactual subía | sesgo de selección en las elasticidades |
| **N8 / N8b** | **pesos del índice de precios que no sumaban 1** | **elasticidades comprimidas hacia −1** |
| N10, N11, N12 | base del Gini, denominador de la VE, promedio con valores faltantes | Gini 0.448 en vez de 0.481 |
| N13 | el respaldo del solver resolvía a precios originales | hogares sin respuesta al cambio de precio |
| N14 | solver de utilidad | 42 % de hogares con utilidad que no resolvía la ecuación (2022) |
| N15 (2022) | controles de costo asignados por posición | ninguna ciudad recibía sus datos |
| N16 (2022) | base del deflactor: mediana de 2018 en vez de julio | 22 % de factores desviados más de 5 % |
| N17 (2022) | unidades mezcladas dentro de un genérico | 27 de 61 genéricos afectados |

**Coincidencias por razones equivocadas** (la base del criterio de §1.2):

* El denominador de la VE se cambió al ingreso monetario porque daba 15.8 % contra el
  15.7 % publicado. El programa usa el ingreso total.
* La reducción del Gini de 7.3 %, idéntica a la publicada, salía de usar el ingreso
  corriente para el Gini y para la VE. El programa usa el monetario para el primero y el
  total para la segunda; con la combinación correcta da 5.7 %.
* *(Medición histórica, 3 de agosto de 2026; D-G.)* Tres correcciones verificadas (N4,
  N9 y N13) alejaron los resultados de los publicados: el Gini contrafactual pasó de
  0.446, idéntico al publicado, a 0.442, y la VE de 15.8 % a 17.4 %. Es consistente con
  que las cifras publicadas incorporen errores que se compensan.

## Anexo B — Reproducibilidad

Desde el directorio que contiene `Replica_COFECE/`:

```
/usr/bin/python3 Replica_COFECE/Codigo/congelar_resultados.py      # todas las cifras (≈40 min)
/usr/bin/python3 Replica_COFECE/Codigo/run_nb.py auditoria_precios.ipynb   # §7
/usr/bin/python3 Replica_COFECE/Codigo/diagnostico_ve_cero.py               # §5.1
```

`Resultados/RESULTADOS.md` contiene todas las tablas de este documento con su diagnóstico
(ciudades × controles por regresión). El programa Gauss original y sus archivos están en
`CD/`. Los microdatos de INEGI no se versionan.
