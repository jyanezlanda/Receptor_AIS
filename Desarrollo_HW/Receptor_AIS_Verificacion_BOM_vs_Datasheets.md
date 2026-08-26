# Receptor AIS — Verificación cruzada Esquemático/BOM vs. datasheets

**Revisión pre-fabricación.** Todos los hallazgos son correcciones a aplicar en el proyecto Altium antes de fabricar.

| | |
|---|---|
| Fuentes | `Esquematicos_Receptor_AIS.pdf`, `RECEPTOR_AIS_BOM.csv`, `Receptor_AIS_Netlist.NET` |
| Plan de frecuencias | RF = 162 MHz → FI = 8 MHz; f_s = 125 MSPS; LO = 154 MHz (banda baja) |
| Rail intermedio | 3.97 V (confirmado; la anotación "3.5V output" es obsoleta) |
| DNP | Sin componentes DNP — comparación omitida |
| Jerarquía | 2 niveles: `RECEPTOR_AIS_BLK_R00` → {HF, DEMOD, FI, PWR}. 126 componentes, 66 redes |

## Criterio de severidad

| Nivel | Alcance |
|---|---|
| **Crítico** | Prioridades 1–3: configuración/funcionalidad de un IC, componentes que lo habilitan, fuentes de alimentación. También lo que impide fabricar, montar o comprar. |
| **Medio** | Prioridad 4 (control digital) y degradaciones de performance o márgenes de derating ajustados. |
| **Cosmético** | Prioridad 5 y consistencia de documentación/trazabilidad sin impacto eléctrico. |

## Orden de procesamiento aplicado

1. PWR (U6, U8, U5, U7) → 2. DEMOD/integrados (U9, U2) → 3. HF (U1, FB1, T1) → 4. DEMOD/control digital (J3, SPI/I²C) → 5. FI (T2/T3, filtro) → 6. BLK + transversales de BOM

---

# 1. Hoja PWR — `RECEPTOR_AIS_PWR_R00`

Datasheets consultados: TI **SLVSFM1A** (TPS62902, rev. nov-2023), ADI **LT3045 Rev. D**.

