from qgis.core import QgsProject
layers= QgsProject.instance().mapLayers().values()
layers['gehaeuse_20201028_f85dc10e_ff7e_4d09_b9ee_5c62d20f0eb1'].sourceCrs()

uri = QgsDataSourceUri()
uri.setConnection("localhost", "5432", "dns_net_geodb", "sebastian", "DNSpln_mg79")
###uri.setDataSource("monitoring_dns_net", "trasse_bb_20201028", "geom", "city='adsf'")  #filter
uri.setDataSource("monitoring_dns_net", "trasse_bb_20201028", "geom")
L=layers['gehaeuse_20201028_f85dc10e_ff7e_4d09_b9ee_5c62d20f0eb1']



dbname='dns_net_geodb' host=212.86.33.238 port=5432 user='msiegert' sslmode=disable key='id' srid=25833 type=MultiLineString checkPrimaryKeyUnicity='1' table="monitoring_dns_net"."trasse_bb_20201028" (geom) sql=
layers['gehaeuse_20201028_f85dc10e_ff7e_4d09_b9ee_5c62d20f0eb1']


L.setDataSource(uri.uri(), "000000", "postgres")
L.setDataSource(uri.uri(), "000001", "postgres", False)



for all layers 
	if
		L.type()==QgsMapLayer.VectorLayer     and     L.storageType() # => 'PostgreSQL database with PostGIS extension'
		
		change the users


uri = QgsDataSourceUri()
uri.setConnection("localhost", "5432", "dns_net_geodb", "sebastian", "DNSpln_mg79")        
        




uri = QgsDataSourceUri()

for L in list(QgsProject.instance().mapLayers().values()):
    if L.type()==QgsMapLayer.VectorLayer and L.storageType()=='PostgreSQL database with PostGIS extension':
        uri.setConnection(host, port, dbname, user, password)
        L.setDataSource(uri.uri(), L.name(), "postgres", False)
        
        
        
for L in list(QgsProject.instance().mapLayers().values()):
   if L.type()==QgsMapLayer.VectorLayer and L.storageType()=='PostgreSQL database with PostGIS extension':
       print(   ((L.source()).replace("\"","")).split(' ')   )  
       print('#'+L.name())
###################################
from PyQt5.QtCore import QSettings
from qgis.core import QgsDataSourceUri, QgsProject, QgsMapLayer
uri = QgsDataSourceUri()

qs = QSettings()
host=qs.value('PostgreSQL/connections/dns_net_geodb/host')
port=qs.value('PostgreSQL/connections/dns_net_geodb/port')
user=qs.value('PostgreSQL/connections/dns_net_geodb/username')
password=qs.value('PostgreSQL/connections/dns_net_geodb/password')
#dbname=qs.value('PostgreSQL/connections/dns_net_geodb/database')


    
def openProject():
    #print('db: '+dbname)
    print('host:' + host)
    print('user: '+user)
    print('Pass: '+password)
    for L in list(QgsProject.instance().mapLayers().values()):
        if L.type()==QgsMapLayer.VectorLayer and L.storageType()=='PostgreSQL database with PostGIS extension':
            inf=((L.source()).replace("\"","")).split(' ')
            dbname=inf[0].split("=")[1]
            dbname=dbname.replace("\'","")
            uri.setConnection(host, port, dbname, user, password)
            uri.setDataSource("")
            L.setDataSource(uri.uri(), L.name(), "postgres", False)
    print('Done')

def saveProject():
    pass

def closeProject():
    pass