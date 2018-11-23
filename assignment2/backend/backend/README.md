# How to get started using the development API

Here are three ways to run the backend.

1. At CSE (only) you can use a version of Python from the 2041 class account which has appropriate packages installed.
It is the simplest way to run the backend but won't work on your own computer:

```bash
cd backend
2041 python3.6.3 run.py
```

2. At CSE and an your own computer, you can use virtual env to create a space in which the backend can run without
clashing with any other python packages and issues on your local account. 

On your own computer /usr/bin/python3 might need to be replaced by another path, e.g. /usr/local/bin/python3

And you will need python 3.6 or 3.7 on your own computer - python 3.5 or earlier will not work.

```bash
cd backend
# create a sandbox for the backend
virtualenv -p /usr/bin/python3 env
# enter sandbox
source env/bin/activate
# set up sandbox
pip install -r requirements.txt
# run backend! Will run on port 5000.
# go to http://127.0.0.1:5000/ to see the docs!
python run.py
```

Once you are done working on the assignment run the following
command to exit the sandbox

```bash
deactivate
```

3. At CSE and an your own computer, you can just install the necessary packages.  This risks breaking other application which uses other versions of these packages (you will need  python 3.6 or 3.7)

```bash
cd backend
# on your local system this may just be pip and python
pip3 install -r requirements.txt
python3 run.py
```
