-- setup/load_reviews.sql
-- Run once in the Databricks SQL Editor (SQL warehouse) before `dbt build`.
--
-- Why this file exists:
-- olist_order_reviews_dataset.csv has free-text comment columns that contain
-- line breaks and commas inside quotes. The Databricks "Create table from upload"
-- UI splits on every line break, so rows were shifted: review_id ended up holding
-- fragments of comment text and the score column held dates.
--
-- read_files() with multiLine => true parses quoted fields correctly.
-- inferSchema => false keeps every column as string, matching the other raw tables,
-- so all typing happens in models/staging/stg_order_reviews.sql.
--
-- Prerequisite: upload the CSV to the volume raw.olist_shipping.landing
-- (Catalog -> raw -> olist_shipping -> Create -> Volume -> Upload).
 
create or replace table raw.olist_shipping.olist_order_reviews_dataset as
select * except (_rescued_data)
from read_files(
    '/Volumes/raw/olist_shipping/landing/olist_order_reviews_dataset.csv',
    format              => 'csv',
    header              => true,
    multiLine           => true,
    escape              => '"',
    schemaEvolutionMode => 'none',
    inferSchema         => false
);
 
-- Sanity check. Expect ~99,224 rows, review_score between 1 and 5,
-- and slightly fewer distinct order_ids than rows (a few orders have two reviews).
select
    count(*)                    as rows,
    count(distinct order_id)    as orders,
    min(review_score)           as min_score,
    max(review_score)           as max_score
from raw.olist_shipping.olist_order_reviews_dataset;
 