| Hoja | RefDes | Campo | Esquemático | BOM actual | Sev. | Nota |
|---|---|---|---|---|---|---|
| PWR | U5 | Encapsulado | Footprint `DD_05-08-1699_ADI` = **DFN-10 3×3**; el símbolo tiene IN en pines 1-2, que es la numeración DD | `LT3045EMSE#TRPBF` = **MSOP-12** (MSE, DWG 05-08-1666) | **Crítico** | El land pattern del PCB y la parte comprada son encapsulados distintos. No monta. Orderable coherente: `LT3045EDD#TRPBF` (o `LT3045IDD#TRPBF` para rango I). |
| PWR | C55 | Capacidad efectiva | 10 µF 25 V X5R 0805 en OUT del LT3045 | ídem (`C0805C106K3PACTU`) | **Crítico** | El datasheet exige **mínimo 10 µF efectivos**, ESR < 20 mΩ, ESL < 2 nH. Con derating por DC bias un 0805 de 25 V a 3.3 V cae a ~7–8 µF, y con tolerancia −10/−20 % queda por debajo del mínimo → riesgo de inestabilidad del rail principal. ADI recomienda explícitamente la serie Murata GJ8 por su coeficiente de tensión. Pasar a 22 µF o caso 1210. |
| PWR | U5 | Margen de corriente | LT3045 = 500 mA máx | — | **Crítico** | El ADRF6850 consume **350 mA típ / 440 mA máx**. Sumado a U2 → ~445 mA = **89 % del máximo del LDO**, sin margen para crecimiento ni para tolerancias. El límite interno con R_ILIM = 0 Ω está en ~700–900 mA, así que no habría corte espurio, y el headroom (670 mV) supera el dropout máximo a 500 mA (450 mV). Pero es un diseño sin reserva: evaluar paralelar dos LT3045 (el datasheet lo contempla con ballast de 20 mΩ) o medir el consumo real. |
| PWR | C50, C57 | Tensión / derating | 22 µF 10 V X5R 0805 | ídem | Medio | TPS62902 a 1 MHz pide C_O **efectiva** de 6 (mín) / 22 (nom) / 50 (máx) µF. Con 5.4 V sobre un X5R de 10 V la efectiva cae a ~7–9 µF, al filo del mínimo de 6 µF. El propio datasheet advierte: "For large output voltages, the dc bias effect of ceramic capacitors is large and the effective capacitance has to be observed". Pasar a 16 V/25 V o duplicar. |
| PWR | C51, C56 | Derating | 10 µF 25 V X5R 0805 con VIN = 12 V | ídem | Medio | C_I efectiva mínima = 3 µF; con derating a 12 V quedan ~5–6 µF. Pasa, pero justo. |
| PWR | R25 | Tolerancia | "140 kΩ **0.1 %**" | `RCS0603140KFKEA` (Vishay; el sufijo **F** indica ±1 %) | Medio | El MPN no cumple la tolerancia especificada, y R25 fija directamente los 3.97 V. Alternativa coherente con R21: `RT0603BRE07140KL` (Yageo RT, ±0.1 %, 25 ppm). *Pendiente de confirmar contra el datasheet Vishay RCS.* |
| PWR | R25 | Potencia | "1/2 W", footprint `R_0603` | `RCS0603140KFKEA` | Cosmético | La serie RCS0603 no es de 1/2 W. Corregir la anotación (en un divisor de realimentación la potencia es irrelevante de todos modos: ~0.11 mW). |
| PWR | D2 / R30 | Corriente de LED | 100 Ω desde +5 V | `CRCW0603-100RFKEA` (CRCW0603 = **0.1 W**) | Medio | I_LED ≈ (5.0−2.1)/100 = **29 mA**, por encima de los 20–25 mA típicos de un LED verde 0805. P_R30 ≈ 86 mW = **86 % de la potencia nominal del 0603**. Subir a 330 Ω (≈9 mA, 8 mW). |
| PWR | D1 / R29 | Corriente de LED | 100 Ω desde +3.3 V | ídem | Medio | ≈13 mA consumidos de un LDO que ya está al 89 % de su capacidad. Subir a 1 kΩ (≈1.3 mA). |
| PWR | C53 / R22 | Tiempo de arranque | C_SET = 4.7 µF, R_SET = 33.2 kΩ | — | Medio | t_SS ≈ 2.3·R_SET·C_SET = **≈ 360 ms** hasta el 90 % de V_OUT. Además, con PGFB atado a IN el **fast start-up queda deshabilitado** (bajaría a ~10 ms). El C_SET de 4.7 µF es la elección correcta para los 0.8 µV_RMS de ruido, pero hay que contemplar el retardo: si el host intenta hablar SPI apenas aparecen los 12 V, va a fallar. Documentar el requisito de retardo de arranque. |
| PWR | J7 / entrada 12 V | Protección | Bornera a tornillo, sólo cerámicos | — | Medio | Sin protección de polaridad inversa ni TVS. El abs max de VIN del TPS62902 es 18 V; un hot-plug de 12 V sobre capacidad puramente cerámica puede repicar hasta ~2×. Agregar TVS (SMBJ15A o similar) y/o un electrolítico de amortiguación. |
| PWR | F1 | Valor | 2 A 32 VDC 0603 | `F0603E2R00FSTR` | Medio | Consumo estimado: 5.0 V×180 mA + 3.97 V×450 mA ≈ 2.7 W → ~255 mA desde 12 V con ~88 % de eficiencia. Un fusible de 2 A es ~8× la corriente nominal: no protege nada. Bajar a 500 mA – 1 A. |
| PWR | J7 | MPN / Comentario | Comment = `691412320004` | MPN = `691210910004`; footprint del PCB = `691210910004` | Cosmético | Footprint y BOM coinciden entre sí; el outlier es el Comment del esquemático. |
| PWR | U5/U6/U8 | PG sin conectar | Los 3 pines PG al aire | — | Cosmético | **Permitido por ambos datasheets** (TI: "tie to GND or leave it open"; ADI: "float the PG pin"). Pero se pierde toda supervisión de rails. Recomendado: llevarlos a pines libres de J3 o a test points, con pull-up. |
| PWR | U5 | PGFB | PGFB (pin 6) atado a VIN_LDO_3.3V | — | Cosmético | **Configuración documentada** ("Tie PGFB to IN if power good and fast start-up functionalities are not needed"). Nota del datasheet: para conservar la protección de entrada inversa hay que intercalar un 1N4148 (ánodo a IN, cátodo a PGFB). No está. Irrelevante acá porque IN viene de un buck, no de una batería. |
| PWR | R21/R24, R25/R27 | Tolerancias mezcladas | 0.1 % arriba, 1 % abajo | ídem | Cosmético | La exactitud del rail queda dominada por el resistor de 1 %. No tiene sentido pagar 0.1 % en el de arriba. Igualar ambos. |
| PWR | Hoja | Anotación | "3.5V output" | — | Cosmético | Confirmado obsoleto. Debe decir 3.97 V. |

### Verificado correcto en PWR

