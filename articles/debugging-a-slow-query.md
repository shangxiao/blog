Debugging a Slow Query
======================

... and solving with DISTINCT ON
--------------------------------


Introduction
------------

 - PostgreSQL RDS t3.medium
   - 2 vCPUs
   - 4 GB
 - Event table
   - ~900,000 records
   - Event type
   - Attributed to a specific IoT device by UUID
 - Query on some layout + latest event for a specific type, for a specific device
 - Query ran once per 5 mins to update a kiosk
 - NewRelic identified this query as taking 60s

Isolation
---------
 
 - Cloned DB from a backup

```sql
SELECT
    master_portal_bin.id AS "id",
    master_portal_waste_stream.site_id AS site_id,
    master_portal_bin.bin_identifier AS bin_identifier,
    COALESCE(master_portal_bin.empty_weight, master_portal_bin_configuration.default_empty_weight) AS bin_empty_weight,
    master_portal_bin_beacon.hardware_id as bin_uuid,
    master_portal_waste_stream.type_id AS waste_stream_type_id,
    master_portal_bin.bin_configuration_id AS bin_configuration_id,
    master_portal_space.level_id AS level_id,
    CASE WHEN master_portal_space.client_account_id IS NOT NULL THEN master_portal_space.client_account_id
         ELSE master_portal_space.tenant_id + 1000000
    END AS tenant_id,
    NULL AS last_modified,
    NULL AS journey_id
FROM master_portal_bin
LEFT JOIN master_portal_bin_configuration ON master_portal_bin_configuration.id = master_portal_bin.bin_configuration_id
LEFT JOIN master_portal_bin_beacon ON master_portal_bin_beacon.id = master_portal_bin.bin_beacon_id
LEFT JOIN (
    SELECT
        t1.occurred_at,
        cast_to_uuid_ignore_invalid(t1.raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
        cast_to_uuid_ignore_invalid(t1.raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
    FROM master_portal_bin_event t1
    JOIN (
        SELECT
            MAX(occurred_at) as occurred_at,
            raw_event_data->>'bin_beacon_uuid' as bin_beacon_uuid
        FROM master_portal_bin_event
        WHERE event_type='BIN_LOCATED'
        GROUP BY bin_beacon_uuid
    ) t2 ON t1.raw_event_data->>'bin_beacon_uuid' = t2.bin_beacon_uuid AND t1.occurred_at = t2.occurred_at
) as latest_bin_located_event ON master_portal_bin_beacon.hardware_id = latest_bin_located_event.bin_beacon_uuid
LEFT JOIN master_portal_waste_stream ON master_portal_waste_stream.id = master_portal_bin.waste_stream_id
LEFT JOIN master_portal_location_beacon ON master_portal_location_beacon.hardware_id = latest_bin_located_event.location_beacon_uuid
LEFT JOIN master_portal_space ON master_portal_space.id = master_portal_location_beacon.space_id
WHERE master_portal_bin.site_id = ANY(ARRAY[1065,425,41,423,40,42,53,422,424,765,766])
ORDER BY master_portal_bin.id DESC
```

Query plan

