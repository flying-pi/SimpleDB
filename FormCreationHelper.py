from PyQt5.QtCore import QObject, pyqtSlot


class FormCreationHelper(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(str, str, result=str)
    def save_sql_to_file(self, name, request) -> str:
        filename = f"./{name}.sql"
        file = open(filename, 'w')
        file.write(request)
        file.close()
        return filename

    @pyqtSlot(str, result=str)
    def get_source_for_component(self, type) -> str:
        if type == "table":
            path = './qml/ControlElementTable.qml'
        elif type == "mainWindow":
            path = './qml/ControlElementMainWindow.qml'
        else:
            return ""
        file = open(path, "r")
        result = file.read()
        return result

    @pyqtSlot(str)
    def seave_generated_source(self,source):
        file = open("./qml/generated.qml", 'w')
        file.write(source)
        file.close()
