use portfolio_project ;

select * from CovidDeaths order by 3,4;

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths;

--looking at total cases vs total deaths 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate from CovidDeaths
where location like '%india%';

--looking at toatal cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as CaseRate from CovidDeaths
where location like '%india%';

--looking at countries with the highest infected case rate
select location,population,max(total_cases)  as Total_cases, max((total_cases/population))*100 as CaseRate
from CovidDeaths  
group by location,population order by caserate desc;

--looking countries with highest deaths 
select location,population,max(total_deaths)  as Total_Deaths 
from CovidDeaths where continent is not null  
group by location,population order by Total_deaths desc;

--lookink continets with highest deaths
select location as continents,max(total_deaths)  as Total_Deaths 
from CovidDeaths where continent is null  
group by location order by Total_deaths desc;

--Global numbers

select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 
as DeathRate from CovidDeaths where continent is not null group by date order by date;

select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 
as DeathRate from CovidDeaths where continent is not null;

select * from CovidVaccinations;
select * from CovidDeaths;

--joining both tables
select * from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date;

--looking at total population and vaccinations
select cd.continent,cd.location,cd.population,sum(cv.new_vaccinations) as vaccinations,
(sum(cv.new_vaccinations)/population)*100 as Vaccination_Rate
from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
group by cd.continent,cd.location,cd.population
order by cd.location;

--looking at total population and vaccinations
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by cd.location;

--use CTE
with popvsvac (continent,loacation,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 as vac_rate from popvsvac; 


--TEMP Table
drop table if exists #peoplevaccinated;
create table #peoplevaccinated(
continent varchar(250),
location varchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #peoplevaccinated 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

select * from #peoplevaccinated order by location;

--creating a view to store data for later visualizations
create view peoplevaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations ,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as rollingpeoplevaccinated
from CovidDeaths cd join CovidVaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

select * from peoplevaccinated;