- **R23/R26 = 16.9 kΩ** en MODE/S-CONF → Tabla 7-1, opción **#7**: FB externo, f_SW = 1 MHz, sin descarga de salida, auto PFM/PWM. Es la configuración que el divisor externo requiere.
- **L11/L12 (2.2 µH) + C50/C57 (22 µF)**: Tabla 8-3 la marca como la combinación estándar recomendada para 1 MHz.
- **C54/C60 = 3300 pF** → t_SS = (C_SS/I_SS)·V_REF + 55 = (3300/2.5)·0.8 + 55 ≈ **1.11 ms**, por encima del piso de 1 ms que recomienda TI para inrush.
- **Divisores**: V_FB = 0.6 V. R21/R24 → 0.6·(1+200/24.9) = **5.419 V** ✓. R25/R27 → 0.6·(1+140/24.9) = **3.973 V** ✓. Ambos R2 muy por debajo del tope de 400 kΩ.
- **EN de U6/U8 a 12 V**: abs max del pin EN = 18 V ✓, y el datasheet exige que EN no quede flotante.
- **VOS de U6/U8** conectado al positivo del capacitor de salida ✓.
- **ILIM de U5 a GND** ✓ — "If the programmable current limit functionality is not needed, tie ILIM to GND".
- **R22 = 33.2 kΩ** → V_OUT = 100 µA × 33.2 k = 3.32 V. Es el valor exacto de la Tabla 1 del datasheet para 3.3 V.
- **C52 = 4.7 µF** en IN del LT3045 ✓ (mínimo 4.7 µF), con 22 µF adicionales aguas arriba.
- **EN/UV a IN** ✓, **OUTS a OUT** ✓ (ambos son la recomendación explícita).
- **Headroom**: 3.97 − 3.3 = 670 mV, contra 260 mV típ / 450 mV máx de dropout a 500 mA ✓.
- **Disipación del LT3045**: 0.45·(3.97−3.3) + 15 mA·3.97 ≈ **0.36 W**; con θ_JA ≈ 35 °C/W (DFN) → ΔT ≈ 13 °C ✓.
- **U7**: C58 (1 µF) en IN, C59 (10 µF) en OUT ✓. Carga de +5 V ≈ 180 mA sobre 500 mA ✓.

---

# 2. Hoja DEMOD — `RECEPTOR_AIS_DEMOD_R00` (integrados)

Datasheet consultado: ADI **ADRF6850 Rev. A** (7/2022).

