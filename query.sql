-- Create tables
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

-- Query to check successful load
SELECT * FROM yelp_data;

SELECT * FROM top250;

-- Join tables on restaurant
SELECT * FROM top250
INNER JOIN yelp_data ON top250.restaurant = yelp_data.name
ORDER BY top250.rank;
