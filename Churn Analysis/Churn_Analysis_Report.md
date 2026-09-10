# Customer Churn Analysis Report — Olist Marketplace

## 1. Executive Summary

This analysis built a predictive model to identify customers likely to churn, using order, delivery, payment, and review data from the Olist marketplace. After comparing Random Forest and XGBoost classifiers and correcting for class imbalance in the training data, **XGBoost was selected as the final model**, achieving a test-set ROC-AUC of **0.761** and accuracy of **68.6%**.

The single strongest predictor of churn is **delivery experience** — average delivery time, delivery delay, and percentage of late orders together account for over 60% of the model's predictive signal. This points to a clear, actionable lever: improving delivery reliability is likely the highest-impact retention strategy available.

## 2. Methodology

- **Data source:** customer-level features aggregated from Olist's order, payment, delivery, and review tables (93,342 customers, 12 modeling features after feature engineering).
- **Target definition:** a customer is labeled churned based on order recency exceeding a fixed inactivity threshold. Roughly 80% of customers in the dataset are labeled churned, reflecting Olist's largely one-time-buyer customer base.
- **Feature engineering:** delivery delay buckets, a "was delivery late" flag, and one-hot encoded payment method were added; features with direct label leakage (e.g., raw recency) or redundancy with other features were removed prior to modeling.
- **Models compared:** Random Forest and XGBoost, each tuned via grid search with 5-fold cross-validation, optimizing for ROC-AUC.
- **Class imbalance handling:** both models were retrained with class-weighting (`class_weight='balanced'` for Random Forest, `scale_pos_weight` for XGBoost) after an initial pass showed the unweighted models simply predicted the majority class for nearly every customer.
- **Evaluation:** an 80/20 train/test split was held out from all tuning, with a further validation split used during model selection. The test set was touched only once, for final reporting.

## 3. Model Performance

| Model | Precision | Recall | F1 | Accuracy | ROC-AUC |
|---|---|---|---|---|---|
| Random Forest (CV) | 0.901 | 0.615 | 0.731 | 0.637 | 0.744 |
| XGBoost (CV) | 0.895 | 0.690 | 0.779 | 0.686 | 0.754 |
| Random Forest (Validation) | 0.903 | 0.612 | 0.729 | 0.636 | 0.749 |
| XGBoost (Validation) | 0.896 | 0.685 | 0.776 | 0.683 | 0.758 |
| **XGBoost (Test — final)** | **0.899** | **0.685** | **0.777** | **0.686** | **0.761** |

**XGBoost outperforms Random Forest on every metric that matters for this problem** — ROC-AUC, recall, F1, and accuracy — while giving up only a marginal amount of precision. Performance is consistent across cross-validation, validation, and the untouched test set, indicating the model generalizes well rather than overfitting to the training data.

A test ROC-AUC of 0.761 indicates **acceptable, above-baseline discrimination** (0.5 = random guessing, 0.7–0.8 is generally considered a fair-to-good working model, 0.8+ is strong). There is room to improve further through additional feature engineering and expanded hyperparameter tuning, discussed in Section 6.

## 4. Confusion Matrix (XGBoost, Test Set)

| | Predicted: Not Churned | Predicted: Churned |
|---|---|---|
| **Actual: Not Churned** | 2,556 (True Negative) | 1,147 (False Positive) |
| **Actual: Churned** | 4,721 (False Negative) | 10,245 (True Positive) |

Out of 18,669 test customers:

- The model correctly identifies **10,245 of 14,966 actual churners** (68.5% recall) — meaning roughly 1 in 3 churners are missed.
- Of the customers flagged as churned, **89.9% actually are** (precision) — false alarms are relatively rare, so retention outreach based on this model's flags would mostly reach real at-risk customers.
- **4,721 churners are missed (false negatives)** — this is the model's main weak point, and the group most worth addressing if the business goal is to catch as many at-risk customers as possible.
- **1,147 loyal customers are incorrectly flagged as churn risks (false positives)** — a smaller group, representing the cost of unnecessary retention spend if outreach is triggered automatically from these predictions.

This precision/recall balance reflects the choice to weight the model against simply predicting the majority class. Depending on the cost of a missed churner versus a wasted retention offer, the classification threshold (currently the default 0.5) could be tuned to shift this balance — lowering the threshold would catch more churners at the cost of more false alarms, and vice versa.

## 5. What Drives Churn: Feature Importance

![Feature Importance](cell_104.png)

| Rank | Feature | Importance |
|---|---|---|
| 1 | Average delivery days | 0.251 |
| 2 | Average delivery delay | 0.192 |
| 3 | Percentage of late orders | 0.170 |
| 4 | Payment method: debit card | 0.152 |
| 5 | Monetary value (total spend) | 0.047 |
| 6 | Order frequency | 0.037 |
| 7 | Payment method: credit card | 0.037 |
| 8 | Payment method: boleto | 0.037 |
| 9 | Average payment installments | 0.035 |
| 10 | Average review score | 0.025 |

**Key finding: delivery experience dominates the model.** The top three features — delivery speed, delivery delay, and rate of late orders — together account for **61.3%** of total feature importance. This is a consistent, single-theme signal rather than a scattered set of weak predictors, which makes it a credible and actionable finding rather than a modeling artifact.

**Payment method is a secondary but notable signal.** Debit card usage alone carries more weight (0.152) than monetary value, order frequency, and review score combined — worth further investigation into whether this reflects a customer segment (e.g., budget-conscious, one-time buyers) rather than a causal effect of the payment method itself.

**Review score, despite being an intuitive churn driver, ranks last** among the top 10. This suggests that *operational* friction (slow, unreliable delivery) is a stronger churn signal in this data than customers' *stated* satisfaction — customers may be leaving due to logistics problems before dissatisfaction ever shows up in a review.

## 6. Limitations & Recommended Next Steps

**Model limitations:**
- ROC-AUC of 0.761 leaves meaningful room for improvement; several tuned hyperparameters (e.g., XGBoost's learning rate and max depth) landed at the edge of the search grid, suggesting the grid should be widened and regularization parameters (`subsample`, `colsample_bytree`, `reg_alpha`, `reg_lambda`) added.
- The churn label itself is defined by a fixed recency cutoff; given Olist's largely one-time-purchase customer base, it's worth testing sensitivity of results to this threshold, as it caps how learnable "churn" can be regardless of model quality.
- The current model uses a default 0.5 classification threshold, which may not reflect the actual business cost trade-off between missed churners and false alarms.

**Recommended next steps:**
1. **Operational:** Investigate delivery reliability improvements (carrier performance, regional delivery SLAs) as the top retention lever, given delivery-related features dominate the model.
2. **Modeling:** Expand the hyperparameter search, add regularization tuning, and consider threshold tuning aligned to retention campaign economics.
3. **Data:** Explore additional features not yet included — e.g., days since first purchase, product category diversity, or regional effects — to capture churn drivers beyond delivery and payment behavior.
4. **Validation:** Re-evaluate the churn label definition (recency threshold) to confirm it reflects a meaningful, actionable definition of "at risk" for the business.