| Hoja | RefDes | Campo | Esquemático | BOM actual | Sev. | Nota |
|---|---|---|---|---|---|---|
| DEMOD | U9 pin 43 (VGAIN) | Polarización | Sólo J2 (SMA) + C11 (10 nF) + C14 (0.1 µF) a GND. **Sin camino DC de referencia** | — | **Crítico** | Datasheet: "Drive this pin by a voltage in the range from 0 V to 1.5 V", Z_in = 20 kΩ, pendiente 25 mV/dB. Si J2 queda sin conectar, la ganancia del VGA (rango de 60 dB) queda indefinida. Agregar divisor por defecto a GND (0 V = 0 dB con CR30 bit 2 = 0) o un DAC, dejando J2 como override. |
| DEMOD | R18 (51 Ω) | Carga del oscilador | U2 OUT → R28 (0 Ω) → C41 (1 nF) → nodo con **R18 51 Ω a GND** → C42 → REFIN | — | **Crítico** | REFIN es "AC couple this **high impedance CMOS input**" (C_in = 10 pF, I_in ±100 µA). **No requiere terminación de 50 Ω** — el 51 Ω es un artefacto del EVB, que inyecta la referencia por SMA desde una fuente de 50 Ω. Con C41 (11.8 Ω a 13.5 MHz) el DSC1001 ve ~52 Ω de carga, decenas de mA de pico, muy fuera de spec para un MEMS CMOS. Reemplazar por un atenuador de alta impedancia (p.ej. 1 kΩ serie + 1 kΩ a GND) que además deje ~1.6 V_pp, dentro del máximo de V_CC especificado para REFIN. |
| DEMOD | J8 / R28 | Conflicto de fuentes | J8 (SMA) queda en paralelo directo con la salida de U2 vía R28 (0 Ω, montado) | `CRCW06030000Z0EAHP` | **Crítico** | Si se inyecta referencia externa por J8, pelea contra el driver del oscilador on-board. Definir una estrategia de montaje mutuamente excluyente (R28 poblado *o* J8 usado) y documentarla en el esquemático. |
| DEMOD | L4, L5 | Footprint | Footprint `L_0805`; el valor dice "20 nH **0402** 370 mA" | `LQW15AN20NH00D` = Murata LQW15A = **0402** | **Crítico** | Land pattern 0805 con componente 0402. Alinear footprint y MPN. |
| DEMOD | L3, L6 | Footprint | Footprint `L_0805`; valor "10 µH 0805 300 mA" | `LQM18DN100M70L` — la serie LQM18 es **0603** | **Crítico** | Mismo patrón que L4/L5. *Pendiente confirmar tamaño y corriente nominal exactos del MPN.* La corriente real por esta rama es ~33 mA (3.3 V/100 Ω), así que el rating no preocupa; el tamaño sí. |
| DEMOD | C12, C61, C62, C63 | Valor | 1 nF a GND sobre CLK/SCL, SDI/SDA, SDO y CS | — | **Crítico** | El datasheet especifica C_IN = 10 pF en esos pines; 1 nF es 100× eso. En **SDO** (salida) V_OH está especificado a I_OH = 500 µA: cargar 1 nF hasta 2.8 V lleva ~5.6 µs, o sea lectura de registros limitada a <100 kHz contra los 20 MHz de spec. En **I²C**, 1 nF por línea excede 2.5× el límite de 400 pF de capacidad de bus. Quitarlos; si hace falta control de flancos, usar resistencias serie de 33–100 Ω. Sin interfaz digital no se pueden escribir CR29/CR30/CR0 y el demodulador nunca arranca — de ahí la severidad. |
| DEMOD | SDA / SCL | Pull-ups | Sin pull-ups en SDI/SDA ni CLK/SCL | — | **Crítico** | El ADRF6850 **arranca en modo I²C** ("The part powers up in I2C mode but is not locked in this mode"). Con CS en alto (pull-up de 330 Ω) la dirección de esclavo es 0x78. Pero sin pull-ups en SDA/SCL el bus I²C no puede funcionar. Si el modo previsto es SPI, hay que mandar **3 pulsos a CS** para engancharlo y luego mantener CS bajo durante toda la comunicación — decidir el modo y poblar en consecuencia (SPI: sin caps, R10 = 10 k; I²C: pull-ups de 2.2–4.7 k, sin caps). |
| DEMOD | R10 | Valor | 330 Ω como pull-up de CS a +3.3 V | — | Medio | Obliga al driver del host a hundir 10 mA para llevar CS a nivel bajo (V_INL de CS = 0.6 V). Subir a 10 kΩ. |
| DEMOD | U9 pin 40 (LDET) | Sin conectar | Pin al aire, sin test point ni ruta a J3 | — | Medio | LDET es la **única** indicación de enganche del PLL por hardware: el mapa de registros no expone un bit de lectura de lock (CR31/CR32 son reserved, CR33 es revision code). Sin esto no hay forma de validar el enganche en banco. Llevar a un pin libre de J3 o a un test point. |
| DEMOD | C13, C18, C21, C23 | Tensión | 100 nF **6.3 V** X5R en las salidas de banda base | `GMC10X5R104K6R3NT` | Medio | El common-mode de banda base es 1.2–1.6 V, así que la tensión de trabajo está bien, pero 6.3 V en X5R deja poco margen de derating. Pasar a 16 V/25 V (mismo costo, mejor capacidad efectiva). |
| DEMOD | R7, R8, R9, R31, R32, C29, C30, C31, C34 | Valores | Filtro de lazo de 4º orden con pines de fastlock LF2/LF3 | — | Medio | La topología es coherente con el EVB, pero **los valores no están verificados** para LO = 154 MHz / f_PFD = 27 MHz / I_CP = 2.5 mA. Correr ADIsimPLL con K_VCO ≈ 15 MHz/V. Datos ya calculados: RFDIV = ÷4 (rango 125–250 MHz, CR28[2:0] = 010), N = (4×2×154)/27 = 45.63 → INT = 45, FRAC = 21.124.464. Verificar también BSCDIV = 112 (CR25 = 0x70) que corresponde a 100 µs con f_PFD = 27 MHz ✓. |
| DEMOD | L4/R14/R17/L6 vs L5/R16/R15/L3/C43 | Simetría | Sólo el lado del pin 26 (LOMON) sale a J4 vía C43; el lado del pin 25 termina en R17/L6 sin salida | — | Medio | Carga asimétrica del par diferencial de monitoreo. Las terminaciones de 51 Ω a +3.3 V sí son correctas (el datasheet exige terminar los open-collector a VCCx). Es un monitor, así que el impacto es acotado — pero conviene igualar las cargas o documentar la asimetría. |
| DEMOD | U2 | Desacople | Sin capacitor de desacople dedicado en VDD | — | Medio | Los 9 pares 0.1 µF + 56 pF están asignados 1:1 a los 9 pines VCCx del U9. U2 se cuelga del rail sin capacitor adyacente. Agregar 0.1 µF. |
| DEMOD | J3 | Pinout | 1-4 = GND agrupados; cada señal duplicada en pines adyacentes (5-6 CLK, 7-8 SDI, 9-10 SDO, 11-12 CS) | `SPI_2X6_CONN` sin MPN | Medio | En cable plano, duplicar cada señal en pines contiguos maximiza la diafonía; lo habitual es alternar señal/GND. Tampoco hay +3.3 V en el conector. Y falta el MPN. |
| DEMOD | R10, R14, R16, R18 | Anotación | Footprint `R_0805`, anotación "1/16 W" | `CR0805-FX-51R0ELF` (0805) ✓ | Cosmético | Footprint y MPN coinciden (0805); lo inconsistente es el texto "1/16 W", que corresponde a un 0402. Corregir la anotación. |
| DEMOD | U9 pin 39 (MUXOUT) | Sin conectar | Al aire | — | — | **Correcto**: "This output is a test output for diagnostic use only. Allow this pin to remain open circuit." |

