# ML Helper

[![ML-HELPER](https://github.com/pseusys/HogWeedGo/actions/workflows/ml-helper.yml/badge.svg)](https://github.com/pseusys/HogWeedGo/actions/workflows/ml-helper.yml)

A Jupyter notebook pipeline for training and exporting the on-device image classifier used by the HogWeedGo mobile client. The model distinguishes three classes — `hogweed` (*Heracleum sosnowskyi*), `cetera` (other plants), and `other` (non-plant images) — achieving **>92% accuracy** on a held-out test set.

---

## Model

**Architecture:** MobileNetV2 pretrained on ImageNet, fine-tuned for 3-class plant classification  
**Input:** 224×224 RGB images  
**Output:** `.tflite` file for direct embedding in the Flutter mobile client

### Training pipeline

Training proceeds in two phases to avoid destroying pretrained feature representations:

1. **Head training** — the MobileNetV2 base is frozen; only the new classification head (Dropout + Dense) is trained. Uses Adam optimizer (`lr=1e-4`), `CategoricalCrossentropy`, early stopping on validation accuracy. Typically converges in 12–14 epochs.

2. **Fine-tuning** — the top 80% of base model layers are unfrozen (bottom 20% and all BatchNorm layers remain frozen to preserve low-level features). Continues training with RMSprop (`lr=1e-5`). Typically stops after 1–2 epochs.

Data augmentation (random horizontal flip + rotation) is applied during both phases.

---

## Dataset

21,300 images per class (63,900 total), assembled from two public sources:

| Class      | Source                                          | Filter                                                   |
| ---------- | ----------------------------------------------- | -------------------------------------------------------- |
| `hogweed`  | iNaturalist (taxon ID 499936)                   | All licenses, CC0 held out for test set                  |
| `cetera`   | iNaturalist (Leningrad Oblast Flora project)    | Excludes *H. sosnowskyi*; CC0 held out for test set      |
| `other`    | OpenImages (validation set, 2018)               | Random sample                                            |

Images are deduplicated using perceptual hashing (`average_hash`, 32-bit) before saving, so near-duplicate downloads (rescaled, recompressed) are rejected automatically.

The held-out **test set** (`datasets/test.csv`) contains 50 CC0-licensed images per plant class (not used in training or validation) plus 50 random images from Unsplash for the `other` class.

---

## Usage

### Prerequisites

```bash
pip3 install --user pipenv
pipenv install --skip-lock --system
```

### Prepare datasets

Download the following CSV files and place them in `./datasets/`:

- `hogweed.csv` — from [iNaturalist observations export](https://www.inaturalist.org/observations/export) using query `has[]=photos&quality_grade=any&identifications=any&iconic_taxa[]=Plantae&taxon_id=499936`
- `cetera.csv` — from iNaturalist using query `has[]=photos&quality_grade=any&identifications=any&iconic_taxa[]=Plantae&projects[]=leningrad-oblast-flora`
- `other.csv` — from [OpenImages validation set](https://storage.googleapis.com/openimages/2018_04/validation/validation-images-with-rotation.csv)

### Train

Open `hogweed-detector.ipynb` in Jupyter and run all cells. The notebook supports both local and Google Colab environments (see the environment setup cells). The trained model is saved as both `.h5` and `.tflite` in `./models/`.

Rename the best `.tflite` output to `hogweed-detector.tflite` for use in CI and the mobile client.

### Test

```bash
python3 test.py -n ./hogweed-detector.tflite -s ./datasets/test.csv
```
