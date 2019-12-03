By Tuan Nguyen(ttn2256)

#### Project Installation:

Step 1: Make sure that mysql shell is installed in the terminal

Step 2: In the bash shell, navigate to the project folder

Step 3: Run the following command in the terminal to open mysql shell:

    mysql -u root -p
	
Step 4: In mysql shell, run the following command:

    source createDB.txt 
	
Now the database “TuanProject”, tables, triggers and stored procedures are created

Note: If you want to reset database and tables again, in the mysql shell, rerun the following command: 

    source createDB.txt