### Verificado correcto en DEMOD

- **VOCM (pin 7) a GND** ✓ — es exactamente lo que pide el datasheet: "When ac coupling the baseband output pins, ground VOCM". **Dependencia de firmware**: hay que poner **CR29 bit 6 = 1** (referencia VOCM interna). El write inicial recomendado ya lo contempla (CR29 = 0x41).
- **R6 = 4.7 kΩ en RSET** ✓ — valor exacto del datasheet: I_CP,max = 23.5/R_SET = 5 mA.
- **C26/C27/C28 = 100 nF en CCOMP1/2/3** ✓ — "This pin must be decoupled to ground with a 100 nF capacitor". Los tres coinciden.
- **TESTLO/TESTLO (pines 22, 23) a GND** ✓ — "For internal use only. These pins should be grounded."
- **REFIN (pin 18) a GND** ✓ — "Reference Input Bar. Ground this pin."
- **U2 = DSC1001DL2-013.5000 (13.5 MHz)**: es literalmente la condición de referencia del datasheet del ADRF6850 (REFIN = 13.5 MHz, PFD = 27 MHz con doubler habilitado). Rango de REFIN: 10–165 MHz sin ÷2 ✓. La configuración de registros recomendada (CR10 = 0x21) habilita el doubler y saltea los divisores → 27 MHz ✓, dentro del rango de PFD de 10–30 MHz ✓.
- **U2 pin 1 (\*STANDBY) y pin 4 (VDD) a +3.3 V** ✓ (habilitado).
- **9 pares 0.1 µF + 56 pF para los 9 VCCx** ✓ — "Decouple each pin with a power supply decoupling capacitor."
- **C9 = 10 µF tantalio 25 V (TAJ-C)** como bulk del rail de 3.3 V ✓, con buen derating.
- **Ancho de banda de banda base**: 50 MHz en narrow-band (default), configurable a 43/37/30 MHz. La FI de 8 MHz queda holgada ✓. Sugerencia: usar el corte de 30 MHz (CR29[5:4] = 11) para ayudar al anti-alias.
- **Rango de entrada RF 100–1000 MHz** → 162 MHz ✓. NF = 11 dB a ganancia > 39 dB.
- **Exposed paddle a plano de masa** ✓ (pin 57 en GND).

---

# 3. Hoja HF — `RECEPTOR_AIS_HF_R00`

Datasheets consultados: Mini-Circuits **TSS-13LN+ Rev. B**, Mini-Circuits **ADT2-1T+ Rev. F**.

| Hoja | RefDes | Campo | Esquemático | BOM actual | Sev. | Nota |
|---|---|---|---|---|---|---|
| HF | R1 + C3 | Topología | R1 (1.5 kΩ) en serie con C3 (0.1 µF) conectan **RF-IN (U1 pin 3) con RF-OUT/DC-IN (U1 pin 7)** | `RC0603FR-071K5L`, `C0603C104K4RACTU` | **Crítico** | En el circuito de aplicación recomendado del TSS-13LN+, **R1/C1/C2 pertenecen a la red del pin VG** (control de shutdown), no a un lazo de realimentación. Tal como está cableado: a 162 MHz C3 es un cortocircuito (X_C = 9.8 mΩ) y R1 queda como realimentación resistiva de 1.5 kΩ alrededor de un amplificador de ~24 dB. β = 50/1550 = 0.032 → A·β ≈ 0.52 → **~3.6 dB de pérdida de ganancia**, degradación de la NF y de la adaptación de entrada (Z_in cae a ~33 Ω). Con el presupuesto de NF de ~2 dB del receptor AIS, es significativo. Notar que la numeración de RefDes del diseño (C1–C7, L1, L2, R1) coincide exactamente con la del circuito de aplicación de Mini-Circuits: es muy probable que se haya copiado el circuito y R1/C3 hayan quedado en la red equivocada. **Confirmar la intención antes de tocar.** |
| HF | C4, C5 | Valor / dieléctrico | 2.2 µF 16 V X5R 0603 como bloqueos de DC de RF | — (sin MPN) | Medio | A 162 MHz un 0603 de 2.2 µF está muy por encima de su SRF (~3–5 MHz): se comporta como inductor con ESR poco controlada. El impacto cuantitativo es chico (<0.1 dB de pérdida), pero **C4 está en la entrada, donde la NF importa**, y los X5R son microfónicos. Pasar a 1 nF–100 nF C0G/X7R 0402. |
| HF | L2, C6 | Valor | L2 = 5.1 nH serie, C6 = 1.5 pF shunt, antes del LNA | `LQW18AS5N1J00D`, sin MPN | Medio | A 162 MHz: Z_L2 = j5.2 Ω, Z_C6 = −j655 Ω → **prácticamente transparentes**. Los valores corresponden a una red de adaptación de banda de GHz. El TSS-13LN+ está internamente adaptado a 50 Ω de 1 MHz a 1 GHz (return loss de entrada 15 dB a 20 MHz), así que no hace falta adaptación externa. Como están no rompen nada, pero agregan parásitos justo en el punto más sensible en NF. Dejar como 0 Ω/no poblado o quitar. |
| HF | FB1 (TA0395A) | Red de adaptación | Conectado directo: pin 7 a C5, pin 2 a T1; pines 1,3,4,5,6,8,9,10 a GND | `TA0395A` | Medio, a verificar | **Pendiente**: no pude verificar el datasheet de Tai-Saw. La mayoría de los SAW de 156–162 MHz especifican una red de adaptación (L serie / C shunt) hacia 50 Ω; omitirla degrada la pérdida de inserción y el ripple en banda. Verificar también el pinout (cuál pin es entrada y cuál salida) y el patrón de masas. |
| HF | U1 pin 1 (VG) | Shutdown | VG atado duro a GND | — | Cosmético | Correcto para "siempre encendido" (ver abajo), pero se pierde la función de shutdown que el propio nombre del componente publicita. Si querés usarla, hace falta la red del datasheet y una línea de control. |
| HF | T1 pin 2 | Pin no usado | Pin 2 conectado a GND | — | Cosmético | El datasheet lo lista como **"NOT USED"**. Aterrizarlo es inocuo, pero lo estrictamente correcto es dejarlo al aire. |

