import sys

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt5.QtWidgets import QApplication

from FormBackend import FormBackend

if __name__ == '__main__':
    myApp = QApplication(sys.argv)

    qmlRegisterType(FormBackend, 'SimpleDB', 1, 0, 'FormBackend')

    appLabel = QQmlApplicationEngine()
    appLabel.load(QUrl('main.qml'))
    myApp.exec_()
    sys.exit()
