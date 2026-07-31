-- cleaning data in sql queries
SELECT * 
FROM project.dbo.NashvilleHousing

--Populate Property Address data
SELECT *
FROM project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]


-- Breaking out Address into Individual Columns (Address,city,State)
SELECT PropertyAddress
FROM project.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM project.dbo.NashvilleHousing;

-- Split address
ALTER TABLE project.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
GO
UPDATE project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);
GO
-- Split city
ALTER TABLE project.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
GO
UPDATE project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
GO

SELECT *
FROM project.dbo.NashvilleHousing

SELECT OwnerAddress
FROM project.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM project.dbo.NashvilleHousing;

ALTER TABLE project.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
GO

UPDATE project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);
GO

ALTER TABLE project.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
GO

UPDATE project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);
GO

ALTER TABLE project.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
GO

UPDATE project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
GO

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM project.dbo.NashvilleHousing;

--Change 1 and 0 to Yes and No in Sold as vacant field
SELECT DISTINCT(SoldAsVacant)
FROM project.dbo.NashvilleHousing;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
     WHEN SoldAsVacant = 0 THEN 'No'
END AS SoldAsVacantText
FROM project.dbo.NashvilleHousing;

ALTER TABLE project.dbo.NashvilleHousing
ADD SoldAsVacantText Nvarchar(255);
GO

UPDATE project.dbo.NashvilleHousing
SET SoldAsVacantText = 
    CASE WHEN SoldAsVacant = 1 THEN 'Yes'
         WHEN SoldAsVacant = 0 THEN 'No'
    END;
GO

SELECT SoldAsVacant, SoldAsVacantText
FROM project.dbo.NashvilleHousing;

-- Remove duplicates
-- Confirming first
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM project.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference;

--deleting

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM project.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

--deleting unused coloumns
SELECT *
FROM project.dbo.NashvilleHousing;

ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate


ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN SaleDate