### Verificado correcto en HF — y una trampa de polaridad

- **VG a GND = amplificador ENCENDIDO.** El datasheet especifica: *Amplifier-ON = 0 a +0.7 V; Amplifier-OFF = +1.9 a +5 V*. La polaridad es la **inversa** de lo intuitivo: masa habilita. La conexión del diseño es correcta.
- **Pines NC (2, 4-6, 8-12) a GND** ✓ — "No connection, grounded externally".
- **Rango 1 MHz – 1 GHz**, NF = 1.1 dB a 20–500 MHz, ganancia ~24 dB a 20 MHz ✓. 162 MHz está en el centro del rango útil.
- **V_DD = +5 V en el pin 7 vía L1** ✓. I_D = 142–151 mA a +5 V → L1 (15 µH, 300 mA) tiene margen ✓. Disipación 0.755 W con θ = 23.3 °C/W → ΔT ≈ 18 °C: **el paddle debe estar bien soldado a masa con vías térmicas**.
- **C1 (10 µF) + C2 (1 nF) de desacople del +5 V** ✓, coherente con C6/C7 del circuito de aplicación.
- L1 a 162 MHz: por encima de su SRF (~20–25 MHz) presenta ~360 Ω reactivos en shunt sobre la línea de 50 Ω → pérdida ≈ 0.02 dB. **Aceptable**, no es hallazgo.
- **T1 (ADT2-1T+) está cableado 100 % correcto.** Pin connections del datasheet vs. netlist:

| Pin | Datasheet ADT2-1T+ | Netlist | ¿OK? |
|---|---|---|---|
| 1 | PRIMARY | GND | ✓ |
| 2 | NOT USED | GND | ✓ (inocuo) |
| 3 | PRIMARY DOT | FB1-2 (salida del SAW) | ✓ |
| 4 | SECONDARY | U9-55 (RFI) | ✓ |
| 5 | SECONDARY CT | U9-53 (RFCM) + C7 | ✓ |
| 6 | SECONDARY DOT | U9-51 (RFI) | ✓ |

  Relación de impedancias 2:1 → 50 Ω primario a **100 Ω diferencial** en secundario, que es exactamente la Z_L con la que está especificado el ADRF6850. Rango 0.4–450 MHz (1 dB BW: 1–200 MHz), IL ≈ 0.5 dB a 162 MHz ✓.
- **C7 = 10 nF en RFCM** ✓ — el ADRF6850 pide literalmente decoupling de 10 nF en RFCM, y el CT del balun conectado a RFCM es la configuración diferencial del datasheet: "When driving the input differentially using a balun, connect this pin to the common terminal of the output coil of the balun."

---

# 4. Hoja FI — `RECEPTOR_AIS_FI_R00`

Datasheet consultado: MACOM **MABAES0060** (equivalente al ETC1-1T).

