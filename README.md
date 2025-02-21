# A Landscape Metric-Enhanced Cellular Automaton Model (LE-CA) for Coastal Wetland Land-Use Simulation: Advancing Accuracy and Sustainability in Blue Carbon Ecosystem Management

## Abstract
Coastal wetlands are key parts of blue carbon ecosystems, with unique structures and strong carbon sequestration abilities, playing vital roles in coastal protection. Traditional cellular automata (CA) models for land-use change often rely on pixel-level data, which fails to fully capture landscape structure. This study proposes a landscape structure-enhanced CA (LE-CA) model that integrates landscape features and cell transition coherence. The LE-CA model outperforms traditional pixel-based CA models in landscape similarity and prediction accuracy. It provides a solid scientific basis for sustainable coastal wetland planning and valuable insights for land-use change management.

## Keywords
Landscape metric; Land-use simulation; Genetic algorithm; Markov chain; Landscape structure

## Introduction
This program is the source code of the parallel LE-CA model based on Matlab. Below are the instructions for its use.

---

## Preparation before Model Simulations

1. **Install Matlab**  
   Ensure you have the correct version of Matlab installed. You can download it from the MathWorks website or through your institution's license portal. Make sure the necessary toolboxes (e.g., Image Processing, Statistics, or GIS-related toolboxes) are installed.

2. **Check Initial Files**  
   Verify that all required data files (e.g., land classification maps, driving factors) are available and correctly formatted.

---

## Calibration and Validation

Calibration and validation are crucial steps in ensuring that a model provides accurate and reliable predictions.

### Calibration
This model structure is updated from previous land-use change simulation modeling studies by incorporating the influence of landscape metrics. A comprehensive explanation of how this model works can also be found in previous studies (Feng and Tong, 2019; Liang et al., 2021; Lin et al., 2020; Lin et al., 2023; Liu et al., 2014; Song et al., 2024a; Song et al., 2024b; Xu et al., 2023). The core components of the LE-CA model include landscape metrics, Markov chain, and Genetic algorithm.

Calibration involves adjusting model parameters (transition probabilities in the Markov chain) to better match observed data. This process fine-tunes the model by comparing its outputs with historical land-use data and making adjustments to improve prediction accuracy. 

During calibration, the following main modules are involved:

1. **Artificial Neural Network (ANN) Algorithm**  
   The ANN algorithm is used to predict land suitability by processing spatial driving factors (e.g., distance to rivers, slope, elevation). The model trains on historical land-use data and driving factors to generate probability maps for future land-use scenarios.

2. **Landscape Metrics**  
   Landscape metrics quantify the structure and composition of the landscape. These metrics are integrated into the model to evaluate how spatial configuration and fragmentation influence land-use changes. The metrics serve as inputs for the CA model to improve the simulation's ecological realism.

3. **GA_Markov**  
   The Markov chain model, optimized by a Genetic Algorithm (GA), predicts transitions between different land cover types. The GA fine-tunes the transition probabilities to enhance the accuracy of land-use predictions, ensuring that the Markov matrix reflects realistic changes over time.

4. **Simulation**  
   The final simulation module integrates the ANN, landscape metrics, and GA-optimized Markov chain to simulate future land-use changes. The CA model runs iteratively, applying transition probabilities to land cells, updating land cover based on the combined inputs, and generating predicted land-use maps for future periods.

---

### Validation

Validation is the process of assessing the model's performance by testing it with independent data that was not used during the calibration phase. This step checks if the model can accurately predict land-use changes in a different time period or spatial area.

1. **Simulation**  
   The simulation is run using the parameters and transition probabilities obtained during calibration, but this time, it is applied to independent data (land-use data from a different year). The goal is to simulate future land-use changes and compare the model's predictions with actual observed land-use changes that were not part of the calibration set. This step helps to evaluate how well the model generalizes to new data and whether the predictions match real-world land-use dynamics.

---

## Running the Simulation Model

After preparing all the files, make sure to update the paths in the following locations: ensure that the file paths in the executive file (CA2.m) are correctly updated. This is crucial because the model needs to know where to find the input data files and where to save the results.

---

## References

- Feng Y, Tong X. Incorporation of spatial heterogeneity-weighted neighborhood into cellular automata for dynamic urban growth simulation. **GISCIENCE & REMOTE SENSING** 2019; 56: 1024-1045. [DOI: 10.1080/15481603.2019.1603187](https://doi.org/10.1080/15481603.2019.1603187)
- Liang X, Guan Q, Clarke KC, Chen G, Guo S, Yao Y. Mixed-cell cellular automata: A new approach for simulating the spatio-temporal dynamics of mixed land use structures. **Landscape and Urban Planning** 2021; 205: 103960. [DOI: 10.1016/j.landurbplan.2020.103960](https://doi.org/10.1016/j.landurbplan.2020.103960)
- Lin J, Li X, Li S, Wen Y. What is the influence of landscape metric selection on the calibration of land-use/cover simulation models? **ENVIRONMENTAL MODELLING & SOFTWARE** 2020; 129. [DOI: 10.1016/j.envsoft.2020.104719](https://doi.org/10.1016/j.envsoft.2020.104719)
- Lin J, Li X, Wen Y, He P. Modeling urban land-use changes using a landscape-driven patch-based cellular automaton (LP-CA). **CITIES** 2023; 132. [DOI: 10.1016/j.cities.2022.103906](https://doi.org/10.1016/j.cities.2022.103906)
- Liu X, Ma L, Li X, Ai B, Li S, He Z. Simulating urban growth by integrating landscape expansion index (LEI) and cellular automata. **INTERNATIONAL JOURNAL OF GEOGRAPHICAL INFORMATION SCIENCE** 2014; 28: 148-163. [DOI: 10.1080/13658816.2013.831097](https://doi.org/10.1080/13658816.2013.831097)
- Song Y, Wang H, Zhang B, Zeng H, Li J, Zhang J. A methodology to Geographic Cellular Automata model accounting for spatial heterogeneity and adaptive neighborhoods. **INTERNATIONAL JOURNAL OF GEOGRAPHICAL INFORMATION SCIENCE** 2024a; 38: 699-725. [DOI: 10.1080/13658816.2023.2298298](https://doi.org/10.1080/13658816.2023.2298298)
- Song Y, Xu H, Wang H, Zhu Z, Kang X, Cao X, et al. An adaptive transition probability matrix with quality seeds for cellular automata models. **GISCIENCE & REMOTE SENSING** 2024b; 61. [DOI: 10.1080/15481603.2024.2347719](https://doi.org/10.1080/15481603.2024.2347719)
- Xu Q, Zhu AX, Liu J. Land-use change modeling with cellular automata using land natural evolution unit. **CATENA** 2023; 224: 106998. [DOI: 10.1016/j.catena.2023.106998](https://doi.org/10.1016/j.catena.2023.106998)
