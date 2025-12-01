# Project

## Introduction

In this project **DBT** is used with **Snowflake database** to discover data and answer customers questions. Afterwards, as an extra mile, data was pulled from Snowflake to **Power BI** to do further analysis and present some KPIs visually.

---

## 1 Data Overview

### 1.1 Data Sets

There are **3 data sets**:

| Table        | Columns |
|--------------|--------|
| **Devices**  | `id`, `type`, `store_id` |
| **Transactions** | `id`, `device_id`, `product_name`, `product_sku`, `category_name`, `amount`, `status`, `card_number`, `cvv`, `created_at`, `happened_at` |
| **Stores**   | `id`, `name`, `address`, `city`, `country`, `created_at`, `typology`, `customer_id` |

From the first glimpse we have sensitive data like (card_number and cvv) that need to be 
Anonymized, more over we can normalize the data for to reduce data redundancy as we have a lot of repetition in product_SKU.  More over we have 


---

### 1.2 Data Quality Issues

- product_SKU should be unique for every product (this can be solved by many ways like doing composite concat for Eg) but this is not the case as the test verifies it should be unique. 
- Also some of the created_at data are before happened at assuming bad parsing. 
- File were converted to csv and Utf8 encoding to avoid any inconvenience. 

---

## 2 Data Modeling

![Data Model](images/data_model.png)  
*Figure 1: Star Schema Model*

### 2.1 Creating The Fact Table

#### 2.1.1 `fct_transactions`
- Removed: `product_name`, `category_name`
- Added: `store_id` via join with `devices`
- **PK**: `id`  
- **FKs**: `product_sku`, `device_id`, `store_id`  
- **Lineage**: `Devices`, `Transactions`

---

### 2.2 Creating Dimension Tables

#### 2.2.1 `dim_products`
- Normalized product data  
- **PK**: `product_sku`  
- **Lineage**: `Transactions`

#### 2.2.2 `dim_devices`
- **PK**: `id`  
- **Lineage**: `Devices`

#### 2.2.3 `dim_stores`
- **PK**: `id`  
- **Lineage**: `Stores`

---

### 2.3 Testing the Model’s Primary Keys

Using DBT built-in tests: to test Primary Key (unique, not null)

<img width="855" height="373" alt="image" src="https://github.com/user-attachments/assets/597a3d71-f8e8-4bb8-b329-d7518a38833b" />


Primary Key Test

![Data Model](images/test_results.png)

*Figure 3: DBT Test Output*

All tests passed as shown in Fig 3

---

## 3. Data Aggregation

### 3.1 Top 10 Stores by Transacted Amount

**Tables used** (Dim_Stores, Fct_Transactions)

To answer this  we need to get the Store id, Store name and the amount for these store from the transactions so we will definitely need to join the Fct_Transactions table. 

Start by selecting the desired columns from Stores and Transactions limiting to Top 10:
<img width="889" height="78" alt="image" src="https://github.com/user-attachments/assets/61df3b40-7d9d-43bb-9cd5-1bf03c8eb147" />

