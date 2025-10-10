## =============================================================================
# Step (1): Install required libraries
## =============================================================================

install.packages(c("readr","dplyr","janitor","caret", "randomForest"))

## ----------------------------------------------------------------------------

## =============================================================================
# Step (2): Load required libraries
## =============================================================================

library(readr)    # for fast CSV reading
library(dplyr)    # for data manipulation
library(janitor)  # for cleaning column names
library(caret)    # for Cross validation
library(randomForest) # Random forest model

## ----------------------------------------------------------------------------

## =============================================================================
# Step (3): Load the data preparation script (contains the prepare_data function)
## =============================================================================

source("data_preparation.R")

## ----------------------------------------------------------------------------

## =============================================================================
# Step (4): Set the path to the raw dataset (update the file path if needed)
## =============================================================================

file <- "Assessment_Parcels_20251003.csv"

## ----------------------------------------------------------------------------

## =============================================================================
# Step (5): Call the data preparation function to load the clean dataset
## =============================================================================

result <- prepare_data(file)

## Cleaned dataset

df_clean <- as.data.frame(result$data)

## Medians used for numeric imputation

result_median <- result$medians

## Factor levels for categorical variables

result_category <- result$categories

# Checking missing values after removing NA from target

na_summary_after <- data.frame(
  missing_count <- sapply(df_clean, function(x) sum(is.na(x))),
  missing_percent <- sapply(df_clean, function(x) mean(is.na(x)) * 100)
)

# print(na_summary_after)

## ----------------------------------------------------------------------------

## =======================================================================================
# Step (6): Check the correlation (before vs after) transformation between numeric variable
## =======================================================================================

numeric_vars <- select_if(df_clean,is.numeric)

# 1) Log transforms to reduce skew and linearize relationships

df_clean$total_assessed_value_log <- log(df_clean$total_assessed_value + 1)
df_clean$total_living_area_log    <- log(df_clean$total_living_area + 1)
df_clean$assessed_land_area_log   <- log(df_clean$assessed_land_area + 1)

# 2) Pick all numeric variables to compare

num_cols <- c("total_assessed_value", "total_assessed_value_log","total_living_area", "total_living_area_log",
              "assessed_land_area", "assessed_land_area_log","rooms")

# 3) Compute correlation matrix using complete cases

cor_mat <- cor(df_clean[, num_cols], use = "complete.obs")

# Compare correlations with the RAW target vs LOG target

cat("\nCorrelation with RAW target:\n")

print(round(cor_mat, 3))

## ----------------------------------------------------------------------------

## ===========================================================================
## Feature Engineering: Encode Neighbourhood as Mean Assessed Value
## ------------------------------------------------------------
## This step replaces the categorical neighbourhood_area variable with a numerical feature representing the average assessed 
## property value (log scale) within each neighbourhood.
## This transformation helps the model capture location influence while avoiding high-cardinality factor issues.
## ============================================================================

neighbour_mean <- aggregate(total_assessed_value_log ~ neighbourhood_area, data=df_clean, mean)
colnames(neighbour_mean)[2] <- "neighbour_mean_value"
df_clean <- merge(df_clean, neighbour_mean, by="neighbourhood_area", all.x=TRUE)

## -----------------------------------------------------------------------------

# Final Model: Random Forest

# ------------------------------------------------------------------------------
# (1) Train the full model (for Future predictions):
# ------------------------------------------------------------------------------

## Train the full model (for Future predictions):

Final_RF_Model <- randomForest(total_assessed_value_log ~ total_living_area_log + assessed_land_area_log +
                         rooms + year_built + neighbour_mean_value + basement + basement_finish + air_conditioning +
                         fire_place + attached_garage + detached_garage + pool +building_type + property_class_1,
                         data = df_clean, ntree = 200,importance = TRUE)
