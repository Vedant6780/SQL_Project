use portfolio_project ;

--selecting all the data
select * from NashvilleHousing ;

--standardize data format
select saledate,saledateconverted,CONVERT(date,saledate) as saledate from NashvilleHousing

update NashvilleHousing set SaleDate=CONVERT(date,saledate);

alter table nashvillehousing add saledateconverted date;

update NashvilleHousing set saledateconverted=CONVERT(date,saledate);

--populate property address data
select propertyaddress from NashvilleHousing where PropertyAddress is null; 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b on a.ParcelID=b.ParcelID 
and a.UniqueID != b.UniqueID where a.PropertyAddress is null;

update a 
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a join NashvilleHousing b on a.ParcelID=b.ParcelID 
and a.UniqueID != b.UniqueID where a.PropertyAddress is null;

--Breaking out address in indivudual columns
select propertyaddress from NashvilleHousing 

select SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)as address,
 SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress)) as address
from nashvillehousing;

alter table nashvillehousing add propertysplitaddress nvarchar(255);

update NashvilleHousing set propertysplitaddress 
= SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1);

alter table nashvillehousing add propertysplitcity nvarchar(255);

update NashvilleHousing set propertysplitcity 
= SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress));

--Breaking owners address into individual columns
select owneraddress from NashvilleHousing

select PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from NashvilleHousing

alter table nashvillehousing add owneraddresssplit nvarchar(255);

update NashvilleHousing set owneraddresssplit
= PARSENAME(REPLACE(owneraddress,',','.'),3);

alter table nashvillehousing add ownercity nvarchar(255);

update NashvilleHousing set ownercity 
= PARSENAME(REPLACE(owneraddress,',','.'),2);

alter table nashvillehousing add ownerstate nvarchar(255);

update NashvilleHousing set ownerstate
= PARSENAME(REPLACE(owneraddress,',','.'),1);

--change Y AND N to YES and NO in sold as vacant field
select * from NashvilleHousing
select soldasvacant,COUNT(soldasvacant) from NashvilleHousing
group by SoldAsVacant
order by 2