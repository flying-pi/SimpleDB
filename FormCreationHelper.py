import glob
import os
from shutil import copyfile

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
        file.close()
        return result

    @pyqtSlot(str)
    def seave_generated_source(self, source):
        file = open("./qml/generated.qml", 'w')
        file.write(source)
        file.close()

    @pyqtSlot(str, str)
    def save_as_project(self, file_path: str, source: str):
        file_path = file_path.replace("file://", "")

        qml_file = file_path + "/main.qml"
        file = open(qml_file, 'w')
        file.write(source)
        file.close()

        copyfile("./Program.py", file_path + "/Program.py")
        copyfile("./FormBackend.py", file_path + "/FormBackend.py")
        copyfile("./DB_Utils.py", file_path + "/DB_Utils.py")

        files = ''
        os.chdir("./")
        for file in glob.glob("*.sql"):
            files += '\'' + file + '\''
            files += ', '
            copyfile("./"+file, file_path + "/"+file)
        setup_file = """

import sys

from setuptools import setup

sys.setrecursionlimit(5000)

APP = ['Program.py']
DATA_FILES = [""" + files + """ 'main.qml' ]
OPTIONS = {}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)

"""
        print(setup_file)

        file = open(file_path + "/setup.py", 'w')
        file.write(setup_file)
        file.close()

        from subprocess import call
        call("/Library/Frameworks/Python.framework/Versions/3.6/bin/python3   setup.py py2app", cwd=file_path,
             shell=True)
