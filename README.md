# EmoRecap

This repository contains code used for data processing and analysis for:

Bowen, H. J., Fields, E. C., & Kensinger, E. A. (2019). Prior Emotional Context Modulates Early Event-Related Potentials to Neutral Retrieval Cues. *Journal of Cognitive Neuroscience, 31*(11), 1755-1767. https://doi.org/10.1162/jocn_a_01451

## Usage/Workflow

### Preprocessing

1. Run `EmoRecap_preprocess`. This will ask for a subject ID, but can also be run as a batch by giving a file with each subject ID on a different line or by supplying a cell array of subject IDs at the top of the file. This script imports the data, adds channel location information, references the data, applies a high pass filter, and bins and epochs the data.  (Note: Various parameters used in preprocessing can be found in `EmoRecap_preproc_params.m`)

### Artifact rejection and correction

2. Run `pre_ICA_rej` and supply subject ID. 
3. Scroll through epochs and mark any with significant non-ocular or muscular artifact by clicking on them.
4. When done, click UPDATE MARKS.
5. Run `save_ICA_rej`, which will save the marked epochs so that they are not used in the next ICA step.
6. Run `EmoRecap_run_ICA`. This will automatically run ICA for any subjects for whom the above pre-ICA rejection has been done but who do not yet have an ICA weight matrix. This script will run ICA and save the weight matrix in the ICA folder.
7. After ICA is done, run `from_preart` and supply a subject ID. This will load the subject's data and create (or load, if already created) a script for applying ICA correction and detecting and rejecting trials with artifact remaining after ICA correction.
8. Examine ICA components and determine which to remove. Specify these in the `ICrej` variable in the arf script.
9. Run the arf script and examine the data. If rejection does not look satisfactory, answer no to saving the data, adjust parameters, and re-run.
10. Once satisfied, save the data. You will then be prompted if you want to calculate ERPs.

### ERP manipulations and grand mean

* Additional bins and difference waves are added to all subject ERPsets with `EmoRecap_add_ERP_bins`
* A grand mean ERPset can be created with `EmoRecap_make_gm`.

### Statistical Analysis

Statistical analysis makes use of the Factorial Mass Univariate Toolbox (FMUT):  
https://github.com/ericcfields/FMUT/wiki

1. Analysis was conducted on 10 Hz low pass filtered ERPsets produced with  the `batch_filter_ERP` function.
2. `EmoRecap_make_GND` creates the GND structures used by FMUT.
3. `EmoRecap_mass_uni_analysis` runs the stats.

### Figures and visualization
* Some useful code for creating figures can be found in the stats/figures folder.
