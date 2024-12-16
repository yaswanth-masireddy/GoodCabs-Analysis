-- Top and Bottom 3 cities based on trips
WITH top_cities AS (
    SELECT 
        city_id, 
        COUNT(trip_id) AS total_trips,
        'Top 3' AS city_category
    FROM 
        trips_db.fact_trips 
    GROUP BY 
        city_id
    ORDER BY 
        total_trips DESC 
    LIMIT 3
),
bottom_cities AS (
    SELECT 
        city_id, 
        COUNT(trip_id) AS total_trips,
        'Bottom 3' AS city_category
    FROM 
        trips_db.fact_trips 
    GROUP BY 
        city_id
    ORDER BY 
        total_trips ASC 
    LIMIT 3
),
combined_cities AS (
    SELECT * FROM top_cities
    UNION
    SELECT * FROM bottom_cities
)
SELECT 
    city_name, 
    total_trips, 
    city_category 
FROM 
    combined_cities
JOIN 
    dim_city 
USING(city_id);

-- Average Fare per City
SELECT 
    city_name,
    ROUND(AVG(fare_amount), 2) AS avg_fare_per_trip, 
    ROUND(AVG(distance_travelled_km), 2) AS avg_trip_distance
FROM 
    fact_trips
JOIN 
    dim_city 
USING(city_id)
GROUP BY
    city_name
ORDER BY 
    avg_fare_per_trip;

-- Average Ratings by City and Passenger Type
WITH ratings_cte AS (
    SELECT
        city_id,
        passenger_type,
        AVG(passenger_rating) AS avg_passenger_rating,
        AVG(driver_rating) AS avg_driver_rating
    FROM
        fact_trips
    GROUP BY
        city_id, passenger_type
    ORDER BY 
        avg_passenger_rating DESC, avg_driver_rating DESC
)
SELECT 
    city_name, 
    passenger_type, 
    avg_passenger_rating, 
    avg_driver_rating 
FROM 
    ratings_cte
JOIN 
    dim_city 
USING(city_id);

-- Peak and Low Demand Months for Cities
WITH monthly_trips_cte AS (
    SELECT
        c.city_name,
        d.month_name,
        COUNT(t.trip_id) AS total_trips,
        RANK() OVER (PARTITION BY c.city_name ORDER BY COUNT(t.trip_id) DESC) AS rank_flag
    FROM
        fact_trips t
    JOIN 
        dim_date d
    USING(date)
    JOIN
        dim_city c
    USING (city_id)
    GROUP BY 
        c.city_name, d.month_name
)
SELECT 
    city_name AS city,
    month_name AS month,
    total_trips,
    CASE
        WHEN rank_flag = 1 THEN 'Peak Demand'
        ELSE 'Low Demand'
    END AS trip_demand
FROM 
    monthly_trips_cte
WHERE 
    rank_flag IN (1, 6);

-- Weekend vs Weekday Trip Demand by City
WITH day_type_cte AS (
    SELECT 
        t.city_id,
        d.day_type, 
        COUNT(t.trip_id) AS total_trips 
    FROM 
        fact_trips t 
    JOIN 
        dim_date d 
    USING(date)
    GROUP BY 
        t.city_id, d.day_type
)
SELECT 
    city_name, 
    day_type, 
    total_trips 
FROM 
    day_type_cte
JOIN 
    dim_city 
USING (city_id);

-- Repeat Passenger Frequency and City Contribution Analysis
WITH repeat_trips_cte AS (
    SELECT 
        city_id, 
        SUM(repeat_passenger_count) AS total_repeat_trips 
    FROM 
        dim_repeat_trip_distribution 
    GROUP BY
        city_id
),
repeat_trips_detailed_cte AS (
    SELECT 
        city_id,
        trip_count, 
        SUM(repeat_passenger_count) AS total_repeat_trips 
    FROM 
        dim_repeat_trip_distribution 
    GROUP BY 
        city_id, trip_count
)
SELECT 
    city_name,
    trip_count,
    detailed_cte.total_repeat_trips AS total_trips,
    ROUND((detailed_cte.total_repeat_trips / summary_cte.total_repeat_trips) * 100, 2) AS trip_percentage
FROM 
    repeat_trips_cte summary_cte
