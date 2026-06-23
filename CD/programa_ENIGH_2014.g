/*Esta version del programa tiene la version final de las regiones geograficas (clave numerica en parentesis):
1.- NOROESTE (seis): Baja California(2), Baja California Sur(3), Chihuahua(8), Durango(10), Sinaloa(25), Sonora(26)
2.- NORESTE (tres): Coahuila(5), Nuevo Leon(19), Tamaulipas(28)
3.- CENTRO_NORTE (cinco): Aguascalientes(1), Guanajuato(11), Queretaro(22), San Luis Potosi(24), Zacatecas(32)
4.- CENTRO_SUR (tres): Ciudad de Mexico(9), Estado de Mexico(15), Morelos(17)
5.- SUROESTE (tres): Chiapas(7), Guerrero(12), Oaxaca(20)
6.- SURESTE (cuatro): Campeche(4), Quintana Roo(23), Tabasco(27), Yucatan(31)
7.- OESTE (cuatro): Colima(6), Jalisco(14), Michoacan(16), Nayarit(18)
8.- ESTE (cuatro): Hidalgo(13), Puebla(21), Tlaxcala(29), Veracruz(30)*/

/*DESCRIPCION DE LAS CARACTERISTICAS DE LOS HOGARES EN EL ARCHIVO DE CONCENTRADO HOGARES*/ 
/*1	folioviv
2	ubica_geo
3	tam_loc
4	est_socio
5	est_dis
6	upm
7	factor_hog
8	clase_hog
9	sexo_jefe
10	edad_jefe
11	educa_jefe
12	tot_integ
13	hombres
14	mujeres
15	mayores
16	menores
17	p12_64
18	p65mas
19	ocupados
20	percep_ing
21	perc_ocupa
22	ing_total
23	ing_cor
24	ing_mon
25	trabajo
26	sueldos
27	horas_extr
28	comisiones
29	otra_rem
30	negocio
31	noagrop
32	industria
33	comercio
34	servicios
35	agrope
36	agricolas
37	pecuarios
38	reproducc
39	pesca
40	otros_trab
41	rentas
42	utilidad
43	arrenda
44	transfer
45	jubilacion
46	becas
47	donativos
48	remesas
49	bene_gob
50	otros_ing
51	gasto_nom
52	autoconsum
53	remu_espec
54	transf_esp
55	transf_hog
56	trans_inst
57	estim_alqu
58	percep_tot
59	percep_mon
60	retiro_inv
61	prestamos
62	otras_perc
63	erogac_nom
64	gasto_tot
65	gasto_cor
66	gasto_mon
67	alimentos
68	ali_dentro
69	cereales
70	carnes
71	pescado
72	leche
73	huevo
74	aceites
75	tuberculo
76	verduras
77	frutas
78	azucar
79	cafe
80	especias
81	otros_alim
82	bebidas
83	ali_fuera
84	tabaco
85	vesti_calz
86	vestido
87	calzado
88	vivienda
89	alquiler
90	pred_cons
91	agua
92	energia
93	limpieza
94	cuidados
95	utensilios
96	enseres
97	salud
98	atenc_ambu
99	hospital
100	medicinas
101	transporte
102	publico
103	foraneo
104	adqui_vehi
105	mantenim
106	refaccion
107	combus
108	comunica
109	educa_espa
110	educacion
111	esparci
112	paq_turist
113	personales
114	cuida_pers
115	acces_pers
116	otros_gas
117	transf_gas
118	erogac_tot
119	erogac_mon
120	cuota_viv
121	mater_serv
122	material
123	servicio
124	deposito
125	prest_terc
126	pago_tarje
127	deudas
128	balance
129	otras_erog
130	smg
131	entidad_federativa
132	clave_municipio
133	clave_localidad*/


tinit=hsec;

/* CLAVES DE ENTIDADES FEDERATIVAS
1	Aguascalientes
2	Baja California
3	Baja California Sur
4	Campeche
5	Coahuila de Zaragoza
6	Colima
7	Chiapas
8	Chihuahua
9	Distrito Federal
10	Durango
11	Guanajuato
12	Guerrero
13	Hidalgo
14	Jalisco
15	MÃ©xico
16	MichoacÃ¡n de Ocampo
17	Morelos
18	Nayarit
19	Nuevo LeÃ³n
20	Oaxaca
21	Puebla
22	QuerÃ©taro
23	Quintana Roo
24	San Luis PotosÃ­
25	Sinaloa
26	Sonora
27	Tabasco
28	Tamaulipas
29	Tlaxcala
30	Veracruz de Ignacio de la Llave
31	YucatÃ¡n
32	Zacatecas*/


INPC_octubre_2014=114.5690;
INPC_octubre_2015=117.410;
factor_inflac_2014=INPC_octubre_2015/INPC_octubre_2014;

/*VARIABLES:
1.- folioviv: Identificador de la vivienda 
2.- clave NUMERICA: Clave de gasto numerica	
3.- gasto_tri: gasto trimestral monetario	
4.- GASTO_TOTAL_TRIMESTRAL: gasto total trimestral monetario y no monetario (incluye pago en especie)	
5.- mes: mes de la compra, N/A=0	
6.- lugar_comp: lugar de la compra. valores van de 0 a 18, ver manual INEGI. 15=Diconsa, 16=Liconsa. 	
7.- orga_inst: organizacion o institucion proveedora. Valores van de 0 a 8. OPORTUNIDADES=5, Liconsa=7, Diconsa=8	
8.- cantidad: numero de unidades recibidas por parte de alguna institucion a un precio menor o sin costo (N/A=-1) 	
9.- inst1: Institucion publica o privada que proporciona productos y servicios de salud. Valores van de 1 a 13. 12=PROGESA U OPORTUNIDADES (N/A=0) 	
10.- inst2: Institucion publica o privada que proporciona productos y servicios de salud. Valores van de 1 a 13. 12=PROGESA U OPORTUNIDADES (N/A=0) 	
NOTAR: No esta clara la diferencia entre inst1 y inst2. Usar ambas para detectar acceso a OPORTUNIDADES*/ 
symmetry_imposed=1;

library optmum, pgraph;
optset;
__output=0;

/*library maxlik;*/


load INPP_CONSTRUCCION_46[4968,6]=inpp_construccion_46_ciudades.asc; 
inpp_mat_46_fecha=INPP_CONSTRUCCION_46[.,1];
inpp_mat_46_estado=INPP_CONSTRUCCION_46[.,2];
inpp_mat_46_municipio=INPP_CONSTRUCCION_46[.,3];
inpp_mat_46_latitud=INPP_CONSTRUCCION_46[.,4]*pi/180; /*(en radianes)*/
inpp_mat_46_longitud=INPP_CONSTRUCCION_46[.,5]*pi/180; /*(en radianes)*/
inpp_mat_46_materiales=INPP_CONSTRUCCION_46[.,6];


load INPC_46[4968,66]=inpc_46_ciudades.asc; 
/*VARIABLES EN ORDEN:
1.-	FECHA (AAAA.MM)
2.-	CLAVE ESTADO
3.-	CLAVE MUNICIPIO
4.-	LATITUD (EN GRADOS)
5.-	LONGITUD (EN GRADOS)
6.-	TORTILLA
7.-	PAN DULCE
8.-	PAN BLANCO
9.-	POLLO
10.-CARNE DE RES
11.-VISCERAS DE RES
12.-CHORIZO
13.-JAMON
14.-SALCHICHAS
15.-TOCINO
16.-LECHE PASTEURIZADA
17.-LECHE EN POLVO
18.-LECHE EVAPORADA Y CONDENSADA
19.-QUESO FRESCO
20.-QUESO OAXACA
21.-CREMA DE LECHE
22.-QUESO MANCHEGO
23.-MANTEQUILLA
24.-QUESO AMARILLO
25.-HUEVO
26.-MANZANA
27.-PLATANOS
28.-AGUACATE
29.-PAPAYA
30.-NARANJA
31.-LIMON
32.-MELON
33.-UVA
34.-PERA
35.-GUAYABA
36.-DURAZNO
37.-SANDIA
38.-PINA
39.-JITOMATE
40.-PAPA
41.-CEBOLLA
42.-TOMATE VERDE
43.-LECHUGA Y COL
44.-CALABACITA
45.-ZANAHORIA
46.-CHILE SERRANO
47.-NOPALES
48.-CHAYOTE
49.-CHILE POBLANO
50.-PEPINO
51.-EJOTES
52.-CHICHARO
53.-FRIJOL
54.-JUGOS Y NECTARES
55.-REFRESCOS
56.-AGUA EMBOTELLADA
57.-ANTIBIOTICOS
58.-CARDIOVASCULARES
59.-ANALGESICOS
60.-NUTRICIONALES
61.-GASTROINTESTINALES
62.-ANTIGRIPALES
63.-MEDICINA PARA LA TOS
64.-MEDICINAS PARA LA PIEL
65.-AUTOBUS FORANEO
66.-TRANSPORTE AEREO*/

inpc_46_fecha=INPC_46[.,1];
inpc_46_estado=INPC_46[.,2];
inpc_46_municipio=INPC_46[.,3];
inpc_46_latitud=INPC_46[.,4]*pi/180; /*(en radianes)*/
inpc_46_longitud=INPC_46[.,5]*pi/180; /*(en radianes)*/
inpc_46_tortilla=INPC_46[.,6];
inpc_46_pan_dulce=INPC_46[.,7];
inpc_46_pan_blanco=INPC_46[.,8];
inpc_46_pollo=INPC_46[.,9];
inpc_46_carne_res=INPC_46[.,10];
inpc_46_visceras_res=INPC_46[.,11];
inpc_46_chorizo=INPC_46[.,12];
inpc_46_jamon=INPC_46[.,13];
inpc_46_salchichas=INPC_46[.,14];
inpc_46_tocino=INPC_46[.,15];
inpc_46_leche_pasteurizada=INPC_46[.,16];
inpc_46_leche_en_polvo=INPC_46[.,17];
inpc_46_leche_evaporada=INPC_46[.,18];
inpc_46_queso_fresco=INPC_46[.,19];
inpc_46_queso_oaxaca=INPC_46[.,20];
inpc_46_crema_de_leche=INPC_46[.,21];
inpc_46_queso_manchego=INPC_46[.,22];
inpc_46_mantequilla=INPC_46[.,23];
inpc_46_queso_amarillo=INPC_46[.,24];
inpc_46_huevo=INPC_46[.,25];
inpc_46_manzana=INPC_46[.,26];
inpc_46_platano=INPC_46[.,27];
inpc_46_aguacate=INPC_46[.,28];
inpc_46_papaya=INPC_46[.,29];
inpc_46_naranja=INPC_46[.,30];
inpc_46_limon=INPC_46[.,31];
inpc_46_melon=INPC_46[.,32];
inpc_46_uva=INPC_46[.,33];
inpc_46_pera=INPC_46[.,34];
inpc_46_guayaba=INPC_46[.,35];
inpc_46_durazno=INPC_46[.,36];
inpc_46_sandia=INPC_46[.,37];
inpc_46_pina=INPC_46[.,38];
inpc_46_jitomate=INPC_46[.,39];
inpc_46_papa=INPC_46[.,40];
inpc_46_cebolla=INPC_46[.,41];
inpc_46_tomate_verde=INPC_46[.,42];
inpc_46_lechuga_col=INPC_46[.,43];
inpc_46_calabacita=INPC_46[.,44];
inpc_46_zanahoria=INPC_46[.,45];
inpc_46_chile_serrano=INPC_46[.,46];
inpc_46_nopales=INPC_46[.,47];
inpc_46_chayote=INPC_46[.,48];
inpc_46_chile_poblano=INPC_46[.,49];
inpc_46_pepino=INPC_46[.,50];
inpc_46_ejotes=INPC_46[.,51];
inpc_46_chicharo=INPC_46[.,52];
inpc_46_frijol=INPC_46[.,53];
inpc_46_jugos_nectares=INPC_46[.,54];
inpc_46_refrescos=INPC_46[.,55];
inpc_46_agua_embotellada=INPC_46[.,56];
inpc_46_antibioticos=INPC_46[.,57];
inpc_46_cardiovasculares=INPC_46[.,58];
inpc_46_analgesicos=INPC_46[.,59];
inpc_46_nutricionales=INPC_46[.,60];
inpc_46_gastrointestinales=INPC_46[.,61];
inpc_46_antigripales=INPC_46[.,62];
inpc_46_medicina_tos=INPC_46[.,63];
inpc_46_medicina_piel=INPC_46[.,64];
inpc_46_autobus_foraneo=INPC_46[.,65];
inpc_46_transporte_aereo=INPC_46[.,66];

load PRECIOS_PROMEDIO_46[46,70]=precios_promedio_46_ciudades_junio_2011.asc; 

/*
1.-	Clave_Estado
2.-	Clave_Municipio
3.-	Latitud (en grados)
4.-	Longitud (en grados)
5.-	Tortillas de Maiz (A004)->(1004) 
6.-	Pan Blanco (A012)->(1012)
7.-	Pan Dulce (A013)->(1013)
8.-	Pollo Entero (A059)->(1059)
9.-	Pollo En Piezas Con Hueso (A057)->(1057)
10.-Huevo (A093)->(1093)
11.-Bistec de Res (A025)->(1025)
12.-Molida de Res (A034)->(1034)
13.-Visceras de Res (A037)->(1037)
14.-Chorizo (A049)->(1049)
15.-Jamon (A052)->(1052)
16.-Salchichas (A055)->(1055)
17.-Tocino (A054)->(1054)
18.-Leche Pasteurizada (A075)->(1075) 
19.-Leche en Polvo (A078)->(1078)
20.-Leche Maternizada (A079)->(1079)
21.-Leche Condensada y Evaporada (A076)->(1076)
22.-Queso Fresco (A085)->(1085)
23.-Queso Oaxaca o Asadero (A087)->(1087)
24.-Queso Amarillo (A082)->(1082)
25.-Crema de Leche (A089)->(1089)
26.-Mantequilla (A090)->(1090)
27.-Manzana (A158)->(1158)
28.-Platano (A166)->(1166)
29.-Aguacate (A108)->(1108)
30.-Papaya (A161)->(1161)
31.-Naranja (A160)->(1160)
32.-Limon (A154)->(1154)
33.-Melon (A159)->(1159)
34.-Uvas (A169)->(1169)
35.-Pera (A162)->(1162)
36.-Guayaba (A152)->(1152)
37.-Sandia (A168)->(1168)
38.-Pina (A163)->(1163)
39.-Jitomate (A124)->(1124)
40.-Papa (A102)->(1102)
41.-Cebolla (A112)->(1112)
42.-Tomate Verde (A129)->(1129)
43.-Col (A120)->(1120)
44.-Lechuga (A125)->(1125)
45.-Calabacita (A111)->(1111)
46.-Zanahoria (A130)->(1130)
47.-Chile Serrano (A117)->(1117)
48.-Nopal (A126)->(1126)
49.-Chayote (A113)->(1113)
50.-Chile Poblano (A116)->(1116)
51.-Pepino (A127)->(1127)
52.-Ejotes (A121)->(1121)
53.-Chicharo (A114)->(1114)
54.-Frijol (A137)->(1137)
55.-Jugos o Nectares Envasados (A218)->(1218)
56.-Refrescos Envasados (A220)->(1220)
57.-Agua Embotellada (A215)->(1215)
58.-Antibioticos (J028+J052)->(10028+10052)
59.-Medicamentos Cardiovasculares (J031+J056)->(10031+10056)
60.-Analgesicos (J026+J050)->(10026+10050)
61.-Nutricionales (J033+J055)->(10033+10055)
62.-Medicina para Diabetes (NO LO INCLUIMOS PORQUE NO HAY SERIE DE INPC PARA EL 2006)
63.-Medicina Gastrointestinal (J020+J044)->(10020+10044)
64.-Antigripales (J021+J045)->(10021+10045)
65.-Antiinflamatorios (NO LO INCLUIMOS PORQUE NO HAY SERIE DE INPC PARA EL 2006)
66.-Medicinas para Alergias (NO LO INCLUIMOS PORQUE NO HAY SERIE DE INPC PARA EL 2006)
67.-Medicina para la tos (J024+J048)->(10024+10048)
68.-Medicina para la Piel (J022+J046)->(10022+10046)
69.-Transporte Autobus Foraneo (B006)->(2006)
70.-Transporte Aereo (M003)->(13003)
*/

precios_46_estado=PRECIOS_PROMEDIO_46[.,1];
precios_46_municipio=PRECIOS_PROMEDIO_46[.,2];
precios_46_latitud=PRECIOS_PROMEDIO_46[.,3]*pi/180; /*(en radianes)*/
precios_46_longitud=PRECIOS_PROMEDIO_46[.,4]*pi/180; /*(en radianes)*/
precios_46_tortillas=PRECIOS_PROMEDIO_46[.,5];
precios_46_pan_blanco=PRECIOS_PROMEDIO_46[.,6];
precios_46_pan_dulce=PRECIOS_PROMEDIO_46[.,7];
precios_46_pollo_entero=PRECIOS_PROMEDIO_46[.,8];
precios_46_pollo_piezas=PRECIOS_PROMEDIO_46[.,9];
precios_46_huevo=PRECIOS_PROMEDIO_46[.,10];
precios_46_bistec_res=PRECIOS_PROMEDIO_46[.,11];
precios_46_molida_res=PRECIOS_PROMEDIO_46[.,12];
precios_46_visceras_res=PRECIOS_PROMEDIO_46[.,13];
precios_46_chorizo=PRECIOS_PROMEDIO_46[.,14];
precios_46_jamon=PRECIOS_PROMEDIO_46[.,15];
precios_46_salchichas=PRECIOS_PROMEDIO_46[.,16];
precios_46_tocino=PRECIOS_PROMEDIO_46[.,17];
precios_46_leche_pasteurizada=PRECIOS_PROMEDIO_46[.,18];
precios_46_leche_en_polvo=PRECIOS_PROMEDIO_46[.,19];
precios_46_leche_maternizada=PRECIOS_PROMEDIO_46[.,20];
precios_46_leche_condensada=PRECIOS_PROMEDIO_46[.,21];
precios_46_queso_fresco=PRECIOS_PROMEDIO_46[.,22];
precios_46_queso_oaxaca=PRECIOS_PROMEDIO_46[.,23];
precios_46_queso_amarillo=PRECIOS_PROMEDIO_46[.,24];
precios_46_crema_de_leche=PRECIOS_PROMEDIO_46[.,25];
precios_46_mantequilla=PRECIOS_PROMEDIO_46[.,26];
precios_46_manzana=PRECIOS_PROMEDIO_46[.,27];
precios_46_platanos=PRECIOS_PROMEDIO_46[.,28];
precios_46_aguacate=PRECIOS_PROMEDIO_46[.,29];
precios_46_papaya=PRECIOS_PROMEDIO_46[.,30];
precios_46_naranja=PRECIOS_PROMEDIO_46[.,31];
precios_46_limon=PRECIOS_PROMEDIO_46[.,32];
precios_46_melon=PRECIOS_PROMEDIO_46[.,33];
precios_46_uvas=PRECIOS_PROMEDIO_46[.,34];
precios_46_pera=PRECIOS_PROMEDIO_46[.,35];
precios_46_guayaba=PRECIOS_PROMEDIO_46[.,36];
precios_46_sandia=PRECIOS_PROMEDIO_46[.,37];
precios_46_pina=PRECIOS_PROMEDIO_46[.,38];
precios_46_jitomate=PRECIOS_PROMEDIO_46[.,39];
precios_46_papa=PRECIOS_PROMEDIO_46[.,40];
precios_46_cebolla=PRECIOS_PROMEDIO_46[.,41];
precios_46_tomate_verde=PRECIOS_PROMEDIO_46[.,42];
precios_46_col=PRECIOS_PROMEDIO_46[.,43];
precios_46_lechuga=PRECIOS_PROMEDIO_46[.,44];
precios_46_calabacita=PRECIOS_PROMEDIO_46[.,45];
precios_46_zanahoria=PRECIOS_PROMEDIO_46[.,46];
precios_46_chile_serrano=PRECIOS_PROMEDIO_46[.,47];
precios_46_nopales=PRECIOS_PROMEDIO_46[.,48];
precios_46_chayote=PRECIOS_PROMEDIO_46[.,49];
precios_46_chile_poblano=PRECIOS_PROMEDIO_46[.,50];
precios_46_pepino=PRECIOS_PROMEDIO_46[.,51];
precios_46_ejotes=PRECIOS_PROMEDIO_46[.,52];
precios_46_chicharo=PRECIOS_PROMEDIO_46[.,53];
precios_46_frijol=PRECIOS_PROMEDIO_46[.,54];
precios_46_jugos_nectares=PRECIOS_PROMEDIO_46[.,55];
precios_46_refrescos_envasados=PRECIOS_PROMEDIO_46[.,56];
precios_46_agua_embotellada=PRECIOS_PROMEDIO_46[.,57];
precios_46_antibioticos=PRECIOS_PROMEDIO_46[.,58];
precios_46_cardiovasculares=PRECIOS_PROMEDIO_46[.,59];
precios_46_analgesicos=PRECIOS_PROMEDIO_46[.,60];
precios_46_nutricionales=PRECIOS_PROMEDIO_46[.,61];
precios_46_gastrointestinales=PRECIOS_PROMEDIO_46[.,63];
precios_46_antigripales=PRECIOS_PROMEDIO_46[.,64];
precios_46_medicinas_tos=PRECIOS_PROMEDIO_46[.,67];
precios_46_medicinas_piel=PRECIOS_PROMEDIO_46[.,68];
precios_46_autobus_foraneo=PRECIOS_PROMEDIO_46[.,69];
precios_46_transporte_aereo=PRECIOS_PROMEDIO_46[.,70];
precios_46_materiales=ones(46,1)*100;
fecha_2011=2011.06;
fecha_inicial_2014=2014.08;
fecha_final_2014=2014.11;
P_46_tortillas_2014=zeros(46,1);
P_46_pan_blanco_2014=zeros(46,1);
P_46_pan_dulce_2014=zeros(46,1);
P_46_pollo_entero_2014=zeros(46,1);
P_46_pollo_piezas_2014=zeros(46,1);
P_46_huevo_2014=zeros(46,1);
P_46_bistec_res_2014=zeros(46,1);
P_46_molida_res_2014=zeros(46,1);
P_46_visceras_res_2014=zeros(46,1);
P_46_chorizo_2014=zeros(46,1);
P_46_jamon_2014=zeros(46,1);
P_46_salchichas_2014=zeros(46,1);
P_46_tocino_2014=zeros(46,1);
P_46_leche_pasteurizada_2014=zeros(46,1);
P_46_leche_en_polvo_2014=zeros(46,1);
P_46_leche_maternizada_2014=zeros(46,1);
P_46_leche_condensada_2014=zeros(46,1);
P_46_queso_fresco_2014=zeros(46,1);
P_46_queso_oaxaca_2014=zeros(46,1);
P_46_queso_amarillo_2014=zeros(46,1);
P_46_crema_de_leche_2014=zeros(46,1);
P_46_mantequilla_2014=zeros(46,1);
P_46_manzana_2014=zeros(46,1);
P_46_platanos_2014=zeros(46,1);
P_46_aguacate_2014=zeros(46,1);
P_46_papaya_2014=zeros(46,1);
P_46_naranja_2014=zeros(46,1);
P_46_limon_2014=zeros(46,1);
P_46_melon_2014=zeros(46,1);
P_46_uvas_2014=zeros(46,1);
P_46_pera_2014=zeros(46,1);
P_46_guayaba_2014=zeros(46,1);
P_46_sandia_2014=zeros(46,1);
P_46_pina_2014=zeros(46,1);
P_46_jitomate_2014=zeros(46,1);
P_46_papa_2014=zeros(46,1);
P_46_cebolla_2014=zeros(46,1);
P_46_tomate_verde_2014=zeros(46,1);
P_46_col_2014=zeros(46,1);
P_46_lechuga_2014=zeros(46,1);
P_46_calabacita_2014=zeros(46,1);
P_46_zanahoria_2014=zeros(46,1);
P_46_chile_serrano_2014=zeros(46,1);
P_46_nopales_2014=zeros(46,1);
P_46_chayote_2014=zeros(46,1);
P_46_chile_poblano_2014=zeros(46,1);
P_46_pepino_2014=zeros(46,1);
P_46_ejotes_2014=zeros(46,1);
P_46_chicharo_2014=zeros(46,1);
P_46_frijol_2014=zeros(46,1);
P_46_jugos_nectares_2014=zeros(46,1);
P_46_refrescos_envasados_2014=zeros(46,1);
P_46_agua_embotellada_2014=zeros(46,1);
P_46_antibioticos_2014=zeros(46,1);
P_46_cardiovasculares_2014=zeros(46,1);
P_46_analgesicos_2014=zeros(46,1);
P_46_nutricionales_2014=zeros(46,1);
P_46_gastrointestinales_2014=zeros(46,1);
P_46_antigripales_2014=zeros(46,1);
P_46_medicinas_tos_2014=zeros(46,1);
P_46_medicinas_piel_2014=zeros(46,1);
P_46_autobus_foraneo_2014=zeros(46,1);
P_46_transporte_aereo_2014=zeros(46,1);
P_46_materiales_2014=zeros(46,1);


i=1;
do while i .le 46;
P_46_tortillas_2014[i]=
quantile(precios_46_tortillas[i]*selif(inpc_46_tortilla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_tortilla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq  fecha_2011)), 0.5);	
	
P_46_pan_blanco_2014[i]=
quantile(precios_46_pan_blanco[i]*selif(inpc_46_pan_blanco, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pan_blanco, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq  fecha_2011)), 0.5);	
	
P_46_pan_dulce_2014[i]=
quantile(precios_46_pan_dulce[i]*selif(inpc_46_pan_dulce, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pan_dulce, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq  fecha_2011)), 0.5);	
	
P_46_pollo_entero_2014[i]=
quantile(precios_46_pollo_entero[i]*selif(inpc_46_pollo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pollo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq  fecha_2011)), 0.5);	
	
P_46_pollo_piezas_2014[i]=
quantile(precios_46_pollo_piezas[i]*selif(inpc_46_pollo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pollo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq  fecha_2011)), 0.5);

P_46_huevo_2014[i]=
quantile(precios_46_huevo[i]*selif(inpc_46_huevo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_huevo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq  fecha_2011)), 0.5);

P_46_bistec_res_2014[i]=
quantile(precios_46_bistec_res[i]*selif(inpc_46_carne_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_carne_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq  fecha_2011)), 0.5);

P_46_molida_res_2014[i]=
quantile(precios_46_molida_res[i]*selif(inpc_46_carne_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_carne_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq  fecha_2011)), 0.5);

P_46_visceras_res_2014[i]=
quantile(precios_46_visceras_res[i]*selif(inpc_46_visceras_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_visceras_res, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq  fecha_2011)), 0.5);

P_46_chorizo_2014[i]=
quantile(precios_46_chorizo[i]*selif(inpc_46_chorizo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_chorizo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq  fecha_2011)), 0.5);

P_46_jamon_2014[i]=
quantile(precios_46_jamon[i]*selif(inpc_46_jamon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_jamon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_salchichas_2014[i]=
quantile(precios_46_salchichas[i]*selif(inpc_46_salchichas, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_salchichas, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_tocino_2014[i]=
quantile(precios_46_tocino[i]*selif(inpc_46_tocino, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./	selif(inpc_46_tocino, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_leche_pasteurizada_2014[i]=
quantile(precios_46_leche_pasteurizada[i]*selif(inpc_46_leche_pasteurizada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_leche_pasteurizada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_leche_en_polvo_2014[i]=
quantile(precios_46_leche_en_polvo[i]*selif(inpc_46_leche_en_polvo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_leche_en_polvo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_leche_maternizada_2014[i]=
quantile(precios_46_leche_maternizada[i]*selif(inpc_46_leche_evaporada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_leche_evaporada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_leche_condensada_2014[i]=
quantile(precios_46_leche_condensada[i]*selif(inpc_46_leche_evaporada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_leche_evaporada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_queso_fresco_2014[i]=
quantile(precios_46_queso_fresco[i]*selif(inpc_46_queso_fresco, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_queso_fresco, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_queso_oaxaca_2014[i]=
quantile(precios_46_queso_oaxaca[i]*selif(inpc_46_queso_oaxaca, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_queso_oaxaca, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_queso_amarillo_2014[i]=
quantile(precios_46_queso_amarillo[i]*selif(inpc_46_queso_amarillo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_queso_amarillo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_crema_de_leche_2014[i]=
quantile(precios_46_crema_de_leche[i]*selif(inpc_46_crema_de_leche, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_crema_de_leche, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_mantequilla_2014[i]=
quantile(precios_46_mantequilla[i]*selif(inpc_46_mantequilla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_mantequilla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_manzana_2014[i]=
quantile(precios_46_manzana[i]*selif(inpc_46_manzana, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_manzana, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_platanos_2014[i]=
quantile(precios_46_platanos[i]*selif(inpc_46_platano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_platano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_aguacate_2014[i]=
quantile(precios_46_aguacate[i]*selif(inpc_46_aguacate, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_aguacate, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_papaya_2014[i]=
quantile(precios_46_papaya[i]*selif(inpc_46_papaya, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_papaya, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_naranja_2014[i]=
quantile(precios_46_naranja[i]*selif(inpc_46_naranja, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_naranja, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_limon_2014[i]=
quantile(precios_46_limon[i]*selif(inpc_46_limon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_limon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_melon_2014[i]=
quantile(precios_46_melon[i]*selif(inpc_46_melon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_melon, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_uvas_2014[i]=
quantile(precios_46_uvas[i]*selif(inpc_46_uva, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_uva, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_pera_2014[i]=
quantile(precios_46_pera[i]*selif(inpc_46_pera, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pera, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_guayaba_2014[i]=
quantile(precios_46_guayaba[i]*selif(inpc_46_guayaba, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_guayaba, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_sandia_2014[i]=
quantile(precios_46_sandia[i]*selif(inpc_46_sandia, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_sandia, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_pina_2014[i]=
quantile(precios_46_pina[i]*selif(inpc_46_pina, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pina, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_jitomate_2014[i]=
quantile(precios_46_jitomate[i]*selif(inpc_46_jitomate, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_jitomate, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_papa_2014[i]=
quantile(precios_46_papa[i]*selif(inpc_46_papa, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_papa, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_cebolla_2014[i]=
quantile(precios_46_cebolla[i]*selif(inpc_46_cebolla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_cebolla, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_tomate_verde_2014[i]=
quantile(precios_46_tomate_verde[i]*selif(inpc_46_tomate_verde, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_tomate_verde, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_col_2014[i]=
quantile(precios_46_col[i]*selif(inpc_46_lechuga_col, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_lechuga_col, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_lechuga_2014[i]=
quantile(precios_46_lechuga[i]*selif(inpc_46_lechuga_col, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_lechuga_col, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_calabacita_2014[i]=
quantile(precios_46_calabacita[i]*selif(inpc_46_calabacita, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_calabacita, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_zanahoria_2014[i]=
quantile(precios_46_zanahoria[i]*selif(inpc_46_zanahoria, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_zanahoria, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_chile_serrano_2014[i]=
quantile(precios_46_chile_serrano[i]*selif(inpc_46_chile_serrano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_chile_serrano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_nopales_2014[i]=
quantile(precios_46_nopales[i]*selif(inpc_46_nopales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_nopales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_chayote_2014[i]=
quantile(precios_46_chayote[i]*selif(inpc_46_chayote, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_chayote, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_chile_poblano_2014[i]=
quantile(precios_46_chile_poblano[i]*selif(inpc_46_chile_poblano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_chile_poblano, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_pepino_2014[i]=
quantile(precios_46_pepino[i]*selif(inpc_46_pepino, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_pepino, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_ejotes_2014[i]=
quantile(precios_46_ejotes[i]*selif(inpc_46_ejotes, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_ejotes, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_chicharo_2014[i]=
quantile(precios_46_chicharo[i]*selif(inpc_46_chicharo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_chicharo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_frijol_2014[i]=
quantile(precios_46_frijol[i]*selif(inpc_46_frijol, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_frijol, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_jugos_nectares_2014[i]=
quantile(precios_46_jugos_nectares[i]*selif(inpc_46_jugos_nectares, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_jugos_nectares, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_refrescos_envasados_2014[i]=
quantile(precios_46_refrescos_envasados[i]*selif(inpc_46_refrescos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_refrescos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_agua_embotellada_2014[i]=
quantile(precios_46_agua_embotellada[i]*selif(inpc_46_agua_embotellada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_agua_embotellada, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_antibioticos_2014[i]=
quantile(precios_46_antibioticos[i]*selif(inpc_46_antibioticos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_antibioticos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_cardiovasculares_2014[i]=
quantile(precios_46_cardiovasculares[i]*selif(inpc_46_cardiovasculares, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_cardiovasculares, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_analgesicos_2014[i]=
quantile(precios_46_analgesicos[i]*selif(inpc_46_analgesicos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_analgesicos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_nutricionales_2014[i]=
quantile(precios_46_nutricionales[i]*selif(inpc_46_nutricionales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_nutricionales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_gastrointestinales_2014[i]=
quantile(precios_46_gastrointestinales[i]*selif(inpc_46_gastrointestinales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_gastrointestinales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_antigripales_2014[i]=
quantile(precios_46_antigripales[i]*selif(inpc_46_antigripales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_antigripales, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_medicinas_tos_2014[i]=
quantile(precios_46_medicinas_tos[i]*selif(inpc_46_medicina_tos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_medicina_tos, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_medicinas_piel_2014[i]=
quantile(precios_46_medicinas_piel[i]*selif(inpc_46_medicina_piel, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_medicina_piel, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha	.eq fecha_2011)), 0.5);

P_46_autobus_foraneo_2014[i]=
quantile(precios_46_autobus_foraneo[i]*selif(inpc_46_autobus_foraneo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_autobus_foraneo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_transporte_aereo_2014[i]=
quantile(precios_46_transporte_aereo[i]*selif(inpc_46_transporte_aereo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .ge fecha_inicial_2014).*(inpc_46_fecha .le fecha_final_2014))./selif(inpc_46_transporte_aereo, (inpc_46_estado .eq precios_46_estado[i]).*(inpc_46_municipio .eq precios_46_municipio[i]).*(inpc_46_fecha .eq fecha_2011)), 0.5);

P_46_materiales_2014[i]=
quantile(precios_46_materiales[i]*selif(inpp_mat_46_materiales, (inpp_mat_46_estado .eq precios_46_estado[i]).*(inpp_mat_46_municipio .eq precios_46_municipio[i]).*(inpp_mat_46_fecha .ge fecha_inicial_2014).*(inpp_mat_46_fecha .le fecha_final_2014))./selif(inpp_mat_46_materiales, (inpp_mat_46_estado .eq precios_46_estado[i]).*(inpp_mat_46_municipio .eq precios_46_municipio[i]).*(inpp_mat_46_fecha .eq fecha_2011)), 0.5);


i=i+1;
endo;


load municipios_latitud_longitud[304568,4]=datos_municipios_latitud_longitud.asc;
ESTADO_latitud_longitud=municipios_latitud_longitud[.,1];
MUNICIPIO_latitud_longitud=municipios_latitud_longitud[.,2];
LATITUD_latitud_longitud=municipios_latitud_longitud[.,3]*pi/180; /*(en radianes)*/
LONGITUD_latitud_longitud=municipios_latitud_longitud[.,4]*pi/180; /*(en radianes)*/
load gastos_hogares_1[393409,10]=gasto_hogar_enigh_2014_archivo_1.asc;
load gastos_hogares_2[392859,10]=gasto_hogar_enigh_2014_archivo_2.asc;
load gastos_hogares_3[386058,10]=gasto_hogar_enigh_2014_archivo_3.asc;
gastos_hogares=gastos_hogares_1|gastos_hogares_2|gastos_hogares_3;
/*VARIABLES:
1.- folioviv: Identificador de la vivienda 
2.- clave NUMERICA: Clave de gasto numerica	
3.- gasto_tri: gasto trimestral monetario	
4.- GASTO_TOTAL_TRIMESTRAL: gasto total trimestral monetario y no monetario (incluye pago en especie)	
5.- mes: mes de la compra, N/A=0	
6.- lugar_comp: lugar de la compra. valores van de 0 a 18, ver manual INEGI. 15=Diconsa, 16=Liconsa. 	
7.- orga_inst: organizacion o institucion proveedora. Valores van de 0 a 8. OPORTUNIDADES=5, Liconsa=7, Diconsa=8	
8.- cantidad: numero de unidades recibidas por parte de alguna institucion a un precio menor o sin costo (N/A=-1) 	
9.- inst1: Institucion publica o privada que proporciona productos y servicios de salud. Valores van de 1 a 13. 12=PROGESA U OPORTUNIDADES (N/A=0) 	
10.- inst2: Institucion publica o privada que proporciona productos y servicios de salud. Valores van de 1 a 13. 12=PROGESA U OPORTUNIDADES (N/A=0) 	*/ 



/*No hay repeticiones, cada vivienda es un hogar y viceversa*/
clave_vivienda_hogares=gastos_hogares[.,1]; 
/*Hay repeticiones. Cada entrada corresponde a un gasto particular de un hogar, cada hogar tiene muchos gastos*/
clave_categ_gasto_hogar=gastos_hogares[.,2];
/*Nos dice la categoria del gasto en cuestion: alimentos, etc...*/
gasto_trimestral_hogar=gastos_hogares[.,3];
load gastos_pers[110122,4]=gasto_persona_enigh_2014.asc;
clave_vivienda_hogares_pers=gastos_pers[.,1]; 
clave_categ_gasto_hogar_pers=gastos_pers[.,2];
gasto_trimestral_hogar_pers=gastos_pers[.,3];
load vars_concentrado_hogares[19124,133]=datos_concentrado_hogares_enigh_2014.asc;
clave_vivienda_concentrados=vars_concentrado_hogares[.,1]; 
num_hogares=rows(clave_vivienda_concentrados);
/*DESCRIPCION DE LAS CARACTERISTICAS DE LOS HOGARES EN EL ARCHIVO DE CONCENTRADO HOGARES*/ 
/*1	folioviv
2	ubica_geo
3	tam_loc
4	est_socio
5	est_dis
6	upm
7	factor_hog
8	clase_hog
9	sexo_jefe
10	edad_jefe
11	educa_jefe
12	tot_integ
13	hombres
14	mujeres
15	mayores
16	menores
17	p12_64
18	p65mas
19	ocupados
20	percep_ing
21	perc_ocupa
22	ing_total
23	ing_cor
24	ing_mon
25	trabajo
26	sueldos
27	horas_extr
28	comisiones
29	otra_rem
30	negocio
31	noagrop
32	industria
33	comercio
34	servicios
35	agrope
36	agricolas
37	pecuarios
38	reproducc
39	pesca
40	otros_trab
41	rentas
42	utilidad
43	arrenda
44	transfer
45	jubilacion
46	becas
47	donativos
48	remesas
49	bene_gob
50	otros_ing
51	gasto_nom
52	autoconsum
53	remu_espec
54	transf_esp
55	transf_hog
56	trans_inst
57	estim_alqu
58	percep_tot
59	percep_mon
60	retiro_inv
61	prestamos
62	otras_perc
63	erogac_nom
64	gasto_tot
65	gasto_cor
66	gasto_mon
67	alimentos
68	ali_dentro
69	cereales
70	carnes
71	pescado
72	leche
73	huevo
74	aceites
75	tuberculo
76	verduras
77	frutas
78	azucar
79	cafe
80	especias
81	otros_alim
82	bebidas
83	ali_fuera
84	tabaco
85	vesti_calz
86	vestido
87	calzado
88	vivienda
89	alquiler
90	pred_cons
91	agua
92	energia
93	limpieza
94	cuidados
95	utensilios
96	enseres
97	salud
98	atenc_ambu
99	hospital
100	medicinas
101	transporte
102	publico
103	foraneo
104	adqui_vehi
105	mantenim
106	refaccion
107	combus
108	comunica
109	educa_espa
110	educacion
111	esparci
112	paq_turist
113	personales
114	cuida_pers
115	acces_pers
116	otros_gas
117	transf_gas
118	erogac_tot
119	erogac_mon
120	cuota_viv
121	mater_serv
122	material
123	servicio
124	deposito
125	prest_terc
126	pago_tarje
127	deudas
128	balance
129	otras_erog
130	smg
131	entidad_federativa
132	clave_municipio
133	clave_localidad*/

ratio_2014=((vars_concentrado_hogares[.,53]+vars_concentrado_hogares[.,86]+vars_concentrado_hogares[.,87]+vars_concentrado_hogares[.,103])./vars_concentrado_hogares[.,52]);
ratio_2014_below_median=selif(ratio_2014, vars_concentrado_hogares[.,52] .le quantile(vars_concentrado_hogares[.,52], 0.5));
ingreso_2014_GINI=sortc(vars_concentrado_hogares[.,24],1);
ahorro_ultima_seccion=vars_concentrado_hogares[.,124];
educ_ultima_seccion=vars_concentrado_hogares[.,110];
salud_ultima_seccion=vars_concentrado_hogares[.,97];
factor_hogar_ultima_seccion=vars_concentrado_hogares[.,7];
entidad_federativa_GINI=vars_concentrado_hogares[.,131];


/* CLAVES DE ENTIDADES FEDERATIVAS
1	Aguascalientes
2	Baja California
3	Baja California Sur
4	Campeche
5	Coahuila de Zaragoza
6	Colima
7	Chiapas
8	Chihuahua
9	Distrito Federal
10	Durango
11	Guanajuato
12	Guerrero
13	Hidalgo
14	Jalisco
15	México
16	Michoacán de Ocampo
17	Morelos
18	Nayarit
19	Nuevo León
20	Oaxaca
21	Puebla
22	Querétaro
23	Quintana Roo
24	San Luis Potosí
25	Sinaloa
26	Sonora
27	Tabasco
28	Tamaulipas
29	Tlaxcala
30	Veracruz de Ignacio de la Llave
31	Yucatán
32	Zacatecas*/

noroeste_GINI=2|3|8|10|25|26;
noreste_GINI=5|19|28;
centro_norte_GINI=1|11|22|24|32;
centro_sur_GINI=9|15|17;
suroeste_GINI=7|12|20;
sureste_GINI=4|23|27|31;
oeste_GINI=6|14|16|18;
este_GINI=13|21|29|30;


region_noroeste_GINI=maxc((entidad_federativa_GINI .eq noroeste_GINI')');
region_noreste_GINI=maxc((entidad_federativa_GINI .eq noreste_GINI')');
region_centro_norte_GINI=maxc((entidad_federativa_GINI .eq centro_norte_GINI')');
region_centro_sur_GINI=maxc((entidad_federativa_GINI .eq centro_sur_GINI')');
region_suroeste_GINI=maxc((entidad_federativa_GINI .eq suroeste_GINI')');
region_sureste_GINI=maxc((entidad_federativa_GINI .eq sureste_GINI')');
region_oeste_GINI=maxc((entidad_federativa_GINI .eq oeste_GINI')');
region_este_GINI=maxc((entidad_federativa_GINI .eq este_GINI')');


regiones_GINI_2014=region_noroeste_GINI~region_noreste_GINI~region_centro_norte_GINI~region_centro_sur_GINI~region_suroeste_GINI~region_sureste_GINI~region_oeste_GINI~region_este_GINI;


ingreso_2014_GINI_noroeste=selif(ingreso_2014_GINI, region_noroeste_GINI);
ingreso_2014_GINI_noreste=selif(ingreso_2014_GINI, region_noreste_GINI);
ingreso_2014_GINI_centro_norte=selif(ingreso_2014_GINI, region_centro_norte_GINI);
ingreso_2014_GINI_centro_sur=selif(ingreso_2014_GINI, region_centro_sur_GINI);
ingreso_2014_GINI_suroeste=selif(ingreso_2014_GINI, region_suroeste_GINI);
ingreso_2014_GINI_sureste=selif(ingreso_2014_GINI, region_sureste_GINI);
ingreso_2014_GINI_oeste=selif(ingreso_2014_GINI, region_oeste_GINI);
ingreso_2014_GINI_este=selif(ingreso_2014_GINI, region_este_GINI);


ingreso_2014_GINI_noroeste=sortc(ingreso_2014_GINI_noroeste,1);
ingreso_2014_GINI_noreste=sortc(ingreso_2014_GINI_noreste,1);
ingreso_2014_GINI_centro_norte=sortc(ingreso_2014_GINI_centro_norte,1);
ingreso_2014_GINI_centro_sur=sortc(ingreso_2014_GINI_centro_sur,1);
ingreso_2014_GINI_suroeste=sortc(ingreso_2014_GINI_suroeste,1);
ingreso_2014_GINI_sureste=sortc(ingreso_2014_GINI_sureste,1);
ingreso_2014_GINI_oeste=sortc(ingreso_2014_GINI_oeste,1);
ingreso_2014_GINI_este=sortc(ingreso_2014_GINI_este,1);


/*EN LA ENIGH 2014:
Valor Etiqueta
1 Es rentada
2 Es prestada
3 Es propia pero la están pagando
4 Es propia
5 Está intestada o en litigio
6 Otra situación*/

load tenencia_vivienda[19124,2]=hogares_tenencia_vivienda_2014.asc;

clave_vivienda_tenencia=tenencia_vivienda[.,1];
tenencia_estatus=tenencia_vivienda[.,2];

tenencia_estatus=((tenencia_estatus .eq 3)+(tenencia_estatus .eq 4) .gt 0);

vivienda_propia=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;
hogar_en_turno=clave_vivienda_concentrados[i];

/*EN LA ENIGH 2014:
Valor Etiqueta
1 Es rentada
2 Es prestada
3 Es propia pero la estÃ¡n pagando
4 Es propia
5 EstÃ¡ intestada o en litigio
6 Otra situaciÃ³n*/

if sumc((clave_vivienda_tenencia .eq hogar_en_turno)) .gt 0;
estatus_seleccionadas_hogar=selif(tenencia_estatus, (clave_vivienda_tenencia .eq hogar_en_turno));
vivienda_propia[i]=(sumc(estatus_seleccionadas_hogar) .gt 0);
endif;

i=i+1;
endo;

clase_de_hogar=vars_concentrado_hogares[.,8];
edad_del_jefe=vars_concentrado_hogares[.,10];
total_integrantes=vars_concentrado_hogares[.,12];
gasto_monetario=vars_concentrado_hogares[.,66];

/* CLAVES DE ENTIDADES FEDERATIVAS
1	Aguascalientes
2	Baja California
3	Baja California Sur
4	Campeche
5	Coahuila de Zaragoza
6	Colima
7	Chiapas
8	Chihuahua
9	Distrito Federal
10	Durango
11	Guanajuato
12	Guerrero
13	Hidalgo
14	Jalisco
15	MÃÂ©xico
16	MichoacÃÂ¡n de Ocampo
17	Morelos
18	Nayarit
19	Nuevo LeÃÂ³n
20	Oaxaca
21	Puebla
22	QuerÃÂ©taro
23	Quintana Roo
24	San Luis PotosÃÂ­
25	Sinaloa
26	Sonora
27	Tabasco
28	Tamaulipas
29	Tlaxcala
30	Veracruz de Ignacio de la Llave
31	YucatÃÂ¡n
32	Zacatecas*/

vars_concentrado_hogares=selif(vars_concentrado_hogares, (vivienda_propia .gt 0).*(clase_de_hogar .le 5).*(edad_del_jefe .ge 20).*(edad_del_jefe .le 75).*(total_integrantes .le 8).*(gasto_monetario .ge quantile(gasto_monetario,0.001)));
clave_vivienda_concentrados=vars_concentrado_hogares[.,1]; 
num_hogares=rows(clave_vivienda_concentrados);
estado_hogar=vars_concentrado_hogares[.,131];
municipio_hogar=vars_concentrado_hogares[.,132];
latitud_hogar=zeros(rows(vars_concentrado_hogares),1);
longitud_hogar=zeros(rows(vars_concentrado_hogares),1);
factor_hogar_poblacion=vars_concentrado_hogares[.,7];

i=1;
do while i .le rows(vars_concentrado_hogares);
count_latitud_longitud=sumc((ESTADO_latitud_longitud .eq estado_hogar[i]).*(MUNICIPIO_latitud_longitud .eq 	municipio_hogar[i]));
if count_latitud_longitud .gt 0;	
aux_latitud_longitud=selif(LATITUD_latitud_longitud~LONGITUD_latitud_longitud, (ESTADO_latitud_longitud .eq estado_hogar[i]).*(MUNICIPIO_latitud_longitud .eq 	municipio_hogar[i]));
latitud_hogar[i]=aux_latitud_longitud[1,1];
longitud_hogar[i]=aux_latitud_longitud[1,2];
endif;
i=i+1;
endo;

numerador_46_ciudades=seqa(1,1,46);
ciudad_46_mas_cercana=zeros(rows(vars_concentrado_hogares),1);
dist_ciudad_46_mas_cercana=zeros(rows(vars_concentrado_hogares),1);

i=1;
do while i .le rows(vars_concentrado_hogares);
distancia_46_ciudades=
acos(
sin(latitud_hogar[i]).*sin(precios_46_latitud)+cos(latitud_hogar[i]).*cos(precios_46_latitud).*cos(precios_46_longitud-longitud_hogar[i])	
)*6371;	
aux_sort_distancia=sortc(numerador_46_ciudades~distancia_46_ciudades,2);
ciudad_46_mas_cercana[i]=aux_sort_distancia[1,1];
dist_ciudad_46_mas_cercana[i]=aux_sort_distancia[1,2];	
i=i+1;
endo;

aux_ciudades=seqa(1,1,46);
poblacion_hogares_46_ciudades=aux_ciudades~sumc((ciudad_46_mas_cercana .eq aux_ciudades').*factor_hogar_poblacion);
distancia_maxima=400; 
vars_concentrado_hogares=selif(vars_concentrado_hogares, dist_ciudad_46_mas_cercana .le distancia_maxima);
ciudad_46_mas_cercana=selif(ciudad_46_mas_cercana, dist_ciudad_46_mas_cercana .le distancia_maxima);
dist_ciudad_46_mas_cercana=selif(dist_ciudad_46_mas_cercana, dist_ciudad_46_mas_cercana .le distancia_maxima);

clave_vivienda_concentrados=vars_concentrado_hogares[.,1]; 
num_hogares=rows(clave_vivienda_concentrados);


P_hogar_tortillas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pan_blanco_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pan_dulce_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pollo_entero_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pollo_piezas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_huevo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_bistec_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_molida_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_visceras_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chorizo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jamon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_salchichas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_tocino_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_pasteurizada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_en_polvo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_maternizada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_condensada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_fresco_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_oaxaca_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_amarillo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_crema_de_leche_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_mantequilla_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_manzana_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_platanos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_aguacate_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_papaya_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_naranja_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_limon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_melon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_uvas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pera_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_guayaba_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_sandia_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pina_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jitomate_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_papa_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_cebolla_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_tomate_verde_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_col_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_lechuga_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_calabacita_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_zanahoria_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chile_serrano_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_nopales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chayote_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chile_poblano_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pepino_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_ejotes_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chicharo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_frijol_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jugos_nectares_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_refrescos_envasados_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_agua_embotellada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_antibioticos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_cardiovasculares_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_analgesicos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_nutricionales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_gastrointestinales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_antigripales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_medicinas_tos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_medicinas_piel_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_autobus_foraneo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_transporte_aereo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_materiales_2014=
zeros(rows(vars_concentrado_hogares),1);

P_hogar_tortillas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pan_blanco_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pan_dulce_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pollo_entero_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pollo_piezas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_huevo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_bistec_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_molida_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_visceras_res_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chorizo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jamon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_salchichas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_tocino_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_pasteurizada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_en_polvo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_maternizada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_leche_condensada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_fresco_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_oaxaca_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_queso_amarillo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_crema_de_leche_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_mantequilla_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_manzana_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_platanos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_aguacate_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_papaya_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_naranja_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_limon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_melon_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_uvas_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pera_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_guayaba_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_sandia_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pina_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jitomate_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_papa_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_cebolla_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_tomate_verde_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_col_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_lechuga_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_calabacita_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_zanahoria_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chile_serrano_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_nopales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chayote_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chile_poblano_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_pepino_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_ejotes_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_chicharo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_frijol_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_jugos_nectares_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_refrescos_envasados_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_agua_embotellada_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_antibioticos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_cardiovasculares_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_analgesicos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_nutricionales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_gastrointestinales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_antigripales_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_medicinas_tos_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_medicinas_piel_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_autobus_foraneo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_transporte_aereo_2014=
zeros(rows(vars_concentrado_hogares),1);
P_hogar_materiales_2014=
zeros(rows(vars_concentrado_hogares),1);


i=1;
do while i .le rows(vars_concentrado_hogares);
rr=ciudad_46_mas_cercana[i];
P_hogar_tortillas_2014[i]=P_46_tortillas_2014[rr];
P_hogar_pan_blanco_2014[i]=P_46_pan_blanco_2014[rr];
P_hogar_pan_dulce_2014[i]=P_46_pan_dulce_2014[rr];
P_hogar_pollo_entero_2014[i]=P_46_pollo_entero_2014[rr];
P_hogar_pollo_piezas_2014[i]=P_46_pollo_piezas_2014[rr];
P_hogar_huevo_2014[i]=P_46_huevo_2014[rr];
P_hogar_bistec_res_2014[i]=P_46_bistec_res_2014[rr];
P_hogar_molida_res_2014[i]=P_46_molida_res_2014[rr];
P_hogar_visceras_res_2014[i]=P_46_visceras_res_2014[rr];
P_hogar_chorizo_2014[i]=P_46_chorizo_2014[rr];
P_hogar_jamon_2014[i]=P_46_jamon_2014[rr];
P_hogar_salchichas_2014[i]=P_46_salchichas_2014[rr];
P_hogar_tocino_2014[i]=P_46_tocino_2014[rr];
P_hogar_leche_pasteurizada_2014[i]=P_46_leche_pasteurizada_2014[rr];
P_hogar_leche_en_polvo_2014[i]=P_46_leche_en_polvo_2014[rr];
P_hogar_leche_maternizada_2014[i]=P_46_leche_maternizada_2014[rr];
P_hogar_leche_condensada_2014[i]=P_46_leche_condensada_2014[rr];
P_hogar_queso_fresco_2014[i]=P_46_queso_fresco_2014[rr];
P_hogar_queso_oaxaca_2014[i]=P_46_queso_oaxaca_2014[rr];
P_hogar_queso_amarillo_2014[i]=P_46_queso_amarillo_2014[rr];
P_hogar_crema_de_leche_2014[i]=P_46_crema_de_leche_2014[rr];
P_hogar_mantequilla_2014[i]=P_46_mantequilla_2014[rr];
P_hogar_manzana_2014[i]=P_46_manzana_2014[rr];
P_hogar_platanos_2014[i]=P_46_platanos_2014[rr];
P_hogar_aguacate_2014[i]=P_46_aguacate_2014[rr];
P_hogar_papaya_2014[i]=P_46_papaya_2014[rr];
P_hogar_naranja_2014[i]=P_46_naranja_2014[rr];
P_hogar_limon_2014[i]=P_46_limon_2014[rr];
P_hogar_melon_2014[i]=P_46_melon_2014[rr];
P_hogar_uvas_2014[i]=P_46_uvas_2014[rr];
P_hogar_pera_2014[i]=P_46_pera_2014[rr];
P_hogar_guayaba_2014[i]=P_46_guayaba_2014[rr];
P_hogar_sandia_2014[i]=P_46_sandia_2014[rr];
P_hogar_pina_2014[i]=P_46_pina_2014[rr];
P_hogar_jitomate_2014[i]=P_46_jitomate_2014[rr];
P_hogar_papa_2014[i]=P_46_papa_2014[rr];
P_hogar_cebolla_2014[i]=P_46_cebolla_2014[rr];
P_hogar_tomate_verde_2014[i]=P_46_tomate_verde_2014[rr];
P_hogar_col_2014[i]=P_46_col_2014[rr];
P_hogar_lechuga_2014[i]=P_46_lechuga_2014[rr];
P_hogar_calabacita_2014[i]=P_46_calabacita_2014[rr];
P_hogar_zanahoria_2014[i]=P_46_zanahoria_2014[rr];
P_hogar_chile_serrano_2014[i]=P_46_chile_serrano_2014[rr];
P_hogar_nopales_2014[i]=P_46_nopales_2014[rr];
P_hogar_chayote_2014[i]=P_46_chayote_2014[rr];
P_hogar_chile_poblano_2014[i]=P_46_chile_poblano_2014[rr];
P_hogar_pepino_2014[i]=P_46_pepino_2014[rr];
P_hogar_ejotes_2014[i]=P_46_ejotes_2014[rr];
P_hogar_chicharo_2014[i]=P_46_chicharo_2014[rr];
P_hogar_frijol_2014[i]=P_46_frijol_2014[rr];
P_hogar_jugos_nectares_2014[i]=P_46_jugos_nectares_2014[rr];
P_hogar_refrescos_envasados_2014[i]=P_46_refrescos_envasados_2014[rr];
P_hogar_agua_embotellada_2014[i]=P_46_agua_embotellada_2014[rr];
P_hogar_antibioticos_2014[i]=P_46_antibioticos_2014[rr];
P_hogar_cardiovasculares_2014[i]=P_46_cardiovasculares_2014[rr];
P_hogar_analgesicos_2014[i]=P_46_analgesicos_2014[rr];
P_hogar_nutricionales_2014[i]=P_46_nutricionales_2014[rr];
P_hogar_gastrointestinales_2014[i]=P_46_gastrointestinales_2014[rr];
P_hogar_antigripales_2014[i]=P_46_antigripales_2014[rr];
P_hogar_medicinas_tos_2014[i]=P_46_medicinas_tos_2014[rr];
P_hogar_medicinas_piel_2014[i]=P_46_medicinas_piel_2014[rr];
P_hogar_autobus_foraneo_2014[i]=P_46_autobus_foraneo_2014[rr];
P_hogar_transporte_aereo_2014[i]=P_46_transporte_aereo_2014[rr];
P_hogar_materiales_2014[i]=P_46_materiales_2014[rr];
i=i+1;
endo;
/*
1.-	Tortillas de Maiz (A004)->(1004) 
2.-	Pan Blanco (A012)->(1012)
3.-	Pan Dulce (A013)->(1013)
4.-	Pollo Entero (A059)->(1059)
5.-	Pollo En Piezas Con Hueso (A057)->(1057)
6.-Huevo (A093)->(1093)
7.-Bistec de Res (A025)->(1025)
8.-Molida de Res (A034)->(1034)
9.-Visceras de Res (A037)->(1037)
10.-Chorizo (A049)->(1049)
11.-Jamon (A052)->(1052)
12.-Salchichas (A055)->(1055)
13.-Tocino (A054)->(1054)
14.-Leche Pasteurizada (A075)->(1075) 
15.-Leche en Polvo (A078)->(1078)
16.-Leche Maternizada (A079)->(1079)
17.-Leche Condensada y Evaporada (A076)->(1076)
18.-Queso Fresco (A085)->(1085)
19.-Queso Oaxaca o Asadero (A087)->(1087)
20.-Queso Amarillo (A082)->(1082)
21.-Crema de Leche (A089)->(1089)
22.-Mantequilla (A090)->(1090)
23.-Manzana (A158)->(1158)
24.-Platano (A166)->(1166)
25.-Aguacate (A108)->(1108)
26.-Papaya (A161)->(1161)
27.-Naranja (A160)->(1160)
28.-Limon (A154)->(1154)
29.-Melon (A159)->(1159)
30.-Uvas (A169)->(1169)
31.-Pera (A162)->(1162)
32.-Guayaba (A152)->(1152)
33.-Sandia (A168)->(1168)
34.-Pina (A163)->(1163)
35.-Jitomate (A124)->(1124)
36.-Papa (A102)->(1102)
37.-Cebolla (A112)->(1112)
38.-Tomate Verde (A129)->(1129)
39.-Col (A120)->(1120)
40.-Lechuga (A125)->(1125)
41.-Calabacita (A111)->(1111)
42.-Zanahoria (A130)->(1130)
43.-Chile Serrano (A117)->(1117)
44.-Nopal (A126)->(1126)
45.-Chayote (A113)->(1113)
46.-Chile Poblano (A116)->(1116)
47.-Pepino (A127)->(1127)
48.-Ejotes (A121)->(1121)
49.-Chicharo (A114)->(1114)
50.-Frijol (A137)->(1137)
51.-Jugos o Nectares Envasados (A218)->(1218)
52.-Refrescos Envasados (A220)->(1220)
53.-Agua Embotellada (A215)->(1215)
54.-Antibioticos CON receta (J028)->(10028)
55.-Antibioticos SIN receta (J052)->(10052)
56.-Medicamentos Cardiovasculares CON receta (J031)->(10031)
57.-Medicamentos Cardiovasculares SIN receta (J056)->(10056)
58.-Analgesicos CON receta (J026)->(10026)
59.-Analgesicos SIN receta (J050)->(10050)
60.-Nutricionales CON receta (J033)->(10033)
61.-Nutricionales SIN receta (J055)->(10055)
62.-Medicina Gastrointestinal CON receta (J020)->(10020)
63.-Medicina Gastrointestinal SIN receta (J044)->(10044)
64.-Antigripales CON receta (J021)->(10021)
65.-Antigripales SIN receta (J045)->(10045)
66.-Medicina para la tos CON receta (J024)->(10024)
67.-Medicina para la tos SIN receta (J048)->(10048)
68.-Medicina para la Piel CON receta (J022)->(10022)
69.-Medicina para la Piel SIN receta (J046)->(10046)
70.-Transporte Autobus (B002)->(2002)
71.-Transporte Autobus Foraneo (B006)->(2006)
72.-Transporte Foraneo (M001)->(13001)
73.-Transporte Aereo (M003)->(13003)*/

claves_categorias=
1004|
1012|
1013|
1059|
1057|
1093|
1025|
1034|
1037|
1049|
1052|
1055|
1054|
1075|
1078|
1079|
1076|
1085|
1087|
1082|
1089|
1090|
1158|
1166|
1108|
1161|
1160|
1154|
1159|
1169|
1162|
1152|
1168|
1163|
1124|
1102|
1112|
1129|
1120|
1125|
1111|
1130|
1117|
1126|
1113|
1116|
1127|
1121|
1114|
1137|
1218|
1220|
1215|
10028|
10052|
10031|
10056|
10026|
10050|
10033|
10055|
10020|
10044|
10021|
10045|
10024|
10048|
10022|
10046|
2002|
2006|
13001|
13003;

vector_gastos_hogares=zeros(num_hogares, rows(claves_categorias));
gastos_hogares_materiales=zeros(num_hogares, 1);

i=1;
do while i .le num_hogares;
hogar_en_turno=clave_vivienda_concentrados[i];

gastos_hogares_materiales[i]=selif(vars_concentrado_hogares[.,121], clave_vivienda_concentrados .eq hogar_en_turno);	

	
if sumc((clave_vivienda_hogares .eq hogar_en_turno)) .gt 0;
claves_seleccionadas_hogar=selif(clave_categ_gasto_hogar, (clave_vivienda_hogares .eq hogar_en_turno));	
gastos_seleccionados_hogar=selif(gasto_trimestral_hogar, (clave_vivienda_hogares .eq hogar_en_turno));
auxiliar_matriz_hogar=(claves_seleccionadas_hogar .eq claves_categorias');
g_hogar=sumc(auxiliar_matriz_hogar.*gastos_seleccionados_hogar);	
else;
g_hogar=zeros(rows(claves_categorias),1);	
endif;


if sumc((clave_vivienda_hogares_pers .eq hogar_en_turno)) .gt 0;
claves_seleccionadas_pers=selif(clave_categ_gasto_hogar_pers, (clave_vivienda_hogares_pers .eq hogar_en_turno));	
gastos_seleccionados_pers=selif(gasto_trimestral_hogar_pers, (clave_vivienda_hogares_pers .eq hogar_en_turno));
auxiliar_matriz_pers=(claves_seleccionadas_pers .eq claves_categorias');
g_pers=sumc(auxiliar_matriz_pers.*gastos_seleccionados_pers);	
else;
g_pers=zeros(rows(claves_categorias),1);	
endif;

vector_gastos_hogares[i,.]=(g_hogar+g_pers)';

i=i+1;
endo;




/*1.-*/ 
gasto_hogar_tortillas=vector_gastos_hogares[.,1];	
gasto_hogar_tortillas=gasto_hogar_tortillas.*(gasto_hogar_tortillas .gt 0)+0.01*(gasto_hogar_tortillas .eq 0);

/*2.-*/ 
gasto_hogar_pan_blanco=vector_gastos_hogares[.,2];
gasto_hogar_pan_blanco=gasto_hogar_pan_blanco.*(gasto_hogar_pan_blanco .gt 0)+0.01*(gasto_hogar_pan_blanco .eq 0);

/*3.-*/ 
gasto_hogar_pan_dulce=vector_gastos_hogares[.,3];
gasto_hogar_pan_dulce=gasto_hogar_pan_dulce.*(gasto_hogar_pan_dulce .gt 0)+0.01*(gasto_hogar_pan_dulce .eq 0);

/*4.-*/ 
gasto_hogar_pollo_entero=vector_gastos_hogares[.,4];
gasto_hogar_pollo_entero=gasto_hogar_pollo_entero.*(gasto_hogar_pollo_entero .gt 0)+0.01*(gasto_hogar_pollo_entero .eq 0);


/*5.-*/ 
gasto_hogar_pollo_piezas=vector_gastos_hogares[.,5];
gasto_hogar_pollo_piezas=gasto_hogar_pollo_piezas.*(gasto_hogar_pollo_piezas .gt 0)+0.01*(gasto_hogar_pollo_piezas .eq 0);


/*6.-*/ 
gasto_hogar_huevo=vector_gastos_hogares[.,6];
gasto_hogar_huevo=gasto_hogar_huevo.*(gasto_hogar_huevo .gt 0)+0.01*(gasto_hogar_huevo .eq 0);

/*7.-*/ 
gasto_hogar_bistec_res=vector_gastos_hogares[.,7];
gasto_hogar_bistec_res=gasto_hogar_bistec_res.*(gasto_hogar_bistec_res .gt 0)+0.01*(gasto_hogar_bistec_res .eq 0);

/*8.-*/ 
gasto_hogar_molida_res=vector_gastos_hogares[.,8];
gasto_hogar_molida_res=gasto_hogar_molida_res.*(gasto_hogar_molida_res .gt 0)+0.01*(gasto_hogar_molida_res .eq 0);


/*9.-*/ 
gasto_hogar_visceras_res=vector_gastos_hogares[.,9];
gasto_hogar_visceras_res=gasto_hogar_visceras_res.*(gasto_hogar_visceras_res .gt 0)+0.01*(gasto_hogar_visceras_res .eq 0);

/*10.-*/ 
gasto_hogar_chorizo=vector_gastos_hogares[.,10];
gasto_hogar_chorizo=gasto_hogar_chorizo.*(gasto_hogar_chorizo .gt 0)+0.01*(gasto_hogar_chorizo .eq 0);

/*11.-*/ 
gasto_hogar_jamon=vector_gastos_hogares[.,11];
gasto_hogar_jamon=gasto_hogar_jamon.*(gasto_hogar_jamon .gt 0)+0.01*(gasto_hogar_jamon .eq 0);

/*12.-*/ 
gasto_hogar_salchichas=vector_gastos_hogares[.,12];
gasto_hogar_salchichas=gasto_hogar_salchichas.*(gasto_hogar_salchichas .gt 0)+0.01*(gasto_hogar_salchichas .eq 0);


/*13.-*/ 
gasto_hogar_tocino=vector_gastos_hogares[.,13];
gasto_hogar_tocino=gasto_hogar_tocino.*(gasto_hogar_tocino .gt 0)+0.01*(gasto_hogar_tocino .eq 0);


/*14.-*/ 
gasto_hogar_leche_pasteur=vector_gastos_hogares[.,14];
gasto_hogar_leche_pasteur=gasto_hogar_leche_pasteur.*(gasto_hogar_leche_pasteur .gt 0)+0.01*(gasto_hogar_leche_pasteur .eq 0);


/*15.-*/ 
gasto_hogar_leche_en_polvo=vector_gastos_hogares[.,15];
gasto_hogar_leche_en_polvo=gasto_hogar_leche_en_polvo.*(gasto_hogar_leche_en_polvo .gt 0)+0.01*(gasto_hogar_leche_en_polvo .eq 0);


/*16.-*/ 
gasto_hogar_leche_maternizada=vector_gastos_hogares[.,16];
gasto_hogar_leche_maternizada=gasto_hogar_leche_maternizada.*(gasto_hogar_leche_maternizada .gt 0)+0.01*(gasto_hogar_leche_maternizada .eq 0);


/*17.-*/ 
gasto_hogar_leche_condensada=vector_gastos_hogares[.,17];
gasto_hogar_leche_condensada=gasto_hogar_leche_condensada.*(gasto_hogar_leche_condensada .gt 0)+0.01*(gasto_hogar_leche_condensada .eq 0);

/*18.-*/ 
gasto_hogar_queso_fresco=vector_gastos_hogares[.,18];
gasto_hogar_queso_fresco=gasto_hogar_queso_fresco.*(gasto_hogar_queso_fresco .gt 0)+0.01*(gasto_hogar_queso_fresco .eq 0);


/*19.-*/ 
gasto_hogar_queso_oaxaca=vector_gastos_hogares[.,19];
gasto_hogar_queso_oaxaca=gasto_hogar_queso_oaxaca.*(gasto_hogar_queso_oaxaca .gt 0)+0.01*(gasto_hogar_queso_oaxaca .eq 0);


/*20.-*/ 
gasto_hogar_queso_amarillo=vector_gastos_hogares[.,20];
gasto_hogar_queso_amarillo=gasto_hogar_queso_amarillo.*(gasto_hogar_queso_amarillo .gt 0)+0.01*(gasto_hogar_queso_amarillo .eq 0);


/*21.-*/ 
gasto_hogar_crema_leche=vector_gastos_hogares[.,21];
gasto_hogar_crema_leche=gasto_hogar_crema_leche.*(gasto_hogar_crema_leche .gt 0)+0.01*(gasto_hogar_crema_leche .eq 0);


/*22.-*/ 
gasto_hogar_mantequilla=vector_gastos_hogares[.,22];
gasto_hogar_mantequilla=gasto_hogar_mantequilla.*(gasto_hogar_mantequilla .gt 0)+0.01*(gasto_hogar_mantequilla .eq 0);


/*23.-*/ 
gasto_hogar_manzana=vector_gastos_hogares[.,23];
gasto_hogar_manzana=gasto_hogar_manzana.*(gasto_hogar_manzana .gt 0)+0.01*(gasto_hogar_manzana .eq 0);


/*24.-*/ 
gasto_hogar_platano=vector_gastos_hogares[.,24];
gasto_hogar_platano=gasto_hogar_platano.*(gasto_hogar_platano .gt 0)+0.01*(gasto_hogar_platano .eq 0);

/*25.-*/ 
gasto_hogar_aguacate=vector_gastos_hogares[.,25];
gasto_hogar_aguacate=gasto_hogar_aguacate.*(gasto_hogar_aguacate .gt 0)+0.01*(gasto_hogar_aguacate .eq 0);

/*26.-*/ 
gasto_hogar_papaya=vector_gastos_hogares[.,26];
gasto_hogar_papaya=gasto_hogar_papaya.*(gasto_hogar_papaya .gt 0)+0.01*(gasto_hogar_papaya .eq 0);

/*27.-*/ 
gasto_hogar_naranja=vector_gastos_hogares[.,27];
gasto_hogar_naranja=gasto_hogar_naranja.*(gasto_hogar_naranja .gt 0)+0.01*(gasto_hogar_naranja .eq 0);

/*28.-*/ 
gasto_hogar_limon=vector_gastos_hogares[.,28];
gasto_hogar_limon=gasto_hogar_limon.*(gasto_hogar_limon .gt 0)+0.01*(gasto_hogar_limon .eq 0);

/*29.-*/ 
gasto_hogar_melon=vector_gastos_hogares[.,29];
gasto_hogar_melon=gasto_hogar_melon.*(gasto_hogar_melon .gt 0)+0.01*(gasto_hogar_melon .eq 0);

/*30.-*/ 
gasto_hogar_uvas=vector_gastos_hogares[.,30];
gasto_hogar_uvas=gasto_hogar_uvas.*(gasto_hogar_uvas .gt 0)+0.01*(gasto_hogar_uvas .eq 0);

/*31.-*/ 
gasto_hogar_pera=vector_gastos_hogares[.,31];
gasto_hogar_pera=gasto_hogar_pera.*(gasto_hogar_pera .gt 0)+0.01*(gasto_hogar_pera .eq 0);

/*32.-*/ 
gasto_hogar_guayaba=vector_gastos_hogares[.,32];
gasto_hogar_guayaba=gasto_hogar_guayaba.*(gasto_hogar_guayaba .gt 0)+0.01*(gasto_hogar_guayaba .eq 0);

/*33.-*/ 
gasto_hogar_sandia=vector_gastos_hogares[.,33];
gasto_hogar_sandia=gasto_hogar_sandia.*(gasto_hogar_sandia .gt 0)+0.01*(gasto_hogar_sandia .eq 0);

/*34.-*/ 
gasto_hogar_pina=vector_gastos_hogares[.,34];
gasto_hogar_pina=gasto_hogar_pina.*(gasto_hogar_pina .gt 0)+0.01*(gasto_hogar_pina .eq 0);

/*35.-*/ 
gasto_hogar_jitomate=vector_gastos_hogares[.,35];
gasto_hogar_jitomate=gasto_hogar_jitomate.*(gasto_hogar_jitomate .gt 0)+0.01*(gasto_hogar_jitomate .eq 0);


/*36.-*/ 
gasto_hogar_papa=vector_gastos_hogares[.,36];
gasto_hogar_papa=gasto_hogar_papa.*(gasto_hogar_papa .gt 0)+0.01*(gasto_hogar_papa .eq 0);

/*37.-*/ 
gasto_hogar_cebolla=vector_gastos_hogares[.,37];
gasto_hogar_cebolla=gasto_hogar_cebolla.*(gasto_hogar_cebolla .gt 0)+0.01*(gasto_hogar_cebolla .eq 0);

/*38.-*/ 
gasto_hogar_tomate_verde=vector_gastos_hogares[.,38];
gasto_hogar_tomate_verde=gasto_hogar_tomate_verde.*(gasto_hogar_tomate_verde .gt 0)+0.01*(gasto_hogar_tomate_verde .eq 0);

/*39.-*/ 
gasto_hogar_col=vector_gastos_hogares[.,39];
gasto_hogar_col=gasto_hogar_col.*(gasto_hogar_col .gt 0)+0.01*(gasto_hogar_col .eq 0);

/*40.-*/ 
gasto_hogar_lechuga=vector_gastos_hogares[.,40];
gasto_hogar_lechuga=gasto_hogar_lechuga.*(gasto_hogar_lechuga .gt 0)+0.01*(gasto_hogar_lechuga .eq 0);

/*41.-*/ 
gasto_hogar_calabacita=vector_gastos_hogares[.,41];
gasto_hogar_calabacita=gasto_hogar_calabacita.*(gasto_hogar_calabacita .gt 0)+0.01*(gasto_hogar_calabacita .eq 0);

/*42.-*/ 
gasto_hogar_zanahoria=vector_gastos_hogares[.,42];
gasto_hogar_zanahoria=gasto_hogar_zanahoria.*(gasto_hogar_zanahoria .gt 0)+0.01*(gasto_hogar_zanahoria .eq 0);

/*43.-*/ 
gasto_hogar_chile_serrano=vector_gastos_hogares[.,43];
gasto_hogar_chile_serrano=gasto_hogar_chile_serrano.*(gasto_hogar_chile_serrano .gt 0)+0.01*(gasto_hogar_chile_serrano .eq 0);

/*44.-*/ 
gasto_hogar_nopales=vector_gastos_hogares[.,44];
gasto_hogar_nopales=gasto_hogar_nopales.*(gasto_hogar_nopales .gt 0)+0.01*(gasto_hogar_nopales .eq 0);

/*45.-*/ 
gasto_hogar_chayote=vector_gastos_hogares[.,45];
gasto_hogar_chayote=gasto_hogar_chayote.*(gasto_hogar_chayote .gt 0)+0.01*(gasto_hogar_chayote .eq 0);

/*46.-*/ 
gasto_hogar_chile_poblano=vector_gastos_hogares[.,46];
gasto_hogar_chile_poblano=gasto_hogar_chile_poblano.*(gasto_hogar_chile_poblano .gt 0)+0.01*(gasto_hogar_chile_poblano .eq 0);

/*47.-*/ 
gasto_hogar_pepino=vector_gastos_hogares[.,47];
gasto_hogar_pepino=gasto_hogar_pepino.*(gasto_hogar_pepino .gt 0)+0.01*(gasto_hogar_pepino .eq 0);

/*48.-*/ 
gasto_hogar_ejotes=vector_gastos_hogares[.,48];
gasto_hogar_ejotes=gasto_hogar_ejotes.*(gasto_hogar_ejotes .gt 0)+0.01*(gasto_hogar_ejotes .eq 0);

/*49.-*/ 
gasto_hogar_chicharo=vector_gastos_hogares[.,49];
gasto_hogar_chicharo=gasto_hogar_chicharo.*(gasto_hogar_chicharo .gt 0)+0.01*(gasto_hogar_chicharo .eq 0);

/*50.-*/ 
gasto_hogar_frijol=vector_gastos_hogares[.,50];
gasto_hogar_frijol=gasto_hogar_frijol.*(gasto_hogar_frijol .gt 0)+0.01*(gasto_hogar_frijol .eq 0);

/*51.-*/ 
gasto_hogar_jugos=vector_gastos_hogares[.,51];
gasto_hogar_jugos=gasto_hogar_jugos.*(gasto_hogar_jugos .gt 0)+0.01*(gasto_hogar_jugos .eq 0);

/*52.-*/ 
gasto_hogar_refrescos=vector_gastos_hogares[.,52];
gasto_hogar_refrescos=gasto_hogar_refrescos.*(gasto_hogar_refrescos .gt 0)+0.01*(gasto_hogar_refrescos .eq 0);

/*53.-*/ 
gasto_hogar_agua=vector_gastos_hogares[.,53];
gasto_hogar_agua=gasto_hogar_agua.*(gasto_hogar_agua .gt 0)+0.01*(gasto_hogar_agua .eq 0);


/*54.-*/ 
gasto_hogar_antibioticos=vector_gastos_hogares[.,54]+vector_gastos_hogares[.,55];
gasto_hogar_antibioticos=gasto_hogar_antibioticos.*(gasto_hogar_antibioticos .gt 0)+0.01*(gasto_hogar_antibioticos .eq 0);

/*55.-*/ 
gasto_hogar_cardiovasculares=vector_gastos_hogares[.,56]+vector_gastos_hogares[.,57];
gasto_hogar_cardiovasculares=gasto_hogar_cardiovasculares.*(gasto_hogar_cardiovasculares .gt 0)+0.01*(gasto_hogar_cardiovasculares .eq 0);

/*56.-*/ 
gasto_hogar_analgesicos=vector_gastos_hogares[.,58]+vector_gastos_hogares[.,59];
gasto_hogar_analgesicos=gasto_hogar_analgesicos.*(gasto_hogar_analgesicos .gt 0)+0.01*(gasto_hogar_analgesicos .eq 0);

/*57.-*/ 
gasto_hogar_nutricionales=vector_gastos_hogares[.,60]+vector_gastos_hogares[.,61];
gasto_hogar_nutricionales=gasto_hogar_nutricionales.*(gasto_hogar_nutricionales .gt 0)+0.01*(gasto_hogar_nutricionales .eq 0);

/*58.-*/ 
gasto_hogar_gastrointestinales=vector_gastos_hogares[.,62]+vector_gastos_hogares[.,63];
gasto_hogar_gastrointestinales=gasto_hogar_gastrointestinales.*(gasto_hogar_gastrointestinales .gt 0)+0.01*(gasto_hogar_gastrointestinales .eq 0);

/*59.-*/ 
gasto_hogar_antigripales=vector_gastos_hogares[.,64]+vector_gastos_hogares[.,65];
gasto_hogar_antigripales=gasto_hogar_antigripales.*(gasto_hogar_antigripales .gt 0)+0.01*(gasto_hogar_antigripales .eq 0);

/*60.-*/ 
gasto_hogar_tos=vector_gastos_hogares[.,66]+vector_gastos_hogares[.,67];
gasto_hogar_tos=gasto_hogar_tos.*(gasto_hogar_tos .gt 0)+0.01*(gasto_hogar_tos .eq 0);

/*61.-*/ 
gasto_hogar_dermatologicos=vector_gastos_hogares[.,68]+vector_gastos_hogares[.,69];
gasto_hogar_dermatologicos=gasto_hogar_dermatologicos.*(gasto_hogar_dermatologicos .gt 0)+0.01*(gasto_hogar_dermatologicos .eq 0);

/*62.-*/ 
gasto_hogar_autobus_foraneo=vector_gastos_hogares[.,70]+vector_gastos_hogares[.,71]+vector_gastos_hogares[.,72];
gasto_hogar_autobus_foraneo=gasto_hogar_autobus_foraneo.*(gasto_hogar_autobus_foraneo .gt 0)+0.01*(gasto_hogar_autobus_foraneo .eq 0);


/*63.-*/ 
gasto_hogar_transporte_aereo=vector_gastos_hogares[.,73];
gasto_hogar_transporte_aereo=gasto_hogar_transporte_aereo.*(gasto_hogar_transporte_aereo .gt 0)+0.01*(gasto_hogar_transporte_aereo .eq 0);

/*64.-*/ 
gasto_hogar_materiales=gastos_hogares_materiales;
gasto_hogar_materiales=gasto_hogar_materiales.*(gasto_hogar_materiales .gt 0)+0.01*(gasto_hogar_materiales .eq 0);

/*GASTOS DE LOS HOGARES EN LAS CATEGORIAS ANALIZADAS*/

/* 1.- TORTILLAS (1 producto)*/
gasto_hogar_tortillas=
gasto_hogar_tortillas;

/* 2.- PAN (2 productos)*/
gasto_hogar_pan=
gasto_hogar_pan_blanco
+gasto_hogar_pan_dulce;

/* 3.- POLLO Y HUEVO (3 productos)*/
gasto_hogar_pollo_huevo=
gasto_hogar_pollo_entero
+gasto_hogar_pollo_piezas
+gasto_hogar_huevo;

/* 4.- CARNE DE RES (3 productos)*/
gasto_hogar_carne_res=
gasto_hogar_bistec_res
+gasto_hogar_molida_res
+gasto_hogar_visceras_res;

/* 5.- CARNES PROCESADAS (4 productos)*/
gasto_hogar_carnes_procesadas=
gasto_hogar_chorizo
+gasto_hogar_jamon
+gasto_hogar_salchichas
+gasto_hogar_tocino;

/* 6.- LACTEOS (9 productos)*/
gasto_hogar_lacteos=
gasto_hogar_leche_pasteur
+gasto_hogar_leche_en_polvo
+gasto_hogar_leche_maternizada
+gasto_hogar_leche_condensada
+gasto_hogar_queso_fresco
+gasto_hogar_queso_oaxaca
+gasto_hogar_queso_amarillo
+gasto_hogar_crema_leche
+gasto_hogar_mantequilla;

/* 7.- FRUTAS (11 productos)*/
gasto_hogar_frutas=
gasto_hogar_manzana
+gasto_hogar_platano
+gasto_hogar_papaya
+gasto_hogar_naranja
+gasto_hogar_limon
+gasto_hogar_melon
+gasto_hogar_uvas
+gasto_hogar_pera
+gasto_hogar_guayaba
+gasto_hogar_sandia
+gasto_hogar_pina;

/* 8.- VERDURAS (17 productos)*/
gasto_hogar_verduras=
gasto_hogar_aguacate
+gasto_hogar_jitomate
+gasto_hogar_papa
+gasto_hogar_cebolla
+gasto_hogar_tomate_verde
+gasto_hogar_col
+gasto_hogar_lechuga
+gasto_hogar_calabacita
+gasto_hogar_zanahoria
+gasto_hogar_chile_serrano
+gasto_hogar_nopales
+gasto_hogar_chayote
+gasto_hogar_chile_poblano
+gasto_hogar_pepino
+gasto_hogar_ejotes
+gasto_hogar_chicharo
+gasto_hogar_frijol;

/* 9.- BEBIDAS (3 productos)*/
gasto_hogar_bebidas=
gasto_hogar_jugos
+gasto_hogar_refrescos
+gasto_hogar_agua;

/* 10.- MEDICAMENTOS (8 productos)*/
gasto_hogar_medicinas=
gasto_hogar_antibioticos
+gasto_hogar_cardiovasculares
+gasto_hogar_analgesicos
+gasto_hogar_nutricionales
+gasto_hogar_gastrointestinales
+gasto_hogar_antigripales
+gasto_hogar_tos
+gasto_hogar_dermatologicos;

/* 11.- TRANSPORTE FORANEO (2 productos)*/
gasto_hogar_transporte_foraneo=
gasto_hogar_autobus_foraneo
+
gasto_hogar_transporte_aereo;


/* 12.- MATERIALES DE CONSTRUCCION (1 producto agregado)*/
gasto_hogar_materiales=
gasto_hogar_materiales;


/*1.- TORTILLAS*/
precios_hogar_tortillas=P_hogar_tortillas_2014;

/*2.- PAN*/
w_pan_blanco=gasto_hogar_pan_blanco./gasto_hogar_pan;
w_pan_dulce=gasto_hogar_pan_dulce./gasto_hogar_pan;
w_bar_pan_blanco=meanc(w_pan_blanco);
w_bar_pan_dulce=meanc(w_pan_dulce);
k_PAN=(w_bar_pan_blanco.^(-w_bar_pan_blanco)).*(w_bar_pan_dulce.^(-w_bar_pan_dulce));
precios_hogar_pan=(1/k_PAN)*((P_hogar_pan_blanco_2014./w_pan_blanco).^w_pan_blanco).*((P_hogar_pan_dulce_2014./w_pan_dulce).^w_pan_dulce);

/*3.- POLLO Y HUEVO*/
w_pollo_entero=gasto_hogar_pollo_entero./gasto_hogar_pollo_huevo;
w_pollo_piezas=gasto_hogar_pollo_piezas./gasto_hogar_pollo_huevo;
w_huevo=gasto_hogar_huevo./gasto_hogar_pollo_huevo;
w_bar_pollo_entero=meanc(w_pollo_entero);
w_bar_pollo_piezas=meanc(w_pollo_piezas);
w_bar_huevo=meanc(w_huevo);
k_POLLO_HUEVO=(w_bar_pollo_entero.^(-w_bar_pollo_entero)).*(w_bar_pollo_piezas.^(-w_bar_pollo_piezas)).*(w_bar_huevo.^(-w_bar_huevo));
precios_hogar_pollo_huevo=(1/k_POLLO_HUEVO)*((P_hogar_pollo_entero_2014./w_pollo_entero).^w_pollo_entero).*((P_hogar_pollo_piezas_2014./w_pollo_piezas).^w_pollo_piezas)
.*((P_hogar_huevo_2014./w_huevo).^w_huevo);


/*4.- CARNE DE RES*/
w_bistec_res=gasto_hogar_bistec_res./gasto_hogar_carne_res;
w_molida_res=gasto_hogar_molida_res./gasto_hogar_carne_res;
w_visceras_res=gasto_hogar_visceras_res./gasto_hogar_carne_res;
w_bar_bistec_res=meanc(w_bistec_res);
w_bar_molida_res=meanc(w_molida_res);
w_bar_visceras_res=meanc(w_visceras_res);
k_CARNE_RES=(w_bar_bistec_res.^(-w_bar_bistec_res)).*(w_bar_molida_res.^(-w_bar_molida_res)).*(w_bar_visceras_res.^(-w_bar_visceras_res));
precios_hogar_carne_res=(1/k_CARNE_RES)*((P_hogar_bistec_res_2014./w_bistec_res).^w_bistec_res).*((P_hogar_molida_res_2014./w_molida_res).^w_molida_res)
.*((P_hogar_visceras_res_2014./w_visceras_res).^w_visceras_res);


/*5.- CARNES PROCESADAS*/
w_chorizo=gasto_hogar_chorizo./gasto_hogar_carnes_procesadas;
w_jamon=gasto_hogar_jamon./gasto_hogar_carnes_procesadas;
w_salchichas=gasto_hogar_salchichas./gasto_hogar_carnes_procesadas;
w_tocino=gasto_hogar_tocino./gasto_hogar_carnes_procesadas; 
w_bar_chorizo=meanc(w_chorizo);
w_bar_jamon=meanc(w_jamon);
w_bar_salchichas=meanc(w_salchichas);
w_bar_tocino=meanc(w_tocino);
k_CARNES_PROCESADAS=(w_bar_chorizo.^(-w_bar_chorizo)).*(w_bar_jamon.^(-w_bar_jamon)).*(w_bar_salchichas.^(-w_bar_salchichas)).*(w_bar_tocino.^(-w_bar_tocino));
precios_hogar_carnes_procesadas=(1/k_CARNES_PROCESADAS)*((P_hogar_chorizo_2014./w_chorizo).^w_chorizo).*((P_hogar_jamon_2014./w_jamon).^w_jamon)
.*((P_hogar_salchichas_2014./w_salchichas).^w_salchichas).*((P_hogar_tocino_2014./w_tocino).^w_tocino);


/*6.- LACTEOS*/
w_leche_pasteur=gasto_hogar_leche_pasteur./gasto_hogar_lacteos;
w_leche_en_polvo=gasto_hogar_leche_en_polvo./gasto_hogar_lacteos;
w_leche_maternizada=gasto_hogar_leche_maternizada./gasto_hogar_lacteos;
w_leche_condensada=gasto_hogar_leche_condensada./gasto_hogar_lacteos;
w_queso_fresco=gasto_hogar_queso_fresco./gasto_hogar_lacteos;
w_queso_oaxaca=gasto_hogar_queso_oaxaca./gasto_hogar_lacteos;
w_queso_amarillo=gasto_hogar_queso_amarillo./gasto_hogar_lacteos;
w_crema_leche=gasto_hogar_crema_leche./gasto_hogar_lacteos;
w_mantequilla=gasto_hogar_mantequilla./gasto_hogar_lacteos;
w_bar_leche_pasteur=meanc(w_leche_pasteur);
w_bar_leche_en_polvo=meanc(w_leche_en_polvo);
w_bar_leche_maternizada=meanc(w_leche_maternizada);
w_bar_leche_condensada=meanc(w_leche_condensada);
w_bar_queso_fresco=meanc(w_queso_fresco);
w_bar_queso_oaxaca=meanc(w_queso_oaxaca);
w_bar_queso_amarillo=meanc(w_queso_amarillo);
w_bar_crema_leche=meanc(w_crema_leche);
w_bar_mantequilla=meanc(w_mantequilla);
k_LACTEOS=(w_bar_leche_pasteur.^(-w_bar_leche_pasteur)).*(w_bar_leche_en_polvo.^(-w_bar_leche_en_polvo)).*(w_bar_leche_maternizada.^(-w_bar_leche_maternizada))
.*(w_bar_leche_condensada.^(-w_bar_leche_condensada)).*(w_bar_queso_fresco.^(-w_bar_queso_fresco)).*(w_bar_queso_oaxaca.^(-w_bar_queso_oaxaca)).*(w_bar_queso_amarillo.^(-w_bar_queso_amarillo))
.*(w_bar_crema_leche.^(-w_bar_crema_leche)).*(w_bar_mantequilla.^(-w_bar_mantequilla));
precios_hogar_lacteos=(1/k_LACTEOS)*((P_hogar_leche_pasteurizada_2014./w_leche_pasteur).^w_leche_pasteur).*((P_hogar_leche_en_polvo_2014./w_leche_en_polvo).^w_leche_en_polvo)
.*((P_hogar_leche_maternizada_2014./w_leche_maternizada).^w_leche_maternizada).*((P_hogar_leche_condensada_2014./w_leche_condensada).^w_leche_condensada)
.*((P_hogar_queso_fresco_2014./w_queso_fresco).^w_queso_fresco).*((P_hogar_queso_oaxaca_2014./w_queso_oaxaca).^w_queso_oaxaca).*((P_hogar_queso_amarillo_2014./w_queso_amarillo).^w_queso_amarillo)
.*((P_hogar_crema_de_leche_2014./w_crema_leche).^w_crema_leche).*((P_hogar_mantequilla_2014./w_mantequilla).^w_mantequilla);


/* 7.- FRUTAS*/
w_manzana=gasto_hogar_manzana./gasto_hogar_frutas;
w_platano=gasto_hogar_platano./gasto_hogar_frutas;
w_papaya=gasto_hogar_papaya./gasto_hogar_frutas;
w_naranja=gasto_hogar_naranja./gasto_hogar_frutas;
w_limon=gasto_hogar_limon./gasto_hogar_frutas;
w_melon=gasto_hogar_melon./gasto_hogar_frutas;
w_uvas=gasto_hogar_uvas./gasto_hogar_frutas;
w_pera=gasto_hogar_pera./gasto_hogar_frutas;
w_guayaba=gasto_hogar_guayaba./gasto_hogar_frutas;
w_sandia=gasto_hogar_sandia./gasto_hogar_frutas;
w_pina=gasto_hogar_pina./gasto_hogar_frutas;
w_bar_manzana=meanc(w_manzana);
w_bar_platano=meanc(w_platano);
w_bar_papaya=meanc(w_papaya);
w_bar_naranja=meanc(w_naranja);
w_bar_limon=meanc(w_limon);
w_bar_melon=meanc(w_melon);
w_bar_uvas=meanc(w_uvas);
w_bar_pera=meanc(w_pera);
w_bar_guayaba=meanc(w_guayaba);
w_bar_sandia=meanc(w_sandia);
w_bar_pina=meanc(w_pina);
k_FRUTAS=(w_bar_manzana.^(-w_bar_manzana)).*(w_bar_platano.^(-w_bar_platano)).*(w_bar_papaya.^(-w_bar_papaya)).*(w_bar_naranja.^(-w_bar_naranja))
.*(w_bar_limon.^(-w_bar_limon)).*(w_bar_melon.^(-w_bar_melon)).*(w_bar_uvas.^(-w_bar_uvas)).*(w_bar_pera.^(-w_bar_pera)).*(w_bar_guayaba.^(-w_bar_guayaba))
.*(w_bar_sandia.^(-w_bar_sandia)).*(w_bar_pina.^(-w_bar_pina));
precios_hogar_frutas=(1/k_FRUTAS)*((P_hogar_manzana_2014./w_manzana).^w_manzana).*((P_hogar_platanos_2014./w_platano).^w_platano).*((P_hogar_papaya_2014./w_papaya).^w_papaya)
.*((P_hogar_naranja_2014./w_naranja).^w_naranja).*((P_hogar_limon_2014./w_limon).^w_limon).*((P_hogar_melon_2014./w_melon).^w_melon)
.*((P_hogar_uvas_2014./w_uvas).^w_uvas).*((P_hogar_pera_2014./w_pera).^w_pera).*((P_hogar_guayaba_2014./w_guayaba).^w_guayaba)
.*((P_hogar_sandia_2014./w_sandia).^w_sandia).*((P_hogar_pina_2014./w_pina).^w_pina);


/*8.- VERDURAS*/
w_aguacate=gasto_hogar_aguacate./gasto_hogar_verduras;
w_jitomate=gasto_hogar_jitomate./gasto_hogar_verduras;
w_papa=gasto_hogar_papa./gasto_hogar_verduras;
w_cebolla=gasto_hogar_cebolla./gasto_hogar_verduras;
w_tomate_verde=gasto_hogar_tomate_verde./gasto_hogar_verduras;
w_col=gasto_hogar_col./gasto_hogar_verduras;
w_lechuga=gasto_hogar_lechuga./gasto_hogar_verduras;
w_calabacita=gasto_hogar_calabacita./gasto_hogar_verduras;
w_zanahoria=gasto_hogar_zanahoria./gasto_hogar_verduras;
w_chile_serrano=gasto_hogar_chile_serrano./gasto_hogar_verduras;
w_nopales=gasto_hogar_nopales./gasto_hogar_verduras;
w_chayote=gasto_hogar_chayote./gasto_hogar_verduras;
w_chile_poblano=gasto_hogar_chile_poblano./gasto_hogar_verduras;
w_pepino=gasto_hogar_pepino./gasto_hogar_verduras;
w_ejotes=gasto_hogar_ejotes./gasto_hogar_verduras;
w_chicharo=gasto_hogar_chicharo./gasto_hogar_verduras;
w_frijol=gasto_hogar_frijol./gasto_hogar_verduras;
w_bar_aguacate=meanc(w_aguacate);
w_bar_jitomate=meanc(w_jitomate);
w_bar_papa=meanc(w_papa);
w_bar_cebolla=meanc(w_cebolla);
w_bar_tomate_verde=meanc(w_tomate_verde);
w_bar_col=meanc(w_col);
w_bar_lechuga=meanc(w_lechuga);
w_bar_calabacita=meanc(w_calabacita);
w_bar_zanahoria=meanc(w_zanahoria);
w_bar_chile_serrano=meanc(w_chile_serrano);
w_bar_nopales=meanc(w_nopales);
w_bar_chayote=meanc(w_chayote);
w_bar_chile_poblano=meanc(w_chile_poblano);
w_bar_pepino=meanc(w_pepino);
w_bar_ejotes=meanc(w_ejotes);
w_bar_chicharo=meanc(w_chicharo);
w_bar_frijol=meanc(w_frijol);
k_VERDURAS=(w_bar_aguacate.^(-w_bar_aguacate)).*(w_bar_jitomate.^(-w_bar_jitomate)).*(w_bar_papa.^(-w_bar_papa))
.*(w_bar_cebolla.^(-w_bar_cebolla)).*(w_bar_tomate_verde.^(-w_bar_tomate_verde)).*(w_bar_col.^(-w_bar_col))
.*(w_bar_lechuga.^(-w_bar_lechuga)).*(w_bar_calabacita.^(-w_bar_calabacita)).*(w_bar_zanahoria.^(-w_bar_zanahoria))
.*(w_bar_chile_serrano.^(-w_bar_chile_serrano)).*(w_bar_nopales.^(-w_bar_nopales)).*(w_bar_chayote.^(-w_bar_chayote))
.*(w_bar_chile_poblano.^(-w_bar_chile_poblano)).*(w_bar_pepino.^(-w_bar_pepino)).*(w_bar_ejotes.^(-w_bar_ejotes))
.*(w_bar_chicharo.^(-w_bar_chicharo)).*(w_bar_frijol.^(-w_bar_frijol));
precios_hogar_verduras=(1/k_VERDURAS)*((P_hogar_aguacate_2014./w_aguacate).^w_aguacate).*((P_hogar_jitomate_2014./w_jitomate).^w_jitomate)
.*((P_hogar_papa_2014./w_papa).^w_papa).*((P_hogar_cebolla_2014./w_cebolla).^w_cebolla)
.*((P_hogar_tomate_verde_2014./w_tomate_verde).^w_tomate_verde).*((P_hogar_col_2014./w_col).^w_col)
.*((P_hogar_lechuga_2014./w_lechuga).^w_lechuga).*((P_hogar_calabacita_2014./w_calabacita).^w_calabacita)
.*((P_hogar_zanahoria_2014./w_zanahoria).^w_zanahoria).*((P_hogar_chile_serrano_2014./w_chile_serrano).^w_chile_serrano)
.*((P_hogar_nopales_2014./w_nopales).^w_nopales).*((P_hogar_chayote_2014./w_chayote).^w_chayote)
.*((P_hogar_chile_poblano_2014./w_chile_poblano).^w_chile_poblano).*((P_hogar_pepino_2014./w_pepino).^w_pepino)
.*((P_hogar_ejotes_2014./w_ejotes).^w_ejotes).*((P_hogar_chicharo_2014./w_chicharo).^w_chicharo)
.*((P_hogar_frijol_2014./w_frijol).^w_frijol);

/* 9.- BEBIDAS*/
w_jugos=gasto_hogar_jugos./gasto_hogar_bebidas;
w_refrescos=gasto_hogar_refrescos./gasto_hogar_bebidas;
w_agua=gasto_hogar_agua./gasto_hogar_bebidas;
w_bar_jugos=meanc(w_jugos);
w_bar_refrescos=meanc(w_refrescos);
w_bar_agua=meanc(w_agua);
k_BEBIDAS=(w_bar_jugos.^(-w_bar_jugos)).*(w_bar_refrescos.^(-w_bar_refrescos)).*(w_bar_agua.^(-w_bar_agua));
precios_hogar_bebidas=(1/k_BEBIDAS)*((P_hogar_jugos_nectares_2014./w_jugos).^w_jugos)
.*((P_hogar_refrescos_envasados_2014./w_refrescos).^w_refrescos)
.*((P_hogar_agua_embotellada_2014./w_agua).^w_agua);


/* 10.- MEDICAMENTOS*/
w_antibioticos=gasto_hogar_antibioticos./gasto_hogar_medicinas;
w_cardiovasculares=gasto_hogar_cardiovasculares./gasto_hogar_medicinas;
w_analgesicos=gasto_hogar_analgesicos./gasto_hogar_medicinas;
w_nutricionales=gasto_hogar_nutricionales./gasto_hogar_medicinas;
w_gastrointestinales=gasto_hogar_gastrointestinales./gasto_hogar_medicinas;
w_antigripales=gasto_hogar_antigripales./gasto_hogar_medicinas;
w_tos=gasto_hogar_tos./gasto_hogar_medicinas;
w_dermatologicos=gasto_hogar_dermatologicos./gasto_hogar_medicinas;
w_bar_antibioticos=meanc(w_antibioticos);
w_bar_cardiovasculares=meanc(w_cardiovasculares);
w_bar_analgesicos=meanc(w_analgesicos);
w_bar_nutricionales=meanc(w_nutricionales);
w_bar_gastrointestinales=meanc(w_gastrointestinales);
w_bar_antigripales=meanc(w_antigripales);
w_bar_tos=meanc(w_tos);
w_bar_dermatologicos=meanc(w_dermatologicos);
k_MEDICINAS=(w_bar_antibioticos.^(-w_bar_antibioticos)).*(w_bar_cardiovasculares.^(-w_bar_cardiovasculares))
.*(w_bar_analgesicos.^(-w_bar_analgesicos)).*(w_bar_nutricionales.^(-w_bar_nutricionales))
.*(w_bar_gastrointestinales.^(-w_bar_gastrointestinales)).*(w_bar_antigripales.^(-w_bar_antigripales))
.*(w_bar_tos.^(-w_bar_tos)).*(w_bar_dermatologicos.^(-w_bar_dermatologicos));
precios_hogar_medicinas=(1/k_MEDICINAS)*((P_hogar_antibioticos_2014./w_antibioticos).^w_antibioticos)
.*((P_hogar_cardiovasculares_2014./w_cardiovasculares).^w_cardiovasculares)
.*((P_hogar_analgesicos_2014./w_analgesicos).^w_analgesicos)
.*((P_hogar_nutricionales_2014./w_nutricionales).^w_nutricionales)
.*((P_hogar_gastrointestinales_2014./w_gastrointestinales).^w_gastrointestinales)
.*((P_hogar_antigripales_2014./w_antigripales).^w_antigripales)
.*((P_hogar_medicinas_tos_2014./w_tos).^w_tos)
.*((P_hogar_medicinas_piel_2014./w_dermatologicos).^w_dermatologicos);


/* 11.- TRANSPORTE FORANEO*/
w_autobus_foraneo=gasto_hogar_autobus_foraneo./gasto_hogar_transporte_foraneo;
w_transporte_aereo=gasto_hogar_transporte_aereo./gasto_hogar_transporte_foraneo;

w_bar_autobus_foraneo=meanc(w_autobus_foraneo);
w_bar_transporte_aereo=meanc(w_transporte_aereo);
k_TRANSPORTE=(w_bar_autobus_foraneo.^(-w_bar_autobus_foraneo)).*(w_bar_transporte_aereo.^(-w_bar_transporte_aereo));

precios_hogar_transporte_foraneo=(1/k_TRANSPORTE)*((P_hogar_autobus_foraneo_2014./w_autobus_foraneo).^w_autobus_foraneo)
.*((P_hogar_transporte_aereo_2014./w_transporte_aereo).^w_transporte_aereo);

/*12.- MATERIALES*/
precios_hogar_materiales=P_hogar_materiales_2014;

n_categ_min=1;
min_gasto=10;

categorias_relevantes_por_hogar=
(gasto_hogar_tortillas .ge min_gasto)+(gasto_hogar_pan .ge min_gasto)+(gasto_hogar_pollo_huevo .ge min_gasto)+(gasto_hogar_carne_res .ge min_gasto)
+(gasto_hogar_carnes_procesadas .ge min_gasto)+(gasto_hogar_lacteos .ge min_gasto)+(gasto_hogar_frutas .ge min_gasto)+(gasto_hogar_verduras .ge min_gasto)
+(gasto_hogar_bebidas .ge min_gasto)+(gasto_hogar_medicinas .ge min_gasto)+(gasto_hogar_transporte_foraneo .ge min_gasto)
+(gasto_hogar_materiales .ge min_gasto);


/*1.-*/ gasto_hogar_tortillas=selif(gasto_hogar_tortillas, categorias_relevantes_por_hogar .ge n_categ_min);
/*2.-*/ gasto_hogar_pan=selif(gasto_hogar_pan, categorias_relevantes_por_hogar .ge n_categ_min);
/*3.-*/ gasto_hogar_pollo_huevo=selif(gasto_hogar_pollo_huevo, categorias_relevantes_por_hogar .ge n_categ_min);
/*4.-*/ gasto_hogar_carne_res=selif(gasto_hogar_carne_res, categorias_relevantes_por_hogar .ge n_categ_min);
/*5.-*/ gasto_hogar_carnes_procesadas=selif(gasto_hogar_carnes_procesadas, categorias_relevantes_por_hogar .ge n_categ_min);
/*6.-*/ gasto_hogar_lacteos=selif(gasto_hogar_lacteos, categorias_relevantes_por_hogar .ge n_categ_min);
/*7.-*/ gasto_hogar_frutas=selif(gasto_hogar_frutas, categorias_relevantes_por_hogar .ge n_categ_min);
/*8.-*/ gasto_hogar_verduras=selif(gasto_hogar_verduras, categorias_relevantes_por_hogar .ge n_categ_min);
/*9.-*/ gasto_hogar_bebidas=selif(gasto_hogar_bebidas, categorias_relevantes_por_hogar .ge n_categ_min);
/*10.-*/ gasto_hogar_medicinas=selif(gasto_hogar_medicinas, categorias_relevantes_por_hogar .ge n_categ_min);
/*11.-*/ gasto_hogar_transporte_foraneo=selif(gasto_hogar_transporte_foraneo, categorias_relevantes_por_hogar .ge n_categ_min);
/*12.-*/ gasto_hogar_materiales=selif(gasto_hogar_materiales, categorias_relevantes_por_hogar .ge n_categ_min);

gasto_hogar_autobus_foraneo=selif(gasto_hogar_autobus_foraneo, categorias_relevantes_por_hogar .ge n_categ_min); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
gasto_hogar_transporte_aereo=selif(gasto_hogar_transporte_aereo, categorias_relevantes_por_hogar .ge n_categ_min); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/


/*1.-*/ precios_hogar_tortillas=selif(precios_hogar_tortillas, categorias_relevantes_por_hogar .ge n_categ_min);
/*2.-*/ precios_hogar_pan=selif(precios_hogar_pan, categorias_relevantes_por_hogar .ge n_categ_min);
/*3.-*/ precios_hogar_pollo_huevo=selif(precios_hogar_pollo_huevo, categorias_relevantes_por_hogar .ge n_categ_min);
/*4.-*/ precios_hogar_carne_res=selif(precios_hogar_carne_res, categorias_relevantes_por_hogar .ge n_categ_min);
/*5.-*/ precios_hogar_carnes_procesadas=selif(precios_hogar_carnes_procesadas, categorias_relevantes_por_hogar .ge n_categ_min);
/*6.-*/ precios_hogar_lacteos=selif(precios_hogar_lacteos, categorias_relevantes_por_hogar .ge n_categ_min);
/*7.-*/ precios_hogar_frutas=selif(precios_hogar_frutas, categorias_relevantes_por_hogar .ge n_categ_min);
/*8.-*/ precios_hogar_verduras=selif(precios_hogar_verduras, categorias_relevantes_por_hogar .ge n_categ_min);
/*9.-*/ precios_hogar_bebidas=selif(precios_hogar_bebidas, categorias_relevantes_por_hogar .ge n_categ_min);
/*10.-*/ precios_hogar_medicinas=selif(precios_hogar_medicinas, categorias_relevantes_por_hogar .ge n_categ_min);
/*11.-*/ precios_hogar_transporte_foraneo=selif(precios_hogar_transporte_foraneo, categorias_relevantes_por_hogar .ge n_categ_min);
/*12.-*/ precios_hogar_materiales=selif(precios_hogar_materiales, categorias_relevantes_por_hogar .ge n_categ_min);

P_hogar_autobus_foraneo_2014=selif(P_hogar_autobus_foraneo_2014, categorias_relevantes_por_hogar .ge n_categ_min); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
P_hogar_transporte_aereo_2014=selif(P_hogar_transporte_aereo_2014, categorias_relevantes_por_hogar .ge n_categ_min); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/


vars_concentrado_hogares=selif(vars_concentrado_hogares, categorias_relevantes_por_hogar .ge n_categ_min);
dist_ciudad_46_mas_cercana=selif(dist_ciudad_46_mas_cercana, categorias_relevantes_por_hogar .ge n_categ_min);
ciudad_46_mas_cercana=selif(ciudad_46_mas_cercana, categorias_relevantes_por_hogar .ge n_categ_min);
clave_vivienda_concentrados=vars_concentrado_hogares[.,1]; 
num_hogares=rows(clave_vivienda_concentrados);


gasto_todas_categorias=gasto_hogar_tortillas+gasto_hogar_pan+gasto_hogar_pollo_huevo+gasto_hogar_carne_res
+gasto_hogar_carnes_procesadas+gasto_hogar_lacteos+gasto_hogar_frutas+gasto_hogar_verduras+gasto_hogar_bebidas
+gasto_hogar_medicinas+gasto_hogar_transporte_foraneo+gasto_hogar_materiales;

/*1.-*/ w_tortillas=gasto_hogar_tortillas./gasto_todas_categorias;
/*2.-*/ w_pan=gasto_hogar_pan./gasto_todas_categorias;
/*3.-*/ w_pollo_huevo=gasto_hogar_pollo_huevo./gasto_todas_categorias;
/*4.-*/ w_carne_res=gasto_hogar_carne_res./gasto_todas_categorias;
/*5.-*/ w_carnes_procesadas=gasto_hogar_carnes_procesadas./gasto_todas_categorias;
/*6.-*/ w_lacteos=gasto_hogar_lacteos./gasto_todas_categorias;
/*7.-*/ w_frutas=gasto_hogar_frutas./gasto_todas_categorias;
/*8.-*/ w_verduras=gasto_hogar_verduras./gasto_todas_categorias;
/*9.-*/ w_bebidas=gasto_hogar_bebidas./gasto_todas_categorias;
/*10.-*/ w_medicinas=gasto_hogar_medicinas./gasto_todas_categorias;
/*11.-*/ w_transporte_foraneo=gasto_hogar_transporte_foraneo./gasto_todas_categorias;
/*12.-*/ w_materiales=gasto_hogar_materiales./gasto_todas_categorias;

w_todos=w_tortillas~w_pan~w_pollo_huevo~w_carne_res~w_carnes_procesadas~w_lacteos~w_frutas~w_verduras~w_bebidas~w_medicinas~w_transporte_foraneo~w_materiales;


load hogares_lavadoras[19124,2]=hogares_lavadoras_ENIGH_2014.asc;
clave_hogar_lavadoras=hogares_lavadoras[.,1];
numero_de_lavadoras=hogares_lavadoras[.,2];
indicadora_lavadora=(numero_de_lavadoras .gt 0);
hogar_tiene_lavadora=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;
hogar_en_turno=clave_vivienda_concentrados[i];
aux_lavadoras=selif(numero_de_lavadoras, clave_hogar_lavadoras .eq hogar_en_turno);
hogar_tiene_lavadora[i]=(sumc(aux_lavadoras) .gt 0);
i=i+1;
endo;	


load hogares_vehiculos[19124,2]=hogares_vehiculos_ENIGH_2014.asc;
clave_hogar_vehiculos=hogares_vehiculos[.,1];
numero_de_vehiculos=hogares_vehiculos[.,2];
indicadora_vehiculos=(numero_de_vehiculos .gt 0);
hogar_tiene_vehiculo=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;
hogar_en_turno=clave_vivienda_concentrados[i];
aux_vehiculos=selif(numero_de_vehiculos, clave_hogar_vehiculos .eq hogar_en_turno);
hogar_tiene_vehiculo[i]=(sumc(aux_vehiculos) .gt 0);
i=i+1;
endo;	

gasto_1=gasto_hogar_tortillas;
gasto_2=gasto_hogar_pan;
gasto_3=gasto_hogar_pollo_huevo;
gasto_4=gasto_hogar_carne_res;
gasto_5=gasto_hogar_carnes_procesadas;
gasto_6=gasto_hogar_lacteos;
gasto_7=gasto_hogar_frutas;
gasto_8=gasto_hogar_verduras;
gasto_9=gasto_hogar_bebidas;
gasto_10=gasto_hogar_medicinas;
gasto_11=gasto_hogar_transporte_foraneo;
gasto_12=gasto_hogar_materiales;

gasto_autobus_foraneo=gasto_hogar_autobus_foraneo; 
gasto_transporte_aereo=gasto_hogar_transporte_aereo; 

gastos_matrix=gasto_1~gasto_2~gasto_3~gasto_4~gasto_5~gasto_6~gasto_7~gasto_8~gasto_9~gasto_10~gasto_11~gasto_12;

suma_gastos=gasto_1+gasto_2+gasto_3+gasto_4+gasto_5+gasto_6+gasto_7+gasto_8+gasto_9+gasto_10+gasto_11+gasto_12;

w_1=gasto_1./suma_gastos;
w_2=gasto_2./suma_gastos;
w_3=gasto_3./suma_gastos;
w_4=gasto_4./suma_gastos;
w_5=gasto_5./suma_gastos;
w_6=gasto_6./suma_gastos;
w_7=gasto_7./suma_gastos;
w_8=gasto_8./suma_gastos;
w_9=gasto_9./suma_gastos;
w_10=gasto_10./suma_gastos;
w_11=gasto_11./suma_gastos;
w_12=gasto_12./suma_gastos;

w_matrix=w_1~w_2~w_3~w_4~w_5~w_6~w_7~w_8~w_9~w_10~w_11~w_12;

precio_1=ln(precios_hogar_tortillas);
precio_2=ln(precios_hogar_pan);
precio_3=ln(precios_hogar_pollo_huevo);
precio_4=ln(precios_hogar_carne_res);
precio_5=ln(precios_hogar_carnes_procesadas);
precio_6=ln(precios_hogar_lacteos);
precio_7=ln(precios_hogar_frutas);
precio_8=ln(precios_hogar_verduras);
precio_9=ln(precios_hogar_bebidas);
precio_10=ln(precios_hogar_medicinas);
precio_11=ln(precios_hogar_transporte_foraneo);
precio_12=ln(precios_hogar_materiales);

precio_autobus_foraneo=P_hogar_autobus_foraneo_2014; 
precio_transporte_aereo=P_hogar_transporte_aereo_2014; 

precios_matrix=precio_1~precio_2~precio_3~precio_4~precio_5~precio_6~precio_7~precio_8~precio_9~precio_10~precio_11~precio_12;

Z1=vars_concentrado_hogares[.,11]; 
Z2=vars_concentrado_hogares[.,12]; 
Z3=Z1.*Z2;
Z4=vars_concentrado_hogares[.,16];
Z5=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 8/10)); /*Indicadora: 1 si ingreso total > percentil 80*/
Z6=Z1.*Z4;
Z7=Z1^2;
Z8=(vars_concentrado_hogares[.,3] .eq 4);
Z9=hogar_tiene_vehiculo.*hogar_tiene_lavadora; 

Z1=vars_concentrado_hogares[.,11]; 
Z2=vars_concentrado_hogares[.,12]; 
Z3=Z1.*Z2;
Z4=vars_concentrado_hogares[.,16];
Z5=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 8/10)); /*Indicadora: 1 si ingreso total > percentil 80*/
Z6=Z1.*Z4;
Z7=Z1^2;
Z8=(vars_concentrado_hogares[.,3] .eq 4);
Z9=hogar_tiene_vehiculo.*hogar_tiene_lavadora; 


Z_vars=Z1~Z2~Z3~Z4~Z5~Z6~Z7~Z8~Z9;

q_1=precio_1-precio_12;
q_2=precio_2-precio_12;
q_3=precio_3-precio_12;
q_4=precio_4-precio_12;
q_5=precio_5-precio_12;
q_6=precio_6-precio_12;
q_7=precio_7-precio_12;
q_8=precio_8-precio_12;
q_9=precio_9-precio_12;
q_10=precio_10-precio_12;
q_11=precio_11-precio_12;

w_bar=meanc(w_matrix);

num_steps=16; 

rr=1;
do while rr .le num_steps;

if rr .eq 1;	
util=ln(suma_gastos)-precios_matrix*w_bar;
endif;

q_vector_categ_1=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
q_vector_Z_categ_1=
q_vector_categ_1.*Z1~q_vector_categ_1.*Z2~q_vector_categ_1.*Z3~q_vector_categ_1.*Z4~q_vector_categ_1.*Z5
~q_vector_categ_1.*Z6~q_vector_categ_1.*Z7~q_vector_categ_1.*Z8~q_vector_categ_1.*Z9;
X_covars_categ_1=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_1~q_vector_Z_categ_1;
Instrum_categ_1=X_covars_categ_1;
Y_categ_1=w_1;
beta_1=inv(Instrum_categ_1'*X_covars_categ_1)*Instrum_categ_1'*Y_categ_1;
epsilon_1=Y_categ_1-X_covars_categ_1*beta_1;
b0_1=beta_1[1]; 
b1_1=beta_1[2]; 
b2_1=beta_1[3]; 
b3_1=beta_1[4];
CZ1_1=beta_1[5]; 
CZ2_1=beta_1[6]; 
CZ3_1=beta_1[7]; 
CZ4_1=beta_1[8]; 
CZ5_1=beta_1[9]; 
CZ6_1=beta_1[10]; 
CZ7_1=beta_1[11]; 
CZ8_1=beta_1[12]; 
CZ9_1=beta_1[13];
DZ1_1=beta_1[14]; 
DZ2_1=beta_1[15]; 
DZ3_1=beta_1[16]; 
DZ4_1=beta_1[17]; 
DZ5_1=beta_1[18]; 
DZ6_1=beta_1[19]; 
DZ7_1=beta_1[20]; 
DZ8_1=beta_1[21]; 
DZ9_1=beta_1[22];
B_11=beta_1[23]; 
B_12=beta_1[24]; 
B_13=beta_1[25]; 
B_14=beta_1[26]; 
B_15=beta_1[27]; 
B_16=beta_1[28]; 
B_17=beta_1[29]; 
B_18=beta_1[30]; 
B_19=beta_1[31]; 
B_110=beta_1[32]; 
B_111=beta_1[33];
AZ1_11=beta_1[34]; 
AZ1_12=beta_1[35]; 
AZ1_13=beta_1[36]; 
AZ1_14=beta_1[37]; 
AZ1_15=beta_1[38]; 
AZ1_16=beta_1[39]; 
AZ1_17=beta_1[40]; 
AZ1_18=beta_1[41]; 
AZ1_19=beta_1[42]; 
AZ1_110=beta_1[43]; 
AZ1_111=beta_1[44];
AZ2_11=beta_1[45]; 
AZ2_12=beta_1[46]; 
AZ2_13=beta_1[47]; 
AZ2_14=beta_1[48]; 
AZ2_15=beta_1[49]; 
AZ2_16=beta_1[50]; 
AZ2_17=beta_1[51]; 
AZ2_18=beta_1[52]; 
AZ2_19=beta_1[53]; 
AZ2_110=beta_1[54]; 
AZ2_111=beta_1[55];
AZ3_11=beta_1[56]; 
AZ3_12=beta_1[57]; 
AZ3_13=beta_1[58]; 
AZ3_14=beta_1[59]; 
AZ3_15=beta_1[60]; 
AZ3_16=beta_1[61]; 
AZ3_17=beta_1[62]; 
AZ3_18=beta_1[63]; 
AZ3_19=beta_1[64]; 
AZ3_110=beta_1[65]; 
AZ3_111=beta_1[66];
AZ4_11=beta_1[67]; 
AZ4_12=beta_1[68]; 
AZ4_13=beta_1[69]; 
AZ4_14=beta_1[70]; 
AZ4_15=beta_1[71]; 
AZ4_16=beta_1[72]; 
AZ4_17=beta_1[73]; 
AZ4_18=beta_1[74]; 
AZ4_19=beta_1[75]; 
AZ4_110=beta_1[76]; 
AZ4_111=beta_1[77];
AZ5_11=beta_1[78]; 
AZ5_12=beta_1[79]; 
AZ5_13=beta_1[80]; 
AZ5_14=beta_1[81]; 
AZ5_15=beta_1[82]; 
AZ5_16=beta_1[83]; 
AZ5_17=beta_1[84]; 
AZ5_18=beta_1[85]; 
AZ5_19=beta_1[86]; 
AZ5_110=beta_1[87]; 
AZ5_111=beta_1[88];
AZ6_11=beta_1[89]; 
AZ6_12=beta_1[90]; 
AZ6_13=beta_1[91]; 
AZ6_14=beta_1[92]; 
AZ6_15=beta_1[93]; 
AZ6_16=beta_1[94]; 
AZ6_17=beta_1[95]; 
AZ6_18=beta_1[96]; 
AZ6_19=beta_1[97]; 
AZ6_110=beta_1[98]; 
AZ6_111=beta_1[99];
AZ7_11=beta_1[100]; 
AZ7_12=beta_1[101]; 
AZ7_13=beta_1[102]; 
AZ7_14=beta_1[103]; 
AZ7_15=beta_1[104]; 
AZ7_16=beta_1[105]; 
AZ7_17=beta_1[106]; 
AZ7_18=beta_1[107]; 
AZ7_19=beta_1[108]; 
AZ7_110=beta_1[109]; 
AZ7_111=beta_1[110];
AZ8_11=beta_1[111]; 
AZ8_12=beta_1[112]; 
AZ8_13=beta_1[113]; 
AZ8_14=beta_1[114]; 
AZ8_15=beta_1[115]; 
AZ8_16=beta_1[116]; 
AZ8_17=beta_1[117]; 
AZ8_18=beta_1[118]; 
AZ8_19=beta_1[119]; 
AZ8_110=beta_1[120]; 
AZ8_111=beta_1[121];
AZ9_11=beta_1[122]; 
AZ9_12=beta_1[123]; 
AZ9_13=beta_1[124]; 
AZ9_14=beta_1[125]; 
AZ9_15=beta_1[126]; 
AZ9_16=beta_1[127]; 
AZ9_17=beta_1[128]; 
AZ9_18=beta_1[129]; 
AZ9_19=beta_1[130]; 
AZ9_110=beta_1[131]; 
AZ9_111=beta_1[132];
if symmetry_imposed .eq 1;
q_vector_categ_2=q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_2=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;
q_vector_Z_categ_2=
q_vector_categ_2.*Z1~q_vector_categ_2.*Z2~q_vector_categ_2.*Z3~q_vector_categ_2.*Z4~q_vector_categ_2.*Z5
~q_vector_categ_2.*Z6~q_vector_categ_2.*Z7~q_vector_categ_2.*Z8~q_vector_categ_2.*Z9;
X_covars_categ_2=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_2~q_vector_Z_categ_2;
Instrum_categ_2=X_covars_categ_2;
if symmetry_imposed .eq 1;
Y_categ_2=w_2-q_1*B_12-(q_1.*Z_vars)*(AZ1_12|AZ2_12|AZ3_12|AZ4_12|AZ5_12|AZ6_12|AZ7_12|AZ8_12|AZ9_12);
else;
Y_categ_2=w_2;
endif;
beta_2=inv(Instrum_categ_2'*X_covars_categ_2)*Instrum_categ_2'*Y_categ_2;
epsilon_2=Y_categ_2-X_covars_categ_2*beta_2;
if symmetry_imposed .eq 1;
b0_2=beta_2[1]; 
b1_2=beta_2[2]; 
b2_2=beta_2[3]; 
b3_2=beta_2[4];
CZ1_2=beta_2[5]; 
CZ2_2=beta_2[6]; 
CZ3_2=beta_2[7]; 
CZ4_2=beta_2[8]; 
CZ5_2=beta_2[9]; 
CZ6_2=beta_2[10]; 
CZ7_2=beta_2[11]; 
CZ8_2=beta_2[12]; 
CZ9_2=beta_2[13];
DZ1_2=beta_2[14]; 
DZ2_2=beta_2[15]; 
DZ3_2=beta_2[16]; 
DZ4_2=beta_2[17]; 
DZ5_2=beta_2[18]; 
DZ6_2=beta_2[19]; 
DZ7_2=beta_2[20]; 
DZ8_2=beta_2[21]; 
DZ9_2=beta_2[22];
B_22=beta_2[23]; 
B_23=beta_2[24]; 
B_24=beta_2[25]; 
B_25=beta_2[26]; 
B_26=beta_2[27]; 
B_27=beta_2[28]; 
B_28=beta_2[29]; 
B_29=beta_2[30]; 
B_210=beta_2[31]; 
B_211=beta_2[32];
AZ1_22=beta_2[33]; 
AZ1_23=beta_2[34]; 
AZ1_24=beta_2[35]; 
AZ1_25=beta_2[36]; 
AZ1_26=beta_2[37]; 
AZ1_27=beta_2[38]; 
AZ1_28=beta_2[39]; 
AZ1_29=beta_2[40]; 
AZ1_210=beta_2[41]; 
AZ1_211=beta_2[42];
AZ2_22=beta_2[43]; 
AZ2_23=beta_2[44]; 
AZ2_24=beta_2[45]; 
AZ2_25=beta_2[46]; 
AZ2_26=beta_2[47]; 
AZ2_27=beta_2[48]; 
AZ2_28=beta_2[49]; 
AZ2_29=beta_2[50]; 
AZ2_210=beta_2[51]; 
AZ2_211=beta_2[52];
AZ3_22=beta_2[53]; 
AZ3_23=beta_2[54]; 
AZ3_24=beta_2[55]; 
AZ3_25=beta_2[56]; 
AZ3_26=beta_2[57]; 
AZ3_27=beta_2[58]; 
AZ3_28=beta_2[59]; 
AZ3_29=beta_2[60]; 
AZ3_210=beta_2[61]; 
AZ3_211=beta_2[62];
AZ4_22=beta_2[63]; 
AZ4_23=beta_2[64]; 
AZ4_24=beta_2[65]; 
AZ4_25=beta_2[66]; 
AZ4_26=beta_2[67]; 
AZ4_27=beta_2[68]; 
AZ4_28=beta_2[69]; 
AZ4_29=beta_2[70]; 
AZ4_210=beta_2[71]; 
AZ4_211=beta_2[72];
AZ5_22=beta_2[73]; 
AZ5_23=beta_2[74]; 
AZ5_24=beta_2[75]; 
AZ5_25=beta_2[76]; 
AZ5_26=beta_2[77]; 
AZ5_27=beta_2[78]; 
AZ5_28=beta_2[79]; 
AZ5_29=beta_2[80]; 
AZ5_210=beta_2[81]; 
AZ5_211=beta_2[82];
AZ6_22=beta_2[83]; 
AZ6_23=beta_2[84]; 
AZ6_24=beta_2[85]; 
AZ6_25=beta_2[86]; 
AZ6_26=beta_2[87]; 
AZ6_27=beta_2[88]; 
AZ6_28=beta_2[89]; 
AZ6_29=beta_2[90]; 
AZ6_210=beta_2[91]; 
AZ6_211=beta_2[92];
AZ7_22=beta_2[93]; 
AZ7_23=beta_2[94]; 
AZ7_24=beta_2[95]; 
AZ7_25=beta_2[96]; 
AZ7_26=beta_2[97]; 
AZ7_27=beta_2[98]; 
AZ7_28=beta_2[99]; 
AZ7_29=beta_2[100]; 
AZ7_210=beta_2[101]; 
AZ7_211=beta_2[102];
AZ8_22=beta_2[103]; 
AZ8_23=beta_2[104]; 
AZ8_24=beta_2[105]; 
AZ8_25=beta_2[106]; 
AZ8_26=beta_2[107]; 
AZ8_27=beta_2[108]; 
AZ8_28=beta_2[109]; 
AZ8_29=beta_2[110]; 
AZ8_210=beta_2[111]; 
AZ8_211=beta_2[112];
AZ9_22=beta_2[113]; 
AZ9_23=beta_2[114]; 
AZ9_24=beta_2[115]; 
AZ9_25=beta_2[116]; 
AZ9_26=beta_2[117]; 
AZ9_27=beta_2[118]; 
AZ9_28=beta_2[119]; 
AZ9_29=beta_2[120]; 
AZ9_210=beta_2[121]; 
AZ9_211=beta_2[122];
else;
b0_2=beta_2[1]; 
b1_2=beta_2[2]; 
b2_2=beta_2[3]; 
b3_2=beta_2[4];
CZ1_2=beta_2[5]; 
CZ2_2=beta_2[6]; 
CZ3_2=beta_2[7]; 
CZ4_2=beta_2[8]; 
CZ5_2=beta_2[9]; 
CZ6_2=beta_2[10]; 
CZ7_2=beta_2[11]; 
CZ8_2=beta_2[12]; 
CZ9_2=beta_2[13];
DZ1_2=beta_2[14]; 
DZ2_2=beta_2[15]; 
DZ3_2=beta_2[16]; 
DZ4_2=beta_2[17]; 
DZ5_2=beta_2[18]; 
DZ6_2=beta_2[19]; 
DZ7_2=beta_2[20]; 
DZ8_2=beta_2[21]; 
DZ9_2=beta_2[22];
B_21=beta_2[23]; 
B_22=beta_2[24]; 
B_23=beta_2[25]; 
B_24=beta_2[26]; 
B_25=beta_2[27]; 
B_26=beta_2[28]; 
B_27=beta_2[29]; 
B_28=beta_2[30]; 
B_29=beta_2[31]; 
B_210=beta_2[32]; 
B_211=beta_2[33];
AZ1_21=beta_2[34]; 
AZ1_22=beta_2[35]; 
AZ1_23=beta_2[36]; 
AZ1_24=beta_2[37]; 
AZ1_25=beta_2[38]; 
AZ1_26=beta_2[39]; 
AZ1_27=beta_2[40]; 
AZ1_28=beta_2[41]; 
AZ1_29=beta_2[42]; 
AZ1_210=beta_2[43]; 
AZ1_211=beta_2[44];
AZ2_21=beta_2[45]; 
AZ2_22=beta_2[46]; 
AZ2_23=beta_2[47]; 
AZ2_24=beta_2[48]; 
AZ2_25=beta_2[49]; 
AZ2_26=beta_2[50]; 
AZ2_27=beta_2[51]; 
AZ2_28=beta_2[52]; 
AZ2_29=beta_2[53]; 
AZ2_210=beta_2[54]; 
AZ2_211=beta_2[55];
AZ3_21=beta_2[56]; 
AZ3_22=beta_2[57]; 
AZ3_23=beta_2[58]; 
AZ3_24=beta_2[59]; 
AZ3_25=beta_2[60]; 
AZ3_26=beta_2[61]; 
AZ3_27=beta_2[62]; 
AZ3_28=beta_2[63]; 
AZ3_29=beta_2[64]; 
AZ3_210=beta_2[65]; 
AZ3_211=beta_2[66];
AZ4_21=beta_2[67]; 
AZ4_22=beta_2[68]; 
AZ4_23=beta_2[69]; 
AZ4_24=beta_2[70]; 
AZ4_25=beta_2[71]; 
AZ4_26=beta_2[72]; 
AZ4_27=beta_2[73]; 
AZ4_28=beta_2[74]; 
AZ4_29=beta_2[75]; 
AZ4_210=beta_2[76]; 
AZ4_211=beta_2[77];
AZ5_21=beta_2[78]; 
AZ5_22=beta_2[79]; 
AZ5_23=beta_2[80]; 
AZ5_24=beta_2[81]; 
AZ5_25=beta_2[82]; 
AZ5_26=beta_2[83]; 
AZ5_27=beta_2[84]; 
AZ5_28=beta_2[85]; 
AZ5_29=beta_2[86]; 
AZ5_210=beta_2[87]; 
AZ5_211=beta_2[88];
AZ6_21=beta_2[89]; 
AZ6_22=beta_2[90]; 
AZ6_23=beta_2[91]; 
AZ6_24=beta_2[92]; 
AZ6_25=beta_2[93]; 
AZ6_26=beta_2[94]; 
AZ6_27=beta_2[95]; 
AZ6_28=beta_2[96]; 
AZ6_29=beta_2[97]; 
AZ6_210=beta_2[98]; 
AZ6_211=beta_2[99];
AZ7_21=beta_2[100]; 
AZ7_22=beta_2[101]; 
AZ7_23=beta_2[102]; 
AZ7_24=beta_2[103]; 
AZ7_25=beta_2[104]; 
AZ7_26=beta_2[105]; 
AZ7_27=beta_2[106]; 
AZ7_28=beta_2[107]; 
AZ7_29=beta_2[108]; 
AZ7_210=beta_2[109]; 
AZ7_211=beta_2[110];
AZ8_21=beta_2[111]; 
AZ8_22=beta_2[112]; 
AZ8_23=beta_2[113]; 
AZ8_24=beta_2[114]; 
AZ8_25=beta_2[115]; 
AZ8_26=beta_2[116]; 
AZ8_27=beta_2[117]; 
AZ8_28=beta_2[118]; 
AZ8_29=beta_2[119]; 
AZ8_210=beta_2[120]; 
AZ8_211=beta_2[121];
AZ9_21=beta_2[122]; 
AZ9_22=beta_2[123]; 
AZ9_23=beta_2[124]; 
AZ9_24=beta_2[125]; 
AZ9_25=beta_2[126]; 
AZ9_26=beta_2[127]; 
AZ9_27=beta_2[128]; 
AZ9_28=beta_2[129]; 
AZ9_29=beta_2[130]; 
AZ9_210=beta_2[131]; 
AZ9_211=beta_2[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_3=q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_3=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_3=
q_vector_categ_3.*Z1~q_vector_categ_3.*Z2~q_vector_categ_3.*Z3~q_vector_categ_3.*Z4~q_vector_categ_3.*Z5
~q_vector_categ_3.*Z6~q_vector_categ_3.*Z7~q_vector_categ_3.*Z8~q_vector_categ_3.*Z9;
X_covars_categ_3=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_3~q_vector_Z_categ_3;
Instrum_categ_3=X_covars_categ_3;
if symmetry_imposed .eq 1;
Y_categ_3=
w_3
-q_1*B_13-(q_1.*Z_vars)*(AZ1_13|AZ2_13|AZ3_13|AZ4_13|AZ5_13|AZ6_13|AZ7_13|AZ8_13|AZ9_13)
-q_2*B_23-(q_2.*Z_vars)*(AZ1_23|AZ2_23|AZ3_23|AZ4_23|AZ5_23|AZ6_23|AZ7_23|AZ8_23|AZ9_23);
else;
Y_categ_3=w_3;
endif;	
beta_3=inv(Instrum_categ_3'*X_covars_categ_3)*Instrum_categ_3'*Y_categ_3;
epsilon_3=Y_categ_3-X_covars_categ_3*beta_3;
if symmetry_imposed .eq 1;
b0_3=beta_3[1]; 
b1_3=beta_3[2]; 
b2_3=beta_3[3]; 
b3_3=beta_3[4];
CZ1_3=beta_3[5]; 
CZ2_3=beta_3[6]; 
CZ3_3=beta_3[7]; 
CZ4_3=beta_3[8]; 
CZ5_3=beta_3[9]; 
CZ6_3=beta_3[10]; 
CZ7_3=beta_3[11]; 
CZ8_3=beta_3[12]; 
CZ9_3=beta_3[13];
DZ1_3=beta_3[14]; 
DZ2_3=beta_3[15]; 
DZ3_3=beta_3[16]; 
DZ4_3=beta_3[17]; 
DZ5_3=beta_3[18]; 
DZ6_3=beta_3[19]; 
DZ7_3=beta_3[20]; 
DZ8_3=beta_3[21]; 
DZ9_3=beta_3[22];
B_33=beta_3[23]; 
B_34=beta_3[24]; 
B_35=beta_3[25]; 
B_36=beta_3[26]; 
B_37=beta_3[27]; 
B_38=beta_3[28]; 
B_39=beta_3[29]; 
B_310=beta_3[30]; 
B_311=beta_3[31]; 
AZ1_33=beta_3[32]; 
AZ1_34=beta_3[33]; 
AZ1_35=beta_3[34]; 
AZ1_36=beta_3[35]; 
AZ1_37=beta_3[36]; 
AZ1_38=beta_3[37]; 
AZ1_39=beta_3[38]; 
AZ1_310=beta_3[39]; 
AZ1_311=beta_3[40];
AZ2_33=beta_3[41]; 
AZ2_34=beta_3[42]; 
AZ2_35=beta_3[43]; 
AZ2_36=beta_3[44]; 
AZ2_37=beta_3[45]; 
AZ2_38=beta_3[46]; 
AZ2_39=beta_3[47]; 
AZ2_310=beta_3[48]; 
AZ2_311=beta_3[49];
AZ3_33=beta_3[50]; 
AZ3_34=beta_3[51]; 
AZ3_35=beta_3[52]; 
AZ3_36=beta_3[53]; 
AZ3_37=beta_3[54]; 
AZ3_38=beta_3[55]; 
AZ3_39=beta_3[56]; 
AZ3_310=beta_3[57]; 
AZ3_311=beta_3[58];
AZ4_33=beta_3[59]; 
AZ4_34=beta_3[60]; 
AZ4_35=beta_3[61]; 
AZ4_36=beta_3[62]; 
AZ4_37=beta_3[63]; 
AZ4_38=beta_3[64]; 
AZ4_39=beta_3[65]; 
AZ4_310=beta_3[66]; 
AZ4_311=beta_3[67]; 
AZ5_33=beta_3[68]; 
AZ5_34=beta_3[69]; 
AZ5_35=beta_3[70]; 
AZ5_36=beta_3[71]; 
AZ5_37=beta_3[72]; 
AZ5_38=beta_3[73]; 
AZ5_39=beta_3[74]; 
AZ5_310=beta_3[75]; 
AZ5_311=beta_3[76];
AZ6_33=beta_3[77]; 
AZ6_34=beta_3[78]; 
AZ6_35=beta_3[79]; 
AZ6_36=beta_3[80]; 
AZ6_37=beta_3[81]; 
AZ6_38=beta_3[82]; 
AZ6_39=beta_3[83]; 
AZ6_310=beta_3[84]; 
AZ6_311=beta_3[85];
AZ7_33=beta_3[86]; 
AZ7_34=beta_3[87]; 
AZ7_35=beta_3[88]; 
AZ7_36=beta_3[89]; 
AZ7_37=beta_3[90]; 
AZ7_38=beta_3[91]; 
AZ7_39=beta_3[92]; 
AZ7_310=beta_3[93]; 
AZ7_311=beta_3[94];
AZ8_33=beta_3[95]; 
AZ8_34=beta_3[96]; 
AZ8_35=beta_3[97]; 
AZ8_36=beta_3[98]; 
AZ8_37=beta_3[99]; 
AZ8_38=beta_3[100]; 
AZ8_39=beta_3[101]; 
AZ8_310=beta_3[102]; 
AZ8_311=beta_3[103];
AZ9_33=beta_3[104]; 
AZ9_34=beta_3[105]; 
AZ9_35=beta_3[106]; 
AZ9_36=beta_3[107]; 
AZ9_37=beta_3[108]; 
AZ9_38=beta_3[109]; 
AZ9_39=beta_3[110]; 
AZ9_310=beta_3[111]; 
AZ9_311=beta_3[112];
else;
b0_3=beta_3[1]; 
b1_3=beta_3[2]; 
b2_3=beta_3[3]; 
b3_3=beta_3[4];
CZ1_3=beta_3[5]; 
CZ2_3=beta_3[6]; 
CZ3_3=beta_3[7]; 
CZ4_3=beta_3[8]; 
CZ5_3=beta_3[9]; 
CZ6_3=beta_3[10]; 
CZ7_3=beta_3[11]; 
CZ8_3=beta_3[12]; 
CZ9_3=beta_3[13];
DZ1_3=beta_3[14]; 
DZ2_3=beta_3[15]; 
DZ3_3=beta_3[16]; 
DZ4_3=beta_3[17]; 
DZ5_3=beta_3[18]; 
DZ6_3=beta_3[19]; 
DZ7_3=beta_3[20]; 
DZ8_3=beta_3[21]; 
DZ9_3=beta_3[22];
B_31=beta_3[23]; 
B_32=beta_3[24]; 
B_33=beta_3[25]; 
B_34=beta_3[26]; 
B_35=beta_3[27]; 
B_36=beta_3[28]; 
B_37=beta_3[29]; 
B_38=beta_3[30]; 
B_39=beta_3[31]; 
B_310=beta_3[32]; 
B_311=beta_3[33];
AZ1_31=beta_3[34]; 
AZ1_32=beta_3[35]; 
AZ1_33=beta_3[36]; 
AZ1_34=beta_3[37]; 
AZ1_35=beta_3[38]; 
AZ1_36=beta_3[39]; 
AZ1_37=beta_3[40]; 
AZ1_38=beta_3[41]; 
AZ1_39=beta_3[42]; 
AZ1_310=beta_3[43]; 
AZ1_311=beta_3[44];
AZ2_31=beta_3[45]; 
AZ2_32=beta_3[46]; 
AZ2_33=beta_3[47]; 
AZ2_34=beta_3[48]; 
AZ2_35=beta_3[49]; 
AZ2_36=beta_3[50]; 
AZ2_37=beta_3[51]; 
AZ2_38=beta_3[52]; 
AZ2_39=beta_3[53]; 
AZ2_310=beta_3[54]; 
AZ2_311=beta_3[55];
AZ3_31=beta_3[56]; 
AZ3_32=beta_3[57]; 
AZ3_33=beta_3[58]; 
AZ3_34=beta_3[59]; 
AZ3_35=beta_3[60]; 
AZ3_36=beta_3[61]; 
AZ3_37=beta_3[62]; 
AZ3_38=beta_3[63]; 
AZ3_39=beta_3[64]; 
AZ3_310=beta_3[65]; 
AZ3_311=beta_3[66];
AZ4_31=beta_3[67]; 
AZ4_32=beta_3[68]; 
AZ4_33=beta_3[69]; 
AZ4_34=beta_3[70]; 
AZ4_35=beta_3[71]; 
AZ4_36=beta_3[72]; 
AZ4_37=beta_3[73]; 
AZ4_38=beta_3[74]; 
AZ4_39=beta_3[75]; 
AZ4_310=beta_3[76]; 
AZ4_311=beta_3[77];
AZ5_31=beta_3[78]; 
AZ5_32=beta_3[79]; 
AZ5_33=beta_3[80]; 
AZ5_34=beta_3[81]; 
AZ5_35=beta_3[82]; 
AZ5_36=beta_3[83]; 
AZ5_37=beta_3[84]; 
AZ5_38=beta_3[85]; 
AZ5_39=beta_3[86]; 
AZ5_310=beta_3[87]; 
AZ5_311=beta_3[88];
AZ6_31=beta_3[89]; 
AZ6_32=beta_3[90]; 
AZ6_33=beta_3[91]; 
AZ6_34=beta_3[92]; 
AZ6_35=beta_3[93]; 
AZ6_36=beta_3[94]; 
AZ6_37=beta_3[95]; 
AZ6_38=beta_3[96]; 
AZ6_39=beta_3[97]; 
AZ6_310=beta_3[98]; 
AZ6_311=beta_3[99];
AZ7_31=beta_3[100]; 
AZ7_32=beta_3[101]; 
AZ7_33=beta_3[102]; 
AZ7_34=beta_3[103]; 
AZ7_35=beta_3[104]; 
AZ7_36=beta_3[105]; 
AZ7_37=beta_3[106]; 
AZ7_38=beta_3[107]; 
AZ7_39=beta_3[108]; 
AZ7_310=beta_3[109]; 
AZ7_311=beta_3[110];
AZ8_31=beta_3[111]; 
AZ8_32=beta_3[112]; 
AZ8_33=beta_3[113]; 
AZ8_34=beta_3[114]; 
AZ8_35=beta_3[115]; 
AZ8_36=beta_3[116]; 
AZ8_37=beta_3[117]; 
AZ8_38=beta_3[118]; 
AZ8_39=beta_3[119]; 
AZ8_310=beta_3[120]; 
AZ8_311=beta_3[121];
AZ9_31=beta_3[122]; 
AZ9_32=beta_3[123]; 
AZ9_33=beta_3[124]; 
AZ9_34=beta_3[125]; 
AZ9_35=beta_3[126]; 
AZ9_36=beta_3[127]; 
AZ9_37=beta_3[128]; 
AZ9_38=beta_3[129]; 
AZ9_39=beta_3[130]; 
AZ9_310=beta_3[131]; 
AZ9_311=beta_3[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_4=q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_4=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_4=
q_vector_categ_4.*Z1~q_vector_categ_4.*Z2~q_vector_categ_4.*Z3~q_vector_categ_4.*Z4~q_vector_categ_4.*Z5
~q_vector_categ_4.*Z6~q_vector_categ_4.*Z7~q_vector_categ_4.*Z8~q_vector_categ_4.*Z9;
X_covars_categ_4=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_4~q_vector_Z_categ_4;
Instrum_categ_4=X_covars_categ_4;
if symmetry_imposed .eq 1;
Y_categ_4=
w_4
-q_1*B_14-(q_1.*Z_vars)*(AZ1_14|AZ2_14|AZ3_14|AZ4_14|AZ5_14|AZ6_14|AZ7_14|AZ8_14|AZ9_14)
-q_2*B_24-(q_2.*Z_vars)*(AZ1_24|AZ2_24|AZ3_24|AZ4_24|AZ5_24|AZ6_24|AZ7_24|AZ8_24|AZ9_24)
-q_3*B_34-(q_3.*Z_vars)*(AZ1_34|AZ2_34|AZ3_34|AZ4_34|AZ5_34|AZ6_34|AZ7_34|AZ8_34|AZ9_34);
else;
Y_categ_4=w_4;
endif;		
beta_4=inv(Instrum_categ_4'*X_covars_categ_4)*Instrum_categ_4'*Y_categ_4;
epsilon_4=Y_categ_4-X_covars_categ_4*beta_4;
if symmetry_imposed .eq 1;
b0_4=beta_4[1]; 
b1_4=beta_4[2]; 
b2_4=beta_4[3]; 
b3_4=beta_4[4];
CZ1_4=beta_4[5]; 
CZ2_4=beta_4[6]; 
CZ3_4=beta_4[7]; 
CZ4_4=beta_4[8]; 
CZ5_4=beta_4[9]; 
CZ6_4=beta_4[10]; 
CZ7_4=beta_4[11]; 
CZ8_4=beta_4[12]; 
CZ9_4=beta_4[13];
/*D coefficients*/
DZ1_4=beta_4[14]; 
DZ2_4=beta_4[15]; 
DZ3_4=beta_4[16]; 
DZ4_4=beta_4[17]; 
DZ5_4=beta_4[18]; 
DZ6_4=beta_4[19]; 
DZ7_4=beta_4[20]; 
DZ8_4=beta_4[21]; 
DZ9_4=beta_4[22];
B_44=beta_4[23]; 
B_45=beta_4[24]; 
B_46=beta_4[25]; 
B_47=beta_4[26]; 
B_48=beta_4[27]; 
B_49=beta_4[28]; 
B_410=beta_4[29]; 
B_411=beta_4[30]; 
AZ1_44=beta_4[31]; 
AZ1_45=beta_4[32]; 
AZ1_46=beta_4[33]; 
AZ1_47=beta_4[34]; 
AZ1_48=beta_4[35]; 
AZ1_49=beta_4[36]; 
AZ1_410=beta_4[37]; 
AZ1_411=beta_4[38];
AZ2_44=beta_4[39]; 
AZ2_45=beta_4[40]; 
AZ2_46=beta_4[41]; 
AZ2_47=beta_4[42]; 
AZ2_48=beta_4[43]; 
AZ2_49=beta_4[44]; 
AZ2_410=beta_4[45]; 
AZ2_411=beta_4[46];
AZ3_44=beta_4[47]; 
AZ3_45=beta_4[48]; 
AZ3_46=beta_4[49]; 
AZ3_47=beta_4[50]; 
AZ3_48=beta_4[51]; 
AZ3_49=beta_4[52]; 
AZ3_410=beta_4[53]; 
AZ3_411=beta_4[54];
AZ4_44=beta_4[55]; 
AZ4_45=beta_4[56]; 
AZ4_46=beta_4[57]; 
AZ4_47=beta_4[58]; 
AZ4_48=beta_4[59]; 
AZ4_49=beta_4[60]; 
AZ4_410=beta_4[61]; 
AZ4_411=beta_4[62]; 
AZ5_44=beta_4[63]; 
AZ5_45=beta_4[64]; 
AZ5_46=beta_4[65]; 
AZ5_47=beta_4[66]; 
AZ5_48=beta_4[67]; 
AZ5_49=beta_4[68]; 
AZ5_410=beta_4[69]; 
AZ5_411=beta_4[70];
AZ6_44=beta_4[71]; 
AZ6_45=beta_4[72]; 
AZ6_46=beta_4[73]; 
AZ6_47=beta_4[74]; 
AZ6_48=beta_4[75]; 
AZ6_49=beta_4[76]; 
AZ6_410=beta_4[77]; 
AZ6_411=beta_4[78];
AZ7_44=beta_4[79]; 
AZ7_45=beta_4[80]; 
AZ7_46=beta_4[81]; 
AZ7_47=beta_4[82]; 
AZ7_48=beta_4[83]; 
AZ7_49=beta_4[84]; 
AZ7_410=beta_4[85]; 
AZ7_411=beta_4[86];
AZ8_44=beta_4[87]; 
AZ8_45=beta_4[88]; 
AZ8_46=beta_4[89]; 
AZ8_47=beta_4[90]; 
AZ8_48=beta_4[91]; 
AZ8_49=beta_4[92]; 
AZ8_410=beta_4[93]; 
AZ8_411=beta_4[94];
AZ9_44=beta_4[95]; 
AZ9_45=beta_4[96]; 
AZ9_46=beta_4[97]; 
AZ9_47=beta_4[98]; 
AZ9_48=beta_4[99]; 
AZ9_49=beta_4[100]; 
AZ9_410=beta_4[101]; 
AZ9_411=beta_4[102];
else;
b0_4=beta_4[1]; 
b1_4=beta_4[2]; 
b2_4=beta_4[3]; 
b3_4=beta_4[4];
CZ1_4=beta_4[5]; 
CZ2_4=beta_4[6]; 
CZ3_4=beta_4[7]; 
CZ4_4=beta_4[8]; 
CZ5_4=beta_4[9]; 
CZ6_4=beta_4[10]; 
CZ7_4=beta_4[11]; 
CZ8_4=beta_4[12]; 
CZ9_4=beta_4[13];
DZ1_4=beta_4[14]; 
DZ2_4=beta_4[15]; 
DZ3_4=beta_4[16]; 
DZ4_4=beta_4[17]; 
DZ5_4=beta_4[18]; 
DZ6_4=beta_4[19]; 
DZ7_4=beta_4[20]; 
DZ8_4=beta_4[21]; 
DZ9_4=beta_4[22];
B_41=beta_4[23]; 
B_42=beta_4[24]; 
B_43=beta_4[25]; 
B_44=beta_4[26]; 
B_45=beta_4[27]; 
B_46=beta_4[28]; 
B_47=beta_4[29]; 
B_48=beta_4[30]; 
B_49=beta_4[31]; 
B_410=beta_4[32]; 
B_411=beta_4[33];
AZ1_41=beta_4[34]; 
AZ1_42=beta_4[35]; 
AZ1_43=beta_4[36]; 
AZ1_44=beta_4[37]; 
AZ1_45=beta_4[38]; 
AZ1_46=beta_4[39]; 
AZ1_47=beta_4[40]; 
AZ1_48=beta_4[41]; 
AZ1_49=beta_4[42]; 
AZ1_410=beta_4[43]; 
AZ1_411=beta_4[44];
AZ2_41=beta_4[45]; 
AZ2_42=beta_4[46]; 
AZ2_43=beta_4[47]; 
AZ2_44=beta_4[48]; 
AZ2_45=beta_4[49]; 
AZ2_46=beta_4[50]; 
AZ2_47=beta_4[51]; 
AZ2_48=beta_4[52]; 
AZ2_49=beta_4[53]; 
AZ2_410=beta_4[54]; 
AZ2_411=beta_4[55];
AZ3_41=beta_4[56]; 
AZ3_42=beta_4[57]; 
AZ3_43=beta_4[58]; 
AZ3_44=beta_4[59]; 
AZ3_45=beta_4[60]; 
AZ3_46=beta_4[61]; 
AZ3_47=beta_4[62]; 
AZ3_48=beta_4[63]; 
AZ3_49=beta_4[64]; 
AZ3_410=beta_4[65]; 
AZ3_411=beta_4[66];
AZ4_41=beta_4[67]; 
AZ4_42=beta_4[68]; 
AZ4_43=beta_4[69]; 
AZ4_44=beta_4[70]; 
AZ4_45=beta_4[71]; 
AZ4_46=beta_4[72]; 
AZ4_47=beta_4[73]; 
AZ4_48=beta_4[74]; 
AZ4_49=beta_4[75]; 
AZ4_410=beta_4[76]; 
AZ4_411=beta_4[77];
AZ5_41=beta_4[78]; 
AZ5_42=beta_4[79]; 
AZ5_43=beta_4[80]; 
AZ5_44=beta_4[81]; 
AZ5_45=beta_4[82]; 
AZ5_46=beta_4[83]; 
AZ5_47=beta_4[84]; 
AZ5_48=beta_4[85]; 
AZ5_49=beta_4[86]; 
AZ5_410=beta_4[87]; 
AZ5_411=beta_4[88];
AZ6_41=beta_4[89]; 
AZ6_42=beta_4[90]; 
AZ6_43=beta_4[91]; 
AZ6_44=beta_4[92]; 
AZ6_45=beta_4[93]; 
AZ6_46=beta_4[94]; 
AZ6_47=beta_4[95]; 
AZ6_48=beta_4[96]; 
AZ6_49=beta_4[97]; 
AZ6_410=beta_4[98]; 
AZ6_411=beta_4[99];
AZ7_41=beta_4[100]; 
AZ7_42=beta_4[101]; 
AZ7_43=beta_4[102]; 
AZ7_44=beta_4[103]; 
AZ7_45=beta_4[104]; 
AZ7_46=beta_4[105]; 
AZ7_47=beta_4[106]; 
AZ7_48=beta_4[107]; 
AZ7_49=beta_4[108]; 
AZ7_410=beta_4[109]; 
AZ7_411=beta_4[110];
AZ8_41=beta_4[111]; 
AZ8_42=beta_4[112]; 
AZ8_43=beta_4[113]; 
AZ8_44=beta_4[114]; 
AZ8_45=beta_4[115]; 
AZ8_46=beta_4[116]; 
AZ8_47=beta_4[117]; 
AZ8_48=beta_4[118]; 
AZ8_49=beta_4[119]; 
AZ8_410=beta_4[120]; 
AZ8_411=beta_4[121];
AZ9_41=beta_4[122]; 
AZ9_42=beta_4[123]; 
AZ9_43=beta_4[124]; 
AZ9_44=beta_4[125]; 
AZ9_45=beta_4[126]; 
AZ9_46=beta_4[127]; 
AZ9_47=beta_4[128]; 
AZ9_48=beta_4[129]; 
AZ9_49=beta_4[130]; 
AZ9_410=beta_4[131]; 
AZ9_411=beta_4[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_5=q_5~q_6~q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_5=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_5=
q_vector_categ_5.*Z1~q_vector_categ_5.*Z2~q_vector_categ_5.*Z3~q_vector_categ_5.*Z4~q_vector_categ_5.*Z5
~q_vector_categ_5.*Z6~q_vector_categ_5.*Z7~q_vector_categ_5.*Z8~q_vector_categ_5.*Z9;
X_covars_categ_5=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_5~q_vector_Z_categ_5;
Instrum_categ_5=X_covars_categ_5;
if symmetry_imposed .eq 1;
Y_categ_5=
w_5
-q_1*B_15-(q_1.*Z_vars)*(AZ1_15|AZ2_15|AZ3_15|AZ4_15|AZ5_15|AZ6_15|AZ7_15|AZ8_15|AZ9_15)
-q_2*B_25-(q_2.*Z_vars)*(AZ1_25|AZ2_25|AZ3_25|AZ4_25|AZ5_25|AZ6_25|AZ7_25|AZ8_25|AZ9_25)
-q_3*B_35-(q_3.*Z_vars)*(AZ1_35|AZ2_35|AZ3_35|AZ4_35|AZ5_35|AZ6_35|AZ7_35|AZ8_35|AZ9_35)
-q_4*B_45-(q_4.*Z_vars)*(AZ1_45|AZ2_45|AZ3_45|AZ4_45|AZ5_45|AZ6_45|AZ7_45|AZ8_45|AZ9_45);
else;
Y_categ_5=w_5;
endif;	
beta_5=inv(Instrum_categ_5'*X_covars_categ_5)*Instrum_categ_5'*Y_categ_5;
epsilon_5=Y_categ_5-X_covars_categ_5*beta_5;
if symmetry_imposed .eq 1;
b0_5=beta_5[1]; 
b1_5=beta_5[2]; 
b2_5=beta_5[3]; 
b3_5=beta_5[4];
CZ1_5=beta_5[5]; 
CZ2_5=beta_5[6]; 
CZ3_5=beta_5[7]; 
CZ4_5=beta_5[8]; 
CZ5_5=beta_5[9]; 
CZ6_5=beta_5[10]; 
CZ7_5=beta_5[11]; 
CZ8_5=beta_5[12]; 
CZ9_5=beta_5[13];
DZ1_5=beta_5[14]; 
DZ2_5=beta_5[15]; 
DZ3_5=beta_5[16]; 
DZ4_5=beta_5[17]; 
DZ5_5=beta_5[18]; 
DZ6_5=beta_5[19]; 
DZ7_5=beta_5[20]; 
DZ8_5=beta_5[21]; 
DZ9_5=beta_5[22];
B_55=beta_5[23]; 
B_56=beta_5[24]; 
B_57=beta_5[25]; 
B_58=beta_5[26]; 
B_59=beta_5[27]; 
B_510=beta_5[28]; 
B_511=beta_5[29]; 
AZ1_55=beta_5[30]; 
AZ1_56=beta_5[31]; 
AZ1_57=beta_5[32]; 
AZ1_58=beta_5[33]; 
AZ1_59=beta_5[34]; 
AZ1_510=beta_5[35]; 
AZ1_511=beta_5[36];
AZ2_55=beta_5[37]; 
AZ2_56=beta_5[38]; 
AZ2_57=beta_5[39]; 
AZ2_58=beta_5[40]; 
AZ2_59=beta_5[41]; 
AZ2_510=beta_5[42]; 
AZ2_511=beta_5[43];
AZ3_55=beta_5[44]; 
AZ3_56=beta_5[45]; 
AZ3_57=beta_5[46]; 
AZ3_58=beta_5[47]; 
AZ3_59=beta_5[48]; 
AZ3_510=beta_5[49]; 
AZ3_511=beta_5[50];
AZ4_55=beta_5[51]; 
AZ4_56=beta_5[52]; 
AZ4_57=beta_5[53]; 
AZ4_58=beta_5[54]; 
AZ4_59=beta_5[55]; 
AZ4_510=beta_5[56]; 
AZ4_511=beta_5[57]; 
AZ5_55=beta_5[58]; 
AZ5_56=beta_5[59]; 
AZ5_57=beta_5[60]; 
AZ5_58=beta_5[61]; 
AZ5_59=beta_5[62]; 
AZ5_510=beta_5[63]; 
AZ5_511=beta_5[64];
AZ6_55=beta_5[65]; 
AZ6_56=beta_5[66]; 
AZ6_57=beta_5[67]; 
AZ6_58=beta_5[68]; 
AZ6_59=beta_5[69]; 
AZ6_510=beta_5[70]; 
AZ6_511=beta_5[71];
AZ7_55=beta_5[72]; 
AZ7_56=beta_5[73]; 
AZ7_57=beta_5[74]; 
AZ7_58=beta_5[75]; 
AZ7_59=beta_5[76]; 
AZ7_510=beta_5[77]; 
AZ7_511=beta_5[78];
AZ8_55=beta_5[79]; 
AZ8_56=beta_5[80]; 
AZ8_57=beta_5[81]; 
AZ8_58=beta_5[82]; 
AZ8_59=beta_5[83]; 
AZ8_510=beta_5[84]; 
AZ8_511=beta_5[85];
AZ9_55=beta_5[86]; 
AZ9_56=beta_5[87]; 
AZ9_57=beta_5[88]; 
AZ9_58=beta_5[89]; 
AZ9_59=beta_5[90]; 
AZ9_510=beta_5[91]; 
AZ9_511=beta_5[92];
else;
b0_5=beta_5[1]; 
b1_5=beta_5[2]; 
b2_5=beta_5[3]; 
b3_5=beta_5[4];
CZ1_5=beta_5[5]; 
CZ2_5=beta_5[6]; 
CZ3_5=beta_5[7]; 
CZ4_5=beta_5[8]; 
CZ5_5=beta_5[9]; 
CZ6_5=beta_5[10]; 
CZ7_5=beta_5[11]; 
CZ8_5=beta_5[12]; 
CZ9_5=beta_5[13];
DZ1_5=beta_5[14]; 
DZ2_5=beta_5[15]; 
DZ3_5=beta_5[16]; 
DZ4_5=beta_5[17]; 
DZ5_5=beta_5[18]; 
DZ6_5=beta_5[19]; 
DZ7_5=beta_5[20]; 
DZ8_5=beta_5[21]; 
DZ9_5=beta_5[22];
B_51=beta_5[23]; 
B_52=beta_5[24]; 
B_53=beta_5[25]; 
B_54=beta_5[26]; 
B_55=beta_5[27]; 
B_56=beta_5[28]; 
B_57=beta_5[29]; 
B_58=beta_5[30]; 
B_59=beta_5[31]; 
B_510=beta_5[32]; 
B_511=beta_5[33];
AZ1_51=beta_5[34]; 
AZ1_52=beta_5[35]; 
AZ1_53=beta_5[36]; 
AZ1_54=beta_5[37]; 
AZ1_55=beta_5[38]; 
AZ1_56=beta_5[39]; 
AZ1_57=beta_5[40]; 
AZ1_58=beta_5[41]; 
AZ1_59=beta_5[42]; 
AZ1_510=beta_5[43]; 
AZ1_511=beta_5[44];
AZ2_51=beta_5[45]; 
AZ2_52=beta_5[46]; 
AZ2_53=beta_5[47]; 
AZ2_54=beta_5[48]; 
AZ2_55=beta_5[49]; 
AZ2_56=beta_5[50]; 
AZ2_57=beta_5[51]; 
AZ2_58=beta_5[52]; 
AZ2_59=beta_5[53]; 
AZ2_510=beta_5[54]; 
AZ2_511=beta_5[55];
AZ3_51=beta_5[56]; 
AZ3_52=beta_5[57]; 
AZ3_53=beta_5[58]; 
AZ3_54=beta_5[59]; 
AZ3_55=beta_5[60]; 
AZ3_56=beta_5[61]; 
AZ3_57=beta_5[62]; 
AZ3_58=beta_5[63]; 
AZ3_59=beta_5[64]; 
AZ3_510=beta_5[65]; 
AZ3_511=beta_5[66];
AZ4_51=beta_5[67]; 
AZ4_52=beta_5[68]; 
AZ4_53=beta_5[69]; 
AZ4_54=beta_5[70]; 
AZ4_55=beta_5[71]; 
AZ4_56=beta_5[72]; 
AZ4_57=beta_5[73]; 
AZ4_58=beta_5[74]; 
AZ4_59=beta_5[75]; 
AZ4_510=beta_5[76]; 
AZ4_511=beta_5[77];
AZ5_51=beta_5[78]; 
AZ5_52=beta_5[79]; 
AZ5_53=beta_5[80]; 
AZ5_54=beta_5[81]; 
AZ5_55=beta_5[82]; 
AZ5_56=beta_5[83]; 
AZ5_57=beta_5[84]; 
AZ5_58=beta_5[85]; 
AZ5_59=beta_5[86]; 
AZ5_510=beta_5[87]; 
AZ5_511=beta_5[88];
AZ6_51=beta_5[89]; 
AZ6_52=beta_5[90]; 
AZ6_53=beta_5[91]; 
AZ6_54=beta_5[92]; 
AZ6_55=beta_5[93]; 
AZ6_56=beta_5[94]; 
AZ6_57=beta_5[95]; 
AZ6_58=beta_5[96]; 
AZ6_59=beta_5[97]; 
AZ6_510=beta_5[98]; 
AZ6_511=beta_5[99];
AZ7_51=beta_5[100]; 
AZ7_52=beta_5[101]; 
AZ7_53=beta_5[102]; 
AZ7_54=beta_5[103]; 
AZ7_55=beta_5[104]; 
AZ7_56=beta_5[105]; 
AZ7_57=beta_5[106]; 
AZ7_58=beta_5[107]; 
AZ7_59=beta_5[108]; 
AZ7_510=beta_5[109]; 
AZ7_511=beta_5[110];
AZ8_51=beta_5[111]; 
AZ8_52=beta_5[112]; 
AZ8_53=beta_5[113]; 
AZ8_54=beta_5[114]; 
AZ8_55=beta_5[115]; 
AZ8_56=beta_5[116]; 
AZ8_57=beta_5[117]; 
AZ8_58=beta_5[118]; 
AZ8_59=beta_5[119]; 
AZ8_510=beta_5[120]; 
AZ8_511=beta_5[121];
AZ9_51=beta_5[122]; 
AZ9_52=beta_5[123]; 
AZ9_53=beta_5[124]; 
AZ9_54=beta_5[125]; 
AZ9_55=beta_5[126]; 
AZ9_56=beta_5[127]; 
AZ9_57=beta_5[128]; 
AZ9_58=beta_5[129]; 
AZ9_59=beta_5[130]; 
AZ9_510=beta_5[131]; 
AZ9_511=beta_5[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_6=q_6~q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_6=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_6=
q_vector_categ_6.*Z1~q_vector_categ_6.*Z2~q_vector_categ_6.*Z3~q_vector_categ_6.*Z4~q_vector_categ_6.*Z5
~q_vector_categ_6.*Z6~q_vector_categ_6.*Z7~q_vector_categ_6.*Z8~q_vector_categ_6.*Z9;
X_covars_categ_6=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_6~q_vector_Z_categ_6;
Instrum_categ_6=X_covars_categ_6;
if symmetry_imposed .eq 1;
Y_categ_6=
w_6
-q_1*B_16-(q_1.*Z_vars)*(AZ1_16|AZ2_16|AZ3_16|AZ4_16|AZ5_16|AZ6_16|AZ7_16|AZ8_16|AZ9_16)
-q_2*B_26-(q_2.*Z_vars)*(AZ1_26|AZ2_26|AZ3_26|AZ4_26|AZ5_26|AZ6_26|AZ7_26|AZ8_26|AZ9_26)
-q_3*B_36-(q_3.*Z_vars)*(AZ1_36|AZ2_36|AZ3_36|AZ4_36|AZ5_36|AZ6_36|AZ7_36|AZ8_36|AZ9_36)
-q_4*B_46-(q_4.*Z_vars)*(AZ1_46|AZ2_46|AZ3_46|AZ4_46|AZ5_46|AZ6_46|AZ7_46|AZ8_46|AZ9_46)
-q_5*B_56-(q_5.*Z_vars)*(AZ1_56|AZ2_56|AZ3_56|AZ4_56|AZ5_56|AZ6_56|AZ7_56|AZ8_56|AZ9_56);
else;
Y_categ_6=w_6;
endif;
beta_6=inv(Instrum_categ_6'*X_covars_categ_6)*Instrum_categ_6'*Y_categ_6;
epsilon_6=Y_categ_6-X_covars_categ_6*beta_6;
if symmetry_imposed .eq 1;
b0_6=beta_6[1]; 
b1_6=beta_6[2]; 
b2_6=beta_6[3]; 
b3_6=beta_6[4];
CZ1_6=beta_6[5]; 
CZ2_6=beta_6[6]; 
CZ3_6=beta_6[7]; 
CZ4_6=beta_6[8]; 
CZ5_6=beta_6[9]; 
CZ6_6=beta_6[10]; 
CZ7_6=beta_6[11]; 
CZ8_6=beta_6[12]; 
CZ9_6=beta_6[13];
DZ1_6=beta_6[14]; 
DZ2_6=beta_6[15]; 
DZ3_6=beta_6[16]; 
DZ4_6=beta_6[17]; 
DZ5_6=beta_6[18]; 
DZ6_6=beta_6[19]; 
DZ7_6=beta_6[20]; 
DZ8_6=beta_6[21]; 
DZ9_6=beta_6[22];
B_66=beta_6[23]; 
B_67=beta_6[24]; 
B_68=beta_6[25]; 
B_69=beta_6[26]; 
B_610=beta_6[27]; 
B_611=beta_6[28]; 
AZ1_66=beta_6[29]; 
AZ1_67=beta_6[30]; 
AZ1_68=beta_6[31]; 
AZ1_69=beta_6[32]; 
AZ1_610=beta_6[33]; 
AZ1_611=beta_6[34];
AZ2_66=beta_6[35]; 
AZ2_67=beta_6[36]; 
AZ2_68=beta_6[37]; 
AZ2_69=beta_6[38]; 
AZ2_610=beta_6[39]; 
AZ2_611=beta_6[40];
AZ3_66=beta_6[41]; 
AZ3_67=beta_6[42]; 
AZ3_68=beta_6[43]; 
AZ3_69=beta_6[44]; 
AZ3_610=beta_6[45]; 
AZ3_611=beta_6[46];
AZ4_66=beta_6[47]; 
AZ4_67=beta_6[48]; 
AZ4_68=beta_6[49]; 
AZ4_69=beta_6[50]; 
AZ4_610=beta_6[51]; 
AZ4_611=beta_6[52]; 
AZ5_66=beta_6[53]; 
AZ5_67=beta_6[54]; 
AZ5_68=beta_6[55]; 
AZ5_69=beta_6[56]; 
AZ5_610=beta_6[57]; 
AZ5_611=beta_6[58];
AZ6_66=beta_6[59]; 
AZ6_67=beta_6[60]; 
AZ6_68=beta_6[61]; 
AZ6_69=beta_6[62]; 
AZ6_610=beta_6[63]; 
AZ6_611=beta_6[64];
AZ7_66=beta_6[65]; 
AZ7_67=beta_6[66]; 
AZ7_68=beta_6[67]; 
AZ7_69=beta_6[68]; 
AZ7_610=beta_6[69]; 
AZ7_611=beta_6[70];
AZ8_66=beta_6[71]; 
AZ8_67=beta_6[72]; 
AZ8_68=beta_6[73]; 
AZ8_69=beta_6[74]; 
AZ8_610=beta_6[75]; 
AZ8_611=beta_6[76];
AZ9_66=beta_6[77]; 
AZ9_67=beta_6[78]; 
AZ9_68=beta_6[79]; 
AZ9_69=beta_6[80]; 
AZ9_610=beta_6[81]; 
AZ9_611=beta_6[82];
else;
b0_6=beta_6[1]; 
b1_6=beta_6[2]; 
b2_6=beta_6[3]; 
b3_6=beta_6[4];
CZ1_6=beta_6[5]; 
CZ2_6=beta_6[6]; 
CZ3_6=beta_6[7]; 
CZ4_6=beta_6[8]; 
CZ5_6=beta_6[9]; 
CZ6_6=beta_6[10]; 
CZ7_6=beta_6[11]; 
CZ8_6=beta_6[12]; 
CZ9_6=beta_6[13];
DZ1_6=beta_6[14]; 
DZ2_6=beta_6[15]; 
DZ3_6=beta_6[16]; 
DZ4_6=beta_6[17]; 
DZ5_6=beta_6[18]; 
DZ6_6=beta_6[19]; 
DZ7_6=beta_6[20]; 
DZ8_6=beta_6[21]; 
DZ9_6=beta_6[22];
B_61=beta_6[23]; 
B_62=beta_6[24]; 
B_63=beta_6[25]; 
B_64=beta_6[26]; 
B_65=beta_6[27]; 
B_66=beta_6[28]; 
B_67=beta_6[29]; 
B_68=beta_6[30]; 
B_69=beta_6[31]; 
B_610=beta_6[32]; 
B_611=beta_6[33];
AZ1_61=beta_6[34]; 
AZ1_62=beta_6[35]; 
AZ1_63=beta_6[36]; 
AZ1_64=beta_6[37]; 
AZ1_65=beta_6[38]; 
AZ1_66=beta_6[39]; 
AZ1_67=beta_6[40]; 
AZ1_68=beta_6[41]; 
AZ1_69=beta_6[42]; 
AZ1_610=beta_6[43]; 
AZ1_611=beta_6[44];
AZ2_61=beta_6[45]; 
AZ2_62=beta_6[46]; 
AZ2_63=beta_6[47]; 
AZ2_64=beta_6[48]; 
AZ2_65=beta_6[49]; 
AZ2_66=beta_6[50]; 
AZ2_67=beta_6[51]; 
AZ2_68=beta_6[52]; 
AZ2_69=beta_6[53]; 
AZ2_610=beta_6[54]; 
AZ2_611=beta_6[55];
AZ3_61=beta_6[56]; 
AZ3_62=beta_6[57]; 
AZ3_63=beta_6[58]; 
AZ3_64=beta_6[59]; 
AZ3_65=beta_6[60]; 
AZ3_66=beta_6[61]; 
AZ3_67=beta_6[62]; 
AZ3_68=beta_6[63]; 
AZ3_69=beta_6[64]; 
AZ3_610=beta_6[65]; 
AZ3_611=beta_6[66];
AZ4_61=beta_6[67]; 
AZ4_62=beta_6[68]; 
AZ4_63=beta_6[69]; 
AZ4_64=beta_6[70]; 
AZ4_65=beta_6[71]; 
AZ4_66=beta_6[72]; 
AZ4_67=beta_6[73]; 
AZ4_68=beta_6[74]; 
AZ4_69=beta_6[75]; 
AZ4_610=beta_6[76]; 
AZ4_611=beta_6[77];
AZ5_61=beta_6[78]; 
AZ5_62=beta_6[79]; 
AZ5_63=beta_6[80]; 
AZ5_64=beta_6[81]; 
AZ5_65=beta_6[82]; 
AZ5_66=beta_6[83]; 
AZ5_67=beta_6[84]; 
AZ5_68=beta_6[85]; 
AZ5_69=beta_6[86]; 
AZ5_610=beta_6[87]; 
AZ5_611=beta_6[88];
AZ6_61=beta_6[89]; 
AZ6_62=beta_6[90]; 
AZ6_63=beta_6[91]; 
AZ6_64=beta_6[92]; 
AZ6_65=beta_6[93]; 
AZ6_66=beta_6[94]; 
AZ6_67=beta_6[95]; 
AZ6_68=beta_6[96]; 
AZ6_69=beta_6[97]; 
AZ6_610=beta_6[98]; 
AZ6_611=beta_6[99];
AZ7_61=beta_6[100]; 
AZ7_62=beta_6[101]; 
AZ7_63=beta_6[102]; 
AZ7_64=beta_6[103]; 
AZ7_65=beta_6[104]; 
AZ7_66=beta_6[105]; 
AZ7_67=beta_6[106]; 
AZ7_68=beta_6[107]; 
AZ7_69=beta_6[108]; 
AZ7_610=beta_6[109]; 
AZ7_611=beta_6[110];
AZ8_61=beta_6[111]; 
AZ8_62=beta_6[112]; 
AZ8_63=beta_6[113]; 
AZ8_64=beta_6[114]; 
AZ8_65=beta_6[115]; 
AZ8_66=beta_6[116]; 
AZ8_67=beta_6[117]; 
AZ8_68=beta_6[118]; 
AZ8_69=beta_6[119]; 
AZ8_610=beta_6[120]; 
AZ8_611=beta_6[121];
AZ9_61=beta_6[122]; 
AZ9_62=beta_6[123]; 
AZ9_63=beta_6[124]; 
AZ9_64=beta_6[125]; 
AZ9_65=beta_6[126]; 
AZ9_66=beta_6[127]; 
AZ9_67=beta_6[128]; 
AZ9_68=beta_6[129]; 
AZ9_69=beta_6[130]; 
AZ9_610=beta_6[131]; 
AZ9_611=beta_6[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_7=q_7~q_8~q_9~q_10~q_11;
else;
q_vector_categ_7=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;	
endif;
q_vector_Z_categ_7=
q_vector_categ_7.*Z1~q_vector_categ_7.*Z2~q_vector_categ_7.*Z3~q_vector_categ_7.*Z4~q_vector_categ_7.*Z5
~q_vector_categ_7.*Z6~q_vector_categ_7.*Z7~q_vector_categ_7.*Z8~q_vector_categ_7.*Z9;
X_covars_categ_7=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_7~q_vector_Z_categ_7;
Instrum_categ_7=X_covars_categ_7;
if symmetry_imposed .eq 1;
Y_categ_7=
w_7
-q_1*B_17-(q_1.*Z_vars)*(AZ1_17|AZ2_17|AZ3_17|AZ4_17|AZ5_17|AZ6_17|AZ7_17|AZ8_17|AZ9_17)
-q_2*B_27-(q_2.*Z_vars)*(AZ1_27|AZ2_27|AZ3_27|AZ4_27|AZ5_27|AZ6_27|AZ7_27|AZ8_27|AZ9_27)
-q_3*B_37-(q_3.*Z_vars)*(AZ1_37|AZ2_37|AZ3_37|AZ4_37|AZ5_37|AZ6_37|AZ7_37|AZ8_37|AZ9_37)
-q_4*B_47-(q_4.*Z_vars)*(AZ1_47|AZ2_47|AZ3_47|AZ4_47|AZ5_47|AZ6_47|AZ7_47|AZ8_47|AZ9_47)
-q_5*B_57-(q_5.*Z_vars)*(AZ1_57|AZ2_57|AZ3_57|AZ4_57|AZ5_57|AZ6_57|AZ7_57|AZ8_57|AZ9_57)
-q_6*B_67-(q_6.*Z_vars)*(AZ1_67|AZ2_67|AZ3_67|AZ4_67|AZ5_67|AZ6_67|AZ7_67|AZ8_67|AZ9_67);
else;
Y_categ_7=w_7;
endif;	
beta_7=inv(Instrum_categ_7'*X_covars_categ_7)*Instrum_categ_7'*Y_categ_7;
epsilon_7=Y_categ_7-X_covars_categ_7*beta_7;
if symmetry_imposed .eq 1;
b0_7=beta_7[1]; 
b1_7=beta_7[2]; 
b2_7=beta_7[3]; 
b3_7=beta_7[4];
CZ1_7=beta_7[5]; 
CZ2_7=beta_7[6]; 
CZ3_7=beta_7[7]; 
CZ4_7=beta_7[8]; 
CZ5_7=beta_7[9]; 
CZ6_7=beta_7[10]; 
CZ7_7=beta_7[11]; 
CZ8_7=beta_7[12]; 
CZ9_7=beta_7[13];
DZ1_7=beta_7[14]; 
DZ2_7=beta_7[15]; 
DZ3_7=beta_7[16]; 
DZ4_7=beta_7[17]; 
DZ5_7=beta_7[18]; 
DZ6_7=beta_7[19]; 
DZ7_7=beta_7[20]; 
DZ8_7=beta_7[21]; 
DZ9_7=beta_7[22];
B_77=beta_7[23]; 
B_78=beta_7[24]; 
B_79=beta_7[25]; 
B_710=beta_7[26]; 
B_711=beta_7[27]; 
AZ1_77=beta_7[28]; 
AZ1_78=beta_7[29]; 
AZ1_79=beta_7[30]; 
AZ1_710=beta_7[31]; 
AZ1_711=beta_7[32];
AZ2_77=beta_7[33]; 
AZ2_78=beta_7[34]; 
AZ2_79=beta_7[35]; 
AZ2_710=beta_7[36]; 
AZ2_711=beta_7[37];
AZ3_77=beta_7[38]; 
AZ3_78=beta_7[39]; 
AZ3_79=beta_7[40]; 
AZ3_710=beta_7[41]; 
AZ3_711=beta_7[42];
AZ4_77=beta_7[43]; 
AZ4_78=beta_7[44]; 
AZ4_79=beta_7[45]; 
AZ4_710=beta_7[46]; 
AZ4_711=beta_7[47]; 
AZ5_77=beta_7[48]; 
AZ5_78=beta_7[49]; 
AZ5_79=beta_7[50]; 
AZ5_710=beta_7[51]; 
AZ5_711=beta_7[52];
AZ6_77=beta_7[53]; 
AZ6_78=beta_7[54]; 
AZ6_79=beta_7[55]; 
AZ6_710=beta_7[56]; 
AZ6_711=beta_7[57];
AZ7_77=beta_7[58]; 
AZ7_78=beta_7[59]; 
AZ7_79=beta_7[60]; 
AZ7_710=beta_7[61]; 
AZ7_711=beta_7[62];
AZ8_77=beta_7[63]; 
AZ8_78=beta_7[64]; 
AZ8_79=beta_7[65]; 
AZ8_710=beta_7[66]; 
AZ8_711=beta_7[67];
AZ9_77=beta_7[68]; 
AZ9_78=beta_7[69]; 
AZ9_79=beta_7[70]; 
AZ9_710=beta_7[71]; 
AZ9_711=beta_7[72];
else;
b0_7=beta_7[1]; 
b1_7=beta_7[2]; 
b2_7=beta_7[3]; 
b3_7=beta_7[4];
CZ1_7=beta_7[5]; 
CZ2_7=beta_7[6]; 
CZ3_7=beta_7[7]; 
CZ4_7=beta_7[8]; 
CZ5_7=beta_7[9]; 
CZ6_7=beta_7[10]; 
CZ7_7=beta_7[11]; 
CZ8_7=beta_7[12]; 
CZ9_7=beta_7[13];
DZ1_7=beta_7[14]; 
DZ2_7=beta_7[15]; 
DZ3_7=beta_7[16]; 
DZ4_7=beta_7[17]; 
DZ5_7=beta_7[18]; 
DZ6_7=beta_7[19]; 
DZ7_7=beta_7[20]; 
DZ8_7=beta_7[21]; 
DZ9_7=beta_7[22];
B_71=beta_7[23]; 
B_72=beta_7[24]; 
B_73=beta_7[25]; 
B_74=beta_7[26]; 
B_75=beta_7[27]; 
B_76=beta_7[28]; 
B_77=beta_7[29]; 
B_78=beta_7[30]; 
B_79=beta_7[31]; 
B_710=beta_7[32]; 
B_711=beta_7[33];
AZ1_71=beta_7[34]; 
AZ1_72=beta_7[35]; 
AZ1_73=beta_7[36]; 
AZ1_74=beta_7[37]; 
AZ1_75=beta_7[38]; 
AZ1_76=beta_7[39]; 
AZ1_77=beta_7[40]; 
AZ1_78=beta_7[41]; 
AZ1_79=beta_7[42]; 
AZ1_710=beta_7[43]; 
AZ1_711=beta_7[44];
AZ2_71=beta_7[45]; 
AZ2_72=beta_7[46]; 
AZ2_73=beta_7[47]; 
AZ2_74=beta_7[48]; 
AZ2_75=beta_7[49]; 
AZ2_76=beta_7[50]; 
AZ2_77=beta_7[51]; 
AZ2_78=beta_7[52]; 
AZ2_79=beta_7[53]; 
AZ2_710=beta_7[54]; 
AZ2_711=beta_7[55];
AZ3_71=beta_7[56]; 
AZ3_72=beta_7[57]; 
AZ3_73=beta_7[58]; 
AZ3_74=beta_7[59]; 
AZ3_75=beta_7[60]; 
AZ3_76=beta_7[61]; 
AZ3_77=beta_7[62]; 
AZ3_78=beta_7[63]; 
AZ3_79=beta_7[64]; 
AZ3_710=beta_7[65]; 
AZ3_711=beta_7[66];
AZ4_71=beta_7[67]; 
AZ4_72=beta_7[68]; 
AZ4_73=beta_7[69]; 
AZ4_74=beta_7[70]; 
AZ4_75=beta_7[71]; 
AZ4_76=beta_7[72]; 
AZ4_77=beta_7[73]; 
AZ4_78=beta_7[74]; 
AZ4_79=beta_7[75]; 
AZ4_710=beta_7[76]; 
AZ4_711=beta_7[77];
AZ5_71=beta_7[78]; 
AZ5_72=beta_7[79]; 
AZ5_73=beta_7[80]; 
AZ5_74=beta_7[81]; 
AZ5_75=beta_7[82]; 
AZ5_76=beta_7[83]; 
AZ5_77=beta_7[84]; 
AZ5_78=beta_7[85]; 
AZ5_79=beta_7[86]; 
AZ5_710=beta_7[87]; 
AZ5_711=beta_7[88];
AZ6_71=beta_7[89]; 
AZ6_72=beta_7[90]; 
AZ6_73=beta_7[91]; 
AZ6_74=beta_7[92]; 
AZ6_75=beta_7[93]; 
AZ6_76=beta_7[94]; 
AZ6_77=beta_7[95]; 
AZ6_78=beta_7[96]; 
AZ6_79=beta_7[97]; 
AZ6_710=beta_7[98]; 
AZ6_711=beta_7[99];
AZ7_71=beta_7[100]; 
AZ7_72=beta_7[101]; 
AZ7_73=beta_7[102]; 
AZ7_74=beta_7[103]; 
AZ7_75=beta_7[104]; 
AZ7_76=beta_7[105]; 
AZ7_77=beta_7[106]; 
AZ7_78=beta_7[107]; 
AZ7_79=beta_7[108]; 
AZ7_710=beta_7[109]; 
AZ7_711=beta_7[110];
AZ8_71=beta_7[111]; 
AZ8_72=beta_7[112]; 
AZ8_73=beta_7[113]; 
AZ8_74=beta_7[114]; 
AZ8_75=beta_7[115]; 
AZ8_76=beta_7[116]; 
AZ8_77=beta_7[117]; 
AZ8_78=beta_7[118]; 
AZ8_79=beta_7[119]; 
AZ8_710=beta_7[120]; 
AZ8_711=beta_7[121];
AZ9_71=beta_7[122]; 
AZ9_72=beta_7[123]; 
AZ9_73=beta_7[124]; 
AZ9_74=beta_7[125]; 
AZ9_75=beta_7[126]; 
AZ9_76=beta_7[127]; 
AZ9_77=beta_7[128]; 
AZ9_78=beta_7[129]; 
AZ9_79=beta_7[130]; 
AZ9_710=beta_7[131]; 
AZ9_711=beta_7[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_8=q_8~q_9~q_10~q_11;
else;
q_vector_categ_8=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_8=
q_vector_categ_8.*Z1~q_vector_categ_8.*Z2~q_vector_categ_8.*Z3~q_vector_categ_8.*Z4~q_vector_categ_8.*Z5
~q_vector_categ_8.*Z6~q_vector_categ_8.*Z7~q_vector_categ_8.*Z8~q_vector_categ_8.*Z9;
X_covars_categ_8=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_8~q_vector_Z_categ_8;
Instrum_categ_8=X_covars_categ_8;
if symmetry_imposed .eq 1;
Y_categ_8=
w_8
-q_1*B_18-(q_1.*Z_vars)*(AZ1_18|AZ2_18|AZ3_18|AZ4_18|AZ5_18|AZ6_18|AZ7_18|AZ8_18|AZ9_18)
-q_2*B_28-(q_2.*Z_vars)*(AZ1_28|AZ2_28|AZ3_28|AZ4_28|AZ5_28|AZ6_28|AZ7_28|AZ8_28|AZ9_28)
-q_3*B_38-(q_3.*Z_vars)*(AZ1_38|AZ2_38|AZ3_38|AZ4_38|AZ5_38|AZ6_38|AZ7_38|AZ8_38|AZ9_38)
-q_4*B_48-(q_4.*Z_vars)*(AZ1_48|AZ2_48|AZ3_48|AZ4_48|AZ5_48|AZ6_48|AZ7_48|AZ8_48|AZ9_48)
-q_5*B_58-(q_5.*Z_vars)*(AZ1_58|AZ2_58|AZ3_58|AZ4_58|AZ5_58|AZ6_58|AZ7_58|AZ8_58|AZ9_58)
-q_6*B_68-(q_6.*Z_vars)*(AZ1_68|AZ2_68|AZ3_68|AZ4_68|AZ5_68|AZ6_68|AZ7_68|AZ8_68|AZ9_68)
-q_7*B_78-(q_7.*Z_vars)*(AZ1_78|AZ2_78|AZ3_78|AZ4_78|AZ5_78|AZ6_78|AZ7_78|AZ8_78|AZ9_78);
else;
Y_categ_8=w_8;
endif;	
beta_8=inv(Instrum_categ_8'*X_covars_categ_8)*Instrum_categ_8'*Y_categ_8;
epsilon_8=Y_categ_8-X_covars_categ_8*beta_8;
if symmetry_imposed .eq 1;
b0_8=beta_8[1]; 
b1_8=beta_8[2]; 
b2_8=beta_8[3]; 
b3_8=beta_8[4];
CZ1_8=beta_8[5]; 
CZ2_8=beta_8[6]; 
CZ3_8=beta_8[7]; 
CZ4_8=beta_8[8]; 
CZ5_8=beta_8[9]; 
CZ6_8=beta_8[10]; 
CZ7_8=beta_8[11]; 
CZ8_8=beta_8[12]; 
CZ9_8=beta_8[13];
DZ1_8=beta_8[14]; 
DZ2_8=beta_8[15]; 
DZ3_8=beta_8[16]; 
DZ4_8=beta_8[17]; 
DZ5_8=beta_8[18]; 
DZ6_8=beta_8[19]; 
DZ7_8=beta_8[20]; 
DZ8_8=beta_8[21]; 
DZ9_8=beta_8[22];
B_88=beta_8[23]; 
B_89=beta_8[24]; 
B_810=beta_8[25]; 
B_811=beta_8[26]; 
AZ1_88=beta_8[27]; 
AZ1_89=beta_8[28]; 
AZ1_810=beta_8[29]; 
AZ1_811=beta_8[30];
AZ2_88=beta_8[31]; 
AZ2_89=beta_8[32]; 
AZ2_810=beta_8[33]; 
AZ2_811=beta_8[34];
AZ3_88=beta_8[35]; 
AZ3_89=beta_8[36]; 
AZ3_810=beta_8[37]; 
AZ3_811=beta_8[38];
AZ4_88=beta_8[39]; 
AZ4_89=beta_8[40]; 
AZ4_810=beta_8[41]; 
AZ4_811=beta_8[42]; 
AZ5_88=beta_8[43]; 
AZ5_89=beta_8[44]; 
AZ5_810=beta_8[45]; 
AZ5_811=beta_8[46];
AZ6_88=beta_8[47]; 
AZ6_89=beta_8[48]; 
AZ6_810=beta_8[49]; 
AZ6_811=beta_8[50];
AZ7_88=beta_8[51]; 
AZ7_89=beta_8[52]; 
AZ7_810=beta_8[53]; 
AZ7_811=beta_8[54];
AZ8_88=beta_8[55]; 
AZ8_89=beta_8[56]; 
AZ8_810=beta_8[57]; 
AZ8_811=beta_8[58];
AZ9_88=beta_8[59]; 
AZ9_89=beta_8[60]; 
AZ9_810=beta_8[61]; 
AZ9_811=beta_8[62];
else;
b0_8=beta_8[1]; 
b1_8=beta_8[2]; 
b2_8=beta_8[3]; 
b3_8=beta_8[4];
CZ1_8=beta_8[5]; 
CZ2_8=beta_8[6]; 
CZ3_8=beta_8[7]; 
CZ4_8=beta_8[8]; 
CZ5_8=beta_8[9]; 
CZ6_8=beta_8[10]; 
CZ7_8=beta_8[11]; 
CZ8_8=beta_8[12]; 
CZ9_8=beta_8[13];
DZ1_8=beta_8[14]; 
DZ2_8=beta_8[15]; 
DZ3_8=beta_8[16]; 
DZ4_8=beta_8[17]; 
DZ5_8=beta_8[18]; 
DZ6_8=beta_8[19]; 
DZ7_8=beta_8[20]; 
DZ8_8=beta_8[21]; 
DZ9_8=beta_8[22];
B_81=beta_8[23]; 
B_82=beta_8[24]; 
B_83=beta_8[25]; 
B_84=beta_8[26]; 
B_85=beta_8[27]; 
B_86=beta_8[28]; 
B_87=beta_8[29]; 
B_88=beta_8[30]; 
B_89=beta_8[31]; 
B_810=beta_8[32]; 
B_811=beta_8[33];
AZ1_81=beta_8[34]; 
AZ1_82=beta_8[35]; 
AZ1_83=beta_8[36]; 
AZ1_84=beta_8[37]; 
AZ1_85=beta_8[38]; 
AZ1_86=beta_8[39]; 
AZ1_87=beta_8[40]; 
AZ1_88=beta_8[41]; 
AZ1_89=beta_8[42]; 
AZ1_810=beta_8[43]; 
AZ1_811=beta_8[44];
AZ2_81=beta_8[45]; 
AZ2_82=beta_8[46]; 
AZ2_83=beta_8[47]; 
AZ2_84=beta_8[48]; 
AZ2_85=beta_8[49]; 
AZ2_86=beta_8[50]; 
AZ2_87=beta_8[51]; 
AZ2_88=beta_8[52]; 
AZ2_89=beta_8[53]; 
AZ2_810=beta_8[54]; 
AZ2_811=beta_8[55];
AZ3_81=beta_8[56]; 
AZ3_82=beta_8[57]; 
AZ3_83=beta_8[58]; 
AZ3_84=beta_8[59]; 
AZ3_85=beta_8[60]; 
AZ3_86=beta_8[61]; 
AZ3_87=beta_8[62]; 
AZ3_88=beta_8[63]; 
AZ3_89=beta_8[64]; 
AZ3_810=beta_8[65]; 
AZ3_811=beta_8[66];
AZ4_81=beta_8[67]; 
AZ4_82=beta_8[68]; 
AZ4_83=beta_8[69]; 
AZ4_84=beta_8[70]; 
AZ4_85=beta_8[71]; 
AZ4_86=beta_8[72]; 
AZ4_87=beta_8[73]; 
AZ4_88=beta_8[74]; 
AZ4_89=beta_8[75]; 
AZ4_810=beta_8[76]; 
AZ4_811=beta_8[77];
AZ5_81=beta_8[78]; 
AZ5_82=beta_8[79]; 
AZ5_83=beta_8[80]; 
AZ5_84=beta_8[81]; 
AZ5_85=beta_8[82]; 
AZ5_86=beta_8[83]; 
AZ5_87=beta_8[84]; 
AZ5_88=beta_8[85]; 
AZ5_89=beta_8[86]; 
AZ5_810=beta_8[87]; 
AZ5_811=beta_8[88];
AZ6_81=beta_8[89]; 
AZ6_82=beta_8[90]; 
AZ6_83=beta_8[91]; 
AZ6_84=beta_8[92]; 
AZ6_85=beta_8[93]; 
AZ6_86=beta_8[94]; 
AZ6_87=beta_8[95]; 
AZ6_88=beta_8[96]; 
AZ6_89=beta_8[97]; 
AZ6_810=beta_8[98]; 
AZ6_811=beta_8[99];
AZ7_81=beta_8[100]; 
AZ7_82=beta_8[101]; 
AZ7_83=beta_8[102]; 
AZ7_84=beta_8[103]; 
AZ7_85=beta_8[104]; 
AZ7_86=beta_8[105]; 
AZ7_87=beta_8[106]; 
AZ7_88=beta_8[107]; 
AZ7_89=beta_8[108]; 
AZ7_810=beta_8[109]; 
AZ7_811=beta_8[110];
AZ8_81=beta_8[111]; 
AZ8_82=beta_8[112]; 
AZ8_83=beta_8[113]; 
AZ8_84=beta_8[114]; 
AZ8_85=beta_8[115]; 
AZ8_86=beta_8[116]; 
AZ8_87=beta_8[117]; 
AZ8_88=beta_8[118]; 
AZ8_89=beta_8[119]; 
AZ8_810=beta_8[120]; 
AZ8_811=beta_8[121];
AZ9_81=beta_8[122]; 
AZ9_82=beta_8[123]; 
AZ9_83=beta_8[124]; 
AZ9_84=beta_8[125]; 
AZ9_85=beta_8[126]; 
AZ9_86=beta_8[127]; 
AZ9_87=beta_8[128]; 
AZ9_88=beta_8[129]; 
AZ9_89=beta_8[130]; 
AZ9_810=beta_8[131]; 
AZ9_811=beta_8[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_9=q_9~q_10~q_11;
else;
q_vector_categ_9=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;
endif;	
q_vector_Z_categ_9=
q_vector_categ_9.*Z1~q_vector_categ_9.*Z2~q_vector_categ_9.*Z3~q_vector_categ_9.*Z4~q_vector_categ_9.*Z5
~q_vector_categ_9.*Z6~q_vector_categ_9.*Z7~q_vector_categ_9.*Z8~q_vector_categ_9.*Z9;
X_covars_categ_9=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_9~q_vector_Z_categ_9;
Instrum_categ_9=X_covars_categ_9;
if symmetry_imposed .eq 1;
Y_categ_9=
w_9
-q_1*B_19-(q_1.*Z_vars)*(AZ1_19|AZ2_19|AZ3_19|AZ4_19|AZ5_19|AZ6_19|AZ7_19|AZ8_19|AZ9_19)
-q_2*B_29-(q_2.*Z_vars)*(AZ1_29|AZ2_29|AZ3_29|AZ4_29|AZ5_29|AZ6_29|AZ7_29|AZ8_29|AZ9_29)
-q_3*B_39-(q_3.*Z_vars)*(AZ1_39|AZ2_39|AZ3_39|AZ4_39|AZ5_39|AZ6_39|AZ7_39|AZ8_39|AZ9_39)
-q_4*B_49-(q_4.*Z_vars)*(AZ1_49|AZ2_49|AZ3_49|AZ4_49|AZ5_49|AZ6_49|AZ7_49|AZ8_49|AZ9_49)
-q_5*B_59-(q_5.*Z_vars)*(AZ1_59|AZ2_59|AZ3_59|AZ4_59|AZ5_59|AZ6_59|AZ7_59|AZ8_59|AZ9_59)
-q_6*B_69-(q_6.*Z_vars)*(AZ1_69|AZ2_69|AZ3_69|AZ4_69|AZ5_69|AZ6_69|AZ7_69|AZ8_69|AZ9_69)
-q_7*B_79-(q_7.*Z_vars)*(AZ1_79|AZ2_79|AZ3_79|AZ4_79|AZ5_79|AZ6_79|AZ7_79|AZ8_79|AZ9_79)
-q_8*B_89-(q_8.*Z_vars)*(AZ1_89|AZ2_89|AZ3_89|AZ4_89|AZ5_89|AZ6_89|AZ7_89|AZ8_89|AZ9_89);
else;
Y_categ_9=w_9;
endif;		
beta_9=inv(Instrum_categ_9'*X_covars_categ_9)*Instrum_categ_9'*Y_categ_9;
epsilon_9=Y_categ_9-X_covars_categ_9*beta_9;
if symmetry_imposed .eq 1;
b0_9=beta_9[1]; 
b1_9=beta_9[2]; 
b2_9=beta_9[3]; 
b3_9=beta_9[4];
CZ1_9=beta_9[5]; 
CZ2_9=beta_9[6]; 
CZ3_9=beta_9[7]; 
CZ4_9=beta_9[8]; 
CZ5_9=beta_9[9]; 
CZ6_9=beta_9[10]; 
CZ7_9=beta_9[11]; 
CZ8_9=beta_9[12]; 
CZ9_9=beta_9[13];
DZ1_9=beta_9[14]; 
DZ2_9=beta_9[15]; 
DZ3_9=beta_9[16]; 
DZ4_9=beta_9[17]; 
DZ5_9=beta_9[18]; 
DZ6_9=beta_9[19]; 
DZ7_9=beta_9[20]; 
DZ8_9=beta_9[21]; 
DZ9_9=beta_9[22];
B_99=beta_9[23]; 
B_910=beta_9[24]; 
B_911=beta_9[25]; 
AZ1_99=beta_9[26]; 
AZ1_910=beta_9[27]; 
AZ1_911=beta_9[28];
AZ2_99=beta_9[29]; 
AZ2_910=beta_9[30]; 
AZ2_911=beta_9[31];
AZ3_99=beta_9[32]; 
AZ3_910=beta_9[33]; 
AZ3_911=beta_9[34];
AZ4_99=beta_9[35]; 
AZ4_910=beta_9[36]; 
AZ4_911=beta_9[37]; 
AZ5_99=beta_9[38]; 
AZ5_910=beta_9[39]; 
AZ5_911=beta_9[40];
AZ6_99=beta_9[41]; 
AZ6_910=beta_9[42]; 
AZ6_911=beta_9[43];
AZ7_99=beta_9[44]; 
AZ7_910=beta_9[45]; 
AZ7_911=beta_9[46];
AZ8_99=beta_9[47]; 
AZ8_910=beta_9[48]; 
AZ8_911=beta_9[49];
AZ9_99=beta_9[50]; 
AZ9_910=beta_9[51]; 
AZ9_911=beta_9[52];
else;
b0_9=beta_9[1]; 
b1_9=beta_9[2]; 
b2_9=beta_9[3]; 
b3_9=beta_9[4];
CZ1_9=beta_9[5]; 
CZ2_9=beta_9[6]; 
CZ3_9=beta_9[7]; 
CZ4_9=beta_9[8]; 
CZ5_9=beta_9[9]; 
CZ6_9=beta_9[10]; 
CZ7_9=beta_9[11]; 
CZ8_9=beta_9[12]; 
CZ9_9=beta_9[13];
DZ1_9=beta_9[14]; 
DZ2_9=beta_9[15]; 
DZ3_9=beta_9[16]; 
DZ4_9=beta_9[17]; 
DZ5_9=beta_9[18]; 
DZ6_9=beta_9[19]; 
DZ7_9=beta_9[20]; 
DZ8_9=beta_9[21]; 
DZ9_9=beta_9[22];
B_91=beta_9[23]; 
B_92=beta_9[24]; 
B_93=beta_9[25]; 
B_94=beta_9[26]; 
B_95=beta_9[27]; 
B_96=beta_9[28]; 
B_97=beta_9[29]; 
B_98=beta_9[30]; 
B_99=beta_9[31]; 
B_910=beta_9[32]; 
B_911=beta_9[33];
AZ1_91=beta_9[34]; 
AZ1_92=beta_9[35]; 
AZ1_93=beta_9[36]; 
AZ1_94=beta_9[37]; 
AZ1_95=beta_9[38]; 
AZ1_96=beta_9[39]; 
AZ1_97=beta_9[40]; 
AZ1_98=beta_9[41]; 
AZ1_99=beta_9[42]; 
AZ1_910=beta_9[43]; 
AZ1_911=beta_9[44];
AZ2_91=beta_9[45]; 
AZ2_92=beta_9[46]; 
AZ2_93=beta_9[47]; 
AZ2_94=beta_9[48]; 
AZ2_95=beta_9[49]; 
AZ2_96=beta_9[50]; 
AZ2_97=beta_9[51]; 
AZ2_98=beta_9[52]; 
AZ2_99=beta_9[53]; 
AZ2_910=beta_9[54]; 
AZ2_911=beta_9[55];
AZ3_91=beta_9[56]; 
AZ3_92=beta_9[57]; 
AZ3_93=beta_9[58]; 
AZ3_94=beta_9[59]; 
AZ3_95=beta_9[60]; 
AZ3_96=beta_9[61]; 
AZ3_97=beta_9[62]; 
AZ3_98=beta_9[63]; 
AZ3_99=beta_9[64]; 
AZ3_910=beta_9[65]; 
AZ3_911=beta_9[66];
AZ4_91=beta_9[67]; 
AZ4_92=beta_9[68]; 
AZ4_93=beta_9[69]; 
AZ4_94=beta_9[70]; 
AZ4_95=beta_9[71]; 
AZ4_96=beta_9[72]; 
AZ4_97=beta_9[73]; 
AZ4_98=beta_9[74]; 
AZ4_99=beta_9[75]; 
AZ4_910=beta_9[76]; 
AZ4_911=beta_9[77];
AZ5_91=beta_9[78]; 
AZ5_92=beta_9[79]; 
AZ5_93=beta_9[80]; 
AZ5_94=beta_9[81]; 
AZ5_95=beta_9[82]; 
AZ5_96=beta_9[83]; 
AZ5_97=beta_9[84]; 
AZ5_98=beta_9[85]; 
AZ5_99=beta_9[86]; 
AZ5_910=beta_9[87]; 
AZ5_911=beta_9[88];
AZ6_91=beta_9[89]; 
AZ6_92=beta_9[90]; 
AZ6_93=beta_9[91]; 
AZ6_94=beta_9[92]; 
AZ6_95=beta_9[93]; 
AZ6_96=beta_9[94]; 
AZ6_97=beta_9[95]; 
AZ6_98=beta_9[96]; 
AZ6_99=beta_9[97]; 
AZ6_910=beta_9[98]; 
AZ6_911=beta_9[99];
AZ7_91=beta_9[100]; 
AZ7_92=beta_9[101]; 
AZ7_93=beta_9[102]; 
AZ7_94=beta_9[103]; 
AZ7_95=beta_9[104]; 
AZ7_96=beta_9[105]; 
AZ7_97=beta_9[106]; 
AZ7_98=beta_9[107]; 
AZ7_99=beta_9[108]; 
AZ7_910=beta_9[109]; 
AZ7_911=beta_9[110];
AZ8_91=beta_9[111]; 
AZ8_92=beta_9[112]; 
AZ8_93=beta_9[113]; 
AZ8_94=beta_9[114]; 
AZ8_95=beta_9[115]; 
AZ8_96=beta_9[116]; 
AZ8_97=beta_9[117]; 
AZ8_98=beta_9[118]; 
AZ8_99=beta_9[119]; 
AZ8_910=beta_9[120]; 
AZ8_911=beta_9[121];
AZ9_91=beta_9[122]; 
AZ9_92=beta_9[123]; 
AZ9_93=beta_9[124]; 
AZ9_94=beta_9[125]; 
AZ9_95=beta_9[126]; 
AZ9_96=beta_9[127]; 
AZ9_97=beta_9[128]; 
AZ9_98=beta_9[129]; 
AZ9_99=beta_9[130]; 
AZ9_910=beta_9[131]; 
AZ9_911=beta_9[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_10=q_10~q_11;
else;
q_vector_categ_10=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;	
endif;
q_vector_Z_categ_10=
q_vector_categ_10.*Z1~q_vector_categ_10.*Z2~q_vector_categ_10.*Z3~q_vector_categ_10.*Z4~q_vector_categ_10.*Z5
~q_vector_categ_10.*Z6~q_vector_categ_10.*Z7~q_vector_categ_10.*Z8~q_vector_categ_10.*Z9;
X_covars_categ_10=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_10~q_vector_Z_categ_10;
Instrum_categ_10=X_covars_categ_10;
if symmetry_imposed .eq 1;
Y_categ_10=
w_10
-q_1*B_110-(q_1.*Z_vars)*(AZ1_110|AZ2_110|AZ3_110|AZ4_110|AZ5_110|AZ6_110|AZ7_110|AZ8_110|AZ9_110)
-q_2*B_210-(q_2.*Z_vars)*(AZ1_210|AZ2_210|AZ3_210|AZ4_210|AZ5_210|AZ6_210|AZ7_210|AZ8_210|AZ9_210)
-q_3*B_310-(q_3.*Z_vars)*(AZ1_310|AZ2_310|AZ3_310|AZ4_310|AZ5_310|AZ6_310|AZ7_310|AZ8_310|AZ9_310)
-q_4*B_410-(q_4.*Z_vars)*(AZ1_410|AZ2_410|AZ3_410|AZ4_410|AZ5_410|AZ6_410|AZ7_410|AZ8_410|AZ9_410)
-q_5*B_510-(q_5.*Z_vars)*(AZ1_510|AZ2_510|AZ3_510|AZ4_510|AZ5_510|AZ6_510|AZ7_510|AZ8_510|AZ9_510)
-q_6*B_610-(q_6.*Z_vars)*(AZ1_610|AZ2_610|AZ3_610|AZ4_610|AZ5_610|AZ6_610|AZ7_610|AZ8_610|AZ9_610)
-q_7*B_710-(q_7.*Z_vars)*(AZ1_710|AZ2_710|AZ3_710|AZ4_710|AZ5_710|AZ6_710|AZ7_710|AZ8_710|AZ9_710)
-q_8*B_810-(q_8.*Z_vars)*(AZ1_810|AZ2_810|AZ3_810|AZ4_810|AZ5_810|AZ6_810|AZ7_810|AZ8_810|AZ9_810)
-q_9*B_910-(q_9.*Z_vars)*(AZ1_910|AZ2_910|AZ3_910|AZ4_910|AZ5_910|AZ6_910|AZ7_910|AZ8_910|AZ9_910);
else;
Y_categ_10=w_10;
endif;	
beta_10=inv(Instrum_categ_10'*X_covars_categ_10)*Instrum_categ_10'*Y_categ_10;
epsilon_10=Y_categ_10-X_covars_categ_10*beta_10;
if symmetry_imposed .eq 1;
b0_10=beta_10[1]; 
b1_10=beta_10[2]; 
b2_10=beta_10[3]; 
b3_10=beta_10[4];
CZ1_10=beta_10[5]; 
CZ2_10=beta_10[6]; 
CZ3_10=beta_10[7]; 
CZ4_10=beta_10[8]; 
CZ5_10=beta_10[9]; 
CZ6_10=beta_10[10]; 
CZ7_10=beta_10[11]; 
CZ8_10=beta_10[12]; 
CZ9_10=beta_10[13];
DZ1_10=beta_10[14]; 
DZ2_10=beta_10[15]; 
DZ3_10=beta_10[16]; 
DZ4_10=beta_10[17]; 
DZ5_10=beta_10[18]; 
DZ6_10=beta_10[19]; 
DZ7_10=beta_10[20]; 
DZ8_10=beta_10[21]; 
DZ9_10=beta_10[22];
B_1010=beta_10[23]; 
B_1011=beta_10[24]; 
AZ1_1010=beta_10[25]; 
AZ1_1011=beta_10[26];
AZ2_1010=beta_10[27]; 
AZ2_1011=beta_10[28];
AZ3_1010=beta_10[29]; 
AZ3_1011=beta_10[30];
AZ4_1010=beta_10[31]; 
AZ4_1011=beta_10[32]; 
AZ5_1010=beta_10[33]; 
AZ5_1011=beta_10[34];
AZ6_1010=beta_10[35]; 
AZ6_1011=beta_10[36];
AZ7_1010=beta_10[37]; 
AZ7_1011=beta_10[38];
AZ8_1010=beta_10[39]; 
AZ8_1011=beta_10[40];
AZ9_1010=beta_10[41]; 
AZ9_1011=beta_10[42];
else;
b0_10=beta_10[1]; 
b1_10=beta_10[2]; 
b2_10=beta_10[3]; 
b3_10=beta_10[4];
CZ1_10=beta_10[5]; 
CZ2_10=beta_10[6]; 
CZ3_10=beta_10[7]; 
CZ4_10=beta_10[8]; 
CZ5_10=beta_10[9]; 
CZ6_10=beta_10[10]; 
CZ7_10=beta_10[11]; 
CZ8_10=beta_10[12]; 
CZ9_10=beta_10[13];
DZ1_10=beta_10[14]; 
DZ2_10=beta_10[15]; 
DZ3_10=beta_10[16]; 
DZ4_10=beta_10[17]; 
DZ5_10=beta_10[18]; 
DZ6_10=beta_10[19]; 
DZ7_10=beta_10[20]; 
DZ8_10=beta_10[21]; 
DZ9_10=beta_10[22];
B_101=beta_10[23]; 
B_102=beta_10[24]; 
B_103=beta_10[25]; 
B_104=beta_10[26]; 
B_105=beta_10[27]; 
B_106=beta_10[28]; 
B_107=beta_10[29]; 
B_108=beta_10[30]; 
B_109=beta_10[31]; 
B_1010=beta_10[32]; 
B_1011=beta_10[33];
AZ1_101=beta_10[34]; 
AZ1_102=beta_10[35]; 
AZ1_103=beta_10[36]; 
AZ1_104=beta_10[37]; 
AZ1_105=beta_10[38]; 
AZ1_106=beta_10[39]; 
AZ1_107=beta_10[40]; 
AZ1_108=beta_10[41]; 
AZ1_109=beta_10[42]; 
AZ1_1010=beta_10[43]; 
AZ1_1011=beta_10[44];
AZ2_101=beta_10[45]; 
AZ2_102=beta_10[46]; 
AZ2_103=beta_10[47]; 
AZ2_104=beta_10[48]; 
AZ2_105=beta_10[49]; 
AZ2_106=beta_10[50]; 
AZ2_107=beta_10[51]; 
AZ2_108=beta_10[52]; 
AZ2_109=beta_10[53]; 
AZ2_1010=beta_10[54]; 
AZ2_1011=beta_10[55];
AZ3_101=beta_10[56]; 
AZ3_102=beta_10[57]; 
AZ3_103=beta_10[58]; 
AZ3_104=beta_10[59]; 
AZ3_105=beta_10[60]; 
AZ3_106=beta_10[61]; 
AZ3_107=beta_10[62]; 
AZ3_108=beta_10[63]; 
AZ3_109=beta_10[64]; 
AZ3_1010=beta_10[65]; 
AZ3_1011=beta_10[66];
AZ4_101=beta_10[67]; 
AZ4_102=beta_10[68]; 
AZ4_103=beta_10[69]; 
AZ4_104=beta_10[70]; 
AZ4_105=beta_10[71]; 
AZ4_106=beta_10[72]; 
AZ4_107=beta_10[73]; 
AZ4_108=beta_10[74]; 
AZ4_109=beta_10[75]; 
AZ4_1010=beta_10[76]; 
AZ4_1011=beta_10[77];
AZ5_101=beta_10[78]; 
AZ5_102=beta_10[79]; 
AZ5_103=beta_10[80]; 
AZ5_104=beta_10[81]; 
AZ5_105=beta_10[82]; 
AZ5_106=beta_10[83]; 
AZ5_107=beta_10[84]; 
AZ5_108=beta_10[85]; 
AZ5_109=beta_10[86]; 
AZ5_1010=beta_10[87]; 
AZ5_1011=beta_10[88];
AZ6_101=beta_10[89]; 
AZ6_102=beta_10[90]; 
AZ6_103=beta_10[91]; 
AZ6_104=beta_10[92]; 
AZ6_105=beta_10[93]; 
AZ6_106=beta_10[94]; 
AZ6_107=beta_10[95]; 
AZ6_108=beta_10[96]; 
AZ6_109=beta_10[97]; 
AZ6_1010=beta_10[98]; 
AZ6_1011=beta_10[99];
AZ7_101=beta_10[100]; 
AZ7_102=beta_10[101]; 
AZ7_103=beta_10[102]; 
AZ7_104=beta_10[103]; 
AZ7_105=beta_10[104]; 
AZ7_106=beta_10[105]; 
AZ7_107=beta_10[106]; 
AZ7_108=beta_10[107]; 
AZ7_109=beta_10[108]; 
AZ7_1010=beta_10[109]; 
AZ7_1011=beta_10[110];
AZ8_101=beta_10[111]; 
AZ8_102=beta_10[112]; 
AZ8_103=beta_10[113]; 
AZ8_104=beta_10[114]; 
AZ8_105=beta_10[115]; 
AZ8_106=beta_10[116]; 
AZ8_107=beta_10[117]; 
AZ8_108=beta_10[118]; 
AZ8_109=beta_10[119]; 
AZ8_1010=beta_10[120]; 
AZ8_1011=beta_10[121];
AZ9_101=beta_10[122]; 
AZ9_102=beta_10[123]; 
AZ9_103=beta_10[124]; 
AZ9_104=beta_10[125]; 
AZ9_105=beta_10[126]; 
AZ9_106=beta_10[127]; 
AZ9_107=beta_10[128]; 
AZ9_108=beta_10[129]; 
AZ9_109=beta_10[130]; 
AZ9_1010=beta_10[131]; 
AZ9_1011=beta_10[132];
endif;	
if symmetry_imposed .eq 1;
q_vector_categ_11=q_11;
else;
q_vector_categ_11=q_1~q_2~q_3~q_4~q_5~q_6~q_7~q_8~q_9~q_10~q_11;	
endif;
q_vector_Z_categ_11=
q_vector_categ_11.*Z1~q_vector_categ_11.*Z2~q_vector_categ_11.*Z3~q_vector_categ_11.*Z4~q_vector_categ_11.*Z5
~q_vector_categ_11.*Z6~q_vector_categ_11.*Z7~q_vector_categ_11.*Z8~q_vector_categ_11.*Z9;
X_covars_categ_11=ones(num_hogares,1)~util~util^2~util^3~Z_vars~Z_vars.*util~q_vector_categ_11~q_vector_Z_categ_11;
Instrum_categ_11=X_covars_categ_11;
if symmetry_imposed .eq 1;
Y_categ_11=
w_11
-q_1*B_111-(q_1.*Z_vars)*(AZ1_111|AZ2_111|AZ3_111|AZ4_111|AZ5_111|AZ6_111|AZ7_111|AZ8_111|AZ9_111)
-q_2*B_211-(q_2.*Z_vars)*(AZ1_211|AZ2_211|AZ3_211|AZ4_211|AZ5_211|AZ6_211|AZ7_211|AZ8_211|AZ9_211)
-q_3*B_311-(q_3.*Z_vars)*(AZ1_311|AZ2_311|AZ3_311|AZ4_311|AZ5_311|AZ6_311|AZ7_311|AZ8_311|AZ9_311)
-q_4*B_411-(q_4.*Z_vars)*(AZ1_411|AZ2_411|AZ3_411|AZ4_411|AZ5_411|AZ6_411|AZ7_411|AZ8_411|AZ9_411)
-q_5*B_511-(q_5.*Z_vars)*(AZ1_511|AZ2_511|AZ3_511|AZ4_511|AZ5_511|AZ6_511|AZ7_511|AZ8_511|AZ9_511)
-q_6*B_611-(q_6.*Z_vars)*(AZ1_611|AZ2_611|AZ3_611|AZ4_611|AZ5_611|AZ6_611|AZ7_611|AZ8_611|AZ9_611)
-q_7*B_711-(q_7.*Z_vars)*(AZ1_711|AZ2_711|AZ3_711|AZ4_711|AZ5_711|AZ6_711|AZ7_711|AZ8_711|AZ9_711)
-q_8*B_811-(q_8.*Z_vars)*(AZ1_811|AZ2_811|AZ3_811|AZ4_811|AZ5_811|AZ6_811|AZ7_811|AZ8_811|AZ9_811)
-q_9*B_911-(q_9.*Z_vars)*(AZ1_911|AZ2_911|AZ3_911|AZ4_911|AZ5_911|AZ6_911|AZ7_911|AZ8_911|AZ9_911);
else;
Y_categ_11=w_11;
endif;	
beta_11=inv(Instrum_categ_11'*X_covars_categ_11)*Instrum_categ_11'*Y_categ_11;
epsilon_11=Y_categ_11-X_covars_categ_11*beta_11;
if symmetry_imposed .eq 1;
b0_11=beta_11[1]; 
b1_11=beta_11[2]; 
b2_11=beta_11[3]; 
b3_11=beta_11[4];
CZ1_11=beta_11[5]; 
CZ2_11=beta_11[6]; 
CZ3_11=beta_11[7]; 
CZ4_11=beta_11[8]; 
CZ5_11=beta_11[9]; 
CZ6_11=beta_11[10]; 
CZ7_11=beta_11[11]; 
CZ8_11=beta_11[12]; 
CZ9_11=beta_11[13];
DZ1_11=beta_11[14]; 
DZ2_11=beta_11[15]; 
DZ3_11=beta_11[16]; 
DZ4_11=beta_11[17]; 
DZ5_11=beta_11[18]; 
DZ6_11=beta_11[19]; 
DZ7_11=beta_11[20]; 
DZ8_11=beta_11[21]; 
DZ9_11=beta_11[22];
B_1111=beta_11[23]; 
AZ1_1111=beta_11[24];
AZ2_1111=beta_11[25];
AZ3_1111=beta_11[26];
AZ4_1111=beta_11[27]; 
AZ5_1111=beta_11[28];
AZ6_1111=beta_11[29];
AZ7_1111=beta_11[30];
AZ8_1111=beta_11[31];
AZ9_1111=beta_11[32];
else;
b0_11=beta_11[1]; 
b1_11=beta_11[2]; 
b2_11=beta_11[3]; 
b3_11=beta_11[4];
CZ1_11=beta_11[5]; 
CZ2_11=beta_11[6]; 
CZ3_11=beta_11[7]; 
CZ4_11=beta_11[8]; 
CZ5_11=beta_11[9]; 
CZ6_11=beta_11[10]; 
CZ7_11=beta_11[11]; 
CZ8_11=beta_11[12]; 
CZ9_11=beta_11[13];
DZ1_11=beta_11[14]; 
DZ2_11=beta_11[15]; 
DZ3_11=beta_11[16]; 
DZ4_11=beta_11[17]; 
DZ5_11=beta_11[18]; 
DZ6_11=beta_11[19]; 
DZ7_11=beta_11[20]; 
DZ8_11=beta_11[21]; 
DZ9_11=beta_11[22];
B_111=beta_11[23]; 
B_112=beta_11[24]; 
B_113=beta_11[25]; 
B_114=beta_11[26]; 
B_115=beta_11[27]; 
B_116=beta_11[28]; 
B_117=beta_11[29]; 
B_118=beta_11[30]; 
B_119=beta_11[31]; 
B_1110=beta_11[32]; 
B_1111=beta_11[33];
AZ1_111=beta_11[34]; 
AZ1_112=beta_11[35]; 
AZ1_113=beta_11[36]; 
AZ1_114=beta_11[37]; 
AZ1_115=beta_11[38]; 
AZ1_116=beta_11[39]; 
AZ1_117=beta_11[40]; 
AZ1_118=beta_11[41]; 
AZ1_119=beta_11[42]; 
AZ1_1110=beta_11[43]; 
AZ1_1111=beta_11[44];
AZ2_111=beta_11[45]; 
AZ2_112=beta_11[46]; 
AZ2_113=beta_11[47]; 
AZ2_114=beta_11[48]; 
AZ2_115=beta_11[49]; 
AZ2_116=beta_11[50]; 
AZ2_117=beta_11[51]; 
AZ2_118=beta_11[52]; 
AZ2_119=beta_11[53]; 
AZ2_1110=beta_11[54]; 
AZ2_1111=beta_11[55];
AZ3_111=beta_11[56]; 
AZ3_112=beta_11[57]; 
AZ3_113=beta_11[58]; 
AZ3_114=beta_11[59]; 
AZ3_115=beta_11[60]; 
AZ3_116=beta_11[61]; 
AZ3_117=beta_11[62]; 
AZ3_118=beta_11[63]; 
AZ3_119=beta_11[64]; 
AZ3_1110=beta_11[65]; 
AZ3_1111=beta_11[66];
AZ4_111=beta_11[67]; 
AZ4_112=beta_11[68]; 
AZ4_113=beta_11[69]; 
AZ4_114=beta_11[70]; 
AZ4_115=beta_11[71]; 
AZ4_116=beta_11[72]; 
AZ4_117=beta_11[73]; 
AZ4_118=beta_11[74]; 
AZ4_119=beta_11[75]; 
AZ4_1110=beta_11[76]; 
AZ4_1111=beta_11[77];
AZ5_111=beta_11[78]; 
AZ5_112=beta_11[79]; 
AZ5_113=beta_11[80]; 
AZ5_114=beta_11[81]; 
AZ5_115=beta_11[82]; 
AZ5_116=beta_11[83]; 
AZ5_117=beta_11[84]; 
AZ5_118=beta_11[85]; 
AZ5_119=beta_11[86]; 
AZ5_1110=beta_11[87]; 
AZ5_1111=beta_11[88];
AZ6_111=beta_11[89]; 
AZ6_112=beta_11[90]; 
AZ6_113=beta_11[91]; 
AZ6_114=beta_11[92]; 
AZ6_115=beta_11[93]; 
AZ6_116=beta_11[94]; 
AZ6_117=beta_11[95]; 
AZ6_118=beta_11[96]; 
AZ6_119=beta_11[97]; 
AZ6_1110=beta_11[98]; 
AZ6_1111=beta_11[99];
AZ7_111=beta_11[100]; 
AZ7_112=beta_11[101]; 
AZ7_113=beta_11[102]; 
AZ7_114=beta_11[103]; 
AZ7_115=beta_11[104]; 
AZ7_116=beta_11[105]; 
AZ7_117=beta_11[106]; 
AZ7_118=beta_11[107]; 
AZ7_119=beta_11[108]; 
AZ7_1110=beta_11[109]; 
AZ7_1111=beta_11[110];
AZ8_111=beta_11[111]; 
AZ8_112=beta_11[112]; 
AZ8_113=beta_11[113]; 
AZ8_114=beta_11[114]; 
AZ8_115=beta_11[115]; 
AZ8_116=beta_11[116]; 
AZ8_117=beta_11[117]; 
AZ8_118=beta_11[118]; 
AZ8_119=beta_11[119]; 
AZ8_1110=beta_11[120]; 
AZ8_1111=beta_11[121];
AZ9_111=beta_11[122]; 
AZ9_112=beta_11[123]; 
AZ9_113=beta_11[124]; 
AZ9_114=beta_11[125]; 
AZ9_115=beta_11[126]; 
AZ9_116=beta_11[127]; 
AZ9_117=beta_11[128]; 
AZ9_118=beta_11[129]; 
AZ9_119=beta_11[130]; 
AZ9_1110=beta_11[131]; 
AZ9_1111=beta_11[132];
endif;	
b0_12=1-(b0_1+b0_2+b0_3+b0_4+b0_5+b0_6+b0_7+b0_8+b0_9+b0_10+b0_11);
b1_12=-(b1_1+b1_2+b1_3+b1_4+b1_5+b1_6+b1_7+b1_8+b1_9+b1_10+b1_11);
b2_12=-(b2_1+b2_2+b2_3+b2_4+b2_5+b2_6+b2_7+b2_8+b2_9+b2_10+b2_11);
b3_12=-(b3_1+b3_2+b3_3+b3_4+b3_5+b3_6+b3_7+b3_8+b3_9+b3_10+b3_11);
CZ1_12=-(CZ1_1+CZ1_2+CZ1_3+CZ1_4+CZ1_5+CZ1_6+CZ1_7+CZ1_8+CZ1_9+CZ1_10+CZ1_11); 
CZ2_12=-(CZ2_1+CZ2_2+CZ2_3+CZ2_4+CZ2_5+CZ2_6+CZ2_7+CZ2_8+CZ2_9+CZ2_10+CZ2_11); 
CZ3_12=-(CZ3_1+CZ3_2+CZ3_3+CZ3_4+CZ3_5+CZ3_6+CZ3_7+CZ3_8+CZ3_9+CZ3_10+CZ3_11); 
CZ4_12=-(CZ4_1+CZ4_2+CZ4_3+CZ4_4+CZ4_5+CZ4_6+CZ4_7+CZ4_8+CZ4_9+CZ4_10+CZ4_11); 
CZ5_12=-(CZ5_1+CZ5_2+CZ5_3+CZ5_4+CZ5_5+CZ5_6+CZ5_7+CZ5_8+CZ5_9+CZ5_10+CZ5_11); 
CZ6_12=-(CZ6_1+CZ6_2+CZ6_3+CZ6_4+CZ6_5+CZ6_6+CZ6_7+CZ6_8+CZ6_9+CZ6_10+CZ6_11); 
CZ7_12=-(CZ7_1+CZ7_2+CZ7_3+CZ7_4+CZ7_5+CZ7_6+CZ7_7+CZ7_8+CZ7_9+CZ7_10+CZ7_11); 
CZ8_12=-(CZ8_1+CZ8_2+CZ8_3+CZ8_4+CZ8_5+CZ8_6+CZ8_7+CZ8_8+CZ8_9+CZ8_10+CZ8_11); 
CZ9_12=-(CZ9_1+CZ9_2+CZ9_3+CZ9_4+CZ9_5+CZ9_6+CZ9_7+CZ9_8+CZ9_9+CZ9_10+CZ9_11); 
DZ1_12=-(DZ1_1+DZ1_2+DZ1_3+DZ1_4+DZ1_5+DZ1_6+DZ1_7+DZ1_8+DZ1_9+DZ1_10+DZ1_11); 
DZ2_12=-(DZ2_1+DZ2_2+DZ2_3+DZ2_4+DZ2_5+DZ2_6+DZ2_7+DZ2_8+DZ2_9+DZ2_10+DZ2_11); 
DZ3_12=-(DZ3_1+DZ3_2+DZ3_3+DZ3_4+DZ3_5+DZ3_6+DZ3_7+DZ3_8+DZ3_9+DZ3_10+DZ3_11); 
DZ4_12=-(DZ4_1+DZ4_2+DZ4_3+DZ4_4+DZ4_5+DZ4_6+DZ4_7+DZ4_8+DZ4_9+DZ4_10+DZ4_11); 
DZ5_12=-(DZ5_1+DZ5_2+DZ5_3+DZ5_4+DZ5_5+DZ5_6+DZ5_7+DZ5_8+DZ5_9+DZ5_10+DZ5_11); 
DZ6_12=-(DZ6_1+DZ6_2+DZ6_3+DZ6_4+DZ6_5+DZ6_6+DZ6_7+DZ6_8+DZ6_9+DZ6_10+DZ6_11); 
DZ7_12=-(DZ7_1+DZ7_2+DZ7_3+DZ7_4+DZ7_5+DZ7_6+DZ7_7+DZ7_8+DZ7_9+DZ7_10+DZ7_11); 
DZ8_12=-(DZ8_1+DZ8_2+DZ8_3+DZ8_4+DZ8_5+DZ8_6+DZ8_7+DZ8_8+DZ8_9+DZ8_10+DZ8_11); 
DZ9_12=-(DZ9_1+DZ9_2+DZ9_3+DZ9_4+DZ9_5+DZ9_6+DZ9_7+DZ9_8+DZ9_9+DZ9_10+DZ9_11); 
if symmetry_imposed .eq 1;
B_112=-(B_11+B_12+B_13+B_14+B_15+B_16+B_17+B_18+B_19+B_110+B_111);
B_212=-(B_12+B_22+B_23+B_24+B_25+B_26+B_27+B_28+B_29+B_210+B_211);
B_312=-(B_13+B_23+B_33+B_34+B_35+B_36+B_37+B_38+B_39+B_310+B_311);
B_412=-(B_14+B_24+B_34+B_44+B_45+B_46+B_47+B_48+B_49+B_410+B_411);
B_512=-(B_15+B_25+B_35+B_45+B_55+B_56+B_57+B_58+B_59+B_510+B_511);
B_612=-(B_16+B_26+B_36+B_46+B_56+B_66+B_67+B_68+B_69+B_610+B_611);
B_712=-(B_17+B_27+B_37+B_47+B_57+B_67+B_77+B_78+B_79+B_710+B_711);
B_812=-(B_18+B_28+B_38+B_48+B_58+B_68+B_78+B_88+B_89+B_810+B_811);
B_912=-(B_19+B_29+B_39+B_49+B_59+B_69+B_79+B_89+B_99+B_910+B_911);
B_1012=-(B_110+B_210+B_310+B_410+B_510+B_610+B_710+B_810+B_910+B_1010+B_1011);
B_1112=-(B_111+B_211+B_311+B_411+B_511+B_611+B_711+B_811+B_911+B_1011+B_1111);
B_1212=-(B_112+B_212+B_312+B_412+B_512+B_612+B_712+B_812+B_912+B_1012+B_1112);
AZ1_112=-(AZ1_11+AZ1_12+AZ1_13+AZ1_14+AZ1_15+AZ1_16+AZ1_17+AZ1_18+AZ1_19+AZ1_110+AZ1_111);
AZ1_212=-(AZ1_12+AZ1_22+AZ1_23+AZ1_24+AZ1_25+AZ1_26+AZ1_27+AZ1_28+AZ1_29+AZ1_210+AZ1_211);
AZ1_312=-(AZ1_13+AZ1_23+AZ1_33+AZ1_34+AZ1_35+AZ1_36+AZ1_37+AZ1_38+AZ1_39+AZ1_310+AZ1_311);
AZ1_412=-(AZ1_14+AZ1_24+AZ1_34+AZ1_44+AZ1_45+AZ1_46+AZ1_47+AZ1_48+AZ1_49+AZ1_410+AZ1_411);
AZ1_512=-(AZ1_15+AZ1_25+AZ1_35+AZ1_45+AZ1_55+AZ1_56+AZ1_57+AZ1_58+AZ1_59+AZ1_510+AZ1_511);
AZ1_612=-(AZ1_16+AZ1_26+AZ1_36+AZ1_46+AZ1_56+AZ1_66+AZ1_67+AZ1_68+AZ1_69+AZ1_610+AZ1_611);
AZ1_712=-(AZ1_17+AZ1_27+AZ1_37+AZ1_47+AZ1_57+AZ1_67+AZ1_77+AZ1_78+AZ1_79+AZ1_710+AZ1_711);
AZ1_812=-(AZ1_18+AZ1_28+AZ1_38+AZ1_48+AZ1_58+AZ1_68+AZ1_78+AZ1_88+AZ1_89+AZ1_810+AZ1_811);
AZ1_912=-(AZ1_19+AZ1_29+AZ1_39+AZ1_49+AZ1_59+AZ1_69+AZ1_79+AZ1_89+AZ1_99+AZ1_910+AZ1_911);
AZ1_1012=-(AZ1_110+AZ1_210+AZ1_310+AZ1_410+AZ1_510+AZ1_610+AZ1_710+AZ1_810+AZ1_910+AZ1_1010+AZ1_1011);
AZ1_1112=-(AZ1_111+AZ1_211+AZ1_311+AZ1_411+AZ1_511+AZ1_611+AZ1_711+AZ1_811+AZ1_911+AZ1_1011+AZ1_1111);
AZ1_1212=-(AZ1_112+AZ1_212+AZ1_312+AZ1_412+AZ1_512+AZ1_612+AZ1_712+AZ1_812+AZ1_912+AZ1_1012+AZ1_1112);
AZ2_112=-(AZ2_11+AZ2_12+AZ2_13+AZ2_14+AZ2_15+AZ2_16+AZ2_17+AZ2_18+AZ2_19+AZ2_110+AZ2_111);
AZ2_212=-(AZ2_12+AZ2_22+AZ2_23+AZ2_24+AZ2_25+AZ2_26+AZ2_27+AZ2_28+AZ2_29+AZ2_210+AZ2_211);
AZ2_312=-(AZ2_13+AZ2_23+AZ2_33+AZ2_34+AZ2_35+AZ2_36+AZ2_37+AZ2_38+AZ2_39+AZ2_310+AZ2_311);
AZ2_412=-(AZ2_14+AZ2_24+AZ2_34+AZ2_44+AZ2_45+AZ2_46+AZ2_47+AZ2_48+AZ2_49+AZ2_410+AZ2_411);
AZ2_512=-(AZ2_15+AZ2_25+AZ2_35+AZ2_45+AZ2_55+AZ2_56+AZ2_57+AZ2_58+AZ2_59+AZ2_510+AZ2_511);
AZ2_612=-(AZ2_16+AZ2_26+AZ2_36+AZ2_46+AZ2_56+AZ2_66+AZ2_67+AZ2_68+AZ2_69+AZ2_610+AZ2_611);
AZ2_712=-(AZ2_17+AZ2_27+AZ2_37+AZ2_47+AZ2_57+AZ2_67+AZ2_77+AZ2_78+AZ2_79+AZ2_710+AZ2_711);
AZ2_812=-(AZ2_18+AZ2_28+AZ2_38+AZ2_48+AZ2_58+AZ2_68+AZ2_78+AZ2_88+AZ2_89+AZ2_810+AZ2_811);
AZ2_912=-(AZ2_19+AZ2_29+AZ2_39+AZ2_49+AZ2_59+AZ2_69+AZ2_79+AZ2_89+AZ2_99+AZ2_910+AZ2_911);
AZ2_1012=-(AZ2_110+AZ2_210+AZ2_310+AZ2_410+AZ2_510+AZ2_610+AZ2_710+AZ2_810+AZ2_910+AZ2_1010+AZ2_1011);
AZ2_1112=-(AZ2_111+AZ2_211+AZ2_311+AZ2_411+AZ2_511+AZ2_611+AZ2_711+AZ2_811+AZ2_911+AZ2_1011+AZ2_1111);
AZ2_1212=-(AZ2_112+AZ2_212+AZ2_312+AZ2_412+AZ2_512+AZ2_612+AZ2_712+AZ2_812+AZ2_912+AZ2_1012+AZ2_1112);
AZ3_112=-(AZ3_11+AZ3_12+AZ3_13+AZ3_14+AZ3_15+AZ3_16+AZ3_17+AZ3_18+AZ3_19+AZ3_110+AZ3_111);
AZ3_212=-(AZ3_12+AZ3_22+AZ3_23+AZ3_24+AZ3_25+AZ3_26+AZ3_27+AZ3_28+AZ3_29+AZ3_210+AZ3_211);
AZ3_312=-(AZ3_13+AZ3_23+AZ3_33+AZ3_34+AZ3_35+AZ3_36+AZ3_37+AZ3_38+AZ3_39+AZ3_310+AZ3_311);
AZ3_412=-(AZ3_14+AZ3_24+AZ3_34+AZ3_44+AZ3_45+AZ3_46+AZ3_47+AZ3_48+AZ3_49+AZ3_410+AZ3_411);
AZ3_512=-(AZ3_15+AZ3_25+AZ3_35+AZ3_45+AZ3_55+AZ3_56+AZ3_57+AZ3_58+AZ3_59+AZ3_510+AZ3_511);
AZ3_612=-(AZ3_16+AZ3_26+AZ3_36+AZ3_46+AZ3_56+AZ3_66+AZ3_67+AZ3_68+AZ3_69+AZ3_610+AZ3_611);
AZ3_712=-(AZ3_17+AZ3_27+AZ3_37+AZ3_47+AZ3_57+AZ3_67+AZ3_77+AZ3_78+AZ3_79+AZ3_710+AZ3_711);
AZ3_812=-(AZ3_18+AZ3_28+AZ3_38+AZ3_48+AZ3_58+AZ3_68+AZ3_78+AZ3_88+AZ3_89+AZ3_810+AZ3_811);
AZ3_912=-(AZ3_19+AZ3_29+AZ3_39+AZ3_49+AZ3_59+AZ3_69+AZ3_79+AZ3_89+AZ3_99+AZ3_910+AZ3_911);
AZ3_1012=-(AZ3_110+AZ3_210+AZ3_310+AZ3_410+AZ3_510+AZ3_610+AZ3_710+AZ3_810+AZ3_910+AZ3_1010+AZ3_1011);
AZ3_1112=-(AZ3_111+AZ3_211+AZ3_311+AZ3_411+AZ3_511+AZ3_611+AZ3_711+AZ3_811+AZ3_911+AZ3_1011+AZ3_1111);
AZ3_1212=-(AZ3_112+AZ3_212+AZ3_312+AZ3_412+AZ3_512+AZ3_612+AZ3_712+AZ3_812+AZ3_912+AZ3_1012+AZ3_1112);
AZ4_112=-(AZ4_11+AZ4_12+AZ4_13+AZ4_14+AZ4_15+AZ4_16+AZ4_17+AZ4_18+AZ4_19+AZ4_110+AZ4_111);
AZ4_212=-(AZ4_12+AZ4_22+AZ4_23+AZ4_24+AZ4_25+AZ4_26+AZ4_27+AZ4_28+AZ4_29+AZ4_210+AZ4_211);
AZ4_312=-(AZ4_13+AZ4_23+AZ4_33+AZ4_34+AZ4_35+AZ4_36+AZ4_37+AZ4_38+AZ4_39+AZ4_310+AZ4_311);
AZ4_412=-(AZ4_14+AZ4_24+AZ4_34+AZ4_44+AZ4_45+AZ4_46+AZ4_47+AZ4_48+AZ4_49+AZ4_410+AZ4_411);
AZ4_512=-(AZ4_15+AZ4_25+AZ4_35+AZ4_45+AZ4_55+AZ4_56+AZ4_57+AZ4_58+AZ4_59+AZ4_510+AZ4_511);
AZ4_612=-(AZ4_16+AZ4_26+AZ4_36+AZ4_46+AZ4_56+AZ4_66+AZ4_67+AZ4_68+AZ4_69+AZ4_610+AZ4_611);
AZ4_712=-(AZ4_17+AZ4_27+AZ4_37+AZ4_47+AZ4_57+AZ4_67+AZ4_77+AZ4_78+AZ4_79+AZ4_710+AZ4_711);
AZ4_812=-(AZ4_18+AZ4_28+AZ4_38+AZ4_48+AZ4_58+AZ4_68+AZ4_78+AZ4_88+AZ4_89+AZ4_810+AZ4_811);
AZ4_912=-(AZ4_19+AZ4_29+AZ4_39+AZ4_49+AZ4_59+AZ4_69+AZ4_79+AZ4_89+AZ4_99+AZ4_910+AZ4_911);
AZ4_1012=-(AZ4_110+AZ4_210+AZ4_310+AZ4_410+AZ4_510+AZ4_610+AZ4_710+AZ4_810+AZ4_910+AZ4_1010+AZ4_1011);
AZ4_1112=-(AZ4_111+AZ4_211+AZ4_311+AZ4_411+AZ4_511+AZ4_611+AZ4_711+AZ4_811+AZ4_911+AZ4_1011+AZ4_1111);
AZ4_1212=-(AZ4_112+AZ4_212+AZ4_312+AZ4_412+AZ4_512+AZ4_612+AZ4_712+AZ4_812+AZ4_912+AZ4_1012+AZ4_1112);
AZ5_112=-(AZ5_11+AZ5_12+AZ5_13+AZ5_14+AZ5_15+AZ5_16+AZ5_17+AZ5_18+AZ5_19+AZ5_110+AZ5_111);
AZ5_212=-(AZ5_12+AZ5_22+AZ5_23+AZ5_24+AZ5_25+AZ5_26+AZ5_27+AZ5_28+AZ5_29+AZ5_210+AZ5_211);
AZ5_312=-(AZ5_13+AZ5_23+AZ5_33+AZ5_34+AZ5_35+AZ5_36+AZ5_37+AZ5_38+AZ5_39+AZ5_310+AZ5_311);
AZ5_412=-(AZ5_14+AZ5_24+AZ5_34+AZ5_44+AZ5_45+AZ5_46+AZ5_47+AZ5_48+AZ5_49+AZ5_410+AZ5_411);
AZ5_512=-(AZ5_15+AZ5_25+AZ5_35+AZ5_45+AZ5_55+AZ5_56+AZ5_57+AZ5_58+AZ5_59+AZ5_510+AZ5_511);
AZ5_612=-(AZ5_16+AZ5_26+AZ5_36+AZ5_46+AZ5_56+AZ5_66+AZ5_67+AZ5_68+AZ5_69+AZ5_610+AZ5_611);
AZ5_712=-(AZ5_17+AZ5_27+AZ5_37+AZ5_47+AZ5_57+AZ5_67+AZ5_77+AZ5_78+AZ5_79+AZ5_710+AZ5_711);
AZ5_812=-(AZ5_18+AZ5_28+AZ5_38+AZ5_48+AZ5_58+AZ5_68+AZ5_78+AZ5_88+AZ5_89+AZ5_810+AZ5_811);
AZ5_912=-(AZ5_19+AZ5_29+AZ5_39+AZ5_49+AZ5_59+AZ5_69+AZ5_79+AZ5_89+AZ5_99+AZ5_910+AZ5_911);
AZ5_1012=-(AZ5_110+AZ5_210+AZ5_310+AZ5_410+AZ5_510+AZ5_610+AZ5_710+AZ5_810+AZ5_910+AZ5_1010+AZ5_1011);
AZ5_1112=-(AZ5_111+AZ5_211+AZ5_311+AZ5_411+AZ5_511+AZ5_611+AZ5_711+AZ5_811+AZ5_911+AZ5_1011+AZ5_1111);
AZ5_1212=-(AZ5_112+AZ5_212+AZ5_312+AZ5_412+AZ5_512+AZ5_612+AZ5_712+AZ5_812+AZ5_912+AZ5_1012+AZ5_1112);
AZ6_112=-(AZ6_11+AZ6_12+AZ6_13+AZ6_14+AZ6_15+AZ6_16+AZ6_17+AZ6_18+AZ6_19+AZ6_110+AZ6_111);
AZ6_212=-(AZ6_12+AZ6_22+AZ6_23+AZ6_24+AZ6_25+AZ6_26+AZ6_27+AZ6_28+AZ6_29+AZ6_210+AZ6_211);
AZ6_312=-(AZ6_13+AZ6_23+AZ6_33+AZ6_34+AZ6_35+AZ6_36+AZ6_37+AZ6_38+AZ6_39+AZ6_310+AZ6_311);
AZ6_412=-(AZ6_14+AZ6_24+AZ6_34+AZ6_44+AZ6_45+AZ6_46+AZ6_47+AZ6_48+AZ6_49+AZ6_410+AZ6_411);
AZ6_512=-(AZ6_15+AZ6_25+AZ6_35+AZ6_45+AZ6_55+AZ6_56+AZ6_57+AZ6_58+AZ6_59+AZ6_510+AZ6_511);
AZ6_612=-(AZ6_16+AZ6_26+AZ6_36+AZ6_46+AZ6_56+AZ6_66+AZ6_67+AZ6_68+AZ6_69+AZ6_610+AZ6_611);
AZ6_712=-(AZ6_17+AZ6_27+AZ6_37+AZ6_47+AZ6_57+AZ6_67+AZ6_77+AZ6_78+AZ6_79+AZ6_710+AZ6_711);
AZ6_812=-(AZ6_18+AZ6_28+AZ6_38+AZ6_48+AZ6_58+AZ6_68+AZ6_78+AZ6_88+AZ6_89+AZ6_810+AZ6_811);
AZ6_912=-(AZ6_19+AZ6_29+AZ6_39+AZ6_49+AZ6_59+AZ6_69+AZ6_79+AZ6_89+AZ6_99+AZ6_910+AZ6_911);
AZ6_1012=-(AZ6_110+AZ6_210+AZ6_310+AZ6_410+AZ6_510+AZ6_610+AZ6_710+AZ6_810+AZ6_910+AZ6_1010+AZ6_1011);
AZ6_1112=-(AZ6_111+AZ6_211+AZ6_311+AZ6_411+AZ6_511+AZ6_611+AZ6_711+AZ6_811+AZ6_911+AZ6_1011+AZ6_1111);
AZ6_1212=-(AZ6_112+AZ6_212+AZ6_312+AZ6_412+AZ6_512+AZ6_612+AZ6_712+AZ6_812+AZ6_912+AZ6_1012+AZ6_1112);
AZ7_112=-(AZ7_11+AZ7_12+AZ7_13+AZ7_14+AZ7_15+AZ7_16+AZ7_17+AZ7_18+AZ7_19+AZ7_110+AZ7_111);
AZ7_212=-(AZ7_12+AZ7_22+AZ7_23+AZ7_24+AZ7_25+AZ7_26+AZ7_27+AZ7_28+AZ7_29+AZ7_210+AZ7_211);
AZ7_312=-(AZ7_13+AZ7_23+AZ7_33+AZ7_34+AZ7_35+AZ7_36+AZ7_37+AZ7_38+AZ7_39+AZ7_310+AZ7_311);
AZ7_412=-(AZ7_14+AZ7_24+AZ7_34+AZ7_44+AZ7_45+AZ7_46+AZ7_47+AZ7_48+AZ7_49+AZ7_410+AZ7_411);
AZ7_512=-(AZ7_15+AZ7_25+AZ7_35+AZ7_45+AZ7_55+AZ7_56+AZ7_57+AZ7_58+AZ7_59+AZ7_510+AZ7_511);
AZ7_612=-(AZ7_16+AZ7_26+AZ7_36+AZ7_46+AZ7_56+AZ7_66+AZ7_67+AZ7_68+AZ7_69+AZ7_610+AZ7_611);
AZ7_712=-(AZ7_17+AZ7_27+AZ7_37+AZ7_47+AZ7_57+AZ7_67+AZ7_77+AZ7_78+AZ7_79+AZ7_710+AZ7_711);
AZ7_812=-(AZ7_18+AZ7_28+AZ7_38+AZ7_48+AZ7_58+AZ7_68+AZ7_78+AZ7_88+AZ7_89+AZ7_810+AZ7_811);
AZ7_912=-(AZ7_19+AZ7_29+AZ7_39+AZ7_49+AZ7_59+AZ7_69+AZ7_79+AZ7_89+AZ7_99+AZ7_910+AZ7_911);
AZ7_1012=-(AZ7_110+AZ7_210+AZ7_310+AZ7_410+AZ7_510+AZ7_610+AZ7_710+AZ7_810+AZ7_910+AZ7_1010+AZ7_1011);
AZ7_1112=-(AZ7_111+AZ7_211+AZ7_311+AZ7_411+AZ7_511+AZ7_611+AZ7_711+AZ7_811+AZ7_911+AZ7_1011+AZ7_1111);
AZ7_1212=-(AZ7_112+AZ7_212+AZ7_312+AZ7_412+AZ7_512+AZ7_612+AZ7_712+AZ7_812+AZ7_912+AZ7_1012+AZ7_1112);
AZ8_112=-(AZ8_11+AZ8_12+AZ8_13+AZ8_14+AZ8_15+AZ8_16+AZ8_17+AZ8_18+AZ8_19+AZ8_110+AZ8_111);
AZ8_212=-(AZ8_12+AZ8_22+AZ8_23+AZ8_24+AZ8_25+AZ8_26+AZ8_27+AZ8_28+AZ8_29+AZ8_210+AZ8_211);
AZ8_312=-(AZ8_13+AZ8_23+AZ8_33+AZ8_34+AZ8_35+AZ8_36+AZ8_37+AZ8_38+AZ8_39+AZ8_310+AZ8_311);
AZ8_412=-(AZ8_14+AZ8_24+AZ8_34+AZ8_44+AZ8_45+AZ8_46+AZ8_47+AZ8_48+AZ8_49+AZ8_410+AZ8_411);
AZ8_512=-(AZ8_15+AZ8_25+AZ8_35+AZ8_45+AZ8_55+AZ8_56+AZ8_57+AZ8_58+AZ8_59+AZ8_510+AZ8_511);
AZ8_612=-(AZ8_16+AZ8_26+AZ8_36+AZ8_46+AZ8_56+AZ8_66+AZ8_67+AZ8_68+AZ8_69+AZ8_610+AZ8_611);
AZ8_712=-(AZ8_17+AZ8_27+AZ8_37+AZ8_47+AZ8_57+AZ8_67+AZ8_77+AZ8_78+AZ8_79+AZ8_710+AZ8_711);
AZ8_812=-(AZ8_18+AZ8_28+AZ8_38+AZ8_48+AZ8_58+AZ8_68+AZ8_78+AZ8_88+AZ8_89+AZ8_810+AZ8_811);
AZ8_912=-(AZ8_19+AZ8_29+AZ8_39+AZ8_49+AZ8_59+AZ8_69+AZ8_79+AZ8_89+AZ8_99+AZ8_910+AZ8_911);
AZ8_1012=-(AZ8_110+AZ8_210+AZ8_310+AZ8_410+AZ8_510+AZ8_610+AZ8_710+AZ8_810+AZ8_910+AZ8_1010+AZ8_1011);
AZ8_1112=-(AZ8_111+AZ8_211+AZ8_311+AZ8_411+AZ8_511+AZ8_611+AZ8_711+AZ8_811+AZ8_911+AZ8_1011+AZ8_1111);
AZ8_1212=-(AZ8_112+AZ8_212+AZ8_312+AZ8_412+AZ8_512+AZ8_612+AZ8_712+AZ8_812+AZ8_912+AZ8_1012+AZ8_1112);
AZ9_112=-(AZ9_11+AZ9_12+AZ9_13+AZ9_14+AZ9_15+AZ9_16+AZ9_17+AZ9_18+AZ9_19+AZ9_110+AZ9_111);
AZ9_212=-(AZ9_12+AZ9_22+AZ9_23+AZ9_24+AZ9_25+AZ9_26+AZ9_27+AZ9_28+AZ9_29+AZ9_210+AZ9_211);
AZ9_312=-(AZ9_13+AZ9_23+AZ9_33+AZ9_34+AZ9_35+AZ9_36+AZ9_37+AZ9_38+AZ9_39+AZ9_310+AZ9_311);
AZ9_412=-(AZ9_14+AZ9_24+AZ9_34+AZ9_44+AZ9_45+AZ9_46+AZ9_47+AZ9_48+AZ9_49+AZ9_410+AZ9_411);
AZ9_512=-(AZ9_15+AZ9_25+AZ9_35+AZ9_45+AZ9_55+AZ9_56+AZ9_57+AZ9_58+AZ9_59+AZ9_510+AZ9_511);
AZ9_612=-(AZ9_16+AZ9_26+AZ9_36+AZ9_46+AZ9_56+AZ9_66+AZ9_67+AZ9_68+AZ9_69+AZ9_610+AZ9_611);
AZ9_712=-(AZ9_17+AZ9_27+AZ9_37+AZ9_47+AZ9_57+AZ9_67+AZ9_77+AZ9_78+AZ9_79+AZ9_710+AZ9_711);
AZ9_812=-(AZ9_18+AZ9_28+AZ9_38+AZ9_48+AZ9_58+AZ9_68+AZ9_78+AZ9_88+AZ9_89+AZ9_810+AZ9_811);
AZ9_912=-(AZ9_19+AZ9_29+AZ9_39+AZ9_49+AZ9_59+AZ9_69+AZ9_79+AZ9_89+AZ9_99+AZ9_910+AZ9_911);
AZ9_1012=-(AZ9_110+AZ9_210+AZ9_310+AZ9_410+AZ9_510+AZ9_610+AZ9_710+AZ9_810+AZ9_910+AZ9_1010+AZ9_1011);
AZ9_1112=-(AZ9_111+AZ9_211+AZ9_311+AZ9_411+AZ9_511+AZ9_611+AZ9_711+AZ9_811+AZ9_911+AZ9_1011+AZ9_1111);
AZ9_1212=-(AZ9_112+AZ9_212+AZ9_312+AZ9_412+AZ9_512+AZ9_612+AZ9_712+AZ9_812+AZ9_912+AZ9_1012+AZ9_1112);
else;
B_121=-(B_11+B_21+B_31+B_41+B_51+B_61+B_71+B_81+B_91+B_101+B_111);
B_122=-(B_12+B_22+B_32+B_42+B_52+B_62+B_72+B_82+B_92+B_102+B_112);
B_123=-(B_13+B_23+B_33+B_43+B_53+B_63+B_73+B_83+B_93+B_103+B_113);
B_124=-(B_14+B_24+B_34+B_44+B_54+B_64+B_74+B_84+B_94+B_104+B_114);
B_125=-(B_15+B_25+B_35+B_45+B_55+B_65+B_75+B_85+B_95+B_105+B_115);
B_126=-(B_16+B_26+B_36+B_46+B_56+B_66+B_76+B_86+B_96+B_106+B_116);
B_127=-(B_17+B_27+B_37+B_47+B_57+B_67+B_77+B_87+B_97+B_107+B_117);
B_128=-(B_18+B_28+B_38+B_48+B_58+B_68+B_78+B_88+B_98+B_108+B_118);
B_129=-(B_19+B_29+B_39+B_49+B_59+B_69+B_79+B_89+B_99+B_109+B_119);
B_1210=-(B_110+B_210+B_310+B_410+B_510+B_610+B_710+B_810+B_910+B_1010+B_1110);
B_1211=-(B_111+B_211+B_311+B_411+B_511+B_611+B_711+B_811+B_911+B_1011+B_1111);
B_1212=-(B_112+B_212+B_312+B_412+B_512+B_612+B_712+B_812+B_912+B_1012+B_1112);
AZ1_121=-(AZ1_11+AZ1_21+AZ1_31+AZ1_41+AZ1_51+AZ1_61+AZ1_71+AZ1_81+AZ1_91+AZ1_101+AZ1_111);
AZ1_122=-(AZ1_12+AZ1_22+AZ1_32+AZ1_42+AZ1_52+AZ1_62+AZ1_72+AZ1_82+AZ1_92+AZ1_102+AZ1_112);
AZ1_123=-(AZ1_13+AZ1_23+AZ1_33+AZ1_43+AZ1_53+AZ1_63+AZ1_73+AZ1_83+AZ1_93+AZ1_103+AZ1_113);
AZ1_124=-(AZ1_14+AZ1_24+AZ1_34+AZ1_44+AZ1_54+AZ1_64+AZ1_74+AZ1_84+AZ1_94+AZ1_104+AZ1_114);
AZ1_125=-(AZ1_15+AZ1_25+AZ1_35+AZ1_45+AZ1_55+AZ1_65+AZ1_75+AZ1_85+AZ1_95+AZ1_105+AZ1_115);
AZ1_126=-(AZ1_16+AZ1_26+AZ1_36+AZ1_46+AZ1_56+AZ1_66+AZ1_76+AZ1_86+AZ1_96+AZ1_106+AZ1_116);
AZ1_127=-(AZ1_17+AZ1_27+AZ1_37+AZ1_47+AZ1_57+AZ1_67+AZ1_77+AZ1_87+AZ1_97+AZ1_107+AZ1_117);
AZ1_128=-(AZ1_18+AZ1_28+AZ1_38+AZ1_48+AZ1_58+AZ1_68+AZ1_78+AZ1_88+AZ1_98+AZ1_108+AZ1_118);
AZ1_129=-(AZ1_19+AZ1_29+AZ1_39+AZ1_49+AZ1_59+AZ1_69+AZ1_79+AZ1_89+AZ1_99+AZ1_109+AZ1_119);
AZ1_1210=-(AZ1_110+AZ1_210+AZ1_310+AZ1_410+AZ1_510+AZ1_610+AZ1_710+AZ1_810+AZ1_910+AZ1_1010+AZ1_1110);
AZ1_1211=-(AZ1_111+AZ1_211+AZ1_311+AZ1_411+AZ1_511+AZ1_611+AZ1_711+AZ1_811+AZ1_911+AZ1_1011+AZ1_1111);
AZ1_1212=-(AZ1_112+AZ1_212+AZ1_312+AZ1_412+AZ1_512+AZ1_612+AZ1_712+AZ1_812+AZ1_912+AZ1_1012+AZ1_1112);
AZ2_121=-(AZ2_11+AZ2_21+AZ2_31+AZ2_41+AZ2_51+AZ2_61+AZ2_71+AZ2_81+AZ2_91+AZ2_101+AZ2_111);
AZ2_122=-(AZ2_12+AZ2_22+AZ2_32+AZ2_42+AZ2_52+AZ2_62+AZ2_72+AZ2_82+AZ2_92+AZ2_102+AZ2_112);
AZ2_123=-(AZ2_13+AZ2_23+AZ2_33+AZ2_43+AZ2_53+AZ2_63+AZ2_73+AZ2_83+AZ2_93+AZ2_103+AZ2_113);
AZ2_124=-(AZ2_14+AZ2_24+AZ2_34+AZ2_44+AZ2_54+AZ2_64+AZ2_74+AZ2_84+AZ2_94+AZ2_104+AZ2_114);
AZ2_125=-(AZ2_15+AZ2_25+AZ2_35+AZ2_45+AZ2_55+AZ2_65+AZ2_75+AZ2_85+AZ2_95+AZ2_105+AZ2_115);
AZ2_126=-(AZ2_16+AZ2_26+AZ2_36+AZ2_46+AZ2_56+AZ2_66+AZ2_76+AZ2_86+AZ2_96+AZ2_106+AZ2_116);
AZ2_127=-(AZ2_17+AZ2_27+AZ2_37+AZ2_47+AZ2_57+AZ2_67+AZ2_77+AZ2_87+AZ2_97+AZ2_107+AZ2_117);
AZ2_128=-(AZ2_18+AZ2_28+AZ2_38+AZ2_48+AZ2_58+AZ2_68+AZ2_78+AZ2_88+AZ2_98+AZ2_108+AZ2_118);
AZ2_129=-(AZ2_19+AZ2_29+AZ2_39+AZ2_49+AZ2_59+AZ2_69+AZ2_79+AZ2_89+AZ2_99+AZ2_109+AZ2_119);
AZ2_1210=-(AZ2_110+AZ2_210+AZ2_310+AZ2_410+AZ2_510+AZ2_610+AZ2_710+AZ2_810+AZ2_910+AZ2_1010+AZ2_1110);
AZ2_1211=-(AZ2_111+AZ2_211+AZ2_311+AZ2_411+AZ2_511+AZ2_611+AZ2_711+AZ2_811+AZ2_911+AZ2_1011+AZ2_1111);
AZ2_1212=-(AZ2_112+AZ2_212+AZ2_312+AZ2_412+AZ2_512+AZ2_612+AZ2_712+AZ2_812+AZ2_912+AZ2_1012+AZ2_1112);
AZ3_121=-(AZ3_11+AZ3_21+AZ3_31+AZ3_41+AZ3_51+AZ3_61+AZ3_71+AZ3_81+AZ3_91+AZ3_101+AZ3_111);
AZ3_122=-(AZ3_12+AZ3_22+AZ3_32+AZ3_42+AZ3_52+AZ3_62+AZ3_72+AZ3_82+AZ3_92+AZ3_102+AZ3_112);
AZ3_123=-(AZ3_13+AZ3_23+AZ3_33+AZ3_43+AZ3_53+AZ3_63+AZ3_73+AZ3_83+AZ3_93+AZ3_103+AZ3_113);
AZ3_124=-(AZ3_14+AZ3_24+AZ3_34+AZ3_44+AZ3_54+AZ3_64+AZ3_74+AZ3_84+AZ3_94+AZ3_104+AZ3_114);
AZ3_125=-(AZ3_15+AZ3_25+AZ3_35+AZ3_45+AZ3_55+AZ3_65+AZ3_75+AZ3_85+AZ3_95+AZ3_105+AZ3_115);
AZ3_126=-(AZ3_16+AZ3_26+AZ3_36+AZ3_46+AZ3_56+AZ3_66+AZ3_76+AZ3_86+AZ3_96+AZ3_106+AZ3_116);
AZ3_127=-(AZ3_17+AZ3_27+AZ3_37+AZ3_47+AZ3_57+AZ3_67+AZ3_77+AZ3_87+AZ3_97+AZ3_107+AZ3_117);
AZ3_128=-(AZ3_18+AZ3_28+AZ3_38+AZ3_48+AZ3_58+AZ3_68+AZ3_78+AZ3_88+AZ3_98+AZ3_108+AZ3_118);
AZ3_129=-(AZ3_19+AZ3_29+AZ3_39+AZ3_49+AZ3_59+AZ3_69+AZ3_79+AZ3_89+AZ3_99+AZ3_109+AZ3_119);
AZ3_1210=-(AZ3_110+AZ3_210+AZ3_310+AZ3_410+AZ3_510+AZ3_610+AZ3_710+AZ3_810+AZ3_910+AZ3_1010+AZ3_1110);
AZ3_1211=-(AZ3_111+AZ3_211+AZ3_311+AZ3_411+AZ3_511+AZ3_611+AZ3_711+AZ3_811+AZ3_911+AZ3_1011+AZ3_1111);
AZ3_1212=-(AZ3_112+AZ3_212+AZ3_312+AZ3_412+AZ3_512+AZ3_612+AZ3_712+AZ3_812+AZ3_912+AZ3_1012+AZ3_1112);
AZ4_121=-(AZ4_11+AZ4_21+AZ4_31+AZ4_41+AZ4_51+AZ4_61+AZ4_71+AZ4_81+AZ4_91+AZ4_101+AZ4_111);
AZ4_122=-(AZ4_12+AZ4_22+AZ4_32+AZ4_42+AZ4_52+AZ4_62+AZ4_72+AZ4_82+AZ4_92+AZ4_102+AZ4_112);
AZ4_123=-(AZ4_13+AZ4_23+AZ4_33+AZ4_43+AZ4_53+AZ4_63+AZ4_73+AZ4_83+AZ4_93+AZ4_103+AZ4_113);
AZ4_124=-(AZ4_14+AZ4_24+AZ4_34+AZ4_44+AZ4_54+AZ4_64+AZ4_74+AZ4_84+AZ4_94+AZ4_104+AZ4_114);
AZ4_125=-(AZ4_15+AZ4_25+AZ4_35+AZ4_45+AZ4_55+AZ4_65+AZ4_75+AZ4_85+AZ4_95+AZ4_105+AZ4_115);
AZ4_126=-(AZ4_16+AZ4_26+AZ4_36+AZ4_46+AZ4_56+AZ4_66+AZ4_76+AZ4_86+AZ4_96+AZ4_106+AZ4_116);
AZ4_127=-(AZ4_17+AZ4_27+AZ4_37+AZ4_47+AZ4_57+AZ4_67+AZ4_77+AZ4_87+AZ4_97+AZ4_107+AZ4_117);
AZ4_128=-(AZ4_18+AZ4_28+AZ4_38+AZ4_48+AZ4_58+AZ4_68+AZ4_78+AZ4_88+AZ4_98+AZ4_108+AZ4_118);
AZ4_129=-(AZ4_19+AZ4_29+AZ4_39+AZ4_49+AZ4_59+AZ4_69+AZ4_79+AZ4_89+AZ4_99+AZ4_109+AZ4_119);
AZ4_1210=-(AZ4_110+AZ4_210+AZ4_310+AZ4_410+AZ4_510+AZ4_610+AZ4_710+AZ4_810+AZ4_910+AZ4_1010+AZ4_1110);
AZ4_1211=-(AZ4_111+AZ4_211+AZ4_311+AZ4_411+AZ4_511+AZ4_611+AZ4_711+AZ4_811+AZ4_911+AZ4_1011+AZ4_1111);
AZ4_1212=-(AZ4_112+AZ4_212+AZ4_312+AZ4_412+AZ4_512+AZ4_612+AZ4_712+AZ4_812+AZ4_912+AZ4_1012+AZ4_1112);
AZ5_121=-(AZ5_11+AZ5_21+AZ5_31+AZ5_41+AZ5_51+AZ5_61+AZ5_71+AZ5_81+AZ5_91+AZ5_101+AZ5_111);
AZ5_122=-(AZ5_12+AZ5_22+AZ5_32+AZ5_42+AZ5_52+AZ5_62+AZ5_72+AZ5_82+AZ5_92+AZ5_102+AZ5_112);
AZ5_123=-(AZ5_13+AZ5_23+AZ5_33+AZ5_43+AZ5_53+AZ5_63+AZ5_73+AZ5_83+AZ5_93+AZ5_103+AZ5_113);
AZ5_124=-(AZ5_14+AZ5_24+AZ5_34+AZ5_44+AZ5_54+AZ5_64+AZ5_74+AZ5_84+AZ5_94+AZ5_104+AZ5_114);
AZ5_125=-(AZ5_15+AZ5_25+AZ5_35+AZ5_45+AZ5_55+AZ5_65+AZ5_75+AZ5_85+AZ5_95+AZ5_105+AZ5_115);
AZ5_126=-(AZ5_16+AZ5_26+AZ5_36+AZ5_46+AZ5_56+AZ5_66+AZ5_76+AZ5_86+AZ5_96+AZ5_106+AZ5_116);
AZ5_127=-(AZ5_17+AZ5_27+AZ5_37+AZ5_47+AZ5_57+AZ5_67+AZ5_77+AZ5_87+AZ5_97+AZ5_107+AZ5_117);
AZ5_128=-(AZ5_18+AZ5_28+AZ5_38+AZ5_48+AZ5_58+AZ5_68+AZ5_78+AZ5_88+AZ5_98+AZ5_108+AZ5_118);
AZ5_129=-(AZ5_19+AZ5_29+AZ5_39+AZ5_49+AZ5_59+AZ5_69+AZ5_79+AZ5_89+AZ5_99+AZ5_109+AZ5_119);
AZ5_1210=-(AZ5_110+AZ5_210+AZ5_310+AZ5_410+AZ5_510+AZ5_610+AZ5_710+AZ5_810+AZ5_910+AZ5_1010+AZ5_1110);
AZ5_1211=-(AZ5_111+AZ5_211+AZ5_311+AZ5_411+AZ5_511+AZ5_611+AZ5_711+AZ5_811+AZ5_911+AZ5_1011+AZ5_1111);
AZ5_1212=-(AZ5_112+AZ5_212+AZ5_312+AZ5_412+AZ5_512+AZ5_612+AZ5_712+AZ5_812+AZ5_912+AZ5_1012+AZ5_1112);
AZ6_121=-(AZ6_11+AZ6_21+AZ6_31+AZ6_41+AZ6_51+AZ6_61+AZ6_71+AZ6_81+AZ6_91+AZ6_101+AZ6_111);
AZ6_122=-(AZ6_12+AZ6_22+AZ6_32+AZ6_42+AZ6_52+AZ6_62+AZ6_72+AZ6_82+AZ6_92+AZ6_102+AZ6_112);
AZ6_123=-(AZ6_13+AZ6_23+AZ6_33+AZ6_43+AZ6_53+AZ6_63+AZ6_73+AZ6_83+AZ6_93+AZ6_103+AZ6_113);
AZ6_124=-(AZ6_14+AZ6_24+AZ6_34+AZ6_44+AZ6_54+AZ6_64+AZ6_74+AZ6_84+AZ6_94+AZ6_104+AZ6_114);
AZ6_125=-(AZ6_15+AZ6_25+AZ6_35+AZ6_45+AZ6_55+AZ6_65+AZ6_75+AZ6_85+AZ6_95+AZ6_105+AZ6_115);
AZ6_126=-(AZ6_16+AZ6_26+AZ6_36+AZ6_46+AZ6_56+AZ6_66+AZ6_76+AZ6_86+AZ6_96+AZ6_106+AZ6_116);
AZ6_127=-(AZ6_17+AZ6_27+AZ6_37+AZ6_47+AZ6_57+AZ6_67+AZ6_77+AZ6_87+AZ6_97+AZ6_107+AZ6_117);
AZ6_128=-(AZ6_18+AZ6_28+AZ6_38+AZ6_48+AZ6_58+AZ6_68+AZ6_78+AZ6_88+AZ6_98+AZ6_108+AZ6_118);
AZ6_129=-(AZ6_19+AZ6_29+AZ6_39+AZ6_49+AZ6_59+AZ6_69+AZ6_79+AZ6_89+AZ6_99+AZ6_109+AZ6_119);
AZ6_1210=-(AZ6_110+AZ6_210+AZ6_310+AZ6_410+AZ6_510+AZ6_610+AZ6_710+AZ6_810+AZ6_910+AZ6_1010+AZ6_1110);
AZ6_1211=-(AZ6_111+AZ6_211+AZ6_311+AZ6_411+AZ6_511+AZ6_611+AZ6_711+AZ6_811+AZ6_911+AZ6_1011+AZ6_1111);
AZ6_1212=-(AZ6_112+AZ6_212+AZ6_312+AZ6_412+AZ6_512+AZ6_612+AZ6_712+AZ6_812+AZ6_912+AZ6_1012+AZ6_1112);
AZ7_121=-(AZ7_11+AZ7_21+AZ7_31+AZ7_41+AZ7_51+AZ7_61+AZ7_71+AZ7_81+AZ7_91+AZ7_101+AZ7_111);
AZ7_122=-(AZ7_12+AZ7_22+AZ7_32+AZ7_42+AZ7_52+AZ7_62+AZ7_72+AZ7_82+AZ7_92+AZ7_102+AZ7_112);
AZ7_123=-(AZ7_13+AZ7_23+AZ7_33+AZ7_43+AZ7_53+AZ7_63+AZ7_73+AZ7_83+AZ7_93+AZ7_103+AZ7_113);
AZ7_124=-(AZ7_14+AZ7_24+AZ7_34+AZ7_44+AZ7_54+AZ7_64+AZ7_74+AZ7_84+AZ7_94+AZ7_104+AZ7_114);
AZ7_125=-(AZ7_15+AZ7_25+AZ7_35+AZ7_45+AZ7_55+AZ7_65+AZ7_75+AZ7_85+AZ7_95+AZ7_105+AZ7_115);
AZ7_126=-(AZ7_16+AZ7_26+AZ7_36+AZ7_46+AZ7_56+AZ7_66+AZ7_76+AZ7_86+AZ7_96+AZ7_106+AZ7_116);
AZ7_127=-(AZ7_17+AZ7_27+AZ7_37+AZ7_47+AZ7_57+AZ7_67+AZ7_77+AZ7_87+AZ7_97+AZ7_107+AZ7_117);
AZ7_128=-(AZ7_18+AZ7_28+AZ7_38+AZ7_48+AZ7_58+AZ7_68+AZ7_78+AZ7_88+AZ7_98+AZ7_108+AZ7_118);
AZ7_129=-(AZ7_19+AZ7_29+AZ7_39+AZ7_49+AZ7_59+AZ7_69+AZ7_79+AZ7_89+AZ7_99+AZ7_109+AZ7_119);
AZ7_1210=-(AZ7_110+AZ7_210+AZ7_310+AZ7_410+AZ7_510+AZ7_610+AZ7_710+AZ7_810+AZ7_910+AZ7_1010+AZ7_1110);
AZ7_1211=-(AZ7_111+AZ7_211+AZ7_311+AZ7_411+AZ7_511+AZ7_611+AZ7_711+AZ7_811+AZ7_911+AZ7_1011+AZ7_1111);
AZ7_1212=-(AZ7_112+AZ7_212+AZ7_312+AZ7_412+AZ7_512+AZ7_612+AZ7_712+AZ7_812+AZ7_912+AZ7_1012+AZ7_1112);
AZ8_121=-(AZ8_11+AZ8_21+AZ8_31+AZ8_41+AZ8_51+AZ8_61+AZ8_71+AZ8_81+AZ8_91+AZ8_101+AZ8_111);
AZ8_122=-(AZ8_12+AZ8_22+AZ8_32+AZ8_42+AZ8_52+AZ8_62+AZ8_72+AZ8_82+AZ8_92+AZ8_102+AZ8_112);
AZ8_123=-(AZ8_13+AZ8_23+AZ8_33+AZ8_43+AZ8_53+AZ8_63+AZ8_73+AZ8_83+AZ8_93+AZ8_103+AZ8_113);
AZ8_124=-(AZ8_14+AZ8_24+AZ8_34+AZ8_44+AZ8_54+AZ8_64+AZ8_74+AZ8_84+AZ8_94+AZ8_104+AZ8_114);
AZ8_125=-(AZ8_15+AZ8_25+AZ8_35+AZ8_45+AZ8_55+AZ8_65+AZ8_75+AZ8_85+AZ8_95+AZ8_105+AZ8_115);
AZ8_126=-(AZ8_16+AZ8_26+AZ8_36+AZ8_46+AZ8_56+AZ8_66+AZ8_76+AZ8_86+AZ8_96+AZ8_106+AZ8_116);
AZ8_127=-(AZ8_17+AZ8_27+AZ8_37+AZ8_47+AZ8_57+AZ8_67+AZ8_77+AZ8_87+AZ8_97+AZ8_107+AZ8_117);
AZ8_128=-(AZ8_18+AZ8_28+AZ8_38+AZ8_48+AZ8_58+AZ8_68+AZ8_78+AZ8_88+AZ8_98+AZ8_108+AZ8_118);
AZ8_129=-(AZ8_19+AZ8_29+AZ8_39+AZ8_49+AZ8_59+AZ8_69+AZ8_79+AZ8_89+AZ8_99+AZ8_109+AZ8_119);
AZ8_1210=-(AZ8_110+AZ8_210+AZ8_310+AZ8_410+AZ8_510+AZ8_610+AZ8_710+AZ8_810+AZ8_910+AZ8_1010+AZ8_1110);
AZ8_1211=-(AZ8_111+AZ8_211+AZ8_311+AZ8_411+AZ8_511+AZ8_611+AZ8_711+AZ8_811+AZ8_911+AZ8_1011+AZ8_1111);
AZ8_1212=-(AZ8_112+AZ8_212+AZ8_312+AZ8_412+AZ8_512+AZ8_612+AZ8_712+AZ8_812+AZ8_912+AZ8_1012+AZ8_1112);
AZ9_121=-(AZ9_11+AZ9_21+AZ9_31+AZ9_41+AZ9_51+AZ9_61+AZ9_71+AZ9_81+AZ9_91+AZ9_101+AZ9_111);
AZ9_122=-(AZ9_12+AZ9_22+AZ9_32+AZ9_42+AZ9_52+AZ9_62+AZ9_72+AZ9_82+AZ9_92+AZ9_102+AZ9_112);
AZ9_123=-(AZ9_13+AZ9_23+AZ9_33+AZ9_43+AZ9_53+AZ9_63+AZ9_73+AZ9_83+AZ9_93+AZ9_103+AZ9_113);
AZ9_124=-(AZ9_14+AZ9_24+AZ9_34+AZ9_44+AZ9_54+AZ9_64+AZ9_74+AZ9_84+AZ9_94+AZ9_104+AZ9_114);
AZ9_125=-(AZ9_15+AZ9_25+AZ9_35+AZ9_45+AZ9_55+AZ9_65+AZ9_75+AZ9_85+AZ9_95+AZ9_105+AZ9_115);
AZ9_126=-(AZ9_16+AZ9_26+AZ9_36+AZ9_46+AZ9_56+AZ9_66+AZ9_76+AZ9_86+AZ9_96+AZ9_106+AZ9_116);
AZ9_127=-(AZ9_17+AZ9_27+AZ9_37+AZ9_47+AZ9_57+AZ9_67+AZ9_77+AZ9_87+AZ9_97+AZ9_107+AZ9_117);
AZ9_128=-(AZ9_18+AZ9_28+AZ9_38+AZ9_48+AZ9_58+AZ9_68+AZ9_78+AZ9_88+AZ9_98+AZ9_108+AZ9_118);
AZ9_129=-(AZ9_19+AZ9_29+AZ9_39+AZ9_49+AZ9_59+AZ9_69+AZ9_79+AZ9_89+AZ9_99+AZ9_109+AZ9_119);
AZ9_1210=-(AZ9_110+AZ9_210+AZ9_310+AZ9_410+AZ9_510+AZ9_610+AZ9_710+AZ9_810+AZ9_910+AZ9_1010+AZ9_1110);
AZ9_1211=-(AZ9_111+AZ9_211+AZ9_311+AZ9_411+AZ9_511+AZ9_611+AZ9_711+AZ9_811+AZ9_911+AZ9_1011+AZ9_1111);
AZ9_1212=-(AZ9_112+AZ9_212+AZ9_312+AZ9_412+AZ9_512+AZ9_612+AZ9_712+AZ9_812+AZ9_912+AZ9_1012+AZ9_1112);
endif;
epsilon_12=-(epsilon_1+epsilon_2+epsilon_3+epsilon_4+epsilon_5+epsilon_6+epsilon_7+epsilon_8+epsilon_9+epsilon_10+epsilon_11);
epsilon_matrix=
epsilon_1~epsilon_2~epsilon_3~epsilon_4~epsilon_5~epsilon_6~epsilon_7~epsilon_8~epsilon_9~epsilon_10~epsilon_11~epsilon_12;
b0_vector=b0_1|b0_2|b0_3|b0_4|b0_5|b0_6|b0_7|b0_8|b0_9|b0_10|b0_11|b0_12;
b1_vector=b1_1|b1_2|b1_3|b1_4|b1_5|b1_6|b1_7|b1_8|b1_9|b1_10|b1_11|b1_12;
b2_vector=b2_1|b2_2|b2_3|b2_4|b2_5|b2_6|b2_7|b2_8|b2_9|b2_10|b2_11|b2_12;
b3_vector=b3_1|b3_2|b3_3|b3_4|b3_5|b3_6|b3_7|b3_8|b3_9|b3_10|b3_11|b3_12;
C_matrix=
(CZ1_1~CZ2_1~CZ3_1~CZ4_1~CZ5_1~CZ6_1~CZ7_1~CZ8_1~CZ9_1)
|(CZ1_2~CZ2_2~CZ3_2~CZ4_2~CZ5_2~CZ6_2~CZ7_2~CZ8_2~CZ9_2)
|(CZ1_3~CZ2_3~CZ3_3~CZ4_3~CZ5_3~CZ6_3~CZ7_3~CZ8_3~CZ9_3)
|(CZ1_4~CZ2_4~CZ3_4~CZ4_4~CZ5_4~CZ6_4~CZ7_4~CZ8_4~CZ9_4)
|(CZ1_5~CZ2_5~CZ3_5~CZ4_5~CZ5_5~CZ6_5~CZ7_5~CZ8_5~CZ9_5)
|(CZ1_6~CZ2_6~CZ3_6~CZ4_6~CZ5_6~CZ6_6~CZ7_6~CZ8_6~CZ9_6)
|(CZ1_7~CZ2_7~CZ3_7~CZ4_7~CZ5_7~CZ6_7~CZ7_7~CZ8_7~CZ9_7)
|(CZ1_8~CZ2_8~CZ3_8~CZ4_8~CZ5_8~CZ6_8~CZ7_8~CZ8_8~CZ9_8)
|(CZ1_9~CZ2_9~CZ3_9~CZ4_9~CZ5_9~CZ6_9~CZ7_9~CZ8_9~CZ9_9)
|(CZ1_10~CZ2_10~CZ3_10~CZ4_10~CZ5_10~CZ6_10~CZ7_10~CZ8_10~CZ9_10)
|(CZ1_11~CZ2_11~CZ3_11~CZ4_11~CZ5_11~CZ6_11~CZ7_11~CZ8_11~CZ9_11)
|(CZ1_12~CZ2_12~CZ3_12~CZ4_12~CZ5_12~CZ6_12~CZ7_12~CZ8_12~CZ9_12);
D_matrix=
(DZ1_1~DZ2_1~DZ3_1~DZ4_1~DZ5_1~DZ6_1~DZ7_1~DZ8_1~DZ9_1)
|(DZ1_2~DZ2_2~DZ3_2~DZ4_2~DZ5_2~DZ6_2~DZ7_2~DZ8_2~DZ9_2)
|(DZ1_3~DZ2_3~DZ3_3~DZ4_3~DZ5_3~DZ6_3~DZ7_3~DZ8_3~DZ9_3)
|(DZ1_4~DZ2_4~DZ3_4~DZ4_4~DZ5_4~DZ6_4~DZ7_4~DZ8_4~DZ9_4)
|(DZ1_5~DZ2_5~DZ3_5~DZ4_5~DZ5_5~DZ6_5~DZ7_5~DZ8_5~DZ9_5)
|(DZ1_6~DZ2_6~DZ3_6~DZ4_6~DZ5_6~DZ6_6~DZ7_6~DZ8_6~DZ9_6)
|(DZ1_7~DZ2_7~DZ3_7~DZ4_7~DZ5_7~DZ6_7~DZ7_7~DZ8_7~DZ9_7)
|(DZ1_8~DZ2_8~DZ3_8~DZ4_8~DZ5_8~DZ6_8~DZ7_8~DZ8_8~DZ9_8)
|(DZ1_9~DZ2_9~DZ3_9~DZ4_9~DZ5_9~DZ6_9~DZ7_9~DZ8_9~DZ9_9)
|(DZ1_10~DZ2_10~DZ3_10~DZ4_10~DZ5_10~DZ6_10~DZ7_10~DZ8_10~DZ9_10)
|(DZ1_11~DZ2_11~DZ3_11~DZ4_11~DZ5_11~DZ6_11~DZ7_11~DZ8_11~DZ9_11)
|(DZ1_12~DZ2_12~DZ3_12~DZ4_12~DZ5_12~DZ6_12~DZ7_12~DZ8_12~DZ9_12);
if symmetry_imposed .eq 1;
B_matrix=
(B_11~B_12~B_13~B_14~B_15~B_16~B_17~B_18~B_19~B_110~B_111~B_112)
|(B_12~B_22~B_23~B_24~B_25~B_26~B_27~B_28~B_29~B_210~B_211~B_212)
|(B_13~B_23~B_33~B_34~B_35~B_36~B_37~B_38~B_39~B_310~B_311~B_312)
|(B_14~B_24~B_34~B_44~B_45~B_46~B_47~B_48~B_49~B_410~B_411~B_412)
|(B_15~B_25~B_35~B_45~B_55~B_56~B_57~B_58~B_59~B_510~B_511~B_512)
|(B_16~B_26~B_36~B_46~B_56~B_66~B_67~B_68~B_69~B_610~B_611~B_612)
|(B_17~B_27~B_37~B_47~B_57~B_67~B_77~B_78~B_79~B_710~B_711~B_712)
|(B_18~B_28~B_38~B_48~B_58~B_68~B_78~B_88~B_89~B_810~B_811~B_812)
|(B_19~B_29~B_39~B_49~B_59~B_69~B_79~B_89~B_99~B_910~B_911~B_912)
|(B_110~B_210~B_310~B_410~B_510~B_610~B_710~B_810~B_910~B_1010~B_1011~B_1012)
|(B_111~B_211~B_311~B_411~B_511~B_611~B_711~B_811~B_911~B_1011~B_1111~B_1112)
|(B_112~B_212~B_312~B_412~B_512~B_612~B_712~B_812~B_912~B_1012~B_1112~B_1212);
AZ1_matrix=
(AZ1_11~AZ1_12~AZ1_13~AZ1_14~AZ1_15~AZ1_16~AZ1_17~AZ1_18~AZ1_19~AZ1_110~AZ1_111~AZ1_112)
|(AZ1_12~AZ1_22~AZ1_23~AZ1_24~AZ1_25~AZ1_26~AZ1_27~AZ1_28~AZ1_29~AZ1_210~AZ1_211~AZ1_212)
|(AZ1_13~AZ1_23~AZ1_33~AZ1_34~AZ1_35~AZ1_36~AZ1_37~AZ1_38~AZ1_39~AZ1_310~AZ1_311~AZ1_312)
|(AZ1_14~AZ1_24~AZ1_34~AZ1_44~AZ1_45~AZ1_46~AZ1_47~AZ1_48~AZ1_49~AZ1_410~AZ1_411~AZ1_412)
|(AZ1_15~AZ1_25~AZ1_35~AZ1_45~AZ1_55~AZ1_56~AZ1_57~AZ1_58~AZ1_59~AZ1_510~AZ1_511~AZ1_512)
|(AZ1_16~AZ1_26~AZ1_36~AZ1_46~AZ1_56~AZ1_66~AZ1_67~AZ1_68~AZ1_69~AZ1_610~AZ1_611~AZ1_612)
|(AZ1_17~AZ1_27~AZ1_37~AZ1_47~AZ1_57~AZ1_67~AZ1_77~AZ1_78~AZ1_79~AZ1_710~AZ1_711~AZ1_712)
|(AZ1_18~AZ1_28~AZ1_38~AZ1_48~AZ1_58~AZ1_68~AZ1_78~AZ1_88~AZ1_89~AZ1_810~AZ1_811~AZ1_812)
|(AZ1_19~AZ1_29~AZ1_39~AZ1_49~AZ1_59~AZ1_69~AZ1_79~AZ1_89~AZ1_99~AZ1_910~AZ1_911~AZ1_912)
|(AZ1_110~AZ1_210~AZ1_310~AZ1_410~AZ1_510~AZ1_610~AZ1_710~AZ1_810~AZ1_910~AZ1_1010~AZ1_1011~AZ1_1012)
|(AZ1_111~AZ1_211~AZ1_311~AZ1_411~AZ1_511~AZ1_611~AZ1_711~AZ1_811~AZ1_911~AZ1_1011~AZ1_1111~AZ1_1112)
|(AZ1_112~AZ1_212~AZ1_312~AZ1_412~AZ1_512~AZ1_612~AZ1_712~AZ1_812~AZ1_912~AZ1_1012~AZ1_1112~AZ1_1212);
AZ2_matrix=
(AZ2_11~AZ2_12~AZ2_13~AZ2_14~AZ2_15~AZ2_16~AZ2_17~AZ2_18~AZ2_19~AZ2_110~AZ2_111~AZ2_112)
|(AZ2_12~AZ2_22~AZ2_23~AZ2_24~AZ2_25~AZ2_26~AZ2_27~AZ2_28~AZ2_29~AZ2_210~AZ2_211~AZ2_212)
|(AZ2_13~AZ2_23~AZ2_33~AZ2_34~AZ2_35~AZ2_36~AZ2_37~AZ2_38~AZ2_39~AZ2_310~AZ2_311~AZ2_312)
|(AZ2_14~AZ2_24~AZ2_34~AZ2_44~AZ2_45~AZ2_46~AZ2_47~AZ2_48~AZ2_49~AZ2_410~AZ2_411~AZ2_412)
|(AZ2_15~AZ2_25~AZ2_35~AZ2_45~AZ2_55~AZ2_56~AZ2_57~AZ2_58~AZ2_59~AZ2_510~AZ2_511~AZ2_512)
|(AZ2_16~AZ2_26~AZ2_36~AZ2_46~AZ2_56~AZ2_66~AZ2_67~AZ2_68~AZ2_69~AZ2_610~AZ2_611~AZ2_612)
|(AZ2_17~AZ2_27~AZ2_37~AZ2_47~AZ2_57~AZ2_67~AZ2_77~AZ2_78~AZ2_79~AZ2_710~AZ2_711~AZ2_712)
|(AZ2_18~AZ2_28~AZ2_38~AZ2_48~AZ2_58~AZ2_68~AZ2_78~AZ2_88~AZ2_89~AZ2_810~AZ2_811~AZ2_812)
|(AZ2_19~AZ2_29~AZ2_39~AZ2_49~AZ2_59~AZ2_69~AZ2_79~AZ2_89~AZ2_99~AZ2_910~AZ2_911~AZ2_912)
|(AZ2_110~AZ2_210~AZ2_310~AZ2_410~AZ2_510~AZ2_610~AZ2_710~AZ2_810~AZ2_910~AZ2_1010~AZ2_1011~AZ2_1012)
|(AZ2_111~AZ2_211~AZ2_311~AZ2_411~AZ2_511~AZ2_611~AZ2_711~AZ2_811~AZ2_911~AZ2_1011~AZ2_1111~AZ2_1112)
|(AZ2_112~AZ2_212~AZ2_312~AZ2_412~AZ2_512~AZ2_612~AZ2_712~AZ2_812~AZ2_912~AZ2_1012~AZ2_1112~AZ2_1212);
AZ3_matrix=
(AZ3_11~AZ3_12~AZ3_13~AZ3_14~AZ3_15~AZ3_16~AZ3_17~AZ3_18~AZ3_19~AZ3_110~AZ3_111~AZ3_112)
|(AZ3_12~AZ3_22~AZ3_23~AZ3_24~AZ3_25~AZ3_26~AZ3_27~AZ3_28~AZ3_29~AZ3_210~AZ3_211~AZ3_212)
|(AZ3_13~AZ3_23~AZ3_33~AZ3_34~AZ3_35~AZ3_36~AZ3_37~AZ3_38~AZ3_39~AZ3_310~AZ3_311~AZ3_312)
|(AZ3_14~AZ3_24~AZ3_34~AZ3_44~AZ3_45~AZ3_46~AZ3_47~AZ3_48~AZ3_49~AZ3_410~AZ3_411~AZ3_412)
|(AZ3_15~AZ3_25~AZ3_35~AZ3_45~AZ3_55~AZ3_56~AZ3_57~AZ3_58~AZ3_59~AZ3_510~AZ3_511~AZ3_512)
|(AZ3_16~AZ3_26~AZ3_36~AZ3_46~AZ3_56~AZ3_66~AZ3_67~AZ3_68~AZ3_69~AZ3_610~AZ3_611~AZ3_612)
|(AZ3_17~AZ3_27~AZ3_37~AZ3_47~AZ3_57~AZ3_67~AZ3_77~AZ3_78~AZ3_79~AZ3_710~AZ3_711~AZ3_712)
|(AZ3_18~AZ3_28~AZ3_38~AZ3_48~AZ3_58~AZ3_68~AZ3_78~AZ3_88~AZ3_89~AZ3_810~AZ3_811~AZ3_812)
|(AZ3_19~AZ3_29~AZ3_39~AZ3_49~AZ3_59~AZ3_69~AZ3_79~AZ3_89~AZ3_99~AZ3_910~AZ3_911~AZ3_912)
|(AZ3_110~AZ3_210~AZ3_310~AZ3_410~AZ3_510~AZ3_610~AZ3_710~AZ3_810~AZ3_910~AZ3_1010~AZ3_1011~AZ3_1012)
|(AZ3_111~AZ3_211~AZ3_311~AZ3_411~AZ3_511~AZ3_611~AZ3_711~AZ3_811~AZ3_911~AZ3_1011~AZ3_1111~AZ3_1112)
|(AZ3_112~AZ3_212~AZ3_312~AZ3_412~AZ3_512~AZ3_612~AZ3_712~AZ3_812~AZ3_912~AZ3_1012~AZ3_1112~AZ3_1212);
AZ4_matrix=
(AZ4_11~AZ4_12~AZ4_13~AZ4_14~AZ4_15~AZ4_16~AZ4_17~AZ4_18~AZ4_19~AZ4_110~AZ4_111~AZ4_112)
|(AZ4_12~AZ4_22~AZ4_23~AZ4_24~AZ4_25~AZ4_26~AZ4_27~AZ4_28~AZ4_29~AZ4_210~AZ4_211~AZ4_212)
|(AZ4_13~AZ4_23~AZ4_33~AZ4_34~AZ4_35~AZ4_36~AZ4_37~AZ4_38~AZ4_39~AZ4_310~AZ4_311~AZ4_312)
|(AZ4_14~AZ4_24~AZ4_34~AZ4_44~AZ4_45~AZ4_46~AZ4_47~AZ4_48~AZ4_49~AZ4_410~AZ4_411~AZ4_412)
|(AZ4_15~AZ4_25~AZ4_35~AZ4_45~AZ4_55~AZ4_56~AZ4_57~AZ4_58~AZ4_59~AZ4_510~AZ4_511~AZ4_512)
|(AZ4_16~AZ4_26~AZ4_36~AZ4_46~AZ4_56~AZ4_66~AZ4_67~AZ4_68~AZ4_69~AZ4_610~AZ4_611~AZ4_612)
|(AZ4_17~AZ4_27~AZ4_37~AZ4_47~AZ4_57~AZ4_67~AZ4_77~AZ4_78~AZ4_79~AZ4_710~AZ4_711~AZ4_712)
|(AZ4_18~AZ4_28~AZ4_38~AZ4_48~AZ4_58~AZ4_68~AZ4_78~AZ4_88~AZ4_89~AZ4_810~AZ4_811~AZ4_812)
|(AZ4_19~AZ4_29~AZ4_39~AZ4_49~AZ4_59~AZ4_69~AZ4_79~AZ4_89~AZ4_99~AZ4_910~AZ4_911~AZ4_912)
|(AZ4_110~AZ4_210~AZ4_310~AZ4_410~AZ4_510~AZ4_610~AZ4_710~AZ4_810~AZ4_910~AZ4_1010~AZ4_1011~AZ4_1012)
|(AZ4_111~AZ4_211~AZ4_311~AZ4_411~AZ4_511~AZ4_611~AZ4_711~AZ4_811~AZ4_911~AZ4_1011~AZ4_1111~AZ4_1112)
|(AZ4_112~AZ4_212~AZ4_312~AZ4_412~AZ4_512~AZ4_612~AZ4_712~AZ4_812~AZ4_912~AZ4_1012~AZ4_1112~AZ4_1212);
AZ5_matrix=
(AZ5_11~AZ5_12~AZ5_13~AZ5_14~AZ5_15~AZ5_16~AZ5_17~AZ5_18~AZ5_19~AZ5_110~AZ5_111~AZ5_112)
|(AZ5_12~AZ5_22~AZ5_23~AZ5_24~AZ5_25~AZ5_26~AZ5_27~AZ5_28~AZ5_29~AZ5_210~AZ5_211~AZ5_212)
|(AZ5_13~AZ5_23~AZ5_33~AZ5_34~AZ5_35~AZ5_36~AZ5_37~AZ5_38~AZ5_39~AZ5_310~AZ5_311~AZ5_312)
|(AZ5_14~AZ5_24~AZ5_34~AZ5_44~AZ5_45~AZ5_46~AZ5_47~AZ5_48~AZ5_49~AZ5_410~AZ5_411~AZ5_412)
|(AZ5_15~AZ5_25~AZ5_35~AZ5_45~AZ5_55~AZ5_56~AZ5_57~AZ5_58~AZ5_59~AZ5_510~AZ5_511~AZ5_512)
|(AZ5_16~AZ5_26~AZ5_36~AZ5_46~AZ5_56~AZ5_66~AZ5_67~AZ5_68~AZ5_69~AZ5_610~AZ5_611~AZ5_612)
|(AZ5_17~AZ5_27~AZ5_37~AZ5_47~AZ5_57~AZ5_67~AZ5_77~AZ5_78~AZ5_79~AZ5_710~AZ5_711~AZ5_712)
|(AZ5_18~AZ5_28~AZ5_38~AZ5_48~AZ5_58~AZ5_68~AZ5_78~AZ5_88~AZ5_89~AZ5_810~AZ5_811~AZ5_812)
|(AZ5_19~AZ5_29~AZ5_39~AZ5_49~AZ5_59~AZ5_69~AZ5_79~AZ5_89~AZ5_99~AZ5_910~AZ5_911~AZ5_912)
|(AZ5_110~AZ5_210~AZ5_310~AZ5_410~AZ5_510~AZ5_610~AZ5_710~AZ5_810~AZ5_910~AZ5_1010~AZ5_1011~AZ5_1012)
|(AZ5_111~AZ5_211~AZ5_311~AZ5_411~AZ5_511~AZ5_611~AZ5_711~AZ5_811~AZ5_911~AZ5_1011~AZ5_1111~AZ5_1112)
|(AZ5_112~AZ5_212~AZ5_312~AZ5_412~AZ5_512~AZ5_612~AZ5_712~AZ5_812~AZ5_912~AZ5_1012~AZ5_1112~AZ5_1212);
AZ6_matrix=
(AZ6_11~AZ6_12~AZ6_13~AZ6_14~AZ6_15~AZ6_16~AZ6_17~AZ6_18~AZ6_19~AZ6_110~AZ6_111~AZ6_112)
|(AZ6_12~AZ6_22~AZ6_23~AZ6_24~AZ6_25~AZ6_26~AZ6_27~AZ6_28~AZ6_29~AZ6_210~AZ6_211~AZ6_212)
|(AZ6_13~AZ6_23~AZ6_33~AZ6_34~AZ6_35~AZ6_36~AZ6_37~AZ6_38~AZ6_39~AZ6_310~AZ6_311~AZ6_312)
|(AZ6_14~AZ6_24~AZ6_34~AZ6_44~AZ6_45~AZ6_46~AZ6_47~AZ6_48~AZ6_49~AZ6_410~AZ6_411~AZ6_412)
|(AZ6_15~AZ6_25~AZ6_35~AZ6_45~AZ6_55~AZ6_56~AZ6_57~AZ6_58~AZ6_59~AZ6_510~AZ6_511~AZ6_512)
|(AZ6_16~AZ6_26~AZ6_36~AZ6_46~AZ6_56~AZ6_66~AZ6_67~AZ6_68~AZ6_69~AZ6_610~AZ6_611~AZ6_612)
|(AZ6_17~AZ6_27~AZ6_37~AZ6_47~AZ6_57~AZ6_67~AZ6_77~AZ6_78~AZ6_79~AZ6_710~AZ6_711~AZ6_712)
|(AZ6_18~AZ6_28~AZ6_38~AZ6_48~AZ6_58~AZ6_68~AZ6_78~AZ6_88~AZ6_89~AZ6_810~AZ6_811~AZ6_812)
|(AZ6_19~AZ6_29~AZ6_39~AZ6_49~AZ6_59~AZ6_69~AZ6_79~AZ6_89~AZ6_99~AZ6_910~AZ6_911~AZ6_912)
|(AZ6_110~AZ6_210~AZ6_310~AZ6_410~AZ6_510~AZ6_610~AZ6_710~AZ6_810~AZ6_910~AZ6_1010~AZ6_1011~AZ6_1012)
|(AZ6_111~AZ6_211~AZ6_311~AZ6_411~AZ6_511~AZ6_611~AZ6_711~AZ6_811~AZ6_911~AZ6_1011~AZ6_1111~AZ6_1112)
|(AZ6_112~AZ6_212~AZ6_312~AZ6_412~AZ6_512~AZ6_612~AZ6_712~AZ6_812~AZ6_912~AZ6_1012~AZ6_1112~AZ6_1212);
AZ7_matrix=
(AZ7_11~AZ7_12~AZ7_13~AZ7_14~AZ7_15~AZ7_16~AZ7_17~AZ7_18~AZ7_19~AZ7_110~AZ7_111~AZ7_112)
|(AZ7_12~AZ7_22~AZ7_23~AZ7_24~AZ7_25~AZ7_26~AZ7_27~AZ7_28~AZ7_29~AZ7_210~AZ7_211~AZ7_212)
|(AZ7_13~AZ7_23~AZ7_33~AZ7_34~AZ7_35~AZ7_36~AZ7_37~AZ7_38~AZ7_39~AZ7_310~AZ7_311~AZ7_312)
|(AZ7_14~AZ7_24~AZ7_34~AZ7_44~AZ7_45~AZ7_46~AZ7_47~AZ7_48~AZ7_49~AZ7_410~AZ7_411~AZ7_412)
|(AZ7_15~AZ7_25~AZ7_35~AZ7_45~AZ7_55~AZ7_56~AZ7_57~AZ7_58~AZ7_59~AZ7_510~AZ7_511~AZ7_512)
|(AZ7_16~AZ7_26~AZ7_36~AZ7_46~AZ7_56~AZ7_66~AZ7_67~AZ7_68~AZ7_69~AZ7_610~AZ7_611~AZ7_612)
|(AZ7_17~AZ7_27~AZ7_37~AZ7_47~AZ7_57~AZ7_67~AZ7_77~AZ7_78~AZ7_79~AZ7_710~AZ7_711~AZ7_712)
|(AZ7_18~AZ7_28~AZ7_38~AZ7_48~AZ7_58~AZ7_68~AZ7_78~AZ7_88~AZ7_89~AZ7_810~AZ7_811~AZ7_812)
|(AZ7_19~AZ7_29~AZ7_39~AZ7_49~AZ7_59~AZ7_69~AZ7_79~AZ7_89~AZ7_99~AZ7_910~AZ7_911~AZ7_912)
|(AZ7_110~AZ7_210~AZ7_310~AZ7_410~AZ7_510~AZ7_610~AZ7_710~AZ7_810~AZ7_910~AZ7_1010~AZ7_1011~AZ7_1012)
|(AZ7_111~AZ7_211~AZ7_311~AZ7_411~AZ7_511~AZ7_611~AZ7_711~AZ7_811~AZ7_911~AZ7_1011~AZ7_1111~AZ7_1112)
|(AZ7_112~AZ7_212~AZ7_312~AZ7_412~AZ7_512~AZ7_612~AZ7_712~AZ7_812~AZ7_912~AZ7_1012~AZ7_1112~AZ7_1212);
AZ8_matrix=
(AZ8_11~AZ8_12~AZ8_13~AZ8_14~AZ8_15~AZ8_16~AZ8_17~AZ8_18~AZ8_19~AZ8_110~AZ8_111~AZ8_112)
|(AZ8_12~AZ8_22~AZ8_23~AZ8_24~AZ8_25~AZ8_26~AZ8_27~AZ8_28~AZ8_29~AZ8_210~AZ8_211~AZ8_212)
|(AZ8_13~AZ8_23~AZ8_33~AZ8_34~AZ8_35~AZ8_36~AZ8_37~AZ8_38~AZ8_39~AZ8_310~AZ8_311~AZ8_312)
|(AZ8_14~AZ8_24~AZ8_34~AZ8_44~AZ8_45~AZ8_46~AZ8_47~AZ8_48~AZ8_49~AZ8_410~AZ8_411~AZ8_412)
|(AZ8_15~AZ8_25~AZ8_35~AZ8_45~AZ8_55~AZ8_56~AZ8_57~AZ8_58~AZ8_59~AZ8_510~AZ8_511~AZ8_512)
|(AZ8_16~AZ8_26~AZ8_36~AZ8_46~AZ8_56~AZ8_66~AZ8_67~AZ8_68~AZ8_69~AZ8_610~AZ8_611~AZ8_612)
|(AZ8_17~AZ8_27~AZ8_37~AZ8_47~AZ8_57~AZ8_67~AZ8_77~AZ8_78~AZ8_79~AZ8_710~AZ8_711~AZ8_712)
|(AZ8_18~AZ8_28~AZ8_38~AZ8_48~AZ8_58~AZ8_68~AZ8_78~AZ8_88~AZ8_89~AZ8_810~AZ8_811~AZ8_812)
|(AZ8_19~AZ8_29~AZ8_39~AZ8_49~AZ8_59~AZ8_69~AZ8_79~AZ8_89~AZ8_99~AZ8_910~AZ8_911~AZ8_912)
|(AZ8_110~AZ8_210~AZ8_310~AZ8_410~AZ8_510~AZ8_610~AZ8_710~AZ8_810~AZ8_910~AZ8_1010~AZ8_1011~AZ8_1012)
|(AZ8_111~AZ8_211~AZ8_311~AZ8_411~AZ8_511~AZ8_611~AZ8_711~AZ8_811~AZ8_911~AZ8_1011~AZ8_1111~AZ8_1112)
|(AZ8_112~AZ8_212~AZ8_312~AZ8_412~AZ8_512~AZ8_612~AZ8_712~AZ8_812~AZ8_912~AZ8_1012~AZ8_1112~AZ8_1212);
AZ9_matrix=
(AZ9_11~AZ9_12~AZ9_13~AZ9_14~AZ9_15~AZ9_16~AZ9_17~AZ9_18~AZ9_19~AZ9_110~AZ9_111~AZ9_112)
|(AZ9_12~AZ9_22~AZ9_23~AZ9_24~AZ9_25~AZ9_26~AZ9_27~AZ9_28~AZ9_29~AZ9_210~AZ9_211~AZ9_212)
|(AZ9_13~AZ9_23~AZ9_33~AZ9_34~AZ9_35~AZ9_36~AZ9_37~AZ9_38~AZ9_39~AZ9_310~AZ9_311~AZ9_312)
|(AZ9_14~AZ9_24~AZ9_34~AZ9_44~AZ9_45~AZ9_46~AZ9_47~AZ9_48~AZ9_49~AZ9_410~AZ9_411~AZ9_412)
|(AZ9_15~AZ9_25~AZ9_35~AZ9_45~AZ9_55~AZ9_56~AZ9_57~AZ9_58~AZ9_59~AZ9_510~AZ9_511~AZ9_512)
|(AZ9_16~AZ9_26~AZ9_36~AZ9_46~AZ9_56~AZ9_66~AZ9_67~AZ9_68~AZ9_69~AZ9_610~AZ9_611~AZ9_612)
|(AZ9_17~AZ9_27~AZ9_37~AZ9_47~AZ9_57~AZ9_67~AZ9_77~AZ9_78~AZ9_79~AZ9_710~AZ9_711~AZ9_712)
|(AZ9_18~AZ9_28~AZ9_38~AZ9_48~AZ9_58~AZ9_68~AZ9_78~AZ9_88~AZ9_89~AZ9_810~AZ9_811~AZ9_812)
|(AZ9_19~AZ9_29~AZ9_39~AZ9_49~AZ9_59~AZ9_69~AZ9_79~AZ9_89~AZ9_99~AZ9_910~AZ9_911~AZ9_912)
|(AZ9_110~AZ9_210~AZ9_310~AZ9_410~AZ9_510~AZ9_610~AZ9_710~AZ9_810~AZ9_910~AZ9_1010~AZ9_1011~AZ9_1012)
|(AZ9_111~AZ9_211~AZ9_311~AZ9_411~AZ9_511~AZ9_611~AZ9_711~AZ9_811~AZ9_911~AZ9_1011~AZ9_1111~AZ9_1112)
|(AZ9_112~AZ9_212~AZ9_312~AZ9_412~AZ9_512~AZ9_612~AZ9_712~AZ9_812~AZ9_912~AZ9_1012~AZ9_1112~AZ9_1212);
else;
B_matrix=
(B_11~B_12~B_13~B_14~B_15~B_16~B_17~B_18~B_19~B_110~B_111~B_112)
|(B_21~B_22~B_23~B_24~B_25~B_26~B_27~B_28~B_29~B_210~B_211~B_212)
|(B_31~B_32~B_33~B_34~B_35~B_36~B_37~B_38~B_39~B_310~B_311~B_312)
|(B_41~B_42~B_43~B_44~B_45~B_46~B_47~B_48~B_49~B_410~B_411~B_412)
|(B_51~B_52~B_53~B_54~B_55~B_56~B_57~B_58~B_59~B_510~B_511~B_512)
|(B_61~B_62~B_63~B_64~B_65~B_66~B_67~B_68~B_69~B_610~B_611~B_612)
|(B_71~B_72~B_73~B_74~B_75~B_76~B_77~B_78~B_79~B_710~B_711~B_712)
|(B_81~B_82~B_83~B_84~B_85~B_86~B_87~B_88~B_89~B_810~B_811~B_812)
|(B_91~B_92~B_93~B_94~B_95~B_96~B_97~B_98~B_99~B_910~B_911~B_912)
|(B_101~B_102~B_103~B_104~B_105~B_106~B_107~B_108~B_109~B_1010~B_1011~B_1012)
|(B_111~B_112~B_113~B_114~B_115~B_116~B_117~B_118~B_119~B_1110~B_1111~B_1112)
|(B_121~B_122~B_123~B_124~B_125~B_126~B_127~B_128~B_129~B_1210~B_1211~B_1212);
AZ1_matrix=
(AZ1_11~AZ1_12~AZ1_13~AZ1_14~AZ1_15~AZ1_16~AZ1_17~AZ1_18~AZ1_19~AZ1_110~AZ1_111~AZ1_112)
|(AZ1_21~AZ1_22~AZ1_23~AZ1_24~AZ1_25~AZ1_26~AZ1_27~AZ1_28~AZ1_29~AZ1_210~AZ1_211~AZ1_212)
|(AZ1_31~AZ1_32~AZ1_33~AZ1_34~AZ1_35~AZ1_36~AZ1_37~AZ1_38~AZ1_39~AZ1_310~AZ1_311~AZ1_312)
|(AZ1_41~AZ1_42~AZ1_43~AZ1_44~AZ1_45~AZ1_46~AZ1_47~AZ1_48~AZ1_49~AZ1_410~AZ1_411~AZ1_412)
|(AZ1_51~AZ1_52~AZ1_53~AZ1_54~AZ1_55~AZ1_56~AZ1_57~AZ1_58~AZ1_59~AZ1_510~AZ1_511~AZ1_512)
|(AZ1_61~AZ1_62~AZ1_63~AZ1_64~AZ1_65~AZ1_66~AZ1_67~AZ1_68~AZ1_69~AZ1_610~AZ1_611~AZ1_612)
|(AZ1_71~AZ1_72~AZ1_73~AZ1_74~AZ1_75~AZ1_76~AZ1_77~AZ1_78~AZ1_79~AZ1_710~AZ1_711~AZ1_712)
|(AZ1_81~AZ1_82~AZ1_83~AZ1_84~AZ1_85~AZ1_86~AZ1_87~AZ1_88~AZ1_89~AZ1_810~AZ1_811~AZ1_812)
|(AZ1_91~AZ1_92~AZ1_93~AZ1_94~AZ1_95~AZ1_96~AZ1_97~AZ1_98~AZ1_99~AZ1_910~AZ1_911~AZ1_912)
|(AZ1_101~AZ1_102~AZ1_103~AZ1_104~AZ1_105~AZ1_106~AZ1_107~AZ1_108~AZ1_109~AZ1_1010~AZ1_1011~AZ1_1012)
|(AZ1_111~AZ1_112~AZ1_113~AZ1_114~AZ1_115~AZ1_116~AZ1_117~AZ1_118~AZ1_119~AZ1_1110~AZ1_1111~AZ1_1112)
|(AZ1_121~AZ1_122~AZ1_123~AZ1_124~AZ1_125~AZ1_126~AZ1_127~AZ1_128~AZ1_129~AZ1_1210~AZ1_1211~AZ1_1212);
AZ2_matrix=
(AZ2_11~AZ2_12~AZ2_13~AZ2_14~AZ2_15~AZ2_16~AZ2_17~AZ2_18~AZ2_19~AZ2_110~AZ2_111~AZ2_112)
|(AZ2_21~AZ2_22~AZ2_23~AZ2_24~AZ2_25~AZ2_26~AZ2_27~AZ2_28~AZ2_29~AZ2_210~AZ2_211~AZ2_212)
|(AZ2_31~AZ2_32~AZ2_33~AZ2_34~AZ2_35~AZ2_36~AZ2_37~AZ2_38~AZ2_39~AZ2_310~AZ2_311~AZ2_312)
|(AZ2_41~AZ2_42~AZ2_43~AZ2_44~AZ2_45~AZ2_46~AZ2_47~AZ2_48~AZ2_49~AZ2_410~AZ2_411~AZ2_412)
|(AZ2_51~AZ2_52~AZ2_53~AZ2_54~AZ2_55~AZ2_56~AZ2_57~AZ2_58~AZ2_59~AZ2_510~AZ2_511~AZ2_512)
|(AZ2_61~AZ2_62~AZ2_63~AZ2_64~AZ2_65~AZ2_66~AZ2_67~AZ2_68~AZ2_69~AZ2_610~AZ2_611~AZ2_612)
|(AZ2_71~AZ2_72~AZ2_73~AZ2_74~AZ2_75~AZ2_76~AZ2_77~AZ2_78~AZ2_79~AZ2_710~AZ2_711~AZ2_712)
|(AZ2_81~AZ2_82~AZ2_83~AZ2_84~AZ2_85~AZ2_86~AZ2_87~AZ2_88~AZ2_89~AZ2_810~AZ2_811~AZ2_812)
|(AZ2_91~AZ2_92~AZ2_93~AZ2_94~AZ2_95~AZ2_96~AZ2_97~AZ2_98~AZ2_99~AZ2_910~AZ2_911~AZ2_912)
|(AZ2_101~AZ2_102~AZ2_103~AZ2_104~AZ2_105~AZ2_106~AZ2_107~AZ2_108~AZ2_109~AZ2_1010~AZ2_1011~AZ2_1012)
|(AZ2_111~AZ2_112~AZ2_113~AZ2_114~AZ2_115~AZ2_116~AZ2_117~AZ2_118~AZ2_119~AZ2_1110~AZ2_1111~AZ2_1112)
|(AZ2_121~AZ2_122~AZ2_123~AZ2_124~AZ2_125~AZ2_126~AZ2_127~AZ2_128~AZ2_129~AZ2_1210~AZ2_1211~AZ2_1212);
AZ3_matrix=
(AZ3_11~AZ3_12~AZ3_13~AZ3_14~AZ3_15~AZ3_16~AZ3_17~AZ3_18~AZ3_19~AZ3_110~AZ3_111~AZ3_112)
|(AZ3_21~AZ3_22~AZ3_23~AZ3_24~AZ3_25~AZ3_26~AZ3_27~AZ3_28~AZ3_29~AZ3_210~AZ3_211~AZ3_212)
|(AZ3_31~AZ3_32~AZ3_33~AZ3_34~AZ3_35~AZ3_36~AZ3_37~AZ3_38~AZ3_39~AZ3_310~AZ3_311~AZ3_312)
|(AZ3_41~AZ3_42~AZ3_43~AZ3_44~AZ3_45~AZ3_46~AZ3_47~AZ3_48~AZ3_49~AZ3_410~AZ3_411~AZ3_412)
|(AZ3_51~AZ3_52~AZ3_53~AZ3_54~AZ3_55~AZ3_56~AZ3_57~AZ3_58~AZ3_59~AZ3_510~AZ3_511~AZ3_512)
|(AZ3_61~AZ3_62~AZ3_63~AZ3_64~AZ3_65~AZ3_66~AZ3_67~AZ3_68~AZ3_69~AZ3_610~AZ3_611~AZ3_612)
|(AZ3_71~AZ3_72~AZ3_73~AZ3_74~AZ3_75~AZ3_76~AZ3_77~AZ3_78~AZ3_79~AZ3_710~AZ3_711~AZ3_712)
|(AZ3_81~AZ3_82~AZ3_83~AZ3_84~AZ3_85~AZ3_86~AZ3_87~AZ3_88~AZ3_89~AZ3_810~AZ3_811~AZ3_812)
|(AZ3_91~AZ3_92~AZ3_93~AZ3_94~AZ3_95~AZ3_96~AZ3_97~AZ3_98~AZ3_99~AZ3_910~AZ3_911~AZ3_912)
|(AZ3_101~AZ3_102~AZ3_103~AZ3_104~AZ3_105~AZ3_106~AZ3_107~AZ3_108~AZ3_109~AZ3_1010~AZ3_1011~AZ3_1012)
|(AZ3_111~AZ3_112~AZ3_113~AZ3_114~AZ3_115~AZ3_116~AZ3_117~AZ3_118~AZ3_119~AZ3_1110~AZ3_1111~AZ3_1112)
|(AZ3_121~AZ3_122~AZ3_123~AZ3_124~AZ3_125~AZ3_126~AZ3_127~AZ3_128~AZ3_129~AZ3_1210~AZ3_1211~AZ3_1212);
AZ4_matrix=
(AZ4_11~AZ4_12~AZ4_13~AZ4_14~AZ4_15~AZ4_16~AZ4_17~AZ4_18~AZ4_19~AZ4_110~AZ4_111~AZ4_112)
|(AZ4_21~AZ4_22~AZ4_23~AZ4_24~AZ4_25~AZ4_26~AZ4_27~AZ4_28~AZ4_29~AZ4_210~AZ4_211~AZ4_212)
|(AZ4_31~AZ4_32~AZ4_33~AZ4_34~AZ4_35~AZ4_36~AZ4_37~AZ4_38~AZ4_39~AZ4_310~AZ4_311~AZ4_312)
|(AZ4_41~AZ4_42~AZ4_43~AZ4_44~AZ4_45~AZ4_46~AZ4_47~AZ4_48~AZ4_49~AZ4_410~AZ4_411~AZ4_412)
|(AZ4_51~AZ4_52~AZ4_53~AZ4_54~AZ4_55~AZ4_56~AZ4_57~AZ4_58~AZ4_59~AZ4_510~AZ4_511~AZ4_512)
|(AZ4_61~AZ4_62~AZ4_63~AZ4_64~AZ4_65~AZ4_66~AZ4_67~AZ4_68~AZ4_69~AZ4_610~AZ4_611~AZ4_612)
|(AZ4_71~AZ4_72~AZ4_73~AZ4_74~AZ4_75~AZ4_76~AZ4_77~AZ4_78~AZ4_79~AZ4_710~AZ4_711~AZ4_712)
|(AZ4_81~AZ4_82~AZ4_83~AZ4_84~AZ4_85~AZ4_86~AZ4_87~AZ4_88~AZ4_89~AZ4_810~AZ4_811~AZ4_812)
|(AZ4_91~AZ4_92~AZ4_93~AZ4_94~AZ4_95~AZ4_96~AZ4_97~AZ4_98~AZ4_99~AZ4_910~AZ4_911~AZ4_912)
|(AZ4_101~AZ4_102~AZ4_103~AZ4_104~AZ4_105~AZ4_106~AZ4_107~AZ4_108~AZ4_109~AZ4_1010~AZ4_1011~AZ4_1012)
|(AZ4_111~AZ4_112~AZ4_113~AZ4_114~AZ4_115~AZ4_116~AZ4_117~AZ4_118~AZ4_119~AZ4_1110~AZ4_1111~AZ4_1112)
|(AZ4_121~AZ4_122~AZ4_123~AZ4_124~AZ4_125~AZ4_126~AZ4_127~AZ4_128~AZ4_129~AZ4_1210~AZ4_1211~AZ4_1212);
AZ5_matrix=
(AZ5_11~AZ5_12~AZ5_13~AZ5_14~AZ5_15~AZ5_16~AZ5_17~AZ5_18~AZ5_19~AZ5_110~AZ5_111~AZ5_112)
|(AZ5_21~AZ5_22~AZ5_23~AZ5_24~AZ5_25~AZ5_26~AZ5_27~AZ5_28~AZ5_29~AZ5_210~AZ5_211~AZ5_212)
|(AZ5_31~AZ5_32~AZ5_33~AZ5_34~AZ5_35~AZ5_36~AZ5_37~AZ5_38~AZ5_39~AZ5_310~AZ5_311~AZ5_312)
|(AZ5_41~AZ5_42~AZ5_43~AZ5_44~AZ5_45~AZ5_46~AZ5_47~AZ5_48~AZ5_49~AZ5_410~AZ5_411~AZ5_412)
|(AZ5_51~AZ5_52~AZ5_53~AZ5_54~AZ5_55~AZ5_56~AZ5_57~AZ5_58~AZ5_59~AZ5_510~AZ5_511~AZ5_512)
|(AZ5_61~AZ5_62~AZ5_63~AZ5_64~AZ5_65~AZ5_66~AZ5_67~AZ5_68~AZ5_69~AZ5_610~AZ5_611~AZ5_612)
|(AZ5_71~AZ5_72~AZ5_73~AZ5_74~AZ5_75~AZ5_76~AZ5_77~AZ5_78~AZ5_79~AZ5_710~AZ5_711~AZ5_712)
|(AZ5_81~AZ5_82~AZ5_83~AZ5_84~AZ5_85~AZ5_86~AZ5_87~AZ5_88~AZ5_89~AZ5_810~AZ5_811~AZ5_812)
|(AZ5_91~AZ5_92~AZ5_93~AZ5_94~AZ5_95~AZ5_96~AZ5_97~AZ5_98~AZ5_99~AZ5_910~AZ5_911~AZ5_912)
|(AZ5_101~AZ5_102~AZ5_103~AZ5_104~AZ5_105~AZ5_106~AZ5_107~AZ5_108~AZ5_109~AZ5_1010~AZ5_1011~AZ5_1012)
|(AZ5_111~AZ5_112~AZ5_113~AZ5_114~AZ5_115~AZ5_116~AZ5_117~AZ5_118~AZ5_119~AZ5_1110~AZ5_1111~AZ5_1112)
|(AZ5_121~AZ5_122~AZ5_123~AZ5_124~AZ5_125~AZ5_126~AZ5_127~AZ5_128~AZ5_129~AZ5_1210~AZ5_1211~AZ5_1212);
AZ6_matrix=
(AZ6_11~AZ6_12~AZ6_13~AZ6_14~AZ6_15~AZ6_16~AZ6_17~AZ6_18~AZ6_19~AZ6_110~AZ6_111~AZ6_112)
|(AZ6_21~AZ6_22~AZ6_23~AZ6_24~AZ6_25~AZ6_26~AZ6_27~AZ6_28~AZ6_29~AZ6_210~AZ6_211~AZ6_212)
|(AZ6_31~AZ6_32~AZ6_33~AZ6_34~AZ6_35~AZ6_36~AZ6_37~AZ6_38~AZ6_39~AZ6_310~AZ6_311~AZ6_312)
|(AZ6_41~AZ6_42~AZ6_43~AZ6_44~AZ6_45~AZ6_46~AZ6_47~AZ6_48~AZ6_49~AZ6_410~AZ6_411~AZ6_412)
|(AZ6_51~AZ6_52~AZ6_53~AZ6_54~AZ6_55~AZ6_56~AZ6_57~AZ6_58~AZ6_59~AZ6_510~AZ6_511~AZ6_512)
|(AZ6_61~AZ6_62~AZ6_63~AZ6_64~AZ6_65~AZ6_66~AZ6_67~AZ6_68~AZ6_69~AZ6_610~AZ6_611~AZ6_612)
|(AZ6_71~AZ6_72~AZ6_73~AZ6_74~AZ6_75~AZ6_76~AZ6_77~AZ6_78~AZ6_79~AZ6_710~AZ6_711~AZ6_712)
|(AZ6_81~AZ6_82~AZ6_83~AZ6_84~AZ6_85~AZ6_86~AZ6_87~AZ6_88~AZ6_89~AZ6_810~AZ6_811~AZ6_812)
|(AZ6_91~AZ6_92~AZ6_93~AZ6_94~AZ6_95~AZ6_96~AZ6_97~AZ6_98~AZ6_99~AZ6_910~AZ6_911~AZ6_912)
|(AZ6_101~AZ6_102~AZ6_103~AZ6_104~AZ6_105~AZ6_106~AZ6_107~AZ6_108~AZ6_109~AZ6_1010~AZ6_1011~AZ6_1012)
|(AZ6_111~AZ6_112~AZ6_113~AZ6_114~AZ6_115~AZ6_116~AZ6_117~AZ6_118~AZ6_119~AZ6_1110~AZ6_1111~AZ6_1112)
|(AZ6_121~AZ6_122~AZ6_123~AZ6_124~AZ6_125~AZ6_126~AZ6_127~AZ6_128~AZ6_129~AZ6_1210~AZ6_1211~AZ6_1212);
AZ7_matrix=
(AZ7_11~AZ7_12~AZ7_13~AZ7_14~AZ7_15~AZ7_16~AZ7_17~AZ7_18~AZ7_19~AZ7_110~AZ7_111~AZ7_112)
|(AZ7_21~AZ7_22~AZ7_23~AZ7_24~AZ7_25~AZ7_26~AZ7_27~AZ7_28~AZ7_29~AZ7_210~AZ7_211~AZ7_212)
|(AZ7_31~AZ7_32~AZ7_33~AZ7_34~AZ7_35~AZ7_36~AZ7_37~AZ7_38~AZ7_39~AZ7_310~AZ7_311~AZ7_312)
|(AZ7_41~AZ7_42~AZ7_43~AZ7_44~AZ7_45~AZ7_46~AZ7_47~AZ7_48~AZ7_49~AZ7_410~AZ7_411~AZ7_412)
|(AZ7_51~AZ7_52~AZ7_53~AZ7_54~AZ7_55~AZ7_56~AZ7_57~AZ7_58~AZ7_59~AZ7_510~AZ7_511~AZ7_512)
|(AZ7_61~AZ7_62~AZ7_63~AZ7_64~AZ7_65~AZ7_66~AZ7_67~AZ7_68~AZ7_69~AZ7_610~AZ7_611~AZ7_612)
|(AZ7_71~AZ7_72~AZ7_73~AZ7_74~AZ7_75~AZ7_76~AZ7_77~AZ7_78~AZ7_79~AZ7_710~AZ7_711~AZ7_712)
|(AZ7_81~AZ7_82~AZ7_83~AZ7_84~AZ7_85~AZ7_86~AZ7_87~AZ7_88~AZ7_89~AZ7_810~AZ7_811~AZ7_812)
|(AZ7_91~AZ7_92~AZ7_93~AZ7_94~AZ7_95~AZ7_96~AZ7_97~AZ7_98~AZ7_99~AZ7_910~AZ7_911~AZ7_912)
|(AZ7_101~AZ7_102~AZ7_103~AZ7_104~AZ7_105~AZ7_106~AZ7_107~AZ7_108~AZ7_109~AZ7_1010~AZ7_1011~AZ7_1012)
|(AZ7_111~AZ7_112~AZ7_113~AZ7_114~AZ7_115~AZ7_116~AZ7_117~AZ7_118~AZ7_119~AZ7_1110~AZ7_1111~AZ7_1112)
|(AZ7_121~AZ7_122~AZ7_123~AZ7_124~AZ7_125~AZ7_126~AZ7_127~AZ7_128~AZ7_129~AZ7_1210~AZ7_1211~AZ7_1212);
AZ8_matrix=
(AZ8_11~AZ8_12~AZ8_13~AZ8_14~AZ8_15~AZ8_16~AZ8_17~AZ8_18~AZ8_19~AZ8_110~AZ8_111~AZ8_112)
|(AZ8_21~AZ8_22~AZ8_23~AZ8_24~AZ8_25~AZ8_26~AZ8_27~AZ8_28~AZ8_29~AZ8_210~AZ8_211~AZ8_212)
|(AZ8_31~AZ8_32~AZ8_33~AZ8_34~AZ8_35~AZ8_36~AZ8_37~AZ8_38~AZ8_39~AZ8_310~AZ8_311~AZ8_312)
|(AZ8_41~AZ8_42~AZ8_43~AZ8_44~AZ8_45~AZ8_46~AZ8_47~AZ8_48~AZ8_49~AZ8_410~AZ8_411~AZ8_412)
|(AZ8_51~AZ8_52~AZ8_53~AZ8_54~AZ8_55~AZ8_56~AZ8_57~AZ8_58~AZ8_59~AZ8_510~AZ8_511~AZ8_512)
|(AZ8_61~AZ8_62~AZ8_63~AZ8_64~AZ8_65~AZ8_66~AZ8_67~AZ8_68~AZ8_69~AZ8_610~AZ8_611~AZ8_612)
|(AZ8_71~AZ8_72~AZ8_73~AZ8_74~AZ8_75~AZ8_76~AZ8_77~AZ8_78~AZ8_79~AZ8_710~AZ8_711~AZ8_712)
|(AZ8_81~AZ8_82~AZ8_83~AZ8_84~AZ8_85~AZ8_86~AZ8_87~AZ8_88~AZ8_89~AZ8_810~AZ8_811~AZ8_812)
|(AZ8_91~AZ8_92~AZ8_93~AZ8_94~AZ8_95~AZ8_96~AZ8_97~AZ8_98~AZ8_99~AZ8_910~AZ8_911~AZ8_912)
|(AZ8_101~AZ8_102~AZ8_103~AZ8_104~AZ8_105~AZ8_106~AZ8_107~AZ8_108~AZ8_109~AZ8_1010~AZ8_1011~AZ8_1012)
|(AZ8_111~AZ8_112~AZ8_113~AZ8_114~AZ8_115~AZ8_116~AZ8_117~AZ8_118~AZ8_119~AZ8_1110~AZ8_1111~AZ8_1112)
|(AZ8_121~AZ8_122~AZ8_123~AZ8_124~AZ8_125~AZ8_126~AZ8_127~AZ8_128~AZ8_129~AZ8_1210~AZ8_1211~AZ8_1212);
AZ9_matrix=
(AZ9_11~AZ9_12~AZ9_13~AZ9_14~AZ9_15~AZ9_16~AZ9_17~AZ9_18~AZ9_19~AZ9_110~AZ9_111~AZ9_112)
|(AZ9_21~AZ9_22~AZ9_23~AZ9_24~AZ9_25~AZ9_26~AZ9_27~AZ9_28~AZ9_29~AZ9_210~AZ9_211~AZ9_212)
|(AZ9_31~AZ9_32~AZ9_33~AZ9_34~AZ9_35~AZ9_36~AZ9_37~AZ9_38~AZ9_39~AZ9_310~AZ9_311~AZ9_312)
|(AZ9_41~AZ9_42~AZ9_43~AZ9_44~AZ9_45~AZ9_46~AZ9_47~AZ9_48~AZ9_49~AZ9_410~AZ9_411~AZ9_412)
|(AZ9_51~AZ9_52~AZ9_53~AZ9_54~AZ9_55~AZ9_56~AZ9_57~AZ9_58~AZ9_59~AZ9_510~AZ9_511~AZ9_512)
|(AZ9_61~AZ9_62~AZ9_63~AZ9_64~AZ9_65~AZ9_66~AZ9_67~AZ9_68~AZ9_69~AZ9_610~AZ9_611~AZ9_612)
|(AZ9_71~AZ9_72~AZ9_73~AZ9_74~AZ9_75~AZ9_76~AZ9_77~AZ9_78~AZ9_79~AZ9_710~AZ9_711~AZ9_712)
|(AZ9_81~AZ9_82~AZ9_83~AZ9_84~AZ9_85~AZ9_86~AZ9_87~AZ9_88~AZ9_89~AZ9_810~AZ9_811~AZ9_812)
|(AZ9_91~AZ9_92~AZ9_93~AZ9_94~AZ9_95~AZ9_96~AZ9_97~AZ9_98~AZ9_99~AZ9_910~AZ9_911~AZ9_912)
|(AZ9_101~AZ9_102~AZ9_103~AZ9_104~AZ9_105~AZ9_106~AZ9_107~AZ9_108~AZ9_109~AZ9_1010~AZ9_1011~AZ9_1012)
|(AZ9_111~AZ9_112~AZ9_113~AZ9_114~AZ9_115~AZ9_116~AZ9_117~AZ9_118~AZ9_119~AZ9_1110~AZ9_1111~AZ9_1112)
|(AZ9_121~AZ9_122~AZ9_123~AZ9_124~AZ9_125~AZ9_126~AZ9_127~AZ9_128~AZ9_129~AZ9_1210~AZ9_1211~AZ9_1212);
endif;
util=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;
numerador=ln(suma_gastos[i])-precios_matrix[i,.]*(w_matrix[i,.]')+(1/2)*(
Z1[i]*precios_matrix[i,.]*AZ1_matrix*(precios_matrix[i,.]')	
+Z2[i]*precios_matrix[i,.]*AZ2_matrix*(precios_matrix[i,.]')	
+Z3[i]*precios_matrix[i,.]*AZ3_matrix*(precios_matrix[i,.]')
+Z4[i]*precios_matrix[i,.]*AZ4_matrix*(precios_matrix[i,.]')
+Z5[i]*precios_matrix[i,.]*AZ5_matrix*(precios_matrix[i,.]')
+Z6[i]*precios_matrix[i,.]*AZ6_matrix*(precios_matrix[i,.]')
+Z7[i]*precios_matrix[i,.]*AZ7_matrix*(precios_matrix[i,.]')
+Z8[i]*precios_matrix[i,.]*AZ8_matrix*(precios_matrix[i,.]')	
+Z9[i]*precios_matrix[i,.]*AZ9_matrix*(precios_matrix[i,.]'));
denominador=1-(1/2)*precios_matrix[i,.]*B_matrix*(precios_matrix[i,.]');
util[i]=numerador/denominador;	
i=i+1;
endo;
if rr .eq 1;
parametros=beta_1|beta_2|beta_3|beta_4|beta_5|beta_6|beta_7|beta_8|beta_9|beta_10|beta_11;	
else;
parametros=parametros~(beta_1|beta_2|beta_3|beta_4|beta_5|beta_6|beta_7|beta_8|beta_9|beta_10|beta_11);
endif;
crittt_low=0.01;
crittt_up=0.01;
/*DESCRIPCION DE LAS CARACTERISTICAS DE LOS HOGARES EN EL ARCHIVO DE CONCENTRADO HOGARES*/ 
/*1	folioviv
2	ubica_geo
3	tam_loc
4	est_socio
5	est_dis
6	upm
7	factor_hog
8	clase_hog
9	sexo_jefe
10	edad_jefe
11	educa_jefe
12	tot_integ
13	hombres
14	mujeres
15	mayores
16	menores
17	p12_64
18	p65mas
19	ocupados
20	percep_ing
21	perc_ocupa
22	ing_total
23	ing_cor
24	ing_mon
25	trabajo
26	sueldos
27	horas_extr
28	comisiones
29	otra_rem
30	negocio
31	noagrop
32	industria
33	comercio
34	servicios
35	agrope
36	agricolas
37	pecuarios
38	reproducc
39	pesca
40	otros_trab
41	rentas
42	utilidad
43	arrenda
44	transfer
45	jubilacion
46	becas
47	donativos
48	remesas
49	bene_gob
50	otros_ing
51	gasto_nom
52	autoconsum
53	remu_espec
54	transf_esp
55	transf_hog
56	trans_inst
57	estim_alqu
58	percep_tot
59	percep_mon
60	retiro_inv
61	prestamos
62	otras_perc
63	erogac_nom
64	gasto_tot
65	gasto_cor
66	gasto_mon
67	alimentos
68	ali_dentro
69	cereales
70	carnes
71	pescado
72	leche
73	huevo
74	aceites
75	tuberculo
76	verduras
77	frutas
78	azucar
79	cafe
80	especias
81	otros_alim
82	bebidas
83	ali_fuera
84	tabaco
85	vesti_calz
86	vestido
87	calzado
88	vivienda
89	alquiler
90	pred_cons
91	agua
92	energia
93	limpieza
94	cuidados
95	utensilios
96	enseres
97	salud
98	atenc_ambu
99	hospital
100	medicinas
101	transporte
102	publico
103	foraneo
104	adqui_vehi
105	mantenim
106	refaccion
107	combus
108	comunica
109	educa_espa
110	educacion
111	esparci
112	paq_turist
113	personales
114	cuida_pers
115	acces_pers
116	otros_gas
117	transf_gas
118	erogac_tot
119	erogac_mon
120	cuota_viv
121	mater_serv
122	material
123	servicio
124	deposito
125	prest_terc
126	pago_tarje
127	deudas
128	balance
129	otras_erog
130	smg
131	entidad_federativa
132	clave_municipio
133	clave_localidad*/
precio_1=selif(precio_1, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_2=selif(precio_2, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_3=selif(precio_3, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_4=selif(precio_4, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_5=selif(precio_5, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_6=selif(precio_6, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_7=selif(precio_7, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_8=selif(precio_8, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_9=selif(precio_9, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_10=selif(precio_10, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_11=selif(precio_11, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_12=selif(precio_12, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
precio_autobus_foraneo=selif(precio_autobus_foraneo, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low))); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
precio_transporte_aereo=selif(precio_transporte_aereo, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low))); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
precios_matrix=precio_1~precio_2~precio_3~precio_4~precio_5~precio_6~precio_7~precio_8~precio_9~precio_10~precio_11~precio_12;
Z1=selif(Z1, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z2=selif(Z2, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z3=selif(Z3, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z4=selif(Z4, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z5=selif(Z5, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z6=selif(Z6, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z7=selif(Z7, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z8=selif(Z8, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z9=selif(Z9, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
Z_vars=Z1~Z2~Z3~Z4~Z5~Z6~Z7~Z8~Z9;
q_1=precio_1-precio_12;
q_2=precio_2-precio_12;
q_3=precio_3-precio_12;
q_4=precio_4-precio_12;
q_5=precio_5-precio_12;
q_6=precio_6-precio_12;
q_7=precio_7-precio_12;
q_8=precio_8-precio_12;
q_9=precio_9-precio_12;
q_10=precio_10-precio_12;
q_11=precio_11-precio_12;
vars_concentrado_hogares=selif(vars_concentrado_hogares, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
ciudad_46_mas_cercana=selif(ciudad_46_mas_cercana, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
num_hogares=rows(vars_concentrado_hogares);
gasto_1=selif(gasto_1, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_2=selif(gasto_2, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_3=selif(gasto_3, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_4=selif(gasto_4, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_5=selif(gasto_5, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_6=selif(gasto_6, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_7=selif(gasto_7, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_8=selif(gasto_8, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_9=selif(gasto_9, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_10=selif(gasto_10, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_11=selif(gasto_11, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_12=selif(gasto_12, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
gasto_autobus_foraneo=selif(gasto_autobus_foraneo, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low))); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
gasto_transporte_aereo=selif(gasto_transporte_aereo, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low))); /*NUEVO CODIGO AGREGADO ENERO 6 2016*/
gastos_matrix=gasto_1~gasto_2~gasto_3~gasto_4~gasto_5~gasto_6~gasto_7~gasto_8~gasto_9~gasto_10~gasto_11~gasto_12;
suma_gastos=gasto_1+gasto_2+gasto_3+gasto_4+gasto_5+gasto_6+gasto_7+gasto_8+gasto_9+gasto_10+gasto_11+gasto_12;
w_1=gasto_1./suma_gastos;
w_2=gasto_2./suma_gastos;
w_3=gasto_3./suma_gastos;
w_4=gasto_4./suma_gastos;
w_5=gasto_5./suma_gastos;
w_6=gasto_6./suma_gastos;
w_7=gasto_7./suma_gastos;
w_8=gasto_8./suma_gastos;
w_9=gasto_9./suma_gastos;
w_10=gasto_10./suma_gastos;
w_11=gasto_11./suma_gastos;
w_12=gasto_12./suma_gastos;
w_matrix=w_1~w_2~w_3~w_4~w_5~w_6~w_7~w_8~w_9~w_10~w_11~w_12;
epsilon_matrix=selif(epsilon_matrix, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
pordebajo_decil_50_hogares=(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.50));
decil_10_hogares=(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.10));
decil_20_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.10)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.20));
decil_30_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.20)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.30));
decil_40_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.30)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.40));
decil_50_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.40)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.50));
decil_60_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.50)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.60));
decil_70_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.60)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.70));
decil_80_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.70)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.80));
decil_90_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.80)).*(vars_concentrado_hogares[.,22] .le quantile(vars_concentrado_hogares[.,22], 0.90));
decil_100_hogares=(vars_concentrado_hogares[.,22] .ge quantile(vars_concentrado_hogares[.,22], 0.90));
util=selif(util, (util .le quantile(util, 1-crittt_up)).*(util .ge quantile(util, crittt_low)));
rr=rr+1;
endo;
tt=2;
do while tt .le cols(parametros);
if tt .eq 2;
criterio=sqrt((parametros[.,tt]-parametros[.,tt-1])'*(parametros[.,tt]-parametros[.,tt-1]))/sqrt(parametros[.,tt-1]'*parametros[.,tt-1]);
else;
criterio=criterio|sqrt((parametros[.,tt]-parametros[.,tt-1])'*(parametros[.,tt]-parametros[.,tt-1]))/sqrt(parametros[.,tt-1]'*parametros[.,tt-1]);	
endif;
tt=tt+1;
endo;
util_indirecta_original=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;

proc indirect_utility_original(x);
local m_u_z, T_p_z, S_p_z;
local u, criterio;

u=x[1];
	
m_u_z=b0_vector+b1_vector*u+b2_vector*u^2+b3_vector*u^3+C_matrix*(Z_vars[i,.]')+D_matrix*(Z_vars[i,.]'*u);	

T_p_z=(1/2)*(
Z1[i]*precios_matrix[i,.]*AZ1_matrix*(precios_matrix[i,.]')	
+Z2[i]*precios_matrix[i,.]*AZ2_matrix*(precios_matrix[i,.]')	
+Z3[i]*precios_matrix[i,.]*AZ3_matrix*(precios_matrix[i,.]')
+Z4[i]*precios_matrix[i,.]*AZ4_matrix*(precios_matrix[i,.]')
+Z5[i]*precios_matrix[i,.]*AZ5_matrix*(precios_matrix[i,.]')
+Z6[i]*precios_matrix[i,.]*AZ6_matrix*(precios_matrix[i,.]')
+Z7[i]*precios_matrix[i,.]*AZ7_matrix*(precios_matrix[i,.]')
+Z8[i]*precios_matrix[i,.]*AZ8_matrix*(precios_matrix[i,.]')	
+Z9[i]*precios_matrix[i,.]*AZ9_matrix*(precios_matrix[i,.]')); 	
	
S_p_z=(1/2)*precios_matrix[i,.]*B_matrix*(precios_matrix[i,.]');	

criterio=(ln(suma_gastos[i])-(u+precios_matrix[i,.]*m_u_z+T_p_z+S_p_z*u+precios_matrix[i,.]*(epsilon_matrix[i,.]')))^2;

retp(criterio);
endp;

xx00=util[i];
{XXXX, FFFF, GGGG, RETTTCODE}=optmum(&indirect_utility_original,xx00);

util_indirecta_original[i]=XXXX;

i=i+1;
endo;

demandas_marshal_original=zeros(num_hogares,12);
w_hat_original=zeros(num_hogares,12);

i=1;
do while i .le num_hogares;

u=util_indirecta_original[i];
	
m_u_z=b0_vector+b1_vector*u+b2_vector*u^2+b3_vector*u^3+C_matrix*(Z_vars[i,.]')+D_matrix*(Z_vars[i,.]'*u);	

Dp_T_p_z=
Z1[i]*AZ1_matrix*(precios_matrix[i,.]')	
+Z2[i]*AZ2_matrix*(precios_matrix[i,.]')	
+Z3[i]*AZ3_matrix*(precios_matrix[i,.]')
+Z4[i]*AZ4_matrix*(precios_matrix[i,.]')
+Z5[i]*AZ5_matrix*(precios_matrix[i,.]')
+Z6[i]*AZ6_matrix*(precios_matrix[i,.]')
+Z7[i]*AZ7_matrix*(precios_matrix[i,.]')
+Z8[i]*AZ8_matrix*(precios_matrix[i,.]')	
+Z9[i]*AZ9_matrix*(precios_matrix[i,.]'); 	
	
Dp_S_p_z=B_matrix*(precios_matrix[i,.]');	
w_marshal=m_u_z+Dp_T_p_z+Dp_S_p_z*u+epsilon_matrix[i,.]';
w_marshal=maxc((w_marshal~zeros(12,1))');	
w_marshal=w_marshal/sumc(w_marshal);
w_hat_original[i,.]=w_marshal';	
demandas_marshal_original[i,.]=(diagrv(eye(12),(1/exp(precios_matrix[i,.]')))*w_marshal*suma_gastos[i])';
i=i+1;
endo;

elastic_46_ciudades_matrix=zeros(46,14);
elastic_46_ciudades_matrix_fin=zeros(46,14);
elastic_agregadas_vector=zeros(14,1);
t_stat_factor_elasticidad_vector=zeros(14,1);
beta_factor_elasticidad_vector=zeros(14,1);
SE_factor_elasticidad_vector=zeros(14,1);
factor_contrafactual=1.25;
/*
1.-	FECHA (AAAA.MM)
2.-	CLAVE ESTADO
3.-	CLAVE MUNICIPIO
4.-	LATITUD (EN GRADOS)
5.-	LONGITUD (EN GRADOS)
6.-	TORTILLA
7.-	PAN DULCE
8.-	PAN BLANCO
9.-	POLLO
10.-CARNE DE RES
11.-VISCERAS DE RES
12.-CHORIZO
13.-JAMON
14.-SALCHICHAS
15.-TOCINO
16.-LECHE PASTEURIZADA
17.-LECHE EN POLVO
18.-LECHE EVAPORADA Y CONDENSADA
19.-QUESO FRESCO
20.-QUESO OAXACA
21.-CREMA DE LECHE
22.-QUESO MANCHEGO
23.-MANTEQUILLA
24.-QUESO AMARILLO
25.-HUEVO
26.-MANZANA
27.-PLATANOS
28.-AGUACATE
29.-PAPAYA
30.-NARANJA
31.-LIMON
32.-MELON
33.-UVA
34.-PERA
35.-GUAYABA
36.-DURAZNO
37.-SANDIA
38.-PINA
39.-JITOMATE
40.-PAPA
41.-CEBOLLA
42.-TOMATE VERDE
43.-LECHUGA Y COL
44.-CALABACITA
45.-ZANAHORIA
46.-CHILE SERRANO
47.-NOPALES
48.-CHAYOTE
49.-CHILE POBLANO
50.-PEPINO
51.-EJOTES
52.-CHICHARO
53.-FRIJOL
54.-JUGOS Y NECTARES
55.-REFRESCOS
56.-AGUA EMBOTELLADA
57.-ANTIBIOTICOS
58.-CARDIOVASCULARES
59.-ANALGESICOS
60.-NUTRICIONALES
61.-GASTROINTESTINALES
62.-ANTIGRIPALES
63.-MEDICINA PARA LA TOS
64.-MEDICINAS PARA LA PIEL
65.-AUTOBUS FORANEO
66.-TRANSPORTE AEREO*/
/* 1.- TORTILLAS (1 producto)*/
/* 2.- PAN (2 productos)*/
/* 3.- POLLO Y HUEVO (3 productos)*/
/* 4.- CARNE DE RES (3 productos)*/
/* 5.- CARNES PROCESADAS (4 productos)*/
/* 6.- LACTEOS (9 productos)*/
/* 7.- FRUTAS (11 productos)*/
/* 8.- VERDURAS (17 productos)*/
/* 9.- BEBIDAS (3 productos)*/
/* 10.- MEDICAMENTOS (8 productos)*/
/* 11.- TRANSPORTE FORANEO (2 productos)*/
/* 12.- MATERIALES DE CONSTRUCCION (1 producto agregado)*/
w_autobus_foraneo=gasto_autobus_foraneo./(gasto_autobus_foraneo+gasto_transporte_aereo);
w_transporte_aereo=gasto_transporte_aereo./(gasto_autobus_foraneo+gasto_transporte_aereo);
w_bar_autobus_foraneo=meanc(w_autobus_foraneo);
w_bar_transporte_aereo=meanc(w_transporte_aereo);
k_TRANSPORTE=(w_bar_autobus_foraneo.^(-w_bar_autobus_foraneo)).*(w_bar_transporte_aereo.^(-w_bar_transporte_aereo));
prec_orig_transporte_foraneo=(1/k_TRANSPORTE)*((precio_autobus_foraneo./w_autobus_foraneo).^w_autobus_foraneo)
.*((precio_transporte_aereo./w_transporte_aereo).^w_transporte_aereo);
prec_contraf_aereo=(1/k_TRANSPORTE)*((precio_autobus_foraneo./w_autobus_foraneo).^w_autobus_foraneo)
.*(((precio_transporte_aereo*factor_contrafactual)./w_transporte_aereo).^w_transporte_aereo);
factor_contrafactual_aereo=prec_contraf_aereo./prec_orig_transporte_foraneo;
prec_contraf_foraneo=(1/k_TRANSPORTE)*(((precio_autobus_foraneo*factor_contrafactual)./w_autobus_foraneo).^w_autobus_foraneo)
.*(((precio_transporte_aereo)./w_transporte_aereo).^w_transporte_aereo);
factor_contrafactual_foraneo=prec_contraf_foraneo./prec_orig_transporte_foraneo; /*TERMINA NUEVO CODIGO AGREGADO ENERO 6 2016*/
pfp=1;
do while pfp .le 14;
categ_counterf=pfp; 
/* 1.- TORTILLAS (1 producto)*/
/* 2.- PAN (2 productos)*/
/* 3.- POLLO Y HUEVO (3 productos)*/
/* 4.- CARNE DE RES (3 productos)*/
/* 5.- CARNES PROCESADAS (4 productos)*/
/* 6.- LACTEOS (9 productos)*/
/* 7.- FRUTAS (11 productos)*/
/* 8.- VERDURAS (17 productos)*/
/* 9.- BEBIDAS (3 productos)*/
/* 10.- MEDICAMENTOS (8 productos)*/
/* 11.- TRANSPORTE FORANEO (2 productos)*/
/* 12.- MATERIALES DE CONSTRUCCION (1 producto agregado)*/

if pfp .ge 13;
categ_counterf=11;
endif;  
if pfp .eq 13;
factor_contrafactual=factor_contrafactual_aereo;
endif;
if pfp .eq 14;
factor_contrafactual=factor_contrafactual_foraneo;
endif;

if categ_counterf .eq 1;
precios_matrix_contrafactual=precios_matrix+(ones(num_hogares,1).*ln(factor_contrafactual)~zeros(num_hogares,11));
elseif categ_counterf .lt 12;
precios_matrix_contrafactual=precios_matrix+(zeros(num_hogares,categ_counterf-1)~ones(num_hogares,1).*ln(factor_contrafactual)~zeros(num_hogares,12-categ_counterf));
elseif categ_counterf .eq 12;
precios_matrix_contrafactual=precios_matrix+(zeros(num_hogares,11)~ones(num_hogares,1).*ln(factor_contrafactual));
else;
precios_matrix_contrafactual=precios_matrix+(zeros(num_hogares,categ_counterf-1)~ones(num_hogares,1).*ln(factor_contrafactual)~zeros(num_hogares,12-categ_counterf));
endif;


util_indirecta_contrafactual=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;

proc indirect_utility_contrafactual(x);
local m_u_z, T_p_z, S_p_z;
local u, criterio;

u=x[1];
	
m_u_z=b0_vector+b1_vector*u+b2_vector*u^2+b3_vector*u^3+C_matrix*(Z_vars[i,.]')+D_matrix*(Z_vars[i,.]'*u);	

T_p_z=(1/2)*(
Z1[i]*precios_matrix_contrafactual[i,.]*AZ1_matrix*(precios_matrix_contrafactual[i,.]')	
+Z2[i]*precios_matrix_contrafactual[i,.]*AZ2_matrix*(precios_matrix_contrafactual[i,.]')	
+Z3[i]*precios_matrix_contrafactual[i,.]*AZ3_matrix*(precios_matrix_contrafactual[i,.]')
+Z4[i]*precios_matrix_contrafactual[i,.]*AZ4_matrix*(precios_matrix_contrafactual[i,.]')
+Z5[i]*precios_matrix_contrafactual[i,.]*AZ5_matrix*(precios_matrix_contrafactual[i,.]')
+Z6[i]*precios_matrix_contrafactual[i,.]*AZ6_matrix*(precios_matrix_contrafactual[i,.]')
+Z7[i]*precios_matrix_contrafactual[i,.]*AZ7_matrix*(precios_matrix_contrafactual[i,.]')
+Z8[i]*precios_matrix_contrafactual[i,.]*AZ8_matrix*(precios_matrix_contrafactual[i,.]')	
+Z9[i]*precios_matrix_contrafactual[i,.]*AZ9_matrix*(precios_matrix_contrafactual[i,.]')); 	
	
S_p_z=(1/2)*precios_matrix_contrafactual[i,.]*B_matrix*(precios_matrix_contrafactual[i,.]');	

criterio=(ln(suma_gastos[i])-(u+precios_matrix_contrafactual[i,.]*m_u_z+T_p_z+S_p_z*u+precios_matrix_contrafactual[i,.]*(epsilon_matrix[i,.]')))^2;

retp(criterio);
endp;

xx00=util_indirecta_original[i];
{XXXX, FFFF, GGGG, RETTTCODE}=optmum(&indirect_utility_contrafactual,xx00);

util_indirecta_contrafactual[i]=XXXX;

i=i+1;
endo;
util_indirecta_contrafactual=util_indirecta_contrafactual.*(util_indirecta_contrafactual .le util_indirecta_original)+
util_indirecta_original.*(util_indirecta_contrafactual .gt util_indirecta_original);
demandas_marshal_contrafactual=zeros(num_hogares,12);
w_hat_contrafactual=zeros(num_hogares,12);

i=1;
do while i .le num_hogares;

u=util_indirecta_contrafactual[i];
	
m_u_z=b0_vector+b1_vector*u+b2_vector*u^2+b3_vector*u^3+C_matrix*(Z_vars[i,.]')+D_matrix*(Z_vars[i,.]'*u);	

Dp_T_p_z=
Z1[i]*AZ1_matrix*(precios_matrix_contrafactual[i,.]')	
+Z2[i]*AZ2_matrix*(precios_matrix_contrafactual[i,.]')	
+Z3[i]*AZ3_matrix*(precios_matrix_contrafactual[i,.]')
+Z4[i]*AZ4_matrix*(precios_matrix_contrafactual[i,.]')
+Z5[i]*AZ5_matrix*(precios_matrix_contrafactual[i,.]')
+Z6[i]*AZ6_matrix*(precios_matrix_contrafactual[i,.]')
+Z7[i]*AZ7_matrix*(precios_matrix_contrafactual[i,.]')
+Z8[i]*AZ8_matrix*(precios_matrix_contrafactual[i,.]')	
+Z9[i]*AZ9_matrix*(precios_matrix_contrafactual[i,.]'); 	
	
Dp_S_p_z=B_matrix*(precios_matrix_contrafactual[i,.]');	
	
w_marshal=m_u_z+Dp_T_p_z+Dp_S_p_z*u+epsilon_matrix[i,.]';
w_marshal=maxc((w_marshal~zeros(12,1))');	
w_marshal=w_marshal/sumc(w_marshal);
w_hat_contrafactual[i,.]=w_marshal';
demandas_marshal_contrafactual[i,.]=(diagrv(eye(12),(1/exp(precios_matrix_contrafactual[i,.]')))*w_marshal*suma_gastos[i])';
i=i+1;
endo;


util_EASI_original=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;
T_p_z=(1/2)*(
Z1[i]*precios_matrix[i,.]*AZ1_matrix*(precios_matrix[i,.]')	
+Z2[i]*precios_matrix[i,.]*AZ2_matrix*(precios_matrix[i,.]')	
+Z3[i]*precios_matrix[i,.]*AZ3_matrix*(precios_matrix[i,.]')
+Z4[i]*precios_matrix[i,.]*AZ4_matrix*(precios_matrix[i,.]')
+Z5[i]*precios_matrix[i,.]*AZ5_matrix*(precios_matrix[i,.]')
+Z6[i]*precios_matrix[i,.]*AZ6_matrix*(precios_matrix[i,.]')
+Z7[i]*precios_matrix[i,.]*AZ7_matrix*(precios_matrix[i,.]')
+Z8[i]*precios_matrix[i,.]*AZ8_matrix*(precios_matrix[i,.]')	
+Z9[i]*precios_matrix[i,.]*AZ9_matrix*(precios_matrix[i,.]'));	

S_p_z=(1/2)*precios_matrix[i,.]*B_matrix*(precios_matrix[i,.]');	
	
numerador=ln(suma_gastos[i])-precios_matrix[i,.]*(w_matrix[i,.]')+T_p_z;
	
denominador=1-S_p_z;	

util_EASI_original[i]=numerador/denominador; /*Utilidad EASI a los precios originales (para la Variacion Compensada o VC)*/

i=i+1;
endo;	


T_p_z_original=zeros(num_hogares,1);
T_p_z_contrafactual=zeros(num_hogares,1);

S_p_z_original=zeros(num_hogares,1);
S_p_z_contrafactual=zeros(num_hogares,1);

m_u_z_original=zeros(num_hogares,12);

VC_costo_original=zeros(num_hogares,1);
VC_costo_contrafactual=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;
u=util_EASI_original[i];

m_u_z_original[i,.]=(b0_vector+b1_vector*u+b2_vector*u^2+b3_vector*u^3+C_matrix*(Z_vars[i,.]')+D_matrix*(Z_vars[i,.]'*u))';	
	
T_p_z_original[i]=(1/2)*(
Z1[i]*precios_matrix[i,.]*AZ1_matrix*(precios_matrix[i,.]')	
+Z2[i]*precios_matrix[i,.]*AZ2_matrix*(precios_matrix[i,.]')	
+Z3[i]*precios_matrix[i,.]*AZ3_matrix*(precios_matrix[i,.]')
+Z4[i]*precios_matrix[i,.]*AZ4_matrix*(precios_matrix[i,.]')
+Z5[i]*precios_matrix[i,.]*AZ5_matrix*(precios_matrix[i,.]')
+Z6[i]*precios_matrix[i,.]*AZ6_matrix*(precios_matrix[i,.]')
+Z7[i]*precios_matrix[i,.]*AZ7_matrix*(precios_matrix[i,.]')
+Z8[i]*precios_matrix[i,.]*AZ8_matrix*(precios_matrix[i,.]')	
+Z9[i]*precios_matrix[i,.]*AZ9_matrix*(precios_matrix[i,.]'));	

S_p_z_original[i]=(1/2)*precios_matrix[i,.]*B_matrix*(precios_matrix[i,.]');	
i=i+1;
endo;	


i=1;
do while i .le num_hogares;
u=util_EASI_original[i]; 
VC_costo_original[i]=u+precios_matrix[i,.]*(m_u_z_original[i,.]')+T_p_z_original[i]+S_p_z_original[i]*u+precios_matrix[i,.]*(epsilon_matrix[i,.]');
	
i=i+1;
endo;


i=1;
do while i .le num_hogares;
T_p_z_contrafactual[i]=(1/2)*(
Z1[i]*precios_matrix_contrafactual[i,.]*AZ1_matrix*(precios_matrix_contrafactual[i,.]')	
+Z2[i]*precios_matrix_contrafactual[i,.]*AZ2_matrix*(precios_matrix_contrafactual[i,.]')	
+Z3[i]*precios_matrix_contrafactual[i,.]*AZ3_matrix*(precios_matrix_contrafactual[i,.]')
+Z4[i]*precios_matrix_contrafactual[i,.]*AZ4_matrix*(precios_matrix_contrafactual[i,.]')
+Z5[i]*precios_matrix_contrafactual[i,.]*AZ5_matrix*(precios_matrix_contrafactual[i,.]')
+Z6[i]*precios_matrix_contrafactual[i,.]*AZ6_matrix*(precios_matrix_contrafactual[i,.]')
+Z7[i]*precios_matrix_contrafactual[i,.]*AZ7_matrix*(precios_matrix_contrafactual[i,.]')
+Z8[i]*precios_matrix_contrafactual[i,.]*AZ8_matrix*(precios_matrix_contrafactual[i,.]')	
+Z9[i]*precios_matrix_contrafactual[i,.]*AZ9_matrix*(precios_matrix_contrafactual[i,.]'));	

S_p_z_contrafactual[i]=(1/2)*precios_matrix_contrafactual[i,.]*B_matrix*(precios_matrix_contrafactual[i,.]');	
i=i+1;
endo;

T_p_z_contrafactual=T_p_z_contrafactual.*(T_p_z_contrafactual .ge T_p_z_original)+T_p_z_original.*(T_p_z_contrafactual .lt T_p_z_original);
S_p_z_contrafactual=S_p_z_contrafactual.*(S_p_z_contrafactual .ge S_p_z_original)+S_p_z_original.*(S_p_z_contrafactual .lt S_p_z_original);


i=1;
do while i .le num_hogares;
u=util_EASI_original[i]; 
VC_costo_contrafactual[i]=u+precios_matrix_contrafactual[i,.]*(m_u_z_original[i,.]')+T_p_z_contrafactual[i]+S_p_z_contrafactual[i]*u+precios_matrix_contrafactual[i,.]*(epsilon_matrix[i,.]');

	
i=i+1;
endo;


demanda_matrix_original=(demandas_marshal_original[.,categ_counterf]).*(ciudad_46_mas_cercana .eq numerador_46_ciudades');
demanda_matrix_contrafactual=(demandas_marshal_contrafactual[.,categ_counterf]).*(ciudad_46_mas_cercana .eq numerador_46_ciudades');

aux_dem_original=demanda_matrix_original.*(demanda_matrix_contrafactual .le demanda_matrix_original);

aux_dem_contrafactual=demanda_matrix_contrafactual.*(demanda_matrix_contrafactual .le demanda_matrix_original);

elastic_demanda_46_ciudades=(ln(sumc(demanda_matrix_contrafactual))-ln(sumc(demanda_matrix_original)))/ln(meanc(factor_contrafactual));

elastic_demanda_46_ciudades_bis=(ln(sumc(aux_dem_contrafactual))-ln(sumc(aux_dem_original)))/ln(meanc(factor_contrafactual));

jjii=1;
do while jjii .le 46;
if elastic_demanda_46_ciudades[jjii] .le 0;
elastic_demanda_46_ciudades[jjii]=elastic_demanda_46_ciudades[jjii];
else;
elastic_demanda_46_ciudades[jjii]=0;
endif;
if elastic_demanda_46_ciudades[jjii] .gt -10^10;
elastic_demanda_46_ciudades[jjii]=elastic_demanda_46_ciudades[jjii];
else;
elastic_demanda_46_ciudades[jjii]=0;
endif;
jjii=jjii+1;
endo;

elastic_46_ciudades_matrix[.,pfp]=elastic_demanda_46_ciudades;
elastic_46_ciudades_matrix_fin[.,pfp]=elastic_demanda_46_ciudades_bis;

demanda_agregada_original=(demandas_marshal_original[.,categ_counterf]);
demanda_agregada_contrafactual=(demandas_marshal_contrafactual[.,categ_counterf]);

aux_dem_agregada_original=selif(demanda_agregada_original, demanda_agregada_contrafactual .le demanda_agregada_original);
aux_dem_agregada_contrafactual=selif(demanda_agregada_contrafactual, demanda_agregada_contrafactual .le demanda_agregada_original);

elastic_agregadas_vector[pfp]=(ln(sumc(aux_dem_agregada_contrafactual))-ln(sumc(aux_dem_agregada_original)))/ln(meanc(factor_contrafactual));


load poblacion_total_46_ciudades[46,1]=poblacion_46_ciudades_CENSO_2010.asc; 

poblacion_total_46_ciudades=poblacion_total_46_ciudades/1000; 


load variables_costos_2014[46,11]=indicadores_costos_censos_economicos_2014.asc; 
unidades_economicas=variables_costos_2014[.,10];
empleados_por_UE=variables_costos_2014[.,1]./unidades_economicas;
empleados_remunerados_por_UE=variables_costos_2014[.,2]./unidades_economicas;
remuneraciones_por_UE=variables_costos_2014[.,3]./unidades_economicas;
produccion_bruta_por_UE=variables_costos_2014[.,4]./unidades_economicas;
consumo_intermedio_por_UE=variables_costos_2014[.,5]./unidades_economicas;
activos_fijos_por_UE=variables_costos_2014[.,7]./unidades_economicas;
depreciacion_activos_por_UE=variables_costos_2014[.,8]./unidades_economicas;
total_gastos_por_UE=variables_costos_2014[.,11]./unidades_economicas;
valor_agregado_por_empleado=variables_costos_2014[.,6]./variables_costos_2014[.,1];
valor_agregado_por_activos=variables_costos_2014[.,6]./variables_costos_2014[.,7];
valor_agregado_por_unidad=variables_costos_2014[.,6]./variables_costos_2014[.,10];


vars_costos=ln(unidades_economicas)~empleados_por_UE~remuneraciones_por_UE~produccion_bruta_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=total_gastos_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=ln(total_gastos_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE);
vars_costos=ln(empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE);
vars_costos=empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=empleados_remunerados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=unidades_economicas~empleados_remunerados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=produccion_bruta_por_UE~empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=produccion_bruta_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~depreciacion_activos_por_UE;
vars_costos=produccion_bruta_por_UE~empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;
vars_costos=produccion_bruta_por_UE~unidades_economicas~empleados_por_UE~remuneraciones_por_UE~consumo_intermedio_por_UE~activos_fijos_por_UE~depreciacion_activos_por_UE;

/*1.- TORTILLAS*/
precio_promedio_tortillas=P_46_tortillas_2014;

/*2.- PAN*/
precio_promedio_pan=sumc((P_46_pan_blanco_2014*meanc(w_pan_blanco)~P_46_pan_dulce_2014*meanc(w_pan_dulce))');

/*3.- POLLO Y HUEVO*/
precio_promedio_pollo_huevo=sumc((P_46_pollo_entero_2014*meanc(w_pollo_entero)~P_46_pollo_piezas_2014*meanc(w_pollo_piezas)
~P_46_huevo_2014*meanc(w_huevo))');

/*4.- CARNE DE RES*/
precio_promedio_carne_res=sumc((P_46_bistec_res_2014*meanc(w_bistec_res)~P_46_molida_res_2014*meanc(w_molida_res)~
P_46_visceras_res_2014*meanc(w_visceras_res))');

/*5.- CARNES PROCESADAS*/
precio_promedio_carnes_proc=sumc((P_46_chorizo_2014*meanc(w_chorizo)~P_46_jamon_2014*meanc(w_jamon)~
P_46_salchichas_2014*meanc(w_salchichas)~P_46_tocino_2014*meanc(w_tocino))');

/*6.- LACTEOS*/
precio_promedio_lacteos=sumc((P_46_leche_pasteurizada_2014*meanc(w_leche_pasteur)~P_46_leche_en_polvo_2014*meanc(w_leche_en_polvo)~
P_46_leche_maternizada_2014*meanc(w_leche_maternizada)~P_46_leche_condensada_2014*meanc(w_leche_condensada)~
P_46_queso_fresco_2014*meanc(w_queso_fresco)~P_46_queso_oaxaca_2014*meanc(w_queso_oaxaca)~P_46_queso_amarillo_2014*meanc(w_queso_amarillo)
~P_46_crema_de_leche_2014*meanc(w_crema_leche)~P_46_mantequilla_2014*meanc(w_mantequilla))');

/* 7.- FRUTAS*/
precio_promedio_frutas=sumc((P_46_manzana_2014*meanc(w_manzana)~P_46_platanos_2014*meanc(w_platano)~
P_46_aguacate_2014*meanc(w_aguacate)~P_46_papaya_2014*meanc(w_papaya)~P_46_naranja_2014*meanc(w_naranja)~
P_46_limon_2014*meanc(w_limon)~P_46_melon_2014*meanc(w_melon)~P_46_uvas_2014*meanc(w_uvas)~P_46_pera_2014*meanc(w_pera)
~P_46_guayaba_2014*meanc(w_guayaba)~P_46_sandia_2014*meanc(w_sandia)~P_46_pina_2014*meanc(w_pina))');

/*8.- VERDURAS*/
precio_promedio_verduras=sumc((P_46_jitomate_2014*meanc(w_jitomate)~P_46_papa_2014*meanc(w_papa)~P_46_cebolla_2014*meanc(w_cebolla)
~P_46_tomate_verde_2014*meanc(w_tomate_verde)~P_46_col_2014*meanc(w_col)~P_46_lechuga_2014*meanc(w_lechuga)~
P_46_calabacita_2014*meanc(w_calabacita)~P_46_zanahoria_2014*meanc(w_zanahoria)~P_46_chile_serrano_2014*meanc(w_chile_serrano)
~P_46_nopales_2014*meanc(w_nopales)~P_46_chayote_2014*meanc(w_chayote)~P_46_chile_poblano_2014*meanc(w_chile_poblano)~
P_46_pepino_2014*meanc(w_pepino)~P_46_ejotes_2014*meanc(w_ejotes)~P_46_chicharo_2014*meanc(w_chicharo)~P_46_frijol_2014*meanc(w_frijol))');

/* 9.- BEBIDAS*/
precio_promedio_bebidas=sumc((P_46_jugos_nectares_2014*meanc(w_jugos)~P_46_refrescos_envasados_2014*meanc(w_refrescos)
~P_46_agua_embotellada_2014*meanc(w_agua))');

/* 10.- MEDICAMENTOS*/
precio_promedio_medicinas=sumc((P_46_antibioticos_2014*meanc(w_antibioticos)~P_46_cardiovasculares_2014*meanc(w_cardiovasculares)
~P_46_analgesicos_2014*meanc(w_analgesicos)~P_46_nutricionales_2014*meanc(w_nutricionales)~
P_46_gastrointestinales_2014*meanc(w_gastrointestinales)~P_46_antigripales_2014*meanc(w_antigripales)
~P_46_medicinas_tos_2014*meanc(w_tos)~P_46_medicinas_piel_2014*meanc(w_dermatologicos))');

/* 11.- TRANSPORTE FORANEO*/
precio_promedio_transporte=sumc((P_46_autobus_foraneo_2014*meanc(w_autobus_foraneo)~P_46_transporte_aereo_2014*meanc(w_transporte_aereo))');

/*12.- MATERIALES*/
precio_promedio_materiales=P_46_materiales_2014;

/*13.- TRANSPORTE AEREO*/
precio_promedio_aereo=P_46_transporte_aereo_2014;

/*14.- AUTOBUS FORANEO*/
precio_promedio_foraneo=P_46_autobus_foraneo_2014;

precio_promedio_matrix=precio_promedio_tortillas~precio_promedio_pan~precio_promedio_pollo_huevo~precio_promedio_carne_res
~precio_promedio_carnes_proc~precio_promedio_lacteos~precio_promedio_frutas~precio_promedio_verduras~precio_promedio_bebidas
~precio_promedio_medicinas~precio_promedio_transporte~precio_promedio_materiales~precio_promedio_aereo~precio_promedio_foraneo;

precio_sector_analizado=precio_promedio_matrix[.,categ_counterf];

factor_elasticidad=-precio_sector_analizado.*(1/elastic_demanda_46_ciudades);

X_vars=selif(factor_elasticidad~vars_costos, elastic_demanda_46_ciudades .lt 0);

Y_var=selif(precio_sector_analizado, elastic_demanda_46_ciudades .lt 0);


N=rows(X_vars);
outlier=zeros(N,cols(X_vars));
factor_outlier=1.5;

ji=1;
do while ji .le cols(X_vars);
IQR=quantile(X_vars[.,ji],0.75)-quantile(X_vars[.,ji],0.25);	
outlier[.,ji]=
((X_vars[.,ji] .le quantile(X_vars[.,ji],0.25)-factor_outlier*IQR)+(X_vars[.,ji] .ge quantile(X_vars[.,ji],0.75)+factor_outlier*IQR) .gt 0);
ji=ji+1;
endo;

outlier=sumc(outlier');

X_vars=selif(X_vars, (outlier .eq 0));
Y_var=selif(Y_var, (outlier .eq 0));

N=rows(X_vars);

X_vars=X_vars~ones(N,1);

betas_X=inv(X_vars'*X_vars)*X_vars'*Y_var;

resid_projection=Y_var-X_vars*betas_X;

Sigma_XX=(X_vars'*X_vars)/N;

Omega_epsilon_X=(X_vars'*(X_vars.*(resid_projection^2)))/N;

var_cov_beta=inv(Sigma_XX)*Omega_epsilon_X*inv(Sigma_XX)';

t_stat_factor_elasticidad=sqrt(N)*betas_X[1]/sqrt(abs(var_cov_beta[1,1]));

t_stat_factor_elasticidad_vector[pfp]=t_stat_factor_elasticidad;

beta_factor_elasticidad_vector[pfp]=betas_X[1];

SE_factor_elasticidad_vector[pfp]=sqrt(abs(var_cov_beta[1,1]))/sqrt(N);

elastic_46_ciudades_matrix[.,pfp]=elastic_demanda_46_ciudades;

pfp=pfp+1;
endo;

factor_elasticidad_46_ciudades=precio_promedio_matrix.*(-1./elastic_46_ciudades_matrix).*(beta_factor_elasticidad_vector');
costo_marginal_46_ciudades=precio_promedio_matrix-factor_elasticidad_46_ciudades;
markup_costo_46_ciudades=precio_promedio_matrix./costo_marginal_46_ciudades;

markup_costo_46_ciudades=markup_costo_46_ciudades.*(markup_costo_46_ciudades .ge 1)+(markup_costo_46_ciudades .lt 1);
markup_costo_46_ciudades=markup_costo_46_ciudades.*(markup_costo_46_ciudades .le 5)+5*(markup_costo_46_ciudades .gt 5);

markup_promedio_46_ciudades_2014=meanc(markup_costo_46_ciudades');
median_markup_46_ciudades_2014=quantile(markup_costo_46_ciudades',0.5)';
	

markups_por_ciudad=zeros(46,14);
qrq=1;
do while qrq .le 14;
aux_average=meanc(selif(elastic_46_ciudades_matrix[.,qrq], elastic_46_ciudades_matrix[.,qrq] .lt 0));
iri=1;
do while iri .le 46;
if elastic_46_ciudades_matrix[iri,qrq] .lt 0;
markups_por_ciudad[iri,qrq]=-(1/elastic_46_ciudades_matrix[iri,qrq]);
else;
markups_por_ciudad[iri,qrq]=-(1/aux_average);
endif;
iri=iri+1;
endo;
qrq=qrq+1;
endo;

markups_por_hogar_por_ciudad=zeros(num_hogares,14);
i=1;
do while i .le num_hogares;
market=ciudad_46_mas_cercana[i];
markups_por_hogar_por_ciudad[i,.]=markup_costo_46_ciudades[market,.];
i=i+1;
endo;

 	
elastic_46_ciudades_matrix=elastic_46_ciudades_matrix.*(elastic_46_ciudades_matrix .le 0);

resumen_resultados_14=seqa(1,1,14)~t_stat_factor_elasticidad_vector~beta_factor_elasticidad_vector~(-1./meanc(elastic_46_ciudades_matrix));

resumen_resultados=resumen_resultados_14[1:12,.];
/*::::::*/
beta_factor_elastic_all=beta_factor_elasticidad_vector;
t_stat_elastic_all=t_stat_factor_elasticidad_vector;
beta_factor_elasticidad_vector=beta_factor_elasticidad_vector[1:12];

sectores_significativos=(resumen_resultados[.,2] .ge cdfni(0.99));
resultados_significativos=resumen_resultados.*sectores_significativos;
solo_resultados_significativos=selif(resultados_significativos, resultados_significativos[.,4] .gt 0);
aux_sort=sortc(solo_resultados_significativos,4);
aux_sort=aux_sort[rows(aux_sort)-(rows(aux_sort)-1),4];
cinco_mayores_markups=(resultados_significativos[.,4] .ge aux_sort);
cinco_sectores_identificados=resultados_significativos~cinco_mayores_markups;
markups_cinco_mayores=cinco_sectores_identificados[.,4].*cinco_sectores_identificados[.,5];
markups_todos_bis=markups_por_hogar_por_ciudad;
markups_cinco_mayores_bis=markups_por_hogar_por_ciudad[.,1:12].*(cinco_mayores_markups');
precios_1=precios_matrix; 
markups_estimados=1./(1+markups_cinco_mayores);
markups_estimados=ones(num_hogares,12).*markups_estimados';
markups_estimados_bis=1./((markups_cinco_mayores_bis .eq 0)+markups_cinco_mayores_bis);
precios_0=precios_matrix+ln(markups_estimados); 
precios_0_bis=precios_matrix+ln(markups_estimados_bis);
precios_0=precios_0_bis;
util_EASI_0=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;

T_p_z_0=(1/2)*(
Z1[i]*precios_0[i,.]*AZ1_matrix*(precios_0[i,.]')	
+Z2[i]*precios_0[i,.]*AZ2_matrix*(precios_0[i,.]')	
+Z3[i]*precios_0[i,.]*AZ3_matrix*(precios_0[i,.]')
+Z4[i]*precios_0[i,.]*AZ4_matrix*(precios_0[i,.]')
+Z5[i]*precios_0[i,.]*AZ5_matrix*(precios_0[i,.]')
+Z6[i]*precios_0[i,.]*AZ6_matrix*(precios_0[i,.]')
+Z7[i]*precios_0[i,.]*AZ7_matrix*(precios_0[i,.]')
+Z8[i]*precios_0[i,.]*AZ8_matrix*(precios_0[i,.]')	
+Z9[i]*precios_0[i,.]*AZ9_matrix*(precios_0[i,.]')); 	
	
S_p_z_0=(1/2)*precios_0[i,.]*B_matrix*(precios_0[i,.]');	
	
util_EASI_0[i]=(ln(suma_gastos[i])-precios_0[i,.]*(w_matrix[i,.]')+T_p_z_0)/(1-S_p_z_0);	
i=i+1;
endo;

util_EASI_1=zeros(num_hogares,1);

i=1;
do while i .le num_hogares;

T_p_z_1=(1/2)*(
Z1[i]*precios_1[i,.]*AZ1_matrix*(precios_1[i,.]')	
+Z2[i]*precios_1[i,.]*AZ2_matrix*(precios_1[i,.]')	
+Z3[i]*precios_1[i,.]*AZ3_matrix*(precios_1[i,.]')
+Z4[i]*precios_1[i,.]*AZ4_matrix*(precios_1[i,.]')
+Z5[i]*precios_1[i,.]*AZ5_matrix*(precios_1[i,.]')
+Z6[i]*precios_1[i,.]*AZ6_matrix*(precios_1[i,.]')
+Z7[i]*precios_1[i,.]*AZ7_matrix*(precios_1[i,.]')
+Z8[i]*precios_1[i,.]*AZ8_matrix*(precios_1[i,.]')	
+Z9[i]*precios_1[i,.]*AZ9_matrix*(precios_1[i,.]')); 	
	
S_p_z_1=(1/2)*precios_1[i,.]*B_matrix*(precios_1[i,.]');	
	
util_EASI_1[i]=(ln(suma_gastos[i])-precios_1[i,.]*(w_matrix[i,.]')+T_p_z_1)/(1-S_p_z_1);	
i=i+1;
endo;

costo_p1_y_p1=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;
T_p_z_1=(1/2)*(
Z1[i]*precios_1[i,.]*AZ1_matrix*(precios_1[i,.]')	
+Z2[i]*precios_1[i,.]*AZ2_matrix*(precios_1[i,.]')	
+Z3[i]*precios_1[i,.]*AZ3_matrix*(precios_1[i,.]')
+Z4[i]*precios_1[i,.]*AZ4_matrix*(precios_1[i,.]')
+Z5[i]*precios_1[i,.]*AZ5_matrix*(precios_1[i,.]')
+Z6[i]*precios_1[i,.]*AZ6_matrix*(precios_1[i,.]')
+Z7[i]*precios_1[i,.]*AZ7_matrix*(precios_1[i,.]')
+Z8[i]*precios_1[i,.]*AZ8_matrix*(precios_1[i,.]')	
+Z9[i]*precios_1[i,.]*AZ9_matrix*(precios_1[i,.]')); 	
S_p_z_1=(1/2)*precios_1[i,.]*B_matrix*(precios_1[i,.]');	
m_u_z=(b0_vector+b1_vector*util_EASI_1[i]+b2_vector*util_EASI_1[i]^2+b3_vector*util_EASI_1[i]^3+C_matrix*(Z_vars[i,.]')
+D_matrix*(Z_vars[i,.]'*util_EASI_1[i]))';	
costo_p1_y_p1[i]=exp(util_EASI_1[i]+precios_1[i,.]*(m_u_z')+T_p_z_1+S_p_z_1*util_EASI_1[i]+precios_1[i,.]*(epsilon_matrix[i,.]'));
i=i+1;
endo;	
	
costo_p0_y_p1=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;
T_p_z_0=(1/2)*(
Z1[i]*precios_0[i,.]*AZ1_matrix*(precios_0[i,.]')	
+Z2[i]*precios_0[i,.]*AZ2_matrix*(precios_0[i,.]')	
+Z3[i]*precios_0[i,.]*AZ3_matrix*(precios_0[i,.]')
+Z4[i]*precios_0[i,.]*AZ4_matrix*(precios_0[i,.]')
+Z5[i]*precios_0[i,.]*AZ5_matrix*(precios_0[i,.]')
+Z6[i]*precios_0[i,.]*AZ6_matrix*(precios_0[i,.]')
+Z7[i]*precios_0[i,.]*AZ7_matrix*(precios_0[i,.]')
+Z8[i]*precios_0[i,.]*AZ8_matrix*(precios_0[i,.]')	
+Z9[i]*precios_0[i,.]*AZ9_matrix*(precios_0[i,.]')); 	
S_p_z_0=(1/2)*precios_0[i,.]*B_matrix*(precios_0[i,.]');	
m_u_z=(b0_vector+b1_vector*util_EASI_1[i]+b2_vector*util_EASI_1[i]^2+b3_vector*util_EASI_1[i]^3+C_matrix*(Z_vars[i,.]')
+D_matrix*(Z_vars[i,.]'*util_EASI_1[i]))';	
costo_p0_y_p1[i]=exp(util_EASI_1[i]+precios_0[i,.]*(m_u_z')+T_p_z_0+S_p_z_0*util_EASI_1[i]+precios_0[i,.]*(epsilon_matrix[i,.]'));
i=i+1;
endo;	


costo_p1_y_p0=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;
T_p_z_1=(1/2)*(
Z1[i]*precios_1[i,.]*AZ1_matrix*(precios_1[i,.]')	
+Z2[i]*precios_1[i,.]*AZ2_matrix*(precios_1[i,.]')	
+Z3[i]*precios_1[i,.]*AZ3_matrix*(precios_1[i,.]')
+Z4[i]*precios_1[i,.]*AZ4_matrix*(precios_1[i,.]')
+Z5[i]*precios_1[i,.]*AZ5_matrix*(precios_1[i,.]')
+Z6[i]*precios_1[i,.]*AZ6_matrix*(precios_1[i,.]')
+Z7[i]*precios_1[i,.]*AZ7_matrix*(precios_1[i,.]')
+Z8[i]*precios_1[i,.]*AZ8_matrix*(precios_1[i,.]')	
+Z9[i]*precios_1[i,.]*AZ9_matrix*(precios_1[i,.]')); 	
S_p_z_1=(1/2)*precios_1[i,.]*B_matrix*(precios_1[i,.]');	
m_u_z=(b0_vector+b1_vector*util_EASI_0[i]+b2_vector*util_EASI_0[i]^2+b3_vector*util_EASI_0[i]^3+C_matrix*(Z_vars[i,.]')
+D_matrix*(Z_vars[i,.]'*util_EASI_0[i]))';	
costo_p1_y_p0[i]=exp(util_EASI_0[i]+precios_1[i,.]*(m_u_z')+T_p_z_1+S_p_z_1*util_EASI_0[i]+precios_1[i,.]*(epsilon_matrix[i,.]'));
i=i+1;
endo;	


costo_p0_y_p0=zeros(num_hogares,1);
i=1;
do while i .le num_hogares;
T_p_z_0=(1/2)*(
Z1[i]*precios_0[i,.]*AZ1_matrix*(precios_0[i,.]')	
+Z2[i]*precios_0[i,.]*AZ2_matrix*(precios_0[i,.]')	
+Z3[i]*precios_0[i,.]*AZ3_matrix*(precios_0[i,.]')
+Z4[i]*precios_0[i,.]*AZ4_matrix*(precios_0[i,.]')
+Z5[i]*precios_0[i,.]*AZ5_matrix*(precios_0[i,.]')
+Z6[i]*precios_0[i,.]*AZ6_matrix*(precios_0[i,.]')
+Z7[i]*precios_0[i,.]*AZ7_matrix*(precios_0[i,.]')
+Z8[i]*precios_0[i,.]*AZ8_matrix*(precios_0[i,.]')	
+Z9[i]*precios_0[i,.]*AZ9_matrix*(precios_0[i,.]')); 	
S_p_z_0=(1/2)*precios_0[i,.]*B_matrix*(precios_0[i,.]');	
m_u_z=(b0_vector+b1_vector*util_EASI_0[i]+b2_vector*util_EASI_0[i]^2+b3_vector*util_EASI_0[i]^3+C_matrix*(Z_vars[i,.]')
+D_matrix*(Z_vars[i,.]'*util_EASI_0[i]))';	
costo_p0_y_p0[i]=exp(util_EASI_0[i]+precios_0[i,.]*(m_u_z')+T_p_z_0+S_p_z_0*util_EASI_0[i]+precios_0[i,.]*(epsilon_matrix[i,.]'));
i=i+1;
endo;	

VC_markups_2014=costo_p1_y_p0-costo_p0_y_p0;
VE_markups_2014=costo_p1_y_p1-costo_p0_y_p1;
VE_2014=((costo_p1_y_p1-costo_p0_y_p1)./costo_p1_y_p1).*suma_gastos;
VE_ingr_2014=VE_2014./vars_concentrado_hogares[.,22];
VE_2014_todo_pais=quantile(VE_2014, 0.5);
VE_2014_decil_10_todo_pais=quantile(selif(VE_2014, decil_10_hogares), 0.5);
VE_2014_decil_20_todo_pais=quantile(selif(VE_2014, decil_20_hogares), 0.5);
VE_2014_decil_30_todo_pais=quantile(selif(VE_2014, decil_30_hogares), 0.5);
VE_2014_decil_40_todo_pais=quantile(selif(VE_2014, decil_40_hogares), 0.5);
VE_2014_decil_50_todo_pais=quantile(selif(VE_2014, decil_50_hogares), 0.5);
VE_2014_decil_60_todo_pais=quantile(selif(VE_2014, decil_60_hogares), 0.5);
VE_2014_decil_70_todo_pais=quantile(selif(VE_2014, decil_70_hogares), 0.5);
VE_2014_decil_80_todo_pais=quantile(selif(VE_2014, decil_80_hogares), 0.5);
VE_2014_decil_90_todo_pais=quantile(selif(VE_2014, decil_90_hogares), 0.5);
VE_2014_decil_100_todo_pais=quantile(selif(VE_2014, decil_100_hogares), 0.5);
VE_2014_debajo_decil_50=quantile(selif(VE_2014, pordebajo_decil_50_hogares), 0.5);
VE_ingr_2014_todo_pais=quantile(VE_ingr_2014, 0.5);
VE_ingr_2014_d_10_todo_pais=quantile(selif(VE_ingr_2014, decil_10_hogares), 0.5);
VE_ingr_2014_d_20_todo_pais=quantile(selif(VE_ingr_2014, decil_20_hogares), 0.5);
VE_ingr_2014_d_30_todo_pais=quantile(selif(VE_ingr_2014, decil_30_hogares), 0.5);
VE_ingr_2014_d_40_todo_pais=quantile(selif(VE_ingr_2014, decil_40_hogares), 0.5);
VE_ingr_2014_d_50_todo_pais=quantile(selif(VE_ingr_2014, decil_50_hogares), 0.5);
VE_ingr_2014_d_60_todo_pais=quantile(selif(VE_ingr_2014, decil_60_hogares), 0.5);
VE_ingr_2014_d_70_todo_pais=quantile(selif(VE_ingr_2014, decil_70_hogares), 0.5);
VE_ingr_2014_d_80_todo_pais=quantile(selif(VE_ingr_2014, decil_80_hogares), 0.5);
VE_ingr_2014_d_90_todo_pais=quantile(selif(VE_ingr_2014, decil_90_hogares), 0.5);
VE_ingr_2014_d_100_todo_pais=quantile(selif(VE_ingr_2014, decil_100_hogares), 0.5);
VE_ingr_2014_debajo_decil_50=quantile(selif(VE_ingr_2014, pordebajo_decil_50_hogares), 0.5);


/*REGIONES

NOROESTE (DIEZ)
13.- Culiacan, Sin.
17.- Hermosillo, Son.
18.- Huatabampo, Son.
22.- La Paz, B.C.S.
26.- Mexicali, B.C.
40.- Tijuana, B.C.
6.- Cd. Juarez, Chih.
8.- Chihuahua, Chih.
14.- Durango, Dgo.
21.- Jimenez, Chih.

NORESTE (SEIS)
5.- Cd. AcuNa, Coah.
24.- Matamoros, Tamps.
27.- Monclova, Coah.
28.- Monterrey, N.L.
35.- Tampico, Tamps.
43.- Torreon, Coah.

CENTRO NORTE (SEIS)
2.- Aguascalientes, Ags.
15.- Fresnillo, Zac.
11.- Cortazar, Gto.
23.- Leon, Gto.
32.- Queretaro, Qro.
34.- San Luis Potosi, S.L.P.

CENTRO SUR (TRES)
3.- Ciudad de Mexico
42.- Toluca, Edomex.
12.- Cuernavaca, Mor.

SUROESTE (CINCO)
1.- Acapulco, Gro.
19.- Iguala, Gro.
30.- Oaxaca, Oax.
36.- Tapachula, Chis.
37.- Tehuantepec, Oax.

SURESTE (CUATRO)
4.- Campeche, Camp.
7.- Chetumal, Q. Roo.
25.- Merida, Yuc.
46.- Villahermosa, Tab

OESTE (SEIS)
39.- Tepic, Nay.
9.- Colima, Col.
16.- Guadalajara, Jal.
38.- Tepatitlan, Jal.
20.- Jacona, Mich.
29.- Morelia, Mich.

ESTE (SEIS)
10.- Cordoba, Ver.
31.- Puebla, Pue.
33.- San Andres Tuxtla, Ver.
41.- Tlaxcala, Tlax.
44.- Tulancingo, Hgo.
45.- Veracruz, Ver.*/


region_noroeste=13|17|18|22|26|40|6|8|14|21;
region_noreste=5|24|27|28|35|43;
region_centro_norte=2|15|11|23|32|34;
region_centro_sur=3|42|12;
region_suroeste=1|19|30|36|37;
region_sureste=4|7|25|46;
region_oeste=39|9|16|38|20|29;
region_este=10|31|33|41|44|45;


ciudades_46=seqa(1,1,46);
ciudad_region_noroeste=maxc((ciudades_46 .eq region_noroeste')');
ciudad_region_noreste=maxc((ciudades_46 .eq region_noreste')');
ciudad_region_centro_norte=maxc((ciudades_46 .eq region_centro_norte')');
ciudad_region_centro_sur=maxc((ciudades_46 .eq region_centro_sur')');
ciudad_region_suroeste=maxc((ciudades_46 .eq region_suroeste')');
ciudad_region_sureste=maxc((ciudades_46 .eq region_sureste')');
ciudad_region_oeste=maxc((ciudades_46 .eq region_oeste')');
ciudad_region_este=maxc((ciudades_46 .eq region_este')');


hogar_region_noroeste=zeros(num_hogares,1);
hogar_region_noreste=zeros(num_hogares,1);
hogar_region_centro_norte=zeros(num_hogares,1);
hogar_region_centro_sur=zeros(num_hogares,1);
hogar_region_suroeste=zeros(num_hogares,1);
hogar_region_sureste=zeros(num_hogares,1);
hogar_region_oeste=zeros(num_hogares,1);
hogar_region_este=zeros(num_hogares,1);


i=1;
do while i .le num_hogares;
hogar_region_noroeste[i]=maxc((ciudad_46_mas_cercana[i] .eq region_noroeste')');
hogar_region_noreste[i]=maxc((ciudad_46_mas_cercana[i] .eq region_noreste')');
hogar_region_centro_norte[i]=maxc((ciudad_46_mas_cercana[i] .eq region_centro_norte')');
hogar_region_centro_sur[i]=maxc((ciudad_46_mas_cercana[i] .eq region_centro_sur')');
hogar_region_suroeste[i]=maxc((ciudad_46_mas_cercana[i] .eq region_suroeste')');
hogar_region_sureste[i]=maxc((ciudad_46_mas_cercana[i] .eq region_sureste')');
hogar_region_oeste[i]=maxc((ciudad_46_mas_cercana[i] .eq region_oeste')');
hogar_region_este[i]=maxc((ciudad_46_mas_cercana[i] .eq region_este')');
i=i+1;
endo;	

decil_10_noroeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.10));
decil_10_noreste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.10));
decil_10_centro_norte=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.10));
decil_10_centro_sur=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.10));
decil_10_suroeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.10));
decil_10_sureste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.10));
decil_10_oeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.10));
decil_10_este=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.10));


decil_20_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.20));
decil_20_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.20));
decil_20_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.20));
decil_20_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.20));
decil_20_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.20));
decil_20_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.20));
decil_20_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.20));
decil_20_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.10)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.20));



decil_30_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.30));
decil_30_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.30));
decil_30_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.30));
decil_30_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.30));
decil_30_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.30));
decil_30_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.30));
decil_30_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.30));
decil_30_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.20)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.30));



decil_40_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.40));
decil_40_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.40));
decil_40_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.40));
decil_40_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.40));
decil_40_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.40));
decil_40_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.40));
decil_40_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.40));
decil_40_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.30)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.40));


decil_50_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.50));
decil_50_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.50));
decil_50_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.50));
decil_50_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.50));
decil_50_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.50));
decil_50_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.50));
decil_50_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.50));
decil_50_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.40)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.50));


decil_60_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.60));
decil_60_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.60));
decil_60_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.60));
decil_60_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.60));
decil_60_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.60));
decil_60_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.60));
decil_60_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.60));
decil_60_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.50)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.60));



decil_70_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.70));
decil_70_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.70));
decil_70_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.70));
decil_70_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.70));
decil_70_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.70));
decil_70_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.70));
decil_70_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.70));
decil_70_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.60)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.70));


decil_80_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.80));
decil_80_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.80));
decil_80_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.80));
decil_80_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.80));
decil_80_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.80));
decil_80_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.80));
decil_80_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.80));
decil_80_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.70)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.80));


decil_90_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.90));
decil_90_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.90));
decil_90_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.90));
decil_90_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.90));
decil_90_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.90));
decil_90_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.90));
decil_90_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.90));
decil_90_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.80)).*
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.90));



decil_100_noroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.90));
decil_100_noreste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.90));
decil_100_centro_norte=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.90));
decil_100_centro_sur=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.90));
decil_100_suroeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.90));
decil_100_sureste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.90));
decil_100_oeste=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.90));
decil_100_este=
(vars_concentrado_hogares[.,22] .ge quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.90));


debajo_decil_50_noroeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noroeste), 0.50));
debajo_decil_50_noreste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_noreste), 0.50));
debajo_decil_50_centro_norte=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_norte), 0.50));
debajo_decil_50_centro_sur=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_centro_sur), 0.50));
debajo_decil_50_suroeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_suroeste), 0.50));
debajo_decil_50_sureste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_sureste), 0.50));
debajo_decil_50_oeste=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_oeste), 0.50));
debajo_decil_50_este=
(vars_concentrado_hogares[.,22] .le quantile(selif(vars_concentrado_hogares[.,22], hogar_region_este), 0.50));


VE_2014_noroeste=quantile(selif(VE_2014, hogar_region_noroeste), 0.5);
VE_2014_d_10_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_10_noroeste), 0.5);
VE_2014_d_20_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_20_noroeste), 0.5);
VE_2014_d_30_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_30_noroeste), 0.5);
VE_2014_d_40_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_40_noroeste), 0.5);
VE_2014_d_50_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_50_noroeste), 0.5);
VE_2014_d_60_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_60_noroeste), 0.5);
VE_2014_d_70_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_70_noroeste), 0.5);
VE_2014_d_80_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_80_noroeste), 0.5);
VE_2014_d_90_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_90_noroeste), 0.5);
VE_2014_d_100_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*decil_100_noroeste), 0.5);

VE_2014_noreste=quantile(selif(VE_2014, hogar_region_noreste), 0.5);
VE_2014_d_10_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_10_noreste), 0.5);
VE_2014_d_20_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_20_noreste), 0.5);
VE_2014_d_30_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_30_noreste), 0.5);
VE_2014_d_40_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_40_noreste), 0.5);
VE_2014_d_50_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_50_noreste), 0.5);
VE_2014_d_60_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_60_noreste), 0.5);
VE_2014_d_70_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_70_noreste), 0.5);
VE_2014_d_80_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_80_noreste), 0.5);
VE_2014_d_90_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_90_noreste), 0.5);
VE_2014_d_100_noreste=quantile(selif(VE_2014, hogar_region_noreste.*decil_100_noreste), 0.5);

VE_2014_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte), 0.5);
VE_2014_d_10_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_10_centro_norte), 0.5);
VE_2014_d_20_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_20_centro_norte), 0.5);
VE_2014_d_30_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_30_centro_norte), 0.5);
VE_2014_d_40_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_40_centro_norte), 0.5);
VE_2014_d_50_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_50_centro_norte), 0.5);
VE_2014_d_60_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_60_centro_norte), 0.5);
VE_2014_d_70_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_70_centro_norte), 0.5);
VE_2014_d_80_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_80_centro_norte), 0.5);
VE_2014_d_90_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_90_centro_norte), 0.5);
VE_2014_d_100_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*decil_100_centro_norte), 0.5);


VE_2014_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur), 0.5);
VE_2014_d_10_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_10_centro_sur), 0.5);
VE_2014_d_20_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_20_centro_sur), 0.5);
VE_2014_d_30_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_30_centro_sur), 0.5);
VE_2014_d_40_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_40_centro_sur), 0.5);
VE_2014_d_50_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_50_centro_sur), 0.5);
VE_2014_d_60_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_60_centro_sur), 0.5);
VE_2014_d_70_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_70_centro_sur), 0.5);
VE_2014_d_80_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_80_centro_sur), 0.5);
VE_2014_d_90_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_90_centro_sur), 0.5);
VE_2014_d_100_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*decil_100_centro_sur), 0.5);

VE_2014_suroeste=quantile(selif(VE_2014, hogar_region_suroeste), 0.5);
VE_2014_d_10_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_10_suroeste), 0.5);
VE_2014_d_20_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_20_suroeste), 0.5);
VE_2014_d_30_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_30_suroeste), 0.5);
VE_2014_d_40_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_40_suroeste), 0.5);
VE_2014_d_50_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_50_suroeste), 0.5);
VE_2014_d_60_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_60_suroeste), 0.5);
VE_2014_d_70_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_70_suroeste), 0.5);
VE_2014_d_80_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_80_suroeste), 0.5);
VE_2014_d_90_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_90_suroeste), 0.5);
VE_2014_d_100_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*decil_100_suroeste), 0.5);

VE_2014_sureste=quantile(selif(VE_2014, hogar_region_sureste), 0.5);
VE_2014_d_10_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_10_sureste), 0.5);
VE_2014_d_20_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_20_sureste), 0.5);
VE_2014_d_30_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_30_sureste), 0.5);
VE_2014_d_40_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_40_sureste), 0.5);
VE_2014_d_50_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_50_sureste), 0.5);
VE_2014_d_60_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_60_sureste), 0.5);
VE_2014_d_70_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_70_sureste), 0.5);
VE_2014_d_80_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_80_sureste), 0.5);
VE_2014_d_90_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_90_sureste), 0.5);
VE_2014_d_100_sureste=quantile(selif(VE_2014, hogar_region_sureste.*decil_100_sureste), 0.5);

VE_2014_oeste=quantile(selif(VE_2014, hogar_region_oeste), 0.5);
VE_2014_d_10_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_10_oeste), 0.5);
VE_2014_d_20_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_20_oeste), 0.5);
VE_2014_d_30_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_30_oeste), 0.5);
VE_2014_d_40_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_40_oeste), 0.5);
VE_2014_d_50_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_50_oeste), 0.5);
VE_2014_d_60_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_60_oeste), 0.5);
VE_2014_d_70_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_70_oeste), 0.5);
VE_2014_d_80_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_80_oeste), 0.5);
VE_2014_d_90_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_90_oeste), 0.5);
VE_2014_d_100_oeste=quantile(selif(VE_2014, hogar_region_oeste.*decil_100_oeste), 0.5);

VE_2014_este=quantile(selif(VE_2014, hogar_region_este), 0.5);
VE_2014_d_10_este=quantile(selif(VE_2014, hogar_region_este.*decil_10_este), 0.5);
VE_2014_d_20_este=quantile(selif(VE_2014, hogar_region_este.*decil_20_este), 0.5);
VE_2014_d_30_este=quantile(selif(VE_2014, hogar_region_este.*decil_30_este), 0.5);
VE_2014_d_40_este=quantile(selif(VE_2014, hogar_region_este.*decil_40_este), 0.5);
VE_2014_d_50_este=quantile(selif(VE_2014, hogar_region_este.*decil_50_este), 0.5);
VE_2014_d_60_este=quantile(selif(VE_2014, hogar_region_este.*decil_60_este), 0.5);
VE_2014_d_70_este=quantile(selif(VE_2014, hogar_region_este.*decil_70_este), 0.5);
VE_2014_d_80_este=quantile(selif(VE_2014, hogar_region_este.*decil_80_este), 0.5);
VE_2014_d_90_este=quantile(selif(VE_2014, hogar_region_este.*decil_90_este), 0.5);
VE_2014_d_100_este=quantile(selif(VE_2014, hogar_region_este.*decil_100_este), 0.5);


VE_ingr_2014_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste), 0.5);
VE_ingr_2014_d_10_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_10_noroeste), 0.5);
VE_ingr_2014_d_20_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_20_noroeste), 0.5);
VE_ingr_2014_d_30_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_30_noroeste), 0.5);
VE_ingr_2014_d_40_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_40_noroeste), 0.5);
VE_ingr_2014_d_50_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_50_noroeste), 0.5);
VE_ingr_2014_d_60_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_60_noroeste), 0.5);
VE_ingr_2014_d_70_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_70_noroeste), 0.5);
VE_ingr_2014_d_80_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_80_noroeste), 0.5);
VE_ingr_2014_d_90_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_90_noroeste), 0.5);
VE_ingr_2014_d_100_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*decil_100_noroeste), 0.5);

VE_ingr_2014_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste), 0.5);
VE_ingr_2014_d_10_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_10_noreste), 0.5);
VE_ingr_2014_d_20_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_20_noreste), 0.5);
VE_ingr_2014_d_30_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_30_noreste), 0.5);
VE_ingr_2014_d_40_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_40_noreste), 0.5);
VE_ingr_2014_d_50_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_50_noreste), 0.5);
VE_ingr_2014_d_60_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_60_noreste), 0.5);
VE_ingr_2014_d_70_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_70_noreste), 0.5);
VE_ingr_2014_d_80_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_80_noreste), 0.5);
VE_ingr_2014_d_90_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_90_noreste), 0.5);
VE_ingr_2014_d_100_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*decil_100_noreste), 0.5);

VE_ingr_2014_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte), 0.5);
VE_ingr_2014_d_10_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_10_centro_norte), 0.5);
VE_ingr_2014_d_20_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_20_centro_norte), 0.5);
VE_ingr_2014_d_30_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_30_centro_norte), 0.5);
VE_ingr_2014_d_40_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_40_centro_norte), 0.5);
VE_ingr_2014_d_50_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_50_centro_norte), 0.5);
VE_ingr_2014_d_60_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_60_centro_norte), 0.5);
VE_ingr_2014_d_70_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_70_centro_norte), 0.5);
VE_ingr_2014_d_80_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_80_centro_norte), 0.5);
VE_ingr_2014_d_90_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_90_centro_norte), 0.5);
VE_ingr_2014_d_100_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*decil_100_centro_norte), 0.5);


VE_ingr_2014_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur), 0.5);
VE_ingr_2014_d_10_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_10_centro_sur), 0.5);
VE_ingr_2014_d_20_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_20_centro_sur), 0.5);
VE_ingr_2014_d_30_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_30_centro_sur), 0.5);
VE_ingr_2014_d_40_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_40_centro_sur), 0.5);
VE_ingr_2014_d_50_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_50_centro_sur), 0.5);
VE_ingr_2014_d_60_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_60_centro_sur), 0.5);
VE_ingr_2014_d_70_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_70_centro_sur), 0.5);
VE_ingr_2014_d_80_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_80_centro_sur), 0.5);
VE_ingr_2014_d_90_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_90_centro_sur), 0.5);
VE_ingr_2014_d_100_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*decil_100_centro_sur), 0.5);

VE_ingr_2014_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste), 0.5);
VE_ingr_2014_d_10_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_10_suroeste), 0.5);
VE_ingr_2014_d_20_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_20_suroeste), 0.5);
VE_ingr_2014_d_30_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_30_suroeste), 0.5);
VE_ingr_2014_d_40_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_40_suroeste), 0.5);
VE_ingr_2014_d_50_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_50_suroeste), 0.5);
VE_ingr_2014_d_60_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_60_suroeste), 0.5);
VE_ingr_2014_d_70_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_70_suroeste), 0.5);
VE_ingr_2014_d_80_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_80_suroeste), 0.5);
VE_ingr_2014_d_90_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_90_suroeste), 0.5);
VE_ingr_2014_d_100_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*decil_100_suroeste), 0.5);

VE_ingr_2014_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste), 0.5);
VE_ingr_2014_d_10_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_10_sureste), 0.5);
VE_ingr_2014_d_20_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_20_sureste), 0.5);
VE_ingr_2014_d_30_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_30_sureste), 0.5);
VE_ingr_2014_d_40_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_40_sureste), 0.5);
VE_ingr_2014_d_50_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_50_sureste), 0.5);
VE_ingr_2014_d_60_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_60_sureste), 0.5);
VE_ingr_2014_d_70_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_70_sureste), 0.5);
VE_ingr_2014_d_80_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_80_sureste), 0.5);
VE_ingr_2014_d_90_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_90_sureste), 0.5);
VE_ingr_2014_d_100_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*decil_100_sureste), 0.5);

VE_ingr_2014_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste), 0.5);
VE_ingr_2014_d_10_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_10_oeste), 0.5);
VE_ingr_2014_d_20_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_20_oeste), 0.5);
VE_ingr_2014_d_30_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_30_oeste), 0.5);
VE_ingr_2014_d_40_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_40_oeste), 0.5);
VE_ingr_2014_d_50_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_50_oeste), 0.5);
VE_ingr_2014_d_60_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_60_oeste), 0.5);
VE_ingr_2014_d_70_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_70_oeste), 0.5);
VE_ingr_2014_d_80_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_80_oeste), 0.5);
VE_ingr_2014_d_90_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_90_oeste), 0.5);
VE_ingr_2014_d_100_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*decil_100_oeste), 0.5);


VE_ingr_2014_este=quantile(selif(VE_ingr_2014, hogar_region_este), 0.5);
VE_ingr_2014_d_10_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_10_este), 0.5);
VE_ingr_2014_d_20_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_20_este), 0.5);
VE_ingr_2014_d_30_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_30_este), 0.5);
VE_ingr_2014_d_40_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_40_este), 0.5);
VE_ingr_2014_d_50_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_50_este), 0.5);
VE_ingr_2014_d_60_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_60_este), 0.5);
VE_ingr_2014_d_70_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_70_este), 0.5);
VE_ingr_2014_d_80_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_80_este), 0.5);
VE_ingr_2014_d_90_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_90_este), 0.5);
VE_ingr_2014_d_100_este=quantile(selif(VE_ingr_2014, hogar_region_este.*decil_100_este), 0.5);

INPC_octubre_2014=114.5690;
INPC_octubre_2015=117.410;
factor_inflac_2014=INPC_octubre_2015/INPC_octubre_2014;

markups_empiricos_signific_2014=meanc(markups_cinco_mayores_bis);
markups_empiricos_todos_2014=meanc(markups_todos_bis);

t_stat_markups_2014=resumen_resultados[.,2];

elastic_demanda_agregada_2014=elastic_agregadas_vector; 
elast_prom_noroeste_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_noroeste));
elast_prom_noreste_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_noreste));
elast_prom_centro_norte_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_centro_norte));
elast_prom_centro_sur_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_centro_sur));
elast_prom_suroeste_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_suroeste));
elast_prom_sureste_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_sureste));
elast_prom_oeste_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_oeste));
elast_prom_este_2014=meanc(selif(elastic_46_ciudades_matrix, ciudad_region_este));


elastic_regionales_2014=elast_prom_noroeste_2014~elast_prom_noreste_2014~elast_prom_centro_norte_2014~elast_prom_centro_sur_2014~elast_prom_suroeste_2014~elast_prom_sureste_2014
~elast_prom_oeste_2014~elast_prom_este_2014;

/*::::::::::*/
elastic_demanda_agregada_2014=elastic_agregadas_vector;
elast_prom_noroeste_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_noroeste));
elast_prom_noreste_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_noreste));
elast_prom_centro_norte_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_centro_norte));
elast_prom_centro_sur_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_centro_sur));
elast_prom_suroeste_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_suroeste));
elast_prom_sureste_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_sureste));
elast_prom_oeste_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_oeste));
elast_prom_este_2014_fin=meanc(selif(elastic_46_ciudades_matrix_fin, ciudad_region_este));


elastic_regionales_2014_fin=elast_prom_noroeste_2014_fin~elast_prom_noreste_2014_fin~elast_prom_centro_norte_2014_fin~elast_prom_centro_sur_2014_fin~elast_prom_suroeste_2014_fin~elast_prom_sureste_2014_fin
~elast_prom_oeste_2014_fin~elast_prom_este_2014_fin;

/*::::::::*/
resultados_todo_pais_2014=
(VE_2014_todo_pais*factor_inflac_2014|
VE_2014_decil_10_todo_pais*factor_inflac_2014|
VE_2014_decil_20_todo_pais*factor_inflac_2014|
VE_2014_decil_30_todo_pais*factor_inflac_2014|
VE_2014_decil_40_todo_pais*factor_inflac_2014|
VE_2014_decil_50_todo_pais*factor_inflac_2014|
VE_2014_decil_60_todo_pais*factor_inflac_2014|
VE_2014_decil_70_todo_pais*factor_inflac_2014|
VE_2014_decil_80_todo_pais*factor_inflac_2014|
VE_2014_decil_90_todo_pais*factor_inflac_2014|
VE_2014_decil_100_todo_pais*factor_inflac_2014)~
(VE_ingr_2014_todo_pais|
VE_ingr_2014_d_10_todo_pais|
VE_ingr_2014_d_20_todo_pais|
VE_ingr_2014_d_30_todo_pais|
VE_ingr_2014_d_40_todo_pais|
VE_ingr_2014_d_50_todo_pais|
VE_ingr_2014_d_60_todo_pais|
VE_ingr_2014_d_70_todo_pais|
VE_ingr_2014_d_80_todo_pais|
VE_ingr_2014_d_90_todo_pais|
VE_ingr_2014_d_100_todo_pais);

resultados_noroeste_2014=
(VE_2014_noroeste*factor_inflac_2014|
VE_2014_d_10_noroeste*factor_inflac_2014|
VE_2014_d_20_noroeste*factor_inflac_2014|
VE_2014_d_30_noroeste*factor_inflac_2014|
VE_2014_d_40_noroeste*factor_inflac_2014|
VE_2014_d_50_noroeste*factor_inflac_2014|
VE_2014_d_60_noroeste*factor_inflac_2014|
VE_2014_d_70_noroeste*factor_inflac_2014|
VE_2014_d_80_noroeste*factor_inflac_2014|
VE_2014_d_90_noroeste*factor_inflac_2014|
VE_2014_d_100_noroeste*factor_inflac_2014)~
(VE_ingr_2014_noroeste|
VE_ingr_2014_d_10_noroeste|
VE_ingr_2014_d_20_noroeste|
VE_ingr_2014_d_30_noroeste|
VE_ingr_2014_d_40_noroeste|
VE_ingr_2014_d_50_noroeste|
VE_ingr_2014_d_60_noroeste|
VE_ingr_2014_d_70_noroeste|
VE_ingr_2014_d_80_noroeste|
VE_ingr_2014_d_90_noroeste|
VE_ingr_2014_d_100_noroeste);


resultados_noreste_2014=
(VE_2014_noreste*factor_inflac_2014|
VE_2014_d_10_noreste*factor_inflac_2014|
VE_2014_d_20_noreste*factor_inflac_2014|
VE_2014_d_30_noreste*factor_inflac_2014|
VE_2014_d_40_noreste*factor_inflac_2014|
VE_2014_d_50_noreste*factor_inflac_2014|
VE_2014_d_60_noreste*factor_inflac_2014|
VE_2014_d_70_noreste*factor_inflac_2014|
VE_2014_d_80_noreste*factor_inflac_2014|
VE_2014_d_90_noreste*factor_inflac_2014|
VE_2014_d_100_noreste*factor_inflac_2014)~
(VE_ingr_2014_noreste|
VE_ingr_2014_d_10_noreste|
VE_ingr_2014_d_20_noreste|
VE_ingr_2014_d_30_noreste|
VE_ingr_2014_d_40_noreste|
VE_ingr_2014_d_50_noreste|
VE_ingr_2014_d_60_noreste|
VE_ingr_2014_d_70_noreste|
VE_ingr_2014_d_80_noreste|
VE_ingr_2014_d_90_noreste|
VE_ingr_2014_d_100_noreste);


resultados_centro_norte_2014=
(VE_2014_centro_norte*factor_inflac_2014|
VE_2014_d_10_centro_norte*factor_inflac_2014|
VE_2014_d_20_centro_norte*factor_inflac_2014|
VE_2014_d_30_centro_norte*factor_inflac_2014|
VE_2014_d_40_centro_norte*factor_inflac_2014|
VE_2014_d_50_centro_norte*factor_inflac_2014|
VE_2014_d_60_centro_norte*factor_inflac_2014|
VE_2014_d_70_centro_norte*factor_inflac_2014|
VE_2014_d_80_centro_norte*factor_inflac_2014|
VE_2014_d_90_centro_norte*factor_inflac_2014|
VE_2014_d_100_centro_norte*factor_inflac_2014)~
(VE_ingr_2014_centro_norte|
VE_ingr_2014_d_10_centro_norte|
VE_ingr_2014_d_20_centro_norte|
VE_ingr_2014_d_30_centro_norte|
VE_ingr_2014_d_40_centro_norte|
VE_ingr_2014_d_50_centro_norte|
VE_ingr_2014_d_60_centro_norte|
VE_ingr_2014_d_70_centro_norte|
VE_ingr_2014_d_80_centro_norte|
VE_ingr_2014_d_90_centro_norte|
VE_ingr_2014_d_100_centro_norte);


resultados_centro_sur_2014=
(VE_2014_centro_sur*factor_inflac_2014|
VE_2014_d_10_centro_sur*factor_inflac_2014|
VE_2014_d_20_centro_sur*factor_inflac_2014|
VE_2014_d_30_centro_sur*factor_inflac_2014|
VE_2014_d_40_centro_sur*factor_inflac_2014|
VE_2014_d_50_centro_sur*factor_inflac_2014|
VE_2014_d_60_centro_sur*factor_inflac_2014|
VE_2014_d_70_centro_sur*factor_inflac_2014|
VE_2014_d_80_centro_sur*factor_inflac_2014|
VE_2014_d_90_centro_sur*factor_inflac_2014|
VE_2014_d_100_centro_sur*factor_inflac_2014)~
(VE_ingr_2014_centro_sur|
VE_ingr_2014_d_10_centro_sur|
VE_ingr_2014_d_20_centro_sur|
VE_ingr_2014_d_30_centro_sur|
VE_ingr_2014_d_40_centro_sur|
VE_ingr_2014_d_50_centro_sur|
VE_ingr_2014_d_60_centro_sur|
VE_ingr_2014_d_70_centro_sur|
VE_ingr_2014_d_80_centro_sur|
VE_ingr_2014_d_90_centro_sur|
VE_ingr_2014_d_100_centro_sur);

resultados_suroeste_2014=
(VE_2014_suroeste*factor_inflac_2014|
VE_2014_d_10_suroeste*factor_inflac_2014|
VE_2014_d_20_suroeste*factor_inflac_2014|
VE_2014_d_30_suroeste*factor_inflac_2014|
VE_2014_d_40_suroeste*factor_inflac_2014|
VE_2014_d_50_suroeste*factor_inflac_2014|
VE_2014_d_60_suroeste*factor_inflac_2014|
VE_2014_d_70_suroeste*factor_inflac_2014|
VE_2014_d_80_suroeste*factor_inflac_2014|
VE_2014_d_90_suroeste*factor_inflac_2014|
VE_2014_d_100_suroeste*factor_inflac_2014)~
(VE_ingr_2014_suroeste|
VE_ingr_2014_d_10_suroeste|
VE_ingr_2014_d_20_suroeste|
VE_ingr_2014_d_30_suroeste|
VE_ingr_2014_d_40_suroeste|
VE_ingr_2014_d_50_suroeste|
VE_ingr_2014_d_60_suroeste|
VE_ingr_2014_d_70_suroeste|
VE_ingr_2014_d_80_suroeste|
VE_ingr_2014_d_90_suroeste|
VE_ingr_2014_d_100_suroeste);

resultados_sureste_2014=
(VE_2014_sureste*factor_inflac_2014|
VE_2014_d_10_sureste*factor_inflac_2014|
VE_2014_d_20_sureste*factor_inflac_2014|
VE_2014_d_30_sureste*factor_inflac_2014|
VE_2014_d_40_sureste*factor_inflac_2014|
VE_2014_d_50_sureste*factor_inflac_2014|
VE_2014_d_60_sureste*factor_inflac_2014|
VE_2014_d_70_sureste*factor_inflac_2014|
VE_2014_d_80_sureste*factor_inflac_2014|
VE_2014_d_90_sureste*factor_inflac_2014|
VE_2014_d_100_sureste*factor_inflac_2014)~
(VE_ingr_2014_sureste|
VE_ingr_2014_d_10_sureste|
VE_ingr_2014_d_20_sureste|
VE_ingr_2014_d_30_sureste|
VE_ingr_2014_d_40_sureste|
VE_ingr_2014_d_50_sureste|
VE_ingr_2014_d_60_sureste|
VE_ingr_2014_d_70_sureste|
VE_ingr_2014_d_80_sureste|
VE_ingr_2014_d_90_sureste|
VE_ingr_2014_d_100_sureste);

resultados_oeste_2014=
(VE_2014_oeste*factor_inflac_2014|
VE_2014_d_10_oeste*factor_inflac_2014|
VE_2014_d_20_oeste*factor_inflac_2014|
VE_2014_d_30_oeste*factor_inflac_2014|
VE_2014_d_40_oeste*factor_inflac_2014|
VE_2014_d_50_oeste*factor_inflac_2014|
VE_2014_d_60_oeste*factor_inflac_2014|
VE_2014_d_70_oeste*factor_inflac_2014|
VE_2014_d_80_oeste*factor_inflac_2014|
VE_2014_d_90_oeste*factor_inflac_2014|
VE_2014_d_100_oeste*factor_inflac_2014)~
(VE_ingr_2014_oeste|
VE_ingr_2014_d_10_oeste|
VE_ingr_2014_d_20_oeste|
VE_ingr_2014_d_30_oeste|
VE_ingr_2014_d_40_oeste|
VE_ingr_2014_d_50_oeste|
VE_ingr_2014_d_60_oeste|
VE_ingr_2014_d_70_oeste|
VE_ingr_2014_d_80_oeste|
VE_ingr_2014_d_90_oeste|
VE_ingr_2014_d_100_oeste);

resultados_este_2014=
(VE_2014_este*factor_inflac_2014|
VE_2014_d_10_este*factor_inflac_2014|
VE_2014_d_20_este*factor_inflac_2014|
VE_2014_d_30_este*factor_inflac_2014|
VE_2014_d_40_este*factor_inflac_2014|
VE_2014_d_50_este*factor_inflac_2014|
VE_2014_d_60_este*factor_inflac_2014|
VE_2014_d_70_este*factor_inflac_2014|
VE_2014_d_80_este*factor_inflac_2014|
VE_2014_d_90_este*factor_inflac_2014|
VE_2014_d_100_este*factor_inflac_2014)~
(VE_ingr_2014_este|
VE_ingr_2014_d_10_este|
VE_ingr_2014_d_20_este|
VE_ingr_2014_d_30_este|
VE_ingr_2014_d_40_este|
VE_ingr_2014_d_50_este|
VE_ingr_2014_d_60_este|
VE_ingr_2014_d_70_este|
VE_ingr_2014_d_80_este|
VE_ingr_2014_d_90_este|
VE_ingr_2014_d_100_este);

VE_2014_debajo_decil_50=VE_2014_debajo_decil_50*factor_inflac_2014;
VE_ingr_2014_debajo_decil_50=VE_ingr_2014_debajo_decil_50;

VE_2014_bajo_d_50_noroeste=quantile(selif(VE_2014, hogar_region_noroeste.*debajo_decil_50_noroeste), 0.5);
VE_2014_bajo_d_50_noreste=quantile(selif(VE_2014, hogar_region_noreste.*debajo_decil_50_noroeste), 0.5);
VE_2014_bajo_d_50_centro_norte=quantile(selif(VE_2014, hogar_region_centro_norte.*debajo_decil_50_noroeste), 0.5);
VE_2014_bajo_d_50_centro_sur=quantile(selif(VE_2014, hogar_region_centro_sur.*debajo_decil_50_noroeste), 0.5);
VE_2014_bajo_d_50_suroeste=quantile(selif(VE_2014, hogar_region_suroeste.*debajo_decil_50_suroeste), 0.5);
VE_2014_bajo_d_50_sureste=quantile(selif(VE_2014, hogar_region_sureste.*debajo_decil_50_sureste), 0.5);
VE_2014_bajo_d_50_oeste=quantile(selif(VE_2014, hogar_region_oeste.*debajo_decil_50_oeste), 0.5);
VE_2014_bajo_d_50_este=quantile(selif(VE_2014, hogar_region_este.*debajo_decil_50_este), 0.5);


VE_2014_bajo_d_50_noroeste=VE_2014_bajo_d_50_noroeste*factor_inflac_2014;
VE_2014_bajo_d_50_noreste=VE_2014_bajo_d_50_noreste*factor_inflac_2014;
VE_2014_bajo_d_50_centro_norte=VE_2014_bajo_d_50_centro_norte*factor_inflac_2014;
VE_2014_bajo_d_50_centro_sur=VE_2014_bajo_d_50_centro_sur*factor_inflac_2014;
VE_2014_bajo_d_50_suroeste=VE_2014_bajo_d_50_suroeste*factor_inflac_2014;
VE_2014_bajo_d_50_sureste=VE_2014_bajo_d_50_sureste*factor_inflac_2014;
VE_2014_bajo_d_50_oeste=VE_2014_bajo_d_50_oeste*factor_inflac_2014;
VE_2014_bajo_d_50_este=VE_2014_bajo_d_50_este*factor_inflac_2014;



VE_ingr_14_baj_d_50_noroeste=quantile(selif(VE_ingr_2014, hogar_region_noroeste.*debajo_decil_50_noroeste), 0.5);
VE_ingr_14_baj_d_50_noreste=quantile(selif(VE_ingr_2014, hogar_region_noreste.*debajo_decil_50_noroeste), 0.5);
VE_ingr_14_baj_d_50_centro_norte=quantile(selif(VE_ingr_2014, hogar_region_centro_norte.*debajo_decil_50_noroeste), 0.5);
VE_ingr_14_baj_d_50_centro_sur=quantile(selif(VE_ingr_2014, hogar_region_centro_sur.*debajo_decil_50_noroeste), 0.5);
VE_ingr_14_baj_d_50_suroeste=quantile(selif(VE_ingr_2014, hogar_region_suroeste.*debajo_decil_50_suroeste), 0.5);
VE_ingr_14_baj_d_50_sureste=quantile(selif(VE_ingr_2014, hogar_region_sureste.*debajo_decil_50_sureste), 0.5);
VE_ingr_14_baj_d_50_oeste=quantile(selif(VE_ingr_2014, hogar_region_oeste.*debajo_decil_50_oeste), 0.5);
VE_ingr_14_baj_d_50_este=quantile(selif(VE_ingr_2014, hogar_region_este.*debajo_decil_50_este), 0.5);



nnn=rows(ingreso_2014_GINI);
aux_gini_vector=seqa(1,1,nnn);
/*::::::::::*/
Gini_coef_2014_todo_pais=(nnn+1)/nnn-(2/nnn)*(sumc(ingreso_2014_GINI.*((nnn+1-aux_gini_vector)))/sumc(ingreso_2014_GINI)); 

noncompetitive_taxes_2014=resultados_todo_pais_2014[2:11,2];

aux_deciles=
(aux_gini_vector .le nnn*0.10)~
(aux_gini_vector .gt nnn*0.10).*(aux_gini_vector .le nnn*0.20)~
(aux_gini_vector .gt nnn*0.20).*(aux_gini_vector .le nnn*0.30)~
(aux_gini_vector .gt nnn*0.30).*(aux_gini_vector .le nnn*0.40)~
(aux_gini_vector .gt nnn*0.40).*(aux_gini_vector .le nnn*0.50)~
(aux_gini_vector .gt nnn*0.50).*(aux_gini_vector .le nnn*0.60)~
(aux_gini_vector .gt nnn*0.60).*(aux_gini_vector .le nnn*0.70)~
(aux_gini_vector .gt nnn*0.70).*(aux_gini_vector .le nnn*0.80)~
(aux_gini_vector .gt nnn*0.80).*(aux_gini_vector .le nnn*0.90)~
(aux_gini_vector .gt nnn*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_compet_TOTAL=ingreso_2014_GINI.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_observ_TOTAL=ingreso_2014_GINI;

ahorro_competitivo=ahorro_ultima_seccion.*(1/(1-taxes_por_decil));

educacion_competitivo=educ_ultima_seccion.*(1/(1-taxes_por_decil));

salud_competitivo=salud_ultima_seccion.*(1/(1-taxes_por_decil));

diferencia_ahorro=ahorro_competitivo-ahorro_ultima_seccion;

diferencia_educacion=educacion_competitivo-educ_ultima_seccion;

perdida_ahorro_promedio=meanc(selif(diferencia_ahorro, ahorro_ultima_seccion .gt 0));

perdida_educacion_promedio=meanc(selif(diferencia_educacion, educ_ultima_seccion .gt 0));

perdida_ahorro_total=sumc(diferencia_ahorro.*factor_hogar_ultima_seccion);

perdida_educacion_total=sumc(diferencia_educacion.*factor_hogar_ultima_seccion);

perdida_ahorro_promedio=perdida_ahorro_promedio*factor_inflac_2014;

perdida_educacion_promedio=perdida_educacion_promedio*factor_inflac_2014;

perdida_ahorro_total=perdida_ahorro_total*factor_inflac_2014;

perdida_educacion_total=perdida_educacion_total*factor_inflac_2014;

ingr_90_10_observ=quantile(ingreso_2014_GINI_observ_TOTAL, 0.90)/quantile(ingreso_2014_GINI_observ_TOTAL, 0.10);
ingr_90_10_compet=quantile(ingreso_2014_GINI_compet_TOTAL, 0.90)/quantile(ingreso_2014_GINI_compet_TOTAL, 0.10);

ingr_80_20_observ=quantile(ingreso_2014_GINI_observ_TOTAL, 0.80)/quantile(ingreso_2014_GINI_observ_TOTAL, 0.20);
ingr_80_20_compet=quantile(ingreso_2014_GINI_compet_TOTAL, 0.80)/quantile(ingreso_2014_GINI_compet_TOTAL, 0.20);

ingr_70_30_observ=quantile(ingreso_2014_GINI_observ_TOTAL, 0.70)/quantile(ingreso_2014_GINI_observ_TOTAL, 0.30);
ingr_70_30_compet=quantile(ingreso_2014_GINI_compet_TOTAL, 0.70)/quantile(ingreso_2014_GINI_compet_TOTAL, 0.30);


ingreso_2014_GINI_competitive=ingreso_2014_GINI.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
/*::::::::*/
counterf_2014_GINI_todo_pais=(nnn+1)/nnn-(2/nnn)*(sumc(ingreso_2014_GINI_competitive.*((nnn+1-aux_gini_vector)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_todo_pais=(Gini_coef_2014_todo_pais-counterf_2014_GINI_todo_pais)/counterf_2014_GINI_todo_pais;

nnn_noroeste=rows(ingreso_2014_GINI_noroeste);
aux_gini_noroeste=seqa(1,1,nnn_noroeste);
Gini_coef_2014_noroeste=(nnn_noroeste+1)/nnn_noroeste-(2/nnn_noroeste)*(sumc(ingreso_2014_GINI_noroeste.*((nnn_noroeste+1-aux_gini_noroeste)))/sumc(ingreso_2014_GINI_noroeste)); 

noncompetitive_taxes_2014=resultados_noroeste_2014[2:11,2];

aux_deciles=
(aux_gini_noroeste .le nnn_noroeste*0.10)~
(aux_gini_noroeste .gt nnn_noroeste*0.10).*(aux_gini_noroeste .le nnn_noroeste*0.20)~
(aux_gini_noroeste .gt nnn_noroeste*0.20).*(aux_gini_noroeste .le nnn_noroeste*0.30)~
(aux_gini_noroeste .gt nnn_noroeste*0.30).*(aux_gini_noroeste .le nnn_noroeste*0.40)~
(aux_gini_noroeste .gt nnn_noroeste*0.40).*(aux_gini_noroeste .le nnn_noroeste*0.50)~
(aux_gini_noroeste .gt nnn_noroeste*0.50).*(aux_gini_noroeste .le nnn_noroeste*0.60)~
(aux_gini_noroeste .gt nnn_noroeste*0.60).*(aux_gini_noroeste .le nnn_noroeste*0.70)~
(aux_gini_noroeste .gt nnn_noroeste*0.70).*(aux_gini_noroeste .le nnn_noroeste*0.80)~
(aux_gini_noroeste .gt nnn_noroeste*0.80).*(aux_gini_noroeste .le nnn_noroeste*0.90)~
(aux_gini_noroeste .gt nnn_noroeste*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_noroeste.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_noroeste=(nnn_noroeste+1)/nnn_noroeste-(2/nnn_noroeste)*(sumc(ingreso_2014_GINI_competitive.*((nnn_noroeste+1-aux_gini_noroeste)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_noroeste=(Gini_coef_2014_noroeste-counterf_2014_GINI_noroeste)/counterf_2014_GINI_noroeste;


nnn_noreste=rows(ingreso_2014_GINI_noreste);
aux_gini_noreste=seqa(1,1,nnn_noreste);
Gini_coef_2014_noreste=(nnn_noreste+1)/nnn_noreste-(2/nnn_noreste)*(sumc(ingreso_2014_GINI_noreste.*((nnn_noreste+1-aux_gini_noreste)))/sumc(ingreso_2014_GINI_noreste)); 

noncompetitive_taxes_2014=resultados_noreste_2014[2:11,2];

aux_deciles=
(aux_gini_noreste .le nnn_noreste*0.10)~
(aux_gini_noreste .gt nnn_noreste*0.10).*(aux_gini_noreste .le nnn_noreste*0.20)~
(aux_gini_noreste .gt nnn_noreste*0.20).*(aux_gini_noreste .le nnn_noreste*0.30)~
(aux_gini_noreste .gt nnn_noreste*0.30).*(aux_gini_noreste .le nnn_noreste*0.40)~
(aux_gini_noreste .gt nnn_noreste*0.40).*(aux_gini_noreste .le nnn_noreste*0.50)~
(aux_gini_noreste .gt nnn_noreste*0.50).*(aux_gini_noreste .le nnn_noreste*0.60)~
(aux_gini_noreste .gt nnn_noreste*0.60).*(aux_gini_noreste .le nnn_noreste*0.70)~
(aux_gini_noreste .gt nnn_noreste*0.70).*(aux_gini_noreste .le nnn_noreste*0.80)~
(aux_gini_noreste .gt nnn_noreste*0.80).*(aux_gini_noreste .le nnn_noreste*0.90)~
(aux_gini_noreste .gt nnn_noreste*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_noreste.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_noreste=(nnn_noreste+1)/nnn_noreste-(2/nnn_noreste)*(sumc(ingreso_2014_GINI_competitive.*((nnn_noreste+1-aux_gini_noreste)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_noreste=(Gini_coef_2014_noreste-counterf_2014_GINI_noreste)/counterf_2014_GINI_noreste;


nnn_centro_norte=rows(ingreso_2014_GINI_centro_norte);
aux_gini_centro_norte=seqa(1,1,nnn_centro_norte);
Gini_coef_2014_centro_norte=(nnn_centro_norte+1)/nnn_centro_norte-(2/nnn_centro_norte)*(sumc(ingreso_2014_GINI_centro_norte.*((nnn_centro_norte+1-aux_gini_centro_norte)))/sumc(ingreso_2014_GINI_centro_norte)); 

noncompetitive_taxes_2014=resultados_centro_norte_2014[2:11,2];

aux_deciles=
(aux_gini_centro_norte .le nnn_centro_norte*0.10)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.10).*(aux_gini_centro_norte .le nnn_centro_norte*0.20)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.20).*(aux_gini_centro_norte .le nnn_centro_norte*0.30)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.30).*(aux_gini_centro_norte .le nnn_centro_norte*0.40)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.40).*(aux_gini_centro_norte .le nnn_centro_norte*0.50)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.50).*(aux_gini_centro_norte .le nnn_centro_norte*0.60)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.60).*(aux_gini_centro_norte .le nnn_centro_norte*0.70)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.70).*(aux_gini_centro_norte .le nnn_centro_norte*0.80)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.80).*(aux_gini_centro_norte .le nnn_centro_norte*0.90)~
(aux_gini_centro_norte .gt nnn_centro_norte*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_centro_norte.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_centro_norte=(nnn_centro_norte+1)/nnn_centro_norte-(2/nnn_centro_norte)*(sumc(ingreso_2014_GINI_competitive.*((nnn_centro_norte+1-aux_gini_centro_norte)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_centro_norte=(Gini_coef_2014_centro_norte-counterf_2014_GINI_centro_norte)/counterf_2014_GINI_centro_norte;


nnn_centro_sur=rows(ingreso_2014_GINI_centro_sur);
aux_gini_centro_sur=seqa(1,1,nnn_centro_sur);
Gini_coef_2014_centro_sur=(nnn_centro_sur+1)/nnn_centro_sur-(2/nnn_centro_sur)*(sumc(ingreso_2014_GINI_centro_sur.*((nnn_centro_sur+1-aux_gini_centro_sur)))/sumc(ingreso_2014_GINI_centro_sur)); 

noncompetitive_taxes_2014=resultados_centro_sur_2014[2:11,2];

aux_deciles=
(aux_gini_centro_sur .le nnn_centro_sur*0.10)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.10).*(aux_gini_centro_sur .le nnn_centro_sur*0.20)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.20).*(aux_gini_centro_sur .le nnn_centro_sur*0.30)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.30).*(aux_gini_centro_sur .le nnn_centro_sur*0.40)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.40).*(aux_gini_centro_sur .le nnn_centro_sur*0.50)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.50).*(aux_gini_centro_sur .le nnn_centro_sur*0.60)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.60).*(aux_gini_centro_sur .le nnn_centro_sur*0.70)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.70).*(aux_gini_centro_sur .le nnn_centro_sur*0.80)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.80).*(aux_gini_centro_sur .le nnn_centro_sur*0.90)~
(aux_gini_centro_sur .gt nnn_centro_sur*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_centro_sur.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_centro_sur=(nnn_centro_sur+1)/nnn_centro_sur-(2/nnn_centro_sur)*(sumc(ingreso_2014_GINI_competitive.*((nnn_centro_sur+1-aux_gini_centro_sur)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_centro_sur=(Gini_coef_2014_centro_sur-counterf_2014_GINI_centro_sur)/counterf_2014_GINI_centro_sur;


nnn_suroeste=rows(ingreso_2014_GINI_suroeste);
aux_gini_suroeste=seqa(1,1,nnn_suroeste);
Gini_coef_2014_suroeste=(nnn_suroeste+1)/nnn_suroeste-(2/nnn_suroeste)*(sumc(ingreso_2014_GINI_suroeste.*((nnn_suroeste+1-aux_gini_suroeste)))/sumc(ingreso_2014_GINI_suroeste)); 

noncompetitive_taxes_2014=resultados_suroeste_2014[2:11,2];

aux_deciles=
(aux_gini_suroeste .le nnn_suroeste*0.10)~
(aux_gini_suroeste .gt nnn_suroeste*0.10).*(aux_gini_suroeste .le nnn_suroeste*0.20)~
(aux_gini_suroeste .gt nnn_suroeste*0.20).*(aux_gini_suroeste .le nnn_suroeste*0.30)~
(aux_gini_suroeste .gt nnn_suroeste*0.30).*(aux_gini_suroeste .le nnn_suroeste*0.40)~
(aux_gini_suroeste .gt nnn_suroeste*0.40).*(aux_gini_suroeste .le nnn_suroeste*0.50)~
(aux_gini_suroeste .gt nnn_suroeste*0.50).*(aux_gini_suroeste .le nnn_suroeste*0.60)~
(aux_gini_suroeste .gt nnn_suroeste*0.60).*(aux_gini_suroeste .le nnn_suroeste*0.70)~
(aux_gini_suroeste .gt nnn_suroeste*0.70).*(aux_gini_suroeste .le nnn_suroeste*0.80)~
(aux_gini_suroeste .gt nnn_suroeste*0.80).*(aux_gini_suroeste .le nnn_suroeste*0.90)~
(aux_gini_suroeste .gt nnn_suroeste*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_suroeste.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_suroeste=(nnn_suroeste+1)/nnn_suroeste-(2/nnn_suroeste)*(sumc(ingreso_2014_GINI_competitive.*((nnn_suroeste+1-aux_gini_suroeste)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_suroeste=(Gini_coef_2014_suroeste-counterf_2014_GINI_suroeste)/counterf_2014_GINI_suroeste;


nnn_sureste=rows(ingreso_2014_GINI_sureste);
aux_gini_sureste=seqa(1,1,nnn_sureste);
Gini_coef_2014_sureste=(nnn_sureste+1)/nnn_sureste-(2/nnn_sureste)*(sumc(ingreso_2014_GINI_sureste.*((nnn_sureste+1-aux_gini_sureste)))/sumc(ingreso_2014_GINI_sureste)); 

noncompetitive_taxes_2014=resultados_sureste_2014[2:11,2];

aux_deciles=
(aux_gini_sureste .le nnn_sureste*0.10)~
(aux_gini_sureste .gt nnn_sureste*0.10).*(aux_gini_sureste .le nnn_sureste*0.20)~
(aux_gini_sureste .gt nnn_sureste*0.20).*(aux_gini_sureste .le nnn_sureste*0.30)~
(aux_gini_sureste .gt nnn_sureste*0.30).*(aux_gini_sureste .le nnn_sureste*0.40)~
(aux_gini_sureste .gt nnn_sureste*0.40).*(aux_gini_sureste .le nnn_sureste*0.50)~
(aux_gini_sureste .gt nnn_sureste*0.50).*(aux_gini_sureste .le nnn_sureste*0.60)~
(aux_gini_sureste .gt nnn_sureste*0.60).*(aux_gini_sureste .le nnn_sureste*0.70)~
(aux_gini_sureste .gt nnn_sureste*0.70).*(aux_gini_sureste .le nnn_sureste*0.80)~
(aux_gini_sureste .gt nnn_sureste*0.80).*(aux_gini_sureste .le nnn_sureste*0.90)~
(aux_gini_sureste .gt nnn_sureste*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_sureste.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_sureste=(nnn_sureste+1)/nnn_sureste-(2/nnn_sureste)*(sumc(ingreso_2014_GINI_competitive.*((nnn_sureste+1-aux_gini_sureste)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_sureste=(Gini_coef_2014_sureste-counterf_2014_GINI_sureste)/counterf_2014_GINI_sureste;

nnn_oeste=rows(ingreso_2014_GINI_oeste);
aux_gini_oeste=seqa(1,1,nnn_oeste);
Gini_coef_2014_oeste=(nnn_oeste+1)/nnn_oeste-(2/nnn_oeste)*(sumc(ingreso_2014_GINI_oeste.*((nnn_oeste+1-aux_gini_oeste)))/sumc(ingreso_2014_GINI_oeste)); 

noncompetitive_taxes_2014=resultados_oeste_2014[2:11,2];

aux_deciles=
(aux_gini_oeste .le nnn_oeste*0.10)~
(aux_gini_oeste .gt nnn_oeste*0.10).*(aux_gini_oeste .le nnn_oeste*0.20)~
(aux_gini_oeste .gt nnn_oeste*0.20).*(aux_gini_oeste .le nnn_oeste*0.30)~
(aux_gini_oeste .gt nnn_oeste*0.30).*(aux_gini_oeste .le nnn_oeste*0.40)~
(aux_gini_oeste .gt nnn_oeste*0.40).*(aux_gini_oeste .le nnn_oeste*0.50)~
(aux_gini_oeste .gt nnn_oeste*0.50).*(aux_gini_oeste .le nnn_oeste*0.60)~
(aux_gini_oeste .gt nnn_oeste*0.60).*(aux_gini_oeste .le nnn_oeste*0.70)~
(aux_gini_oeste .gt nnn_oeste*0.70).*(aux_gini_oeste .le nnn_oeste*0.80)~
(aux_gini_oeste .gt nnn_oeste*0.80).*(aux_gini_oeste .le nnn_oeste*0.90)~
(aux_gini_oeste .gt nnn_oeste*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_oeste.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_oeste=(nnn_oeste+1)/nnn_oeste-(2/nnn_oeste)*(sumc(ingreso_2014_GINI_competitive.*((nnn_oeste+1-aux_gini_oeste)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_oeste=(Gini_coef_2014_oeste-counterf_2014_GINI_oeste)/counterf_2014_GINI_oeste;

nnn_este=rows(ingreso_2014_GINI_este);
aux_gini_este=seqa(1,1,nnn_este);
Gini_coef_2014_este=(nnn_este+1)/nnn_este-(2/nnn_este)*(sumc(ingreso_2014_GINI_este.*((nnn_este+1-aux_gini_este)))/sumc(ingreso_2014_GINI_este)); 

noncompetitive_taxes_2014=resultados_este_2014[2:11,2];

aux_deciles=
(aux_gini_este .le nnn_este*0.10)~
(aux_gini_este .gt nnn_este*0.10).*(aux_gini_este .le nnn_este*0.20)~
(aux_gini_este .gt nnn_este*0.20).*(aux_gini_este .le nnn_este*0.30)~
(aux_gini_este .gt nnn_este*0.30).*(aux_gini_este .le nnn_este*0.40)~
(aux_gini_este .gt nnn_este*0.40).*(aux_gini_este .le nnn_este*0.50)~
(aux_gini_este .gt nnn_este*0.50).*(aux_gini_este .le nnn_este*0.60)~
(aux_gini_este .gt nnn_este*0.60).*(aux_gini_este .le nnn_este*0.70)~
(aux_gini_este .gt nnn_este*0.70).*(aux_gini_este .le nnn_este*0.80)~
(aux_gini_este .gt nnn_este*0.80).*(aux_gini_este .le nnn_este*0.90)~
(aux_gini_este .gt nnn_este*0.10);

taxes_por_decil=aux_deciles.*(noncompetitive_taxes_2014');
taxes_por_decil=sumc(taxes_por_decil');

ingreso_2014_GINI_competitive=ingreso_2014_GINI_este.*(1/(1-taxes_por_decil));
ingreso_2014_GINI_competitive=sortc(ingreso_2014_GINI_competitive,1);
counterf_2014_GINI_este=(nnn_este+1)/nnn_este-(2/nnn_este)*(sumc(ingreso_2014_GINI_competitive.*((nnn_este+1-aux_gini_este)))/sumc(ingreso_2014_GINI_competitive)); 

GINI_prop_diff_2014_este=(Gini_coef_2014_este-counterf_2014_GINI_este)/counterf_2014_GINI_este;

GINI_coefficients_2014=
Gini_coef_2014_todo_pais|
Gini_coef_2014_noroeste|
Gini_coef_2014_noreste|
Gini_coef_2014_centro_norte|
Gini_coef_2014_centro_sur|
Gini_coef_2014_suroeste|
Gini_coef_2014_sureste|
Gini_coef_2014_oeste|
Gini_coef_2014_este;


counterf_GINI_coefficients_2014=
counterf_2014_GINI_todo_pais|
counterf_2014_GINI_noroeste|
counterf_2014_GINI_noreste|
counterf_2014_GINI_centro_norte|
counterf_2014_GINI_centro_sur|
counterf_2014_GINI_suroeste|
counterf_2014_GINI_sureste|
counterf_2014_GINI_oeste|
counterf_2014_GINI_este;

unidades_econom_por_hogar_2014=zeros(num_hogares,1);
unidades_econom_total_2014=zeros(num_hogares,1);
empleados_por_unidad_econom_2014=zeros(num_hogares,1);
activos_por_unidad_econom_2014=zeros(num_hogares,1);
valor_agregado_por_empleado_2014=zeros(num_hogares,1);
valor_agregado_por_activos_2014=zeros(num_hogares,1);
valor_agregado_por_unidad_2014=zeros(num_hogares,1);
UE_por_hogar_CENSO_2010_2014=zeros(num_hogares,1);


noroeste=2|3|8|10|25|26;
noreste=5|19|28;
centro_norte=1|11|22|24|32;
centro_sur=9|15|17;
suroeste=7|12|20;
sureste=4|23|27|31;
oeste=6|14|16|18;
este=13|21|29|30;


noroeste_indicadora_2014=maxc((ciudad_46_mas_cercana .eq noroeste')');
noreste_indicadora_2014=maxc((ciudad_46_mas_cercana .eq noreste')');
centro_norte_indicadora_2014=maxc((ciudad_46_mas_cercana .eq centro_norte')');
centro_sur_indicadora_2014=maxc((ciudad_46_mas_cercana .eq centro_sur')');
suroeste_indicadora_2014=maxc((ciudad_46_mas_cercana .eq suroeste')');
sureste_indicadora_2014=maxc((ciudad_46_mas_cercana .eq sureste')');
oeste_indicadora_2014=maxc((ciudad_46_mas_cercana .eq oeste')');
este_indicadora_2014=maxc((ciudad_46_mas_cercana .eq este')');


i=1;
do while i .le num_hogares;
ciudad_del_hogar=ciudad_46_mas_cercana[i];
numero_unidades_economicas=unidades_economicas[ciudad_del_hogar];
poblacion_ciudad_del_hogar=selif(poblacion_hogares_46_ciudades[.,2], poblacion_hogares_46_ciudades[.,1] .eq ciudad_del_hogar);
pob_ciudad_del_hogar_CENSO_2010=poblacion_total_46_ciudades[ciudad_del_hogar];
unidades_econom_por_hogar_2014[i]=numero_unidades_economicas/poblacion_ciudad_del_hogar;
UE_por_hogar_CENSO_2010_2014[i]=numero_unidades_economicas/pob_ciudad_del_hogar_CENSO_2010;	
unidades_econom_total_2014[i]=numero_unidades_economicas;
empleados_por_unidad_econom_2014[i]=empleados_por_UE[ciudad_del_hogar];	
activos_por_unidad_econom_2014[i]=activos_fijos_por_UE[ciudad_del_hogar];
valor_agregado_por_empleado_2014[i]=valor_agregado_por_empleado[ciudad_del_hogar];
valor_agregado_por_activos_2014[i]=valor_agregado_por_activos[ciudad_del_hogar];	
valor_agregado_por_unidad_2014[i]=valor_agregado_por_unidad[ciudad_del_hogar];
i=i+1;
endo;    

aux_ciudades=seqa(1,1,46);
VE_ciudad_2014=zeros(46,1);
VE_ingr_ciudad_2014=zeros(46,1);
numero_establecimientos_2014=zeros(46,1);
tamano_ciudad_2014=zeros(46,1);
mm=1;
do while mm .le 46;
numero_establecimientos_2014[mm]=unidades_economicas[mm];    
VE_ingr_ciudad_2014[mm]=quantile((selif(VE_ingr_2014, ciudad_46_mas_cercana .eq mm)),0.5);
VE_ciudad_2014[mm]=quantile((selif(VE_2014, ciudad_46_mas_cercana .eq mm)),0.5);
tamano_ciudad_2014[mm]=poblacion_hogares_46_ciudades[mm,2];
mm=mm+1;
endo;    


VE_ciudad_2014=VE_ciudad_2014*factor_inflac_2014;

X1_2014=unidades_econom_por_hogar_2014;
X2_2014=empleados_por_unidad_econom_2014;
X3_2014=activos_por_unidad_econom_2014;
X4_2014=valor_agregado_por_empleado_2014;
X5_2014=valor_agregado_por_activos_2014;
X6_2014=valor_agregado_por_unidad_2014;
X7_2014=UE_por_hogar_CENSO_2010_2014;



Vars_1_2014=selif(VE_ingr_2014~X1_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X1_2014 .le quantile(X1_2014,0.90)));
Y1_2014=Vars_1_2014[.,1];
X1_2014=Vars_1_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X1_values_2014=quantile(X1_2014,0.01);
else;
X1_values_2014=X1_values_2014|X1_values_2014[jij-1]+(quantile(X1_2014,0.90)-quantile(X1_2014,0.01))/499;
endif;
if maxc(X1_values_2014 .le quantile(X1_2014,0.90));
jij=jij+1;
else;
jij=501;
endif;
endo;

N1=rows(Y1_2014);
N1_vals=rows(X1_values_2014);

sigma_x1=stdc(X1_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_x1*N1^(-alpha_h);

E_Y_X1_2014=zeros(N1_vals,1);

i=1;
do while i .le N1_vals;
X1_val=X1_values_2014[i];
psi=(X1_2014-X1_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X1_2014[i]=meanc(Y1_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;


Vars_2_2014=selif(VE_ingr_2014~X2_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X2_2014 .le quantile(X2_2014,0.90)));
Y2_2014=Vars_2_2014[.,1];
X2_2014=Vars_2_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X2_values_2014=quantile(X2_2014,0.01);
else;
X2_values_2014=X2_values_2014|X2_values_2014[jij-1]+(30-quantile(X2_2014,0.01))/499;
endif;
if maxc(X2_values_2014 .le 30);
jij=jij+1;
else;
jij=501;
endif;
endo;

N2=rows(Y2_2014);
N2_vals=rows(X2_values_2014);

sigma_X2=stdc(X2_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X2*N2^(-alpha_h);

E_Y_X2_2014=zeros(N2_vals,1);

i=1;
do while i .le N2_vals;
X2_val=X2_values_2014[i];
psi=(X2_2014-X2_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X2_2014[i]=meanc(Y2_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;

Vars_3_2014=selif(VE_ingr_2014~X3_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X3_2014 .le quantile(X3_2014,0.90)));
Y3_2014=Vars_3_2014[.,1];
X3_2014=Vars_3_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X3_values_2014=quantile(X3_2014,0.01);
else;
X3_values_2014=X3_values_2014|X3_values_2014[jij-1]+(quantile(X3_2014,0.90)-quantile(X3_2014,0.01))/499;
endif;
if maxc(X3_values_2014 .le quantile(X3_2014,0.90));
jij=jij+1;
else;
jij=501;
endif;
endo;

N3=rows(Y3_2014);
N3_vals=rows(X3_values_2014);

sigma_X3=stdc(X3_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X3*N3^(-alpha_h);

E_Y_X3_2014=zeros(N3_vals,1);

i=1;
do while i .le N3_vals;
X3_val=X3_values_2014[i];
psi=(X3_2014-X3_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X3_2014[i]=meanc(Y3_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;


Vars_4_2014=selif(VE_ingr_2014~X4_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X4_2014 .le quantile(X4_2014,0.90)));
Y4_2014=Vars_4_2014[.,1];
X4_2014=Vars_4_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X4_values_2014=quantile(X4_2014,0.01);
else;
X4_values_2014=X4_values_2014|X4_values_2014[jij-1]+(quantile(X4_2014,0.90)-quantile(X4_2014,0.01))/499;
endif;
if maxc(X4_values_2014 .le quantile(X4_2014,0.90));
jij=jij+1;
else;
jij=501;
endif;
endo;

N4=rows(Y4_2014);
N4_vals=rows(X4_values_2014);

sigma_X4=stdc(X4_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X4*N4^(-alpha_h);

E_Y_X4_2014=zeros(N4_vals,1);

i=1;
do while i .le N4_vals;
X4_val=X4_values_2014[i];
psi=(X4_2014-X4_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X4_2014[i]=meanc(Y4_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;

Vars_5_2014=selif(VE_ingr_2014~X5_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X5_2014 .le quantile(X5_2014,0.90)));
Y5_2014=Vars_5_2014[.,1];
X5_2014=Vars_5_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X5_values_2014=quantile(X5_2014,0.01);
else;
X5_values_2014=X5_values_2014|X5_values_2014[jij-1]+(quantile(X5_2014,0.90)-quantile(X5_2014,0.01))/499;
endif;
if maxc(X5_values_2014 .le quantile(X5_2014,0.90));
jij=jij+1;
else;
jij=501;
endif;
endo;

N5=rows(Y5_2014);
N5_vals=rows(X5_values_2014);

sigma_X5=stdc(X5_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X5*N5^(-alpha_h);

E_Y_X5_2014=zeros(N5_vals,1);

i=1;
do while i .le N5_vals;
X5_val=X5_values_2014[i];
psi=(X5_2014-X5_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X5_2014[i]=meanc(Y5_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;

Vars_6_2014=selif(VE_ingr_2014~X6_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X6_2014 .le quantile(X6_2014,0.90)));
Y6_2014=Vars_6_2014[.,1];
X6_2014=Vars_6_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X6_values_2014=quantile(X6_2014,0.01);
else;
X6_values_2014=X6_values_2014|X6_values_2014[jij-1]+(4000-quantile(X6_2014,0.01))/499;
endif;
if maxc(X6_values_2014 .le 4000);
jij=jij+1;
else;
jij=501;
endif;
endo;

N6=rows(Y6_2014);
N6_vals=rows(X6_values_2014);

sigma_X6=stdc(X6_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X6*N6^(-alpha_h);

E_Y_X6_2014=zeros(N6_vals,1);

i=1;
do while i .le N6_vals;
X6_val=X6_values_2014[i];
psi=(X6_2014-X6_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X6_2014[i]=meanc(Y6_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;


Vars_7_2014=selif(VE_ingr_2014~X7_2014, (VE_ingr_2014 .le quantile(VE_ingr_2014, 0.90)).*(X7_2014 .le quantile(X7_2014,0.90)));
Y7_2014=Vars_7_2014[.,1];
X7_2014=Vars_7_2014[.,2];

jij=1;
do while jij .le 500;
if jij .eq 1;
X7_values_2014=quantile(X7_2014,0.01);
else;
X7_values_2014=X7_values_2014|X7_values_2014[jij-1]+(quantile(X7_2014,0.90)-quantile(X7_2014,0.01))/499;
endif;
if maxc(X7_values_2014 .le quantile(X7_2014,0.90));
jij=jij+1;
else;
jij=501;
endif;
endo;

N7=rows(Y7_2014);
N7_vals=rows(X7_values_2014);

sigma_X7=stdc(X7_2014);
C_h=4;
alpha_h=1/5;
bandwidth_1=C_h*sigma_X7*N7^(-alpha_h);

E_Y_X7_2014=zeros(N7_vals,1);

i=1;
do while i .le N7_vals;
X7_val=X7_values_2014[i];
psi=(X7_2014-X7_val)/bandwidth_1;
kernel_vector=pdfn(psi);
E_Y_X7_2014[i]=meanc(Y7_2014.*kernel_vector)/meanc(kernel_vector);	
i=i+1;
endo;


if hsec .ge tinit;
totaltime=(hsec-tinit)/100;
else;
totaltime=(8640000+hsec-tinit)/100;
endif;
