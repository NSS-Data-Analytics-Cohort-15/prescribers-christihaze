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
