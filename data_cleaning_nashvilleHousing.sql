use Data_Cleaning;

select * from nashville_housing;

-- estandizar los datos 

select  saledate, convert(Date,saleDate) from Nashville_housing;

alter table nashville_housing 
add SaleDateConverted date;

update Nashville_housing set SaleDateConverted = convert(Date,saleDate);

select  saledate, SaleDateConverted from Nashville_housing;

--  Rellenar los valores faltantes en la columna "PropertyAddress" utilizando los valores correspondientes de registros duplicados.

select  * from Nashville_housing where PropertyAddress is null; 

select a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress , isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing a join Nashville_housing b 
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a 
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing a join Nashville_housing b 
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

select  * from Nashville_housing where PropertyAddress is null;  

-- Vamos separar la columna "Propertyadress" en "property address" y "city" para facilitar consultas futuras. 
-- Esto proporciona mayor flexibilidad y agilidad en el análisis de datos relacionados con las propiedades.

select  PropertyAddress from Nashville_housing; 

select	SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1 ) as Adress ,  
		SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress) ) as city
from Nashville_housing;

alter table Nashville_housing add propertySplitAddress Nvarchar(255); 

alter table Nashville_housing add propertySplitCity Nvarchar(255); 

update Nashville_housing set propertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',', PropertyAddress) -1 ); 

update Nashville_housing set propertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select  propertySplitAddress , propertySplitCity from Nashville_housing;

-- vamos a separar la columna "Owneradress" en "Owner address", "owner city" y "owner state" para mejorar las consultas SQL futuras y agilizar el análisis de datos relacionados con los propietarios.

select OwnerAddress from Nashville_housing;

select	PARSENAME(replace(OwnerAddress, ',' , '.') , 3 )  , 
		PARSENAME(replace(OwnerAddress, ',' , '.') , 2 )  ,
		PARSENAME(replace(OwnerAddress, ',' , '.') , 1 )
from Nashville_housing;

alter table Nashville_housing add OwnerSplitAddress Nvarchar(255); 

alter table Nashville_housing add OwnerSplitCity Nvarchar(255); 

alter table Nashville_housing add OwnerSplitState Nvarchar(255); 

update Nashville_housing set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',' , '.') , 3 ); 

update Nashville_housing set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',' , '.') , 2 );

update Nashville_housing set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',' , '.') , 1 ); 

select  OwnerSplitAddress , OwnerSplitCity , OwnerSplitState  from Nashville_housing;

-- Reemplazaremos en la columna "soldAsVacant" los valores "N" y "Y" por "No" y "Yes", respectivamente.
-- Este cambio tiene como objetivo estandarizar los datos y asegurar una representación consistente de la información.
-- Al hacerlo, facilitaremos la comprensión y el análisis de los datos,  ya que la mayoría de los valores esperados corresponden a "No" y "Yes".

Select SoldAsVacant , count(SoldAsVacant) as count
from Nashville_housing group by SoldAsVacant order by 2 desc; 

Select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then  'No' 
						else SoldAsVacant end as updated
from Nashville_housing;

Select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then  'No' 
						else SoldAsVacant end as updated
from Nashville_housing;

alter table Nashville_housing add SoldAsVacantUpdated Nvarchar(3); 


update Nashville_housing SET SoldAsVacantUpdated = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then  'No' 
						else SoldAsVacant end;

Select count(SoldAsVacantUpdated) as count, SoldAsVacantUpdated
from Nashville_housing group by SoldAsVacantUpdated order by 2 desc;

-- Veamos cuántas filas duplicadas tenemos en la tabla.


With RomNumCTE as ( 
select *, ROW_NUMBER() over  ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num

from Nashville_housing
)
select * from RomNumCTE where row_num > 1 ;

--  procedemos a eliminar las filas duplicadas de la tabla. 
-- El objetivo es garantizar la integridad de los datos y optimizar el rendimiento de las consultas al eliminar las repeticiones innecesarias.
With RomNumCTE as ( 
select *, ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num

from Nashville_housing
)
delete from RomNumCTE where row_num > 1 ;


-- Verificamos que no queden filas duplicadas. 
With RomNumCTE as ( 
select *, ROW_NUMBER() over  ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num

from Nashville_housing
)
select * from RomNumCTE where row_num > 1 ;


-- Procedemos a eliminar las columnas que no estamos utilizando o que han sido reemplazadas por las columnas creadas anteriormente.
-- El objetivo es optimizar el diseño de la tabla y reducir el espacio de almacenamiento, eliminando aquellas columnas que ya no son relevantes para las consultas o que han sido sustituidas por información más actualizada.

select * from Nashville_housing ;

alter table Nashville_housing drop column owneraddress, PropertyAddress , SaleDate;

