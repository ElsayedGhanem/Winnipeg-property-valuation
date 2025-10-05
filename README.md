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

- **Ensured numeric variables were properly formatted:**  
  Numeric columns stored as strings (like “$743,000”) were converted into numeric format to allow mathematical operations.

- **Converted categorical variables to factors:**  
  Many R models (e.g., `lm`, `randomForest`) require categorical data to be encoded as factors to automatically generate dummy variables.

- **Selected Features:**  
After cleaning and feature selection, the following predictors were used in modeling:

- `total_living_area` , `assessed_land_area`, `rooms` , `year_built` , `basement` , `basement_finish` , `air_conditioning` , `fire_place` , `attached_garage` , `detached_garage` , `pool` , `building_type , `property_class_1.
-The target variable used for prediction was **`total_assessed_value`**.

- **Performed Feature Transformation:**
  - To address skewness in highly right-skewed numeric variables, log transformations were applied to key predictors such as `total_assessed_value`, `total_living_area`, and `assessed_land_area`.
  - The log-transformed features (`total_assessed_value_log`, `total_living_area_log`, and `assessed_land_area_log`) helped stabilize variance and improve linear relationships between variables.

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

---

## 📈 Evaluation Metrics
Models were evaluated using:
- **RMSE** — Root Mean Squared Error (lower is better)
- **R²** — Proportion of variance explained by the model
---

## 🧠 Modeling Approach
The `modeling.R` script includes the training and evaluation of predictive models.  
The modeling process was conducted in **several stages** to ensure interpretability and gradual performance improvement.

### 1️⃣ Baseline Model – Linear Regression (LM)

I began with a **Linear Regression model** using the raw numerical features (`total_living_area`, `assessed_land_area`, `rooms`, `year_built`) to establish a baseline and understand the linear relationships between predictors and the assessed property value.  

However, the initial model achieved a relatively **low R² (~0.21)**, indicating weak linear correlation between predictors and the target variable.  

To address this limitation, I:  
- Applied **log transformations** on highly skewed numeric variables (`total_assessed_value`, `total_living_area`, and `assessed_land_area`) to stabilize variance.  
- Re-ran the model with transformed variables (`log`) along with other numeric predictors (`rooms`, `year_built`). This model achieved a **moderate R² (~0.44)**.
- Subsequently, I included additional categorical predictors (e.g., `basement` , `basement_finish` , `air_conditioning` , `fire_place` , `attached_garage` , `detached_garage` , `pool` , `building_type` , `property_class_1`) to capture more variability in property characteristics.  
- After these enhancements, the **adjusted R² increased to ~0.60** and **RMSE = 0.49**, showing a clear improvement in the model’s explanatory power.  
- A **5-fold Cross-Validation** was then applied to validate model consistency, confirming the model’s robustness across data splits.
  
---
### 2️⃣ Advanced Model – Random Forest (RF)
To further enhance predictive performance and capture **nonlinear relationships** between features, I trained a **Random Forest regression model** using the same set of predictors.  

**Key parameters used:**  
- `ntree = 200` (number of trees)  
- `sampsize = 0.6*nrow(dataframe)` (sample size per tree)  

The Random Forest model improved the explained variance to **R² ≈ 0.70** and **RMSE = 0.17**, demonstrating its ability to model complex interactions among features.  
Feature importance analysis revealed that the most influential predictors were:  
To interpret the model, the variable importance plot was analyzed. The table below shows the **top predictors contributing to the model**:

| Feature                 | Importance (%) |
|--------------------------|----------------|
| year_built               | 29.57 |
| assessed_land_area_log   | 26.86 |
| total_living_area_log    | 22.86 |
| property_class_1         | 16.05 |
| building_type            | 13.48 |
| basement_finish          | 9.73 |
| fire_place               | 9.28 |
| attached_garage          | 9.64 |
| air_conditioning         | 8.00 |
| basement                 | 7.89 |
| rooms                    | 7.37 |
| detached_garage          | 6.23 |
| pool                     | 5.67 |  

