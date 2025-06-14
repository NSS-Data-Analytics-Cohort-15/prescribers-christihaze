--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;
--1a. 1881634483, 99707

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims
SELECT p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description, SUM(total_claim_count)
FROM prescription
INNER JOIN prescriber AS p
ON prescription.npi = p.npi
GROUP BY p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description
ORDER BY SUM(total_claim_count) DESC;
--1b."BRUCE", "PENDLEY", "Family Practice", 99707

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p.specialty_description, SUM(total_claim_count)
FROM prescription
INNER JOIN prescriber AS p
ON prescription.npi = p.npi
GROUP BY p.specialty_description
ORDER BY SUM(total_claim_count) DESC;
--2a."Family Practice", 9752347

--2b. Which specialty had the most total number of claims for opioids?
SELECT p.specialty_description, SUM(total_claim_count), drug.opioid_drug_flag
FROM prescription
INNER JOIN prescriber AS p
ON prescription.npi = p.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY p.specialty_description,drug.opioid_drug_flag 
ORDER BY SUM(total_claim_count) DESC;
--2b. "Nurse Practitioner"

--c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3a. Which drug (generic_name) had the highest total drug cost?
SELECT  generic_name, SUM(prescription.total_drug_cost)
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC;
--3a."INSULIN GLARGINE,HUM.REC.ANLOG", 104264066.35

--3b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
SELECT  generic_name, ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply),2)
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply),2) DESC;
--3b."C1 ESTERASE INHIBITOR", 3495.22

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT CAST(SUM(prescription.total_drug_cost)as money),
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;
--4b.Opioid

--5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
SELECT *
FROM cbsa
WHERE cbsaname iLIKE '%TN';
--5a. 33

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population)
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) DESC;
--5b. "Nashville-Davidson--Murfreesboro--Franklin, TN",	1830410

--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT fips_county.county, SUM(population)
FROM population
INNER JOIN fips_county
ON population.fipscounty = fips_county.fipscounty
GROUP BY fips_county.county
ORDER BY SUM(population) DESC;
--5c. "SHELBY", 937847

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug.drug_name, total_claim_count,
   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM prescription
CROSS JOIN  drug
WHERE total_claim_count >= 3000;
--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug.drug_name, total_claim_count,
   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	     WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type,
	CONCAT(nppes_provider_first_name, ' ',nppes_provider_last_org_name) AS prescriber_name
FROM prescription
CROSS JOIN  drug
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE total_claim_count >= 3000;

--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT prescriber.npi, drug.drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescriber.npi, drug.drug_name, prescription.total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';
--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name,COALESCE((prescription.total_claim_count),0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' 
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';