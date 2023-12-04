--1>Populate property address
with t as(select a.parcelid, coalesce(a.propertyaddress,b.propertyaddress) as propertyaddress
from
Nashville_Housing_data a
join
 Nashville_Housing_data b
on  a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null)


update Nashville_Housing_data a 
set propertyaddress=t.propertyaddress
from
t
where  a.parcelid=t.parcelid
;

select * from Nashville_Housing_data where propertyaddress is null

--2>Breaking out address into individual cols(address,city,state)

select Substring(propertyaddress,1,position(',' in propertyaddress)-1),
Substring(propertyaddress,position(',' in propertyaddress)+1)
from Nashville_Housing_data;


Alter table Nashville_Housing_data
Add propadd1 varchar(225);

update Nashville_Housing_data
set propadd1=Substring(propertyaddress,1,position(',' in propertyaddress)-1);

Alter table Nashville_Housing_data
Add propcity varchar(225);

update Nashville_Housing_data
set  propcity=Substring(propertyaddress,position(',' in propertyaddress)+1);

select owneraddress,split_part(owneraddress,',',1)
from Nashville_Housing_data;;

Alter table Nashville_Housing_data
Add ownadd varchar(225);

update Nashville_Housing_data
set  ownadd=split_part(owneraddress,',',1);

Alter table Nashville_Housing_data
Add owncity varchar(225);

update Nashville_Housing_data
set  owncity=split_part(owneraddress,',',2);

Alter table Nashville_Housing_data
Add ownstate varchar(225);

update Nashville_Housing_data
set  ownstate=split_part(owneraddress,',',3);

select * from Nashville_Housing_data where soldasvacant='N'

------3>Change Y ann N to 'Yes' and 'No' in "Sold as Vacant" field


update Nashville_Housing_data 
set soldasvacant=case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant end;

-----4>Remove dupicates
WITH t_deleted AS
(DELETE FROM Nashville_Housing_data returning *), 

t_inserted AS
(SELECT *, row_number()  over(partition by parcelid,propertyaddress,saleprice,saledate,
		   legalreference order by uniqueid) as rn_num
    FROM t_deleted)
	
INSERT INTO Nashville_Housing_data 
SELECT UniqueID ,
ParcelID ,
LandUse ,
PropertyAddress ,
SaleDate ,
SalePrice ,
LegalReference,
SoldAsVacant,
OwnerName,
OwnerAddress,
Acreage,
TaxDistrict,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
FullBath,
HalfBath,
propadd1,
propcity,
ownadd,
owncity,
ownstate
FROM t_inserted 
WHERE rn_num=1;

select * from
(select 
row_number()  over(partition by parcelid,propertyaddress,saleprice,saledate,
legalreference order by uniqueid) as rn_num,
* from Nashville_Housing_data)a where rn_num=2;

------5>Delete unused columns

Alter table Nashville_Housing_data
drop column owneraddress,
drop column TaxDistrict,
drop column propertyaddress,
drop column saledate

select * from Nashville_Housing_data where propadd1 is not null


COPY Nashville_Housing_data
FROM 'C:\Users\Dell\Documents\2023\Data analysis projects\Project-2\Data cleaning\Nashville Housing Data for Data Cleaning.csv'
CSV HEADER;

CREATE TABLE Nashville_Housing_data(
UniqueID int,
ParcelID varchar(225),
LandUse text,
PropertyAddress varchar(225),
SaleDate Date,
SalePrice varchar(225),
LegalReference varchar(225),
SoldAsVacant Text,
OwnerName varchar(225),
OwnerAddress varchar(225),
Acreage numeric(22,6),
TaxDistrict Text,
LandValue bigint,
BuildingValue bigint,
TotalValue bigint,
YearBuilt int,
Bedrooms int,
FullBath int,
HalfBath int);