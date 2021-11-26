USE SalesHousing
/*

Cleaning data in T-SQl

*/

SELECT
	*
FROM	
	SalesHousing..NashvilleSales
GO
-------------------------------------------------------------------------------------------------------------------------

-- Standardize date formart
-- (Estandarizar el formato de la fecha)

SELECT
	SaleDate
FROM	
	SalesHousing..NashvilleSales
GO


-- formatting the SaleDate column
-- (formateando la columna SaleDate)
ALTER TABLE NashvilleSales
ALTER COLUMN [SaleDate] date

-- check column SaleDate 
SELECT
	*
FROM
	SalesHousing..NashvilleSales
GO


-- Another way 
-- Add a column with the name SaleDateConverted
-- (Agregar una columna con el nombre SaleDateConverted)
ALTER TABLE NashvilleSales
ADD SaleDateConverted Date;


-- Now you have to refresh the table to check if the new column has been created and perform the date formatting.
-- (Ahora hay que actualizar la tabla para revisar si se ha creado la nueva columna y realizar el formateo de fecha)
UPDATE  NashvilleSales
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Checking that the date has been formatted correctly
--(Revisando que la fecha se haya formatedo correctamente)
SELECT
	SaleDateConverted
FROM
	SalesHousing..NashvilleSales
GO

-- deleting column SaleDateConverted
ALTER TABLE NashvilleSales
DROP COLUMN SaleDateConverted;
GO

--------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- (Rellenar los datos de la dirección de la propiedad)

-- step 1. Check null values
SELECT 
	PropertyAddress
FROM
	SalesHousing..NashvilleSales
WHERE
	PropertyAddress IS NULL


-- Check null values in all columns
SELECT 
	*
FROM
	SalesHousing..NashvilleSales
WHERE
	PropertyAddress IS NULL
GO

-- check the column ParcelID  
SELECT 
	*
FROM
	SalesHousing..NashvilleSales
--WHERE
--	PropertyAddress IS NULL
ORDER BY
	ParcelID
GO

-- Self Join to check which null values in the PropertyAddress column match the ParcelID column and find null values.
-- (Self Join para revisar que valores nulos de la columna PropertyAddress empatan con la columna ParcelID y encontrar valores nulos)
SELECT
	a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
FROM
	SalesHousing..NashvilleSales a
JOIN
	SalesHousing..NashvilleSales b
ON 
	a.ParcelID = b.ParcelID AND 
	a.[UniqueID] <> b.[UniqueID]
WHERE
	a.PropertyAddress IS NULL
GO

-- Check for null values in the PropertyAddress cluman
-- (Comprobar los valores nulos en la cluman PropertyAddress)
SELECT
	a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	SalesHousing..NashvilleSales a
JOIN
	SalesHousing..NashvilleSales b
ON 
	a.ParcelID = b.ParcelID AND 
	a.[UniqueID] <> b.[UniqueID]
WHERE
	a.PropertyAddress IS NULL
GO


-- updating and filling in the null values with the corresponding values
-- (actualizando y rellenando los valores nulos con los valores correspondientes)
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL(a.PropertyAddress, 'NoAddress') en el caso de desconocer los valores se puede sustituir con un string 
FROM
	SalesHousing..NashvilleSales a
JOIN
	SalesHousing..NashvilleSales b
ON 
	a.ParcelID = b.ParcelID AND 
	a.[UniqueID] <> b.[UniqueID]
WHERE
	a.PropertyAddress IS NULL
GO


-- checking that null values have been filled in correctly
-- (revisando que los valores nulos se hayan rellenado correctamente)
SELECT 
	PropertyAddress
FROM
	SalesHousing..NashvilleSales
WHERE
	PropertyAddress IS NULL
GO


------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address and City) with SUBSTRING
-- (Desglosar la dirección en columnas individuales (dirección y ciudad) con SUBSTRING)

SELECT 
	PropertyAddress
FROM
	SalesHousing..NashvilleSales
GO

