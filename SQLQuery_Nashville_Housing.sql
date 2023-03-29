select * from 
	PortfolioProject..NashvilleHousing

--Standardize Date format

select SaleDate, adjusted_date
from  PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD adjusted_date date

UPDATE PortfolioProject..NashvilleHousing
SET adjusted_date = convert(Date,SaleDate)


EXEC sp_rename 'PortfolioProject..NashvilleHousing.adjusted_date', 'SaleDateConverted';


--Populate property Address data

select *
from  PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID	

select a.ParcelID, a.PropertyAddress,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from  PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID
where b.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from  PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null

--Breaking out adress into Individual Columns (Address, City, State)

select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address1,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address2
from  PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))


-- separating Owner address into individual columns

select PARSENAME(replace(OwnerAddress,',','.'),3), PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from  PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity= PARSENAME(replace(OwnerAddress,',','.'),2)



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


select * from 
PortfolioProject..NashvilleHousing


--Change Y to Yes and N to No in soldasVacant column

select  distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select count( SoldAsVacant),
case
 when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing
group by SoldAsVacant


update PortfolioProject..NashvilleHousing
set SoldAsVacant =
	case
 when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


---- Removing Duplicates
with RowNumCTE as(
select*,
	ROW_NUMBER() over (
		partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
						UniqueID) as row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1



--Delete Unused columns

Alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress,PropertyAddress,TaxDistrict 

select * from
PortfolioProject..NashvilleHousing