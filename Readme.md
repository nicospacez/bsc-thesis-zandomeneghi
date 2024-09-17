## First spin up the containers
```
docker compose up -d
```
Run ./scripts/schema.sql in pgadmin sql Query Tool

## Download example data
https://drive.google.com/drive/folders/15l8o2wnB7qlo56zIxwDbFw2IT783QfBG?usp=sharing

Add this to downloaded folder to ./data

## Install dependencies
```
pip install -r requirements.txt         
```
## Run insert script
```
cd scripts && python insert_data.py
```

