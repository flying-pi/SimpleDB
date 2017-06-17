from typing import Tuple, List

from PyQt5.QtSql import QSqlDatabase, QSqlQuery, QSqlTableModel, QSqlField

from DBItems import *


def contains_table(db: QSqlDatabase, table_name: str) -> bool:
    tables = db.tables()
    for i in tables:
        if i == table_name:
            return True
    return False


def make_request(request: str) -> Tuple[bool, QSqlQuery]:
    print("Execution request: ", request)
    query = QSqlQuery()
    create_table_result = query.exec(request)
    if not create_table_result:
        print("error when execution request; ", "request :: ", request, " error :: ",
              query.lastError().databaseText())
        return False, query
    return True, query


def sql_column_type_name(column_type: ColumnType) -> Tuple[bool, str]:
    if column_type == ColumnType.number:
        return True, "real"
    if column_type == ColumnType.string:
        return True, "text"
    if column_type == ColumnType.picture:
        return True, "bytea"
    return False, "text"


class SingletonTM(type):
    def __init__(cls, name, bases, attrs, **kwargs):
        super().__init__(name, bases, attrs)
        cls._instance = None

    def __call__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__call__(*args, **kwargs)
        return cls._instance


class TablesManager(metaclass=SingletonTM):
    TABLE_NAME = "simple_db_tables_names"

    def __init__(self) -> None:
        self._parent_db = self.open_bd()
        super().__init__()
        if not contains_table(self._parent_db, self.TABLE_NAME):
            self.create_table()
        self._tables = self.load_all_tables()

    def open_bd(self) -> QSqlDatabase:
        db = QSqlDatabase.addDatabase("QPSQL")
        db.setHostName("localhost")
        db.setDatabaseName("postgres")
        open_result = db.open()
        if not open_result:
            print("Can not open database :: ", db.lastError())
            raise Exception("can not open database")
        else:
            print("DB opened")
        global table_manager
        return db

    def create_table(self):
        make_request(f'CREATE TABLE {self.TABLE_NAME}  (id SERIAL, name varchar UNIQUE );')

    def load_all_tables(self) -> List[str]:
        query_result = make_request(f'SELECT t.name FROM {self.TABLE_NAME} t ;')
        if not query_result[0]:
            return []
        result = []
        while query_result[1].next():
            result.append(query_result[1].value(0))
        return result

    @property
    def tables(self) -> List[str]:
        return self._tables

    @property
    def database(self) -> QSqlDatabase:
        return self._parent_db

    def add_item(self, name) -> bool:
        query_result = make_request(f"INSERT INTO {self.TABLE_NAME}(name) VALUES ('{name}');")
        if query_result[0]:
            make_request(f'CREATE TABLE {name}  (id SERIAL);')

        return query_result[0]


class Table:
    def __init__(self, name: str) -> None:
        super().__init__()
        self._name = name
        self._parent_db = TablesManager().database
        self._filed_info = self.load_table_info()

    def load_table_info(self) -> List[QSqlField]:
        table_info = QSqlTableModel(None, self._parent_db)
        table_info.setTable(self._name)
        record = table_info.record()
        return [record.field(i) for i in range(record.count())]

    def add_new_field(self, name: str, field_type: ColumnType) -> bool:
        result, field_type = sql_column_type_name(field_type)
        if not result:
            return False
        result, _ = make_request(f'ALTER TABLE {self._name}  ADD COLUMN {name} {field_type};')
        self._filed_info = self.load_table_info()
        return result

    def field_name(self, pos: int) -> str:
        if pos < len(self._filed_info):
            return self._filed_info[pos].name()
        return ''

    def field_type(self, pos: int) -> int:
        if pos < len(self._filed_info):
            return self._filed_info[pos].type()
        return -1

    def fields_count(self):
        return len(self._filed_info)

    def add_empty_record(self) -> Tuple[bool, int]:
        status, result = make_request(f'INSERT INTO {self._name}(id) VALUES (DEFAULT);')
        if not status:
            return False, -1
        return True, result.lastInsertId()

    def update(self, id: int, column_name: str, column_type: ColumnType, value):
        if column_type == ColumnType.string:
            value = "'" + value + "'"
        status, _ = make_request(f'UPDATE {self._name} SET {column_name} = {value} WHERE id = {id};')
        return status

    def select_all(self) -> (int, List[List[str]]):
        status, sql_data = make_request(f'SELECT * FROM {self._name} ;')
        if not status:
            return 0, []
        result = []
        fields_count = len(self._filed_info)
        rows = 0
        while sql_data.next():
            rows += 1
            result.append([str(sql_data.value(i)) for i in range(fields_count)])
        return rows, result
