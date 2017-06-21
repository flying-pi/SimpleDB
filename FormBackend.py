import abc

from PyQt5.QtCore import QObject, pyqtProperty, Qt, QMetaObject, pyqtSlot, QVariant
from PyQt5.QtQml import QJSValue, QQmlProperty
from PyQt5.QtSql import QSqlQuery

from DB_Utils import open_bd

INIT_TRIGGER_NAME = "Init"


class DataSet(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def __init__(self, caller_name="") -> None:
        super().__init__()

    @abc.abstractmethod
    def value(self):
        """Calling for getting data in set"""

    @abc.abstractmethod
    def clone(self, caller_name=""):
        """return new data set with same rule but with """


class MockDataSet(DataSet):
    def value(self):
        return []

    def clone(self, caller_name=""):
        return self

    def __init__(self, caller_name="") -> None:
        pass


class Element:
    def __init__(self, el: QJSValue) -> None:
        super().__init__()
        self.name = el.property("name").toString()
        self.eID = el.property("eID").toInt()
        self.programs = el.property("program").toString()
        self.read_ui(el)

    def read_ui(self, el: QJSValue):
        ui_property = el.property("ui")
        self.ui_object = ui_property.toQObject()
        self.objectName = QQmlProperty(self.ui_object, "objectName").read()
        self.update_function = QQmlProperty(self.ui_object, "update").method()

    def call_ui_update(self):
        print("in call_ui_update")
        QMetaObject.invokeMethod(self.ui_object, "update", Qt.DirectConnection)
        print("out from call_ui_update")


class SqlRequest(DataSet):
    def __init__(self, proto=None, caller_name="") -> None:
        super().__init__()
        if proto is not None:
            self.name = proto.name
            self.raw_sql = proto.raw_sql
        else:
            self.name = ""
            self.raw_sql = ""
        self.caller_name = caller_name
        self._data = []

    def _make_request(self):
        if len(self.raw_sql) == 0:
            self._data = []
            return
        query = QSqlQuery()
        query_result = query.exec(self.raw_sql)
        if not query_result:
            print("error when execution request; ", "request :: ", self.raw_sql, " error :: ",
                  query.lastError().databaseText())
            self._data = []
            return
        self._data.clear()
        record_size = query.record().count()
        while query.next():
            new_row = {}
            for i in range(record_size):
                new_row[str(i)] = query.value(i)
            self._data.append(new_row)

    def value(self):
        return self._data

    def clone(self, caller_name=""):
        result = SqlRequest(proto=self, caller_name=caller_name)
        result._make_request()
        return result


def load_request(path: str) -> str:
    file = open(path, "r")
    result = file.read()
    file.close()
    return result


def parse_sql_request(req: QJSValue) -> SqlRequest:
    result = SqlRequest()
    result.name = req.property("name").toString()
    result.raw_sql = load_request(req.property("body").toString())
    result.caller_name = ""
    return result


class FormBackend(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.db = open_bd()
        self._json_requests = None
        self._json_elements = None
        self._datasets = [MockDataSet()]
        self._elements = {}
        self._data_sets_map = {'mock': 0}
        self._program_map = {}
        self._data_set_by_eID = {}

    @pyqtProperty(QJSValue)
    def requests(self):
        return self._json_requests

    @requests.setter
    def requests(self, items: QJSValue):
        self._json_requests = items
        size = items.property("length").toInt()
        for i in range(size):
            request = parse_sql_request(items.property(i))
            self._datasets.append(request)
            self._data_sets_map[request.name] = len(self._datasets) - 1
        self._processing_form()

    @pyqtProperty(QJSValue)
    def elements(self):
        return self._json_elements

    @elements.setter
    def elements(self, items: QJSValue):
        self._json_elements = items
        size = items.property("length").toInt()
        for i in range(size):
            element = Element(items.property(i))
            self._elements[element.eID] = element
        self._processing_form()

    @pyqtSlot(int, result=QVariant)
    def updateData(self, eID):
        data = self._datasets[self._data_set_by_eID[eID]].value()
        data_str = str(data).replace("\\\\", "").replace("'", '"')
        print("drrr")
        return data

    def _processing_form(self):
        if self._json_elements is None or self._json_requests is None:
            return
        element_count = len(self._elements)
        for i in range(element_count):
            self._compile_program(self._elements[i])
        if INIT_TRIGGER_NAME in self._program_map:
            for programs in self._program_map[INIT_TRIGGER_NAME]:
                for (arg, command) in programs:
                    command(**arg)
        print("heh)")

    def _get_dataset_for_name(self, name: str, el: Element = None):
        if el is not None:
            if f'{el.name}.{name}' in self._data_sets_map:
                return self._data_sets_map[f'{el.name}.{name}']
        if name in self._data_sets_map:
            return self._data_sets_map[name]

        result = len(self._datasets)
        self._datasets.append(MockDataSet())
        var_name = name
        if el is not None:
            var_name = f'{el.name}.{name}'
        self._data_sets_map[var_name] = result
        return result

    def assignment_action(self, left=0, right=0):
        self._datasets[left] = self._datasets[right].clone()

    def _compile_program(self, el: Element):
        last_trigger = None
        command_buffer = None
        program_lines = el.programs.split('\n')

        def try_add_block():
            if last_trigger is not None:
                command_buffer.append(({}, el.call_ui_update))
                if last_trigger not in self._program_map:
                    self._program_map[last_trigger] = []
                self._program_map[last_trigger].append(command_buffer)

        for l in program_lines:
            line = l.strip()
            if line.endswith(':'):
                try_add_block()
                command_buffer = []
                last_trigger = line.replace(':', '')
                continue
            if command_buffer is None:
                continue
            if "=" in line:
                puts = line.split("=")
                if len(puts) != 2:
                    continue
                left = self._get_dataset_for_name(puts[0], el)
                right = self._get_dataset_for_name(puts[1])
                command_buffer.append(({'left': left, 'right': right}, self.assignment_action))
        try_add_block()
        element_data_set = self._get_dataset_for_name(el.name + ".value")
        self._data_set_by_eID[el.eID] = element_data_set
