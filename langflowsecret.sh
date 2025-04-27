oc create secret generic postgres-azure-secret \
  --from-literal=POSTGRES_USER="myAdmin@microsweeper-30d70f389agbbpwd" \
  --from-literal=POSTGRES_PASSWORD="adminUserGBB-30d70f389agbbpwd" \
  --from-literal=POSTGRES_DB="postgres" \
  --from-literal=POSTGRES_HOST="microsweeper-30d70f389agbbpwd.postgres.database.azure.com" \
  --from-literal=LANGFLOW_DATABASE_URL="postgresql://myAdmin@microsweeper-30d70f389agbbpwd:adminUserGBB-30d70f389agbbpwd@microsweeper-30d70f389agbbpwd.postgres.database.azure.com/postgres?sslmode=require"
