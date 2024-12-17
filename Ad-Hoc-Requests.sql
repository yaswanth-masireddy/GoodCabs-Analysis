-- 1. City-Level Fare and Trip Summary (Business Request - 1)
WITH trip_summary AS (
    SELECT
        city_id,
        COUNT(trip_id) AS Total_Trips,
        SUM(fare_amount) AS Total_fare_amount,
        SUM(distance_travelled_km) AS Total_distance_travelled_km
    FROM fact_trips
    GROUP BY city_id
),
city_avg_fare AS (
    SELECT 
        city_id, 
        Total_Trips, 
        ROUND((Total_fare_amount / Total_distance_travelled_km), 2) AS avg_fare_per_km,  
        ROUND((Total_fare_amount / Total_Trips), 2) AS avg_fare_per_trip,
        ROUND((Total_Trips / (SELECT COUNT(trip_id) AS Total_trips FROM fact_trips)) * 100, 2) AS contribution_to_total_trips
    FROM trip_summary
)
SELECT
    c.city_name, 
    a.Total_Trips AS total_trips, 
    a.avg_fare_per_km,
    a.avg_fare_per_trip,
    a.contribution_to_total_trips AS "%_contribution_to_total_trips"
FROM city_avg_fare a
JOIN dim_city c USING (city_id);

-- 2. Monthly City-Level Trips Target Performance Report (Business Request - 2)
WITH trip_count AS (
    SELECT 
        city_id, 
        date,
        MONTHNAME(date) AS month,
        COUNT(trip_id) AS trips 
    FROM fact_trips 
    GROUP BY city_id, date
),
monthly_trip_totals AS (
    SELECT
        city_id,
        month,
        SUM(trips) AS Total_Trips
    FROM trip_count 
    GROUP BY city_id, month
),
monthly_target AS (
    SELECT 
        city_id, 
        MONTHNAME(month) AS month, 
        total_target_trips 
    FROM targets_db.monthly_target_trips
    ORDER BY city_id
),
performance_status AS (
    SELECT 
        *, 
        CASE
            WHEN Total_Trips <= total_target_trips THEN "Below Target"
            WHEN Total_Trips > total_target_trips THEN "Above Target"
        END AS "performance_status",
        ROUND(((Total_Trips - total_target_trips) / total_target_trips) * 100, 2) AS difference
    FROM monthly_trip_totals c1
    JOIN monthly_target c2 USING (city_id, month)
)
SELECT 
    cc.city_name,
    c.month AS month_name,
    Total_Trips AS actual_trips,
    total_target_trips AS target_trips,
    performance_status,
    difference AS "%_difference"
FROM performance_status c
JOIN dim_city cc USING (city_id);

-- 3. City-Level Repeat Passenger Trip Frequency Report (Business Request - 3)
WITH city_repeat_trip_data AS (
    SELECT * 
    FROM dim_city c
    JOIN dim_repeat_trip_distribution r USING (city_id)
),
repeat_trip_percentage AS (
    SELECT
        city_name,
        ROUND((SUM(CASE WHEN trip_count = "2-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "2-Trips",
        ROUND((SUM(CASE WHEN trip_count = "3-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "3-Trips",
        ROUND((SUM(CASE WHEN trip_count = "4-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "4-Trips",
        ROUND((SUM(CASE WHEN trip_count = "5-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "5-Trips",
        ROUND((SUM(CASE WHEN trip_count = "6-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "6-Trips",
        ROUND((SUM(CASE WHEN trip_count = "7-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "7-Trips",
        ROUND((SUM(CASE WHEN trip_count = "8-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "8-Trips",
        ROUND((SUM(CASE WHEN trip_count = "9-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "9-Trips",
        ROUND((SUM(CASE WHEN trip_count = "10-Trips" THEN repeat_passenger_count ELSE 0 END) * 100) / SUM(repeat_passenger_count), 2) AS "10-Trips"
    FROM city_repeat_trip_data
    GROUP BY city_name
)
SELECT * FROM repeat_trip_percentage;

-- 4. Identify Cities with Highest and Lowest Total New Passengers (Business Request - 4)
WITH new_passenger_count AS (
    SELECT
        city_name, 
        month, 
        SUM(new_passengers) AS total_new_passengers 
    FROM dim_city c
    JOIN fact_passenger_summary p USING (city_id)
    GROUP BY city_name, month
),
city_new_passenger_totals AS (
    SELECT
        city_name, 
        SUM(total_new_passengers) AS total_new_passengers
    FROM new_passenger_count
    GROUP BY city_name
),
top_cities AS (
    SELECT 
        *,
        "Top 3" AS city_category
    FROM city_new_passenger_totals
    ORDER BY total_new_passengers DESC
    LIMIT 3
),
bottom_cities AS (
    SELECT 
        *,
        "Bottom 3" AS city_category
    FROM city_new_passenger_totals
    ORDER BY total_new_passengers ASC
    LIMIT 3
)
SELECT * FROM top_cities
UNION
SELECT * FROM bottom_cities;

-- 5. Identify Month with Highest Revenue for Each City (Business Request - 5)
WITH monthly_revenue AS (
    SELECT 
        MONTHNAME(date) AS Month, 
        city_id, 
        SUM(fare_amount) AS Revenue
    FROM fact_trips
    GROUP BY city_id, Month
),
city_max_revenue AS (
    SELECT 
        city_id, 
        MAX(Revenue) AS Max_Revenue
    FROM monthly_revenue 
    GROUP BY city_id
),
city_total_revenue AS (
    SELECT 
        city_id,
        SUM(fare_amount) AS Total_Revenue
    FROM fact_trips
    GROUP BY city_id
),
highest_revenue_month AS (
    SELECT 
        city_id, 
        Month, 
        Revenue 
    FROM monthly_revenue c
    JOIN city_max_revenue USING(city_id)
    WHERE Revenue = Max_Revenue
),
revenue_contribution AS (
    SELECT
        *, 
        ROUND((Revenue / Total_Revenue) * 100, 2) AS contribution 
    FROM highest_revenue_month
    JOIN city_total_revenue USING(city_id)
)
SELECT 
    c2.city_name,
    c.Month AS "highest_revenue_month", 
    C.Total_Revenue AS "revenue", 
    c.contribution AS "percentage_contribution (%)"
FROM revenue_contribution c
JOIN (SELECT * FROM dim_city) AS c2 USING (City_id);

-- 6. Repeat Passengers Rate Analysis (Business Request - 6)
WITH repeat_passenger_rate AS (
    SELECT 
        city_name,
        MONTHNAME(month) AS month, 
        repeat_passengers,
        total_passengers, 
        ROUND((repeat_passengers / total_passengers) * 100, 2) AS "monthly_repeat_passengers_rate (%)"
    FROM fact_passenger_summary
    JOIN dim_city USING (city_id)
),
city_repeat_passenger_totals AS (
    SELECT 
        city_id,
        SUM(repeat_passengers) AS total_repeat_passengers,
        SUM(total_passengers) AS total_passengers
    FROM fact_passenger_summary
    GROUP BY city_id
),
city_repeat_passenger_rate AS (
    SELECT 
        city_name,
        total_repeat_passengers,
        total_passengers, 
        ROUND((total_repeat_passengers / total_passengers) * 100, 2) AS city_repeat_passengers_rate
    FROM city_repeat_passenger_totals
    JOIN dim_city USING (city_id)
)
SELECT 
    c.*, 
    c2.city_repeat_passengers_rate AS "city_repeat_passengers_rate (%)"
FROM repeat_passenger_rate c
JOIN city_repeat_passenger_rate c2 USING (city_name);
