from PyQt5.QtSql import QSqlDatabase, QSqlQuery


def open_bd():
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
    TableManager(db)
    print("heh")


def contains_table(db: QSqlDatabase, table_name: str) -> bool:
    tables = db.tables()
    for i in tables:
        if i == table_name:
            return True
    return False


class SingletonTM(type):
    """
    Define an Instance operation that lets clients access its unique
    instance.
    """

    def __init__(cls, name, bases, attrs, **kwargs):
        super().__init__(name, bases, attrs)
        cls._instance = None

    def __call__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__call__(*args, **kwargs)
        return cls._instance


class TableManager(metaclass=SingletonTM):
    TABLE_NAME = "simple_db_tables_names"

    def __init__(self, parent_db: QSqlDatabase) -> None:
        super().__init__()
        if not contains_table(parent_db, self.TABLE_NAME):
            self.create_table()
        self._tables = self.load_all_tables()

    def _make_request(self, request: str) -> (bool, QSqlQuery):
        print("Execution request: ", request)
        query = QSqlQuery()
        create_table_result = query.exec(request)
        if not create_table_result:
            print("error when execution request; ", "request :: ", request, " error :: ",
                  query.lastError().databaseText())
            return False, query
        return True, query

    def create_table(self):
        self._make_request('CREATE TABLE {s.TABLE_NAME}  (id SERIAL, name varchar UNIQUE );'.format(s=self))

    def load_all_tables(self):
        query_result = self._make_request(f'SELECT t.name FROM {self.TABLE_NAME} t ;')
        if not query_result[0]:
            return []
        result = []
        while query_result[1].next():
            result.append(query_result[1].value(0))
        return result

    @property
    def tables(self):
        return self._tables

    def add_item(self, name) -> bool:
        query_result = self._make_request(f"INSERT INTO {self.TABLE_NAME}(name) VALUES ('{name}');")
        return query_result[0]