| Hoja | RefDes | Campo | Esquemático | BOM actual | Sev. | Nota |
|---|---|---|---|---|---|---|
| FI | T2, T3 | Relación de impedancias | Balun **1:1** entre las salidas de banda base y un filtro de 50 Ω | `MABAES0060` | **Crítico** | El ADRF6850 está especificado con **Z_L = 100 Ω diferencial** (Z_out diferencial = 28 Ω; swing de 2.5 V_pp definido sobre 100 Ω). Con un balun 1:1 y un filtro de 50 Ω, el chip ve **~50 Ω diferenciales**: el divisor cae de 100/128 = 0.781 a 50/78 = 0.641 → **≈ 1.7 dB menos de ganancia de conversión** y swing máximo reducido. Además el filtro Butterworth queda excitado por una fuente de 28 Ω en vez de 50 Ω → **ripple en la banda de paso** y corrimiento del corte. Opciones: (a) balun 1:2 (equivalente a ADT2-1T+/TC2-1T+ en el rango 0.3–200 MHz), o (b) rediseñar el filtro para 25 Ω de fuente. |
| FI | T2, T3 | Pinout | Diseño usa 1/3 como par balanceado, 2 y 5 a GND, 4 como salida single-ended | `MABAES0060`, footprint `MABAES0060_MCM` | **Crítico**, a verificar | **Pendiente**: no pude obtener la tabla de pin connections del SM-22-5. Es exactamente el mismo tipo de riesgo que resolví en T1 — verificarlo contra el datasheet MACOM antes de fabricar. |
| FI | L7–L10 | MPN | 820 nH 0805 180 mA | **sin MPN** | **Crítico** (compra) | Además del MPN faltante: en un Butterworth de 5º orden la tolerancia importa. Especificar ±5 % o mejor y verificar el Q (un 0805 de 820 nH con Q bajo redondea la esquina del filtro). |
| FI | C15, C46, C47, C49, C22, C48 | MPN | 130 pF y 430 pF 100 V C0G | **sin MPN** | **Crítico** (compra) | El dieléctrico C0G y la tolerancia ±5 % ya están implícitos en el valor, pero hay que fijar el MPN. |
| FI | R19, R20 / J5, J6 | Terminación | 50 Ω a GND en la salida del filtro, en paralelo con el conector SMA | `RT0603BRE0750RL` | Medio | Si el destino es el Red Pitaya STEMlab (entradas de alta impedancia), R19/R20 **son** la terminación correcta ✓. Pero si se conecta un instrumento de 50 Ω, la carga baja a 25 Ω → ~6 dB de pérdida y desadaptación del filtro. Documentarlo en la hoja o en el manual de banco. |

### Verificado correcto en FI

- **Filtro LC**: C15(130p) – L7(820n) – C22(430p) – L8(820n) – C46(130p), terminado en R19 (50 Ω). Es un **Butterworth de 5º orden, 50 Ω, f_c ≈ 15.1 MHz**:
  - g1 = 0.618 → C = 0.618/(2π·f_c·50) = 130 pF ✓
  - g2 = 1.618 → L = 1.618·50/(2π·f_c) = 851 nH → 820 nH (−3.6 %) ✓
  - g3 = 2.000 → C = 2.0/(2π·f_c·50) = 421 pF → 430 pF (+2 %) ✓

  Muy buena elección para FI = 8 MHz con muestreo a 125 MSPS: deja pasar los 8 MHz con margen y ataca el alias con 100 dB/década. Las dos cadenas (I y Q) son idénticas ✓.
- **MABAES0060: 300 kHz – 200 MHz** ✓ cubre 8 MHz holgadamente. IL 1.5 dB máx.
- **C13/C18/C21/C23 (100 nF) de acoplo**: f_corte alta = 1/(2π·50·100n) = 32 kHz → totalmente transparente a 8 MHz ✓.

---

# 5. Hoja BLK y hallazgos transversales de BOM

