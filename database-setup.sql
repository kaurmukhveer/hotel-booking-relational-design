--2a

set search_path = "D2"

create table Hotel_chain(
	Hotel_Chain_ID numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
	Number_Of_Hotels numeric(4,0) check (Number_Of_Hotels >= 8),
	Name varchar(20) not null,
	Street varchar(20),
	Unit numeric(4),
	City varchar(20) not null,
	Province varchar(20) not null,
	Zipcode varchar(6) not null check (Zipcode ~ '^[0-9]{6}$' or Zipcode ~ '^[0-9a-zA-Z]{6}$'),
	primary key (hotel_chain_id)
);

--set search_path = "D2";

--drop table Hotel_chain;

--select * from Hotel_chain;

--alter table hotel_chain
--add constraint primary_key primary key (hotel_chain_id);

create table hotel(
	hotel_id numeric(12,0) not null check (hotel_id >= 0),
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
	number_of_rooms numeric(4,0) check (number_of_rooms >= 5),
	street varchar(20),
	unit numeric(4),
	city varchar(20) not null,
	province varchar(20) not null,
	zipcode varchar(6) not null check (zipcode ~ '^[0-9]{6}$' or zipcode ~ '^[0-9a-zA-Z]{6}$'),
	catagory varchar(1) not null check (catagory ~ '^[1-5]{1}$'),
	primary key(hotel_chain_id, hotel_id),
	foreign key(hotel_chain_id) references hotel_chain
);

--some adjustments about constraints

alter table hotel
add constraint unit_zipcode_unique unique (unit, zipcode);--different hotels in the same building

alter table hotel
rename column catagory to category;

alter table hotel
alter column category 
type numeric(1,0) using category::numeric(1,0);

alter table hotel 
add constraint category_range_check check (category between 1 and 5);

--drop table hotel;

create table phone_number(
	phone_id SERIAL,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
	hotel_id numeric(12,0) check (hotel_id >= 0),
	--format +countryNumber(0-2) phoneNumber(7-11)
	phone_number VARCHAR(14) NOT NULL CHECK (
        phone_number ~ '^\+[1-9]\d{0,2}[ ]?\d{7,11}$'
    ),
	primary key(phone_id),
	foreign key(hotel_chain_id) references hotel_chain,
	--
	foreign key(hotel_chain_id, hotel_id) references hotel
);

alter table phone_number
add constraint phone_number_unique unique (phone_number);

--drop table phone_number;

create table email_address(
	email_id serial,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
	hotel_id numeric(12,0) check (hotel_id >= 0),
	email_address varchar(20) not null check(
		email_address like '%@%.%'
		AND position('@' in email_address) <= position('.' in email_address) - 3
        AND position('.' in email_address) < length(email_address)
	),
	primary key(email_id),
	foreign key (hotel_chain_id) references hotel_chain,
	foreign key(hotel_chain_id, hotel_id) references hotel
);

alter table email_address 
add constraint email_unique unique (email_address);

--drop table email_address;

--alter table email_address
--add constraint primary_key_ea primary key(email_id);

--alter table email_address
--add constraint foreign_key_ea1 foreign key(hotel_chain_id) references hotel_chain;

--alter table email_address
--add constraint foreign_key_ea2 foreign key(hotel_id) references hotel;

create table employee(
	employee_id varchar(20) not null,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
	hotel_id numeric(12,0) not null check (hotel_id >= 0),
	id_type varchar(3) not null check (id_type in ('SSN','SIN')),
	family_name varchar(10) not null,
	given_name varchar(10) not null,
	street varchar(20),
	unit numeric(4),
	city varchar(20) not null,
	zipcode varchar(6) not null check (Zipcode ~ '^[0-9]{6}$' or Zipcode ~ '^[0-9a-zA-Z]{6}$'),
	role varchar(20) not null,
	primary key(employee_id),
	foreign key(hotel_chain_id, hotel_id) references hotel,
	constraint check_id_format check(
		(id_type = 'SSN' and employee_id ~ '^\d{3}-\d{2}-\d{4}$')
		or
		(id_type = 'SIN' and employee_id ~ '^\d{3}-\d{3}-\d{3}$')
		or
		(id_type not in ('SSN','SIN'))
	)
);



--drop table employee;

create table room (
    room_id NUMERIC(4, 0) not null check(room_id > 0),
    hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id NUMERIC(12, 0) NOT NULL,
	room_view varchar(20) check (room_view in ('sea view', 'mountain view')
								or room_view is null),
    room_price NUMERIC(6,2) CHECK (room_price >= 100 AND room_price <= 10000) NOT NULL,
    capacity NUMERIC CHECK (capacity >= 50 AND capacity <= 1000) NOT NULL,
    can_be_extended BOOLEAN NOT NULL,
    problems_or_damages VARCHAR(100),
	status boolean not null,
	primary key (hotel_chain_id, hotel_id, room_id),
    FOREIGN KEY (hotel_chain_id, hotel_id) REFERENCES hotel
);

select constraint_name
from information_schema.constraint_column_usage
where table_name = 'room' and column_name = 'room_view';

--drop constraint
alter table room drop constraint room_room_view_check;

--create constraint
alter table room
add constraint view_check check (room_view in ('sea view', 'mountain view', 'sea_and_mountain view'));

alter table room
alter column room_view
type varchar(100) using room_view::varchar(100);

create table amenities (
    amenity_id SERIAL PRIMARY KEY,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id NUMERIC(12, 0) NOT NULL,
    room_id NUMERIC(4, 0) NOT NULL,
    amenity_name VARCHAR(50) NOT NULL,
    amenity_description VARCHAR(255),
    FOREIGN KEY (hotel_chain_id, hotel_id, room_id) REFERENCES room
);


alter table room drop column problems_or_damages;

create table room_damage (
	room_damage_id SERIAL PRIMARY KEY,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id NUMERIC(12, 0) NOT NULL,
    room_id NUMERIC(4, 0) NOT NULL,
    room_damage_part VARCHAR(50) NOT NULL,
    room_damage_description VARCHAR(255),
    FOREIGN KEY (hotel_chain_id, hotel_id, room_id) REFERENCES room
);

create table customer (
    customer_id varchar(20) NOT NULL,
    family_name VARCHAR(10) NOT NULL,
    given_name VARCHAR(10) NOT NULL,
    street VARCHAR(20),
    unit NUMERIC(4),
    city VARCHAR(20),
    zipcode VARCHAR(6) CHECK (zipcode ~ '^[0-9]{6}$' OR zipcode ~ '^[0-9a-zA-Z]{6}$'),
    registration_year NUMERIC(4, 0) NOT NULL CHECK (registration_year >= 2000 AND registration_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2),
    registration_month NUMERIC(2, 0) NOT NULL CHECK (registration_month >= 1 AND registration_month <= 12),
    registration_day NUMERIC(2, 0) NOT NULL CHECK (registration_day >= 1 AND registration_day <= 31),
    ID_type VARCHAR NOT NULL CHECK (ID_type IN ('SSN', 'SIN', 'driving license')),
    PRIMARY KEY (customer_id),
    CONSTRAINT chk_customers_id_format CHECK (
        (ID_type = 'SSN' AND customer_id::TEXT ~ '^\d{3}-\d{2}-\d{4}$') OR
        (ID_type = 'SIN' AND customer_id::TEXT ~ '^\d{3}-\d{3}-\d{3}$') OR
        (ID_type = 'driving license' AND customer_id::TEXT ~ '^A\d{4}-\d{5}-\d{5}$') OR
        (ID_type NOT IN ('SSN', 'SIN', 'driving license'))
    )
);

select conname
from pg_constraint
where conrelid = 'customer'::regclass and contype = 'c';

alter table customer drop constraint customer_registration_year_check;

alter table customer add constraint customer_registration_year_check check (registration_year >= 2000 AND registration_year <= EXTRACT(YEAR FROM CURRENT_DATE));


--drop table customer;

