# 📦 E-Commerce Supply Chain Bottleneck Analysis

### 📋 Project Objective
We analyzed an e-commerce dataset (Olist) to understand why a large volume of orders missed their delivery dates. The goal was to identify the exact root cause of these delays: is it an internal warehouse processing issue or an external delivery carrier bottleneck? I built a Data Cleansing Pipeline in Google BigQuery to extract, clean, and analyze this relational data.

### 🗂️ Data Source
* **Dataset:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### 🛠️ Tools & Technologies
* **Data Lake:** Google Cloud Storage (GCS)
* **Data Warehouse / SQL Engine:** Google BigQuery
* **Data Visualization:** Microsoft Power BI

### 📊 Key Business Insights
* **Fast Internal Warehouse:** The internal warehouse operations are highly efficient and are not the source of the bottleneck. Data shows it takes an average of only 3.3 days to process orders and hand them over to the carriers.
* **Severe Carrier Delays (External Bottleneck):** The external carriers are the primary cause of the delivery failures. Analysis revealed that carriers held 1,107 "shipped" orders for an average of 311 days without delivering them to the customers.
* **Freight Cost vs. Speed:** The data showed no correlation between higher freight costs and faster delivery times. Paying premium shipping rates did not mitigate or prevent carrier delays.

### 💡 Strategic Recommendations
* **Renegotiate SLAs:** The business should urgently review Service Level Agreements (SLAs) with current delivery carriers. Management should hold them accountable for the severe delays, seek financial compensation, or transition to more reliable logistics partners.
* **Proactive Damage Control:** Immediately contact the 1,107 affected customers. Offering refunds or dispatching replacement products is critical to retaining their trust and protecting the brand's reputation.
