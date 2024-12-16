# Goodcabs Dashboard & Data Analysis - README

## Project Overview
The **Goodcabs Dashboard** is an advanced analytics tool designed to help **Goodcabs** monitor and optimize its operations across multiple cities in India. It provides insights into key performance indicators (KPIs) such as trip volume, passenger satisfaction, repeat passenger rates, and the balance between new and repeat passengers. The goal is to support decision-making, performance improvements, and growth, especially in tier-2 city markets.

---

## Dashboard Pages
The dashboard consists of the following key pages:

### 1. Overview Page
Displays an overall summary of key metrics.
- **KPIs**:
  - Total Revenue (₹) (compared to last month)
  - Total Trips (compared to last month)
  - Average Passenger Rating
  - Trips Target Achieved (%)
  - New Passenger Target Achieved (%)
- **Visuals**:
  - Top 3 Cities by Trip Volume
  - Bottom 3 Cities by Trip Volume
  - Top 3 Cities by Passenger Rating
  - Bottom 3 Cities by Passenger Rating
  - City Performance Table
  - Top 5 Cities by New Passenger Contribution

### 2. Revenue Page
Tracks revenue performance and insights.
- **KPIs**:
  - Total Revenue (₹) (compared to last month)
  - Total Trips (compared to last month)
  - MoM Revenue Growth (%)
  - Average Revenue per Trip (₹)
  - Repeat Passenger Rate (%)
  - New Passenger Rate (%)
- **Visuals**:
  - Monthly Revenue Trends
  - City-Wise Revenue Insights
  - Revenue vs. Travel Distance
  - Performance Overview Matrix
  - Revenue Distribution Map

### 3. Trips Page
Provides detailed trip statistics and trends.
- **KPIs**:
  - Total Trips (compared to last month)
  - Total New Trips (compared to last month)
  - Total Repeat Trips (compared to last month)
  - Average Distance Travelled (km)
  - Average Driver Rating
  - Average Fare per KM
- **Visuals**:
  - City-Wise Trip Distribution
  - Monthly Trip Trends
  - Trip Length Distribution
  - Trip Performance Summary

### 4. Actual vs Target Trips Page
Compares actual performance against set targets.
- **KPIs**:
  - Trips Target Achieved (%)
  - New Passenger Target (%)
  - Cities Meeting Trip Targets (%)
  - Passenger Rating Target (%)
  - New vs Repeat Trips Ratio
- **Visuals**:
  - City Performance: Actual vs Target Trips
  - Monthly New Passenger Target Achievement
  - City Performance: Actual vs Target Passenger Ratings
  - Target Achievement Summary Table

---

## Data Files
The dashboard relies on several data sources from **Goodcabs'** internal systems. Below is a summary of each data file used:

1. **city_target_passenger_rating**
   - **Columns**: `city_id`, `target_avg_passenger_rating`
   - **Purpose**: Contains target passenger ratings for each city.

2. **dim_city**
   - **Columns**: `city_id`, `city_name`
   - **Purpose**: Contains city information where Goodcabs operates.

3. **dim_date**
   - **Columns**: `date`, `start_of_month`, `month_name`, `day_type`
   - **Purpose**: Provides date-related information (weekend/weekday, month).

4. **dim_repeat_trip_distribution**
   - **Columns**: `month`, `city_id`, `trip_count`, `repeat_passenger_count`
   - **Purpose**: Distribution of repeat trips by city and month.

5. **fact_passenger_summary**
   - **Columns**: `month`, `city_id`, `new_passengers`, `repeat_passengers`, `total_passengers`
   - **Purpose**: Summary of new and repeat passengers by city and month.

6. **fact_trips**
   - **Columns**: `trip_id`, `date`, `city_id`, `passenger_type`, `distance_travelled (km)`, `fare_amount`, `passenger_rating`, `driver_rating`
   - **Purpose**: Contains trip data (distance, fare, ratings).

7. **monthly_target_new_passengers**
   - **Columns**: `month`, `city_id`, `target_new_passengers`
   - **Purpose**: Monthly new passenger targets per city.

8. **monthly_target_trips**
   - **Columns**: `month`, `city_id`, `total_target_trips`
   - **Purpose**: Monthly target trips per city.

