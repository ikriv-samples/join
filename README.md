# Join ON more than just ids
When we write a JOIN statement in SQL, it usually goes like this
`SELECT {columns} FROM parent LEFT JOIN child ON child.parent_id = parent.id`
Does it ever make sense for the ON condition to be more elaborate? The answer is a definite **YES** as demonstrated by this example.

## Summary
If we have a parent --> child relationship, and we want to left-join parents to children with specific criteria, this criteria should
go to the ON condition of the join. For example, if we have brands with promotions, and we want to fetch brands alongside promotions that start soon, ignoring all other promotions, we should put "starts soon" into the ON condition like this:

```
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b LEFT JOIN promotions p 
ON b.id = p.brand_id AND p.start_date BETWEEN DATE'2024-12-05' AND DATE'2024-12-31'
```

## Creating the Database

To create the database
1. Clone the repo: `git clone https://github.com/ikriv-samples/join.git`
2. Start mysql container: `./run-container.sh`. NOTE: you should have Docker installed on your system.
3. Fill the database: `./sql.sh create_db.sql`

This will create a simple database with two tables: brands and promotions.
```
mysql> select * from brands;
+----+-------------------------+
| id | name                    |
+----+-------------------------+
|  1 | ACME                    |
|  2 | Road Runner Auto Repair |
|  3 | Bugs Bunny Foods        |
|  4 | Daffy Duck Outfitters   |
+----+-------------------------+
```

```
mysql> select * from promotions;
+----+----------+---------------------------+------------+------------+
| id | brand_id | description               | start_date | end_date   |
+----+----------+---------------------------+------------+------------+
|  1 |        1 | 50% off all items         | 2024-12-01 | 2024-12-31 |
|  2 |        1 | Buy one bomb get one free | 2024-12-05 | 2024-12-25 |
|  3 |        3 | 50 carrots for $3         | 2024-10-05 | 2024-10-07 |
|  4 |        3 | 100 carrots for $5        | 2024-12-10 | 2024-12-15 |
+----+----------+---------------------------+------------+------------+
```

## Fetching brands alongside upcoming promotions

We need to fetch brands alongside upcoming promotions, i.e. promotions that start between 2024-12-05 and 2024-12-31. If a brand has no upcoming promotions, we still want to see it, but with NULLs in the promotion data columns, following the LEFT JOIN semantics.

The SQL query to do so is

```
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b
LEFT JOIN promotions p 
ON b.id = p.brand_id AND p.start_date BETWEEN DATE'2024-12-05' AND DATE'2024-12-31'
```

Note how the promotion condition is included as part of the ON criteria. 

`./sql.sh upcoming_promotions.sql`
```
+-------------------------+---------------------------+------------+------------+
| name                    | description               | start_date | end_date   |
+-------------------------+---------------------------+------------+------------+
| ACME                    | Buy one bomb get one free | 2024-12-05 | 2024-12-25 |
| Road Runner Auto Repair | NULL                      | NULL       | NULL       |
| Bugs Bunny Foods        | 100 carrots for $5        | 2024-12-10 | 2024-12-15 |
| Daffy Duck Outfitters   | NULL                      | NULL       | NULL       |
+-------------------------+---------------------------+------------+------------+
```
## Compare to other usages of JOIN
If we want to see all promotions, we execute a traditional JOIN with id comparison:

```
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b
LEFT JOIN promotions p
ON b.id = p.brand_id
```

`./sql.sh all_promotions.sql`
```
+-------------------------+---------------------------+------------+------------+
| name                    | description               | start_date | end_date   |
+-------------------------+---------------------------+------------+------------+
| ACME                    | Buy one bomb get one free | 2024-12-05 | 2024-12-25 |
| ACME                    | 50% off all items         | 2024-12-01 | 2024-12-31 |
| Road Runner Auto Repair | NULL                      | NULL       | NULL       |
| Bugs Bunny Foods        | 100 carrots for $5        | 2024-12-10 | 2024-12-15 |
| Bugs Bunny Foods        | 50 carrots for $3         | 2024-10-05 | 2024-10-07 |
| Daffy Duck Outfitters   | NULL                      | NULL       | NULL       |
+-------------------------+---------------------------+------------+------------+
```

Beware of applying the promotion criteria AFTER the join. This will select only brands with upcoming promotions and leave out all other brands.

```
FROM brands b
LEFT JOIN promotions
ON b.id = p.brand_id
WHERE p.start_date BETWEEN DATE'2024-12-05' AND DATE'2024-12-31' -- WRONG!
```

`./sql.sh wrong_promotions.sql`
```
+------------------+---------------------------+------------+------------+
| name             | description               | start_date | end_date   |
+------------------+---------------------------+------------+------------+
| ACME             | Buy one bomb get one free | 2024-12-05 | 2024-12-25 |
| Bugs Bunny Foods | 100 carrots for $5        | 2024-12-10 | 2024-12-15 |
+------------------+---------------------------+------------+------------+
```

Only the brands with upcoming promotions are retrieved, and all other brands are hidden.

## Conclusion
With `LEFT JOIN`, including a criteria in the `ON` clause has different effect from including the same criteria in the `WHERE` clause. `WHERE` clause filters out the parent records that don't have any children that match the criteria, effectively turning `LEFT JOIN` into an `INNER JOIN`. To maintain the `LEFT JOIN` semantics, any criteria pertaining to the child table should be placed in the `ON` clause.

