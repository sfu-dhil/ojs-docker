#!/bin/sh

echo "[CLI Install Journal] Start Journal setup!"
cookie_jar_file=admin_script_cookie.txt
touch $cookie_jar_file

echo "[CLI Install Journal] Login as Admin"
csrf_token="$(curl --silent --show-error --fail -L $BASE_URL/index/login | tr -d '\n' | sed -r -e 's/^.*name="csrfToken" value="([a-zA-Z0-9_]+)".*$/\1/g')"
# echo "$BASE_URL/index/login csrf_token: $csrf_token"

curl -o /dev/null --silent --show-error --fail -L -X POST "$BASE_URL/index/login/signIn" \
    --cookie $cookie_jar_file --cookie-jar $cookie_jar_file \
    -d csrfToken="$csrf_token" \
    -d source="" \
    -d username="admin" \
    -d password="$ADMIN_PASSWORD" \
    -d remember="1"

echo "[CLI Install Journal] Disable notifications for admin"
csrf_token="$(curl --silent --show-error --fail -L $BASE_URL/index/user/profile --cookie $cookie_jar_file --cookie-jar $cookie_jar_file | tr -d '\n' | sed -r -e 's/^.*"csrfToken":"([a-zA-Z0-9_]+)".*$/\1/g')"
# echo "$BASE_URL/index/user/profile csrf_token: $csrf_token"

curl -o /dev/null --silent --show-error --fail -L -X POST "$BASE_URL/index/\$\$\$call\$\$\$/tab/user/profile-tab/save-notification-settings" \
    --cookie $cookie_jar_file --cookie-jar $cookie_jar_file \
    -d csrfToken="$csrf_token" \
    -d submitFormButton=""

echo "[CLI Install Journal] Generate API key to admin"
csrf_token="$(curl --silent --show-error --fail -L $BASE_URL/index/user/profile --cookie $cookie_jar_file --cookie-jar $cookie_jar_file | tr -d '\n' | sed -r -e 's/^.*"csrfToken":"([a-zA-Z0-9_]+)".*$/\1/g')"
# echo "$BASE_URL/index/user/profile csrf_token: $csrf_token"

curl -o /dev/null --silent --show-error --fail -L -X POST "$BASE_URL/index/\$\$\$call\$\$\$/tab/user/profile-tab/save-a-p-i-profile" \
    --cookie $cookie_jar_file --cookie-jar $cookie_jar_file \
    -d csrfToken="$csrf_token" \
    -d apiKey="None" \
    -d apiKeyAction="1"

echo "[CLI Install Journal] Get generated API key"
api_token="$(curl --silent --show-error --fail -L $BASE_URL/index/\$\$\$call\$\$\$/tab/user/profile-tab/api-profile --cookie $cookie_jar_file --cookie-jar $cookie_jar_file | sed -E 's,\\t|\\r|\\n,,g' | sed -r -e 's/^.*name=\\"apiKey\\"value=\\"([^\\]+)\\".*$/\1/g')"
# echo "$BASE_URL/index/\$\$\$call\$\$\$/tab/user/profile-tab/api-profile api_token: $api_token"

echo "[CLI Install Journal] Create Journal via API"
curl -o /dev/null --silent --show-error --fail -L -X POST "$BASE_URL/index/api/v1/contexts" \
    -H "Authorization: Bearer $api_token" \
    -H "Content-Type: application/json" \
    -d "{ \"name\": { \"en\": \"$JOURNAL_NAME\" }, \"acronym\": { \"en\": \"$JOURNAL_ACRONYM\" }, \"contactName\": \"$CONTACT_NAME\", \"contactEmail\": \"$CONTACT_EMAIL\", \"country\": \"CA\", \"urlPath\": \"$JOURNAL_ACRONYM\", \"enabled\": true }"


echo "[CLI Install Journal] Edit Site Info via API"
curl -o /dev/null --silent --show-error --fail -L -X PUT "$BASE_URL/index/api/v1/site" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        -d "{ \"title\": { \"en\": \"$SITE_TITLE\" }, \"contactName\": { \"en\": \"$CONTACT_NAME\" }, \"contactEmail\": { \"en\": \"$CONTACT_EMAIL\" } }"

echo "[CLI Install Journal] DONE!"
rm $cookie_jar_file