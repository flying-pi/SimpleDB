from PyQt5.QtSql import QSqlDatabase


def open_bd() -> QSqlDatabase:
    db = QSqlDatabase.addDatabase("QPSQL")
    db.setHostName("localhost")
    db.setDatabaseName("postgres")
    open_result = db.open()
    if not open_result:
        print("Can not open database :: ", db.lastError())
        raise Exception("can not open database")
    else:
        print("DB opened")
    return db
