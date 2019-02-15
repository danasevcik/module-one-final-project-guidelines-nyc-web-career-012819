# Shake Shack Finder project brief intro

##Dana and Nate(kyung1)'s module 1 final project.

*AN APP FOR SHAKE SHACK LOVERS*

Purpose of this memo help us remember some issues we had, how this project works, and features we developed.


### Project

1. Sqlite3 with ActiveRecord
2. Use API (Yelp)
  **Yelp** [Yelp Developer](https://www.yelp.com/developers?country=US)
3. CLI interface

### Features & How it works

1. Lets users select their favorite Shake Shacks.
  * lets users check if the restaurant is open.
  * lets users delete one of the favorites Shake Shacks.
2. Lets users find near by Shake Shacks by either zip_code or city.
  * lets users save to their favorites list.

3. Lets users delete their accounts.

4. API_KEY is hidden (git ignore).

### Issues

1. Since this project is Shake Shack specific and the restaurant are not as many as coffee shops, it was easier to locate restaurants by city name.

2. Even if we explicitly told our program to return Shake Shacks only, it always returns other restaurants too. We believe it is Yelp's API that designed to return at least something similar.

  * Ex) Searching API by city name, 'New York' also returns 'Brooklyn', 'Queens', and other near by cities in 'NY' state.

3. ...

---
