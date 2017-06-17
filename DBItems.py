from enum import Enum

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSlot, QVariant


class ColumnType(Enum):
    number = 0
    string = 1
    picture = 2


ColumnTypeNames = ["Number", "String", "Picture"]


class DBInfoView(QObject):
    def __init__(self, name, parent=None):
        super().__init__(parent)
        self._name = name

    @pyqtProperty('QString')
    def name(self):
        return self._name


class ColumnInfo(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtProperty('QStringList')
    def column_types(self):
        return ColumnTypeNames


class TableEditModel(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._column_count = 0
        self._row_count = 0
        self.columnData = [[]]

    @pyqtSlot()
    def add_column(self):
        self._column_count += 1

    @pyqtSlot()
    def add_row(self):
        self._row_count += 1

    @pyqtSlot(QVariant, QVariant, result=str)
    def item_data(self, row, role):
        return "row " + str(row) + role
