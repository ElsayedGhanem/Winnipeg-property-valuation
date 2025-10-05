# 🏡 Winnipeg Property Valuation Model
This project builds an automated valuation model (AVM) to predict the assessed value of residential properties in Winnipeg using open data from the City of Winnipeg.

---
## 📂 Files
| File | Description |
|------|--------------|
| `data_preparation.R` | Script for cleaning and preparing data |
| `modeling.R` | Script for model training, validation, and performance metrics |
| `README.md` | Project documentation |

---
## 📊 Overview
The goal is to create a reproducible and interpretable model that predicts property-assessed values based on property features such as living area, year built, number of rooms, and building type.  
The project was completed using **R**, with a focus on proper data preparation, model training, and validation.

---

## ⚙️ Data Preparation
All data cleaning and preparation steps were automated in the `data_preparation.R` script:
- **Removed irrelevant columns:**  
  Columns unrelated to property value prediction (e.g., roll numbers, address components, Market Region, Property Use Code, Water Frontage Measurement, etc) were excluded to reduce model noise and improve efficiency.
  
- **Handled missing values:**
  - For numeric variables, missing values were replaced with the **median** instead of deleting rows. Rationale: The median is more robust to outliers than the mean, ensuring that extreme property values do not distort imputation. Additionally, removing rows would result in significant data loss (~10–20%), which could weaken the model's learning.
  - For categorical variables, missing values were replaced with **"Unknown"** to preserve those records and avoid information loss.

- **Performed Feature Transformation:**
  - To address skewness in highly right-skewed numeric variables, log transformations were applied to key predictors such as  
`total_assessed_value`, `total_living_area`, and `assessed_land_area`.  
The log-transformed features (`total_assessed_value_log`, `total_living_area_log`, and `assessed_land_area_log`) helped stabilize variance and improve linear relationships between variables.

- **Correlation Analysis:**
 - We compared correlations between the original (raw) and log-transformed features to evaluate the impact of transformation on model interpretability.  
After transformation, correlations between predictors and the target variable increased noticeably:
- Example: `cor(total_living_area, total_assessed_value)` = **0.034** →  
  `cor(total_living_area_log, total_assessed_value_log)` = **0.402**
- Example: `cor(assessed_land_area, total_assessed_value)` = **0.236** →  
  `cor(assessed_land_area_log, total_assessed_value_log)` = **0.583**
- Example: `cor(rooms, total_assessed_value)` = **0.032** →  
  `cor(rooms, total_assessed_value_log)` = **0.266**

These results confirmed that log transformation improved the linearity and overall predictive power of numeric relationships, making the features more suitable for both linear regression and Random Forest models.

- **Converted categorical variables to factors:**  
  Many R models (e.g., `lm`, `randomForest`) require categorical data to be encoded as factors to automatically generate dummy variables.

- **Ensured numeric variables were properly formatted:**  
  Numeric columns stored as strings (like “$743,000”) were converted into numeric format to allow mathematical operations.
---

## 🧠 Modeling Approach
The `modeling.R` script includes the training and evaluation of predictive models.  
We experimented with:
- **Linear Regression (LM)** — baseline model.  
- **Random Forest (RF)** — to capture nonlinear relationships and improve prediction accuracy.  

A **5-fold Cross-Validation** was used to evaluate model performance.

---

## 📈 Evaluation Metrics
Models were evaluated using:
- **RMSE** — Root Mean Squared Error (lower is better)
- **R²** — Proportion of variance explained by the model

---

## 🧾 Summary for Non-Technical Audience (≤ 200 words)
*(To be added after final model results — this section will explain the purpose and findings in simple language.)*

---

## 🧮 Technical Summary (≤ 500 words)
*(To be added — this section will describe preprocessing, modeling choices, results, and justification for the model selection.)*

---

## 🤖 Note on AI Assistance
Parts of this project were developed with guidance from **OpenAI’s ChatGPT (GPT-5)** for clarifying R syntax and organizing code.  
All analytical decisions, modeling choices, and interpretations were made independently by the author.

---



## 🧑‍💻 Author
**Elsayed Abdalla Ghanem**  
Data Scientist | Statistical Analyst | R & Python Enthusiast  
📍 Newfoundland and Labrador, Canada  