-- splitting the PropertyAddress column up to the comma with SUBSTRING
-- (diviendo la columna PropertyAddress en hasta la coma con SUBSTRING)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))
FROM
	SalesHousing..NashvilleSales


-- finding the position number up to the decimal point
-- (encontrando el numero de posicion hasta la coma)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
	,CHARINDEX(',', PropertyAddress) AS Position
FROM
	SalesHousing..NashvilleSales
--ORDER BY Position ASC
GO

-- to find the string without the comma
-- (para encontrar el string sin la coma)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
	,CHARINDEX(',', PropertyAddress) AS Position
FROM
	SalesHousing..NashvilleSales
GO

-- finding the string after the comma
-- (encontrando el string despues de la coma)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))  AS City 
FROM
	SalesHousing..NashvilleSales
GO


-- create address and city columns
-- (crear columnas de direccion y ciudad )
ALTER TABLE NashvilleSales
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleSales
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
GO

-- check the new columns
--SELECT *
--FROM
--	SalesHousing..NashvilleSales
--GO

ALTER TABLE NashvilleSales
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleSales
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
GO



-- Breaking out Address into Individual Columns (Address and City) with PARSENAME
-- PARSENAME ONLY WORKS WITH DOT (.)
-- split everything but from the end
-- (divide todo pero desde el final)
SELECT
	OwnerAddress
FROM	
	SalesHousing..NashvilleSales
GO


SELECT
	 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM
	SalesHousing..NashvilleSales
GO


-- appending the new columns
-- (anexando las nuevas columnas)

ALTER TABLE NashvilleSales
ADD OwnerSplitAddress nvarchar(255)
	,OwnerSplitCity nvarchar(255)
	,OwnerSplitState nvarchar(255)
	;

UPDATE NashvilleSales
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
	,OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
	,OwnerSplitState   = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
	;
GO

-- reviewing the creation of the new columns
-- (revisadno la creacion de las nuevas columnas)
--SELECT 
--	*
--FROM
--	SalesHousing..NashvilleSales
-- GO



-------------------------------------------------------------------------------------------------------------------------------------
-- Replace data with CASE statement

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Cambiar Y y N por Sí y No en el campo "Vendido como vacante"

SELECT
	DISTINCT (SoldAsVacant)
	,COUNT(SoldAsVacant) AS Count
FROM
	SalesHousing..NashvilleSales
GROUP BY 
	SoldAsVacant
ORDER BY
	2 DESC
GO


SELECT
	SoldAsVacant
	,CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant  = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
	SalesHousing..NashvilleSales
GO


UPDATE NashvilleSales
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant  = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
GO



-----------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates with CTE

SELECT
	*
FROM
	SalesHousing..NashvilleSales
GO


-- all this values are duplicates
WITH RowNumCTE AS 
(
	SELECT 
		*,
		ROW_NUMBER() 
		OVER
		(
		  PARTITION BY  
						ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY 
							UniqueID
		) AS row_num
	FROM
		SalesHousing..NashvilleSales
	--ORDER BY 
	--	ParcelID
)
SELECT	
	*
FROM
	RowNumCTE
WHERE
	row_num > 1
ORDER BY
	SaleDate
GO	


-- to delete

WITH RowNumCTE AS 
(
	SELECT 
		*,
		ROW_NUMBER() 
		OVER
		(
		  PARTITION BY  
						ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY 
							UniqueID
		) AS row_num
	FROM
		SalesHousing..NashvilleSales
	--ORDER BY 
	--	ParcelID
)
DELETE
	FROM
		RowNumCTE
	WHERE
		row_num > 1
	--ORDER BY
	--	SaleDate
GO	



-----------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- (Borrar las columnas no utilizadas, solo despues de que los han sido procesados en la base de datos)

SELECT
	*
FROM
	SalesHousing..NashvilleSales
GO


ALTER TABLE 
	SalesHousing..NashvilleSales
DROP COLUMN 
	OwnerAddress
	,PropertyAddress
GO



