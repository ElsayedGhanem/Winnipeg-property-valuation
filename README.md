# 🏡 Winnipeg Property Valuation Model
This project builds an automated valuation model (AVM) to predict the assessed value of residential properties in Winnipeg using open data from the City of Winnipeg.

---
## 📂 Files
| File | Description |
|------|--------------|
| `data_preparation.R` | Script for cleaning and preparing data |
| `modeling.R` | Script for training and evaluating multiple predictive models **(Linear Regression, Random Forest)** using cross-validation to compare performance. |
| `Final Model.R` | Script for training the final optimized **Random Forest** model on the full dataset using the best hyperparameters obtained from cross-validation. |
| `Model Explanation.md` |Explanation to non-technical and technical people.|
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

- `total_living_area` , `assessed_land_area`, `rooms` , `year_built` , `basement` , `basement_finish` , `air_conditioning` , `fire_place` , `attached_garage` , `detached_garage` , `pool` , `building_type ` , `property_class_1` , `neighbourhood_area`.
-The target variable used for prediction was **`total_assessed_value`**.

- **Performed Feature Transformation:**
  - To address skewness in highly right-skewed numeric variables, log transformations were applied to key predictors such as `total_assessed_value`, `total_living_area`, and `assessed_land_area`.
  - The log-transformed features (`total_assessed_value_log`, `total_living_area_log`, and `assessed_land_area_log`) helped stabilize variance and improve linear relationships between variables.

- **Transformed High-Cardinality Categorical Variable (`neighbourhood_area`):**  
  The original `neighbourhood_area` variable contained over **200 unique categories**, which posed two main challenges:  
  1. `RandomForest` models in R cannot efficiently handle categorical features with more than ~50 levels.  
  2. Including over 200 dummy variables in a `Linear Regression` model would cause severe overfitting and increase computational cost.  

  To address this, the categorical variable was transformed into a **numeric feature** representing the *average assessed property value* within each neighbourhood.  

  This approach preserved the geographic effect on property values while reducing dimensionality and improving model stability.

  **Implementation Example in R:**
  ```r
  # Compute the average assessed value per neighbourhood
  neighbour_mean <- aggregate(total_assessed_value_log ~ neighbourhood_area, data = df_clean, mean)
  # Rename the new column and assign it as a numeric feature
  colnames(neighbour_mean)[2] <- "neighbour_mean_value"

  # Merge the mean value back into the main dataset
  df_clean <- merge(df_clean, neighbour_mean, by="neighbourhood_area", all.x=TRUE)

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

However, the initial model achieved a relatively **low R² (~0.07)**, indicating weak linear correlation between predictors and the target variable.  

To address this limitation, I:  
- Applied **log transformations** on highly skewed numeric variables (`total_assessed_value`, `total_living_area`, and `assessed_land_area`) to stabilize variance.  
- Re-ran the model with transformed variables (`log`) along with other numeric predictors (`rooms`, `year_built`, `neighbour_mean_value`). This model achieved a **moderate R² (~0.45)** and **RMSE = 0.565**.
- Subsequently, I included additional categorical predictors (e.g., `basement` , `basement_finish` , `air_conditioning` , `fire_place` , `attached_garage` , `detached_garage` , `pool` , `building_type` , `property_class_1`) to capture more variability in property characteristics.  
- After these enhancements, the **adjusted R² increased to ~0.61** and **RMSE = 0.482**, showing a clear improvement in the model’s explanatory power.  
- A **5-fold Cross-Validation** was then applied to validate model consistency, confirming the model’s robustness across data splits.
  
---
### 2️⃣ Advanced Model – Random Forest (RF)
To further enhance predictive performance and capture **nonlinear relationships** between features, I trained a **Random Forest regression model** using the same set of predictors.  

**Key parameters used:**  
- `ntree = 200` (number of trees)  
- `sampsize = 0.6*nrow(dataframe)` (sample size per tree)  

The Random Forest model improved the explained variance to **R² ≈ 0.74** and **RMSE = 0.151**, demonstrating its ability to model complex interactions among features.  
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
| Model | Features | R² (Approx.) | RMSE | Notes |
|--------|------------|---------------|--------|--------|
| Linear Regression (raw) | Numeric only | 0.07 | 2591027 | Baseline |
| Linear Regression (raw) | Numeric + categorical | 0.13 | 2524865 |Added categorical variables |
| Linear Regression (log-trasformed) | Log-Transformed variables + Numeric Variables only| 0.45 | 0.565 |Improved interpretability |
| Linear Regression (log-trasformed) | Log-Transformed variables (Numeric + categorical) | 0.61 | 0.482 | Stronger fit, improved accuracy |
| Random Forest | Log-Transformed variables (Numeric + categorical) | 0.74 | 0.151 | Best overall performance

These results summarize the progressive improvements achieved across different modeling stages.  
Starting with a simple linear regression using only numeric features, the baseline model demonstrated limited predictive power.  
By gradually incorporating categorical variables and applying log-transformations to reduce skewness and stabilize variance, model accuracy improved substantially.  

The final Random Forest model achieved the best performance, explaining approximately 70% of the variance in property values and achieving the lowest RMSE.  
This improvement highlights the benefits of both data transformation and the use of nonlinear algorithms capable of capturing complex feature interactions.

---

### 🧩 Model Justification  
The **Random Forest model** was selected as the final predictive model because it effectively captured nonlinear relationships, handled feature interactions automatically, and produced the highest R² score.  
Its interpretability through variable importance ranking also made it suitable for property valuation applications, where understanding feature influence is essential.

---
## 🧪 Testing on Unseen Data

Once the model was trained and validated using 5-fold Cross-Validation,  
the next step was to ensure that it could generalize well to unseen property data.  
To achieve this, the same preprocessing pipeline applied during training must be replicated before making predictions.

### 🔧 Preprocessing Steps for New Data
When new property data becomes available (e.g., a single house or a batch of listings), the following transformations must be applied in the **exact same order** as during training:

1. **Log Transformations:**  
   Apply logarithmic transformations to numeric predictors to match the training scale:  
   ```r
   new_data$total_living_area_log <- log(new_data$total_living_area + 1)
   new_data$assessed_land_area_log <- log(new_data$assessed_land_area + 1)

