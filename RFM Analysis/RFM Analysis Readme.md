# RFM Customer Segmentation: Olist E-commerce

Customer segmentation using **RFM analysis** (Recency, Frequency, Monetary) on the Olist Brazilian e-commerce dataset. The project uses **MySQL** to build the RFM base table and **Python** to score, segment and interpret customers.

## Objective

Identify which customer groups drive revenue, which are at risk of churning, and where marketing effort should go.

## Dataset

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).

Tables used:

| Table | Purpose |
|---|---|
| `orders_table` | Order status and purchase date |
| `customers_table` | Maps orders to `customer_unique_id` |
| `order_items_table` | Item price and freight value |

Only orders with `order_status = 'delivered'` are included.

> The raw dataset are in datasets folder.

## Tools

- MySQL
- Python: pandas, NumPy, SQLAlchemy, PyMySQL, python-dotenv
- Visualisation: matplotlib, seaborn
- Jupyter Notebook

## Methodology

### 1. SQL: build the RFM table

- `rfm_base_view`: one row per delivered order, with `order_total = price + freight_value`, joined to `customer_unique_id`.
- `rfm_data` table, per customer:
  - **Recency**: days between the customer's last order and the latest order date in the dataset
  - **Frequency**: number of distinct orders
  - **Monetary**: total spend (price + freight)

`customer_unique_id` is used instead of `customer_id`, because Olist creates a new `customer_id` for each order.

### 2. Python: scoring

- **R score**: quintiles (1 to 5), with lower recency giving a higher score
- **M score**: quintiles (1 to 5)
- **F score**: fixed business rules instead of quantiles

| Orders | F score |
|---|---|
| 1 | 1 |
| 2 | 3 |
| 3+ | 5 |

**Why not quantiles for frequency?** About 97% of customers placed exactly one order. Splitting them into quintiles (for example with `rank(method='first')`) assigns one-time buyers to different buckets based on row order, not behaviour. This produced misleading segments in my first attempt, where "Loyal" customers had an average frequency of about 1.0. Fixed rules solved that problem.

### 3. Segmentation rules

| Segment | Rule |
|---|---|
| Champions | R >= 4, M >= 4, F >= 3 |
| Recent High-spenders | R >= 4, M >= 4, F < 3 |
| New / Potential | R >= 4 (remaining) |
| At Risk - High value | R <= 2, M >= 4 |
| Lost | R <= 2, M <= 2 |
| Repeat Customers | F >= 3 (remaining) |
| Mid-term One-timers | Everything else |

## Results

| Segment | Customers | Avg recency (days) | Avg frequency | Avg monetary |
|---|---|---|---|---|
| Mid-term One-timers | 25,290 | 270 | 1.00 | ~139 |
| New / Potential | 22,053 | 90 | 1.01 | ~73 |
| Lost | 15,327 | 396 | 1.01 | ~56 |
| Recent High-spenders | 14,505 | 91 | 1.00 | ~302 |
| At Risk - High value | 14,407 | 394 | 1.06 | ~310 |
| Champions | 995 | 89 | 2.18 | ~372 |
| Repeat Customers | 759 | 250 | 2.08 | ~268 |

*Monetary values are in Brazilian reais (BRL), rounded, and include freight. Recency is measured relative to the last order date in the dataset.*

## Key insights

1. **Revenue is concentrated.** At Risk - High value and Recent High-spenders are about 31% of customers but roughly 57% of estimated revenue.
2. **Repeat buying is very rare.** Champions and Repeat Customers together are under 2% of customers, so the main challenge is getting a second purchase.
3. **Recent High-spenders are the best opportunity.** They spend as much as the At Risk group but are still active, which makes them ideal for a follow-up campaign.
4. **At Risk - High value needs a win-back campaign.** They have been inactive for over a year (about 394 days).
5. **Lost customers are not worth spending on.** They are about 16% of customers and a small share of revenue.

## Recommendations

| Segment | Action |
|---|---|
| Recent High-spenders | Follow up at 60 to 90 days: cross-sell, review request, second-order incentive |
| New / Potential | Low-cost automated nurture emails |
| At Risk - High value | Strong win-back offer |
| Champions | Loyalty perks, early access, referral programme |
| Repeat Customers | Reminder and re-engagement campaign |
| Mid-term One-timers | Seasonal promotions |
| Lost | Minimal or no spend |

## Limitations

- Most customers have a single order, so frequency carries limited information.
- Monetary value includes freight, which can inflate spend for remote customers.
- Revenue shares are estimated as customers x average monetary value.
- Only delivered orders are included.

## How to run

1. Download the Olist dataset and load it into a MySQL database.
2. Run the SQL scripts in `SQL codes/` to create `rfm_base_view` and `rfm_data`.
3. Create a `.env` file in the notebook folder (see `.env.example`):

   ```
   DB_USER=
   DB_PASSWORD=
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=Olist_db
   ```

4. Install dependencies:

   ```bash
   pip install pandas numpy seaborn matplotlib sqlalchemy pymysql python-dotenv
   ```

5. Open `RFM Analysis.ipynb` and run all cells.

> **Security note:** database credentials are read from `.env`, which is excluded from version control via `.gitignore`. Never commit real passwords.

## Project structure

```
Olist Dataset Analysis/
├── RFM Analysis/
│   ├── RFM Analysis.ipynb
│   ├── RFM_Analysis_Report.md
│   └── Result dataset/
├── SQL codes/
├── .env.example
├── .gitignore
└── README.md
```
