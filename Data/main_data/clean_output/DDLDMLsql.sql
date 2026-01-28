USE adt_project;

 -- DDL Create statements -- Harsh Gupta
CREATE TABLE lots (
    lot_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);
 -- DDL Create statements -- Harsh Gupta
CREATE TABLE permits (
    permit_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);
 -- DDL Create statements -- Harsh Gupta
CREATE TABLE lot_permit (
    lot_id INT NOT NULL,
    permit_id INT NOT NULL,
    PRIMARY KEY (lot_id, permit_id),
    FOREIGN KEY (lot_id) REFERENCES lots(lot_id),
    FOREIGN KEY (permit_id) REFERENCES permits(permit_id)
);

-- Create Statement -- Harsh Gupta
CREATE TABLE buildings (
    building_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);

-- Create Statement -- Harsh Gupta
CREATE TABLE lot_building_distance (
    lot_id        INT NOT NULL,
    building_id   INT NOT NULL,
    distance  INT NOT NULL,    

    PRIMARY KEY (lot_id, building_id),   
    CONSTRAINT fk_lbd_lot
        FOREIGN KEY (lot_id)
        REFERENCES lots(lot_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_lbd_building
        FOREIGN KEY (building_id)
        REFERENCES buildings(building_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Create Statement -- Harsh Gupta
CREATE TABLE staging_lot_building_distance (
  lot_title_raw VARCHAR(255),
  building_name_raw VARCHAR(255),
  distance_sec_raw VARCHAR(50)
);



 -- Constraints statements -- Pranay Bandaru
ALTER TABLE lot_permit
  ADD PRIMARY KEY (lot_id, permit_id);
-- Constraints statements -- Pranay Bandaru
ALTER TABLE lot_permit
  ADD CONSTRAINT fk_lp_lot
    FOREIGN KEY (lot_id) REFERENCES lots(lot_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
-- Constraints statements -- Pranay Bandaru
ALTER TABLE lot_permit
  ADD CONSTRAINT fk_lp_permit
    FOREIGN KEY (permit_id) REFERENCES permits(permit_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
-- Constraints statements -- Pranay Bandaru
ALTER TABLE lot_inventory
  ADD CONSTRAINT fk_li_lot
    FOREIGN KEY (lot_id) REFERENCES lots(lot_id)
    ON DELETE RESTRICT   -- change to CASCADE if you prefer automatic inventory deletion
    ON UPDATE CASCADE;
    

-- Loading Data -- Pranay Bandaru
LOAD DATA LOCAL INFILE 'C:\Users\pranay\OneDrive\Desktop\Study_Materials\College_Course\Fall25\ADT\Project\Data\main_data\clean_output\building_parking_distance_long.csv'
INTO TABLE staging_lot_building_distance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@lot_raw, @building_raw, @dist_raw)
SET
  lot_title_raw = NULLIF(TRIM(@lot_raw), ''),
  building_name_raw = NULLIF(TRIM(@building_raw), ''),
  distance_sec_raw = NULLIF(TRIM(@dist_raw), '');

-- Create Statement -- Harsh Gupta
DROP TABLE IF EXISTS staging_lot_capacity;
CREATE TABLE staging_lot_capacity (
  title VARCHAR(255),
  parking_space_inventory TEXT,
  emp VARCHAR(50),
  ems VARCHAR(50),
  ch VARCHAR(50),
  st VARCHAR(50),
  disabled VARCHAR(50),
  motorcycle VARCHAR(50),
  meter VARCHAR(50),
  garage VARCHAR(50),
  reserved VARCHAR(50),
  other VARCHAR(50),
  total VARCHAR(50)
);
-- Create Statement -- Harsh Gupta
CREATE TABLE IF NOT EXISTS lot_inventory (
  inventory_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  lot_id INT NULL,
  lot_title VARCHAR(255) NULL,
  snapshot_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  parking_space_inventory TEXT,
  emp INT NULL CHECK (emp >= 0),
  ems INT NULL CHECK (ems >= 0),
  ch INT NULL CHECK (ch >= 0),
  st INT NULL CHECK (st >= 0),
  disabled INT NULL CHECK (disabled >= 0),
  motorcycle INT NULL CHECK (motorcycle >= 0),
  meter INT NULL CHECK (meter >= 0),
  garage INT NULL CHECK (garage >= 0),
  reserved INT NULL CHECK (reserved >= 0),
  other INT NULL CHECK (other >= 0),
  capacity_total INT NULL CHECK (capacity_total >= 0)
);

-- Populating the table Pranay Bandaru
INSERT INTO lot_inventory (
  lot_title, parking_space_inventory,
  emp, ems, ch, st, disabled, motorcycle, meter, garage, reserved, other,
  capacity_total
)
SELECT
  LEFT(TRIM(title),255) AS lot_title,
  parking_space_inventory,
  CASE WHEN emp REGEXP '^[0-9]+$' THEN CAST(emp AS UNSIGNED) ELSE NULL END AS emp,
  CASE WHEN ems REGEXP '^[0-9]+$' THEN CAST(ems AS UNSIGNED) ELSE NULL END AS ems,
  CASE WHEN ch REGEXP '^[0-9]+$' THEN CAST(ch AS UNSIGNED) ELSE NULL END AS ch,
  CASE WHEN st REGEXP '^[0-9]+$' THEN CAST(st AS UNSIGNED) ELSE NULL END AS st,
  CASE WHEN disabled REGEXP '^[0-9]+$' THEN CAST(disabled AS UNSIGNED) ELSE NULL END AS disabled,
  CASE WHEN motorcycle REGEXP '^[0-9]+$' THEN CAST(motorcycle AS UNSIGNED) ELSE NULL END AS motorcycle,
  CASE WHEN meter REGEXP '^[0-9]+$' THEN CAST(meter AS UNSIGNED) ELSE NULL END AS meter,
  CASE WHEN garage REGEXP '^[0-9]+$' THEN CAST(garage AS UNSIGNED) ELSE NULL END AS garage,
  CASE WHEN reserved REGEXP '^[0-9]+$' THEN CAST(reserved AS UNSIGNED) ELSE NULL END AS reserved,
  CASE WHEN other REGEXP '^[0-9]+$' THEN CAST(other AS UNSIGNED) ELSE NULL END AS other,
  CASE WHEN total REGEXP '^[0-9]+$' THEN CAST(total AS UNSIGNED) ELSE NULL END AS capacity_total
FROM staging_lot_capacity
WHERE TRIM(title) <> '';

-- Update Statement -- Harsh Gupta
UPDATE lot_inventory li
JOIN lots l ON LOWER(TRIM(li.lot_title)) = LOWER(TRIM(l.title))
SET li.lot_id = l.lot_id
WHERE li.lot_id IS NULL;

-- Constrains -- Pranay Bandaru
ALTER TABLE lot_inventory
ADD CONSTRAINT fk_lot_inventory_lot
FOREIGN KEY (lot_id)
REFERENCES lots(lot_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Constrains -- Pranay Bandaru
ALTER TABLE lots
  MODIFY COLUMN title VARCHAR(255) NOT NULL;
-- Constrains -- Pranay Bandaru
ALTER TABLE permits
  MODIFY COLUMN name VARCHAR(255) NOT NULL;
-- Constrains -- Pranay Bandaru
CREATE UNIQUE INDEX uq_lots_title ON lots (title(255));
CREATE UNIQUE INDEX uq_permits_name ON permits (name(255));
-- Constrains -- Pranay Bandaru
CREATE INDEX idx_lots_latlon ON lots (latitude, longitude);
CREATE INDEX idx_li_lot_ts ON lot_inventory (lot_id, snapshot_ts);

-- Preparing and Executing Insert statement -- Harsh Gupta
INSERT IGNORE INTO permits (name) VALUES ('Accessible Metered Parking');
INSERT IGNORE INTO permits (name) VALUES ('Accessible Parking');
INSERT IGNORE INTO permits (name) VALUES ('Accessible Pay Parking');
INSERT IGNORE INTO permits (name) VALUES ('Athletic Parking');
INSERT IGNORE INTO permits (name) VALUES ('CH6 Parking');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 1');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 1 & 2');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 2');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 3');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 4');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 5');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 6');
INSERT IGNORE INTO permits (name) VALUES ('Campus Housing Parking - Zone 7');
INSERT IGNORE INTO permits (name) VALUES ('EM Retired Parking');
INSERT IGNORE INTO permits (name) VALUES ('EMP Parking');
INSERT IGNORE INTO permits (name) VALUES ('EMP Parking (24 Hr)');
INSERT IGNORE INTO permits (name) VALUES ('EMS Parking');
INSERT IGNORE INTO permits (name) VALUES ('EMS Parking (24 Hr)');
INSERT IGNORE INTO permits (name) VALUES ('EMS Parking (Upper Level only)');
INSERT IGNORE INTO permits (name) VALUES ('Electric Veh Parking');
INSERT IGNORE INTO permits (name) VALUES ('IU Foundation Parking');
INSERT IGNORE INTO permits (name) VALUES ('Metered Parking');
INSERT IGNORE INTO permits (name) VALUES ('Motor Pool Vehicle Parking');
INSERT IGNORE INTO permits (name) VALUES ('Motorcycle Parking');
INSERT IGNORE INTO permits (name) VALUES ('Patient Parking');
INSERT IGNORE INTO permits (name) VALUES ('Real Estate Office Parking');
INSERT IGNORE INTO permits (name) VALUES ('Reserved Parking');
INSERT IGNORE INTO permits (name) VALUES ('Service Vehicle Parking');
INSERT IGNORE INTO permits (name) VALUES ('Student Parking');
INSERT IGNORE INTO permits (name) VALUES ('Student Parking Section');
INSERT IGNORE INTO permits (name) VALUES ('Student Parking Section E ONLY');
INSERT IGNORE INTO permits (name) VALUES ('This is all of David Baker Ave Street Parking');
INSERT IGNORE INTO permits (name) VALUES ('Visitor Parking');
INSERT IGNORE INTO permits (name) VALUES ('Visitor Pay Lot');
INSERT IGNORE INTO permits (name) VALUES ('Visitor Pay Parking');
INSERT IGNORE INTO permits (name) VALUES ('Visitor Pay Parking (Upper Level Only)');

select * from lots;
select * from permits;
select * from buildings where name = '1000 N INDIANA AVE';
select * from lot_permit where permit_id = null;


-- INSERT statements for lots -- Pranay Bandaru
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 442', 39.16354, -86.522394);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 255', 39.17300802, -86.51977418);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 238', 39.173833, -86.521811);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Headley School Parking', 39.18590997, -86.51465575);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 424', 39.163537, -86.526325);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 100', 39.18106219, -86.52754248);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 102', 39.18489312, -86.52478087);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 103', 39.18283817, -86.52458169);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 104', 39.18080536, -86.52374889);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 108', 39.1787845, -86.52549279);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 110', 39.17947672, -86.52020975);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 111', 39.17969243, -86.51877087);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 112', 39.18133415, -86.52053335);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 114', 39.18222084, -86.52121027);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 115', 39.18684303, -86.51960788);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 116', 39.19062312, -86.522872);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 117', 39.18433022, -86.51977642);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 120', 39.18155316, -86.51668531);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 121', 39.18633226, -86.51333709);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 122', 39.18445655, -86.51167684);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 123', 39.179551, -86.513989);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 125', 39.18281264, -86.51314328);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 126', 39.17770727, -86.50998314);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 127', 39.17726915, -86.51265233);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 128', 39.17796305, -86.50780363);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 130', 39.1791, -86.5048);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 132', 39.17656241, -86.50823344);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 133', 39.17671824, -86.51050761);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 134', 39.17614982, -86.50980086);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 136', 39.17525816, -86.50907961);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 138', 39.17522138, -86.51039077);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 140', 39.17384091, -86.51056657);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 142', 39.17298115, -86.51177038);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 144', 39.17334082, -86.51481171);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 146', 39.17250911, -86.51494331);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 148', 39.17208318, -86.51291399);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 150', 39.17335891, -86.50936124);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 152', 39.17273673, -86.50895433);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 153', 39.17176491, -86.50891787);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 154', 39.17451165, -86.50482346);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 156', 39.17330602, -86.50438934);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 158', 39.1783, -86.5043);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 160', 39.1751815, -86.50104766);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 162', 39.17505492, -86.49960588);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 164', 39.17381611, -86.50218347);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 166', 39.17264923, -86.50088177);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 168', 39.17262563, -86.49894493);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 169', 39.17302995, -86.49928917);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 170', 39.17310785, -86.49629727);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 172', 39.17403732, -86.49590863);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 174', 39.17513354, -86.49764035);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 178', 39.17736978, -86.49343919);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 200', 39.17213208, -86.52634458);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 201', 39.17191897, -86.52715704);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 202', 39.17281429, -86.52612582);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 204', 39.17388065, -86.52659733);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 207', 39.17457, -86.524887);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 208', 39.17485071, -86.52258694);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 210', 39.17498067, -86.52180075);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 212', 39.17547659, -86.52345115);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 214', 39.17815268, -86.5224005);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 216', 39.17838852, -86.52058182);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 218', 39.17807652, -86.51930389);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 222', 39.17641711, -86.51918574);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 226', 39.1748869, -86.52006581);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 227', 39.17856535, -86.51533959);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 228', 39.17661876, -86.51851054);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 229', 39.1766853, -86.51694212);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 230', 39.17597039, -86.51684924);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 231', 39.17420724, -86.51730451);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 232', 39.1750924, -86.51853941);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 234', 39.1742768, -86.52391381);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 235', 39.17412657, -86.52281311);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 242', 39.17347462, -86.51991016);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 249', 39.17228236, -86.52287233);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 250', 39.17221306, -86.52176994);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 256', 39.17317941, -86.51790652);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 257', 39.17244468, -86.51703882);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 258', 39.17352954, -86.51588525);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 259', 39.17260973, -86.51639455);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 260', 39.17253535, -86.51586958);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 302', 39.17103362, -86.53572535);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 310', 39.17098417, -86.52764697);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 312', 39.17007322, -86.52657723);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 330', 39.16991181, -86.52502853);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 342', 39.16902041, -86.52541715);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 343', 39.16892681, -86.52502068);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 344', 39.16892015, -86.52417696);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 346', 39.16903447, -86.52387171);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 350', 39.16899946, -86.52294419);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 354', 39.16897724, -86.52240813);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 355', 39.16883821, -86.52123011);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 356', 39.16967219, -86.52033232);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 358', 39.1696025, -86.5193646);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 364', 39.16952868, -86.51669083);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 366', 39.16815016, -86.51790642);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 368', 39.16821007, -86.51924433);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 402', 39.16779585, -86.52771842);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 403', 39.16796149, -86.5272003);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 404', 39.16725839, -86.52758932);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 406', 39.16625104, -86.52780242);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 409', 39.16473448, -86.52771405);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 412', 39.16582902, -86.52768499);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 414', 39.1652336, -86.52744702);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 418', 39.16721732, -86.52509611);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 420', 39.16570613, -86.5265649);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 422', 39.16486145, -86.52554965);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 423', 39.16362689, -86.52749312);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 426', 39.16338755, -86.52486532);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 428', 39.16362745, -86.52325105);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 434', 39.16271822, -86.52331482);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 436', 39.16271477, -86.52216614);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 438', 39.16271472, -86.52176681);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 440', 39.1637762, -86.52186363);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 450', 39.16672851, -86.52308223);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 451', 39.16594957, -86.52323113);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 452', 39.16700471, -86.52325207);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 453', 39.16806631, -86.52338602);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 455', 39.16805644, -86.52240004);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 456', 39.16784741, -86.52158609);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 466', 39.16457692, -86.51968713);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 468', 39.16403019, -86.51971815);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 469', 39.16356998, -86.52088668);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 470', 39.16345772, -86.51964826);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 474', 39.16285259, -86.51839535);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 475', 39.16349021, -86.51883338);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 476', 39.16347327, -86.51855632);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 477', 39.16395293, -86.51721247);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 478', 39.16479315, -86.51888877);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 479', 39.16364414, -86.51671656);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 480', 39.16557897, -86.51792939);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 482', 39.16563919, -86.51933109);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 484', 39.16583274, -86.51900872);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 488', 39.16722661, -86.51717889);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 500', 39.17077329, -86.51539921);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 504', 39.17010864, -86.51400932);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 508', 39.16937319, -86.51241778);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 510', 39.17088746, -86.51087889);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 512', 39.17135898, -86.50899096);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 513', 39.17069119, -86.5081628);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 514', 39.17039859, -86.50749764);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 515', 39.16992166, -86.50852915);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 517', 39.16922868, -86.50803648);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 518', 39.16849579, -86.5087267);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 520', 39.16823502, -86.51105307);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 522', 39.1687092, -86.5154284);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 524', 39.16838049, -86.51561134);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 525', 39.16802738, -86.51565563);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 529', 39.16741081, -86.51495738);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 530', 39.16677318, -86.51561038);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 532', 39.16649995, -86.51490483);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 534', 39.16641544, -86.51609502);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 536', 39.16586213, -86.51609562);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 538', 39.16558658, -86.51451245);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 540', 39.16541657, -86.51466847);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 544', 39.16520076, -86.51586799);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 547', 39.16345466, -86.51478977);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 548', 39.16479647, -86.51387869);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 550', 39.16479659, -86.51360402);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 552', 39.16453872, -86.51245601);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 554', 39.16479553, -86.51132253);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 556', 39.16687206, -86.51167885);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 562', 39.16601986, -86.50972642);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 566', 39.16734333, -86.50805204);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 569', 39.171269, -86.50652);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 640', 39.1620453, -86.53072949);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 650', 39.16128757, -86.5038675);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lots 316 / 318 / 320 / 322 / 324 / 326', 39.17099979, -86.52514019);
INSERT IGNORE INTO lots (title, latitude, longitude) VALUES ('Lot 400', 39.167808, -86.528847);


