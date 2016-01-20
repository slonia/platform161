Platform161
================
Notes
-----------
* Test app should use campaigns 2108960, 2108961, 2108962, 2109230 but AdvertiserReports API has no data for them. So I've used this ids to retrieve data in top report section, but tables and charts are rendered from AdvertiserReports data for all campaigns/creatives.
* PDF report is generate after report creation, and it can take time. In real-life app it's better to use background jobs (Sidekiq for example).
* App consist of two parts: website itself and api (see API section below)

Setup
-----------
To start application you should run following commands:

```
cd platform161
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml
```

Edit this files and then:

```
bundle install
rake db:setup
rails s
```
Now you can login at [http://localhost:3000/](http://localhost:3000/) with email and password from *secrets.yml*

API
-------------
To access api you should add auth_token to each request. auth_token is generated per-user and is stores as user.authentication_token.

Available requests:
* GET /api/reports.json
* GET /api/reports/:ID.json
* POST /api/reports with ***campaign_id*** param


Ruby on Rails
-------------

This application uses:

- Ruby 2.2.0
- Rails 4.2.5

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).
