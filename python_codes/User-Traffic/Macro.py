from PyQt5.QtCore import QSettings
from qgis.core import QgsDataSourceUri, QgsProject, QgsMapLayer
import re
uri = QgsDataSourceUri()

qs = QSettings()
#host=qs.value('PostgreSQL/connections/dns_net_geodb/host')
#port=qs.value('PostgreSQL/connections/dns_net_geodb/port')
try:
    user=qs.value('PostgreSQL/connections/dns_net_geodb/username')
    password=qs.value('PostgreSQL/connections/dns_net_geodb/password')
    print('User: '+user)
except:
    pass
#dbname=qs.value('PostgreSQL/connections/dns_net_geodb/database')

    
def openProject():
    try:
        #print('db: '+dbname)
        #print('host:' + host)
        for L in list(QgsProject.instance().mapLayers().values()):
            if L.type()==QgsMapLayer.VectorLayer and L.storageType()=='PostgreSQL database with PostGIS extension':
                #inf=((L.source()).replace("\"","")).split(' ')
                #dbname=inf[0].split("=")[1]
                #dbname=dbname.replace("\'","")
                
                ## host
                m=re.findall(r"host=[^\s]*", L.source());
                host=m[0].split('=')[1]
                
                ## port
                m=re.findall(r"port=[^\s]*", L.source());
                port=m[0].split('=')[1]
                
                ## dbname
                m=re.findall('dbname=[^\s]*', L.source());
                dbname=(m[0].split('=')[1]).replace('\'','')
                
                ## Schema and table
                #m=re.findall('table=[^\s]*', L.source());
                m=re.findall('table=".*"\.".*"', L.source())
                schm, tbl=(m[0].split('=')[1]).split('.')
                schm=schm.replace('"','')
                tbl=tbl.replace('"','')
                
                ## Primary key
                m=re.findall(r"key=[^\s]*", L.source());
                if len(m)==1:
                    ky=(m[0].split('=')[1]).replace('\'','')
                else:
                    ky=''
                    
                ## geometry column
                m=re.findall(r"\s\(.*\)\s*", L.source());
                if len(m)==1:
                    col=m[0].replace('(','').replace(')','').replace(' ','')
                else:
                    col=''
                
                ## SQL filter:
                m=re.findall(r"sql=.*", L.source());
                if len(m)==1:
                    sql=m[0].split('=')[1];
                else:
                    sql=''
                ##print('connection: '+L.source())
                ##print('host: '+host)
                ##print('port: '+port)
                ##print('user: '+user)
                ##print('Pass: '+password)
                ##print('dbname: '+dbname)
                ##print('schema: '+schm)
                ##print('table: '+tbl)
                ##print('geometry column: '+col)
                ##print('key column: '+ky)
                ##print('filter: '+sql)
                uri.setConnection(host, port, dbname, user, password)
                uri.setDataSource(schm, tbl, col, sql, ky)
                L.setDataSource(uri.uri(), L.name(), "postgres", False)
        print('Done')
    except:
        pass

def saveProject():
    pass

def closeProject():
    pass












############################################################################################################################################

import sys
from PyQt5.QtWidgets import (QApplication, QWidget, QPushButton, QLabel, QLineEdit, QGridLayout, QMessageBox)
import psycopg2

class LoginForm(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Login Form')
        self.resize(500, 120)
        
        layout=QGridLayout()
        
        label_name=QLabel('<font size="4"> Username </font>')
        self.lineEdit_username = QLineEdit()
        self.lineEdit_username.setPlaceholderText('Datenbank Username:')
        layout.addWidget(label_name, 0,0)
        Layout.addWidget(self.lineEdit_username, 0 ,1)
        
        self.setLayout(layout)

if __name__=='__main__':
    app = QApplication(sys.argv)
    form=LoginForm()
    form.show()
    sys.exit(app.exec_())
    
app = QApplication(sys.argv)

def openProject():
    form=LoginForm()
    form.show()
    sys.exit(app.exec_())
    
    print('hi')

def saveProject():
    pass

def closeProject():
    pass








L=list(QgsProject.instance().mapLayers().values())[1]
L.source();

m=re.findall(r"sql=.*", L.source()); m[0].split('=')[1]
m=re.findall(r"host=[^\s]*", L.source()); m[0].split('=')[1]
m=re.findall(r"port=[^\s]*", L.source()); m[0].split('=')[1]
m=re.findall('dbname=[^\s]*', L.source()); (m[0].split('=')[1]).replace('\'','')
m=re.findall('table=[^\s]*', L.source()); schm, tbl=(m[0].split('=')[1]).split('.')
m=re.findall(r"key=[^\s]*", L.source()); (m[0].split('=')[1]).replace('\'','')
m=re.findall(r"\s\(.*\)\s", L.source()); m[0].replace('(','').replace(')','').replace(' ','')