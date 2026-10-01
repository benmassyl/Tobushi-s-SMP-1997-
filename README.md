# Tobushi (1997) SMP thermomechanical model — MATLAB implementation

MATLAB implementation of the linear thermoviscoelastic constitutive model for shape memory polymers (SMP) of the polyurethane series proposed by Tobushi et al. (1997). The script simulates the full thermomechanical shape-memory cycle (loading, cooling under constraint, unloading, free recovery) and reproduces Figures 5–7 of the paper for a maximum strain of ε<sub>m</sub> = 4 %.

**Reference**
H. Tobushi, T. Hashimoto, S. Hayashi, E. Yamada, *Thermomechanical constitutive modeling in shape memory polymer of polyurethane series*, Journal of Intelligent Material Systems and Structures, 8 (1997) 711–718.

---

## Files

| File | Role |
|---|---|
| `test_step1.m` | Main script: parameters, time integration of the four stages, plots and export. |
| `parameters.m` | Function returning the temperature-dependent coefficients `E`, `mu`, `lam`, `C`, `el` and `alpha` at a given temperature. |

## Requirements

- MATLAB R2020a or later (`exportgraphics`).
- R2018b or later for `xline`; on older versions see the alternatives in *Plotting*.
- No toolbox required.

## Usage

Place both files in the same folder, set it as the current folder, and run:

```matlab
test_step1
```

The script fills the history arrays `t`, `sig` (MPa), `epsi` (–) and `temp` (K), draws the three figures and exports them as vector PDFs to the current folder.

---

## Constitutive model

Four-element model (Maxwell + Kelvin–Voigt with a slip element) with thermal expansion, Eq. (4) of the paper:

```
dε/dt = (dσ/dt)/E + σ/μ − (ε − ε_s)/λ + α·dT/dt
```

Irrecoverable (slip) strain, Eq. (2):

```
ε_s = C·(ε_c − ε_l)   if ε_c > ε_l
ε_s = 0               otherwise
```

where ε<sub>c</sub> is the maximum strain reached. ε<sub>s</sub> is a history variable: it is updated only while ε<sub>c</sub> increases (stage 1) and is kept constant during temperature changes.

Temperature dependence, Eqs. (6)–(10), for x ∈ {E, μ, λ, C}:

```
x   = x_g · exp[  a_x · (T_g/T − 1) ]
ε_l = ε_g · exp[ −a_ε · (T_g/T − 1) ]
```

Following Fig. 4(b) of the paper, the coefficients vary only within the glass transition region T<sub>g</sub> − T<sub>w</sub> ≤ T ≤ T<sub>g</sub> + T<sub>w</sub> (T<sub>w</sub> = 15 K) and are constant outside it. `parameters.m` implements this by clamping the temperature to [T<sub>g</sub> − 15, T<sub>g</sub> + 15] K.

### Material parameters (Tables 1–2)

| Coefficient | Value at T<sub>g</sub> | Exponent |
|---|---|---|
| E | 146 MPa | a<sub>E</sub> = 38.1 |
| μ | 14 000 MPa·s | a<sub>μ</sub> = 44.2 |
| λ | 521 s | a<sub>λ</sub> = 35.4 |
| C | 0.112 | a<sub>C</sub> = 38.7 |
| ε<sub>l</sub> | 0.3 % | a<sub>ε</sub> = 58.2 |
| α | 11.6 × 10⁻⁵ K⁻¹ | — |

T<sub>g</sub> = 328 K.

---

## Thermomechanical cycle

| Stage | Condition | Control | Duration |
|---|---|---|---|
| ① Loading | T = T<sub>h</sub> = T<sub>g</sub> + 20 = 348 K, ε̇ = 5 %/min | strain | `d1` = 48 s (ε<sub>m</sub> = 4 %) |
| ② Cooling | ε = ε<sub>m</sub> fixed, Ṫ = −4 K/min, 348 → 308 K | strain | `d2` = 600 s |
| ③ Unloading | T = T<sub>l</sub> = T<sub>g</sub> − 20 = 308 K, σ → 0 | stress | 1 time step (instantaneous) |
| ④ Heating | σ = 0, Ṫ = +4 K/min, 308 → 348 K | stress | `d4` = 600 s |

