from PyQt5.QtCore import pyqtSlot, QVariant
from PyQt5.QtQml import QQmlListProperty

from DBItems import *


class Welcome(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._exist_bd = [DBInfoView("test1"), DBInfoView("test2")]

    @pyqtProperty(QQmlListProperty)
    def exist_bd(self):
        return QQmlListProperty(DBInfoView, self, self._exist_bd)

    @pyqtSlot(QVariant)
    def add_item(self, name):
        print(name)
