from PyQt5.QtCore import QObject, pyqtSlot


class FormBackend(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

