
# Run scheduler
while [ true ]
do
  /usr/local/bin/php /app/artisan schedule:run --verbose --no-interaction
  sleep 60
done

exec "$@"