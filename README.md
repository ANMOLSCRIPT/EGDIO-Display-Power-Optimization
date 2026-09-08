# EGDIO Display Power Optimization

Official source code, simulation scripts, and evaluation framework for the paper:  
**"A Novel Nature-Inspired Metaheuristic Approach for Power Optimization in Emissive Displays"**

---

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
- `/src` — Core EGDIO optimization engine and sub-pixel power modeling scripts.
- `/data` — Kodak test image suite references and preprocessing pipelines.
- `/benchmarks` — Comparative simulation scripts for PSO, ACO, and CSA.
- `/results` — Output logs, convergence curves, and power-saving metrics.

---

## 📄 Citation
If you use this code or reference this work in your research, please cite our conference paper:
```bibtex
@inproceedings{garg2026egdio,
  title={A Novel Nature-Inspired Metaheuristic Approach for Power Optimization in Emissive Displays},
  author={Garg, Anmol and Gupta, Navya and Kumar, Vineet and Rana, K.P.S.},
  booktitle={India Display Conference (IDC)},
  year={2026}
}
