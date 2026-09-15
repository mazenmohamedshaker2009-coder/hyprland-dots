#!/usr/bin/env python3

import sys

from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (
    QApplication,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class WifiPasswordDialog(QWidget):
    def __init__(self, ssid):
        super().__init__()

        self.ssid = ssid

        self.setWindowTitle("Connect to Wi-Fi")
        self.setFixedSize(380, 210)

        self.setWindowFlags(
            Qt.WindowType.WindowStaysOnTopHint
            | Qt.WindowType.FramelessWindowHint
            | Qt.WindowType.Dialog
        )

        self.setStyleSheet("""
            QWidget {
                background-color: #18181b;
                color: white;
                font-family: sans-serif;
                border-radius: 16px;
                border: 1px solid rgba(255, 255, 255, 0.15);
            }

            QLabel {
                border: none;
            }

            QLineEdit {
                background-color: rgba(255, 255, 255, 0.06);
                border: 1px solid #4F46E5;
                border-radius: 10px;
                padding: 0 12px;
                color: white;
                font-size: 14px;
            }

            QPushButton {
                background-color: #4F46E5;
                color: white;
                border-radius: 9px;
                font-weight: bold;
                font-size: 13px;
            }

            QPushButton#cancelBtn {
                background-color: rgba(255, 255, 255, 0.06);
                color: #aaaaaa;
            }
        """)

        layout = QVBoxLayout()
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(14)

        title = QLabel("Connect to Wi-Fi")
        title.setStyleSheet(
            "font-size: 18px; font-weight: bold;"
        )
        layout.addWidget(title)

        ssidLabel = QLabel(self.ssid)
        ssidLabel.setStyleSheet(
            "color: #888888; font-size: 13px;"
        )
        layout.addWidget(ssidLabel)

        self.passwordInput = QLineEdit()
        self.passwordInput.setPlaceholderText("Password")
        self.passwordInput.setEchoMode(
            QLineEdit.EchoMode.Password
        )
        self.passwordInput.setFixedHeight(42)
        self.passwordInput.returnPressed.connect(
            self.submitPassword
        )

        layout.addWidget(self.passwordInput)

        buttonLayout = QHBoxLayout()
        buttonLayout.addStretch()

        cancelButton = QPushButton("Cancel")
        cancelButton.setObjectName("cancelBtn")
        cancelButton.setFixedSize(85, 34)
        cancelButton.clicked.connect(self.cancel)

        buttonLayout.addWidget(cancelButton)

        connectButton = QPushButton("Connect")
        connectButton.setFixedSize(85, 34)
        connectButton.clicked.connect(
            self.submitPassword
        )

        buttonLayout.addWidget(connectButton)

        layout.addLayout(buttonLayout)

        self.setLayout(layout)

        screen = QApplication.primaryScreen().geometry()

        self.move(
            (screen.width() - self.width()) // 2,
            (screen.height() - self.height()) // 2
        )

    def showEvent(self, event):
        super().showEvent(event)
        self.passwordInput.setFocus()

    def submitPassword(self):
        password = self.passwordInput.text().strip()

        if not password:
            return

        sys.stdout.write(password)
        sys.stdout.flush()

        QApplication.exit(0)

    def cancel(self):
        QApplication.exit(1)


if __name__ == "__main__":
    app = QApplication(sys.argv)

    targetSsid = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "Unknown Network"
    )

    dialog = WifiPasswordDialog(targetSsid)
    dialog.show()

    sys.exit(app.exec())