```
                                                                                    QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=365804.21..365813.98 rows=3908 width=124) (actual time=50249.900..50251.158 rows=9303 loops=1)
   Sort Key: master_portal_bin.id DESC
   Sort Method: quicksort  Memory: 1324kB
   ->  Nested Loop Left Join  (cost=68698.38..365571.05 rows=3908 width=124) (actual time=1023.957..50240.341 rows=9303 loops=1)
         ->  Hash Left Join  (cost=68698.08..364582.87 rows=3908 width=62) (actual time=1023.595..50213.114 rows=9303 loops=1)
               Hash Cond: ((cast_to_uuid_ignore_invalid(((t1.raw_event_data ->> 'location_beacon_uuid'::text))::character varying)) = master_portal_location_beacon.hardware_id)
               ->  Hash Right Join  (cost=68692.93..364535.70 rows=3908 width=74) (actual time=1023.531..50206.296 rows=9303 loops=1)
                     Hash Cond: (cast_to_uuid_ignore_invalid(((t1.raw_event_data ->> 'bin_beacon_uuid'::text))::character varying) = master_portal_bin_beacon.hardware_id)
                     ->  Hash Join  (cost=68505.38..363716.78 rows=4556 width=372) (actual time=1014.591..50146.006 rows=8882 loops=1)
                           Hash Cond: (((t1.raw_event_data ->> 'bin_beacon_uuid'::text) = t2.bin_beacon_uuid) AND (t1.occurred_at = t2.occurred_at))
                           ->  Seq Scan on master_portal_bin_event t1  (cost=0.00..290319.20 rows=910176 width=380) (actual time=0.070..45786.474 rows=910467 loops=1)
                           ->  Hash  (cost=68300.53..68300.53 rows=13657 width=40) (actual time=886.340..886.344 rows=1069 loops=1)
                                 Buckets: 16384  Batches: 1  Memory Usage: 212kB
                                 ->  Subquery Scan on t2  (cost=67993.24..68300.53 rows=13657 width=40) (actual time=885.743..886.041 rows=1069 loops=1)
                                       ->  HashAggregate  (cost=67993.24..68163.96 rows=13657 width=40) (actual time=885.742..885.947 rows=1069 loops=1)
                                             Group Key: (master_portal_bin_event.raw_event_data ->> 'bin_beacon_uuid'::text)
                                             Batches: 1  Memory Usage: 529kB
                                             ->  Seq Scan on master_portal_bin_event  (cost=0.00..64514.55 rows=695739 width=40) (actual time=0.006..650.183 rows=692422 loops=1)
                                                   Filter: ((event_type)::text = 'BIN_LOCATED'::text)
                                                   Rows Removed by Filter: 218045
                     ->  Hash  (cost=168.80..168.80 rows=1500 width=58) (actual time=8.926..8.931 rows=1490 loops=1)
                           Buckets: 2048  Batches: 1  Memory Usage: 130kB
                           ->  Hash Left Join  (cost=69.11..168.80 rows=1500 width=58) (actual time=0.573..7.449 rows=1490 loops=1)
                                 Hash Cond: (master_portal_bin.waste_stream_id = master_portal_waste_stream.id)
                                 ->  Hash Left Join  (cost=48.07..143.80 rows=1500 width=54) (actual time=0.368..6.513 rows=1490 loops=1)
                                       Hash Cond: (master_portal_bin.bin_beacon_id = master_portal_bin_beacon.id)
                                       ->  Hash Left Join  (cost=2.15..93.94 rows=1500 width=42) (actual time=0.032..3.579 rows=1490 loops=1)
                                             Hash Cond: (master_portal_bin.bin_configuration_id = master_portal_bin_configuration.id)
                                             ->  Seq Scan on master_portal_bin  (cost=0.03..87.54 rows=1500 width=26) (actual time=0.013..2.389 rows=1490 loops=1)
                                                   Filter: (site_id = ANY ('{1065,425,41,423,40,42,53,422,424,765,766}'::integer[]))
                                                   Rows Removed by Filter: 13
                                             ->  Hash  (cost=1.50..1.50 rows=50 width=20) (actual time=0.014..0.014 rows=24 loops=1)
                                                   Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                   ->  Seq Scan on master_portal_bin_configuration  (cost=0.00..1.50 rows=50 width=20) (actual time=0.005..0.009 rows=24 loops=1)
                                       ->  Hash  (cost=28.74..28.74 rows=1374 width=20) (actual time=0.331..0.332 rows=1422 loops=1)
                                             Buckets: 2048  Batches: 1  Memory Usage: 89kB
                                             ->  Seq Scan on master_portal_bin_beacon  (cost=0.00..28.74 rows=1374 width=20) (actual time=0.005..0.182 rows=1422 loops=1)
                                 ->  Hash  (cost=12.13..12.13 rows=713 width=12) (actual time=0.192..0.193 rows=774 loops=1)
                                       Buckets: 1024  Batches: 1  Memory Usage: 42kB
                                       ->  Seq Scan on master_portal_waste_stream  (cost=0.00..12.13 rows=713 width=12) (actual time=0.006..0.108 rows=774 loops=1)
               ->  Hash  (cost=3.40..3.40 rows=140 width=20) (actual time=0.054..0.055 rows=144 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 16kB
                     ->  Seq Scan on master_portal_location_beacon  (cost=0.00..3.40 rows=140 width=20) (actual time=0.011..0.036 rows=144 loops=1)
         ->  Memoize  (cost=0.30..6.26 rows=1 width=16) (actual time=0.002..0.002 rows=1 loops=9303)
               Cache Key: master_portal_location_beacon.space_id
               Cache Mode: logical
               Hits: 9172  Misses: 131  Evictions: 0  Overflows: 0  Memory Usage: 15kB
               ->  Index Scan using space_site_constraint_target on master_portal_space  (cost=0.29..6.25 rows=1 width=16) (actual time=0.068..0.068 rows=1 loops=131)
                     Index Cond: (id = master_portal_location_beacon.space_id)
 Planning Time: 1.118 ms
 Execution Time: 50251.671 ms
(51 rows)
```

