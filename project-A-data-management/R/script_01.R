install.packages(c("duckdb", "DBI"))
library(DBI); library(duckdb)

con <- dbConnect(duckdb(), dbdir = "D:/synthea/synthea.duckdb")
csv_dir <- "D:/synthea/output/csv"

tables <- c("patients", "encounters", "conditions",
            "observations", "medications", "procedures")

for (t in tables) {
  dbExecute(con, sprintf(
    "CREATE OR REPLACE TABLE %s AS SELECT * FROM read_csv_auto('%s/%s.csv')",
    t, csv_dir, t))
  message(t, " : ", dbGetQuery(con, sprintf("SELECT COUNT(*) n FROM %s", t))$n, " lignes")
}


# Premiers contrôles à faire (règle ③ de ton plan : vérifier, pas seulement produire)

# 1. Effectif : doit donner 11455 et 1455
dbGetQuery(con, "SELECT COUNT(*) AS n, COUNT(DEATHDATE) AS deces FROM patients")

# 2. Unicité de l'identifiant patient
dbGetQuery(con, "SELECT COUNT(DISTINCT Id) FROM patients")

# 3. Répartition par sexe
dbGetQuery(con, "SELECT GENDER, COUNT(*) n FROM patients GROUP BY GENDER")

# 4. Les 20 diagnostics les plus fréquents (en nombre de patients)
dbGetQuery(con, "
  SELECT DESCRIPTION, COUNT(DISTINCT PATIENT) AS n_patients
  FROM conditions
  GROUP BY DESCRIPTION
  ORDER BY n_patients DESC
  LIMIT 20")





