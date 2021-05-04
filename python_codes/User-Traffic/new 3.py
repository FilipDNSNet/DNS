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
        layout.addWidget(self.lineEdit_username, 0 ,1)
        
        self.setLayout(layout)

if __name__=='__main__':
    print('<><>')
    app = QApplication(['tt'])
    form=LoginForm()
    form.show()
    sys.exit(app.exec_())



    
def openProject():
    app = QApplication(['tt'])
    form=LoginForm()
    form.show()
    sys.exit(app.exec_())
    
    print('hi')

def saveProject():
    pass

def closeProject():
    pass














    from qgis.core import (
      QgsApplication,
      QgsRasterLayer,
      QgsAuthMethodConfig,
      QgsDataSourceUri,
      QgsPkiBundle,
      QgsMessageLog,
    )

    from qgis.gui import (
        QgsAuthAuthoritiesEditor,
        QgsAuthConfigEditor,
        QgsAuthConfigSelect,
        QgsAuthSettingsWidget,
    )

    from qgis.PyQt.QtWidgets import (
        QWidget,
        QTabWidget,
    )

    from qgis.PyQt.QtNetwork import QSslCertificate
	
	
	
	
	
	
	
from PyQt5 import QtWidgets, QtCore, QtGui


class Login_Dialog(QtWidgets.QDialog, LoginForm):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.setupUi(self)
        self.login_button.clicked.connect(self.accept)


class Widget(QtWidgets.QWidget):
    def __init__(self, parent = None):
        super().__init__(parent)
        # setup ui as before
        
    def get_login(self):
        dialog = Login_Dialog(self)
        if dialog.exec_():
            # get activation key from dialog
            # (I'm assuming here that the line edit in your dialog is assigned to dialog.line_edit)  
            self.activation_key = dialog.line_edit.text()
            self.login()
            
    def login(self)
        print(f'The activation_key you entered is {self.activation_key}')