Joining transactions table(keeping in mind as it is already transacted amount so the status should be **accepted**:
<img width="975" height="87" alt="image" src="https://github.com/user-attachments/assets/2169da71-94ad-4ed1-aa89-09b2680f3d54" />

Group by the Store Id and Store name and ordering the output descending by stores profit (the sum of amount transacted): 
<img width="822" height="78" alt="image" src="https://github.com/user-attachments/assets/aed10ed4-5001-42fe-9056-4dc9b8d15851" />

Output: 
<img width="975" height="350" alt="image" src="https://github.com/user-attachments/assets/d369eebc-4cd9-4945-b6fd-c4116fd5b458" />
Figure 4 Top 10 Stores Results

As shown in (Fig 4) the top 10 stores with **Nec Ante Ltd** as the top store with profit **9383**. 

---

### 3.2 Top 10 Products Sold

**Tables used** (Fct_Transactions) 

To answer this we need to use the product_sku assuming we want to know the exact products by its sku not its name, The product_sku indicates to a unique product (regardless the data quality issue mentioned above).

Assuming the most products sold with accepted transactions we will select the product_sku and count of product sku (top 10) from Transactions table: 
 <img width="916" height="119" alt="image" src="https://github.com/user-attachments/assets/ae0ba247-d8dd-4740-980c-eca39d94ab62" />

As we need the products already sold so the status should be accepted so we make this condition grouping by product sku and ordering by sold_products (Count(product_sku):

<img width="445" height="119" alt="image" src="https://github.com/user-attachments/assets/5b29f2cb-bc2e-4ba4-bf6b-2b5237761cfb" />

**Output:**

<img width="975" height="320" alt="image" src="https://github.com/user-attachments/assets/03c6b11d-b518-4466-9cde-b84d4a3862db" />
Figure 5 Top 10 products sold


As we can observe in the output the top 10 product_skus by sold products. 

---

### 3.3 Average Transacted Amount per Store Typology and Country

**Tables used** (Dim_Stores, Fct_Transactions)

To answer this we would need the country, typology from the stores table(Dim_Stores) and the average of the transacted amount from the transactions table(Fct_Transactions).

First we are going to select the required fields and round the average of the amount to get only 2 decimal numbers for better observation:
<img width="975" height="126" alt="image" src="https://github.com/user-attachments/assets/76ae3f40-7c9a-4053-b5c4-a622fce9b8b4" />

Joining Fact Table Transactions (Fct_Transactions) to get the amount:
<img width="731" height="95" alt="image" src="https://github.com/user-attachments/assets/9cec308a-d688-4701-a5c4-edc7a05f4164" />

As we need the already transacted so status would be in accepted Grouping by country and typology, ordering by amount descending:

<img width="673" height="184" alt="image" src="https://github.com/user-attachments/assets/2a5e3759-93bc-43d9-ae5b-a09749275b0d" />

**Output:**
<img width="975" height="316" alt="image" src="https://github.com/user-attachments/assets/fe155d5b-530f-46d7-bb3a-a89fdfac99e3" />
Figure 6 Average transacted amount per store typology and country

As shown in the output **Vietnam Beauty** has the most average amount.

---

### 3.4 Percentage of Transactions per Device Type

**Tables used** (Dim_Devices, Fct_Transactions)

To answer this we have to use the device type(1,2,3,4,5) from Dim_devices and to count Id transactions from Fct_Transactions. 

Count of the T.id as No.of.Transactions assuming all transactions regardless of their status will be counted as the device was used for it, and the same number we will take for each device type / the total number of all rows(by the help of over() function) * times 100 to get the percentage and rounding all that to get only 2 decimal numbers for better observation. 

**(Number of transactions for each device type/  all transaction) x 100 as percentage** 

**Example: if device 1 were used 500 times(number of transactions used device 1) and we have 2000 transactions(total transactions)**

 **device 1 percentage would be 500/2000 * 100 = 25%**
<img width="975" height="221" alt="image" src="https://github.com/user-attachments/assets/0b674b37-0ae3-46c8-99be-0bdbefd77274" />

**Output:**
<img width="975" height="145" alt="image" src="https://github.com/user-attachments/assets/75a81565-78bc-409c-8962-024defd398ef" />
Figure 7 Percentage of transactions per device type

As Shown in (fig 7) device 4 have the most number of transactions(350) scoring 23.33%.  

---

### 3.5 Average Time for a Store to Perform First 5 Transactions

**Tables used** (Fct_Transactions)

To solve this we will need the store id and the happened at date(assuming that we want to over see when our customers trust our service regardless it is accepted or not) 

---

#### 3.4.1Creating The First CTE 

First step creating CTE ranked:

Selecting store id and our date(happened at) 

Using row_number window function (because it does not skip numbers) partition by store id (store that made the sale) order by the date (happened at as a timestamp) by default it will be ordered ascendingly. 
<img width="975" height="181" alt="image" src="https://github.com/user-attachments/assets/be058eed-691d-4cba-9f0e-6a942aa62c8c" />

**Checking Ranked Table output:** 
<img width="975" height="281" alt="image" src="https://github.com/user-attachments/assets/50dfcd10-e51a-4628-8992-78db8c0d19c2" />
Figure 8 Ranked Table Output

As shown in (fig 8) this is exactly what we want to see what we need to do now is to take the difference between the 2 timestamps (1 (the first transaction) and 5  the last transaction

#### 3.4.2 Creating The Second CTE 

Now we want to capture 1 & 5 as shown in (fig 8): 

What we will do is to make a case when with min() to capture is when row number(row_no) = 1 and max() to capture when row number = 5 

End as first date(first_date) = 1 and fifth date(fifth_date) = 5 from the first CTE(ranked):
<img width="975" height="157" alt="image" src="https://github.com/user-attachments/assets/72a728c9-b2b1-4dec-a047-7c80a396d091" />

Afterwards we set the row number to always be under 5 (as in fig8 we don’t want any transaction after that. Group by store id having count all = 5 as having runs after our query. 

<img width="420" height="123" alt="image" src="https://github.com/user-attachments/assets/32a27ebb-6e4d-4c96-b690-b275aa5f9e9f" />

#### 3.4.3 Selecting From First Five 

The final step is to select the average of difference between first and fifth dates and round them to two decimal numbers. 
<img width="975" height="97" alt="image" src="https://github.com/user-attachments/assets/6be5071c-e2ef-44ca-94f7-2aaae5f9b97f" />

**Output:**

<img width="975" height="55" alt="image" src="https://github.com/user-attachments/assets/4c092793-e007-4259-8945-e0796fe2efb5" />
Figure 9 Average time for a store to perform its first 5 transactions


Finally run all of the views using dbt run: 
<img width="975" height="509" alt="image" src="https://github.com/user-attachments/assets/3b01e115-739d-413b-a98d-25df483a1b97" />
Now the views are present in our snowflake database. 

---

## 4 Data Visualization and more insights  


With Snowflake Database connected to power bi we can grab out data for visualizations and further data discovery: 

<img width="975" height="557" alt="image" src="https://github.com/user-attachments/assets/c4a20b9e-5931-4ea7-8308-5907296b9291" />
Figure 10 Data visualization and further insights

As we can see in fig(9) after the data was ingested from Snowflake an interactive dashboard was created to dive deeper, discover more kpis and to be able to filter fast and effective. 















 


