# etl-project

### Team
- Daniel Kletter
- Jess Ramirez
- Graciela Zamudio

### Data Sources
- Top 250 Chains: https://www.kaggle.com/michau96/restaurant-business-rankings-2020
- Yelp Academic Dataset: https://www.yelp.com/dataset

### Proposal
Join two datasets consisting of Yelp business listings the Top 250 Restaurant Chains of 2020. We see value in using both datasets for competitive insights, sentiment analysis, and business intelligence in the restaurant industry. Also, these datasets are a great choice because what better way to get to know your teammates over breaking bread at the... data table.

The top250 CSV obtained from Kaggle is based on restaurant financial reports scraped from [Restaurant Business Magazine](http://www.restaurantbusinessonline.com/). The yelp JSON file is a subset of business data — including location, attributes, and categories — for use in personal, educational, and academic purposes.

### Extract
Separate jupyter notebooks were created to read the top250 CSV and yelp JSON files respectively. This was done to avoid conflicts and make sure each portion of code was working appropriately.

### Transform
Starting with the top250 dataset, we dropped the following columns which didn’t add any apparent value: `Content` and `Headquarters` were mostly null values. `YOY_Sales`, and `YOY_Units` were calculated deltas formatted as a percentage.

Because there isn’t a true common ID field to join on, and this is a one-to-many situation, we needed to compare restaurant names in the two datasets for consistency before any joining and to make sure we had enough useful data. After searching for each name from the top250 data in the yelp data we found 37 names which wouldn’t match for varying reasons. Using a dictionary and `.replace()` we changed the affected restaurant names in the top250 data because it was easier to make one change than many changes in the yelp data.

We dropped the following columns from the yelp dataset to keep things simple: `business_id`, `latitude`, `longitude`, `is_open`, `attributes`, and `hours`. 

Because the business category is organized as an array in the yelp data, we needed to find anything with `restaurants` or `coffee & tea` to eliminate non-restaurant businesses from the dataset. This was done using an OR regular expression off a keyword dictionary. The original yelp dataset was about 120 MB large and our priority was to reduce that as much as possible before loading it into the database.

### Load
We created a PostgreSQL database called restaurant_db and created two tables called top250 and yelp_data with the following schema:

```
CREATE table yelp_data (
	id SERIAL,
	name TEXT,
	address TEXT,
	city TEXT,
	state TEXT,
	postal_code TEXT,
	stars DEC,
	review_count INT,
	categories TEXT,
	PRIMARY KEY(id)
);

CREATE table top250 (
	id SERIAL,
	rank INT,
	restaurant TEXT,
	sales INT,
	units INT,
	category TEXT,
	PRIMARY KEY(id)
);
```

Back in our jupyter notebooks we made a connection to the database, inspected the table names, and appended the data into the appropriate tables. We used `pd.read_sql_query()` to confirm the data had been successfully loaded into each table.

Finally, we joined the two tables on the business name as follows:

```
SELECT top250.rank, yelp_data.name, yelp_data.address, yelp_data.city, yelp_data.state, yelp_data.postal_code, yelp_data.stars, top250.category, top250.sales, top250.units
FROM top250
INNER JOIN yelp_data ON top250.restaurant = yelp_data.name
ORDER BY top250.rank;
```
