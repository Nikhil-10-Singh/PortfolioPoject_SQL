/*

Cleaning data in SQL queries

*/

SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [PortfolioPoject]..[Nashville_Housing]

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted DATE;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address Data

SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM [PortfolioPoject]..[Nashville_Housing] x
JOIN  [PortfolioPoject]..[Nashville_Housing] y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL

UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM [PortfolioPoject]..[Nashville_Housing] x
JOIN  [PortfolioPoject]..[Nashville_Housing] y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL

SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]


--BREAKING OUT ADDRESS INTO INDIVDUAL COLUMNS (Address, City, State)

SELECT PropertyAddress
FROM [PortfolioPoject]..[Nashville_Housing]


SELECT  
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [PortfolioPoject]..[Nashville_Housing]


ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]


SELECT OwnerAddress
FROM [PortfolioPoject]..[Nashville_Housing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortfolioPoject]..[Nashville_Housing]


ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioPoject]..[Nashville_Housing]
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [PortfolioPoject]..[Nashville_Housing]


UPDATE Nashville_Housing
SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates



WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER 
		(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
							UniqueID
		) row_num
FROM [PortfolioPoject]..[Nashville_Housing]
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]



--Delete Unused Column


SELECT *
FROM [PortfolioPoject]..[Nashville_Housing]


ALTER TABLE [PortfolioPoject]..[Nashville_Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate