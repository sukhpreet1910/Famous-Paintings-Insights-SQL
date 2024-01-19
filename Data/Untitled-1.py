import pandas as pd 
from sqlalchemy import create_engine

# Replace 'your_username' and 'your_password' with your actual PostgreSQL username and password
username = 'sukh'
password = 'sukh'
host = 'localhost'
database = 'paintings'

# Use double quotes around the password to handle special characters
conn_string = f'postgresql://{username}:"{password}"@{host}/{database}'

db = create_engine(conn_string)
conn = db.connect()



df = pd.read_csv('/Users/sukhsodhi/Desktop/DS_DA/SQL/Projects/famousPaintings/Data/artist.csv')
print(df.info)