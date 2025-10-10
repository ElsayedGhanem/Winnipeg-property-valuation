## Data Preparation

# --- Function to load and clean assessment data ---
prepare_data <- function(file) {
  
  # 1. Load data
  
  df <- read_csv(file, show_col_types = FALSE) %>%
    clean_names()
  
  # 2. Select important columns
  
  df_selected <- df %>%
    select(
      total_assessed_value,
      total_living_area,
      assessed_land_area,
      rooms,
      year_built,
      basement,
      basement_finish,
      air_conditioning,
      fire_place,
      attached_garage,
      detached_garage,
      pool,
      building_type,
      property_class_1,
      neighbourhood_area
    )
  
  # 3. Drop rows where target is missing
  
  df_selected <- filter(df_selected, !is.na(total_assessed_value))
  
  # 4. Convert target variable to numeric (remove "$" and ",")
  
  df_selected$total_assessed_value <- as.numeric(gsub("[\\$,]", "", df_selected$total_assessed_value))
  
  # 5. Convert numeric columns to numeric type
  
  numeric_cols <- c("total_living_area", "assessed_land_area", "rooms", "year_built")
  for (col in numeric_cols) {
    df_selected[[col]] <- as.numeric(df_selected[[col]])
  }
  
  
  # 6. Handle numeric missing values (replace with median)
  
  medians <- list()   # object to store medians
  
  for (col in numeric_cols) {
    median_val <- median(df_selected[[col]], na.rm = TRUE)
    df_selected[[col]][is.na(df_selected[[col]])] <- median_val
    medians[[col]] <- median_val   # save median
  }
  
  # 7. Handle categorical missing values (replace with "Unknown")
  
  categorical_cols <- c("basement", "basement_finish", "air_conditioning", 
                        "fire_place", "attached_garage", "detached_garage", 
                        "pool", "building_type", "property_class_1","neighbourhood_area")
  for (col in categorical_cols) {
    df_selected[[col]][is.na(df_selected[[col]])] <- "Unknown"
    df_selected[[col]] <- as.factor(df_selected[[col]])  # convert to factor
  }
  
  
  # 8. Return both cleaned data and metadata (medians + factor levels) 
  return(list(
    data = df_selected,
    medians = medians,
    categories = lapply(df_selected[categorical_cols], levels)))
}

