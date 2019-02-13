.PHONY: install build

install:
	./run -e -c
build:
	rm -rf dist build; pip3 install pyinstaller && pip3 install -r requirements.txt && python3 -m PyInstaller --onefile install.py && cp dist/install ./run && rm -rf dist build install.spec

