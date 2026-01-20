#!/usr/bin/env python3
import os
import sys
import json
from pathlib import Path
from datetime import datetime
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QTextEdit, QFileDialog,
    QProgressBar, QFrame, QSpacerItem, QSizePolicy
)
from PyQt6.QtCore import Qt, QThread, pyqtSignal, QTimer
from PyQt6.QtGui import QFont, QPixmap, QIcon, QPalette

# Import the downloader logic
import re
import requests
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor, as_completed


class DownloadWorker(QThread):
    progress = pyqtSignal(int, int)  # current, total
    log = pyqtSignal(str)
    finished = pyqtSignal(dict)

    def __init__(self, root_dir, max_workers=5):
        super().__init__()
        self.root_dir = root_dir
        self.max_workers = max_workers
        self.backup_file = os.path.join(root_dir, '.imgur_backup.json')
        self.backup_data = {}

    def find_imgur_links(self, content):
        # Fixed pattern - only matches valid https://i.imgur.com links
        pattern = r'https?://i\.imgur\.com/[a-zA-Z0-9]+\.[a-zA-Z]+'
        return re.findall(pattern, content)

    def download_image(self, url, save_path):
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
            }
            response = requests.get(url, headers=headers, timeout=15, stream=True)
            response.raise_for_status()

            total_size = int(response.headers.get('content-length', 0))

            with open(save_path, 'wb') as f:
                if total_size == 0:
                    f.write(response.content)
                else:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)

            return True, None
        except Exception as e:
            return False, str(e)

    def save_backup(self):
        try:
            with open(self.backup_file, 'w', encoding='utf-8') as f:
                json.dump(self.backup_data, f, indent=2)
            return True
        except Exception as e:
            self.log.emit(f"Failed to save backup: {e}")
            return False

    def process_markdown_file(self, md_file):
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                original_content = f.read()
        except Exception as e:
            return {
                'file': md_file,
                'status': 'error',
                'message': f"Error reading file: {e}"
            }

        imgur_links = self.find_imgur_links(original_content)

        if not imgur_links:
            return {
                'file': md_file,
                'status': 'skipped',
                'message': 'No imgur links found'
            }

        md_dir = os.path.dirname(md_file)
        downloaded_images = []
        updated_content = original_content
        download_tasks = []

        for url in imgur_links:
            parsed = urlparse(url)
            filename = os.path.basename(parsed.path)
            save_path = os.path.join(md_dir, filename)

            if not os.path.exists(save_path):
                download_tasks.append((url, save_path, filename))
            else:
                updated_content = updated_content.replace(url, filename)

        downloaded = 0
        failed = 0

        if download_tasks:
            with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
                future_to_task = {
                    executor.submit(self.download_image, url, save_path): (url, save_path, filename)
                    for url, save_path, filename in download_tasks
                }

                for future in as_completed(future_to_task):
                    url, save_path, filename = future_to_task[future]
                    success, error = future.result()

                    if success:
                        downloaded += 1
                        downloaded_images.append(filename)
                        updated_content = updated_content.replace(url, filename)
                        self.log.emit(f"✓ Downloaded: {filename}")
                    else:
                        failed += 1
                        self.log.emit(f"✗ Failed: {filename} - {error}")

        if updated_content != original_content:
            try:
                with open(md_file, 'w', encoding='utf-8') as f:
                    f.write(updated_content)

                self.backup_data['files'][md_file] = {
                    'original_content': original_content,
                    'downloaded_images': downloaded_images
                }
            except Exception as e:
                return {
                    'file': md_file,
                    'status': 'error',
                    'message': f"Error updating file: {e}"
                }

        return {
            'file': md_file,
            'status': 'success',
            'total_links': len(imgur_links),
            'downloaded': downloaded,
            'failed': failed,
            'skipped': len(imgur_links) - downloaded - failed
        }

    def run(self):
        root_path = Path(self.root_dir)
        md_files = list(root_path.rglob('*.md'))

        if not md_files:
            self.log.emit("No markdown files found in directory")
            self.finished.emit({
                'success': 0,
                'skipped': 0,
                'errors': 0,
                'total_downloaded': 0,
                'total_failed': 0
            })
            return

        self.log.emit(f"Found {len(md_files)} markdown file(s)")
        self.log.emit(f"Using {self.max_workers} parallel workers\n")

        self.backup_data = {
            'timestamp': datetime.now().isoformat(),
            'root_dir': self.root_dir,
            'files': {}
        }

        results = {
            'success': 0,
            'skipped': 0,
            'errors': 0,
            'total_downloaded': 0,
            'total_failed': 0
        }

        for idx, md_file in enumerate(md_files):
            self.progress.emit(idx + 1, len(md_files))
            self.log.emit(f"\nProcessing: {os.path.basename(md_file)}")

            result = self.process_markdown_file(str(md_file))

            if result['status'] == 'success':
                results['success'] += 1
                results['total_downloaded'] += result['downloaded']
                results['total_failed'] += result['failed']
            elif result['status'] == 'skipped':
                results['skipped'] += 1
                self.log.emit("  No imgur links found")
            elif result['status'] == 'error':
                results['errors'] += 1
                self.log.emit(f"  Error: {result['message']}")

        if self.backup_data['files']:
            self.save_backup()
            self.log.emit(f"\n✓ Backup saved to: {self.backup_file}")

        self.finished.emit(results)


