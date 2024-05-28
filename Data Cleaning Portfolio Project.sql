--Cleaning Data in SQL
select * from NashvilleHousing

--Standardize Date Format

select SaleDate, CONVERT(date, SaleDate) from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

--Populate PropertyAddress data
select * from NashvilleHousing
order by ParcelId

select a.[UniqueID ], a.ParcelID,a.PropertyAddress,b.[UniqueID ], b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns(Address, City,State)
select PropertyAddress from NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address from NashvilleHousing 
select SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address from NashvilleHousing

--Updating Address
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from NashvilleHousing
select OwnerAddress from NashvilleHousing

select	PARSENAME(replace(OwnerAddress,',','.'),3),
		PARSENAME(replace(OwnerAddress,',','.'),2),
		PARSENAME(replace(OwnerAddress,',','.'),1)
		from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from NashvilleHousing

--Change Y and N to 'yes' and 'No' in "SoldAsVacant" field 
select distinct(SoldAsVacant), COUNT(*) from NashvilleHousing
group by (SoldAsVacant) 
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant 
end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No' 
						else SoldAsVacant 
					end;

select * from NashvilleHousing

--Removing Duplicates

with CTE as(
	select *, 
	ROW_NUMBER() over 
	(partition by ParcelId, 
				PropertyAddress, 
				SaleDate, 
				SalePrice, 
				LegalReference 
				order by UniqueId)  RowNum
	from NashvilleHousing
) 

delete from CTE
where RowNum > 1;

--Delete Unused Columns
alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SalePrice
