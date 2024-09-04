
-- Cleaning Housing Data With SQL

SELECT * 
FROM TYCHE.dbo.house

--------------------------------------------
-- Standardize Date Format

SELECT SaleDate
FROM dbo.house

ALTER TABLE dbo.house
ALTER COLUMN SaleDate Date

--------------------------------------------
-- Populate Property Address Missing Values

SELECT *
FROM dbo.house
WHERE PropertyAddress IS NULL

-- We Can Populate The Address With The Help Of ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress LIMIT1
FROM dbo.house AS a
JOIN dbo.house AS b
	ON a.ParcelID = b.ParcelID
	AND a.PropertyAddress IS NULL
WHERE b.PropertyAddress IS NOT NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.house AS a
JOIN dbo.house AS b
	ON a.ParcelID = b.ParcelID
	AND a.PropertyAddress IS NULL
WHERE b.PropertyAddress IS NOT NULL

---------------------------------------------
-- Breaking Out Address into Individual Columns(Address, City)
-- PARSENAME(REPLACE(COLUMN, ',', '.'), NUM)

SELECT 
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.house

ALTER TABLE dbo.house
ADD DetailAddress NVARCHAR(256)

ALTER TABLE dbo.house
ADD City NVARCHAR(256)

UPDATE house
SET DetailAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1)

UPDATE house
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertyAddress, DetailAddress, City
FROM house

-----------------------------------------
-- Organize SoldAsVacant 

SELECT COUNT(*) AS VacantNum, SoldAsVacant
FROM house
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM house

UPDATE house
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

-----------------------------------------
-- Remove Duplicates


SELECT Column_Name , Data_Type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'house'


SELECT COUNT(*), ParcelID, SaleDate, LegalReference
FROM house
GROUP BY ParcelID, SaleDate, LegalReference
HAVING COUNT(*) > 1

SELECT *
FROM house
WHERE ParcelID = '081 02 0 144.00'


WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
	FROM dbo.house
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


---- DELETING!!!! -----

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
	FROM dbo.house
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

------------------------
-- Droping useless column OwnerAddress

SELECT * FROM house

ALTER TABLE house
DROP COLUMN OwnerAddress

----------------------------------