The problem is mainly within the event table subquery, let's confirm that by isolation:

```sql
=> explain analyze

SELECT
    t1.occurred_at,
    cast_to_uuid_ignore_invalid(t1.raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
    cast_to_uuid_ignore_invalid(t1.raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
FROM master_portal_bin_event t1
JOIN (
    SELECT
        MAX(occurred_at) as occurred_at,
        raw_event_data->>'bin_beacon_uuid' as bin_beacon_uuid
    FROM master_portal_bin_event
    WHERE event_type='BIN_LOCATED'
    GROUP BY bin_beacon_uuid
) t2 ON t1.raw_event_data->>'bin_beacon_uuid' = t2.bin_beacon_uuid AND t1.occurred_at = t2.occurred_at
;
                                                                        QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=68505.38..136198.12 rows=4556 width=40) (actual time=1646.849..49792.512 rows=8882 loops=1)
   Hash Cond: (((t1.raw_event_data ->> 'bin_beacon_uuid'::text) = t2.bin_beacon_uuid) AND (t1.occurred_at = t2.occurred_at))
   ->  Seq Scan on master_portal_bin_event t1  (cost=0.00..60499.76 rows=910176 width=364) (actual time=0.041..1386.383 rows=910467 loops=1)
   ->  Hash  (cost=68300.53..68300.53 rows=13657 width=40) (actual time=1608.543..1608.545 rows=1069 loops=1)
         Buckets: 16384  Batches: 1  Memory Usage: 212kB
         ->  Subquery Scan on t2  (cost=67993.24..68300.53 rows=13657 width=40) (actual time=1604.617..1606.485 rows=1069 loops=1)
               ->  HashAggregate  (cost=67993.24..68163.96 rows=13657 width=40) (actual time=1604.617..1606.377 rows=1069 loops=1)
                     Group Key: (master_portal_bin_event.raw_event_data ->> 'bin_beacon_uuid'::text)
                     Batches: 1  Memory Usage: 529kB
                     ->  Seq Scan on master_portal_bin_event  (cost=0.00..64514.55 rows=695739 width=40) (actual time=0.007..1400.057 rows=692422 loops=1)
                           Filter: ((event_type)::text = 'BIN_LOCATED'::text)
                           Rows Removed by Filter: 218045
 Planning Time: 2.103 ms
 Execution Time: 49794.078 ms
(14 rows)
```

- The hash join is the predominate cost
- There is an index on the event table for the device UUID, however it is a functional index casting the text to `uuid` type: `cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid')`

Updating the join to make use of the index:

```sql
=> explain analyze

SELECT
    t1.occurred_at,
    cast_to_uuid_ignore_invalid(t1.raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
    cast_to_uuid_ignore_invalid(t1.raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
FROM master_portal_bin_event t1
JOIN (
    SELECT
        MAX(occurred_at) as occurred_at,
        cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid
    FROM master_portal_bin_event
    WHERE event_type='BIN_LOCATED'
    GROUP BY bin_beacon_uuid
) t2 ON cast_to_uuid_ignore_invalid(t1.raw_event_data->>'bin_beacon_uuid') = t2.bin_beacon_uuid AND t1.occurred_at = t2.occurred_at
;
                                                                                                                                                    QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=241928.42..249482.12 rows=52 width=40) (actual time=2036.895..2104.268 rows=8882 loops=1)
   ->  HashAggregate  (cost=241927.99..242192.07 rows=1006 width=24) (actual time=2036.867..2037.297 rows=1069 loops=1)
         Group Key: cast_to_uuid_ignore_invalid(((master_portal_bin_event.raw_event_data ->> 'bin_beacon_uuid'::text))::character varying)
         Batches: 1  Memory Usage: 193kB
         ->  Seq Scan on master_portal_bin_event  (cost=0.00..238449.30 rows=695739 width=24) (actual time=0.076..1853.386 rows=692422 loops=1)
               Filter: ((event_type)::text = 'BIN_LOCATED'::text)
               Rows Removed by Filter: 218045
   ->  Index Scan using master_portal_bin_event_cast_to_uuid_ignore_invalid_occurre_idx on master_portal_bin_event t1  (cost=0.42..7.20 rows=1 width=364) (actual time=0.006..0.017 rows=8 loops=1069)
         Index Cond: ((cast_to_uuid_ignore_invalid(((raw_event_data ->> 'bin_beacon_uuid'::text))::character varying) = (cast_to_uuid_ignore_invalid(((master_portal_bin_event.raw_event_data ->> 'bin_beacon_uuid'::text))::character varying))) AND (occurred_at = (max(master_portal_bin_event.occurred_at))))
 Planning Time: 0.307 ms
 Execution Time: 2104.726 ms
(11 rows)
```