2. **Neighbourhood Mean Value**
  Merge the neigh_mean_value feature, which was computed from the training data, instead of recalculating it from the new dataset:
  ```r
   new_data <- merge(new_data, neighbour_mean, by = "neighbourhood_area", all.x = TRUE)

3. **Categorical Variables**

Convert all categorical columns into factors using the same levels as the training dataset to avoid mismatches:
```r
   cat_cols <- c("basement", "basement_finish", "air_conditioning", "fire_place", "attached_garage", "detached_garage", "pool", "building_type", "property_class_1")

for (col in cat_cols) {
  new_data[[col]] <- factor(new_data[[col]], levels = levels(df_clean[[col]]))
}

### 🤖 🤖 Making Predictions
```r
   predicted_log <- predict(final_model_rf, newdata = new_data)
   predicted_value <- exp(predicted_log) - 1  # Convert back to the original scale
---

## 🤖 Note on AI Assistance
Parts of this project were developed with guidance from **OpenAI’s ChatGPT (GPT-5)** 
AI assistance helped me to:  
- Clarify R syntax and troubleshoot code.  
- Improve documentation structure (e.g., organizing the README layout and section flow). 
- Refine the wording for technical explanations.  

All analytical decisions, modeling choices, and interpretations were made independently by the author.

---

## 🧑‍💻 Author
**Elsayed Abdalla Ghanem**  
Data Scientist | Statistical Analyst | R & Python Enthusiast  
📍 Newfoundland and Labrador, Canada  