JOIN 
    repeat_trips_detailed_cte detailed_cte 
USING(city_id)
JOIN
    dim_city 
USING(city_id);

-- Monthly Target Achievement
WITH actuals_cte AS (
    WITH trips_cte AS (
        SELECT 
            city_id, 
            COUNT(trip_id) AS total_trips,
            AVG(passenger_rating) AS avg_passenger_rating 
        FROM 
            fact_trips 
        GROUP BY 
            city_id
    ),
    new_passengers_cte AS (
        SELECT 
            city_id, 
            COUNT(trip_id) AS total_new_passengers
        FROM 
            fact_trips 
        WHERE 
            passenger_type = 'new' 
        GROUP BY 
            city_id
    )
    SELECT 
        * 
    FROM 
        trips_cte
    JOIN 
        new_passengers_cte 
    USING(city_id)
),
targets_cte AS (
    WITH monthly_targets_cte AS (
        SELECT 
            city_id, 
            SUM(target_new_passengers) AS target_new_passengers
        FROM 
            targets_db.monthly_target_new_passengers
        GROUP BY
            city_id
    ),
    trips_targets_cte AS (
        SELECT
            city_id,
            SUM(total_target_trips) AS target_trips
        FROM 
            targets_db.monthly_target_trips
        GROUP BY 
            city_id
    ),
    ratings_targets_cte AS (
        SELECT 
            * 
        FROM 
            targets_db.city_target_passenger_rating
    )
    SELECT 
        * 
    FROM 
        monthly_targets_cte
    JOIN 
        trips_targets_cte 
    USING(city_id)
    JOIN 
        ratings_targets_cte 
    USING(city_id)
)
SELECT 
    city_name,
    total_trips,
    target_trips,
    ROUND((total_trips / target_trips) * 100, 2) AS target_trips_achieved_percentage,
    total_new_passengers,
    target_new_passengers,
    ROUND((total_new_passengers / target_new_passengers) * 100, 2) AS target_new_passengers_achieved_percentage,
    avg_passenger_rating, 
    target_avg_passenger_rating,
    ROUND((avg_passenger_rating / target_avg_passenger_rating) * 100, 2) AS target_passenger_rating_achieved_percentage
FROM 
    actuals_cte
JOIN 
    targets_cte 
USING(city_id)
JOIN 
    dim_city 
USING(city_id);

-- Highest and Lowest Repeat Passenger Rate (RPR%) by City and Month
-- By City
WITH city_rpr_cte AS (
    SELECT 
        city_id, 
        SUM(total_passengers) AS total_passengers, 
        SUM(repeat_passengers) AS repeat_passengers 
    FROM 
        fact_passenger_summary
    GROUP BY 
        city_id
),
city_rpr_calculated_cte AS (
    SELECT 
        *, 
        ROUND((repeat_passengers / total_passengers) * 100, 2) AS rpr
    FROM 
        city_rpr_cte
    ORDER BY 
        rpr DESC
),
city_rpr_ranked_cte AS (
    SELECT 
        city_name, 
        repeat_passengers, 
        total_passengers, 
        rpr,
        DENSE_RANK() OVER (ORDER BY rpr DESC) AS rank_flag
    FROM 
        city_rpr_calculated_cte
    JOIN 
        dim_city 
    USING(city_id)
)
SELECT 
    city_name AS city, 
    repeat_passengers, 
    total_passengers, 
    rpr AS rpr_percentage
FROM 
    city_rpr_ranked_cte
WHERE 
    rank_flag IN (1, 2, 9, 10);

-- By Month
WITH month_rpr_cte AS (
    SELECT 
        month_name,
        SUM(total_passengers) AS total_passengers, 
        SUM(repeat_passengers) AS repeat_passengers 
    FROM 
        fact_passenger_summary p
    JOIN 
        dim_date d 
    ON d.date = p.month
    GROUP BY 
        month_name
),
month_rpr_calculated_cte AS (
    SELECT 
        *,
        ROUND((repeat_passengers / total_passengers) * 100, 2) AS rpr 
    FROM 
        month_rpr_cte
    ORDER BY 
        rpr DESC
)
SELECT
    month_name,
    repeat_passengers, 
    total_passengers,
    rpr AS rpr_percentage
FROM 
    month_rpr_calculated_cte;