---
### ✅ Summary  
| Model | Features | R² (Approx.) | Notes |
|--------|------------|---------------|--------|
| Linear Regression (raw) | Numeric only | 0.21 | Baseline |
| Linear Regression (log + categorical) | Transformed + categorical | 0.60 | Improved interpretability |
| Random Forest | Log-transformed + all predictors | 0.70 | Best performance |

These results indicate that **data transformation** and inclusion of **nonlinear models** significantly improved the overall predictive accuracy.

---

### 🧩 Model Justification  
The **Random Forest model** was selected as the final predictive model because it effectively captured nonlinear relationships, handled feature interactions automatically, and produced the highest R² score.  
Its interpretability through variable importance ranking also made it suitable for property valuation applications, where understanding feature influence is essential.

---

## 🧾 Summary for Non-Technical Audience (≤ 200 words)
This project aimed to develop an **automated valuation model (AVM)** to estimate the assessed market value of residential properties in Winnipeg using publicly available city data.  
The model uses information such as **living area, land size, year built, number of rooms, and building features** (e.g., basement, garage, fireplace, pool) to predict property values.

The process began with a simple **linear regression model**, which provided a baseline understanding of how each feature relates to property value. After refining the dataset and applying **log transformations** to reduce skewness in numeric variables, prediction accuracy improved significantly.  

Finally, a **Random Forest model** was implemented to capture more complex, nonlinear relationships. This model explained approximately **70% of the variation** in property values, highlighting key predictors such as **year built, land area, and total living area** as the strongest drivers of value.  

The findings suggest that machine learning models can provide reliable and interpretable tools for municipal property assessment and data-driven decision-making in the real estate sector.

---

## 🧮 Technical Summary (≤ 500 words)
The **goal** of this project was to build a reproducible and interpretable predictive model that estimates the *total assessed value* of Winnipeg residential properties based on structural and categorical attributes.  

### 🧹 Data Preparation  
Data cleaning and transformation were fully automated in `data_preparation.R`.  
- **Irrelevant variables** (e.g., address, roll number, property use code) were removed.  
- **Missing numeric values** were imputed using the median to preserve data integrity.  
- **Categorical variables** were encoded as factors to ensure compatibility with R models.  
- **Log transformations** were applied to skewed variables (`total_assessed_value`, `total_living_area`, `assessed_land_area`) to stabilize variance and improve linearity.  

Correlation analysis confirmed that these transformations significantly strengthened relationships with the target variable (e.g., correlation between `total_living_area` and `total_assessed_value` increased from 0.034 to 0.402).  

### 🧠 Modeling Approach  
Two main models were trained and compared using **5-fold cross-validation**:
1. **Linear Regression (LM):**  
   Served as a baseline model to capture linear relationships. The initial R² was ~0.21.  
   After transformations and inclusion of categorical features, R² improved to ~0.60.  

2. **Random Forest (RF):**  
   Designed to model nonlinear interactions among predictors.  
   The RF achieved an R² of approximately 0.70, explaining 0.70% of the variance, which confirms better generalization and robustness.  

### 🔍 Feature Importance  
Variable importance analysis indicated that:`year_built`, `assessed_land_area_log`, and `total_living_area_log` were the most influential predictors, followed by categorical features like `building_type` and `property_class_1`.  

| Feature | Importance (%) |
|----------|----------------|
| year_built | 29.57 |
| assessed_land_area_log | 26.86 |
| total_living_area_log | 22.86 |
| property_class_1 | 16.05 |
| building_type | 13.48 |

### ✅ Results and Insights  
The combination of **data transformations** and **ensemble learning** enhanced model accuracy and interpretability.  
The Random Forest model provided a reliable basis for predicting property values and identifying the most impactful property characteristics.

---

## 🤖 Note on AI Assistance
Parts of this project were developed with guidance from **OpenAI’s ChatGPT (GPT-5)** for clarifying R syntax and organizing code.  
All analytical decisions, modeling choices, and interpretations were made independently by the author.

---



## 🧑‍💻 Author
**Elsayed Abdalla Ghanem**  
Data Scientist | Statistical Analyst | R & Python Enthusiast  
📍 Newfoundland and Labrador, Canada  
