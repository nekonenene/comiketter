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
	bundle exec spring stop
	bundle exec foreman start

.PHONY: db-migrate
db-migrate:
	bundle exec rake ridgepole:apply

.PHONY: db-migrate-dry-run
db-migrate-dry-run:
	bundle exec rake ridgepole:dry_run

.PHONY: db-reset
db-reset:
	bundle exec rake ridgepole:reset

.PHONY: update-schemafile
update-schemafile:
	bundle exec rake ridgepole:export
