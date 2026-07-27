CREATE TABLE analytics.state_lookup (
    state_code VARCHAR(2) PRIMARY KEY,
    state_name VARCHAR(50) NOT NULL
);
--Inserting state codes and names
INSERT INTO analytics.state_lookup (state_code, state_name) VALUES
('AL','Alabama'),
('AK','Alaska'),
('AZ','Arizona'),
('AR','Arkansas'),
('CA','California'),
('CO','Colorado'),
('CT','Connecticut'),
('DE','Delaware'),
('FL','Florida'),
('GA','Georgia'),
('HI','Hawaii'),
('ID','Idaho'),
('IL','Illinois'),
('IN','Indiana'),
('IA','Iowa'),
('KS','Kansas'),
('KY','Kentucky'),
('LA','Louisiana'),
('ME','Maine'),
('MD','Maryland'),
('MA','Massachusetts'),
('MI','Michigan'),
('MN','Minnesota'),
('MS','Mississippi'),
('MO','Missouri'),
('MT','Montana'),
('NE','Nebraska'),
('NV','Nevada'),
('NH','New Hampshire'),
('NJ','New Jersey'),
('NM','New Mexico'),
('NY','New York'),
('NC','North Carolina'),
('ND','North Dakota'),
('OH','Ohio'),
('OK','Oklahoma'),
('OR','Oregon'),
('PA','Pennsylvania'),
('RI','Rhode Island'),
('SC','South Carolina'),
('SD','South Dakota'),
('TN','Tennessee'),
('TX','Texas'),
('UT','Utah'),
('VT','Vermont'),
('VA','Virginia'),
('WA','Washington'),
('WV','West Virginia'),
('WI','Wisconsin'),
('WY','Wyoming');

--Verifying the lookup table
SELECT *
FROM analytics.state_lookup
ORDER BY state_code;


--Category lookup
DROP TABLE IF EXISTS analytics.category_lookup;

CREATE TABLE analytics.category_lookup AS
SELECT
    TRIM(category_id) AS category_id,
    MAX(INITCAP(TRIM(category_name))) AS category_name
FROM buildpro.products_raw
WHERE NULLIF(TRIM(category_name), '') IS NOT NULL
GROUP BY TRIM(category_id);

--Checking categories
SELECT *
FROM analytics.category_lookup
ORDER BY category_id;