create table booking (
    booking_id SERIAL,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id numeric(12,0) not null check (hotel_id >= 0),
    room_id NUMERIC(4, 0) NOT NULL check (room_id > 0),
    customer_id varchar(20) NOT NULL,
	cancelled boolean default false,
    start_year NUMERIC(4, 0) NOT NULL CHECK (start_year >= 2000 AND start_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2),
    start_month NUMERIC(2, 0) NOT NULL CHECK (start_month >= 1 AND start_month <= 12),
    start_day NUMERIC(2, 0) NOT NULL CHECK (
        (start_day >= 1 AND start_day <= 31) AND
        ((start_month = 2 AND start_day <= 28) OR
        (start_month IN (4, 6, 9, 11) AND start_day <= 30) OR
        (start_month IN (1, 3, 5, 7, 8, 10, 12) AND start_day <= 31))
    ),
    start_hour NUMERIC(2, 0) NOT NULL CHECK (start_hour >= 0 AND start_hour <= 23),
    end_year NUMERIC(4, 0) NOT NULL CHECK (end_year >= 2000 AND end_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2),
    end_month NUMERIC(2, 0) NOT NULL CHECK (end_month >= 1 AND end_month <= 12),
    end_day NUMERIC(2, 0) NOT NULL CHECK (
        (end_day >= 1 AND end_day <= 31) AND
        ((end_month = 2 AND end_day <= 28) OR
        (end_month IN (4, 6, 9, 11) AND end_day <= 30) OR
        (end_month IN (1, 3, 5, 7, 8, 10, 12) AND end_day <= 31))
    ),
    end_hour NUMERIC(2, 0) NOT NULL CHECK (end_hour >= 0 AND end_hour <= 23),
	primary key (booking_id, hotel_chain_id, hotel_id, room_id, customer_id),
    FOREIGN KEY (hotel_chain_id, hotel_id, room_id) REFERENCES room,
    FOREIGN KEY (customer_id) REFERENCES customer
);

set search_path = "D2";
--drop table booking;

create table renting_with_booking(
	renting_id numeric(9,0) not null check (renting_id >= 0),
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id numeric(12,0) not null check (hotel_id >= 0),
    room_id numeric(4, 0) NOT NULL check (room_id > 0),
    customer_id varchar(20) NOT NULL,
    employee_id varchar(20) NOT NULL,
	booking_id serial not null,
	check_in_year numeric(4) check (
		check_in_year <= extract(year from current_date)
	),
	check_in_month numeric(2) check (
		(check_in_month between 1 and 12)
		and
		(check_in_month < extract(month from current_date))
	),
	check_in_day numeric(2) check (
		((check_in_month in (1, 3, 5, 7, 8, 10, 12) and check_in_day between 1 and 31)
		or
		(check_in_month in (4, 6, 9, 11) and check_in_day between 1 and 30)
		or 
		(check_in_month = 2 and check_in_day between 1 and 28))
		and 
		(check_in_day <= extract(day from current_date))
	),
	check_in_hour numeric(2) check (
		(check_in_hour between 1 and 24)
		and 
		(check_in_hour < extract(hour from current_date))
	),
	check_out_year numeric(4) check (
		check_in_year <= extract(year from current_date)
	),
	check_out_month numeric(2) check (
		(check_in_month between 1 and 12)
		and
		(check_in_month < extract(month from current_date))
	),
	check_out_day numeric(2) check (
		((check_in_month in (1, 3, 5, 7, 8, 10, 12) and check_in_day between 1 and 31)
		or
		(check_in_month in (4, 6, 9, 11) and check_in_day between 1 and 30)
		or 
		(check_in_month = 2 and check_in_day between 1 and 28))
		and 
		(check_in_day <= extract(day from current_date))
	),
	check_out_hour numeric(2) check (
		(check_in_hour between 1 and 24)
		and 
		(check_in_hour < extract(hour from current_date))
	),
	primary key (renting_id),
	foreign key (booking_id, hotel_chain_id, hotel_id, room_id, customer_id) 
		references booking(booking_id, hotel_chain_id, hotel_id, room_id, customer_id),
	foreign key (employee_id) references employee
);

ALTER TABLE renting_with_booking DROP COLUMN renting_id;
ALTER TABLE renting_with_booking ADD COLUMN renting_id SERIAL;

--drop some redundant constraints
SELECT conname AS constraint_name
FROM pg_constraint
INNER JOIN pg_class ON pg_constraint.conrelid = pg_class.oid
WHERE pg_class.relname = 'renting_with_booking';

ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check1;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_hour_check;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_hour_check1;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_month_check;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_month_check1;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_year_check;
ALTER TABLE renting_with_booking DROP CONSTRAINT renting_with_booking_check_in_year_check1;



create table renting_without_booking(
	renting_id numeric(9,0) not null check (renting_id >= 0),
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id numeric(12,0) not null check (hotel_id >= 0),
    room_id numeric(4, 0) NOT NULL check (room_id > 0),
    customer_id varchar(20) NOT NULL,
    employee_id varchar(20) NOT NULL,
	check_in_year numeric(4) check (
		check_in_year <= extract(year from current_date)
	),
	check_in_month numeric(2) check (
		(check_in_month between 1 and 12)
		and
		(check_in_month < extract(month from current_date))
	),
	check_in_day numeric(2) check (
		((check_in_month in (1, 3, 5, 7, 8, 10, 12) and check_in_day between 1 and 31)
		or
		(check_in_month in (4, 6, 9, 11) and check_in_day between 1 and 30)
		or 
		(check_in_month = 2 and check_in_day between 1 and 28))
		and 
		(check_in_day <= extract(day from current_date))
	),
	check_in_hour numeric(2) check (
		(check_in_hour between 1 and 24)
		and 
		(check_in_hour < extract(hour from current_date))
	),
	check_out_year numeric(4) check (
		check_in_year <= extract(year from current_date)
	),
	check_out_month numeric(2) check (
		(check_in_month between 1 and 12)
		and
		(check_in_month < extract(month from current_date))
	),
	check_out_day numeric(2) check (
		((check_in_month in (1, 3, 5, 7, 8, 10, 12) and check_in_day between 1 and 31)
		or
		(check_in_month in (4, 6, 9, 11) and check_in_day between 1 and 30)
		or 
		(check_in_month = 2 and check_in_day between 1 and 28))
		and 
		(check_in_day <= extract(day from current_date))
	),
	check_out_hour numeric(2) check (
		(check_in_hour between 1 and 24)
		and 
		(check_in_hour < extract(hour from current_date))
	),
	primary key (renting_id),
	foreign key (hotel_chain_id, hotel_id, room_id) references room,
	foreign key (customer_id) references customer,
	foreign key (employee_id) references employee
);
ALTER TABLE renting_without_booking DROP COLUMN renting_id;
ALTER TABLE renting_without_booking ADD COLUMN renting_id SERIAL;

--drop some redundant constraints
SELECT conname AS constraint_name
FROM pg_constraint
INNER JOIN pg_class ON pg_constraint.conrelid = pg_class.oid
WHERE pg_class.relname = 'renting_without_booking';

ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check1;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_hour_check;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_hour_check1;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_month_check;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_month_check1;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_year_check;
ALTER TABLE renting_without_booking DROP CONSTRAINT renting_without_booking_check_in_year_check1;
ALTER TABLE renting_without_booking DROP CONSTRAINT check_in_year;

ALTER TABLE renting_without_booking
ADD CONSTRAINT check_in_month CHECK (check_in_month >= 1 AND check_in_month <= 12);
ALTER TABLE renting_without_booking
ADD CONSTRAINT check_in_day CHECK ((check_in_day >= 1 AND check_in_day <= 31) AND
        ((check_in_month = 2 AND check_in_day <= 28) OR
        (check_in_month IN (4, 6, 9, 11) AND check_in_day <= 30) OR
        (check_in_month IN (1, 3, 5, 7, 8, 10, 12) AND check_in_day <= 31)));
ALTER TABLE renting_without_booking
ADD CONSTRAINT check_in_hour CHECK (check_in_hour >= 0 AND check_in_hour <= 23);
ALTER TABLE renting_without_booking
ADD CONSTRAINT check_out_month CHECK (check_out_month >= 1 AND check_out_month <= 12);
ALTER TABLE renting_without_booking
ADD CONSTRAINT check_out_day CHECK ((check_out_day >= 1 AND check_out_day <= 31) AND
        ((check_out_month = 2 AND check_out_day <= 28) OR
        (check_out_month IN (4, 6, 9, 11) AND check_out_day <= 30) OR
        (check_out_month IN (1, 3, 5, 7, 8, 10, 12) AND check_out_day <= 31)));
ALTER TABLE renting_without_booking
ADD CONSTRAINT check_out_hour CHECK (check_out_hour >= 0 AND check_out_hour <= 23);



alter table 

