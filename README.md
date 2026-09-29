# Olist E-Commerce Dataset Analysis

An end-to-end analysis of the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering customer segmentation (RFM), churn analysis, and SQL-based exploration of orders, customers, sellers, and payments.

## Overview

Olist is a Brazilian marketplace that connects small businesses to customers through a single platform. The public dataset contains roughly 100,000 orders placed between 2016 and 2018, along with customer, product, seller, payment, and review information.

This project uses that data to answer questions such as:

- Who are the most valuable customers, and how can customers be grouped by behavior?
- Which customers are likely to churn, and what characterizes them?
- Which products and regions have the most sales in the marketplace?


## Repository Structure

```
Olist_Dataset_Analysis/
├── datasets/          # Raw Olist CSV files
├── SQL codes/         # SQL queries for data exploration and analysis
├── RFM Analysis/      # Recency-Frequency-Monetary customer segmentation
├── Churn Analysis/    # Customer churn analysis
└── README.md
```

| Folder | Description |
|---|---|
| `datasets/` | Source data files from the Olist public dataset (customers, orders, order items, payments, reviews, products, sellers, geolocation, category translation). |
| `SQL codes/` | SQL scripts used to join tables, clean data, and extract key metrics. |
| `RFM Analysis/` | Scores customers on Recency, Frequency, and Monetary value and groups them into segments. |
| `Churn Analysis/` | Defines churn, explores contributing factors, and identifies at-risk customers. |

## Dataset

The data is split across several related tables:

| Table | Contents |
|---|---|
| Customers | Customer IDs and location |
| Orders | Order status and purchase/delivery timestamps |
| Order Items | Products, sellers, prices, and freight per order |
| Payments | Payment type, installments, and value |
| Reviews | Customer review scores and comments |
| Products | Product category and physical attributes |
| Sellers | Seller IDs and location |
| Geolocation | Zip code prefixes with coordinates |
| Category Translation | Portuguese to English category names |

**Source:** [Kaggle: Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Methodology

### SQL Analysis
Queries join the relational tables and compute metrics such as revenue, order volume, delivery performance, payment behavior, and review scores.

### RFM Analysis
Customers are scored on three dimensions:

- **Recency:** how recently the customer made a purchase
- **Frequency:** how often they purchase
- **Monetary:** how much they spend

Scores are combined to create customer segments (for example, champions, loyal customers, at-risk, and lost) that can guide targeted marketing.

### Churn Analysis
Churn is defined based on customer purchase inactivity. The analysis looks at which behaviors and attributes are associated with customers who do not return.

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/rachelT2/Olist_Dataset_Analysis.git
   cd Olist_Dataset_Analysis
   ```
2. Explore the raw data in `datasets/`.
3. Run the SQL scripts in `SQL codes/` against your database of choice after loading the CSVs.
4. Open the notebooks or files in `RFM Analysis/` and `Churn Analysis/` to reproduce the segmentation and churn results.

## Tools

<!-- Update this list to match what you actually used -->
- SQL
- Python (pandas, matplotlib/seaborn, scikit-learn)
- Jupyter Notebook

## Key Findings

<!-- Add your headline insights here, for example: -->
- _Share of customers in each RFM segment and their contribution to revenue_
- _Repeat purchase rate and main churn drivers_
- _Notable delivery or review patterns_

## Author

**rachelT2** · [GitHub](https://github.com/rachelT2)

## Acknowledgments

Dataset provided by [Olist](https://olist.com/) and shared publicly on Kaggle.
