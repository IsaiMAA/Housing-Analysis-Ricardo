#Housing Problems

select * from cleaneddata

#Status Analysis
select `Last Status` as Last_Status, round(avg(`List Price`),0) as Avg_List_Price from cleaneddata group by Last_Status order by Avg_List_Price desc

#Area Analysis
select Area, round(avg(`List Price`),2) as List_Price from cleaneddata group by Area order by List_Price desc

#Municipality Analysis / We can see which areas have the greatest prices.
select Municipality, round(avg(`List Price`),2) as Avg_List_Price from cleaneddata group by Municipality order by Avg_List_Price desc

select Age, round(Avg(`List Price`),2) as Avg_List_Price from cleaneddata group by Age order by Avg_List_Price desc
#We can clearly see new houses are more expensive than ols houses but the difference is not huge

#House Lot Analysis - We find out the Average Square Price per Municipality, now we want to find undervaluated deals
select Municipality , round(avg(`List Price`/(`Lot Depth`*`Lot Front`)),0) as LotSize from cleaneddata GROUP BY Municipality  ORDER BY Municipality

#Bredooms analysis 
select `Bedrooms Tot`,Washrooms, round(avg(`List Price`),0) from cleaneddata group by `Bedrooms Tot`,Washrooms order by `Bedrooms Tot`,Washrooms

select round((count(*) * sum(`Bedrooms Tot` * `List Price`) - sum(`Bedrooms Tot`) * sum(`List Price`)) / 
       (sqrt(count(*) * sum(`Bedrooms Tot` * `Bedrooms Tot`) - sum(`Bedrooms Tot`) * sum(`Bedrooms Tot`)) * 
       sqrt(count(*) * sum(`List Price` * `List Price`) - sum(`List Price`) * sum(`List Price`))) , 4) as Cor_BP from cleaneddata

#WashRooms Analaysis / Very little correlation

select round((count(*) * sum(Washrooms * `List Price`) - sum(Washrooms) * sum(`List Price`)) / 
       (sqrt(count(*) * sum(Washrooms * `Bedrooms Tot`) - sum(Washrooms) * sum(Washrooms)) * 
       sqrt(count(*) * sum(`List Price` * `List Price`) - sum(`List Price`) * sum(`List Price`))) , 4) as Cor_BP from cleaneddata

#Find out which areas houses are undervaluated
select id,municipality, coalesce(round(avg(`List Price`/(`Lot Depth`*`Lot Front`)),0),0) as Avg_Per_Lot_sqft from cleaneddata group by id,municipality
select Municipality , round(avg(`List Price`/(`Lot Depth`*`Lot Front`)),0) as LotSize from cleaneddata GROUP BY Municipality  ORDER BY Municipality

#This houses are undervalued compared to the average
select a.ID,a.Municipality,a.Avg_Per_Lot_sqft,b.LotSize from (select id,municipality, coalesce(round(avg(`List Price`/(`Lot Depth`*`Lot Front`)),0),0) as Avg_Per_Lot_sqft from cleaneddata group by id,municipality) a inner join (select Municipality , round(avg(`List Price`/(`Lot Depth`*`Lot Front`)),0) as LotSize from cleaneddata GROUP BY Municipality  ORDER BY Municipality) b on a.municipality=b.municipality where b.LotSize<a.Avg_Per_Lot_sqft

select 5858.88+2400;