drop table if exists booking_renting_archive;
create table booking_renting_archive(
	booking_renting_id serial not null,
	hotel_chain_id numeric(1,0) not null check (Hotel_Chain_ID >= 1 and Hotel_Chain_ID <= 5),
    hotel_id numeric(12,0) not null check (hotel_id >= 0),
    room_id numeric(4, 0) NOT NULL check (room_id > 0),
	customer_id varchar(20) not null,
	employee_id varchar(20),
	archive_type varchar(20) not null check (archive_type in ('booking', 'booking_renting', 'renting')),
	booking_id integer,
	check_in_year numeric(4),
	check_in_month numeric(2),
	check_in_day numeric(2),
	check_in_hour numeric(2),
	check_out_year numeric(4),
	check_out_month numeric(2),
	check_out_day numeric(2),
	check_out_hour numeric(2),
	primary key (booking_renting_id)
);





--2b

set search_path = "D2";

-- populate data into hotel_chain

--test check constraints
insert into hotel_chain (hotel_chain_id, number_of_hotels, name, street, unit, city, province, zipcode)
values (1, 5, 'HC_1', '1 Albert Avenue', 101, 'Ottawa', 'Ontario', 'K1K6N9');
--ERROR:  Failing row contains (1, 5, HC_1, 1 Albert Avenue, 101, Ottawa, Ontario, K1K6N9).new row for relation "hotel_chain" violates check constraint "hotel_chain_number_of_hotels_check" 
--ERROR:  new row for relation "hotel_chain" violates check constraint "hotel_chain_number_of_hotels_check"
--SQL state: 23514
--Detail: Failing row contains (1, 5, HC_1, 1 Albert Avenue, 101, Ottawa, Ontario, K1K6N9).

select * from hotel_chain;

insert into hotel_chain (hotel_chain_id, number_of_hotels, name, street, unit, city, province, zipcode)
values (1, 8, 'HC_1', '1 Albert Street', 101, 'Calgary', 'Albert', 'K1K6N9'),
	(2, 8, 'HC_2', '2 Mann Street', 202, 'Vancouver', 'British Columbia', 'K7N7Y9'),
	(3, 8, 'HC_3', '3 Dalhousie Street', 303, 'Halifax', ' Nova Scotia', 'K1N8N9'),
	(4, 8, 'HC_4', '4 York Street', 404, 'Toronto', 'Ontario', 'K2P5A3'), 
	(5, 8, 'HC_5', '5 Rideau Street', 505, 'Ottawa', 'Ontario', 'K1G6A9');
	
update hotel_chain
set province = 'Nova Scotia'
where hotel_chain_id = 3;

--populate data into hotel
select * from hotel;
--test integrity constraint
insert into hotel (hotel_id, hotel_chain_id, number_of_rooms, street, unit, city, province, zipcode,category)
values (1, 7, 4, '1 A Street', '100', 'Ottawa', 'Ontario', 'K1N1N1', 1);
--ERROR:  Failing row contains (1, 7, 4, 1 A Street, 100, Ottawa, Ontario, K1N1N1, 1).new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check" 
--ERROR:  new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check"
--SQL state: 23514
--Detail: Failing row contains (1, 7, 4, 1 A Street, 100, Ottawa, Ontario, K1N1N1, 1).

insert into hotel (hotel_id, hotel_chain_id, number_of_rooms, street, unit, city, province, zipcode,category)
values 
	(1, 1, 5, '1 St', 101, 'Ottawa', 'Ontario', 'A8JG3F', '1'),
 	(2, 1, 5, '2 St', 102, 'Toronto', 'Ontario', 'B2VI8P', '2'),
 	(3, 1, 5, '3 St', 103, 'Montreal', 'Quebec', 'B3CI6H', '3'),
 	(4, 1, 5, '4 St', 104, 'Ottawa', 'Ontario', 'B5LY5Q', '1'),
 	(5, 1, 5, '5 St', 105, 'Vancouver', 'British Columbia', 'C4AN2H', '2'),
 	(6, 1, 5, '6 St', 106, 'London', 'Ontario', 'C6TL4O', '4'),
 	(7, 1, 5, '7 St', 107, 'Halifax', 'Nova Scotia', 'D3AH5O', '5'),
 	(8, 1, 5, '8 St', 108, 'Kingston', 'Ontario', 'D5OM1S', '3'),
 	(1, 2, 5, '9 St', 101, 'Ottawa', 'Ontario', 'E0RZ6U', '1'),
 	(2, 2, 5, '10 St', 102, 'Toronto', 'Ontario', 'E1HU2C', '2'),
 	(3, 2, 5, '11 St', 103, 'Montreal', 'Quebec', 'E5WA1L', '3'),
 	(4, 2, 5, '12 St', 104, 'Ottawa', 'Ontario', 'E9ZD6L', '1'),
 	(5, 2, 5, '13 St', 105, 'Vancouver', 'British Columbia', 'F2KU9D', '2'),
 	(6, 2, 5, '14 St', 106, 'London', 'Ontario', 'F5AZ9S', '4'),
 	(7, 2, 5, '15 St', 107, 'Halifax', 'Nova Scotia', 'H0EL8K', '5'),
 	(8, 2, 5, '16 St', 108, 'Kingston', 'Ontario', 'I3RF7X', '3'),
 	(1, 3, 5, '17 St', 101, 'Ottawa', 'Ontario', 'I5GX8L', '1'),
 	(2, 3, 5, '18 St', 102, 'Toronto', 'Ontario', 'I5RR6L', '2'),
 	(3, 3, 5, '19 St', 103, 'Montreal', 'Quebec', 'I7TY5O', '3'),
 	(4, 3, 5, '20 St', 104, 'Ottawa', 'Ontario', 'J3VI4T', '1'), 
 	(5, 3, 5, '21 St', 105, 'Vancouver', 'British Columbia', 'K3AD8O', '2'),
 	(6, 3, 5, '22 St', 106, 'London', 'Ontario', 'K5TQ2Z', '4'),
 	(7, 3, 5, '23 St', 107, 'Halifax', 'Nova Scotia', 'L7QC4S', '5'),
 	(8, 3, 5, '24 St', 108, 'Kingston', 'Ontario', 'M1BB9M', '3'),
 	(1, 4, 5, '25 St', 101, 'Ottawa', 'Ontario', 'M5MC2L', '1'),
 	(2, 4, 5, '26 St', 102, 'Toronto', 'Ontario', 'N3LU9L', '2'),
 	(3, 4, 5, '27 St', 103, 'Montreal', 'Quebec', 'O2DN9P', '3'),
 	(4, 4, 5, '28 St', 104, 'Ottawa', 'Ontario', 'O7QM5F', '1'),
 	(5, 4, 5, '29 St', 105, 'Vancouver', 'British Columbia', 'Q1VB9G', '2'),
 	(6, 4, 5, '30 St', 106, 'London', 'Ontario', 'R0SE3V', '4'),
 	(7, 4, 5, '31 St', 107, 'Halifax', 'Nova Scotia', 'R2QO7O', '5'),
 	(8, 4, 5, '32 St', 108, 'Kingston', 'Ontario', 'T0XK6O', '3'),
 	(1, 5, 5, '33 St', 101, 'Ottawa', 'Ontario', 'T5EB8A', '1'),
 	(2, 5, 5, '34 St', 102, 'Toronto', 'Ontario', 'T7AN4X', '2'),
 	(3, 5, 5, '35 St', 103, 'Montreal', 'Quebec', 'U6PV3K', '3'),
 	(4, 5, 5, '36 St', 104, 'Ottawa', 'Ontario', 'V6QK8A', '1'),
 	(5, 5, 5, '37 St', 105, 'Vancouver', 'British Columbia', 'W5OF8T', '2'),
 	(6, 5, 5, '38 St', 106, 'London', 'Ontario', 'W6QC7R', '4'),
 	(7, 5, 5, '39 St', 107, 'Halifax', 'Nova Scotia', 'X5VB5S', '5'),
 	(8, 5, 5, '40 St', 108, 'Kingston', 'Ontario', 'Y3IO4H', '3'); 

--populate data into phone_number 
select * from phone_number;

--hotel_chain phone number
--hotel_id is null -> hotel_chain phone number
insert into phone_number(hotel_chain_id, hotel_id, phone_number)
values (1, null, '+1 123456789'),
	(1, null, '+2 19847230589'),
	(2, null, '+1 3432229999'),
	(2, null, '+2 17766668888'),
	(3, null, '+1 234567890'),
	(4, null, '+1 134567890'),
	(5, null, '+1 987654321');
	
