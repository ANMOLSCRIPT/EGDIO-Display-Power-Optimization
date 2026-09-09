# EGDIO Display Power Optimization

Official source code, simulation scripts, and evaluation framework for the paper:  
**"A Novel Nature-Inspired Metaheuristic Approach for Power Optimization in Emissive Displays"**

---

## Authors
1. Anmol Garg* `(anmol.garg.ug23@nsut.ac.in)`
2. Navya Gupta* `(navya.gupta.ug23@nsut.ac.in)`
3. Dr. K.P.S. Rana
4. Dr. Vineet Kumar

Affiliation of all authors: Department of Instrumentation and Control, Netaji Subhas University of Technology

*: Corresponding Authors
## 📌 Abstract
High-resolution emissive displays, such as OLEDs and MicroLEDs, deliver exceptional visual quality but impose heavy demands on battery life. Unlike conventional backlit panels, emissive pixels draw power proportionally to their individual luminance and colour values. This project introduces a novel metaheuristic approach—**Elite Guided Dholes Inspired Optimization (EGDIO)**—to minimize dynamic power consumption while preserving strict visual fidelity.

---

## 🔬 Core Methodology
* **Sub-Pixel Power Model:** Formulates total dynamic power as a combination of static hardware overhead and non-linear power functions across individual red, green, and blue sub-pixels.
* **EGDIO Algorithm:** Inspired by the cooperative pack-hunting behavior and social hierarchy of dholes (*Cuon alpinus*). It integrates an elite-guidance mechanism to balance exploration and exploitation, preventing premature convergence in high-dimensional search spaces.
* **Quality Constraint:** Operates under a strict Structural Similarity Index Measure (**SSIM $\ge 0.95$**) constraint to ensure perceptually lossless image transformations (with exploratory testing down to 0.80–0.85).

---

## 📊 Benchmarks & Comparison
The framework is rigorously evaluated using 24 high-resolution images from the **Kodak Lossless True Color Image Suite** and benchmarked against established nature-inspired algorithms:
* **Particle Swarm Optimization (PSO)**
* **Ant Colony Optimization (ACO)**
* **Cuckoo Search Algorithm (CSA)**

Results demonstrate that EGDIO achieves superior dynamic power savings (~35%) while exhibiting faster convergence rates and superior structural fidelity preservation.

---

## ⚙️ Repository Structure
- `/Matlab Codes` — Core EGDIO optimization engine, PSO, ACO, CSA and sub-pixel power modeling scripts.
- `/Image Dataset (Kodak Suite)` — Kodak test image suite references.
- `display_power_optimization_results.csv` — Comparative results of algorithms across each image.
- `/Results` — Output logs, convergence curves, and power-saving metrics.

---
