# Modèle de Tobushi (1997)

This repository contains a MATLAB implementation inspired by:

**Tobushi et al. (1997)** — *Thermomechanical constitutive modeling in shape memory polymer of polyurethane series*.

## Repository contents

- `test_step1.m`: main script that runs a 4-stage thermo-mechanical cycle and exports plots.
- `parameters.m`: helper function for temperature-dependent material parameters.
- `Tobushi et al. - 1997 - Thermomechanical constitutive modeling in shape memory polymer of polyurethane series.pdf`: reference paper.
- `fig5_stress_strain.pdf`, `fig6_stress_temp.pdf`, `fig7_strain_temp.pdf`: exported figures.

## Requirements

- MATLAB (recommended), or GNU Octave with compatible plotting/export support.

## How to run

1. Open MATLAB in this repository folder.
2. Run:

   ```matlab
   test_step1
   ```

3. The script generates:
   - Stress–strain plot (`fig5_stress_strain.pdf`)
   - Stress–temperature plot (`fig6_stress_temp.pdf`)
   - Strain–temperature plot (`fig7_strain_temp.pdf`)

## Notes

- The implementation is intended for study/reproduction of the referenced model behavior.
- Intermediate MATLAB autosave files are ignored via `.gitignore`.
