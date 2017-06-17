from enum import Enum

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSlot, QVariant

INDEX_COLUMN_NAME = '#'


class ColumnType(Enum):
    number = 0
    string = 1
    picture = 2
    util_item = 100


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
    def __init__(self, parent=None, name: str = ''):
        super().__init__(parent)
        from DB_Worker import Table
        self._table = Table(name)
        self._name = name
        self._column_count = self._table.fields_count()
        self._row_count, self._item_data = self._table.select_all()
        self._columns_info = self.get_column_info()

    def get_column_info(self):
        result = [(ColumnType.util_item, '#')]
        for i in range(1, self._column_count):
            column_type = ColumnType.util_item
            if self._table.field_type(i) == QVariant.Double:
                column_type = ColumnType.number
            elif self._table.field_type(i) == QVariant.String:
                column_type = ColumnType.string
            elif self._table.field_type(i) == QVariant.BitArray:
                column_type = ColumnType.picture
            result.append((column_type, self._table.field_name(i)))
        return result

    @pyqtSlot(int, str)
    def add_column(self, type, name):
        column_type = ColumnType(type)
        if self._table.add_new_field(name, column_type):
            self._column_count += 1
            self._columns_info.append((column_type, name))
            for i in range(self._row_count):
                self._item_data[i].append("")
        else:
            print("some error")  # todo show error

    @pyqtSlot()
    def add_row(self):
        status, id_value = self._table.add_empty_record()
        if status:
            self._row_count += 1
            new_row = ["" for _ in range(self._column_count)]
            new_row.insert(0, str(id_value))
            self._item_data.append(new_row)
        else:
            print("some error")  # todo show error

    @pyqtSlot(int, str, result=str)
    def item_data(self, row, role: str):
        if len(role) == 0:
            role = '0'
        return self._item_data[row][int(role)]

    @pyqtSlot(int, str, str)
    def set_data(self, row, role, data):  # todo check for type
        if len(role) == 0:
            role = '0'
        column = int(role)
        if self._table.update(self._item_data[row][0], self._columns_info[column][1],
                              self._columns_info[column][0], data):
            self._item_data[row][column] = str(data)
        else:
            print("show error ")

    @pyqtSlot(result=int)
    def get_row_count(self):
        return self._row_count

    @pyqtSlot(result=int)
    def get_column_count(self):
        return self._column_count

    @pyqtSlot(int, result=str)
    def get_column_name(self, position):
        if position == 0:
            return INDEX_COLUMN_NAME
        return self._columns_info[position][1]

    @pyqtSlot(str, result=bool)
    def is_readonly(self, role_name) -> bool:
        column = int(role_name)
        if column < self._column_count:
            return self._columns_info[column][0] == ColumnType.util_item
        return True


class TableEditModelCreator(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(str, result=TableEditModel)
    def get_table_editor(self, name: str) -> TableEditModel:
        return TableEditModel(self, name)
