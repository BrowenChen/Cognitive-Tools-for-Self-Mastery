

Sample App Deployed At:
https://ancient-river-53152.herokuapp.com/

Admin account:
Email: falklieder@gmail.com
Password: password
Username: Admin

1. Open the repo.
2. Deploy to heroku: heroku push
3. Heroku run rake db:migrate.
4. heroku ps:scale web=1  (Scale a web dyno)
5. Create an account with “Admin” as the username (!Important)
    a) Username "Admin" is how enable_admin function looks up the correct Admin account
6. Once logged in as Admin, hit the /enable_admin/9128 route first.
    a) In production, deployed on Heroku, this may lead to an "Application Crash" page,
        but just refresh the main page and the activities should be populated with the todo.csv
7. Subsequent users can now initialize their to-do lists via “Initialize todo list” Button.

You can swap out the csv files in the code for points and activities (search up the .csv strings in the code)