## Numerical scheme

- Explicit (forward) Euler, time step `dt` = 0.01 s.
- Strain-controlled stages (①, ②): ε̇ prescribed, σ̇ obtained from Eq. (4).
- Stress-controlled stage (④): σ̇ = 0, ε̇ obtained from Eq. (4).
- Stage ③ is treated as purely elastic and instantaneous: Δε = −σ<sub>l</sub>/E(T<sub>l</sub>). This is justified because at 308 K the relaxation times (μ/E ≈ 128 s, λ ≈ 2840 s) are much longer than the 2 s unloading of the experiment.
- Loop bounds are computed with `round()` to avoid floating-point truncation of `d/dt`.

---

## Changing the maximum strain

ε<sub>m</sub> is set through the duration of stage 1: `d1 = eps_m / eps_dot`.

| ε<sub>m</sub> | `d1` | Paper figure |
|---|---|---|
| 2.4 % | 28.8 s | 5(a), 6(a), 7(a) |
| 4 % | 48 s | 5(b), 6(b), 7(b) |
| 10 % | 120 s | 5(c), 6(c), 7(c) |

Adjust the axis limits accordingly (stress up to 5 MPa and strain up to 12 % for ε<sub>m</sub> = 10 %).

## Plotting

Three figures are produced, each stage drawn in its own colour (① black, ② red, ③ blue, ④ green):

| Figure | Axes | Paper |
|---|---|---|
| Stress–strain | ε (%) vs σ (MPa) | Fig. 5 |
| Stress–temperature | T (K) vs σ (MPa) | Fig. 6 |
| Strain–temperature | T (K) vs ε (%) | Fig. 7 |

Export is done with `exportgraphics(gcf, '<name>.pdf', 'ContentType', 'vector')`.
For releases older than R2020a use `print(gcf, '-dpdf', '-vector', '<name>.pdf')` (`-painters` before R2022b); replace `xline` with `plot([tempg tempg], ylim, 'k--')` before R2018b.

---

## Expected results (ε<sub>m</sub> = 4 %)

| Quantity | Script | Paper, calculated (read from figures) |
|---|---|---|
| σ at end of stage ① | 1.00 MPa | ≈ 1.0 MPa (Fig. 5b) |
| σ minimum during ② | 0.81 MPa at ≈ 340 K | ≈ 0.8 MPa (Fig. 6b) |
| σ at T<sub>g</sub> during ② | 1.00 MPa | ≈ 1.0 MPa (Fig. 6b) |
| σ<sub>l</sub> at end of ② (308 K) | 2.11 MPa | ≈ 2.05 MPa (Fig. 6b) |
| ε after unloading ③ | 3.77 % | ≈ 3.5 % (Fig. 7b) |
| ε at T<sub>g</sub> during ④ | 3.17 % | ≈ 3.0 % (Fig. 7b) |
| ε at end of ④ (348 K) | 0.66 % | < 1 % (Fig. 7b) |

## Notes and limitations

- **Stress–strain plot, stage ②.** At constant strain the stress first relaxes (1.00 → 0.81 MPa) and then rises (→ 2.11 MPa). Both parts lie on the vertical line ε = ε<sub>m</sub> and overlap in Fig. 5; the minimum is visible in the stress–temperature plot.
- **Kinks at T<sub>g</sub> ± 15 K.** The slope changes abruptly where the coefficients stop varying with temperature. This is a property of the piecewise approximation of the paper, not a numerical artefact.
- **Unloading strain.** The model gives Δε = σ<sub>l</sub>/E = 2.11/907 ≈ 0.23 %, smaller than the drop suggested by Fig. 7(b). This is inherent to the parameters, not to the implementation.
- **Residual strain after recovery.** About 0.46 % of the 0.66 % remaining at 348 K is thermal expansion (α · 40 K); the slip strain ε<sub>s</sub> is negligible at ε<sub>m</sub> = 4 % (ε<sub>m</sub> barely exceeds ε<sub>l</sub> = 3.83 % at T<sub>h</sub>).
- **Model scope.** As stated by the authors, the linear model underestimates the stress in stage ① and the rate of strain recovery in stage ④ compared with experiments.
