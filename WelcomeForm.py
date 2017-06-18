from PyQt5.QtCore import pyqtSlot, QVariant, pyqtSignal
from PyQt5.QtQml import QQmlListProperty, QQmlComponent

from DBItems import *
from DB_Worker import *


class Welcome(QObject):
    addTable = pyqtSignal(str)
    showError = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._exist_bd = TablesManager().tables

    @pyqtProperty('QStringList')
    def exist_bd(self):
        return self._exist_bd

    @pyqtSlot(str)
    def add_item(self, name:str):
        name = name.lower()
        if ' ' in name:
            self.showError.emit("Name contains spacing")
        for i in self._exist_bd:
            if i == name:
                self.showError.emit("already exist")
                return
        if not TablesManager().add_item(name):
            self.showError.emit("unknown error")
            return
        self.addTable.emit(name)




