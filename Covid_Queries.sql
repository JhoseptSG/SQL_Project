use covid_portfolio;

select * from Deaths
where continent is not null
order by 3,4;

select * from vaccinations order by 3,4;

-- Seleccionar los datos que vamos a utilizar
select location, date, total_cases, new_cases, total_deaths, population
from Deaths order by 1,2;

-- Analizando el total de casos vs el total de muertes en un pa�s
select location,date,total_cases, total_deaths, total_deaths/total_cases*100 as Letalidad
from Deaths where location like '%argentina%' and continent is not null order by 1,2;

-- Analizando el total de casos vs la poblaci�n en un pa�s
select location,date,total_cases, population, total_cases/population*100 as infectionRate
from Deaths where location like '%argentina%' and continent is not null order by 1,2;

-- �Qu� pa�s tiene la tasa de infecci�n m�s alta en comparaci�n con la poblaci�n?
select location, MAX(total_cases) as CasosInfeccionMaximos, population, MAX(total_cases/population*100) as infectionRate
from Deaths where continent is not null
Group by location,population order by infectionRate desc;

-- �Cu�les son los pa�ses con el mayor n�mero de muertes por poblaci�n?
select location, MAX(cast(total_deaths as int)) as MayorCantMuertes, population, MAX(total_deaths/population*100) as Letalidad
from Deaths where continent is not null
Group by location,population
order by Letalidad desc;

-- Mostrar los continentes con el mayor n�mero de muertes por poblaci�n
select location,MAX(cast(total_deaths as int)) as MayorCantMuertes, MAX(total_deaths/population*100) as PercentageDeath
from Deaths where continent is null
Group by location
order by MayorCantMuertes desc;

-- Obtener el n�mero total de casos, muertes y el porcentaje de muertes a nivel global.
select sum(new_cases) as CasosTotales, sum(cast(new_deaths as int)) as MuertesTotales,
sum(cast(new_deaths as int))*100 / sum(new_cases) as Porcentaje_Muertes
from Deaths where continent is not null;

-- Analizando la poblaci�n total vs las vacunaciones
-- Dos formas de hacerlo
-- Forma 1:Utilizando la cl�usula WITH
with PopvsVac (continente, ubicacion, fecha , poblacion, nuevas_vacunaciones, personas_vacunadas_acumuladas)
as (
select deaths.continent, deaths.location, deaths.date , deaths.population, vaccinations.new_vaccinations,
sum(convert(int,vaccinations.new_vaccinations))
over (partition by deaths.location order by deaths.location , deaths.date) as personas_vacunadas_acumuladas
from deaths join vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null

)

select * , personas_vacunadas_acumuladas / poblacion * 100 as porcentaje_poblacion_total_vacunada from PopvsVac;

-- El campo "porcentaje_poblacion_total_vacunada" representa el porcentaje de la poblaci�n total que ha sido vacunada. 
-- Puede superar el 100% debido a que una persona puede recibir m�ltiples dosis de la vacuna


-- Forma 2: Creando una tabla.

Create Table #PorcentajePoblacionVacunada
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeopleVaccinated numeric
)

-- Insertar datos en la tabla.
insert into #PorcentajePoblacionVacunada
select deaths.continent, deaths.location, deaths.date , deaths.population, vaccinations.new_vaccinations,
sum(convert(int,vaccinations.new_vaccinations))
over (partition by deaths.location order by deaths.location , deaths.date) as RollingPeopleVaccinated
from deaths join vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null

-- Obtener el porcentaje de poblaci�n vacunada.
select * , RollingPeopleVaccinated / population * 100  as porcentaje_poblacion_total_vacunada from #PorcentajePoblacionVacunada; 

-- El campo "porcentaje_poblacion_total_vacunada" representa el porcentaje de la poblaci�n total que ha sido vacunada. 
-- Puede superar el 100% debido a que una persona puede recibir m�ltiples dosis de la vacuna

-- Eliminar la tabla temporal si se desea.
drop table if exists #PorcentajePoblacionVacunada

-- Crear una vista para facilitar la reutilizacion de futuras c .
create view PorcentajePoblacionVacunada as
select deaths.continent, deaths.location, deaths.date , deaths.population, vaccinations.new_vaccinations,
sum(convert(int,vaccinations.new_vaccinations))
over (partition by deaths.location order by deaths.location , deaths.date) as RollingPeopleVaccinated
from deaths join vaccinations
on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null;