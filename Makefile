.PHONY: init
init:
	cp dotenv.dist .env
	npm install
	gem install bundler
	bundle install
	bundle exec rails tmp:create
	mkdir -p log
	bundle exec rails log:clear

.PHONY: run
run:
	bundle exec foreman start

.PHONY: db-migrate
db-migrate:
	bundle exec rake db:migrate

.PHONY: db-reset
db-reset:
	bundle exec rake db:migrate:reset
