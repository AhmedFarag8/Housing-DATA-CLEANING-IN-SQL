select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing 
------------------------------------------------------------------------------------------------------------------------
  -- Standardize Date Format--
select 
  SaleDate, 
  convert(date, SaleDate) 
From 
  [Project SQL].dbo.NashvilleHousing 
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  SaleDate = CONVERT(date, SaleDate) 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  SaleDateConverted Date;
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  SaleDateConverted = CONVERT(date, SaleDate) 
-------------------------------------------------------------------------------------------------------------------------
  -- Populate Property Address data--
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing --where PropertyAddress is null
select 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress, 
  ISNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
From 
  [Project SQL].dbo.NashvilleHousing a 
  Join [Project SQL].dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID 
  And a.[UniqueID ] <> b.[UniqueID ] 
Where 
  a.PropertyAddress is null 
Update 
  a 
Set 
  PropertyAddress = ISNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
From 
  [Project SQL].dbo.NashvilleHousing a 
  Join [Project SQL].dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID 
  And a.[UniqueID ] <> b.[UniqueID ] 
Where 
  a.PropertyAddress is null 
-------------------------------------------------------------------------------------------------------------------------
  -- Breaking out Address into Individual Columns (Address, City, State)--
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing --Where PropertyAddress is null
  --order by ParcelID
select 
  SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress) -1
  ) as Address --Removing the Comma and the after it-- 
  , 
  SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress) + 1, 
    Len(PropertyAddress)
  ) as Address 
From 
  [Project SQL].dbo.NashvilleHousing 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  PropertySplitAddress Nvarchar(255);
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  PropertySplitAddress = SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress) -1
  ) 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  PropertySplitCity Nvarchar(255);
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  PropertySplitCity = SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress) + 1, 
    Len(PropertyAddress)
  ) 
-------------------------------------------------------------------------------------------------------------------------
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing 
Where 
  OwnerAddress is null 
select 
  PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    3
  ), 
  PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    2
  ), 
  PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    1
  ) 
From 
  [Project SQL].dbo.NashvilleHousing 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  OwnerSplitAddress Nvarchar(255);
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  OwnerSplitAddress = PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    3
  ) 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  OwnerSplitCity Nvarchar(255);
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  OwnerSplitCity = PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    2
  ) 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Add 
  OwnerSplitState Nvarchar(255);
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  OwnerSplitState = PARSENAME(
    Replace(OwnerAddress, ',', '.'), 
    1
  ) 
-------------------------------------------------------------------------------------------------------------------------
  -- Change Y and N to Yes and No in "Sold as Vacant" field
select 
  Distinct(SoldAsVacant), 
  COUNT(SoldAsVacant) 
From 
  [Project SQL].dbo.NashvilleHousing 
Group By 
  SoldAsVacant 
Order By 
  2 
Select 
  SoldAsVacant, 
  Case when SoldAsVacant = 'Y' Then 'Yes' When SoldAsVacant = 'N' Then 'No' Else SoldAsVacant End 
From 
  [Project SQL].dbo.NashvilleHousing 
Update 
  [Project SQL].dbo.NashvilleHousing 
Set 
  SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes' When SoldAsVacant = 'N' Then 'No' Else SoldAsVacant End 
----------------------------------------------------------------------------------------------------------------------------------
  -- Remove Duplicates--
  With RowNumCTE AS(
    Select 
      *, 
      ROW_NUMBER() Over(
        Partition By ParcelID, 
        PropertyAddress, 
        SalePrice, 
        SaleDate, 
        LegalReference 
        Order By 
          UniqueID
      ) row_num 
    From 
      [Project SQL].dbo.NashvilleHousing --Order By ParcelID--
      ) 
Select 
  * 
From 
  RowNumCTE 
where 
  row_num > 1 
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing 
--------------------------------------------------------------------------------------------------------------------------------------
  --Delete Unused Columns--
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Drop 
  Column SaleDate, 
  OwnerAddress, 
  TaxDistrict 
Alter Table 
  [Project SQL].dbo.NashvilleHousing 
Drop 
  Column PropertyAddress 
select 
  * 
From 
  [Project SQL].dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------------------------------