--hotel phone number
insert into phone_number(hotel_chain_id, hotel_id, phone_number)
values (1, 1, '+1 111111111'),
	(1, 2, '+1 222222222'),
	(1, 3, '+1 333333333'),
	(1, 4, '+1 444444444'),
	(1, 5, '+1 555555555'),
	(1, 6, '+1 666666666'),
	(1, 7, '+1 777777777'),
	(1, 8, '+1 888888888'),--1st hc
	(2, 1, '+1 191111111'),
	(2, 2, '+1 292222222'),
	(2, 3, '+1 393333333'),
	(2, 4, '+1 494444444'),
	(2, 5, '+1 595555555'),
	(2, 6, '+1 696666666'),
	(2, 7, '+1 797777777'),
	(2, 8, '+1 898888888'),--2nd hc
	(3, 1, '+1 119111111'),
	(3, 2, '+1 229222222'),
	(3, 3, '+1 339333333'),
	(3, 4, '+1 449444444'),
	(3, 5, '+1 559555555'),
	(3, 6, '+1 669666666'),
	(3, 7, '+1 779777777'),
	(3, 8, '+1 889888888'),--3rd hc
	(4, 1, '+1 111911111'),
	(4, 2, '+1 222922222'),
	(4, 3, '+1 333933333'),
	(4, 4, '+1 444944444'),
	(4, 5, '+1 555955555'),
	(4, 6, '+1 666966666'),
	(4, 7, '+1 777977777'),
	(4, 8, '+1 888988888'),--4th hc
	(5, 1, '+1 111191111'),
	(5, 2, '+1 222292222'),
	(5, 3, '+1 333393333'),
	(5, 4, '+1 444494444'),
	(5, 5, '+1 555595555'),
	(5, 6, '+1 666696666'),
	(5, 7, '+1 777797777'),
	(5, 8, '+1 888898888');--5th hc
	
select * from phone_number;

--populate data into email_address
select * from email_address;

--hotel chain emails
insert into email_address(hotel_chain_id, hotel_id, email_address)
values (1, null, '1@hc.com'),
	(1, null, '12@hc.com'),
	(2, null, '2@hc.com'),
	(2, null, '22@hc.com'),
	(3, null, '3@hc.com'),
	(4, null, '4@hc.com'),
	(5, null, '5@hc.com');
	
--hotel email
insert into email_address(hotel_chain_id, hotel_id, email_address)
values 
	(1, 1, 'h11@ho.com'),
	(1, 2, 'h12@ho.com'),
	(1, 3, 'h13@ho.com'),
	(1, 4, 'h14@ho.com'),
	(1, 5, 'h15@ho.com'),
	(1, 6, 'h16@ho.com'),
	(1, 7, 'h17@ho.com'),
	(1, 8, 'h18@ho.com'),--1st hc
	(2, 1, 'h21@ho.com'),
	(2, 2, 'h22@ho.com'),
	(2, 3, 'h23@ho.com'),
	(2, 4, 'h24@ho.com'),
	(2, 5, 'h25@ho.com'),
	(2, 6, 'h26@ho.com'),
	(2, 7, 'h27@ho.com'),
	(2, 8, 'h28@ho.com'),--2nd hc
	(3, 1, 'h31@ho.com'),
	(3, 2, 'h32@ho.com'),
	(3, 3, 'h33@ho.com'),
	(3, 4, 'h34@ho.com'),
	(3, 5, 'h35@ho.com'),
	(3, 6, 'h36@ho.com'),
	(3, 7, 'h37@ho.com'),
	(3, 8, 'h38@ho.com'),--3rd hc
	(4, 1, 'h41@ho.com'),
	(4, 2, 'h42@ho.com'),
	(4, 3, 'h43@ho.com'),
	(4, 4, 'h44@ho.com'),
	(4, 5, 'h45@ho.com'),
	(4, 6, 'h46@ho.com'),
	(4, 7, 'h47@ho.com'),
	(4, 8, 'h48@ho.com'),--4th hc
	(5, 1, 'h51@ho.com'),
	(5, 2, 'h52@ho.com'),
	(5, 3, 'h53@ho.com'),
	(5, 4, 'h54@ho.com'),
	(5, 5, 'h55@ho.com'),
	(5, 6, 'h56@ho.com'),
	(5, 7, 'h57@ho.com'),
	(5, 8, 'h58@ho.com');--5th hc

select *from email_address;

--find the constraint name for room_view

select * from room;

