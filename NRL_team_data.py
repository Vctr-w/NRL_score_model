import urllib
import json

data = {"seasons": []}
SeasonDict = {1: 2005, 2: 2006, 3: 2007, 4: 2008, 5: 2009, 6: 2010, 7: 2011, 10: 2012, 41: 2013, 42: 2014, 43: 2015}

for i in SeasonDict.keys():
    url = "http://www.nrl.com/Ajax.aspx?feed=ClubStatistics.AjaxGetClubStats&seriesId=1&seasonId=" + str(i) + \
        "&roundId=0&imageSizeId=0&averages=false&statName=P&direction=desc&_=1456668359497"
   
    htmltext = urllib.urlopen(url)
    seasondata = json.load(htmltext)

    season = []
    round_teams = []

    for round in seasondata["roundList"]:
        roundDict = {k: round[k] for k in ("RoundID", "Value", "Number", "IsFinal", "IsGrandFinal", "IsSelected")}
       
        roundurl = "http://www.nrl.com/Ajax.aspx?feed=ClubStatistics.AjaxGetClubStats&seriesId=1&seasonId=" + str(i) + \
            "&roundId=" + str(roundDict["RoundID"]) + "&imageSizeId=0&averages=false&statName=P&direction=desc&_=1456668359497"
    
        htmltext = urllib.urlopen(roundurl)
        rounddata = json.load(htmltext)

        for team in rounddata["stats"]:
            teamcopy = {k: team[k] for k in ("ClubShortCode", "Nickname")}
            teamcopy.update(roundDict)
            teamcopy.update(team["SeasonStats"])
            round_teams.append(teamcopy)
            #teams.append({**roundDict, **team})

    for round in round_teams:
        season = {"SeasonID": i, "SeasonYear": SeasonDict[i]}
        season.update(round)
        data["seasons"].append(season)
        #season.append({**round, **{"season": i})

    print str(SeasonDict[i]) + " completed"

with open('NRL_seasondata.json', 'w') as fp:
    json.dump(data, fp)
    fp.write("\n")
    
