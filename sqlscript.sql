REM   Script: OLAP
REM   DWM OLAP Operations

CREATE TABLE LOCATION_DIM ( 
    LOC_KEY INT, 
    REGION_NAME VARCHAR(50), 
    AREA_TYPE VARCHAR(10)  -- 'Land' or 'Ocean' 
);

CREATE TABLE TIME_DIM ( 
    TIME_KEY INT, 
    DATE_RECORDED DATE, 
    HOUR INT, 
    MONTH INT, 
    YEAR INT 
);

CREATE TABLE PROBE_DIM ( 
    PROBE_KEY INT, 
    PROBE_ID VARCHAR(10), 
    INSTALLED_DATE DATE 
);

CREATE TABLE WEATHER_FACT ( 
    FACT_ID INT, 
    LOC_KEY INT, 
    TIME_KEY INT, 
    PROBE_KEY INT, 
    AIR_PRESSURE FLOAT, 
    TEMPERATURE FLOAT, 
    PRECIPITATION FLOAT 
);

INSERT INTO LOCATION_DIM VALUES (1, 'Atlantic', 'Ocean');
INSERT INTO LOCATION_DIM VALUES (2, 'Pacific', 'Ocean');
INSERT INTO LOCATION_DIM VALUES (3, 'Sahara', 'Land');
INSERT INTO LOCATION_DIM VALUES (4, 'Amazon', 'Land');

INSERT INTO TIME_DIM VALUES (1, TO_DATE('2024-05-01', 'YYYY-MM-DD'), 10, 5, 2024);
INSERT INTO TIME_DIM VALUES (2, TO_DATE('2024-05-01', 'YYYY-MM-DD'), 11, 5, 2024);
INSERT INTO TIME_DIM VALUES (3, TO_DATE('2024-05-02', 'YYYY-MM-DD'), 10, 5, 2024);
INSERT INTO PROBE_DIM VALUES (1, 'P101', TO_DATE('2023-01-01', 'YYYY-MM-DD'));
INSERT INTO PROBE_DIM VALUES (2, 'P102', TO_DATE('2023-02-01', 'YYYY-MM-DD'));

INSERT INTO WEATHER_FACT VALUES (1, 1, 1, 1, 1013.2, 22.5, 1.2);
INSERT INTO WEATHER_FACT VALUES (2, 2, 1, 2, 1010.8, 23.0, 1.5);
INSERT INTO WEATHER_FACT VALUES (3, 3, 2, 1, 1009.3, 34.1, 0.0);
INSERT INTO WEATHER_FACT VALUES (4, 4, 3, 2, 1012.0, 28.4, 2.3);

--Drill Down
SELECT t.YEAR, t.MONTH, t.HOUR, AVG(f.TEMPERATURE) AS avg_temp 
FROM WEATHER_FACT f 
JOIN TIME_DIM t ON f.TIME_KEY = t.TIME_KEY 
GROUP BY t.YEAR, t.MONTH, t.HOUR 
ORDER BY t.YEAR, t.MONTH, t.HOUR;

--Slice
SELECT l.REGION_NAME, t.DATE_RECORDED, f.TEMPERATURE 
FROM WEATHER_FACT f 
JOIN LOCATION_DIM l ON f.LOC_KEY = l.LOC_KEY 
JOIN TIME_DIM t ON f.TIME_KEY = t.TIME_KEY 
WHERE l.AREA_TYPE = 'Land';

--Roll Up
SELECT t.DATE_RECORDED, AVG(f.PRECIPITATION) AS avg_precip 
FROM WEATHER_FACT f 
JOIN TIME_DIM t ON f.TIME_KEY = t.TIME_KEY 
GROUP BY t.DATE_RECORDED;

--Dice
SELECT t.DATE_RECORDED, f.TEMPERATURE 
FROM WEATHER_FACT f 
JOIN PROBE_DIM p ON f.PROBE_KEY = p.PROBE_KEY 
JOIN LOCATION_DIM l ON f.LOC_KEY = l.LOC_KEY 
JOIN TIME_DIM t ON f.TIME_KEY = t.TIME_KEY 
WHERE l.REGION_NAME = 'Sahara' 
  AND p.PROBE_ID = 'P101' 
  AND t.MONTH = 5;