--populate data into room
--the first hotel chain
insert into room (room_id, hotel_chain_id, hotel_id, room_view, room_price, capacity, can_be_extended, status)
values 
	(101, 1, 1, null, 200, 80, true, true),
	(102, 1, 1, null, 400, 120, true, true),
	(201, 1, 1, 'sea view', 400, 90, true, true),
	(202, 1, 1, 'mountain view', 600, 110, true, true),
	(301, 1, 1, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 1st hotel
	(101, 1, 2, null, 200, 80, true, true),
	(102, 1, 2, null, 400, 120, true, true),
	(201, 1, 2, 'sea view', 400, 90, true, true),
	(202, 1, 2, 'mountain view', 600, 110, true, true),
	(301, 1, 2, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 2nd hotel
	(101, 1, 3, null, 200, 80, true, true),
	(102, 1, 3, null, 400, 120, true, true),
	(201, 1, 3, 'sea view', 400, 90, true, true),
	(202, 1, 3, 'mountain view', 600, 110, true, true),
	(301, 1, 3, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 3rd hotel
	(101, 1, 4, null, 200, 80, true, true),
	(102, 1, 4, null, 400, 120, true, true),
	(201, 1, 4, 'sea view', 400, 90, true, true),
	(202, 1, 4, 'mountain view', 600, 110, true, true),
	(301, 1, 4, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 4th hotel
	(101, 1, 5, null, 200, 80, true, true),
	(102, 1, 5, null, 400, 120, true, true),
	(201, 1, 5, 'sea view', 400, 90, true, true),
	(202, 1, 5, 'mountain view', 600, 110, true, true),
	(301, 1, 5, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 5th hotel
	(101, 1, 6, null, 200, 80, true, true),
	(102, 1, 6, null, 400, 120, true, true),
	(201, 1, 6, 'sea view', 400, 90, true, true),
	(202, 1, 6, 'mountain view', 600, 110, true, true),
	(301, 1, 6, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 6th hotel
	(101, 1, 7, null, 200, 80, true, true),
	(102, 1, 7, null, 400, 120, true, true),
	(201, 1, 7, 'sea view', 400, 90, true, true),
	(202, 1, 7, 'mountain view', 600, 110, true, true),
	(301, 1, 7, 'sea_and_mountain view', 1000, 200, true, true),--1st hc 7th hotel
	(101, 1, 8, null, 200, 80, true, true),
	(102, 1, 8, null, 400, 120, true, true),
	(201, 1, 8, 'sea view', 400, 90, true, true),
	(202, 1, 8, 'mountain view', 600, 110, true, true),
	(301, 1, 8, 'sea_and_mountain view', 1000, 200, true, true);--1st hc 8th hotel
	
	
select * from room;

--the second hotel chain
insert into room (room_id, hotel_chain_id, hotel_id, room_view, room_price, capacity, can_be_extended, status)
values 
	(101, 2, 1, null, 200, 80, true, true),
	(102, 2, 1, null, 400, 120, true, true),
	(201, 2, 1, 'sea view', 400, 90, true, true),
	(202, 2, 1, 'mountain view', 600, 110, true, true),
	(301, 2, 1, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 1st hotel
	(101, 2, 2, null, 200, 80, true, true),
	(102, 2, 2, null, 400, 120, true, true),
	(201, 2, 2, 'sea view', 400, 90, true, true),
	(202, 2, 2, 'mountain view', 600, 110, true, true),
	(301, 2, 2, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 2nd hotel
	(101, 2, 3, null, 200, 80, true, true),
	(102, 2, 3, null, 400, 120, true, true),
	(201, 2, 3, 'sea view', 400, 90, true, true),
	(202, 2, 3, 'mountain view', 600, 110, true, true),
	(301, 2, 3, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 3rd hotel
	(101, 2, 4, null, 200, 80, true, true),
	(102, 2, 4, null, 400, 120, true, true),
	(201, 2, 4, 'sea view', 400, 90, true, true),
	(202, 2, 4, 'mountain view', 600, 110, true, true),
	(301, 2, 4, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 4th hotel
	(101, 2, 5, null, 200, 80, true, true),
	(102, 2, 5, null, 400, 120, true, true),
	(201, 2, 5, 'sea view', 400, 90, true, true),
	(202, 2, 5, 'mountain view', 600, 110, true, true),
	(301, 2, 5, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 5th hotel
	(101, 2, 6, null, 200, 80, true, true),
	(102, 2, 6, null, 400, 120, true, true),
	(201, 2, 6, 'sea view', 400, 90, true, true),
	(202, 2, 6, 'mountain view', 600, 110, true, true),
	(301, 2, 6, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 6th hotel
	(101, 2, 7, null, 200, 80, true, true),
	(102, 2, 7, null, 400, 120, true, true),
	(201, 2, 7, 'sea view', 400, 90, true, true),
	(202, 2, 7, 'mountain view', 600, 110, true, true),
	(301, 2, 7, 'sea_and_mountain view', 1000, 200, true, true),--2nd hc 7th hotel
	(101, 2, 8, null, 200, 80, true, true),
	(102, 2, 8, null, 400, 120, true, true),
	(201, 2, 8, 'sea view', 400, 90, true, true),
	(202, 2, 8, 'mountain view', 600, 110, true, true),
	(301, 2, 8, 'sea_and_mountain view', 1000, 200, true, true);--2nd hc 8th hotel
	
select * from room;

--the third hotel chain
insert into room (room_id, hotel_chain_id, hotel_id, room_view, room_price, capacity, can_be_extended, status)
values 
	(101, 3, 1, null, 200, 80, true, true),
	(102, 3, 1, null, 400, 120, true, true),
	(201, 3, 1, 'sea view', 400, 90, true, true),
	(202, 3, 1, 'mountain view', 600, 110, true, true),
	(301, 3, 1, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 1st hotel
	(101, 3, 2, null, 200, 80, true, true),
	(102, 3, 2, null, 400, 120, true, true),
	(201, 3, 2, 'sea view', 400, 90, true, true),
	(202, 3, 2, 'mountain view', 600, 110, true, true),
	(301, 3, 2, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 2nd hotel
	(101, 3, 3, null, 200, 80, true, true),
	(102, 3, 3, null, 400, 120, true, true),
	(201, 3, 3, 'sea view', 400, 90, true, true),
	(202, 3, 3, 'mountain view', 600, 110, true, true),
	(301, 3, 3, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 3rd hotel
	(101, 3, 4, null, 200, 80, true, true),
	(102, 3, 4, null, 400, 120, true, true),
	(201, 3, 4, 'sea view', 400, 90, true, true),
	(202, 3, 4, 'mountain view', 600, 110, true, true),
	(301, 3, 4, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 4th hotel
	(101, 3, 5, null, 200, 80, true, true),
	(102, 3, 5, null, 400, 120, true, true),
	(201, 3, 5, 'sea view', 400, 90, true, true),
	(202, 3, 5, 'mountain view', 600, 110, true, true),
	(301, 3, 5, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 5th hotel
	(101, 3, 6, null, 200, 80, true, true),
	(102, 3, 6, null, 400, 120, true, true),
	(201, 3, 6, 'sea view', 400, 90, true, true),
	(202, 3, 6, 'mountain view', 600, 110, true, true),
	(301, 3, 6, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 6th hotel
	(101, 3, 7, null, 200, 80, true, true),
	(102, 3, 7, null, 400, 120, true, true),
	(201, 3, 7, 'sea view', 400, 90, true, true),
	(202, 3, 7, 'mountain view', 600, 110, true, true),
	(301, 3, 7, 'sea_and_mountain view', 1000, 200, true, true),--3rd hc 7th hotel
	(101, 3, 8, null, 200, 80, true, true),
	(102, 3, 8, null, 400, 120, true, true),
	(201, 3, 8, 'sea view', 400, 90, true, true),
	(202, 3, 8, 'mountain view', 600, 110, true, true),
	(301, 3, 8, 'sea_and_mountain view', 1000, 200, true, true);--3rd hc 8th hotel
	
select * from room;

--the fourth hotel chain
insert into room (room_id, hotel_chain_id, hotel_id, room_view, room_price, capacity, can_be_extended, status)
values 
	(101, 4, 1, null, 200, 80, true, true),
	(102, 4, 1, null, 400, 120, true, true),
	(201, 4, 1, 'sea view', 400, 90, true, true),
	(202, 4, 1, 'mountain view', 600, 110, true, true),
	(301, 4, 1, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 1st hotel
	(101, 4, 2, null, 200, 80, true, true),
	(102, 4, 2, null, 400, 120, true, true),
	(201, 4, 2, 'sea view', 400, 90, true, true),
	(202, 4, 2, 'mountain view', 600, 110, true, true),
	(301, 4, 2, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 2nd hotel
	(101, 4, 3, null, 200, 80, true, true),
	(102, 4, 3, null, 400, 120, true, true),
	(201, 4, 3, 'sea view', 400, 90, true, true),
	(202, 4, 3, 'mountain view', 600, 110, true, true),
	(301, 4, 3, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 3rd hotel
	(101, 4, 4, null, 200, 80, true, true),
	(102, 4, 4, null, 400, 120, true, true),
	(201, 4, 4, 'sea view', 400, 90, true, true),
	(202, 4, 4, 'mountain view', 600, 110, true, true),
	(301, 4, 4, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 4th hotel
	(101, 4, 5, null, 200, 80, true, true),
	(102, 4, 5, null, 400, 120, true, true),
	(201, 4, 5, 'sea view', 400, 90, true, true),
	(202, 4, 5, 'mountain view', 600, 110, true, true),
	(301, 4, 5, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 5th hotel
	(101, 4, 6, null, 200, 80, true, true),
	(102, 4, 6, null, 400, 120, true, true),
	(201, 4, 6, 'sea view', 400, 90, true, true),
	(202, 4, 6, 'mountain view', 600, 110, true, true),
	(301, 4, 6, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 6th hotel
	(101, 4, 7, null, 200, 80, true, true),
	(102, 4, 7, null, 400, 120, true, true),
	(201, 4, 7, 'sea view', 400, 90, true, true),
	(202, 4, 7, 'mountain view', 600, 110, true, true),
	(301, 4, 7, 'sea_and_mountain view', 1000, 200, true, true),--4th hc 7th hotel
	(101, 4, 8, null, 200, 80, true, true),
	(102, 4, 8, null, 400, 120, true, true),
	(201, 4, 8, 'sea view', 400, 90, true, true),
	(202, 4, 8, 'mountain view', 600, 110, true, true),
	(301, 4, 8, 'sea_and_mountain view', 1000, 200, true, true);--4th hc 8th hotel
	
select * from room;

--the fifth hotel chain
insert into room (room_id, hotel_chain_id, hotel_id, room_view, room_price, capacity, can_be_extended, status)
values 
	(101, 5, 1, null, 200, 80, true, true),
	(102, 5, 1, null, 400, 120, true, true),
	(201, 5, 1, 'sea view', 400, 90, true, true),
	(202, 5, 1, 'mountain view', 600, 110, true, true),
	(301, 5, 1, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 1st hotel
	(101, 5, 2, null, 200, 80, true, true),
	(102, 5, 2, null, 400, 120, true, true),
	(201, 5, 2, 'sea view', 400, 90, true, true),
	(202, 5, 2, 'mountain view', 600, 110, true, true),
	(301, 5, 2, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 2nd hotel
	(101, 5, 3, null, 200, 80, true, true),
	(102, 5, 3, null, 400, 120, true, true),
	(201, 5, 3, 'sea view', 400, 90, true, true),
	(202, 5, 3, 'mountain view', 600, 110, true, true),
	(301, 5, 3, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 3rd hotel
	(101, 5, 4, null, 200, 80, true, true),
	(102, 5, 4, null, 400, 120, true, true),
	(201, 5, 4, 'sea view', 400, 90, true, true),
	(202, 5, 4, 'mountain view', 600, 110, true, true),
	(301, 5, 4, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 4th hotel
	(101, 5, 5, null, 200, 80, true, true),
	(102, 5, 5, null, 400, 120, true, true),
	(201, 5, 5, 'sea view', 400, 90, true, true),
	(202, 5, 5, 'mountain view', 600, 110, true, true),
	(301, 5, 5, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 5th hotel
	(101, 5, 6, null, 200, 80, true, true),
	(102, 5, 6, null, 400, 120, true, true),
	(201, 5, 6, 'sea view', 400, 90, true, true),
	(202, 5, 6, 'mountain view', 600, 110, true, true),
	(301, 5, 6, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 6th hotel
	(101, 5, 7, null, 200, 80, true, true),
	(102, 5, 7, null, 400, 120, true, true),
	(201, 5, 7, 'sea view', 400, 90, true, true),
	(202, 5, 7, 'mountain view', 600, 110, true, true),
	(301, 5, 7, 'sea_and_mountain view', 1000, 200, true, true),--5th hc 7th hotel
	(101, 5, 8, null, 200, 80, true, true),
	(102, 5, 8, null, 400, 120, true, true),
	(201, 5, 8, 'sea view', 400, 90, true, true),
	(202, 5, 8, 'mountain view', 600, 110, true, true),
	(301, 5, 8, 'sea_and_mountain view', 1000, 200, true, true);--5th hc 8th hotel
	
select * from room;

--insert amenities
select * from amenities;

set search_path = 'D2';

do $$
declare 
	current_hotel_chain_id numeric;
	current_hotel_id numeric;
	room_ids numeric[] := array[101, 102, 201, 202, 301];
	current_room_id numeric;
	amenity_1 varchar := 'WIFI';
	amenity_1_description varchar := 'Complimentary WiFi access within the room for browsing, streaming, and staying connected.';
	amenity_2 varchar := 'Air Conditioning';
	amenity_2_description varchar := 'Adjustable air conditioning system to ensure your comfort regardless of the outside temperature.';
	amenity_3 varchar := 'Flat Screen TV';
	amenity_3_description varchar := 'A high-definition television offering a variety of local and international channels.';
	amenity_4 varchar := 'Hair Dryer';
	amenity_4_description varchar:= 'A powerful hair dryer to ensure your hair is perfectly styled after every shower.';		
	amenity_5 varchar := 'Work Desk';
	amenity_5_description varchar := 'A dedicated space equipped with a comfortable chair and desk lamp, ideal for guests who need to work.';
	amenity_6 varchar := 'Mini Bar';
	amenity_6_description varchar := 'A small refrigerator stocked with snacks, beverages, and mini bottles of alcohol for convenience.';
	
begin
	for current_hotel_chain_id in 1..5 loop
		for current_hotel_id in 1..8 loop
			foreach current_room_id in array room_ids loop
				if current_room_id = 101 or current_room_id = 201 then
				
					insert into amenities (hotel_chain_id, hotel_id, room_id, amenity_name, amenity_description)
					values (current_hotel_chain_id, current_hotel_id, current_room_id, amenity_1, amenity_1_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_2, amenity_2_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_3, amenity_3_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_4, amenity_4_description);
					
				elsif current_room_id = 102 or current_room_id = 202 then
					
					insert into amenities (hotel_chain_id, hotel_id, room_id, amenity_name, amenity_description)
					values (current_hotel_chain_id, current_hotel_id, current_room_id, amenity_1, amenity_1_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_2, amenity_2_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_3, amenity_3_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_4, amenity_4_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_5, amenity_5_description);
						
				elsif current_room_id = 301 then
			 		
					insert into amenities (hotel_chain_id, hotel_id, room_id, amenity_name, amenity_description)
					values (current_hotel_chain_id, current_hotel_id, current_room_id, amenity_1, amenity_1_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_2, amenity_2_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_3, amenity_3_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_4, amenity_4_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_5, amenity_5_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, amenity_6, amenity_6_description);
						
				end if;
			end loop;
		end loop;
	end loop;
end $$;

select pg_get_serial_sequence('amenities', 'amenity_id') as sequence_name;

alter sequence "D2".amenities_amenity_id_seq restart with 1;

delete from amenities;

select * from amenities;

--insert room damages

select * from room_damage;

do $$
declare 
	current_hotel_chain_id numeric;
	current_hotel_id numeric;
	room_ids numeric[] := array[101, 102, 201, 202, 301];
	current_room_id numeric;
	damage_1 varchar := 'WIFI';
	damage_1_description varchar := 'The wifi connection is unstable and sometimes disconnects suddenly.';
	damage_2 varchar := 'Air Conditioning';
	damage_2_description varchar := 'The air conditioner temperature cannot be set to the lowest temperature it should be.';
	
begin
	for current_hotel_chain_id in 1..5 loop
		for current_hotel_id in 1..8 loop
			foreach current_room_id in array room_ids loop
				if current_room_id = 102 then
				
					insert into room_damage (hotel_chain_id, hotel_id, room_id, room_damage_part, room_damage_description)
					values (current_hotel_chain_id, current_hotel_id, current_room_id, damage_1, damage_1_description);
						
				elsif current_room_id = 202 then
					
					insert into room_damage (hotel_chain_id, hotel_id, room_id, room_damage_part, room_damage_description)
					values (current_hotel_chain_id, current_hotel_id, current_room_id, damage_1, damage_1_description),
						(current_hotel_chain_id, current_hotel_id, current_room_id, damage_2, damage_2_description);
						
				end if;
			end loop;
		end loop;
	end loop;
end $$;

select * from room_damage;





--2c

--query 1 
--all the hotels in Ottawa
select * from hotel where city = 'Ottawa';

--query 2 
--all the rooms with the price less than 500 in Ottawa
select r.room_id, r.hotel_chain_id, r.hotel_id, r.room_price, h.city 
from room r join hotel h 
on r.hotel_chain_id = h.hotel_chain_id and r.hotel_id = h.hotel_id
where r.room_price < 500 and  h.city = 'Ottawa';

--query 3 with aggregation 
--count all the rooms with damages in each city
select h.city, count(r.room_id) as number_room_damage
from hotel h
join room r on r.hotel_chain_id = h.hotel_chain_id and r.hotel_id = h.hotel_id
join room_damage d on r.room_id = d.room_id and r.hotel_chain_id = d.hotel_chain_id and r.hotel_id = d.hotel_id
group by h.city;

--query 4 with aggregation
--calculate the average room_price 
select avg(room_price) as average_room_price from room;

--query 5 nested query
--all the rooms with the price > average price
select r.room_id, r.hotel_chain_id, r.hotel_id, r.room_price
from room r
where r.room_price > (select avg(room_price) from room);

--query 6 nested query
--all the city where has at least two hotels belonged to one hotel chain
select distinct city from (select hotel_chain_id, city from hotel h group by hotel_chain_id, city having count(city) > 1);






--2d
set search_path = "D2";
select * from hotel;
--  Qurey for test
-- Insert a new hotel without having a valid hotel_chain_id
-- Expected: Error due to foreign key constraint violation
INSERT INTO hotel (hotel_id, hotel_chain_id, number_of_rooms, street, unit, city, province, zipcode, category)
VALUES (9, 9, 10, 'street', 1, 'Ottawa', 'Ontario', 'K1N6N6', 1);
--get error
--ERROR:  Failing row contains (9, 9, 10, street, 1, Ottawa, Ontario, K1N6N6, 1).new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check" 
--ERROR:  new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check"
--SQL state: 23514
--Detail: Failing row contains (9, 9, 10, street, 1, Ottawa, Ontario, K1N6N6, 1).


-- Insert a new hotel
-- Expected: Successfully insert
INSERT INTO hotel (hotel_id, hotel_chain_id, number_of_rooms, street, unit, city, province, zipcode, category)
VALUES (9, 5, 10, 'R street', 1, 'Ottawa', 'Ontario', 'K1N6N6', 1);

-- Update the hotel_chain_id for a hotel
-- Expected: violates the foreign key constraint since this hotel_chain_id doesn't exsit
UPDATE hotel SET hotel_chain_id = 9 WHERE hotel_chain_id = 5 and hotel_id = 9;
--get error 
--ERROR:  Failing row contains (9, 9, 10, R street, 1, Ottawa, Ontario, K1N6N6, 1).new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check" 
--ERROR:  new row for relation "hotel" violates check constraint "hotel_hotel_chain_id_check"
--SQL state: 23514
--Detail: Failing row contains (9, 9, 10, R street, 1, Ottawa, Ontario, K1N6N6, 1).

-- Update the hotel_chain_id for a hotel
-- Expected: Successfully update
UPDATE hotel SET hotel_chain_id = 1 WHERE hotel_chain_id = 5 and hotel_id = 9;

-- Delete a hotel_chain that has associated hotels
-- Expected: violate foreign key constraint since we still have reference between hotel and hotel_chain
DELETE FROM hotel_chain WHERE hotel_chain_id = 1;
--get error
--ERROR:  Key (hotel_chain_id)=(1) is still referenced from table "hotel".update or delete on table "hotel_chain" violates foreign key constraint "hotel_hotel_chain_id_fkey" on table "hotel" 
--ERROR:  update or delete on table "hotel_chain" violates foreign key constraint "hotel_hotel_chain_id_fkey" on table "hotel"
--SQL state: 23503
--Detail: Key (hotel_chain_id)=(1) is still referenced from table "hotel".

-- Delete a hotel without any relation to the other tables
-- Expected: Successfully delete
DELETE FROM hotel WHERE hotel_id = 9 and hotel_chain_id = 1;


--t1
-- a trigger function that ensures each hotel has one manager
CREATE OR REPLACE FUNCTION check_unique_manager() RETURNS TRIGGER AS $$
BEGIN
  
  IF EXISTS (
    SELECT 1 FROM employee
    WHERE hotel_chain_id = NEW.hotel_chain_id AND hotel_id = NEW.hotel_id AND role = 'manager'
  ) THEN
    RAISE EXCEPTION 'This hotel already has one manager';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- a trigger about the insertion of employees
CREATE TRIGGER trigger_check_unique_manager
BEFORE INSERT OR UPDATE ON employee
FOR EACH ROW
WHEN (NEW.role = 'manager')
EXECUTE FUNCTION check_unique_manager();

set search_path = "D2";

-- test trigger 1

--successfully
select * from employee;
delete from employee;
insert into employee (employee_id, hotel_chain_id, hotel_id, id_type, family_name, given_name, street, unit, city, zipcode, role)
	values ('111-11-1111', 1, 1, 'SSN', 'e', '1', 'st', 102, 'Ottawa', 'K7Y9V0', 'manager');
--unsuccessfully
insert into employee (employee_id, hotel_chain_id, hotel_id, id_type, family_name, given_name, street, unit, city, zipcode, role)
	values ('111-11-1112', 1, 1, 'SSN', 'e', '2', 'st', 103, 'Ottawa', 'K7Y9V8', 'manager');



--t2
-- a trigger function that ensures the atart time after the current time for booking
--drop function if exists check_booking_start_time();
CREATE OR REPLACE FUNCTION check_booking_start_time() RETURNS TRIGGER AS $$
BEGIN
    IF TO_TIMESTAMP(NEW.start_year || '-' || NEW.start_month || '-' || NEW.start_day || ' ' || NEW.start_hour || ':00', 'YYYY-MM-DD HH24:MI') <= CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'The start time must be after the current time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- use trigger_check_booking_start_before_insert_or_update on booking
--drop trigger if exists trigger_check_booking_start_before_insert_or_update on booking
CREATE TRIGGER trigger_check_booking_start_before_insert_or_update
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW EXECUTE FUNCTION check_booking_start_time();



--t3
-- a trigger that ensures the end time is after the start time for booking
CREATE OR REPLACE FUNCTION check_booking_end_after_start() RETURNS TRIGGER AS $$
BEGIN
    IF TO_TIMESTAMP(NEW.end_year || '-' || NEW.end_month || '-' || NEW.end_day || ' ' || NEW.end_hour || ':00', 'YYYY-MM-DD HH24:MI') <= TO_TIMESTAMP(NEW.start_year || '-' || NEW.start_month || '-' || NEW.start_day || ' ' || NEW.start_hour || ':00', 'YYYY-MM-DD HH24:MI') THEN
        RAISE EXCEPTION 'The end time must be after the start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- use trigger_check_booking_end_after_start_before_insert_or_update on booking
CREATE TRIGGER trigger_check_booking_end_after_start_before_insert_or_update
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW EXECUTE FUNCTION check_booking_end_after_start();

--test trigger 2 3
select * from customer;
delete from customer;
insert into customer (customer_id, family_name, given_name, street, unit, city, zipcode, registration_year, registration_month, registration_day, id_type)
	values ('333-33-3333', 'c', '1', 's', 101, 'Ottawa', 'K1N9N9', 2019, 8, 20, 'SSN');
	
select * from booking;
select * from booking_renting_archive;
delete from booking;
delete from booking_renting_archive;
--unsuccessfully
insert into booking (hotel_chain_id, hotel_id, room_id, customer_id, cancelled, start_year, start_month, start_day, start_hour, end_year, end_month, end_day, end_hour)
	values (1, 1, 101, '333-33-3333', false, 2023, 8, 25, 12, 2023, 8, 27, 14);
--unsuccessfully
insert into booking (hotel_chain_id, hotel_id, room_id, customer_id, cancelled, start_year, start_month, start_day, start_hour, end_year, end_month, end_day, end_hour)
	values (1, 1, 101, '333-33-3333', false, 2024, 8, 25, 12, 2023, 8, 27, 14);
--successfully
insert into booking (hotel_chain_id, hotel_id, room_id, customer_id, cancelled, start_year, start_month, start_day, start_hour, end_year, end_month, end_day, end_hour)
	values (2, 1, 101, '333-33-3333', false, 2024, 9, 25, 12, 2024, 9, 27, 14);


--t4
-- a trigger function that ensures the atart time after the current time for booking_without_renting
--drop function if exists check_renting_without_booking_start_time();
CREATE OR REPLACE FUNCTION check_renting_without_booking_start_time() RETURNS TRIGGER AS $$
BEGIN
    IF TO_TIMESTAMP(NEW.check_in_year || '-' || NEW.check_in_month || '-' || NEW.check_in_day || ' ' || NEW.check_in_hour || ':00', 'YYYY-MM-DD HH24:MI') <= CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'The start time must be after the current time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- use trigger_check_booking_start_before_insert_or_update on bookirenting_without_booking
--drop trigger if exists renting_without_booking_start_before_insert_or_update on renting_without_booking;
CREATE TRIGGER renting_without_booking_start_before_insert_or_update
BEFORE INSERT OR UPDATE ON renting_without_booking
FOR EACH ROW EXECUTE FUNCTION check_renting_without_booking_start_time();


--t5
-- a trigger that ensures the end time is after the start time for renting_without_booking
CREATE OR REPLACE FUNCTION check_renting_without_booking_end_after_start() RETURNS TRIGGER AS $$
BEGIN
    IF TO_TIMESTAMP(NEW.check_out_year || '-' || NEW.check_out_month || '-' || NEW.check_out_day || ' ' || NEW.check_out_hour || ':00', 'YYYY-MM-DD HH24:MI') <= TO_TIMESTAMP(NEW.check_in_year || '-' || NEW.check_in_month || '-' || NEW.check_in_day || ' ' || NEW.check_in_hour || ':00', 'YYYY-MM-DD HH24:MI') THEN
        RAISE EXCEPTION 'The end time must be after the start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- use trigger_check_booking_end_after_start_before_insert_or_update on booking
CREATE TRIGGER renting_without_booking_end_after_start_before_insert_or_update
BEFORE INSERT OR UPDATE ON renting_without_booking
FOR EACH ROW EXECUTE FUNCTION check_renting_without_booking_end_after_start();

-- test trigger 45
select * from renting_without_booking;
delete from renting_without_booking;
--unsuccessfully
insert into renting_without_booking (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, check_in_year, check_in_month, check_in_day, check_in_hour, check_out_year, check_out_month, check_out_day, check_out_hour)
	values (1, 1, 101, '333-33-3333', '111-11-1111', 2024, 8, 25, 12, 2023, 8, 27, 14);	
--successfully
insert into renting_without_booking (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, check_in_year, check_in_month, check_in_day, check_in_hour, check_out_year, check_out_month, check_out_day, check_out_hour)
	values (1, 1, 101, '333-33-3333', '111-11-1111', 2024, 8, 25, 12, 2024, 8, 27, 14);	


--t6
-- a trigger function that ensures the date of renting_with_booking is the same as that of booking
CREATE OR REPLACE FUNCTION check_renting_with_booking_times() RETURNS TRIGGER AS $$
DECLARE
    v_start_year NUMERIC(4, 0);
    v_start_month NUMERIC(2, 0);
    v_start_day NUMERIC(2, 0);
    v_start_hour NUMERIC(2, 0);
    v_end_year NUMERIC(4, 0);
    v_end_month NUMERIC(2, 0);
    v_end_day NUMERIC(2, 0);
    v_end_hour NUMERIC(2, 0);
BEGIN
    SELECT start_year, start_month, start_day, start_hour, end_year, end_month, end_day, end_hour
    INTO v_start_year, v_start_month, v_start_day, v_start_hour, v_end_year, v_end_month, v_end_day, v_end_hour
    FROM booking
    WHERE booking_id = NEW.booking_id;

    IF NOT (NEW.check_in_year = v_start_year AND NEW.check_in_month = v_start_month AND NEW.check_in_day = v_start_day AND NEW.check_in_hour = v_start_hour AND
            NEW.check_out_year = v_end_year AND NEW.check_out_month = v_end_month AND NEW.check_out_day = v_end_day AND NEW.check_out_hour = v_end_hour) THEN
        RAISE EXCEPTION 'The start_time and end_time of Renting with booking must be the same as that of booking';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- use trigger check_renting_with_booking_times on renting_with_booking
CREATE TRIGGER trigger_check_renting_with_booking_times
BEFORE INSERT OR UPDATE ON renting_with_booking
FOR EACH ROW EXECUTE FUNCTION check_renting_with_booking_times();

--test trigger 6
select *from booking;
select * from renting_with_booking;
delete from renting_with_booking;
--unsuccessfully
insert into renting_with_booking (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, booking_id, check_in_year, check_in_month, check_in_day, check_in_hour, check_out_year, check_out_month, check_out_day, check_out_hour)
	values (2, 1, 101, '333-33-3333', '111-11-1111', 44, 2024, 8, 25, 12, 2023, 8, 27, 14);	
--successfully
select * from renting_with_booking;
insert into renting_with_booking (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, booking_id, check_in_year, check_in_month, check_in_day, check_in_hour, check_out_year, check_out_month, check_out_day, check_out_hour)
	values (2, 1, 101, '333-33-3333', '111-11-1111', 44, 2024, 9, 25, 12, 2024, 9, 27, 14);	
	

--t7
-- a trigger function that transfers info to archive
--drop function if exists transfer_to_archive();
create or replace function transfer_to_archive() returns trigger as $$
begin
	if TG_TABLE_NAME = 'booking' then
		insert into booking_renting_archive (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, archive_type, booking_id, 
											 check_in_year, check_in_month, check_in_day, check_in_hour, 
											 check_out_year, check_out_month, check_out_day, check_out_hour)
		values(new.hotel_chain_id, new.hotel_id, new.room_id, new.customer_id, null, 'booking', new.booking_id,
			   new.start_year, new.start_month, new.start_day, new.start_hour, 
			   new.end_year, new.end_month, new.end_day, new.end_hour);
	elsif TG_TABLE_NAME = 'renting_with_booking' then 
		insert into booking_renting_archive (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, archive_type, booking_id,
											 check_in_year, check_in_month, check_in_day, check_in_hour, 
											 check_out_year, check_out_month, check_out_day, check_out_hour)
		values(new.hotel_chain_id, new.hotel_id, new.room_id, new.customer_id, new.employee_id, 'booking_renting', null,
			   new.check_in_year, new.check_in_month, new.check_in_day, new.check_in_hour, 
			   new.check_out_year, new.check_out_month, new.check_out_day, new.check_out_hour);
	elsif TG_TABLE_NAME = 'renting_without_booking' then
		insert into booking_renting_archive (hotel_chain_id, hotel_id, room_id, customer_id, employee_id, archive_type, booking_id,
											 check_in_year, check_in_month, check_in_day, check_in_hour, 
											 check_out_year, check_out_month, check_out_day, check_out_hour)
		values(new.hotel_chain_id, new.hotel_id, new.room_id, new.customer_id, new.employee_id, 'renting', null,
			   new.check_in_year, new.check_in_month, new.check_in_day, new.check_in_hour, 
			   new.check_out_year, new.check_out_month, new.check_out_day, new.check_out_hour);
	end if;
	return new;
end;
$$ language plpgsql;

-- a trigger about the insertion of archive
--drop trigger if exists transfer_booking_to_archive on booking
create trigger transfer_booking_to_archive after insert on booking
	for each row execute function transfer_to_archive();

--drop trigger if exists transfer_r enting_with_booking_to_archive on renting_with_booking
create trigger transfer_renting_with_booking_to_archive after insert on renting_with_booking
	for each row execute function transfer_to_archive();
	
--drop trigger if exists transfer_renting_without_booking_to_archive on renting_without_booking	
create trigger transfer_renting_without_booking_to_archive after insert on renting_without_booking
	for each row execute function transfer_to_archive();
	
--test 
select * from booking_renting_archive;


--t8
-- a trigger function that detects the cancellation of booking
drop function if exists delete_booking_after_cancellation();
CREATE OR REPLACE FUNCTION delete_booking_after_cancellation() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cancelled THEN
        DELETE FROM booking_renting_archive WHERE booking_id = NEW.booking_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- a trigger about the cancellation of booking in booking and archive
CREATE TRIGGER trigger_delete_booking_after_cancellation
AFTER UPDATE OF cancelled ON booking
FOR EACH ROW EXECUTE FUNCTION delete_booking_after_cancellation();

--test trigger 8	
select * from booking;
select * from booking_renting_archive;
update booking set cancelled = true where booking_id = 46; 




--  2e
set search_path = "D2";

--  Index customer name to check if booked
--  Check if a specific booking is canceled based on the booking ID
--  This index can speed up queries that need to quickly determine the cancellation status of a booking, making it convenient for employees to view customer booking status
CREATE INDEX index_booking_id_cancelled ON booking (booking_id, cancelled);

--  Index the start date and end date of booking
--  Find bookings within a specific date range or check the availability of rooms based on booking dates
--  This index can accelerate queries related to date-based searches, making it convenient for employees to find all bookings within a specific time period or to check if a room is available for a specific date and time
CREATE INDEX index_booking_dates ON booking (start_year, start_month, start_day, start_hour, end_year, end_month, end_day, end_hour);

--  Index room status to check availability
--  Quickly find all available or occupied rooms
--  This index can speed up queries that need to filter rooms based on their availability status, making it convenient for employees to see if a room is available, especially if a customer has special room requirements
CREATE INDEX index_room_status ON room (status);

--  Index hotel's zip code
--  Find all hotels in a specific zip code area
--  This index can improve the performance of queries that need to retrieve hotels based on their location, making it convenient for customers to find where the hotel is located
CREATE INDEX index_hotel_zipcode ON hotel (zipcode);

--  Index room's price
--  Find rooms within a specific price range
--  This index can expedite queries related to pricing, making it convenient for customers to find rooms that meet their budget expectations
CREATE INDEX index_room_price ON room (room_price);


--  Query for test 
SELECT * FROM hotel WHERE zipcode = 'U6PV3K';
EXPLAIN SELECT * FROM hotel WHERE zipcode = 'U6PV3K';

SELECT * FROM room WHERE status = 'true';
EXPLAIN SELECT * FROM room WHERE status = 'true';

SELECT * FROM booking WHERE cancelled = false;
EXPLAIN SELECT * FROM booking WHERE cancelled = false;

SELECT * FROM room WHERE room_price BETWEEN 100 AND 200;
EXPLAIN SELECT * FROM room WHERE room_price BETWEEN 100 AND 200;







--  2f

--  the number of available rooms per city
--  the view has subtracted the number of rooms booked or rented
CREATE VIEW available_rooms_per_city AS
SELECT h.city,
       SUM(h.number_of_rooms) - COALESCE(SUM(b.booked_rooms), 0) - COALESCE(SUM(rwob.rented_rooms), 0) AS available_rooms
FROM hotel h
LEFT JOIN (
    SELECT hotel_id, hotel_chain_id, COUNT(*) AS booked_rooms
    FROM booking
    WHERE cancelled = false
    GROUP BY hotel_id, hotel_chain_id
) b ON h.hotel_id = b.hotel_id AND h.hotel_chain_id = b.hotel_chain_id
LEFT JOIN (
    SELECT hotel_id, hotel_chain_id, COUNT(*) AS rented_rooms
    FROM renting_with_booking
    GROUP BY hotel_id, hotel_chain_id
) rwb ON h.hotel_id = rwb.hotel_id AND h.hotel_chain_id = rwb.hotel_chain_id
LEFT JOIN (
    SELECT hotel_id, hotel_chain_id, COUNT(*) AS rented_rooms
    FROM renting_without_booking
    GROUP BY hotel_id, hotel_chain_id
) rwob ON h.hotel_id = rwob.hotel_id AND h.hotel_chain_id = rwob.hotel_chain_id
GROUP BY h.city;

--   the aggregated capacity of all the rooms of a specific hotel
CREATE VIEW total_capacity_per_hotel AS
SELECT hotel_id, SUM(capacity) AS total_capacity
FROM room
GROUP BY hotel_id;

--  Query for test 
SELECT * FROM available_rooms_per_city;
SELECT * FROM total_capacity_per_hotel;

SELECT * FROM available_rooms_per_city WHERE city = 'Ottawa';
SELECT * FROM total_capacity_per_hotel WHERE hotel_id = 8;






				
					
					










