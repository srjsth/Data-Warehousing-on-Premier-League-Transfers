drop table PlayerStatsFactTable 
drop table TransferFactTable
drop table PlayerDimTable
drop table transferwindowdimtable
drop table seasondimtable
drop table  ClubDimTable

CREATE TABLE SeasonDimTable(
SeasonID int not null,
StartDate varchar(255),
EndDate varchar(255),
SeasonYear varchar(255),
StartYear varchar(255),
EndYear varchar(255),
StartMonth varchar(255),
EndMonth varchar(255),
StartDay varchar(255),
EndDay varchar(255),
PRIMARY KEY(SeasonID))







CREATE TABLE TransferWindowDimTable(
TransferDimID int not null,
Year varchar(255),
TransferWindow varchar(255), 
DeadlineMonth varchar(255),
DeadlineDay varchar(255),
PRIMARY KEY(TransferDimID))



CREATE TABLE ClubDimTable(
ClubID int not null,
Nationality varchar(255),
League varchar(255), 
Club varchar(255),
PRIMARY KEY(ClubID))



CREATE TABLE PlayerDimTable(
PlayerDimID int not null,
ClubID int REFERENCES ClubDimTable(ClubID),
PlayerID int not null,
Name varchar(255),
Club varchar(255),
Nationality varchar(255),
Age varchar(255),
RowEffectiveDate DATE, 
RowExpiryDate DATE,
ActiveClubIndicator BOOLEAN,
PRIMARY KEY(PlayerDimID))






CREATE TABLE PlayerStatsFactTable(
PlayerFactID int not null,
PlayerDimID int REFERENCES PlayerDimTable(PlayerDimID),
SeasonID int REFERENCES SeasonDimTable(SeasonID),
Name varchar(255),
Club varchar(255),
Nationality varchar(255),
Matches float,
Starts float, 
Minutes float,
Goals float,
Assists float,
GoalstoGamesRatio float,
GoalstoStartsRatio float,
SeasonYear varchar(255),
PRIMARY KEY(PlayerFactID))










CREATE TABLE TransferFactTable(
TransferFactID INT NOT NULL,
TransferDimID INT REFERENCES TransferWindowDimTable(transferdimid),
ClubID int REFERENCES ClubDimTable(ClubID),
PlayerDimID int REFERENCES PlayerDimTable(PlayerDimID), 
Club varchar(255), 
Name varchar(255),
TransferFee float,
Year int, 
TransferWindow varchar(255),
TransferType varchar(255),
PRIMARY KEY(TransferFactID))



select * from SeasonDimTable
select * from TransferWindowDimTable
select * from ClubDimTable
select * from PlayerDimTable 
select * from PlayerStatsFactTable 
select * from TransferFactTable

SELECT PlayerName, PlayerClub, Season, PlayerGoals, PlayerAssists, TotalGoalsOverall, TotalAssistsOverall,transferfacttable.transferfee, 
DENSE_RANK() OVER (ORDER BY TotalGoalsOverall desc) as TopScorersTransferredPlayersOverall
FROM(
SELECT PlayerDimTable.playerdimid, PlayerDimTable.name AS PlayerName, ClubDimTable.club AS PlayerClub, seasondimtable.seasonyear AS Season, 
PlayerStatsFactTable.goals AS PlayerGoals, Sum(PlayerStatsFactTable.goals) over (partition by PlayerDimTable.playerdimid) TotalGoalsOverall,
PlayerStatsFactTable.assists AS PlayerAssists, Sum(PlayerStatsFactTable.assists) over (partition by PlayerDimTable.playerdimid) TotalAssistsOverall
FROM PlayerDimTable
JOIN PlayerStatsFactTable ON PlayerStatsFactTable.playerdimid = playerdimtable.playerdimid
JOIN transferfacttable ON transferfacttable.playerdimid = playerdimtable.playerdimid
JOIN seasondimtable seasondimtable ON seasondimtable.seasonid = PlayerStatsFactTable.seasonid
JOIN clubdimtable ON clubdimtable.clubid = playerdimtable.clubid
WHERE PlayerStatsFactTable.goals != 'NaN'
GROUP BY PlayerDimTable.name, PlayerDimTable.playerdimid, ClubDimTable.club, seasondimtable.seasonyear, PlayerStatsFactTable.goals, PlayerStatsFactTable.assists
ORDER BY PlayerDimTable.name, Sum(PlayerStatsFactTable.goals) desc)S
JOIN transferfacttable ON transferfacttable.playerdimid = S.playerdimid