| Hoja | RefDes | Campo | Esquemático | BOM actual | Sev. | Nota |
|---|---|---|---|---|---|---|
| Todas | 13 líneas | MPN / Fabricante / Proveedor | — | **vacío** | **Crítico** (compra) | C2/C12/C30/C31/C34/C41/C42/C61-63 (1 nF), C4/C5 (2.2 µF), C6 (1.5 pF), C7 (10 nF C0G), C11 (10 nF X7R), C15/C46/C47/C49 (130 pF), C22/C48 (430 pF), C50/C57 (22 µF), D1/D2 (LED), J3 (SPI_2X6_CONN), L7–L10 (820 nH), R10 (330 Ω), R22 (33.2 kΩ 0.1 %). **Caso especial R22**: fija la tensión del rail de 3.3 V (V_OUT = 100 µA × R_SET) y es de 0.1 % — comprarlo genérico arruina la exactitud. |
| Todas | C1, C3, C8, C58… | Fabricante | — | Columna dice "Yageo Group", pero los MPN son formato **KEMET** (`C0805C106K3PACTU`, `C0603C104K4RACTU`, `C0603C560J5GACTU`, `C0603X105J4RACAUTO`) y los códigos DigiKey `399-…` corresponden a KEMET (Yageo usa `311-`) | Medio | Los resistores sí son Yageo de verdad (`RC0603…` + `311-…`) ✓. Corregir el fabricante de los cerámicos: con el dato cruzado se termina consultando el datasheet equivocado, justo donde importan las curvas de DC bias. |
| Todas | J1, J2, J4, J5, J6, J8 | MPN / Comentario | Comment = `SMA-J-P-**X**-ST-EM1` | MPN = `SMA-J-P-**H**-ST-EM1`; footprint `CONN_SMA-J-P-H-ST-EM1_SAI` | Cosmético | La "X" es el placeholder de Samtec en la nomenclatura de la serie. Footprint y BOM coinciden → corregir el Comment del esquemático. |
| BLK | `1`, `2`, `3`, `4` | RefDes | Designadores **puramente numéricos**, footprint `Mounting_Hole_M2` | ausentes de la BOM | Medio | Los designadores solo-numéricos rompen exportaciones (pick&place, ODB++, IPC-2581, ActiveBOM). Renombrar a H1–H4 o MH1–MH4. La ausencia en la BOM es correcta si son agujeros mecánicos plateados a GND. |
| Todas | R2–R5, R11–R13, U3–U4 | RefDes | No existen ni en esquemático ni en netlist | ausentes | Cosmético | Huecos de anotación. Sin impacto; reanotar o documentar. Nota relacionada: la BOM salta del renglón 30 al 32 (falta el 31), consistente con una línea borrada. |
| Todas | — | Codificación | Netlist con `1.5kO`, `4.7 k?`, `200 ?`, `16.9KO` | ídem | Cosmético | Los símbolos Ω y µ salen mal codificados en la exportación ISO-8859-1. Ensucia diffs y comparaciones automáticas de BOM. Exportar en UTF-8 o normalizar los valores en la librería. |

---

# 6. Pendientes de verificación

No pude cerrar estos puntos con los datasheets disponibles. Ninguno cambia los hallazgos ya listados, pero sí pueden agregar hallazgos nuevos:

| Ítem | Qué hay que verificar | Riesgo si sale mal |
|---|---|---|
| **FB1 — TA0395A** (Tai-Saw) | Pinout (entrada/salida), impedancia de puerto y red de adaptación recomendada | Alto: pérdida de inserción y ripple en el filtro de canal |
| **T2/T3 — MABAES0060** | Tabla de pin connections del SM-22-5 | Alto: transformador mal cableado en ambas cadenas I y Q |
| **U2 — DSC1001DL2** | Capacidad de carga de salida y jitter vs. carga | Cuantifica el daño real de R18 (ya identificado como problema) |
| **U7 — TPS7A2650** | Manejo recomendado de FB_NC (pin 2) y PG (pin 3), ambos a GND en el diseño | Bajo: es la práctica habitual para la variante de tensión fija |
| **Pasivos** | `LQM18DN100M70L` (tamaño y corriente), `LQW15AN20NH00D` (0402), `RCS0603140KFKEA` (tolerancia y potencia) | Medio: confirma tres hallazgos ya listados |

---

# 7. Resumen ejecutivo

**Bloqueantes de fabricación/montaje (4):**
1. U5 — footprint DFN-10 vs. MPN MSOP-12
2. L4/L5 — footprint 0805 vs. componente 0402
3. L3/L6 — footprint 0805 vs. componente 0603
4. 13 líneas de BOM sin MPN

**Bloqueantes funcionales (6):**
5. HF — R1/C3 como realimentación de 1.5 kΩ alrededor del LNA (~3.6 dB de ganancia y NF)
6. DEMOD — 1 nF sobre las cuatro líneas SPI/I²C: sin interfaz digital utilizable
7. DEMOD — sin pull-ups I²C y sin definición de modo SPI vs. I²C
8. DEMOD — VGAIN sin polarización por defecto: ganancia del VGA indefinida
9. DEMOD — R18 51 Ω cargando la salida del oscilador MEMS, más el conflicto J8/R28
10. FI — balun 1:1 donde el ADRF6850 pide 100 Ω diferenciales

**Márgenes de fuente que conviene corregir (3):**
11. C55 — 10 µF nominales que quedan por debajo del mínimo del LT3045 tras derating
12. LT3045 al 89 % de su corriente máxima con el consumo real del ADRF6850
13. C50/C57 — 22 µF/10 V al filo del mínimo de C_O del TPS62902 a 5.4 V

**Lo que está bien y no conviene tocar:** toda la configuración del TPS62902 (S-CONF, divisores, soft-start, L/C), el RSET y los CCOMP del ADRF6850, VOCM a masa, la elección del oscilador de 13.5 MHz, el cableado completo de T1, el filtro Butterworth de FI y la polaridad de VG del LNA.