This can be made a lot simpler. The query is designed to get the latest event for a specific type & device, which is what `DISTINCT ON` is useful for:


```sql
=> explain analyze

SELECT
    DISTINCT ON (cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'))
    occurred_at,
    cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
    cast_to_uuid_ignore_invalid(raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
FROM master_portal_bin_event
WHERE event_type='BIN_LOCATED'
ORDER BY cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'), occurred_at DESC
;
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Unique  (cost=498597.34..502059.76 rows=996 width=40) (actual time=3616.956..3758.485 rows=1069 loops=1)
   ->  Sort  (cost=498597.34..500328.55 rows=692484 width=40) (actual time=3616.953..3711.670 rows=692422 loops=1)
         Sort Key: (cast_to_uuid_ignore_invalid(((raw_event_data ->> 'bin_beacon_uuid'::text))::character varying)), occurred_at DESC
         Sort Method: external merge  Disk: 33960kB
         ->  Seq Scan on master_portal_bin_event  (cost=0.00..412482.97 rows=692484 width=40) (actual time=0.078..3082.405 rows=692422 loops=1)
               Filter: ((event_type)::text = 'BIN_LOCATED'::text)
               Rows Removed by Filter: 218045
 Planning Time: 0.109 ms
 Execution Time: 3763.902 ms
(9 rows)
```

 - The query is using the uuid type but is only slightly slower with the text value (how to tell from sort node if/which index?)
 - The sort method is external merge with default `work_mem` - increasing this to allow sort to use `quicksort` does not change the time as the bulk of the query is now on the sequential scan

There is no index on event_type, however that will not affect this query as the rows produced are 692,484:

```sql
=> create index temp on master_portal_bin_event (event_type);
=> explain analyze

SELECT
    DISTINCT ON (cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'))
    occurred_at,
    cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
    cast_to_uuid_ignore_invalid(raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
FROM master_portal_bin_event
WHERE event_type='BIN_LOCATED'
ORDER BY cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'), occurred_at DESC
;
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Unique  (cost=496996.38..500446.27 rows=1000 width=40) (actual time=3455.395..3591.518 rows=1069 loops=1)
   ->  Sort  (cost=496996.38..498721.32 rows=689978 width=40) (actual time=3455.392..3543.409 rows=692422 loops=1)
         Sort Key: (cast_to_uuid_ignore_invalid(((raw_event_data ->> 'bin_beacon_uuid'::text))::character varying)), occurred_at DESC
         Sort Method: external merge  Disk: 33960kB
         ->  Seq Scan on master_portal_bin_event  (cost=0.00..411213.15 rows=689978 width=40) (actual time=0.052..2968.348 rows=692422 loops=1)
               Filter: ((event_type)::text = 'BIN_LOCATED'::text)
               Rows Removed by Filter: 218045
 Planning Time: 0.665 ms
 Execution Time: 3597.166 ms
(9 rows)
```

It's interesting to see postgres use the same query plan even when moving the where clause above the distinct query:

```sql
=> explain analyze

select * from
(
SELECT
    DISTINCT ON (event_type, cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'))
    event_type,
    occurred_at,
    cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid') as bin_beacon_uuid,
    cast_to_uuid_ignore_invalid(raw_event_data->>'location_beacon_uuid') as location_beacon_uuid
FROM master_portal_bin_event
ORDER BY event_type, cast_to_uuid_ignore_invalid(raw_event_data->>'bin_beacon_uuid'), occurred_at DESC
) t
WHERE t.event_type='BIN_LOCATED'
;
                                                                                      QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Unique  (cost=501714.38..505164.27 rows=6000 width=53) (actual time=4114.736..4332.773 rows=1069 loops=1)
   ->  Sort  (cost=501714.38..503439.32 rows=689978 width=53) (actual time=4114.734..4265.910 rows=692422 loops=1)
         Sort Key: (cast_to_uuid_ignore_invalid(((master_portal_bin_event.raw_event_data ->> 'bin_beacon_uuid'::text))::character varying)), master_portal_bin_event.occurred_at DESC
         Sort Method: external merge  Disk: 44744kB
         ->  Seq Scan on master_portal_bin_event  (cost=0.00..411213.15 rows=689978 width=53) (actual time=0.077..3266.083 rows=692422 loops=1)
               Filter: ((event_type)::text = 'BIN_LOCATED'::text)
               Rows Removed by Filter: 218045
 Planning Time: 0.166 ms
 Execution Time: 4343.722 ms
(9 rows)
```
