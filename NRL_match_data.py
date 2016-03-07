import urllib
import json

url = "https://tds-nrl-matchcentre.s3-ap-southeast-2.amazonaws.com/data/prod/2015/fixtures/111.json?1457194123800"
   
htmltext = urllib.urlopen(url)
matchdata = json.load(htmltext)

for team in matchdata:
    print team["roundId"]



#with open('NRL_seasondata.json', 'w') as fp:
#    json.dump(data, fp)
#    fp.write("\n")
