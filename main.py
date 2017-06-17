import sys

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

from DB_Worker import *
from WelcomeForm import *

# Main Function
if __name__ == '__main__':
    TablesManager()  # need for open db

    # test = Table("car")


    myApp = QApplication(sys.argv)

    qmlRegisterType(Welcome, 'SimpleDB', 1, 0, 'WelcomeInfo')
    qmlRegisterType(TableEditModel, 'SimpleDB', 1, 0, 'TableEditModel')
    qmlRegisterType(TableEditModelCreator, 'SimpleDB', 1, 0, 'TableEditModelCreator')
    qmlRegisterType(ColumnInfo, 'SimpleDB', 1, 0, 'ColumnInfo')

    appLabel = QQmlApplicationEngine()
    appLabel.load(QUrl('qml/MainWindow.qml'))

    # Execute the Application and Exit
    myApp.exec_()
    sys.exit()
