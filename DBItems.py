from enum import Enum

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSlot


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
        self._columnData = []
        self._columnsInfo = []

    @pyqtSlot(int, str)
    def add_column(self, type, name):
        self._column_count += 1
        self._columnsInfo.append((type, name))
        for i in range(self._row_count):
            self._columnData[i].append("")

    @pyqtSlot()
    def add_row(self):
        self._row_count += 1
        self._columnData.append(["" for _ in range(self._column_count)])

    @pyqtSlot(int, str, result=str)
    def item_data(self, row, role: str):
        if len(role) == 0:
            role = '0'
        return self._columnData[row][int(role)]

    @pyqtSlot(int, str, str)
    def set_data(self, row, role, data):
        if len(role) == 0:
            role = '0'
        self._columnData[row][int(role)] = str(data)