class RevertWorker(QThread):
    log = pyqtSignal(str)
    finished = pyqtSignal(bool)

    def __init__(self, root_dir):
        super().__init__()
        self.root_dir = root_dir
        self.backup_file = os.path.join(root_dir, '.imgur_backup.json')

    def load_backup(self):
        try:
            if os.path.exists(self.backup_file):
                with open(self.backup_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            return {}
        except Exception as e:
            self.log.emit(f"Failed to load backup: {e}")
            return {}

    def run(self):
        backup = self.load_backup()

        if not backup:
            self.log.emit("No backup file found!")
            self.finished.emit(False)
            return

        self.log.emit(f"Reverting changes from backup...")
        self.log.emit(f"Backup created: {backup.get('timestamp', 'Unknown')}\n")

        files = backup.get('files', {})
        if not files:
            self.log.emit("No files to revert!")
            self.finished.emit(False)
            return

        reverted = 0
        errors = 0

        for file_path, data in files.items():
            try:
                self.log.emit(f"Reverting: {os.path.basename(file_path)}")

                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(data['original_content'])

                md_dir = os.path.dirname(file_path)
                for img in data.get('downloaded_images', []):
                    img_path = os.path.join(md_dir, img)
                    if os.path.exists(img_path):
                        os.remove(img_path)
                        self.log.emit(f"  Removed: {img}")

                reverted += 1
            except Exception as e:
                self.log.emit(f"  Error: {e}")
                errors += 1

        self.log.emit(f"\n✓ Reverted {reverted} file(s)")
        if errors > 0:
            self.log.emit(f"✗ {errors} error(s) occurred")

        try:
            os.remove(self.backup_file)
            self.log.emit("✓ Backup file removed")
        except:
            pass

        self.finished.emit(True)


class ImgurDownloaderGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Imgur Image Downloader")
        self.setMinimumSize(800, 700)

        # Apply minimal styling that respects system theme
        palette = self.palette()

        self.setStyleSheet(f"""
            QLineEdit {{
                padding: 10px 15px;
                border: 1px solid palette(mid);
                border-radius: 16px;
                background-color: palette(base);
                font-size: 13px;
            }}
            QLineEdit:focus {{
                border: 1px solid palette(highlight);
            }}
            QLineEdit:read-only {{
                background-color: palette(window);
                color: palette(text);
            }}
            QPushButton {{
                padding: 10px 25px;
                border: 1px solid palette(mid);
                border-radius: 16px;
                background-color: palette(button);
                font-size: 13px;
                font-weight: 500;
            }}
            QPushButton:hover {{
                background-color: palette(light);
            }}
            QPushButton:pressed {{
                background-color: palette(mid);
            }}
            QPushButton:disabled {{
                background-color: palette(mid);
                color: palette(disabled-text);
            }}
            QTextEdit {{
                border: 1px solid palette(mid);
                border-radius: 16px;
                padding: 10px;
                background-color: palette(base);
                font-family: 'Monospace', 'Courier New';
                font-size: 12px;
            }}
            QProgressBar {{
                border: 1px solid palette(mid);
                border-radius: 16px;
                text-align: center;
                background-color: palette(base);
                height: 25px;
            }}
            QProgressBar::chunk {{
                background-color: palette(highlight);
                border-radius: 15px;
            }}
        """)

        self.init_ui()

    def init_ui(self):
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        # Main layout
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(40, 30, 40, 30)
        main_layout.setSpacing(20)

        # Header section
        header_layout = QVBoxLayout()
        header_layout.setSpacing(15)

        # Logo
        logo_label = QLabel()
        logo_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        logo_font = QFont()
        logo_font.setPointSize(48)
        logo_font.setBold(True)
        logo_label.setFont(logo_font)
        logo_label.setText("📥")
        header_layout.addWidget(logo_label)

        # Title
        title_label = QLabel("Imgur Image Ripper")
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_font = QFont()
        title_font.setPointSize(18)
        title_font.setBold(True)
        title_label.setFont(title_font)
        header_layout.addWidget(title_label)

        # Description - clarified for beginners
        desc_label = QLabel(
            "This tool automatically scans all markdown (.md) files in the selected folder and subfolders,\n"
            "finds Imgur image links, downloads those images, and updates the links to use local files.\n\n"
            "Simply point to your main posts folder — the tool will handle everything inside it.\n\n"
            "Example: Changes 'https://i.imgur.com/abc123.png' to just 'abc123.png'\n\n"
            "A backup is automatically created so you can undo changes if needed."
        )
        desc_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        desc_label.setWordWrap(True)
        desc_font = QFont()
        desc_font.setPointSize(10)
        desc_label.setFont(desc_font)
        header_layout.addWidget(desc_label)

        main_layout.addLayout(header_layout)

        # Separator line
        separator = QFrame()
        separator.setFrameShape(QFrame.Shape.HLine)
        separator.setFrameShadow(QFrame.Shadow.Sunken)
        main_layout.addWidget(separator)

        # Directory selection section
        dir_layout = QVBoxLayout()
        dir_layout.setSpacing(8)

        dir_label = QLabel("Posts Directory")
        dir_label_font = QFont()
        dir_label_font.setPointSize(11)
        dir_label_font.setBold(True)
        dir_label.setFont(dir_label_font)
        dir_layout.addWidget(dir_label)

        dir_input_layout = QHBoxLayout()
        dir_input_layout.setSpacing(10)

        self.path_input = QLineEdit()
        self.path_input.setReadOnly(True)  # Make it read-only
        self.path_input.setPlaceholderText("Click 'Browse' to select your posts folder...")
        dir_input_layout.addWidget(self.path_input)

        self.browse_btn = QPushButton("Browse")
        self.browse_btn.setFixedWidth(100)
        self.browse_btn.clicked.connect(self.browse_directory)
        dir_input_layout.addWidget(self.browse_btn)

        dir_layout.addLayout(dir_input_layout)
        main_layout.addLayout(dir_layout)

        # Action buttons
        button_layout = QHBoxLayout()
        button_layout.setSpacing(10)

        self.download_btn = QPushButton("Start Download")
        self.download_btn.clicked.connect(self.start_download)
        button_layout.addWidget(self.download_btn)

        self.revert_btn = QPushButton("Revert Changes")
        self.revert_btn.clicked.connect(self.revert_changes)
        button_layout.addWidget(self.revert_btn)

        main_layout.addLayout(button_layout)

        # Progress bar
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        main_layout.addWidget(self.progress_bar)

        # Log section
        log_label = QLabel("Activity Log")
        log_label_font = QFont()
        log_label_font.setPointSize(11)
        log_label_font.setBold(True)
        log_label.setFont(log_label_font)
        main_layout.addWidget(log_label)

        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setPlaceholderText("Activity will be logged here...")
        main_layout.addWidget(self.log_text)

        # Status bar
        self.statusBar().showMessage("Ready")

    def browse_directory(self):
        directory = QFileDialog.getExistingDirectory(
            self,
            "Select Posts Directory",
            os.path.expanduser("~")
        )
        if directory:
            self.path_input.setText(directory)
            self.log_message(f"Selected directory: {directory}")

    def log_message(self, message):
        self.log_text.append(message)

    def start_download(self):
        directory = self.path_input.text().strip()

        if not directory:
            self.log_message("⚠ Please select a directory first")
            return

        if not os.path.exists(directory):
            self.log_message("⚠ Directory does not exist")
            return

        # Disable buttons
        self.download_btn.setEnabled(False)
        self.revert_btn.setEnabled(False)
        self.browse_btn.setEnabled(False)

        # Clear log
        self.log_text.clear()
        self.log_message("Starting download process...\n")

        # Show progress bar
        self.progress_bar.setVisible(True)
        self.progress_bar.setValue(0)

        # Start worker thread
        self.worker = DownloadWorker(directory, max_workers=5)
        self.worker.progress.connect(self.update_progress)
        self.worker.log.connect(self.log_message)
        self.worker.finished.connect(self.download_finished)
        self.worker.start()

        self.statusBar().showMessage("Processing...")

    def update_progress(self, current, total):
        percentage = int((current / total) * 100)
        self.progress_bar.setValue(percentage)

    def download_finished(self, results):
        self.log_message("\n" + "="*50)
        self.log_message("SUMMARY")
        self.log_message("="*50)
        self.log_message(f"✓ Successfully processed: {results['success']}")
        self.log_message(f"⊝ Skipped (no links): {results['skipped']}")
        self.log_message(f"✗ Errors: {results['errors']}")
        self.log_message(f"↓ Total images downloaded: {results['total_downloaded']}")
        if results['total_failed'] > 0:
            self.log_message(f"⚠ Failed downloads: {results['total_failed']}")
        self.log_message("="*50)

        # Re-enable buttons
        self.download_btn.setEnabled(True)
        self.revert_btn.setEnabled(True)
        self.browse_btn.setEnabled(True)

        # Hide progress bar after a delay
        QTimer.singleShot(1000, lambda: self.progress_bar.setVisible(False))

        self.statusBar().showMessage("Download complete")

    def revert_changes(self):
        directory = self.path_input.text().strip()

        if not directory:
            self.log_message("⚠ Please select a directory first")
            return

        backup_file = os.path.join(directory, '.imgur_backup.json')
        if not os.path.exists(backup_file):
            self.log_message("⚠ No backup file found in selected directory")
            return

        # Disable buttons
        self.download_btn.setEnabled(False)
        self.revert_btn.setEnabled(False)
        self.browse_btn.setEnabled(False)

        # Clear log
        self.log_text.clear()
        self.log_message("Starting revert process...\n")

        # Start revert worker
        self.revert_worker = RevertWorker(directory)
        self.revert_worker.log.connect(self.log_message)
        self.revert_worker.finished.connect(self.revert_finished)
        self.revert_worker.start()

        self.statusBar().showMessage("Reverting changes...")

    def revert_finished(self, success):
        self.download_btn.setEnabled(True)
        self.revert_btn.setEnabled(True)
        self.browse_btn.setEnabled(True)

        if success:
            self.statusBar().showMessage("Revert complete")
        else:
            self.statusBar().showMessage("Revert failed")


def main():
    app = QApplication(sys.argv)

    window = ImgurDownloaderGUI()
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