9. **actual_and_target_trip**
   - **Columns**: `city_id`, `target_achieved_%`, `Target_trip_check`, `Total_target_trips`, `Total_Trips`, `Cities_Achieved_Target_%`, `Target_met_count`
   - **Purpose**: Comparison of actual vs target trips, achievement percentages for each city.

---

## Dashboard KPIs and Visuals

### Overview Page
**KPIs**:
- Total Revenue (₹) (compared to last month)
- Total Trips (compared to last month)
- Average Passenger Rating
- Trips Target Achieved (%)
- New Passenger Target Achieved (%)

**Visuals**:
- Top 3 Cities by Trip Volume
- Bottom 3 Cities by Trip Volume
- Top 3 Cities by Passenger Rating
- Bottom 3 Cities by Passenger Rating
- City Performance Table
- Top 5 Cities by New Passenger Contribution

---

## Data Analysis Insights

### 1. **Top and Bottom Performing Cities**
- **Top 3 Cities by total trips**: Jaipur, Lucknow, Surat
- **Bottom 3 Cities by total trips**: Mysore, Coimbatore, Visakhapatnam

### 2. **Average Fare per Trip by City**
- **Highest Average Fare per Trip**: Jaipur (₹483.92)
- **Lowest Average Fare per Trip**: Surat (₹117.27)

### 3. **Average Ratings by City and Passenger Type**
- **Highest Passenger Ratings**: Mysore (New: 8.98, Repeat: 7.98)
- **Lowest Passenger Ratings**: Surat (New: 7.98, Repeat: 5.99)

### 4. **Peak and Low Demand Months by City**
- **Peak Demand**: Visakhapatnam (April), Jaipur (February), Indore (May)
- **Low Demand**: Chandigarh (April), Coimbatore (June), Mysore (January)

### 5. **Weekend vs Weekday Trip Demand by City**
- **Higher Weekday Demand**: Surat, Lucknow, Indore
- **Higher Weekend Demand**: Jaipur, Kochi, Vadodara

### 6. **Repeat Passenger Frequency and City Contribution**
- **Top Cities for Repeat Passengers**: Jaipur, Lucknow

### 7. **Monthly Target Achievement**
- **Top Performer**: Visakhapatnam (Achieved near 100% targets)
- **Bottom Performer**: Surat (Challenges in total trips and passenger ratings)

### 8. **Repeat Passenger Rate (RPR%)**
- **Top RPR%**: Surat (42.63%), Lucknow (37.12%)
- **Bottom RPR%**: Mysore (11.23%), Coimbatore (25.57%)

---

## Recommendations for Growth

### 1. **Quality of Service**
- **Maintain high vehicle standards** to enhance the passenger experience.
- **Professional driver behavior**: Provide training to drivers to maintain punctuality and professionalism.

### 2. **Competitive Pricing**
- **Adjust pricing strategies** based on the competitive landscape.
- **Offer discounts** in high-competition areas to attract and retain customers.

### 3. **Demographics & Socioeconomic Factors**
- **Affluent Populations**: Tailor services for tourists and higher-income groups in cities like Mysore and Jaipur.
- **Working-Class Focus**: Develop commuter packages in cities like Lucknow and Vadodara.

### 4. **Impact of Tourism & Local Events**
- **Event-Specific Campaigns**: Focus on seasonal spikes (e.g., Diwali, Onam).
- **Tailored Tourist Services**: Offer special packages for tourists.

### 5. **Emerging Mobility Trends**
- **Electric Vehicles (EVs)**: Introduce EVs in cities like Surat and Coimbatore.
- **Shared Mobility**: Promote ride-sharing options in tier-2 cities.

### 6. **Partnership Opportunities**
- **Collaborate with local businesses**: Partner with hotels, malls, and event venues for promotions.
- **Seamless travel solutions**: Provide integrated travel packages.

### 7. **Data-Driven Decisions**
- **Customer Feedback**: Use feedback to identify areas for improvement.
- **Route Optimization**: Leverage real-time traffic data for better service.

---

## Conclusion
This README serves as a comprehensive guide for both the **Goodcabs Dashboard** and **Data Analysis**. For more detailed queries or further analysis, refer to the data tables or contact the analysis team for assistance. By utilizing these insights, Goodcabs can optimize operations, improve customer experience, and drive growth.
