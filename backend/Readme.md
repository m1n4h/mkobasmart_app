cd backend
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
pip install setuptools


# run migration
python3 manage.py makemigrations 
python3 manage.py migrate

# create superuser
python3 manage.py createsuperuser

# run server
python3 manage.py runserver


