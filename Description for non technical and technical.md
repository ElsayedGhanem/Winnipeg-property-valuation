## 🧭 Summary for Non-Technical Audience (≤ 200 words)

This project aimed to develop an **automated valuation model (AVM)** to estimate the assessed market value of residential properties in Winnipeg using publicly available city data.  
The model uses information such as **living area, land size, year built, number of rooms, and building features** (e.g., basement, garage, fireplace, pool) to predict property values.

The process began with a simple **linear regression model**, which provided a baseline understanding of how each feature relates to property value. After refining the dataset and applying **log transformations** to reduce skewness in numeric variables, prediction accuracy improved significantly.  

Finally, a **Random Forest model** was implemented to capture more complex, nonlinear relationships. This model explained approximately **70% of the information** in property values, highlighting key predictors such as **year built, land area, total living area, property_class_1, and building_type** as the strongest drivers of value.  

The findings suggest that machine learning models can provide reliable and interpretable tools for municipal property assessment and data-driven decision-making in the real estate sector.

## ⚙️ Technical Summary (≤ 500 words)

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
   The RF achieved an R² ≈ of ~0.70, with ~70% variance explained, confirming better generalization and robustness.  

### 🔍 Feature Importance  
Variable importance analysis indicated that:  
`year_built`, `assessed_land_area_log`, and `total_living_area_log` were the most influential predictors, followed by categorical features like `building_type` and `property_class_1`.  

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

### ✅ Results and Insights  
The combination of **data transformations** and **ensemble learning** enhanced model accuracy and interpretability.  
The Random Forest model provided a reliable basis for predicting property values and identifying the most impactful property characteristics.

