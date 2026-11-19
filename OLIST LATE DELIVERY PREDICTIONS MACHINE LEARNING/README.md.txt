# Olist E-commerce late dlivery prediction
## Project Overview
The project focuses on analysing and predicting late deliveries using the Brazilian E-commerce public dataset by Olist.
The objective is to identify the opertaional, geographical and logistical factors associated with late deliveries nad develops a delivery learning classification model to predict whether an order will be delivered late.
## Business Objectives
1. Analyze delivery performance and identify patterns associated with late deliveries.
2. Evaluate geographical differences in delivery performances.
3. Investigate the relationship between freight cost and delivery delays.
4. Develop a machine learning model to identify orders at risk of late delivery.
5. Provide actionable business recommendations to improve logistics performance.
## Tools and Technologies
SQL Server: Data collection, cleaning, joins, aggregations and CTE.
Python: Data manipulation, and Exploratory Data Analysis (EDA).
Pandas and Numpy: Data processing and feature engineering.
Matplotlib and Seaborm: Data visualisation.
Scikit-learn: Data preprocessing, model evaluation(Logistic Regression, Random Forest Classifier+ and pipeline creation.
XGBoost: Classification model development.
Jupyter notebook: Analysis and model development.
## Project Workflow
### 1. Data Extraction and Preparation
-Combined relevant information from multiple Olist databse tables.

-Use SQL joins, aggregations and CTE to create master late delivery dataset.

-Cleaned and validated the extracted data.
### 2. Exploratory Data Analysis
-Analyzed order and delivery patterns.

-Estimated monthly trends and delivery estimates.

-Investigated geographical delivery performances.

-Compared freight cost between on time and late deliveries.
### 3. Feature Engineering
-Created relevant delivery oriented featues.

-Prepared numerical and categorical variables.

-Selected features for machine learning.
### 4. Machine Learning
-Developed an XGboost classification model.

-Applied preprocessing pipelines.

-Addressed class limitations through model evaluation and threshold tuning.

-Evaluated performance using precision, recall, f1 score and confusion matrix.

-Comapred and analysed different machine learning models like logistics regression, Random Forest Classifier and XGBoost.
### 5. Buisnes Insights
-Identified geographical and operational patterns.

-Evaluated factors associated with delivery delays.

-Developed recommendations for logistics and delivery performance improvements.
## Model Evaluation
The model was evaluated with particular attention to recall and F1 score because identifying potentially late orders is an important business objective.
## Business Impact
The analysis provides a framework for identifying potential delivery risks, investigating regional logistics challenges and supporting data driven operational decisions.
## Conclusion
This project demonstrates an end to end data analytics and machibe learning workflow, combining SQL based data preparation, Python analysis, predictive modeing and business oriented recommendations.

