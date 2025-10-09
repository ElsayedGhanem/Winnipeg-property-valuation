## 🧭 Summary for Non-Technical Audience (≤ 200 words)

This project aimed to create a **data-driven tool** that can estimate the market value of homes in Winnipeg using information already available from the city.  
The model looks at property characteristics such as **size of the house and land, year it was built, number of rooms, and building features** like garages, basements, or pools to predict the assessed value.

To start, a simple model was used to understand how each factor affects property prices. However, the first version did not capture the full picture.  
To improve accuracy, the data was adjusted so that very large or very small numbers did not distort the results.  

Next, a more advanced machine-learning model was used to recognize **patterns and interactions** that are not directly visible in the data.  
This improved the model’s ability to explain about **74% of the information in property values**, showing that the **year built, land size, living area, and building type** are among the strongest drivers of a home’s value.

Overall, this project demonstrates how data analysis and machine learning can support **fairer, faster, and more consistent property assessments** for both residents and city decision-makers.

## ⚙️ Technical Summary (≤ 500 words)

The **goal** of this project was to build a reproducible and interpretable predictive model that estimates the *total assessed value* of Winnipeg residential properties based on structural and categorical attributes.  

### 🧹 Data Preparation  
Data cleaning and transformation were fully automated in `data_preparation.R`.  
- **Irrelevant variables** (e.g., address, roll number, property use code) were removed.  
- **Missing numeric values** were imputed using the median to preserve data integrity.  
- **Categorical variables** were encoded as factors to ensure compatibility with R models.  
- **Log transformations** were applied to skewed variables (`total_assessed_value`, `total_living_area`, `assessed_land_area`) to stabilize variance and improve linearity.
- **Neighbourhood variable handling:**  
  The original `neighbourhood_area` column contained over 200 unique values, which caused dimensionality issues and model instability.  
  - For **Linear Regression**, including all factor levels would have introduced severe multicollinearity and overfitting.  
  - For **Random Forest**, R’s default implementation cannot process categorical variables with more than 53 categories.  
  To address this, the dataset was aggregated to create a **`neighbour_mean_value`** variable — representing the average assessed value per neighbourhood — which captures location-based variation without exploding feature dimensions.  

Correlation analysis confirmed that these transformations significantly strengthened relationships with the target variable (e.g., correlation between `total_living_area` and `total_assessed_value` increased from 0.034 to 0.402).  

### 🧠 Modeling Approach  
Two main models were trained and compared using **5-fold cross-validation**:
1. **Linear Regression (LM):**  
   Served as a baseline model to capture linear relationships. The initial R² was ~0.13.  
   After transformations and inclusion of categorical features, R² improved to ~0.61.  

2. **Random Forest (RF):**  
   Designed to model nonlinear interactions among predictors.  
   The RF achieved an R² ≈ of ~0.74, with ~74% variance explained, confirming better generalization and robustness.  

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

